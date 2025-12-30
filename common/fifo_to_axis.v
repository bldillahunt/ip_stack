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
	
	// State machine signals
	localparam WAIT_FOR_FIFO_DATA = 8'h01;
	localparam START_DATA_QUEUE = 8'h02;
	localparam FINISH_BUS_TRANSFER = 8'h04;
	localparam WAIT_FOR_END_OF_QUEUE = 8'h08;
	
	reg [7:0] fifo_to_axis_state;	
	integer queue_counter;		
	reg reset_pointer;		
	reg flush_pipeline;
	reg ready_to_send;
	reg end_of_frame;
	reg decrement_pointer;
	
	// Control registers
	reg [DATA_SIZE-1:0] data_queue[0:PIPELINE_DEPTH-1];
	reg [0:PIPELINE_DEPTH-1] valid_queue;
	integer output_pointer;
	
	always @(posedge clock or reset) begin
		if (reset) begin
			fifo_to_axis_state	<= WAIT_FOR_FIFO_DATA;
			fifo_read_enable	<= 1'b0;
			queue_counter		<= 0;
			reset_pointer		<= 1'b0;
			flush_pipeline		<= 1'b0;
			ready_to_send		<= 1'b0;
			end_of_frame		<= 1'b0;
			decrement_pointer	<= 1'b0;
		end
		else begin
			reset_pointer		<= 1'b0;
			end_of_frame		<= 1'b0;
			decrement_pointer	<= 1'b0;
			
			case (fifo_to_axis_state)
				WAIT_FOR_FIFO_DATA:
				begin
					if (!fifo_empty) begin
						fifo_read_enable	<= 1'b1;
						queue_counter		<= 0;
						reset_pointer		<= 1'b1;
						fifo_to_axis_state	<= START_DATA_QUEUE;
					end
				end
				START_DATA_QUEUE:
				begin
					if (!fifo_empty) begin
						if (queue_counter < PIPELINE_DEPTH-1) begin
							fifo_read_enable	<= 1'b1;
							queue_counter		<= queue_counter + 1;
						end
						else begin
							fifo_read_enable	<= 1'b0;
							fifo_to_axis_state	<= FINISH_BUS_TRANSFER;
						end
					end
					else begin
						fifo_read_enable	<= 1'b0;
						decrement_pointer	<= 1'b1;
						fifo_to_axis_state	<= FINISH_BUS_TRANSFER;
					end
				end
				FINISH_BUS_TRANSFER:
				begin
					if (!fifo_empty) begin
						ready_to_send	<= 1'b1;
					
						if (tready_in) begin
							fifo_read_enable	<= 1'b1;
						end
						else begin
							fifo_read_enable	<= 1'b0;
						end
					end
					else begin
						ready_to_send		<= 1'b0;
						fifo_read_enable	<= 1'b0;
						flush_pipeline		<= 1'b1;
						fifo_to_axis_state	<= WAIT_FOR_END_OF_QUEUE;
					end
				end
				WAIT_FOR_END_OF_QUEUE:
				begin
					if (output_pointer == 0) begin
						flush_pipeline		<= 1'b0;
						end_of_frame		<= 1'b1;
						fifo_to_axis_state	<= WAIT_FOR_FIFO_DATA;
					end
				end
				default : fifo_to_axis_state	<= WAIT_FOR_FIFO_DATA;
			endcase
		end
	end
	always @(posedge clock) begin
		if (reset_pointer) begin
			output_pointer	<= 0;
			
			for (i = 0; i < PIPELINE_DEPTH; i = i + 1) begin
				data_queue[i]	<= 0;
				valid_queue[i]	<= 0;
			end
		end
		else if (flush_pipeline) begin
			tdata_out		<= data_queue[output_pointer];
			tvalid_out		<= valid_queue[output_pointer];
			tkeep_out		<= {DATA_SIZE/8{1'b1}};
			
			if (output_pointer > 0) begin
				output_pointer	<= output_pointer - 1;
				tlast_out		<= 1'b0;
			end
			else begin
				tlast_out	<= 1'b1;
			end
		end
		else if (end_of_frame) begin
			tdata_out		<= 0;
			tvalid_out		<= 1'b0;
			tkeep_out		<= {DATA_SIZE/8{1'b0}};
			tlast_out		<= 1'b0;
			output_pointer	<= 0;
			
			for (i = 0; i < PIPELINE_DEPTH; i = i + 1) begin
				data_queue[i]	<= 0;
				valid_queue[i]	<= 0;
			end
		end
		else if (decrement_pointer) begin
			if (output_pointer < PIPELINE_DEPTH-1) begin
				output_pointer	<= output_pointer - 1;
			end
		end
		else if (tready_in) begin
			tdata_out		<= data_queue[output_pointer];
			tvalid_out		<= valid_queue[output_pointer];
			tkeep_out		<= {DATA_SIZE/8{1'b1}};
			
			if ((fifo_data_valid == 1'b1)  || (ready_to_send == 1'b1))begin
				if (output_pointer < PIPELINE_DEPTH-1) begin
					output_pointer	<= output_pointer + 1;
				end
				
				data_queue[0] 	<= fifo_data_out;
				valid_queue[0]	<= fifo_data_valid;

				for (i = 1; i < PIPELINE_DEPTH; i = i + 1) begin
					data_queue[i]	<= data_queue[i-1];
					valid_queue[i]	<= valid_queue[i-1];
				end
			end
		end
		else begin
			tvalid_out		<= 1'b0;
			tdata_out		<= 0;
			tlast_out		<= 1'b0;
			tkeep_out		<= {DATA_SIZE/8{1'b0}};
		end
	end
endmodule