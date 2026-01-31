module command_capture (clock, reset, tready_out, tvalid_in, tdata_in, tlast_in, tkeep_in, header_data, header_data_valid);
	parameter BITS_PER_BEAT = 512;
	parameter HEADER_SIZE = 112;
	parameter PIPELINE_DEPTH = 8;				// Maximum number of clock cycles between tvalid and tready
	
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
	output reg [HEADER_SIZE-1:0] header_data;
	output reg header_data_valid;
	
	localparam [7:0] WAIT_FOR_DATA = 8'b00000001;
//	localparam [7:0] CAPTURE_HEADER = 8'b00000010;
//	localparam [7:0] TRANSMIT_REMAINING_DATA = 8'b00000100;
	localparam [7:0] WAIT_FOR_END_OF_DATA = 8'b00001000;
//	localparam [7:0] TRANSMIT_EXTRA_BEAT = 8'b00010000;

	reg [7:0] header_state;
	
	integer byte_counter;
	integer header_byte_counter;
	reg [READ_LATENCY*BITS_PER_BEAT-1:0] data_shift_register;
	reg [READ_LATENCY*CONTROL_DATA_SIZE-1:0] control_shift_register;
	integer fifo_read_counter;
	localparam INTERPACKET_GAP = 12;
	integer ipg_counter;
	
	generate
		if (BITS_PER_BEAT == HEADER_SIZE) begin : same_data_size
			reg [HEADER_SHIFT_REG_SIZE-1:0] header_shift_register;
		
			wire fifo_read_enable;
			localparam LEFT_OVER_DATA_SIZE = BITS_PER_BEAT - HEADER_SIZE;
			localparam LEFT_OVER_TKEEP_SIZE = LEFT_OVER_DATA_SIZE/8;
			reg [LEFT_OVER_DATA_SIZE-1:0] leftover_tdata;
			reg [LEFT_OVER_TKEEP_SIZE-1:0] leftover_tkeep;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state		<= WAIT_FOR_DATA;
					tready_out			<= 1'b0;
					header_data			<= 0;
					header_data_valid	<= 1'b0;
					ipg_counter			<= 0;
				end
				else begin
					header_data_valid	<= 1'b0;
					
					case (header_state)
						WAIT_FOR_DATA:
						begin
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								header_data			<= tdata_in;
								header_data_valid	<= 1'b1;
								header_state		<= WAIT_FOR_END_OF_DATA;
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
//							ipg_counter			<= ipg_counter + 1;
							
//							if (ipg_counter >= INTERPACKET_GAP) begin
								header_state		<= WAIT_FOR_DATA;
//							end
						end
						default : header_state		<= WAIT_FOR_DATA;
					endcase
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
			wire fifo_read_enable;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state		<= WAIT_FOR_DATA;
					tready_out			<= 1'b0;
					header_data			<= 0;
					header_data_valid	<= 1'b0;
					leftover_tdata		<= 0;
					leftover_tkeep		<= 0;
					ipg_counter			<= 0;
				end
				else begin
					header_data_valid	<= 1'b0;
					
					case (header_state)
						WAIT_FOR_DATA:
						begin
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								header_data			<= tdata_in[HEADER_SIZE-1:0];
								header_data_valid	<= 1'b1;
								leftover_tdata		<= tdata_in[BITS_PER_BEAT-1:HEADER_SIZE];
								leftover_tkeep		<= tkeep_in[BITS_PER_BEAT/8-1:BYTES_PER_HEADER];
								header_state		<= WAIT_FOR_END_OF_DATA;
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
//							ipg_counter			<= ipg_counter + 1;
							
//							if (ipg_counter >= INTERPACKET_GAP) begin
								header_state		<= WAIT_FOR_DATA;
//							end
						end
						default : header_state		<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) != 0) begin : not_evenly_divisible
			localparam LEFT_OVER_DATA_SIZE = DATA_IN_LEFTOVER;
			localparam LEFT_OVER_TKEEP_SIZE = LEFT_OVER_DATA_SIZE/8;
			reg [LEFT_OVER_DATA_SIZE-1:0] leftover_tdata;
			reg [LEFT_OVER_TKEEP_SIZE-1:0] leftover_tkeep;
			reg [HEADER_SHIFT_REG_SIZE-1:0] header_shift_register;
			wire fifo_read_enable;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state			<= WAIT_FOR_DATA;
					tready_out				<= 1'b0;
					header_data				<= 0;
					header_data_valid		<= 1'b0;
					leftover_tdata			<= 0;
					leftover_tkeep			<= 0;
					byte_counter			<= 0;
					header_shift_register	<= 0;
				end
				else begin
					header_data_valid		<= 1'b0;
					
					case (header_state)
						WAIT_FOR_DATA:
						begin
							byte_counter		<= 0;
							
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								
								if (byte_counter < BYTES_PER_HEADER-1) begin
									header_shift_register	<= {tdata_in[BITS_PER_BEAT-1:0], header_shift_register[HEADER_SHIFT_REG_SIZE-1:BITS_PER_BEAT]};
									byte_counter			<= byte_counter + BYTES_PER_BEAT;
									leftover_tdata			<= tdata_in[(BITS_PER_BEAT-1)-:DATA_IN_LEFTOVER];
									leftover_tkeep			<= tkeep_in[(BYTES_PER_BEAT-1)-:KEEP_LEFTOVER];
								end
								else begin
									header_data				<= {tdata_in[BITS_PER_BEAT-1:0], header_shift_register[HEADER_SHIFT_REG_SIZE-1:BITS_PER_BEAT]};	// header_shift_register[HEADER_SIZE-1:0];
									header_data_valid		<= 1'b1;
									ipg_counter				<= 0;
									header_state			<= WAIT_FOR_END_OF_DATA;
								end
							end
							else begin
								tready_out			<= 1'b0;
							end
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
							ipg_counter			<= ipg_counter + 1;
							
							if (ipg_counter >= INTERPACKET_GAP) begin
								header_state		<= WAIT_FOR_DATA;
							end
						end
						default : header_state		<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : evenly_divisible	// Small data size, divides evenly into the header size
			reg [HEADER_SIZE-1:0] header_shift_register;
			wire fifo_read_enable;
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			reg data_output_enable;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_state			<= WAIT_FOR_DATA;
					tready_out				<= 1'b0;
					header_data				<= 0;
					header_data_valid		<= 1'b0;
					byte_counter			<= 0;
					header_byte_counter		<= 0;
					header_shift_register	<= 0;
					data_output_enable		<= 1'b0;
				end
				else begin
					header_data_valid		<= 1'b0;

					case (header_state)
						WAIT_FOR_DATA:
						begin
							byte_counter		<= 0;
							header_byte_counter	<= 0;
							
							if (tvalid_in) begin
								tready_out			<= 1'b1;
								data_output_enable	<= 1'b1;
								
								if (header_byte_counter < BYTES_PER_HEADER) begin
									if (data_output_enable) begin
										header_byte_counter		<= header_byte_counter + BYTES_PER_BEAT;
										header_shift_register	<= {tdata_in, header_shift_register[HEADER_SIZE-1:BITS_PER_BEAT]};
									end
								end
								else begin
									header_data				<= header_shift_register;
									header_data_valid		<= 1'b1;
									ipg_counter				<= 0;
									header_state			<= WAIT_FOR_END_OF_DATA;
								end
							end
							else begin
								if (header_byte_counter == BYTES_PER_HEADER) begin
									header_data				<= header_shift_register;
									header_data_valid		<= 1'b1;
									ipg_counter				<= 0;
									header_state			<= WAIT_FOR_END_OF_DATA;
								end
								else begin
									tready_out			<= 1'b0;
									data_output_enable	<= 1'b0;
								end
							end
						end
						WAIT_FOR_END_OF_DATA:
						begin
							tready_out			<= 1'b0;
							data_output_enable	<= 1'b0;
							ipg_counter			<= ipg_counter + 1;
							
							if (ipg_counter >= INTERPACKET_GAP) begin
								header_state		<= WAIT_FOR_DATA;
							end
						end
						default : header_state			<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
	endgenerate
	
endmodule	