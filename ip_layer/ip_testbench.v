`timescale 1ns/1ps
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/global_parameters.vh"

module ip_testbench;

	localparam BITS_PER_BEAT 	= 128;
	localparam PIPELINE_DEPTH 	= 16;
	localparam BYTES_PER_BEAT	= BITS_PER_BEAT/8;
	localparam TOTAL_BYTE_COUNT = 2048;
	localparam TOTAL_BIT_COUNT  = TOTAL_BYTE_COUNT * 8;

	localparam [31:0] LOCAL_IP_ADDRESS = 32'hA9FEA810;
	localparam [47:0] SRC_MAC_ADDRESS = SOURCE_MAC_ADDRESS;
	localparam [47:0] DEST_MAC_ADDRESS = DESTINATION_MAC_ADDRESS;
	localparam [15:0] ETH_TYPE = 16'h0806;
	localparam TOTAL_HEADER_SIZE = `IP_HEADER_SIZE + `ETHERNET_HEADER_SIZE;

	ip_receiver #(BITS_PER_BEAT, PIPELINE_DEPTH) dut_ip_rx (reset, clock, eth_rx_tready, eth_rx_tvalid, eth_rx_tdata, eth_rx_tkeep, eth_rx_tlast, udp_rx_tready, udp_rx_tvalid, udp_rx_tdata, udp_rx_tkeep, udp_rx_tlast, tcp_rx_tready, tcp_rx_tvalid, tcp_rx_tdata, tcp_rx_tkeep, tcp_rx_tlast, icmp_rx_tready, icmp_rx_tvalid, icmp_rx_tdata, icmp_rx_tkeep, icmp_rx_tlast, LOCAL_IP_ADDRESS, source_ip_address, dest_ip_address);
	
	reg clock;
	reg reset;

	wire eth_rx_tready;
	reg eth_rx_tvalid;
	reg [BITS_PER_BEAT-1:0]  eth_rx_tdata;
	reg [BYTES_PER_BEAT-1:0] eth_rx_tkeep;
	reg eth_rx_tlast;
	reg udp_rx_tready;
	wire udp_rx_tvalid;
	wire [BITS_PER_BEAT-1:0]  udp_rx_tdata;
	wire [BYTES_PER_BEAT-1:0] udp_rx_tkeep;
	wire udp_rx_tlast;
	reg tcp_rx_tready;
	wire tcp_rx_tvalid;
	wire [BITS_PER_BEAT-1:0]  tcp_rx_tdata;
	wire [BYTES_PER_BEAT-1:0] tcp_rx_tkeep;
	wire tcp_rx_tlast;
	reg icmp_rx_tready;
	wire icmp_rx_tvalid;
	wire [BITS_PER_BEAT-1:0]  icmp_rx_tdata;
	wire [BYTES_PER_BEAT-1:0] icmp_rx_tkeep;
	wire icmp_rx_tlast;
	wire [31:0] source_ip_address;
	wire [31:0] dest_ip_address;
	
	// IP layer header
	localparam [3:0] IPV4_VERSION;
	localparam [3:0] IPV4_IHL;
	localparam [5:0] IPV4_DSCP;
	localparam [1:0] IPV4_ECN;
	localparam [15:0] IPV4_TOTAL_LENGTH ;
	localparam [15:0] IPV4_IDENTIFICATION ;
	localparam [2:0] IPV4_FLAGS;
	localparam [12:0] IPV4_FRAGMENT_OFFSET ;
	localparam [7:0] IPV4_TTL;
	localparam [7:0] IPV4_PROTOCOL;
	localparam [15:0] IPV4_HEADER_CHECKSUM ;
	localparam [31:0] IPV4_SOURCE_ADDRESS ;
	localparam [31:0] IPV4_DESTINATION_ADDRESS ;
	
	// IPv4 header
	wire [3:0]  ip_version				;
	wire [3:0]  ip_length				;
	wire [5:0]  ip_dscp					;
	wire [1:0]  ip_ecn					;
	wire [15:0] ip_total_length			;
	wire [7:0]  ip_identification		;
	wire [2:0]  ip_flags				;
	wire [12:0] ip_offset				;
	wire [7:0]  ip_ttl					;
	wire [7:0]  ip_protocol				;
	wire [15:0] ip_checksum				;
	wire [31:0] ip_source_address		;
	wire [31:0] ip_destination_address	;
	wire [15:0] ip_flags_fragment		;	// Contains a 3-bit field and a 13 bit field
	wire [`IP_HEADER_SIZE-1:0] ip_datagram_header;
	assign ip_datagram_header = {ip_destination_address, ip_source_address,	ip_checksum, ip_protocol, ip_ttl, ip_flags_fragment, ip_identification,	ip_total_length, ip_ecn, ip_dscp, ip_length, ip_version};
	
	// Ethernet header
	wire [ETH_HEADER_SIZE-1:0] header_data_112bit;
	wire [47:0] source_mac_address;
	wire [47:0] destination_mac_address;
	wire [15:0] ethernet_type;

	byte_swap #(.WIDTH(48))	src_mac (.data_in(SRC_MAC_ADDRESS),	.data_out(source_mac_address));	
	byte_swap #(.WIDTH(48))	dest_mac (.data_in(DEST_MAC_ADDRESS), .data_out(destination_mac_address));	
	byte_swap #(.WIDTH(16))	type_len (.data_in(ETH_TYPE), .data_out(ethernet_type));	

	assign header_data_112bit = {ethernet_type, destination_mac_address, source_mac_address};
	assign eth_datagram_header = header_data_112bit;		
	
	assign ip_version = IPV4_VERSION;														
	assign ip_length = IPV4_IHL;															
	assign ip_dscp = IPV4_DSCP;																
	assign ip_ecn = IPV4_ECN;																
	byte_swap #(.WIDTH(16))	ip_length (.data_in(IPV4_TOTAL_LENGTH), .data_out(ip_total_length));				
	byte_swap #(.WIDTH(16))	ip_id (.data_in(IPV4_IDENTIFICATION), .data_out(ip_identification));				
	assign ip_flags = IPV4_FLAGS;														
	assign ip_offset = IPV4_FRAGMENT_OFFSET;											
	byte_swap #(.WIDTH(16))	ip_flags_frag (.data_in({IPV4_FLAGS, IPV4_FRAGMENT_OFFSET}), .data_out(ip_flags_fragment));							
	assign ip_ttl = IPV4_TTL;															
	assign ip_protocol = IPV4_PROTOCOL;													
	byte_swap #(.WIDTH(16))	ip_checksum (.data_in(IPV4_HEADER_CHECKSUM), .data_out(ip_checksum));									
	byte_swap #(.WIDTH(32))	ip_src_addr (.data_in(IPV4_SOURCE_ADDRESS), .data_out(ip_source_address));							
	byte_swap #(.WIDTH(32))	ip_dest_addr (.data_in(IPV4_DESTINATION_ADDRESS), .data_out(ip_destination_address));

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
	
	generate
		if (BITS_PER_BEAT == TOTAL_HEADER_SIZE) begin: same_data_size
			always @(posedge clock or reset) begin
				if (reset) begin
					ip_layer_state			<= IDLE;
					header_shift_register	<= 0;
					prbs_shift_register		<= 0;
					current_prbs_pattern	<= 32'hFFFFFFFF;
				end
				else begin
					case (ip_layer_state)
						IDLE:
						begin
							header_shift_register	<= 0;
							
							// Create the large array containing the PRBS data
							prbs_shift_register		<= prbs_data_array(current_prbs_pattern);
							
						end
						default : ip_layer_state	<= IDLE;
					end case
				end
			end
		end
		else if (BITS_PER_BEAT > TOTAL_HEADER_SIZE) begin: large_data_size
		
		end
		else if ((TOTAL_HEADER_SIZE % BITS_PER_BEAT) == 0) begin: small_data_size_even
		
		end
		else if ((TOTAL_HEADER_SIZE % BITS_PER_BEAT) != 0) begin: small_data_size_odd
		
		end
	endgenerate
endmodule	