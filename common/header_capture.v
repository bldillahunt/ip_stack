module header_capture (clock, reset, tready_out, tvalid_in, tdata_in, tlast_in, tkeep_in, tready_in, tvalid_out, tdata_out, tlast_out, tkeep_out, header_data);
	parameter BITS_PER_BEAT = 512;
	parameter HEADER_SIZE = 112;
	
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BYTES_PER_HEADER = HEADER_SIZE/8;
	localparam BACK_PRESSURE_DEPTH = 32;
	localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;

	localparam real header_size_real = HEADER_SIZE;
	localparam real bit_per_beat_real = BITS_PER_BEAT;
	localparam integer HEADER_SHIFT_REG_SIZE = $ceil(header_size_real/bit_per_beat_real)*bit_per_beat_real;
	localparam integer DATA_IN_LEFTOVER = $ceil(header_size_real/bit_per_beat_real) * bit_per_beat_real - header_size_real;
	localparam KEEP_LEFTOVER = DATA_IN_LEFTOVER/8;
	localparam DATA_IN_TRUNCATED = BITS_PER_BEAT - DATA_IN_LEFTOVER;
	localparam KEEP_IN_TRUNCATED = DATA_IN_TRUNCATED/8;
	localparam READ_LATENCY = 4;

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
	output reg [HEADER_SIZE-1:0] header_data;
	
	localparam [7:0] WAIT_FOR_DATA = 8'b00000001;
	localparam [7:0] CAPTURE_HEADER = 8'b00000010;
	localparam [7:0] TRANSMIT_REMAINING_DATA = 8'b00000100;
	localparam [7:0] WAIT_FOR_END_OF_DATA = 8'b00001000;
	localparam [7:0] TRANSMIT_EXTRA_BEAT = 8'b00010000;

	reg [7:0] header_state;
	
	localparam [3:0] WAIT_FOR_FIFO_READY = 4'h1;
	localparam [3:0] WAIT_FOR_OUTPUT_READY = 4'h2;
	localparam [3:0] EMPTY_SHIFT_REGISTERS = 4'h4;
	localparam [3:0] END_OF_TRANSMIT = 4'h8;
	
	reg [3:0] capture_output_state;
	
	reg fifo_write_enable;
	reg [BITS_PER_BEAT-1:0] fifo_data_in;
	wire [BITS_PER_BEAT-1:0] fifo_data_out;
	wire fifo_data_valid;
	wire fifo_data_empty;
	wire fifo_data_full;
	reg [CONTROL_DATA_SIZE-1:0] fifo_control_in;
	wire [CONTROL_DATA_SIZE-1:0] fifo_control_out;
	wire fifo_control_valid;
	wire fifo_control_empty;
	wire fifo_control_full;
	integer byte_counter;
	integer header_byte_counter;
	reg [READ_LATENCY*BITS_PER_BEAT-1:0] data_shift_register;
	reg [READ_LATENCY*CONTROL_DATA_SIZE-1:0] control_shift_register;
	integer fifo_read_counter;
	
	generate
		reg [HEADER_SHIFT_REG_SIZE-1:0] header_shift_register;
		
		if (BITS_PER_BEAT == HEADER_SIZE) begin : same_data_size
			reg fifo_read_enable;
			localparam LEFT_OVER_DATA_SIZE = BITS_PER_BEAT - HEADER_SIZE;
			localparam LEFT_OVER_TKEEP_SIZE = LEFT_OVER_DATA_SIZE/8;
			reg [LEFT_OVER_DATA_SIZE-1:0] leftover_tdata;
			reg [LEFT_OVER_TKEEP_SIZE-1:0] leftover_tkeep;
			
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state		<= WAIT_FOR_DATA;
					tready_out			<= 1'b0;
					header_data			<= 0;
					fifo_write_enable	<= 1'b0;
					fifo_data_in		<= 0;
				end
				else begin
					case (header_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								header_state		<= CAPTURE_HEADER;
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						CAPTURE_HEADER:
						begin
							header_data			<= tdata_in;
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							header_state		<= TRANSMIT_REMAINING_DATA;
						end
						TRANSMIT_REMAINING_DATA:
						begin
							fifo_write_enable	<= tvalid_in;
							fifo_data_in		<= tdata_in;
							fifo_control_in		<= {tvalid_in, tlast_in, tkeep_in};
							
							if (tlast_in) begin
								header_state		<= WAIT_FOR_END_OF_DATA;
							end
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							
							if (fifo_data_empty && fifo_control_empty) begin
								header_state		<= WAIT_FOR_DATA;
							end
						end
						default : header_state		<= WAIT_FOR_DATA;
					endcase
				end
			end
			
			always @(posedge clock) begin
				if ((!fifo_data_empty) && (!fifo_data_valid)) begin
					fifo_read_enable	<= 1'b1;
				end
				else if ((!fifo_data_empty) && (tready_in)) begin
					fifo_read_enable	<= 1'b1;
				end
				else begin
					fifo_read_enable	<= 1'b0;
				end
					
				if (tready_in && (fifo_data_valid && fifo_control_valid)) begin
					tvalid_out		<= fifo_control_out[CONTROL_DATA_SIZE-1];
					tdata_out		<= fifo_data_out;
					tlast_out		<= fifo_control_out[CONTROL_DATA_SIZE-2];
					tkeep_out		<= fifo_control_out[CONTROL_DATA_SIZE-3:0];
				end
				else begin
					tvalid_out		<= 1'b0;
					tlast_out		<= 1'b0;
				end
			end
		end
		else if (BITS_PER_BEAT > HEADER_SIZE) begin : large_data_size
			localparam LEFT_OVER_DATA_SIZE = BITS_PER_BEAT - HEADER_SIZE;
			localparam LEFT_OVER_TKEEP_SIZE = LEFT_OVER_DATA_SIZE/8;
			reg [LEFT_OVER_DATA_SIZE-1:0] leftover_tdata;
			reg [LEFT_OVER_TKEEP_SIZE-1:0] leftover_tkeep;
			reg [HEADER_SHIFT_REG_SIZE-1:0] header_shift_register;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;
			wire fifo_read_enable;
			
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state		<= WAIT_FOR_DATA;
					tready_out			<= 1'b0;
					header_data			<= 0;
					fifo_write_enable	<= 1'b0;
					fifo_data_in		<= 0;
					leftover_tdata		<= 0;
					leftover_tkeep		<= 0;
				end
				else begin
					case (header_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								header_state		<= CAPTURE_HEADER;
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						CAPTURE_HEADER:
						begin
							header_data			<= tdata_in[HEADER_SIZE-1:0];
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							leftover_tdata		<= tdata_in[BITS_PER_BEAT-1:HEADER_SIZE];
							leftover_tkeep		<= tkeep_in[BITS_PER_BEAT/8-1:BYTES_PER_HEADER];
							header_state		<= TRANSMIT_REMAINING_DATA;
						end
						TRANSMIT_REMAINING_DATA:
						begin
//							header_data			<= {tdata_in[HEADER_SIZE-1:0], leftover_tdata};
							leftover_tdata		<= tdata_in[BITS_PER_BEAT-1:HEADER_SIZE];
							leftover_tkeep		<= tkeep_in[BITS_PER_BEAT/8-1:BYTES_PER_HEADER];
							
							if (tlast_in) begin
								fifo_write_enable	<= tvalid_in;
								fifo_data_in		<= {tdata_in[HEADER_SIZE-1:0], leftover_tdata};
								fifo_control_in		<= {tvalid_in, 1'b1, tkeep_in[BYTES_PER_HEADER-1:0], leftover_tkeep};
								header_state		<= WAIT_FOR_END_OF_DATA;
							end
							else begin
								fifo_write_enable	<= tvalid_in;
								fifo_data_in		<= {tdata_in[HEADER_SIZE-1:0], leftover_tdata};
								fifo_control_in		<= {tvalid_in, 1'b0, tkeep_in[BYTES_PER_HEADER-1:0], leftover_tkeep};
							end
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							
							if (fifo_data_empty && fifo_control_empty) begin
								header_state		<= WAIT_FOR_DATA;
							end
						end
						default : header_state		<= WAIT_FOR_DATA;
					endcase
				end
			end

			fifo_to_axis #(BITS_PER_BEAT, 8) tdata_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_data_empty), .fifo_full(fifo_data_full), .fifo_data_out(fifo_data_out), .fifo_data_valid(fifo_data_valid), .tready_in(tready_in), .tvalid_out(data_valid_reg), .tdata_out(data_reg), .tlast_out(last_reg), .tkeep_out(keep_reg));
			fifo_to_axis #(CONTROL_DATA_SIZE, 8) control_signal_interface (.reset(reset), .clock(clock), .fifo_read_enable(fifo_read_enable), .fifo_empty(fifo_control_empty), .fifo_full(fifo_control_full), .fifo_data_out(fifo_control_out), .fifo_data_valid(fifo_control_valid), .tready_in(tready_in), .tvalid_out(control_valid_reg), .tdata_out(control_data_reg), .tlast_out(control_last_reg), .tkeep_out(control_keep_reg));
			
			always @(control_data_reg or data_reg or data_valid_reg) begin
				tvalid_out	<= data_valid_reg;	// control_data_reg[CONTROL_DATA_SIZE-1];
				tdata_out	<= data_reg;
				tlast_out	<= control_data_reg[CONTROL_DATA_SIZE-2];
				tkeep_out	<= control_data_reg[BYTES_PER_BEAT-1:0];
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) != 0) begin : not_evenly_divisible
			localparam LEFT_OVER_DATA_SIZE = DATA_IN_LEFTOVER;
			localparam LEFT_OVER_TKEEP_SIZE = LEFT_OVER_DATA_SIZE/8;
			reg [LEFT_OVER_DATA_SIZE-1:0] leftover_tdata;
			reg [LEFT_OVER_TKEEP_SIZE-1:0] leftover_tkeep;
			reg [HEADER_SHIFT_REG_SIZE-1:0] header_shift_register;
			reg fifo_read_enable;
			
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state			<= WAIT_FOR_DATA;
					tready_out				<= 1'b0;
					header_data				<= 0;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					leftover_tdata			<= 0;
					leftover_tkeep			<= 0;
					byte_counter			<= 0;
					header_shift_register	<= 0;
				end
				else begin
					case (header_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							byte_counter		<= 0;
							
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								header_state		<= CAPTURE_HEADER;
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						CAPTURE_HEADER:
						begin
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								
								if (byte_counter < BYTES_PER_HEADER-1) begin
									header_shift_register	<= {tdata_in[BITS_PER_BEAT-1:0], header_shift_register[HEADER_SHIFT_REG_SIZE-1:BITS_PER_BEAT]};
									byte_counter			<= byte_counter + BYTES_PER_BEAT;
									fifo_write_enable		<= 1'b0;
									fifo_data_in			<= 0;
									fifo_control_in			<= 0;
									leftover_tdata			<= tdata_in[(BITS_PER_BEAT-1)-:DATA_IN_LEFTOVER];
									leftover_tkeep			<= tkeep_in[(BYTES_PER_BEAT-1)-:KEEP_LEFTOVER];
								end
								else begin
									header_data				<= header_shift_register[HEADER_SIZE-1:0];
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= {tdata_in[DATA_IN_TRUNCATED-1:0], leftover_tdata};
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-KEEP_LEFTOVER-1:0], leftover_tkeep};
									leftover_tdata			<= tdata_in[(BITS_PER_BEAT-1)-:DATA_IN_LEFTOVER];
									leftover_tkeep			<= tkeep_in[(BYTES_PER_BEAT-1)-:KEEP_LEFTOVER];
									header_state			<= TRANSMIT_REMAINING_DATA;
								end
							end
						end
						TRANSMIT_REMAINING_DATA:
						begin
							if (tvalid_in) begin
								if (tlast_in) begin
									if (tkeep_in[(BYTES_PER_BEAT-1)-:KEEP_LEFTOVER] == 0) begin	// Send final beat one clock cycle sooner
										fifo_write_enable		<= 1'b1;
										fifo_data_in			<= {tdata_in[DATA_IN_TRUNCATED-1:0], leftover_tdata};
										fifo_control_in			<= {tvalid_in, 1'b1, tkeep_in[BYTES_PER_BEAT-KEEP_LEFTOVER-1:0], leftover_tkeep};
										tready_out				<= 1'b0;
										header_state			<= WAIT_FOR_END_OF_DATA;
									end
									else begin												// Same number of beats as the input
										fifo_write_enable		<= 1'b1;
										fifo_data_in			<= {tdata_in[DATA_IN_TRUNCATED-1:0], leftover_tdata};
										fifo_control_in			<= {tvalid_in, 1'b0, tkeep_in[BYTES_PER_BEAT-KEEP_LEFTOVER-1:0], leftover_tkeep};
										leftover_tdata			<= tdata_in[(BITS_PER_BEAT-1)-:DATA_IN_LEFTOVER];
										leftover_tkeep			<= tkeep_in[(BYTES_PER_BEAT-1)-:KEEP_LEFTOVER];
										tready_out				<= 1'b0;
										header_state			<= TRANSMIT_EXTRA_BEAT;
									end
								end
								else begin
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= {tdata_in[DATA_IN_TRUNCATED-1:0], leftover_tdata};
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-KEEP_LEFTOVER-1:0], leftover_tkeep};
									leftover_tdata			<= tdata_in[(BITS_PER_BEAT-1)-:DATA_IN_LEFTOVER];
									leftover_tkeep			<= tkeep_in[(BYTES_PER_BEAT-1)-:KEEP_LEFTOVER];
									tready_out				<= 1'b1;
								end
							end
							else begin
								tready_out				<= 1'b1;
							end
						end
						TRANSMIT_EXTRA_BEAT :
						begin
							tready_out			<= 1'b0;
							fifo_write_enable	<= 1'b1;
							fifo_data_in		<= {{DATA_IN_TRUNCATED{1'b0}}, leftover_tdata};
							fifo_control_in		<= {tvalid_in, 1'b1, {KEEP_IN_TRUNCATED{1'b0}}, leftover_tkeep};
							header_state		<= WAIT_FOR_END_OF_DATA;
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							
							if (fifo_data_empty && fifo_control_empty) begin
								header_state		<= WAIT_FOR_DATA;
							end
						end
						default : header_state		<= WAIT_FOR_DATA;
					endcase
				end
			end
			
			always @(posedge clock) begin
				if ((!fifo_data_empty) && (!fifo_data_valid)) begin
					fifo_read_enable	<= 1'b1;
				end
				else if ((!fifo_data_empty) && (tready_in)) begin
					fifo_read_enable	<= 1'b1;
				end
				else begin
					fifo_read_enable	<= 1'b0;
				end
					
				if (tready_in && (fifo_data_valid && fifo_control_valid)) begin
					tvalid_out		<= fifo_control_out[CONTROL_DATA_SIZE-1];
					tdata_out		<= fifo_data_out;
					tlast_out		<= fifo_control_out[CONTROL_DATA_SIZE-2];
					tkeep_out		<= fifo_control_out[CONTROL_DATA_SIZE-3:0];
				end
				else begin
					tvalid_out		<= 1'b0;
					tlast_out		<= 1'b0;
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : evenly_divisible	// Small data size, divides evenly into the header size
			reg [HEADER_SIZE-1:0] header_shift_register;
			reg fifo_read_enable;
			
			generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
			generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state			<= WAIT_FOR_DATA;
					tready_out				<= 1'b0;
					header_data				<= 0;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
					byte_counter			<= 0;
					header_byte_counter		<= 0;
					header_shift_register	<= 0;
				end
				else begin
					case (header_state)
						WAIT_FOR_DATA:
						begin
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							byte_counter		<= 0;
							header_byte_counter	<= 0;
							
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								header_state		<= CAPTURE_HEADER;
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						CAPTURE_HEADER:
						begin
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								
								if (header_byte_counter < BYTES_PER_HEADER-1) begin
									header_byte_counter		<= header_byte_counter + BYTES_PER_BEAT;
									header_shift_register	<= {tdata_in, header_shift_register[HEADER_SIZE-1:BITS_PER_BEAT]};
								end
								else begin
									header_data				<= header_shift_register;
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= tdata_in;
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in};
									header_state			<= TRANSMIT_REMAINING_DATA;
								end
							end							
						end
						TRANSMIT_REMAINING_DATA:
						begin
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								
								if (tlast_in) begin
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= tdata_in;
									fifo_control_in			<= {tvalid_in, 1'b1, tkeep_in};
									header_state			<= WAIT_FOR_END_OF_DATA;
								end
								else begin
									fifo_write_enable		<= 1'b1;
									fifo_data_in			<= tdata_in;
									fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in};
								end
							end							
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
							fifo_write_enable	<= 1'b0;
							fifo_data_in		<= 0;
							fifo_control_in		<= 0;
							
							if (fifo_data_empty && fifo_control_empty) begin
								header_state		<= WAIT_FOR_DATA;
							end
						end
						default : header_state			<= WAIT_FOR_DATA;
					endcase
				end
			end
			
			always @(posedge clock) begin
				if ((!fifo_data_empty) && (!fifo_data_valid)) begin
					fifo_read_enable	<= 1'b1;
				end
				else if ((!fifo_data_empty) && (tready_in)) begin
					fifo_read_enable	<= 1'b1;
				end
				else begin
					fifo_read_enable	<= 1'b0;
				end
					
				if (tready_in && (fifo_data_valid && fifo_control_valid)) begin
					tvalid_out		<= fifo_control_out[CONTROL_DATA_SIZE-1];
					tdata_out		<= fifo_data_out;
					tlast_out		<= fifo_control_out[CONTROL_DATA_SIZE-2];
					tkeep_out		<= fifo_control_out[CONTROL_DATA_SIZE-3:0];
				end
				else begin
					tvalid_out		<= 1'b0;
					tlast_out		<= 1'b0;
				end
			end
		end
	endgenerate
	
endmodule	