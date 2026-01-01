`timescale 1ns/1ps

module fifo_to_axis_testbench;

	localparam BITS_PER_BEAT = 128;
	localparam BEATS_PER_BURST = 128;
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
	localparam BACK_PRESSURE_DEPTH = 32;
	localparam PRBS_SIZE = 32;
	localparam TOTAL_BIT_COUNT = BITS_PER_BEAT * BEATS_PER_BURST;
	
	localparam START_PRBS_PATTERN = 8'h01;
	localparam START_FIFO_WRITE = 8'h02;
	localparam CHECK_FOR_END_OF_DATA = 8'h04;
	localparam WAIT_FOR_FIFO_EMPTY = 8'h08;

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
	
	wire data_valid_reg;
	wire [BITS_PER_BEAT-1:0] data_reg;
	wire last_reg;
	wire [BYTES_PER_BEAT-1:0] keep_reg;
	wire control_valid_reg;
	wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
	wire control_last_reg;
	wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;
	
	reg clock;
	reg reset;
	reg [PRBS_SIZE-1:0] prbs_register;
	reg [TOTAL_BIT_COUNT-1:0] prbs_shift_register;
	integer byte_counter;
	reg [7:0] ip_to_axis_state;
	reg tready_in;
	
	localparam WAIT_FOR_AXIS_DATA = 4'h1;
	localparam START_VERIFICATION = 4'h2;
	
	reg [3:0] verification_state;		
	reg [PRBS_SIZE-1:0] prbs_verifier;			
	reg [TOTAL_BIT_COUNT-1:0] verifier_shift_register;	
	reg data_valid;				

	function [31:0] prbs_pattern_generator;
		input data_enable;
		input [31:0] seed_value;
		reg [31:0] lfsr_data;
		reg [31:0] lfsr_bit;
		
		begin
			if (data_enable) begin
				lfsr_bit	= (seed_value ^ (seed_value >> 10) ^ (seed_value >> 30) ^ (seed_value >> 31)) & 1'b1;
				lfsr_data	= (seed_value >> 1) | (lfsr_bit << 31);
			end
			
			prbs_pattern_generator = lfsr_data;
		end
	endfunction

	function [TOTAL_BIT_COUNT-1:0] prbs_data_array;
		integer i;
		input [31:0] previous_prbs_input;
		reg [TOTAL_BIT_COUNT-1:0] shift_register;
		reg [31:0] current_prbs_data;
		
		begin
			shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE] = prbs_pattern_generator(1'b1, previous_prbs_input);
			current_prbs_data = shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];

			for (i = 0; i < TOTAL_BIT_COUNT/PRBS_SIZE-1; i = i + 1) begin
				shift_register	= shift_register >> PRBS_SIZE;
				shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE] = prbs_pattern_generator(1'b1, current_prbs_data);
				current_prbs_data = shift_register[TOTAL_BIT_COUNT-1-:PRBS_SIZE];
//				$display("prbs = %08H\n", current_prbs_data);			
			end
			
			prbs_data_array = shift_register;
		end
	endfunction

	generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
	generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
			
	fifo_to_axis #(BITS_PER_BEAT, 4) tdata_interface (reset, clock, fifo_read_enable, fifo_data_empty, fifo_data_full, fifo_data_out, fifo_data_valid, tready_in, data_valid_reg, data_reg, last_reg, keep_reg);
	fifo_to_axis #(CONTROL_DATA_SIZE, 4) control_signal_interface (reset, clock, fifo_read_enable, fifo_control_empty, fifo_control_full, fifo_control_out, fifo_control_valid, tready_in, control_valid_reg, control_data_reg, control_last_reg, control_keep_reg);

	initial begin
		clock = 1'b0;
		reset = 1'b1;
	end

	initial begin
		#1000 reset = 1'b0;
	end
	
	always begin
		#5 clock = ~clock;
	end

	always @(posedge clock or reset) begin
		if (reset) begin
			ip_to_axis_state	<= START_PRBS_PATTERN;
			prbs_register		<= 32'hFFFFFFFF;
			prbs_shift_register	<= 0;
			fifo_write_enable	<= 1'b0;
			fifo_data_in		<= 0;
			fifo_control_in		<= 0;
			byte_counter		<= 0;
			tready_in			<= 1'b0;
		end
		else begin
			tready_in			<= 1'b1;
				
			case (ip_to_axis_state)
				START_PRBS_PATTERN:
				begin
					prbs_shift_register	= prbs_data_array(prbs_register);
					prbs_register		= prbs_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
					fifo_write_enable	<= 1'b0;
					fifo_data_in		<= 0;
					fifo_control_in		<= 0;
					byte_counter		<= 0;
					ip_to_axis_state	<= START_FIFO_WRITE;
				end
				START_FIFO_WRITE:
				begin
					byte_counter		<= byte_counter + BYTES_PER_BEAT;
					fifo_write_enable	<= 1'b1;
					fifo_data_in		<= prbs_shift_register[BITS_PER_BEAT-1:0];
					fifo_control_in		<= {1'b1, 1'b0, {BYTES_PER_BEAT{1'b0}}};
					prbs_shift_register	<= prbs_shift_register >> BITS_PER_BEAT;
					ip_to_axis_state	<= CHECK_FOR_END_OF_DATA;
				end
				CHECK_FOR_END_OF_DATA:
				begin
					if (byte_counter < (TOTAL_BIT_COUNT/8)-1) begin
						byte_counter		<= byte_counter + BYTES_PER_BEAT;
						fifo_write_enable	<= 1'b1;
						fifo_data_in		<= prbs_shift_register[BITS_PER_BEAT-1:0];
						
						if (byte_counter < (TOTAL_BIT_COUNT/8)-2) begin
							fifo_control_in		<= {1'b1, 1'b0, {BYTES_PER_BEAT{1'b0}}};
						end
						else begin
							fifo_control_in		<= {1'b1, 1'b1, {BYTES_PER_BEAT{1'b0}}};
						end
						
						prbs_shift_register	<= prbs_shift_register >> BITS_PER_BEAT;
					end
					else begin
						fifo_write_enable	<= 1'b0;
						fifo_data_in		<= 0;
						ip_to_axis_state	<= WAIT_FOR_FIFO_EMPTY;
					end
				end
				WAIT_FOR_FIFO_EMPTY:
				begin
					if (fifo_data_empty && fifo_control_empty) begin
						ip_to_axis_state	<= START_PRBS_PATTERN;
					end
				end
				default: ip_to_axis_state	<= START_PRBS_PATTERN;
			endcase
		end
	end

	always @(posedge clock or reset) begin
		if (reset) begin
			verification_state		<= WAIT_FOR_AXIS_DATA;
			prbs_verifier			<= 32'hFFFFFFFF;
			verifier_shift_register	<= 0;
			data_valid				<= 1'b0;
		end
		else begin
			case (verification_state)
				WAIT_FOR_AXIS_DATA:
				begin
					verifier_shift_register	= prbs_data_array(prbs_verifier);
					prbs_verifier			= verifier_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
					verification_state		<= START_VERIFICATION;
				end
				START_VERIFICATION:
				begin
					if (tready_in && data_valid_reg) begin
						if (data_reg == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
							data_valid				<= 1'b1;
						end
						else begin
							data_valid				<= 1'b0;
						end

						verifier_shift_register	= verifier_shift_register >> BITS_PER_BEAT;
						
						if (last_reg) begin
							verification_state		<= WAIT_FOR_AXIS_DATA;
						end
					end
				end
				default: verification_state		<= WAIT_FOR_AXIS_DATA;
			endcase
		end
	end

endmodule