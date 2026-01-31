module header_insertion (clock, reset, tready_out, tvalid_in, tdata_in, tlast_in, tkeep_in, tready_in, tvalid_out, tdata_out, tlast_out, tkeep_out, header_data);

	parameter BITS_PER_BEAT = 512;
	parameter HEADER_SIZE = 112;
	parameter PIPELINE_DEPTH = 8;				// Maximum number of clock cycles between tvalid and tready
	
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BYTES_PER_HEADER = HEADER_SIZE/8;
	localparam BACK_PRESSURE_DEPTH = 32;
	localparam LEFTOVER_DATA_SIZE = HEADER_SIZE;
	localparam LEFTOVER_BYTES = LEFTOVER_DATA_SIZE/8;

	input clock;
	input reset;
	output reg tready_out;
	input tvalid_in;
	input [BITS_PER_BEAT-1:0] tdata_in;
	input tlast_in;
	input [BITS_PER_BEAT/8-1:0] tkeep_in;
	input tready_in;
	output reg tvalid_out;
	output reg [BITS_PER_BEAT-1:0] tdata_out;
	output reg tlast_out;
	output reg [BITS_PER_BEAT/8-1:0] tkeep_out;
	input [HEADER_SIZE-1:0] header_data;

	reg fifo_write_enable;
	reg [BITS_PER_BEAT-1:0] fifo_data_in;
	wire [BITS_PER_BEAT-1:0] fifo_data_out;
	wire fifo_data_valid;
	wire fifo_data_empty;
	wire fifo_data_full;
	wire fifo_control_valid;
	wire fifo_control_empty;
	wire fifo_control_full;
	
	localparam WAIT_FOR_DATA = 8'h01;
	localparam CAPTURE_HEADER = 8'h02;
	localparam STORE_REMAINING_DATA = 8'h04;
	localparam TRANSMIT_EXTRA_BEAT = 8'h08;
	localparam END_BUS_TRANSACTION = 8'h10;
	localparam WAIT_FOR_END_OF_DATA = 8'h20;
	localparam SAMPLE_HEADER_DATA = 8'h40;
	
	reg [7:0] header_insertion_state;
	
	wire fifo_read_enable;
	
	generate
		if (BITS_PER_BEAT == HEADER_SIZE) begin : same_data_size
			reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
			reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
			reg [CONTROL_DATA_SIZE-1:0] fifo_control_in;
			wire [CONTROL_DATA_SIZE-1:0] fifo_control_out;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;

			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					fifo_control_in			<= 0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
					tready_out				<= 1'b0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= header_data;
								tready_out				<= 1'b1;
								header_insertion_state	<= CAPTURE_HEADER;
							end
							else begin
								tready_out				<= 1'b0;
							end
						end
						CAPTURE_HEADER:
						begin
							tready_out				<= 1'b1;
							
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= tdata_in;
								fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in};
								header_insertion_state	<= STORE_REMAINING_DATA;
							end
							else begin
								fifo_write_enable		<= 1'b0;
							end
						end
						STORE_REMAINING_DATA:
						begin
							tready_out				<= 1'b1;
							
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= tdata_in;

								if (tlast_in) begin								
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in};
									header_insertion_state	<= END_BUS_TRANSACTION;
								end
								else begin
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in};
								end
							end
							else begin
								fifo_write_enable		<= 1'b0;
							end
						end
						TRANSMIT_EXTRA_BEAT:
						begin
							fifo_write_enable		<= 1'b1;
							fifo_data_in			<= tdata_in;
							fifo_control_in			<= {1'b1, 1'b1, {(BYTES_PER_BEAT){1'b1}}};
							header_insertion_state	<= END_BUS_TRANSACTION;
						end
						END_BUS_TRANSACTION:
						begin
							tready_out				<= 1'b0;
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							header_insertion_state	<= WAIT_FOR_END_OF_DATA;
						end
						WAIT_FOR_END_OF_DATA:
						begin
							if (last_reg) begin
								header_insertion_state	<= WAIT_FOR_DATA;
							end
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end

			fifo_to_axis #(BITS_PER_BEAT, PIPELINE_DEPTH) tdata_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_data_empty), .fifo_full(fifo_data_full), .fifo_data_out(fifo_data_out), .fifo_data_valid(fifo_data_valid), .tready_in(tready_in), .tvalid_out(data_valid_reg), .tdata_out(data_reg), .tlast_out(last_reg));
			fifo_to_axis #(BITS_PER_BEAT/8 + 2, PIPELINE_DEPTH) control_signal_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_control_empty), .fifo_full(fifo_control_full), .fifo_data_out(fifo_control_out), .fifo_data_valid(fifo_control_valid), .tready_in(tready_in), .tvalid_out(control_valid_reg), .tdata_out(control_data_reg), .tlast_out(control_last_reg));
			
			always @(control_data_reg or data_reg or data_valid_reg) begin
				tvalid_out	<= data_valid_reg;	// control_data_reg[CONTROL_DATA_SIZE-1];
				tdata_out	<= data_reg;
				tlast_out	<= control_last_reg;	// control_data_reg[CONTROL_DATA_SIZE-2];
				tkeep_out	<= control_data_reg[BYTES_PER_BEAT-1:0];
			end
		end
		else if (BITS_PER_BEAT > HEADER_SIZE) begin : large_data_size
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
			reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
			reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
			reg [CONTROL_DATA_SIZE-1:0] fifo_control_in;
			wire [CONTROL_DATA_SIZE-1:0] fifo_control_out;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;
		
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					fifo_control_in			<= 0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
					tready_out				<= 1'b0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							tkeep_leftover			<= {LEFTOVER_BYTES{1'b1}};
							
							if (tvalid_in) begin
								tready_out				<= 1'b1;
								header_insertion_state	<= CAPTURE_HEADER;
							end
							else begin
								tready_out				<= 1'b0;
							end
						end
						CAPTURE_HEADER:
						begin
							tready_out				<= 1'b1;
							
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= {tdata_in[BITS_PER_BEAT-LEFTOVER_DATA_SIZE-1:0], header_data};
								tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:HEADER_SIZE];		// tdata_in[HEADER_SIZE-1:0];
								tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT-1)-:BYTES_PER_HEADER];	// tkeep_in[BYTES_PER_HEADER-1:0];

								if (tlast_in) begin
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-LEFTOVER_BYTES-1:0], tkeep_leftover};
									header_insertion_state	<= END_BUS_TRANSACTION;
								end
								else begin
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-LEFTOVER_BYTES-1:0], {BYTES_PER_HEADER{1'b1}}};
									header_insertion_state	<= STORE_REMAINING_DATA;
								end
							end
							else begin
								fifo_write_enable		<= 1'b0;
							end
						end
						STORE_REMAINING_DATA:
						begin
							tready_out				<= 1'b1;
							
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= {tdata_in[BITS_PER_BEAT-LEFTOVER_DATA_SIZE-1:0], tdata_leftover};
								tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:HEADER_SIZE];
								tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT-1)-:BYTES_PER_HEADER];

								if (tlast_in) begin								
									if (tkeep_in[(BYTES_PER_BEAT-1)-:BYTES_PER_HEADER] != 0) begin
										fifo_control_in			<= {tvalid_in, 1'b0, tkeep_in[BYTES_PER_BEAT-LEFTOVER_BYTES-1:0], tkeep_leftover};
										header_insertion_state	<= TRANSMIT_EXTRA_BEAT;
									end
									else begin
										fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-LEFTOVER_BYTES-1:0], tkeep_leftover};
										header_insertion_state	<= END_BUS_TRANSACTION;
									end
								end
								else begin
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-LEFTOVER_BYTES-1:0], tkeep_leftover};
								end
							end
							else begin
								fifo_write_enable		<= 1'b0;
							end
						end
						TRANSMIT_EXTRA_BEAT:
						begin
							fifo_write_enable		<= 1'b1;
							fifo_data_in			<= {{(BITS_PER_BEAT-HEADER_SIZE){1'b0}}, tdata_leftover};
							fifo_control_in			<= {1'b1, 1'b1, {(BYTES_PER_BEAT-BYTES_PER_HEADER){1'b0}}, tkeep_leftover};
							header_insertion_state	<= END_BUS_TRANSACTION;
						end
						END_BUS_TRANSACTION:
						begin
							tready_out				<= 1'b0;
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							header_insertion_state	<= WAIT_FOR_END_OF_DATA;
						end
						WAIT_FOR_END_OF_DATA:
						begin
							if (last_reg) begin
								header_insertion_state	<= WAIT_FOR_DATA;
							end
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end

			fifo_to_axis #(BITS_PER_BEAT, PIPELINE_DEPTH) tdata_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_data_empty), .fifo_full(fifo_data_full), .fifo_data_out(fifo_data_out), .fifo_data_valid(fifo_data_valid), .tready_in(tready_in), .tvalid_out(data_valid_reg), .tdata_out(data_reg), .tlast_out(last_reg));
			fifo_to_axis #(BITS_PER_BEAT/8 + 2, PIPELINE_DEPTH) control_signal_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_control_empty), .fifo_full(fifo_control_full), .fifo_data_out(fifo_control_out), .fifo_data_valid(fifo_control_valid), .tready_in(tready_in), .tvalid_out(control_valid_reg), .tdata_out(control_data_reg), .tlast_out(control_last_reg));
			
			always @(control_data_reg or data_reg or data_valid_reg) begin
				tvalid_out	<= data_valid_reg;	// control_data_reg[CONTROL_DATA_SIZE-1];
				tdata_out	<= data_reg;
				tlast_out	<= control_last_reg;	// control_data_reg[CONTROL_DATA_SIZE-2];
				tkeep_out	<= control_data_reg[(CONTROL_DATA_SIZE-3)-:BYTES_PER_BEAT];
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : small_data_size_even
			reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
			reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
			reg [CONTROL_DATA_SIZE-1:0] fifo_control_in;
			wire [CONTROL_DATA_SIZE-1:0] fifo_control_out;
			integer byte_counter;
			reg [HEADER_SIZE-1:0] header_shift_register;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;

			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, CONTROL_DATA_SIZE) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					fifo_control_in			<= 0;
					byte_counter			<= 0;
					header_shift_register	<= 0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							
							if (tvalid_in) begin
								tready_out				<= 1'b0;
								header_insertion_state	<= SAMPLE_HEADER_DATA;
							end
							else begin
								tready_out				<= 1'b0;
							end
						end
						SAMPLE_HEADER_DATA:
						begin
							header_shift_register	<= header_data;
							header_insertion_state	<= CAPTURE_HEADER;
						end
						CAPTURE_HEADER:
						begin
							if (tvalid_in) begin
								if (byte_counter < BYTES_PER_HEADER) begin
									tready_out				<= 1'b0;
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= header_shift_register[BITS_PER_BEAT-1:0];
									fifo_control_in			<= {tvalid_in, tlast_in, {6{1'b1}}};
									byte_counter			<= byte_counter + BYTES_PER_BEAT;
									header_shift_register	<= header_shift_register >> BITS_PER_BEAT;
								end
								else begin
									tready_out				<= 1'b1;
									fifo_write_enable		<= 1'b0;
									fifo_data_in			<= tdata_in;	// header_shift_register[BITS_PER_BEAT-1:0];
									fifo_control_in			<= {tvalid_in, tlast_in, {30{1'b1}}};
									header_insertion_state	<= STORE_REMAINING_DATA;
								end
							end
						end
						STORE_REMAINING_DATA:
						begin
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= tdata_in;
								fifo_control_in			<= {tvalid_in, tlast_in, {30{1'b1}}};
								
								if (tlast_in) begin
									tready_out				<= 1'b1;
									header_insertion_state	<= END_BUS_TRANSACTION;
								end
								else begin
									tready_out				<= 1'b1;
								end
							end								
							else begin
								fifo_write_enable		<= 1'b0;
							end
						end
						END_BUS_TRANSACTION:
						begin
							tready_out				<= 1'b0;
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							header_insertion_state	<= WAIT_FOR_END_OF_DATA;
						end
						WAIT_FOR_END_OF_DATA:
						begin
							if (last_reg) begin
								byte_counter			<= 0;
								header_insertion_state	<= WAIT_FOR_DATA;
							end
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end

			fifo_to_axis #(BITS_PER_BEAT, PIPELINE_DEPTH) tdata_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_data_empty), .fifo_full(fifo_data_full), .fifo_data_out(fifo_data_out), .fifo_data_valid(fifo_data_valid), .tready_in(tready_in), .tvalid_out(data_valid_reg), .tdata_out(data_reg), .tlast_out(last_reg));
			fifo_to_axis #(BITS_PER_BEAT/8 + 2, PIPELINE_DEPTH) control_signal_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_control_empty), .fifo_full(fifo_control_full), .fifo_data_out(fifo_control_out), .fifo_data_valid(fifo_control_valid), .tready_in(tready_in), .tvalid_out(control_valid_reg), .tdata_out(control_data_reg), .tlast_out(control_last_reg));
			
			always @(control_data_reg or data_reg or data_valid_reg) begin
				tvalid_out	<= data_valid_reg;	// control_data_reg[CONTROL_DATA_SIZE-1];
				tdata_out	<= data_reg;
				tlast_out	<= control_last_reg;	// control_data_reg[CONTROL_DATA_SIZE-2];
				tkeep_out	<= control_data_reg[BYTES_PER_BEAT-1:0];
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) != 0) begin : small_data_size_odd
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;

			localparam real header_size_real = HEADER_SIZE;
			localparam real bits_per_beat_real = BITS_PER_BEAT;
			localparam real header_leftover_real = header_size_real - $floor(header_size_real/bits_per_beat_real) * bits_per_beat_real;
			localparam real header_leftover_real_bytes = header_leftover_real/8;
			localparam integer header_leftover_int = header_leftover_real;
			localparam integer header_leftover_int_bytes = header_leftover_real_bytes;
			localparam tdata_leftover_int = header_leftover_int;
			localparam tkeep_leftover_int = tdata_leftover_int/8;
			
			reg [CONTROL_DATA_SIZE-1:0] fifo_control_in;
			wire [CONTROL_DATA_SIZE-1:0] fifo_control_out;
			integer byte_counter;
			reg [HEADER_SIZE-1:0] header_shift_register;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;
			reg [header_leftover_int-1:0] tdata_leftover;
			reg [header_leftover_int_bytes-1:0] tkeep_leftover;

			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, CONTROL_DATA_SIZE) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					fifo_control_in			<= 0;
					byte_counter			<= 0;
					header_shift_register	<= 0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							
							if (tvalid_in) begin
								tready_out				<= 1'b0;
								byte_counter			<= 0;
								header_insertion_state	<= SAMPLE_HEADER_DATA;
							end
							else begin
								tready_out				<= 1'b0;
							end
						end
						SAMPLE_HEADER_DATA:
						begin
							header_shift_register	<= header_data;
							header_insertion_state	<= CAPTURE_HEADER;
						end
						CAPTURE_HEADER:
						begin
							if (tvalid_in) begin
								if (byte_counter < BYTES_PER_HEADER-BYTES_PER_BEAT) begin
									if (byte_counter < BYTES_PER_HEADER-2*BYTES_PER_BEAT) begin
										tready_out		<= 1'b0;
									end
									else begin
										tready_out		<= 1'b1;
									end
									
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= header_shift_register[BITS_PER_BEAT-1:0];
									fifo_control_in			<= {tvalid_in, tlast_in, {(CONTROL_DATA_SIZE-2){1'b1}}};
									byte_counter			<= byte_counter + BYTES_PER_BEAT;
									header_shift_register	<= header_shift_register >> BITS_PER_BEAT;
								end
								else begin
									tready_out				<= 1'b1;
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= {tdata_in[BITS_PER_BEAT-tdata_leftover_int-1:0], header_shift_register[tdata_leftover_int-1:0]};
									fifo_control_in			<= {tvalid_in, tlast_in, {(CONTROL_DATA_SIZE-2){1'b1}}};
									tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:tdata_leftover_int];
									tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT)-:tkeep_leftover_int];
									header_insertion_state	<= STORE_REMAINING_DATA;
								end
							end
						end
						STORE_REMAINING_DATA:
						begin
							if (tvalid_in) begin
								fifo_write_enable		<= 1'b1;
								
								if (tlast_in) begin
									if (tkeep_in[(BYTES_PER_BEAT-1)-:BYTES_PER_HEADER] == {BYTES_PER_HEADER{1'b0}}) begin
										tready_out				<= 1'b1;
										fifo_data_in			<= {{tdata_leftover_int{1'b0}}, tdata_leftover};
										fifo_control_in			<= {tvalid_in, tlast_in, {(30-header_leftover_int_bytes){1'b0}}, tkeep_leftover};
										header_insertion_state	<= END_BUS_TRANSACTION;
									end
									else begin
										tready_out				<= 1'b1;
										fifo_data_in			<= {tdata_in[tdata_leftover_int-1:0], tdata_leftover};
										fifo_control_in			<= {tvalid_in, tlast_in, {30{1'b1}}};
										tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:tdata_leftover_int];
										tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT)-:tkeep_leftover_int];
										header_insertion_state	<= TRANSMIT_EXTRA_BEAT;
									end
								end
								else begin
									fifo_data_in			<= {tdata_in[tdata_leftover_int-1:0], tdata_leftover};
									fifo_control_in			<= {tvalid_in, tlast_in, {30{1'b1}}};
									tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:tdata_leftover_int];
									tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT)-:tkeep_leftover_int];
									tready_out				<= 1'b1;
								end
							end								
							else begin
								fifo_write_enable		<= 1'b0;
							end
						end
						TRANSMIT_EXTRA_BEAT:
						begin
							fifo_write_enable		<= 1'b1;
							fifo_data_in			<= {{(BITS_PER_BEAT-header_leftover_int){1'b0}}, tdata_leftover};
							fifo_control_in			<= {1'b1, 1'b1, {((BITS_PER_BEAT-header_leftover_int)/8){1'b0}}, tkeep_leftover};
							header_insertion_state	<= END_BUS_TRANSACTION;
						end
						END_BUS_TRANSACTION:
						begin
							tready_out				<= 1'b0;
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_control_in			<= 0;
							header_insertion_state	<= WAIT_FOR_END_OF_DATA;
						end
						WAIT_FOR_END_OF_DATA:
						begin
							if (last_reg) begin
								byte_counter			<= 0;
								header_insertion_state	<= WAIT_FOR_DATA;
							end
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end

			fifo_to_axis #(BITS_PER_BEAT, PIPELINE_DEPTH) tdata_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_data_empty), .fifo_full(fifo_data_full), .fifo_data_out(fifo_data_out), .fifo_data_valid(fifo_data_valid), .tready_in(tready_in), .tvalid_out(data_valid_reg), .tdata_out(data_reg), .tlast_out(last_reg));
			fifo_to_axis #(BITS_PER_BEAT/8 + 2, PIPELINE_DEPTH) control_signal_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_control_empty), .fifo_full(fifo_control_full), .fifo_data_out(fifo_control_out), .fifo_data_valid(fifo_control_valid), .tready_in(tready_in), .tvalid_out(control_valid_reg), .tdata_out(control_data_reg), .tlast_out(control_last_reg));
			
			always @(control_data_reg or data_reg or data_valid_reg) begin
				tvalid_out	<= data_valid_reg;	// control_data_reg[CONTROL_DATA_SIZE-1];
				tdata_out	<= data_reg;
				tlast_out	<= control_last_reg;	// control_data_reg[CONTROL_DATA_SIZE-2];
				tkeep_out	<= control_data_reg[BYTES_PER_BEAT-1:0];
			end
		end
	endgenerate
endmodule
