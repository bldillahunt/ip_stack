`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module ethernet_transmitter (reset, clock, source_mac_address, destination_mac_address, ip_tx_tready, ip_tx_tvalid, ip_tx_tdata, ip_tx_tkeep, ip_tx_tlast, arp_tx_tready, arp_tx_tvalid, arp_tx_tdata, arp_tx_tkeep, arp_tx_tlast, temac_tx_tready, temac_tx_tvalid, temac_tx_tdata, temac_tx_tkeep, temac_tx_tlast, temac_tx_tuser, temac_tx_filter_tuser);
	// Parameters
	parameter BITS_PER_BEAT				= 512;							// The number of bits per beat of data
	parameter PIPELINE_DEPTH 			= 8;		// Maximum number of clock cycles between tvalid and tready

	localparam DATA_WIDTH				= 8;							// The size of one octet
	localparam BYTES_PER_BEAT			= BITS_PER_BEAT/DATA_WIDTH;		// The number of bytes to process on each clock cycle
	
	// I/O ports
	input reset;
	input clock;
	input [47:0] source_mac_address;
	input [47:0] destination_mac_address;
	output ip_tx_tready;
	input ip_tx_tvalid;
	input [BITS_PER_BEAT-1:0] ip_tx_tdata;
	input [BYTES_PER_BEAT-1:0] ip_tx_tkeep;
	input ip_tx_tlast;
	output arp_tx_tready;
	input arp_tx_tvalid;
	input [BITS_PER_BEAT-1:0] arp_tx_tdata;
	input [BYTES_PER_BEAT-1:0] arp_tx_tkeep;
	input arp_tx_tlast;
	output reg temac_tx_tvalid;
	input temac_tx_tready;
	output reg [BITS_PER_BEAT-1:0] temac_tx_tdata;
	output reg [BYTES_PER_BEAT-1:0] temac_tx_tkeep;
	output reg temac_tx_tlast;
	output [0:0] temac_tx_tuser;
	output temac_tx_filter_tuser;

	localparam HEADER_BYTE_COUNT		= 14;
	localparam BROADCAST_MAC_ADDRESS	= 48'hFFFFFFFFFFFF;
	
	localparam MAC_ADDRESS_BYTE_COUNT	= 6;
	localparam MAC_SHIFT_COUNT			= MAC_ADDRESS_BYTE_COUNT/BYTES_PER_BEAT;
	localparam MAC_ADDRESS_SIZE			= (DATA_WIDTH * MAC_ADDRESS_BYTE_COUNT);
	localparam ETHER_TYPE_BYTE_COUNT	= 2;
	localparam ETHER_TYPE_SIZE			= (DATA_WIDTH * ETHER_TYPE_BYTE_COUNT);
	localparam ETHERNET_HEADER_SIZE		= (2*MAC_ADDRESS_SIZE + ETHER_TYPE_SIZE);
	localparam ARP_HEADER_TYPE			= 16'h0806;
	localparam IP_HEADER_TYPE			= 16'h0800;

	// Local parameters
	localparam INPUT_BUFFER_BYTE_COUNT = HEADER_BYTE_COUNT;
	localparam INPUT_BUFFER_SIZE = DATA_WIDTH * INPUT_BUFFER_BYTE_COUNT;

	wire [ETHERNET_HEADER_SIZE-1:0] header_data;
	reg [15:0] protocol_type;
	
	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] WAIT_FOR_END_OF_IP = 8'h02;
	localparam [7:0] WAIT_FOR_END_OF_ARP = 8'h04;
	
	reg [7:0] ethernet_state;
	reg enable_ip_interface;	
	reg enable_arp_interface;
	
	// Submodule connections
	reg ip_mac_tready;
	wire ip_mac_tvalid;
	wire [BITS_PER_BEAT-1:0] ip_mac_tdata;
	wire ip_mac_tlast;
	wire [BYTES_PER_BEAT-1:0] ip_mac_tkeep;
	reg arp_mac_tready;
	wire arp_mac_tvalid;
	wire [BITS_PER_BEAT-1:0] arp_mac_tdata;
	wire arp_mac_tlast;
	wire [BYTES_PER_BEAT-1:0] arp_mac_tkeep;
	
	wire [47:0] source_swapped;
	wire [47:0] destination_swapped;
	wire [15:0] protocol_swapped;

	header_insertion #(BITS_PER_BEAT, ETHERNET_HEADER_SIZE, PIPELINE_DEPTH) ip_interface (.clock(clock), .reset(reset), .tready_out(ip_tx_tready), .tvalid_in(ip_tx_tvalid), .tdata_in(ip_tx_tdata), .tlast_in(ip_tx_tlast), .tkeep_in(ip_tx_tkeep), .tready_in(ip_mac_tready), .tvalid_out(ip_mac_tvalid), .tdata_out(ip_mac_tdata), .tlast_out(ip_mac_tlast), .tkeep_out(ip_mac_tkeep), .header_data(header_data));
	header_insertion #(BITS_PER_BEAT, ETHERNET_HEADER_SIZE, PIPELINE_DEPTH) arp_interface (.clock(clock), .reset(reset), .tready_out(arp_tx_tready), .tvalid_in(arp_tx_tvalid), .tdata_in(arp_tx_tdata), .tlast_in(arp_tx_tlast), .tkeep_in(arp_tx_tkeep), .tready_in(arp_mac_tready), .tvalid_out(arp_mac_tvalid), .tdata_out(arp_mac_tdata), .tlast_out(arp_mac_tlast), .tkeep_out(arp_mac_tkeep), .header_data(header_data));

	always @* begin
		if (enable_ip_interface) begin
			ip_mac_tready	<= temac_tx_tready;
			temac_tx_tvalid	<= ip_mac_tvalid; 
			temac_tx_tdata	<= ip_mac_tdata;
			temac_tx_tkeep	<= ip_mac_tkeep;
			temac_tx_tlast	<= ip_mac_tlast;
		end
		else if (enable_arp_interface) begin
			arp_mac_tready	<= temac_tx_tready;
			temac_tx_tvalid	<= arp_mac_tvalid;
			temac_tx_tdata	<= arp_mac_tdata;
			temac_tx_tkeep	<= arp_mac_tkeep;
			temac_tx_tlast	<= arp_mac_tlast;
		end
		else begin
			ip_mac_tready	<= 1'b0;
			arp_mac_tready	<= 1'b0;
			temac_tx_tvalid	<= 1'b0;
			temac_tx_tdata	<= 0;
			temac_tx_tkeep	<= 0;
			temac_tx_tlast	<= 1'b0;
		end
	end
	
	byte_swap #(.WIDTH(48))	src_mac (.data_in(source_mac_address), .data_out(source_swapped));	
	byte_swap #(.WIDTH(48))	dest_mac (.data_in(destination_mac_address), .data_out(destination_swapped));	
	byte_swap #(.WIDTH(16))	type_len (.data_in(protocol_type), .data_out(protocol_swapped));	
	
	assign header_data = {protocol_swapped, destination_swapped, source_swapped};
	
	always @(posedge clock or reset) begin
		if (reset) begin
			ethernet_state		<= IDLE;
			protocol_type		<= 0;
			enable_ip_interface	<= 1'b0;
			enable_arp_interface<= 1'b0;
		end
		else begin
			case (ethernet_state)
				IDLE:
				begin
					if (ip_tx_tvalid) begin
						enable_ip_interface	<= 1'b1;
						protocol_type		<= IP_HEADER_TYPE;
						ethernet_state		<= WAIT_FOR_END_OF_IP;
					end
					else if (arp_tx_tvalid) begin
						enable_arp_interface<= 1'b1;
						protocol_type		<= ARP_HEADER_TYPE;
						ethernet_state		<= WAIT_FOR_END_OF_ARP;
					end
				end
				WAIT_FOR_END_OF_IP:
				begin
					if (ip_mac_tvalid && ip_mac_tlast && ip_mac_tready) begin
						enable_ip_interface	<= 1'b0;
						ethernet_state		<= IDLE;
					end
				end
				WAIT_FOR_END_OF_ARP:
				begin
					if (arp_mac_tvalid && arp_mac_tlast && arp_mac_tready) begin
						enable_arp_interface<= 1'b0;
						ethernet_state		<= IDLE;
					end
				end
				default: ethernet_state		<= IDLE;
			endcase
		end
	end
endmodule
