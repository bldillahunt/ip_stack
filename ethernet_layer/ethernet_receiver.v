`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module ethernet_receiver (reset, clock, temac_rx_tvalid, temac_rx_tdata, temac_rx_tkeep, temac_rx_tlast, temac_rx_tuser, temac_rx_filter_tuser, ip_rx_tready, ip_rx_tvalid, ip_rx_tdata, ip_rx_tkeep, ip_rx_tlast, arp_rx_tready, arp_rx_tvalid, arp_rx_tdata, arp_rx_tkeep, arp_rx_tlast, temac_address, received_mac_address, valid_mac_address);
	// Parameters
	parameter BITS_PER_BEAT				= 512;							// The number of bits per beat of data
	parameter PIPELINE_DEPTH 			= 8;		// Maximum number of clock cycles between tvalid and tready

	localparam DATA_WIDTH				= 8;							// The size of one octet
	localparam BYTES_PER_BEAT			= BITS_PER_BEAT/DATA_WIDTH;		// The number of bytes to process on each clock cycle
	localparam HEADER_BYTE_COUNT		= 14;
	localparam BROADCAST_MAC_ADDRESS	= 48'hFFFFFFFFFFFF;
	
	localparam MAC_ADDRESS_BYTE_COUNT	= 6;
	localparam MAC_ADDRESS_SIZE			= (DATA_WIDTH * MAC_ADDRESS_BYTE_COUNT);
	localparam ETHER_TYPE_BYTE_COUNT	= 2;
	localparam ETHER_TYPE_SIZE			= (DATA_WIDTH * ETHER_TYPE_BYTE_COUNT);
	localparam ETHERNET_HEADER_SIZE		= (2*MAC_ADDRESS_SIZE + ETHER_TYPE_SIZE);
	localparam ARP_HEADER_TYPE			= 16'h0806;
	localparam IP_HEADER_TYPE			= 16'h0800;

	// I/O ports
	input reset;
	input clock;
	input temac_rx_tvalid;
	input [BITS_PER_BEAT-1:0] temac_rx_tdata;
	input [BYTES_PER_BEAT-1:0] temac_rx_tkeep;
	input temac_rx_tlast;
	input [0:0] temac_rx_tuser;
	input temac_rx_filter_tuser;
	input ip_rx_tready;
	output reg ip_rx_tvalid;
	output reg [BITS_PER_BEAT-1:0] ip_rx_tdata;
	output reg [BYTES_PER_BEAT-1:0] ip_rx_tkeep;
	output reg ip_rx_tlast;
	input arp_rx_tready;
	output reg arp_rx_tvalid;
	output reg [BITS_PER_BEAT-1:0] arp_rx_tdata;
	output reg [BYTES_PER_BEAT-1:0] arp_rx_tkeep;
	output reg arp_rx_tlast;
	input [47:0] temac_address;
	output reg [47:0] received_mac_address;
	output reg valid_mac_address;

	wire tready_out;
	reg tvalid_in;
	reg [BITS_PER_BEAT-1:0] tdata_in;
	reg tlast_in;
	reg [BITS_PER_BEAT/8-1:0] tkeep_in;
	reg tready_in;
	wire tvalid_out;
	wire [BITS_PER_BEAT-1:0] tdata_out;
	wire tlast_out;
	wire [BITS_PER_BEAT/8-1:0] tkeep_out;
	wire [ETHERNET_HEADER_SIZE-1:0] header_data;
	wire header_data_valid;

	wire [47:0] source_mac_address;
	wire [47:0] destination_mac_address;
	wire [15:0] ethernet_type;
	wire temac_rx_tready;
	
	reg header_data_valid_reg;
	reg header_pending;
	reg [ETHERNET_HEADER_SIZE-1:0] current_header;
	reg temac_done_pending;
	reg arp_done_pending;
	reg ip_done_pending;
	
	localparam [15:0] WAIT_FOR_ETHERNET_DATA = 16'h0001;
	localparam [15:0] WAIT_FOR_PENDING_CLEAR = 16'h0002;
	localparam [15:0] CHECK_PROTOCOL = 16'h0004;
	localparam [15:0] WAIT_FOR_END_OF_ARP_TRANSACTION = 16'h0008;
	localparam [15:0] WAIT_FOR_ARP_DONE_CLEAR = 16'h0010;
	localparam [15:0] WAIT_FOR_END_OF_IP_TRANSACTION = 16'h0020;
	localparam [15:0] WAIT_FOR_IP_DONE_CLEAR = 16'h0040;
	localparam [15:0] UNSUPPORTED_PROTOCOL = 16'h0080;
	localparam [15:0] WAIT_FOR_TEMAC_READY_CLEAR = 16'h0100;
	
	reg [7:0] ethernet_receive_state;	
	reg clear_header_pending;	
	reg enable_arp_interface;	
	reg enable_ip_interface;	
	reg flush_data_stream;		
	reg clear_arp_done_pending;	
	reg clear_ip_done_pending;	
	reg clear_temac_done_pending;

	byte_swap #(.WIDTH(48))	src_mac (.data_in(current_header[47:0]), .data_out(source_mac_address));	
	byte_swap #(.WIDTH(48))	dest_mac (.data_in(current_header[95:48]), .data_out(destination_mac_address));	
	byte_swap #(.WIDTH(16))	type_len (.data_in(current_header[111:96]), .data_out(ethernet_type));	

	header_capture #(BITS_PER_BEAT, ETHERNET_HEADER_SIZE, PIPELINE_DEPTH) eth_rx (.clock(clock), .reset(reset), .tready_out(temac_rx_tready), .tvalid_in(temac_rx_tvalid), .tdata_in(temac_rx_tdata), .tlast_in(temac_rx_tlast), .tkeep_in(temac_rx_tkeep), .tready_in(tready_in), .tvalid_out(tvalid_out), .tdata_out(tdata_out), .tlast_out(tlast_out), .tkeep_out(tkeep_out), .header_data(header_data), .header_data_valid(header_data_valid));
	
	// Output MUX
	always @(enable_ip_interface, enable_arp_interface, flush_data_stream, ip_rx_tready, arp_rx_tready, tvalid_out, tdata_out, tkeep_out, tlast_out) begin
		if (enable_ip_interface) begin
			tready_in		<= ip_rx_tready;
			ip_rx_tvalid	<= tvalid_out;
			ip_rx_tdata		<= tdata_out;
			ip_rx_tkeep		<= tkeep_out;
			ip_rx_tlast		<= tlast_out;
		end
		else if (enable_arp_interface) begin
			tready_in		<= arp_rx_tready;
			arp_rx_tvalid	<= tvalid_out;
			arp_rx_tdata	<= tdata_out;
			arp_rx_tkeep	<= tkeep_out;
			arp_rx_tlast	<= tlast_out;
		end
		else begin
			tready_in		<= flush_data_stream;
			ip_rx_tvalid	<= 1'b0;
			ip_rx_tdata		<= 0;
			ip_rx_tkeep		<= 0;
			ip_rx_tlast		<= 1'b0;
			arp_rx_tvalid	<= 1'b0;
			arp_rx_tdata	<= 0;
			arp_rx_tkeep	<= 0;
			arp_rx_tlast	<= 1'b0;
		end
	end
	
	// Input side registers
	always @(posedge clock) begin
		header_data_valid_reg	<= header_data_valid;
		
		if (!header_data_valid_reg && header_data_valid) begin
			header_pending	<= 1'b1;
			current_header	<= header_data;
		end
		else if (clear_header_pending) begin
			header_pending	<= 1'b0;
		end

		if (temac_rx_tvalid && temac_rx_tlast) begin
			temac_done_pending	<= 1'b1;
		end
		else if (clear_temac_done_pending) begin
			temac_done_pending	<= 1'b0;
		end

		if (arp_rx_tvalid && arp_rx_tlast) begin
			arp_done_pending	<= 1'b1;
		end
		else if (clear_arp_done_pending) begin
			arp_done_pending	<= 1'b0;
		end

		if (ip_rx_tvalid && ip_rx_tlast) begin
			ip_done_pending		<= 1'b1;
		end
		else if (clear_ip_done_pending) begin
			ip_done_pending		<= 1'b0;
		end
	end
	
	always @(posedge clock or reset) begin
		if (reset) begin
			ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
			clear_header_pending	<= 1'b0;
			enable_arp_interface	<= 1'b0;
			enable_ip_interface		<= 1'b0;
			flush_data_stream		<= 1'b0;
			clear_arp_done_pending	<= 1'b0;
			clear_ip_done_pending	<= 1'b0;
			clear_temac_done_pending<= 1'b0;
			valid_mac_address		<= 1'b0;
		end
		else begin
			case (ethernet_receive_state)
				WAIT_FOR_ETHERNET_DATA:
				begin
					if (header_pending) begin
						clear_header_pending	<= 1'b1;
						ethernet_receive_state	<= WAIT_FOR_PENDING_CLEAR;
					end
				end
				WAIT_FOR_PENDING_CLEAR:
				begin
					if (!header_pending) begin
						clear_header_pending	<= 1'b0;
						ethernet_receive_state	<= CHECK_PROTOCOL;
					end
				end
				CHECK_PROTOCOL:
				begin
					if ((destination_mac_address == temac_address) || (destination_mac_address == BROADCAST_MAC_ADDRESS)) begin
						if (ethernet_type == ARP_HEADER_TYPE) begin
							enable_arp_interface	<= 1'b1;
							valid_mac_address		<= 1'b1;
							ethernet_receive_state	<= WAIT_FOR_END_OF_ARP_TRANSACTION;
						end
						else if (ethernet_type == IP_HEADER_TYPE) begin
							valid_mac_address		<= 1'b1;
							enable_ip_interface		<= 1'b1;
							ethernet_receive_state	<= WAIT_FOR_END_OF_IP_TRANSACTION;
						end
						else begin
							enable_arp_interface	<= 1'b0;
							enable_ip_interface		<= 1'b0;
							flush_data_stream		<= 1'b1;
							valid_mac_address		<= 1'b0;
							ethernet_receive_state	<= UNSUPPORTED_PROTOCOL;
						end
					end
					else begin
						enable_arp_interface	<= 1'b0;
						enable_ip_interface		<= 1'b0;
						flush_data_stream		<= 1'b1;
						valid_mac_address		<= 1'b0;
						ethernet_receive_state	<= UNSUPPORTED_PROTOCOL;
					end
				end
				WAIT_FOR_END_OF_ARP_TRANSACTION:
				begin
					if (arp_done_pending) begin
						clear_arp_done_pending	<= 1'b1;
						ethernet_receive_state	<= WAIT_FOR_ARP_DONE_CLEAR;
					end
				end
				WAIT_FOR_ARP_DONE_CLEAR:
				begin
					if (!arp_done_pending) begin
						clear_arp_done_pending	<= 1'b0;
						ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
					end
				end
				WAIT_FOR_END_OF_IP_TRANSACTION:
				begin
					if (ip_done_pending) begin
						clear_ip_done_pending	<= 1'b1;
						ethernet_receive_state	<= WAIT_FOR_IP_DONE_CLEAR;
					end
				end
				WAIT_FOR_IP_DONE_CLEAR:
				begin
					if (!ip_done_pending) begin
						clear_ip_done_pending	<= 1'b0;
						ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
					end
				end
				UNSUPPORTED_PROTOCOL:
				begin
					if (temac_done_pending) begin
						flush_data_stream		<= 1'b0;
						clear_temac_done_pending<= 1'b1;
						ethernet_receive_state	<= WAIT_FOR_TEMAC_READY_CLEAR;
					end
				end
				WAIT_FOR_TEMAC_READY_CLEAR:
				begin
					if (!temac_done_pending) begin
						clear_temac_done_pending<= 1'b0;
						ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
					end
				end
				default : ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
			endcase
		end
	end
endmodule
