module header_insertion (clock, reset, tready_out, tvalid_in, tdata_in, tlast_in, tkeep_in, tready_in, tvalid_out, tdata_out, tlast_out, tkeep_out, header_data);

	parameter BITS_PER_BEAT = 512;
	parameter HEADER_SIZE = 112;
	
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BYTES_PER_HEADER = HEADER_SIZE/8;
	localparam BACK_PRESSURE_DEPTH = 32;
	localparam CONTROL_DATA_SIZE = BYTES_PER_BEAT + 2;
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
	reg [CONTROL_DATA_SIZE-1:0] fifo_control_in;
	wire [CONTROL_DATA_SIZE-1:0] fifo_control_out;
	wire fifo_control_valid;
	wire fifo_control_empty;
	wire fifo_control_full;
	
	localparam WAIT_FOR_DATA = 8'h01;
	localparam CAPTURE_HEADER = 8'h02;
	localparam STORE_REMAINING_DATA = 8'h04;
	localparam TRANSMIT_EXTRA_BEAT = 8'h08;
	localparam END_BUS_TRANSACTION = 8'h10;
	
	reg [7:0] header_insertion_state;
	
	reg [LEFTOVER_DATA_SIZE-1:0] tdata_leftover;
	reg [LEFTOVER_BYTES-1:0] tkeep_leftover;
	wire fifo_read_enable;
	
	generic_fifo #(BACK_PRESSURE_DEPTH, BITS_PER_BEAT) data_memory (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_data_empty, fifo_data_full);	
	generic_fifo #(BACK_PRESSURE_DEPTH, (BITS_PER_BEAT/8)+2) control_memory (clock, reset, fifo_write_enable, fifo_control_in, fifo_read_enable, fifo_control_out, fifo_control_valid, fifo_control_empty, fifo_control_full);	
	
	generate
		if (BITS_PER_BEAT > HEADER_SIZE) begin : large_data_size
		
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
								fifo_control_in			<= {tvalid_in, tlast_in, tkeep_in[BYTES_PER_BEAT-LEFTOVER_BYTES-1:0], {BYTES_PER_HEADER{1'b1}}};
								tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:HEADER_SIZE];		// tdata_in[HEADER_SIZE-1:0];
								tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT-1)-:BYTES_PER_HEADER];	// tkeep_in[BYTES_PER_HEADER-1:0];
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
								fifo_data_in			<= {tdata_in[BITS_PER_BEAT-LEFTOVER_DATA_SIZE-1:0], tdata_leftover};
								tdata_leftover			<= tdata_in[(BITS_PER_BEAT-1)-:HEADER_SIZE];
								tkeep_leftover			<= tkeep_in[(BYTES_PER_BEAT-1)-:BYTES_PER_HEADER];

								if (tlast_in) begin								
									if (tkeep_in[BYTES_PER_BEAT-1:BYTES_PER_HEADER] != 0) begin
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
							header_insertion_state	<= WAIT_FOR_DATA;
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end
			
			wire data_valid_reg;
			wire [BITS_PER_BEAT-1:0] data_reg;
			wire last_reg;
			wire [BYTES_PER_BEAT-1:0] keep_reg;
			wire control_valid_reg;
			wire [CONTROL_DATA_SIZE-1:0] control_data_reg;
			wire control_last_reg;
			wire [CONTROL_DATA_SIZE/8-1:0] control_keep_reg;
			
			fifo_to_axis #(BITS_PER_BEAT, 4) tdata_interface (reset, clock, fifo_read_enable, fifo_data_empty, fifo_data_full, fifo_data_out, fifo_data_valid, tready_in, data_valid_reg, data_reg, last_reg, keep_reg);
			fifo_to_axis #(CONTROL_DATA_SIZE, 4) control_signal_interface (reset, clock, fifo_read_enable, fifo_control_empty, fifo_control_full, fifo_control_out, fifo_control_valid, tready_in, control_valid_reg, control_data_reg, control_last_reg, control_keep_reg);
			
			always begin
				tvalid_out		<= control_data_reg[CONTROL_DATA_SIZE-1];
				tdata_out		<= data_reg;
				tlast_out		<= control_data_reg[CONTROL_DATA_SIZE-2];
				tkeep_out		<= control_data_reg[BYTES_PER_BEAT-1:0];
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : small_data_size_even
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) != 0) begin : small_data_size_odd
			always @(posedge clock or reset) begin
				if (reset) begin
					header_insertion_state	<= WAIT_FOR_DATA;
					fifo_write_enable		<= 1'b0;
					fifo_data_in			<= 0;
				end
				else begin
					case (header_insertion_state)
						WAIT_FOR_DATA:
						begin
							
						end
						default : header_insertion_state	<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
	endgenerate
endmodule
