`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/global_parameters.vh"

module ip_transmitter (reset, clock, icmp_tx_tready, icmp_tx_tvalid, icmp_tx_tdata, icmp_tx_tlast, icmp_tx_tkeep, udp_tx_tready, udp_tx_tvalid, udp_tx_tdata, udp_tx_tlast, udp_tx_tkeep, tcp_tx_tready, tcp_tx_tvalid, tcp_tx_tdata, tcp_tx_tlast, tcp_tx_tkeep, source_ip_address, destination_ip_address, eth_tx_tready, eth_tx_tvalid, eth_tx_tdata, eth_tx_tlast, eth_tx_tkeep);
	parameter BITS_PER_BEAT		= 128;
	parameter PIPELINE_DEPTH 	= 16;
	
	localparam BYTES_PER_HEADER	= 20;
	localparam BITS_PER_HEADER= BYTES_PER_HEADER*8;
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam CHECKSUM_ARRAY_SIZE = `IP_HEADER_SIZE/`CHECKSUM_SIZE;

	input reset;
	input clock;
	output icmp_tx_tready;
	input icmp_tx_tvalid;
	input [BITS_PER_BEAT-1:0] icmp_tx_tdata;
	input icmp_tx_tlast;
	input [BYTES_PER_BEAT-1:0] icmp_tx_tkeep;
	output udp_tx_tready;
	input udp_tx_tvalid;
	input [BITS_PER_BEAT-1:0] udp_tx_tdata;
	input udp_tx_tlast;
	input [BYTES_PER_BEAT-1:0] udp_tx_tkeep;
	output tcp_tx_tready;
	input tcp_tx_tvalid;
	input [BITS_PER_BEAT-1:0] tcp_tx_tdata;
	input tcp_tx_tlast;
	input [BYTES_PER_BEAT-1:0] tcp_tx_tkeep;
	input source_ip_address;
	input destination_ip_address;
	input eth_tx_tready;
	output eth_tx_tvalid;
	output [BITS_PER_BEAT-1:0] eth_tx_tdata;
	output eth_tx_tlast;
	output [BYTES_PER_BEAT-1:0] eth_tx_tkeep;
	
	// Local interconnects
	reg icmp_out_tready;
	wire icmp_out_tvalid;
	wire [BITS_PER_BEAT-1:0] icmp_out_tdata;
	wire [BYTES_PER_BEAT-1:0] icmp_out_tkeep;
	wire icmp_out_tlast;
	reg udp_out_tready;
	wire udp_out_tvalid;
	wire [BITS_PER_BEAT-1:0] udp_out_tdata;
	wire [BYTES_PER_BEAT-1:0] udp_out_tkeep;
	wire udp_out_tlast;
	reg tcp_out_tready;
	wire tcp_out_tvalid;
	wire [BITS_PER_BEAT-1:0] tcp_out_tdata;
	wire [BYTES_PER_BEAT-1:0] tcp_out_tkeep;
	wire tcp_out_tlast;
	reg [BITS_PER_HEADER-1:0] icmp_header;
	reg [BITS_PER_HEADER-1:0] udp_header;
	reg [BITS_PER_HEADER-1:0] tcp_header;

	reg [3:0]  ip_version;
	reg [3:0]  ip_header_length;
	reg [5:0]  ip_dscp;
	reg [1:0]  ip_ecn;
	reg [15:0] ip_total_length;
	reg [15:0] ip_identification;
	reg [2:0]  ip_flags;
	reg [12:0] ip_fragment_offset;
	reg [7:0]  ip_ttl;
	reg [7:0]  ip_protocol;
	reg [15:0] ip_header_checksum;
	reg [31:0] ip_source_address;
	reg [31:0] ip_destination_address;
	
	assign ip_version = 4'h04;
	assign ip_header_length = 4'h05;
	assign ip_dscp = 0;
	assign ip_ecn = 0;
	assign ip_total_length = ;
	assign ip_identification = ;
	assign ip_flags = ;
	assign ip_fragment_offset = ;
	assign ip_ttl = ;
	assign ip_protocol = ;
	assign ip_header_checksum = ;
	assign ip_source_address = ;
	assign ip_destination_address = ;
	
	header_insertion #(BITS_PER_BEAT, `IP_HEADER_SIZE, PIPELINE_DEPTH) icmp_interface (.clock(clock), .reset(reset), .tready_out(icmp_tx_tready), .tvalid_in(icmp_tx_tvalid), .tdata_in(icmp_tx_tdata), .tlast_in(icmp_tx_tlast), .tkeep_in(icmp_tx_tkeep), .tready_in(icmp_out_tready), .tvalid_out(icmp_out_tvalid), .tdata_out(icmp_out_tdata), .tlast_out(icmp_out_tlast), .tkeep_out(icmp_out_tkeep), .header_data(icmp_header));
	header_insertion #(BITS_PER_BEAT, `IP_HEADER_SIZE, PIPELINE_DEPTH) udp_interface (.clock(clock), .reset(reset), .tready_out(udp_tx_tready), .tvalid_in(udp_tx_tvalid), .tdata_in(udp_tx_tdata), .tlast_in(udp_tx_tlast), .tkeep_in(udp_tx_tkeep), .tready_in(udp_out_tready), .tvalid_out(udp_out_tvalid), .tdata_out(udp_out_tdata), .tlast_out(udp_out_tlast), .tkeep_out(udp_out_tkeep), .header_data(udp_header));
	header_insertion #(BITS_PER_BEAT, `IP_HEADER_SIZE, PIPELINE_DEPTH) tcp_interface (.clock(clock), .reset(reset), .tready_out(tcp_tx_tready), .tvalid_in(tcp_tx_tvalid), .tdata_in(tcp_tx_tdata), .tlast_in(tcp_tx_tlast), .tkeep_in(tcp_tx_tkeep), .tready_in(tcp_out_tready), .tvalid_out(tcp_out_tvalid), .tdata_out(tcp_out_tdata), .tlast_out(tcp_out_tlast), .tkeep_out(tcp_out_tkeep), .header_data(tcp_header));
	
	always @(posedge clock or reset) begin
		if (reset) begin
			ip_transmit_state	<= IDLE;
			icmp_header			<= 0;
			udp_header			<= 0;
			tcp_header			<= 0;
			current_packet_id	<= 0;
			enable_icmp			<= 1'b0;
			enable_udp			<= 1'b0;
			enable_tcp			<= 1'b0;
		end
		else begin
			case (ip_transmit_state)
				IDLE:
				begin
					if (icmp_tx_tvalid) begin
						enable_icmp			<= 1'b1;
						ip_transmit_state	<= WAIT_FOR_ICMP_FINISHED;
					end
					else if (udp_tx_tvalid) begin
						enable_udp			<= 1'b1;
						ip_transmit_state	<= WAIT_FOR_UDP_FINISHED;
					end
					else if (tcp_tx_tvalid) begin
						enable_tcp			<= 1'b1;
						ip_transmit_state	<= WAIT_FOR_TCP_FINISHED;
					end
				end
				WAIT_FOR_ICMP_FINISHED:
				begin
				end
				WAIT_FOR_UDP_FINISHED:
				begin
				end
				WAIT_FOR_TCP_FINISHED:
				begin
				end
				default: ip_transmit_state	<= IDLE;
			endcase
		end
	end
	
endmodule