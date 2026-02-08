`timescale 1ns/1ps
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/global_parameters.vh"
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"
`include "C:/Xilinx/2025.1/Vivado/ids_lite/ISE/verilog/src/glbl.v"

module axis_fifo_testbench;

	localparam TDATA_WIDTH = 32;
	localparam FIFO_DEPTH = 2048;
	localparam BYTES_PER_BEAT = TDATA_WIDTH/8;
	localparam TOTAL_BYTE_COUNT = 1500;
	localparam TOTAL_BEAT_COUNT = TOTAL_BYTE_COUNT/BYTES_PER_BEAT;

	// Polynomial = x^32 + x^22 + x^2 + x^1 + 1
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
	
	reg clock;
	reg reset;
	
	wire m_axis_tready;
	wire [TDATA_WIDTH-1:0] m_axis_tdata;
	wire m_axis_tdest;
	wire m_axis_tid;
	wire [BYTES_PER_BEAT-1:0] m_axis_tkeep;
	wire m_axis_tlast;
	wire [BYTES_PER_BEAT-1:0] m_axis_tstrb;
	wire m_axis_tuser;
	wire m_axis_tvalid;
	
	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] START_DATA_GENERATION = 8'h02;
	localparam [7:0] WAIT_FOR_END_OF_DATA = 8'h04;
	localparam [7:0] INTERPACKET_GAP = 8'h08;

	reg [7:0] axis_fifo_state;		
	reg [TDATA_WIDTH-1:0] s_axis_tdata;
	reg s_axis_tdest;		
	reg s_axis_tid;			
	reg [BYTES_PER_BEAT-1:0] s_axis_tkeep;		
	reg s_axis_tlast;		
	reg [BYTES_PER_BEAT-1:0] s_axis_tstrb;		
	reg s_axis_tuser;		
	reg s_axis_tvalid;		
	reg [31:0] next_prbs_pattern;
	integer byte_counter;		

	axi_stream_fifo #(TDATA_WIDTH,
					  FIFO_DEPTH)
					  dut (
						reset,
						clock, 
						m_axis_tready,
						m_axis_tdata,
						m_axis_tdest,
						m_axis_tid,
						m_axis_tkeep,
						m_axis_tlast,
						m_axis_tstrb,
						m_axis_tuser,
						m_axis_tvalid,
						s_axis_tready,
						s_axis_tdata,
						s_axis_tdest,
						s_axis_tid,
						s_axis_tkeep,
						s_axis_tlast,
						s_axis_tstrb,
						s_axis_tuser,
						s_axis_tvalid,
						fifo_full,
						fifo_empty
						);

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

	assign m_axis_tready = m_axis_tvalid;
	
	always @(posedge clock or reset) begin
		if (reset) begin
			axis_fifo_state		<= IDLE;
			s_axis_tdata		<= 0;
			s_axis_tdest		<= 0;
			s_axis_tid			<= 0;
			s_axis_tkeep		<= 0;
			s_axis_tlast		<= 1'b0;
			s_axis_tstrb		<= 0;		
			s_axis_tuser		<= 0;
			s_axis_tvalid		<= 1'b0;
			next_prbs_pattern	<= {32{1'b1}};
			byte_counter		<= 0;
		end
		else begin
			case (axis_fifo_state)
				IDLE: 
				begin
					axis_fifo_state		<= START_DATA_GENERATION;
				end
				START_DATA_GENERATION:
				begin
					s_axis_tvalid		<= 1'b1;
					s_axis_tdata		<= next_prbs_pattern;
					s_axis_tkeep		<= {BYTES_PER_BEAT{1'b1}};
					s_axis_tlast		<= 1'b0;
					
					if (s_axis_tready) begin
						next_prbs_pattern	<= prbs_pattern_generator(1'b1, next_prbs_pattern);
						byte_counter		<= byte_counter + BYTES_PER_BEAT;
						axis_fifo_state		<= WAIT_FOR_END_OF_DATA;
					end
				end
				WAIT_FOR_END_OF_DATA:
				begin	
					if (byte_counter < TOTAL_BYTE_COUNT) begin
						s_axis_tvalid		<= 1'b1;
						s_axis_tdata		<= next_prbs_pattern;
						s_axis_tkeep		<= {BYTES_PER_BEAT{1'b1}};
						
						if (byte_counter == (TOTAL_BYTE_COUNT-BYTES_PER_BEAT)) begin
							s_axis_tlast		<= 1'b1;
						end
						else begin
							s_axis_tlast		<= 1'b0;
						end
						
						next_prbs_pattern	<= prbs_pattern_generator(1'b1, next_prbs_pattern);
						byte_counter		<= byte_counter + BYTES_PER_BEAT;
					end
					else begin
						s_axis_tvalid		<= 1'b0;
						s_axis_tdata		<= 0;
						s_axis_tkeep		<= {BYTES_PER_BEAT{1'b0}};
						s_axis_tlast		<= 1'b0;
						axis_fifo_state		<= INTERPACKET_GAP;					
					end
				end
				INTERPACKET_GAP:
				begin
					byte_counter		<= 0;
					#25 axis_fifo_state		<= IDLE;
				end
				default: axis_fifo_state		<= IDLE;
			endcase
		end
	end
endmodule
