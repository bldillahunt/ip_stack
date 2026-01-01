module fifo_to_axis (reset, clock, fifo_read_enable, fifo_empty, fifo_full, fifo_data_out, fifo_data_valid, tready_in, tvalid_out, tdata_out, tlast_out, tkeep_out);
	
	parameter DATA_SIZE = 512;
	parameter PIPELINE_DEPTH = 4;
	
	input reset;
	input clock;
	output reg fifo_read_enable;
	input fifo_empty;
	input fifo_full;
	input [DATA_SIZE-1:0] fifo_data_out;
	input fifo_data_valid;
	input tready_in;
	output reg tvalid_out;
	output reg [DATA_SIZE-1:0] tdata_out;
	output reg tlast_out;
	output reg [DATA_SIZE/8-1:0] tkeep_out;
	integer i;
	
	localparam IDLE = 8'h01;
	localparam WAIT_FOR_FIFO_DATA = 8'h02;
	localparam CHECK_FOR_READY_TO_SEND = 8'h04;
	localparam WAIT_FOR_FIFO_EMPTY = 8'h08;
	localparam WAIT_FOR_PIPELINE_EMPTY = 8'h10;
	
	// State machine signals
	reg [7:0] fifo_to_axis_state;	
	reg enable_data_output;	
	reg flush_pipeline;		
	reg reset_index;
	reg push_pipeline;

	// Control registers
	integer input_index;		
	integer input_counter;	
	reg [PIPELINE_DEPTH-1:0] valid_buffer;	
	reg [PIPELINE_DEPTH-1:0] eof_buffer;		
	reg [DATA_SIZE-1:0] axis_buffer[PIPELINE_DEPTH-1:0];
	
	always @(posedge clock or reset) begin
		if (reset) begin
			fifo_to_axis_state	<= IDLE;
			fifo_read_enable	<= 1'b0;
			enable_data_output	<= 1'b0;
			flush_pipeline		<= 1'b0;
			reset_index			<= 1'b0;
			push_pipeline		<= 1'b0;
		end
		else begin
			reset_index			<= 1'b0;
			
			case (fifo_to_axis_state)
				IDLE:
				begin
					reset_index			<= 1'b1;
					flush_pipeline		<= 1'b0;
					push_pipeline		<= 1'b0;
					fifo_to_axis_state	<= WAIT_FOR_FIFO_DATA;
				end
				WAIT_FOR_FIFO_DATA:
				begin
					if (!fifo_empty) begin
						fifo_read_enable	<= 1'b1;
						fifo_to_axis_state	<= CHECK_FOR_READY_TO_SEND;
					end
				end
				CHECK_FOR_READY_TO_SEND:
				begin
					if (fifo_empty) begin
						fifo_read_enable	<= 1'b0;
						enable_data_output	<= 1'b1;
						
						if (input_index < PIPELINE_DEPTH-1) begin
							push_pipeline		<= 1'b1;
						end
						else begin
							push_pipeline		<= 1'b0;
						end
						
						fifo_to_axis_state	<= WAIT_FOR_PIPELINE_EMPTY;
					end
					else if (input_counter == PIPELINE_DEPTH-1) begin
						fifo_read_enable	<= 1'b1;
						enable_data_output	<= 1'b1;
						fifo_to_axis_state	<= WAIT_FOR_FIFO_EMPTY;
					end
				end
				WAIT_FOR_FIFO_EMPTY:
				begin
					if (fifo_empty) begin
						fifo_read_enable	<= 1'b0;
						flush_pipeline		<= 1'b1;
						enable_data_output	<= 1'b1;
						fifo_to_axis_state	<= WAIT_FOR_PIPELINE_EMPTY;
					end
					else if (!tready_in) begin
						enable_data_output	<= 1'b0;
					end
				end
				WAIT_FOR_PIPELINE_EMPTY:				
				begin
					if ((eof_buffer[PIPELINE_DEPTH-1]) || ((push_pipeline) && (input_index == 0))) begin
						flush_pipeline		<= 1'b0;
						enable_data_output	<= 1'b0;
						push_pipeline		<= 1'b0;
						fifo_to_axis_state	<= IDLE;
					end
					else if (!tready_in) begin
						enable_data_output	<= 1'b0;
					end
				end
				default : fifo_to_axis_state	<= IDLE;
			endcase
		end
	end
	
	always @(posedge clock) begin
		if (reset_index) begin
			input_index		<= 0;
			input_counter	<= 0;
			valid_buffer	<= {PIPELINE_DEPTH-1{1'b0}};
			eof_buffer		<= {PIPELINE_DEPTH-1{1'b0}};
			
			for (i = 0; i < PIPELINE_DEPTH; i = i + 1) begin
				axis_buffer[i]		<= {DATA_SIZE{1'b0}};
			end
		end
		else if (fifo_data_valid) begin
			axis_buffer[0]	<= fifo_data_out;
			
			for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
				axis_buffer[i]	<= axis_buffer[i-1];
			end
			
			if (input_counter < PIPELINE_DEPTH) begin
				input_index			<= input_counter;
			end
			
			if (input_counter < PIPELINE_DEPTH-1) begin
				input_counter		<= input_counter + 1;
			end
			
			eof_buffer[0]					<= 1'b1;
			eof_buffer[PIPELINE_DEPTH-1:1]	<= {PIPELINE_DEPTH-1{1'b0}};
			valid_buffer[0]					<= 1'b1;
			
			for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
				valid_buffer[i]		<= valid_buffer[i-1];
			end
		end
		else if ((flush_pipeline) || ((fifo_empty) && (input_index == PIPELINE_DEPTH-1))) begin
			axis_buffer[0]	<= 0;
			eof_buffer[0]	<= 1'b0;
			
			for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
				axis_buffer[i]	<= axis_buffer[i-1];
				valid_buffer[i]	<= valid_buffer[i-1];
				eof_buffer[i]	<= eof_buffer[i-1];
			end
		end
		else if (push_pipeline) begin
			if (input_index > 0) begin
				input_index	<= input_index - 1;
			end
		end
		
		if (enable_data_output) begin
			tvalid_out		<= valid_buffer[input_index];
			tdata_out		<= axis_buffer[input_index];
			tlast_out		<= eof_buffer[input_index];
			tkeep_out		<= {DATA_SIZE/8{1'b1}};
		end
		else if (push_pipeline) begin
			tvalid_out		<= valid_buffer[input_index];
			tdata_out		<= axis_buffer[input_index];
			tlast_out		<= eof_buffer[input_index];
			tkeep_out		<= {DATA_SIZE/8{1'b1}};
		end
		else begin
			tvalid_out		<= 1'b0;
			tdata_out		<= 0;
			tlast_out		<= 1'b0;
			tkeep_out		<= 0;
		end
	end
endmodule