`include "C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv"
`include "C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv"
`include "C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv"
`include "C:/Xilinx/2025.1/Vivado/ids_lite/ISE/verilog/src/glbl.v"

module axi_stream_fifo (reset,
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

	parameter TDATA_WIDTH = 32;
	parameter FIFO_DEPTH = 2048;
	
	localparam BYTES_PER_BEAT = TDATA_WIDTH/8;
	localparam FULL_THRESHOLD = FIFO_DEPTH - 5;
	localparam DATA_COUNT = $clog2(FIFO_DEPTH) + 1;
	
	// Input side signals
	input reset;
	input clock;
	
	// Output bus signals
	input m_axis_tready;
	output [TDATA_WIDTH-1:0] m_axis_tdata; 
	output m_axis_tdest; 
	output m_axis_tid; 
	output [BYTES_PER_BEAT-1:0] m_axis_tkeep;
	output m_axis_tlast;
	output [BYTES_PER_BEAT-1:0] m_axis_tstrb;
	output m_axis_tuser; 
	output m_axis_tvalid;
	output reg fifo_empty;
	
	// Input bus signals
	output s_axis_tready;
	input [TDATA_WIDTH-1:0] s_axis_tdata;
	input [BYTES_PER_BEAT-1:0] s_axis_tkeep;
	input s_axis_tlast;
	input [BYTES_PER_BEAT-1:0] s_axis_tstrb;
	input s_axis_tuser;
	input s_axis_tvalid;
	output reg fifo_full;
	input s_axis_tdest;
	input s_axis_tid;
	
	// Local registers
	wire s_aresetn;
	wire prog_empty_axis;
	wire prog_full_axis; 
	wire [DATA_COUNT-1:0] rd_data_count_axis;
	wire sbiterr_axis;
	wire [DATA_COUNT-1:0] wr_data_count_axis;
	wire injectdbiterr_axis; 
	wire injectsbiterr_axis;
	
	reg almost_empty_reg;	
	reg empty_pending;		
	reg clear_empty_pending;	
	reg almost_full_reg;		
	reg fifo_full_pending;	
	reg clear_full_pending;	
	
	assign s_aresetn = ~reset;

	xpm_fifo_axis #(
		.CASCADE_HEIGHT(0), // DECIMAL
		.CDC_SYNC_STAGES(2), // DECIMAL
		.CLOCKING_MODE("common_clock"), // String
		.ECC_MODE("no_ecc"), // String
		.EN_SIM_ASSERT_ERR("warning"), // String
		.FIFO_DEPTH(FIFO_DEPTH), // DECIMAL
		.FIFO_MEMORY_TYPE("auto"), // String
		.PACKET_FIFO("false"), // String
		.PROG_EMPTY_THRESH(5), // DECIMAL
		.PROG_FULL_THRESH(FULL_THRESHOLD), // DECIMAL
		.RD_DATA_COUNT_WIDTH(DATA_COUNT), // DECIMAL
		.RELATED_CLOCKS(0), // DECIMAL
		.SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		.TDATA_WIDTH(TDATA_WIDTH), // DECIMAL
		.TDEST_WIDTH(1), // DECIMAL
		.TID_WIDTH(1), // DECIMAL
		.TUSER_WIDTH(1), // DECIMAL
		.USE_ADV_FEATURES("111111111111"), // String
		.WR_DATA_COUNT_WIDTH(DATA_COUNT) // DECIMAL
	)
	fifo_macro (
		.almost_empty_axis(almost_empty_axis),
		.almost_full_axis(almost_full_axis),
		.dbiterr_axis(dbiterr_axis), 
		.m_axis_tdata(m_axis_tdata), 
		.m_axis_tdest(m_axis_tdest), 
		.m_axis_tid(m_axis_tid), 
		.m_axis_tkeep(m_axis_tkeep), 
		.m_axis_tlast(m_axis_tlast), 
		.m_axis_tstrb(m_axis_tstrb), 
		.m_axis_tuser(m_axis_tuser), 
		.m_axis_tvalid(m_axis_tvalid),
		.prog_empty_axis(prog_empty_axis),
		.prog_full_axis(prog_full_axis), 
		.rd_data_count_axis(rd_data_count_axis),
		.s_axis_tready(s_axis_tready),
		.sbiterr_axis(sbiterr_axis),
		.wr_data_count_axis(wr_data_count_axis),
		.injectdbiterr_axis(injectdbiterr_axis), 
		.injectsbiterr_axis(injectsbiterr_axis), 
		.m_aclk(clock), 
		.m_axis_tready(m_axis_tready),
		.s_aclk(clock),
		.s_aresetn(s_aresetn),
		.s_axis_tdata(s_axis_tdata),
		.s_axis_tdest(s_axis_tdest),
		.s_axis_tid(s_axis_tid),
		.s_axis_tkeep(s_axis_tkeep),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tstrb(s_axis_tstrb),
		.s_axis_tuser(s_axis_tuser),
		.s_axis_tvalid(s_axis_tvalid)
	);

	// Create a fifo full signal and a fifo empty signal
	always @ (posedge clock or reset) begin
		if (reset) begin
			fifo_full			<= 1'b0;
			fifo_empty			<= 1'b0;
			almost_empty_reg	<= 1'b0;
			empty_pending		<= 1'b0;
			clear_empty_pending	<= 1'b0;
			almost_full_reg		<= 1'b0;
			fifo_full_pending	<= 1'b0;
			clear_full_pending	<= 1'b0;
		end
		else begin
			almost_empty_reg	<= almost_empty_axis;
			
			if (!almost_empty_reg && almost_empty_axis) begin
				empty_pending		<= 1'b1;
			end	
			else if (clear_empty_pending) begin
				empty_pending		<= 1'b0;
			end
			
			if (empty_pending && m_axis_tvalid && m_axis_tready) begin
				fifo_empty	<= 1'b1;
			end
			else if (s_axis_tvalid && s_axis_tready) begin
				fifo_empty	<= 1'b0;
			end
			
			if (empty_pending) begin
				if (m_axis_tvalid && m_axis_tready) begin
					clear_empty_pending	<= 1'b1;
				end
			else begin
				clear_empty_pending	<= 1'b0;
			end
			
			almost_full_reg	<= almost_full_axis;
			
			if (!almost_full_reg && almost_full_axis) begin
				fifo_full_pending	<= 1'b1;
			end
			else if (clear_full_pending) begin
				fifo_full_pending	<= 1'b0;
			end
			
			if (fifo_full_pending && s_axis_tready & s_axis_tvalid) begin
				fifo_full	<= 1'b1;
			end
			else if (m_axis_tvalid && m_axis_tready) begin
				fifo_full	<= 1'b0;
			end
			
			if (fifo_full_pending ) begin
				clear_full_pending	<= 1'b1;
			end
			else
				clear_full_pending	<= 1'b0;
			end
		end
	end
endmodule