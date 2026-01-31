// This module inserts a single set of data into a datagram (used by ARP and ICMP)

module command_insertion (clock, reset, tready_in, tvalid_out, tdata_out, tlast_out, tkeep_out, header_data_valid, header_data);

	parameter BITS_PER_BEAT = 512;
	parameter HEADER_SIZE = 112;
	parameter PIPELINE_DEPTH = 8;				// Maximum number of clock cycles between tvalid and tready
	
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BYTES_PER_HEADER = HEADER_SIZE/8;
	localparam BACK_PRESSURE_DEPTH = 32;
	localparam LEFTOVER_DATA_SIZE = HEADER_SIZE;
	localparam LEFTOVER_BYTES = LEFTOVER_DATA_SIZE/8;
	
	localparam real bits_per_beat_real = BITS_PER_BEAT;
	localparam real header_size_real = HEADER_SIZE;
	localparam real datagram_padding_real = $ceil(header_size_real/bits_per_beat_real) * bits_per_beat_real - header_size_real;
	localparam integer DATA_PADDING = datagram_padding_real;
	localparam TKEEP_PADDING = DATA_PADDING/8;

	input clock;
	input reset;
	input tready_in;
	output reg tvalid_out;
	output reg [BITS_PER_BEAT-1:0] tdata_out;
	output reg tlast_out;
	output reg [BITS_PER_BEAT/8-1:0] tkeep_out;
	input header_data_valid;
	input [HEADER_SIZE-1:0] header_data;

	reg fifo_write_enable;
	reg [BITS_PER_BEAT-1:0] fifo_data_in;
	wire [BITS_PER_BEAT-1:0] fifo_data_out;
	wire fifo_data_valid;
	wire fifo_data_empty;
	wire fifo_data_full;
	reg [BYTES_PER_BEAT-1:0] fifo_keep_in;
	wire keep_read_enable;
	wire [BYTES_PER_BEAT-1:0] fifo_keep_out;
	wire fifo_keep_valid;
	wire fifo_keep_empty;
	wire fifo_keep_full;
	wire keep_valid_reg;
	wire [BYTES_PER_BEAT-1:0] keep_reg;
	wire keep_last_reg;
	
	localparam WAIT_FOR_DATA = 8'h01;
	localparam CAPTURE_HEADER = 8'h02;
	localparam WAIT_FOR_PENDING_CLEAR = 8'h04;
	localparam END_BUS_TRANSACTION = 8'h10;
	localparam WAIT_FOR_END_OF_DATA = 8'h20;
	localparam SAMPLE_HEADER_DATA = 8'h40;
	
	reg [7:0] header_insertion_state;
	
	wire fifo_read_enable;
	reg header_data_pending;
	reg clear_header_pending;
	
	generate
		if (BITS_PER_BEAT == HEADER_SIZE) begin : same_data_size
			reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
			reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;

			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	

			always @(posedge clock) begin
				if (header_data_valid) begin
					header_data_pending	<= 1'b1;
				end
				else if (clear_header_pending) begin
					header_data_pending	<= 1'b0;
				end
			end
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
					clear_header_pending	<= 1'b0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							
							if (header_data_pending) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= header_data;
								clear_header_pending	<= 1'b1;
								header_insertion_state	<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							
							if (!header_data_pending) begin
								clear_header_pending	<= 1'b0;
								header_insertion_state	<= WAIT_FOR_END_OF_DATA;
							end
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
			
			always @(data_reg or data_valid_reg) begin
				if (data_valid_reg) begin
					tvalid_out	<= 1'b1;	// control_data_reg[CONTROL_DATA_SIZE-1];
					tdata_out	<= data_reg;
					tlast_out	<= 1'b1;			// control_data_reg[CONTROL_DATA_SIZE-2];
					tkeep_out	<= {BYTES_PER_BEAT{1'b1}};
				end
				else begin
					tvalid_out	<= 1'b0;	// control_data_reg[CONTROL_DATA_SIZE-1];
					tdata_out	<= 0;
					tlast_out	<= 1'b0;			// control_data_reg[CONTROL_DATA_SIZE-2];
					tkeep_out	<= {BYTES_PER_BEAT{1'b0}};
				end
			end
		end
		else if (BITS_PER_BEAT > HEADER_SIZE) begin : large_data_size
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
			reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
			reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
		
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
					clear_header_pending	<= 1'b0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							tkeep_leftover			<= {LEFTOVER_BYTES{1'b1}};
							
							if (header_data_pending) begin
								clear_header_pending	<= 1'b1;
								header_insertion_state	<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							
							if (!header_data_pending) begin
								clear_header_pending	<= 1'b0;
								header_insertion_state	<= CAPTURE_HEADER;
							end
						end
						CAPTURE_HEADER:
						begin
							fifo_write_enable		<= 1'b1;
							fifo_data_in			<= {{(BITS_PER_BEAT-HEADER_SIZE){1'b0}}, header_data};
							header_insertion_state	<= END_BUS_TRANSACTION;
						end
						END_BUS_TRANSACTION:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
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
			
			always @(data_reg or data_valid_reg) begin
				if (data_valid_reg) begin
					tvalid_out	<= 1'b1;
					tdata_out	<= data_reg;
					tlast_out	<= 1'b1;
					tkeep_out	<= {{TKEEP_PADDING{1'b0}}, {BYTES_PER_HEADER{1'b1}}};
				end
				else begin
					tvalid_out	<= 1'b0;
					tdata_out	<= 0;
					tlast_out	<= 1'b0;
					tkeep_out	<= 0;
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : small_data_size_even
			reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
			reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
			localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
			integer byte_counter;
			reg [HEADER_SIZE-1:0] header_shift_register;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;

			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					byte_counter			<= 0;
					header_shift_register	<= 0;
					clear_header_pending	<= 1'b0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							
							if (header_data_pending) begin
								clear_header_pending	<= 1'b1;
								header_insertion_state	<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							
							if (!header_data_pending) begin
								header_shift_register	<= header_data;
								clear_header_pending	<= 1'b0;
								header_insertion_state	<= CAPTURE_HEADER;
							end
						end
						CAPTURE_HEADER:
						begin
							if (byte_counter < BYTES_PER_HEADER) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= header_shift_register[BITS_PER_BEAT-1:0];
								byte_counter			<= byte_counter + BYTES_PER_BEAT;
								header_shift_register	<= header_shift_register >> BITS_PER_BEAT;
							end
							else begin
								header_insertion_state	<= END_BUS_TRANSACTION;
							end
						end
						END_BUS_TRANSACTION:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
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
			
			always @(data_reg or data_valid_reg) begin
				if (data_valid_reg) begin
					tvalid_out	<= 1'b1;
					tdata_out	<= data_reg;
					tlast_out	<= last_reg;	// control_data_reg[CONTROL_DATA_SIZE-2];
					tkeep_out	<= {BYTES_PER_BEAT{1'b1}};
				end
				else begin
					tvalid_out	<= 1'b0;
					tdata_out	<= 0;
					tlast_out	<= 1'b0;
					tkeep_out	<= 0;
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) != 0) begin : small_data_size_odd
			localparam real header_size_real = HEADER_SIZE;
			localparam real bits_per_beat_real = BITS_PER_BEAT;
			localparam real header_leftover_real = header_size_real - $floor(header_size_real/bits_per_beat_real) * bits_per_beat_real;
			localparam real header_leftover_real_bytes = header_leftover_real/8;
			localparam integer header_leftover_int = header_leftover_real;
			localparam integer header_leftover_int_bytes = header_leftover_real_bytes;
			localparam tdata_leftover_int = BITS_PER_BEAT - header_leftover_int;
			localparam tkeep_leftover_int = tdata_leftover_int/8;
			
			integer byte_counter;
			reg [HEADER_SIZE-1:0] header_shift_register;
			reg [BYTES_PER_HEADER-1:0] tkeep_shift_register;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;

			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) keep_memory (clock, reset, fifo_write_enable, fifo_keep_in, keep_read_enable, fifo_keep_out, fifo_keep_valid, fifo_keep_empty, fifo_keep_full);	
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					fifo_keep_in			<= 0;
					byte_counter			<= 0;
					header_shift_register	<= 0;
					tkeep_shift_register	<= 0;
					clear_header_pending	<= 1'b0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_keep_in			<= 0;

							if (header_data_pending) begin
								byte_counter			<= 0;
								header_shift_register	<= header_data;
								tkeep_shift_register	<= {BYTES_PER_HEADER{1'b1}};
								clear_header_pending	<= 1'b1;
								header_insertion_state	<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_keep_in			<= 0;
							
							if (!header_data_pending) begin
								clear_header_pending	<= 1'b0;
								header_insertion_state	<= CAPTURE_HEADER;
							end
						end
						CAPTURE_HEADER:
						begin
							if (byte_counter < BYTES_PER_HEADER-BYTES_PER_BEAT) begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= header_shift_register[BITS_PER_BEAT-1:0];
								fifo_keep_in			<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
								byte_counter			<= byte_counter + BYTES_PER_BEAT;
								header_shift_register	<= header_shift_register >> BITS_PER_BEAT;
								tkeep_shift_register	<= tkeep_shift_register >> BYTES_PER_BEAT;
							end
							else begin
								fifo_write_enable		<= 1'b1;
								fifo_data_in			<= {{DATA_PADDING{1'b0}}, header_shift_register[header_leftover_int-1:0]};
								fifo_keep_in			<= {{TKEEP_PADDING{1'b0}}, tkeep_shift_register[BYTES_PER_BEAT-1:0]};
								header_insertion_state	<= END_BUS_TRANSACTION;
							end
						end
						END_BUS_TRANSACTION:
						begin
							fifo_write_enable		<= 1'b0;
							fifo_data_in			<= 0;
							fifo_keep_in			<= 0;
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
			fifo_to_axis #(BYTES_PER_BEAT, PIPELINE_DEPTH) tkeep_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_keep_empty), .fifo_full(fifo_keep_full), .fifo_data_out(fifo_keep_out), .fifo_data_valid(fifo_keep_valid), .tready_in(tready_in), .tvalid_out(keep_valid_reg), .tdata_out(keep_reg), .tlast_out(keep_last_reg));
			
			always @(data_reg or data_valid_reg or keep_reg) begin
				if (data_valid_reg) begin
					tvalid_out	<= 1'b1;	// control_data_reg[CONTROL_DATA_SIZE-1];
					tdata_out	<= data_reg;
					tkeep_out	<= keep_reg;
					tlast_out	<= last_reg;
				end
				else begin
					tvalid_out	<= 1'b0;
					tdata_out	<= 0;
					tlast_out	<= 1'b0;
					tkeep_out	<= 0;
				end
			end
		end
	endgenerate
endmodule
