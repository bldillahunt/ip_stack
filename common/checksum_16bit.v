module checksum_16bit (clock, reset, checksum_data_valid, checksum_data, end_of_frame, checksum_expected, checksum_done, checksum_correct, checksum_value);

	input clock;
	input reset;
	input checksum_data_valid;
	input [7:0] checksum_data;
	input end_of_frame;
	input [15:0] checksum_expected;
	output checksum_done;
	output checksum_correct;
	output [15:0] checksum_value;
	
	// State machine registers
	localparam WAIT_FOR_DATA = 5'b00001;
	localparam WAIT_FOR_END_OF_FRAME = 5'b00010;
	localparam INVERT_OVERFLOW_SUM = 5'b00100;
	localparam CHECKSUM_VERIFICATION = 5'b01000;
		
	reg [7:0] checksum_state;		
	reg add_sum_overflow;	
	reg start_of_frame;	
	reg invert_checksum;	
	reg latch_final_checksum;
		
	reg checksum_done;
	reg checksum_correct;
	reg [15:0] checksum_value;
	reg checksum_data_valid_reg0;	
	reg [7:0] checksum_data_reg0;		
	reg end_of_frame_reg0;		
	reg checksum_data_valid_reg1;	
	reg [7:0] checksum_data_reg1;		
	reg end_of_frame_reg1;		
	reg end_of_frame_reg2;
	reg latch_data_word0;	
	reg latch_data_word1;	
	reg [31:0] current_sum;		
	reg [15:0] checksum_shift_reg;	
	integer byte_counter;
	reg [31:0] overflow_sum;	
	reg checksum_add_done;
	reg [31:0] inverted_checksum;		
	reg inverted_checksum_done;
	reg clear_checksum_add;
	
	always @(posedge clock or reset) begin
		if (reset) begin
			checksum_state		<= WAIT_FOR_DATA;
			checksum_done		<= 1'b0;
			checksum_correct	<= 1'b0;
			add_sum_overflow	<= 1'b0;
			start_of_frame		<= 1'b0;
			invert_checksum		<= 1'b0;
			latch_final_checksum<= 1'b0;
			clear_checksum_add	<= 1'b0;
		end
		else begin
			start_of_frame		<= 1'b0;
			add_sum_overflow	<= 1'b0;
			checksum_done		<= 1'b0;
			latch_final_checksum<= 1'b0;
			clear_checksum_add	<= 1'b0;
			
			case (checksum_state)
				WAIT_FOR_DATA:
				begin
					if (checksum_data_valid) begin
						start_of_frame		<= 1'b1;
						checksum_state		<= WAIT_FOR_END_OF_FRAME;
					end
				end
				WAIT_FOR_END_OF_FRAME:
				begin
					if (checksum_add_done) begin
						if (overflow_sum[31:16] != 0) begin
							add_sum_overflow	<= 1'b1;
						end
						else begin
							add_sum_overflow	<= 1'b0;
							invert_checksum		<= 1'b1;
							clear_checksum_add	<= 1'b1;
							checksum_state		<= INVERT_OVERFLOW_SUM;	
						end
					end
				end
				INVERT_OVERFLOW_SUM:
				begin
					invert_checksum			<= 1'b1;
					
					if ((inverted_checksum != 0) && (inverted_checksum_done)) begin
						latch_final_checksum	<= 1'b1;
						invert_checksum			<= 1'b0;
						checksum_state			<= CHECKSUM_VERIFICATION;
					end
				end
				CHECKSUM_VERIFICATION:
				begin
					if (checksum_value == checksum_expected) begin
						checksum_correct	<= 1'b1;
					end
					else begin
						checksum_correct	<= 1'b0;
					end
					
					checksum_done			<= 1'b1;
					checksum_state			<= WAIT_FOR_DATA;
				end
				default: checksum_state		<= WAIT_FOR_DATA;
			endcase
		end
	end
	
	// Combinational logic section
	always @(posedge clock) begin
		checksum_data_valid_reg0<= checksum_data_valid;
		checksum_data_reg0		<= checksum_data;
		end_of_frame_reg0		<= end_of_frame;
		checksum_data_valid_reg1<= checksum_data_valid_reg0;
		checksum_data_reg1		<= checksum_data_reg0;		
		end_of_frame_reg1		<= end_of_frame_reg0;		
		end_of_frame_reg2		<= end_of_frame_reg1;
			
		if (start_of_frame) begin
			latch_data_word0		<= 1'b0;
		end
		else if (checksum_data_valid_reg1) begin
			checksum_shift_reg	<= {checksum_shift_reg[7:0], checksum_data_reg1};			
			latch_data_word0		<= ~latch_data_word0;
		end
		
		latch_data_word1	<= latch_data_word0;
		
		if (start_of_frame) begin
			byte_counter	<= 0;
		end
		else if (checksum_data_valid_reg1) begin
			byte_counter	<= byte_counter + 1;
		end

		if (start_of_frame) begin
			current_sum		<= 0;
		end			
		if (latch_data_word1) begin
			current_sum			<= current_sum + {16'h0000, checksum_shift_reg};
		end
		
		if (end_of_frame_reg2) begin
			overflow_sum		<= current_sum;
		end
		else if (add_sum_overflow) begin
			overflow_sum		<= overflow_sum[31:16] + overflow_sum[15:0];
		end
		
		if (end_of_frame_reg2) begin
			checksum_add_done	<= 1'b1;
		end
		else if (clear_checksum_add) begin
			checksum_add_done	<= 1'b0;
		end
		
		if (invert_checksum) begin
			inverted_checksum		<= ~overflow_sum;
			inverted_checksum_done	<= 1'b1;
		end
		else begin
			inverted_checksum_done	<= 1'b0;
		end

		if (latch_final_checksum) begin
			checksum_value		<= inverted_checksum[15:0];
		end
	end
endmodule
