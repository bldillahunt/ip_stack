`timescale 1ns/1ps

module ip_layer_testbench;
	localparam DATA_WIDTH =	8;
	localparam BROADCAST_MAC_ADDRESS = 48'hFFFFFFFFFFFF;
	localparam SOURCE_MAC_ADDRESS = 48'h112233445566;
	localparam DESTINATION_MAC_ADDRESS = 48'hF071AD9025B4;
	localparam ETHER_TYPE = 16'h0800;
	localparam ETHERNET_HEADER_BYTE_COUNT = 14;
	localparam INTERPACKET_GAP_TIME = 12;
	localparam UDP_PROTOCOL			= 8'h11;
	localparam TCP_PROTOCOL			= 8'h06;
	localparam ICMP_PROTOCOL		= 8'h01;

	wire [DATA_WIDTH-1:0] ethernet_header[ETHERNET_HEADER_BYTE_COUNT-1:0]; 
																		  
	assign ethernet_header[0] 	= SOURCE_MAC_ADDRESS[47:40];																		  
	assign ethernet_header[1] 	= SOURCE_MAC_ADDRESS[39:32]; 																	  
	assign ethernet_header[2] 	= SOURCE_MAC_ADDRESS[31:24]; 																	  
	assign ethernet_header[3] 	= SOURCE_MAC_ADDRESS[23:16]; 																	  
	assign ethernet_header[4] 	= SOURCE_MAC_ADDRESS[15:8]; 																	  
	assign ethernet_header[5] 	= SOURCE_MAC_ADDRESS[7:0];																	  
	assign ethernet_header[6] 	= DESTINATION_MAC_ADDRESS[47:40];																	  
	assign ethernet_header[7] 	= DESTINATION_MAC_ADDRESS[39:32];																	  
	assign ethernet_header[8] 	= DESTINATION_MAC_ADDRESS[31:24];																	  
	assign ethernet_header[9] 	= DESTINATION_MAC_ADDRESS[23:16];																	  
	assign ethernet_header[10] 	= DESTINATION_MAC_ADDRESS[15:8]; 																	  
	assign ethernet_header[11] 	= DESTINATION_MAC_ADDRESS[7:0];																	  
	assign ethernet_header[12] 	= ETHER_TYPE[15:8];																	  
	assign ethernet_header[13]  = ETHER_TYPE[7:0];
	
	localparam DATA_PAYLOAD_SIZE = 1472;
	localparam TOTAL_BYTE_COUNT	= DATA_PAYLOAD_SIZE;
	localparam TOTAL_WORD_COUNT = DATA_PAYLOAD_SIZE/4;
	localparam START_OF_FRAME = 4'b0001;
	localparam TRANSMIT_ETHERNET_HEADER = 4'b0010;
	localparam TRANSMIT_IP_HEADER = 4'b0100;
	localparam TRANSMIT_PAYLOAD = 4'b1000;

	integer current_packet_size[9:0];
	integer packet_size_pointer;
	
	reg clock;
	reg reset;
	reg temac_rx_tvalid;
	reg [DATA_WIDTH-1:0] temac_rx_tdata;
	reg temac_rx_tlast;
	reg [0:0] temac_rx_tuser;
	reg temac_rx_filter_tuser;
	wire ip_rx_tready;
	wire ip_rx_tvalid;
	wire [DATA_WIDTH-1:0] ip_rx_tdata;
	wire ip_rx_tlast;
	wire arp_rx_tready;
	wire arp_rx_tvalid;
	wire [DATA_WIDTH-1:0] arp_rx_tdata;
	wire arp_rx_tlast;
	wire [47:0] temac_address;
	assign temac_address = DESTINATION_MAC_ADDRESS;
	wire [47:0] received_mac_address;
	wire valid_mac_address;
	reg [3:0] mac_receiver_state;
	integer interpacket_gap_timer;
	integer eth_data_counter;	
	integer ip_data_counter;		
	integer payload_data_counter;
	
	reg [31:0] lfsr_data_register;
	reg [31:0] lfsr_shift_register;
	integer lfsr_data_counter;
	
	reg [31:0] lfsr_test_vector;
	integer i;
	
	localparam WAIT_FOR_END_OF_FRAME = 4'b0001;
	localparam START_IP_VERIFICATION = 4'b0010;
	localparam VERIFY_IP_DATA = 4'b0100;
	
	// IP Layer
	localparam IP_LAYER_BYTE_COUNT = 20;
	wire udp_rx_tready;
	wire udp_rx_tvalid;
	wire [7:0] udp_rx_tdata;
	wire udp_rx_tlast;
	wire tcp_rx_tready;
	wire tcp_rx_tvalid;
	wire [7:0] tcp_rx_tdata;
	wire tcp_rx_tlast;
	wire icmp_rx_tready;
	wire icmp_rx_tvalid;
	wire [7:0] icmp_rx_tdata;
	wire icmp_rx_tlast;
	reg [31:0] local_ip_address;
	wire [31:0] source_ip_address;
	wire [31:0] dest_ip_address;
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
	reg [31:0] ip_dest_address;
		
	reg [7:0] ip_data_buffer[19:0];
	reg [10*16-1:0] checksum_data_array;
	
	assign udp_rx_tready = 1'b1;
	assign tcp_rx_tready = 1'b1;
	assign icmp_rx_tready = 1'b1;
		
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

	localparam CHECKSUM_DATA_SIZE	= 16;
	localparam CHECKSUM_ARRAY_SIZE	= 10;
	
	// 16-bit checksum calculator
	function [CHECKSUM_DATA_SIZE-1:0] checksum_16bit;
		input [CHECKSUM_DATA_SIZE*CHECKSUM_ARRAY_SIZE-1:0] addend_data;
		reg [31:0] primary_sum;
		integer i;
		reg [15:0] checksum_temp;
		begin
			primary_sum	= 0;

			for (i = 0; i < CHECKSUM_ARRAY_SIZE; i = i + 1) begin
				primary_sum	= primary_sum + addend_data[i*CHECKSUM_DATA_SIZE +: CHECKSUM_DATA_SIZE];
				$display("input = %04H\n", addend_data[i*CHECKSUM_DATA_SIZE +: CHECKSUM_DATA_SIZE]);			
			end
			
			$display("primary sum = %08H\n", primary_sum);			
			
			while (primary_sum[31:16] != 0) begin
				primary_sum		= primary_sum[31:16] + primary_sum[15:0];
			end
			
			$display("primary sum = %08H\n", primary_sum);			

			checksum_temp	= primary_sum[15:0];

			$display("checksum temp = %04H\n", checksum_temp);			
			
			if (checksum_temp != 16'hFFFF) begin
				checksum_16bit	= ~checksum_temp;
			end
			else begin
				checksum_16bit	= checksum_temp;
			end

			$display("checksum temp = %04H\n", checksum_16bit);			
		end
	endfunction
	
	ethernet_datagram_receiver #(DATA_WIDTH, BROADCAST_MAC_ADDRESS, ETHERNET_HEADER_BYTE_COUNT) dut_eth_layer (reset, clock, temac_rx_tvalid, temac_rx_tdata, temac_rx_tlast, temac_rx_tuser, temac_rx_filter_tuser, ip_rx_tready, ip_rx_tvalid, ip_rx_tdata, ip_rx_tlast, arp_rx_tready, arp_rx_tvalid, arp_rx_tdata, arp_rx_tlast, temac_address, received_mac_address, valid_mac_address);
	ip_datagram_receiver #(DATA_WIDTH, IP_LAYER_BYTE_COUNT) dut_ip_layer (reset, clock, ip_rx_tready, ip_rx_tvalid, ip_rx_tdata, ip_rx_tlast, udp_rx_tready, udp_rx_tvalid, udp_rx_tdata, udp_rx_tlast, tcp_rx_tready, tcp_rx_tvalid, tcp_rx_tdata, tcp_rx_tlast, icmp_rx_tready, icmp_rx_tvalid, icmp_rx_tdata, icmp_rx_tlast, local_ip_address, source_ip_address, dest_ip_address);
	
	initial begin
		local_ip_address = 32'hAABBCCDD;
		ip_source_address = 32'h00112233;
		ip_dest_address = 32'h33221100;
		ip_version = 4'h4;
		ip_header_length = 4'h5;
		ip_dscp = 0;
		ip_ecn = 0;
		ip_total_length = 20 + DATA_PAYLOAD_SIZE;
		ip_identification = 0;
		ip_flags = 0;
		ip_fragment_offset = 0;
		ip_ttl = 10;
		ip_protocol = UDP_PROTOCOL;
		ip_data_buffer[0] 	= {ip_version, ip_header_length};
		ip_data_buffer[1] 	= {ip_dscp, ip_ecn};
		ip_data_buffer[2] 	= ip_total_length[15:8];
		ip_data_buffer[3] 	= ip_total_length[7:0];
		ip_data_buffer[4] 	= 8'h00;
		ip_data_buffer[5] 	= 8'h00;
		ip_data_buffer[6] 	= 8'h00;
		ip_data_buffer[7] 	= 8'h00;
		ip_data_buffer[8] 	= ip_ttl;
		ip_data_buffer[9] 	= ip_protocol;
		ip_data_buffer[10] 	= 0;	// ip_header_checksum[15:8];
		ip_data_buffer[11] 	= 0;	// ip_header_checksum[7:0];
		ip_data_buffer[12] 	= ip_source_address[31:24];
		ip_data_buffer[13]  = ip_source_address[23:16];
		ip_data_buffer[14]	= ip_source_address[15:8];
		ip_data_buffer[15]	= ip_source_address[7:0];
		ip_data_buffer[16]	= ip_dest_address[31:24];
		ip_data_buffer[17]	= ip_dest_address[23:16];
		ip_data_buffer[18]	= ip_dest_address[15:8];
		ip_data_buffer[19]	= ip_dest_address[7:0];

		$display("ip_data_buffer[0] = %02H\t%01H\t%01H\n", ip_data_buffer[0], ip_version, ip_header_length);

		for (i = 0; i < 10; i = i + 1) begin
			checksum_data_array[16*i+:16] = {ip_data_buffer[i*2], ip_data_buffer[i*2+1]};
			$display("checksum data array %d = %016b\t%08b\t%08b\n", i, checksum_data_array[16*i+:16], ip_data_buffer[i*2], ip_data_buffer[i*2+1]);
		end

		ip_header_checksum = checksum_16bit(checksum_data_array);
		ip_data_buffer[10] 	= ip_header_checksum[15:8];
		ip_data_buffer[11] 	= ip_header_checksum[7:0];
	end
	
	initial begin
		current_packet_size[0]  = DATA_PAYLOAD_SIZE;
		current_packet_size[1]  = DATA_PAYLOAD_SIZE/2;
		current_packet_size[2]  = DATA_PAYLOAD_SIZE/4;
		current_packet_size[3]  = DATA_PAYLOAD_SIZE/8;
		current_packet_size[4]  = DATA_PAYLOAD_SIZE/16;
		current_packet_size[5]  = DATA_PAYLOAD_SIZE;
		current_packet_size[6]  = DATA_PAYLOAD_SIZE/2;
		current_packet_size[7]  = DATA_PAYLOAD_SIZE/4;
		current_packet_size[8]  = DATA_PAYLOAD_SIZE/8;
		current_packet_size[9]  = DATA_PAYLOAD_SIZE/16;
	end

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

	// Emulate the CMAC
	always @(posedge clock or reset) begin
		if (reset == 1'b1) begin
			mac_receiver_state		<= START_OF_FRAME;
			interpacket_gap_timer	<= 0;
			temac_rx_tvalid			<= 0;
			temac_rx_tdata			<= 0;
			temac_rx_tlast			<= 0;
			temac_rx_tuser			<= 0;
			temac_rx_filter_tuser	<= 0;
			eth_data_counter		<= 0;
			ip_data_counter			<= 0;
			payload_data_counter	<= 0;
			lfsr_data_register		<= 32'h0FFFFFFF;
			lfsr_shift_register		<= 0;
			lfsr_data_counter		<= 0;
			packet_size_pointer		<= 0;
		end
		else begin
			case (mac_receiver_state)
				START_OF_FRAME:
				begin
					if (interpacket_gap_timer < INTERPACKET_GAP_TIME-1) begin
						interpacket_gap_timer	<= interpacket_gap_timer + 1;
					end
					else begin
						interpacket_gap_timer	<= 0;
						eth_data_counter		<= 0;
						ip_data_counter			<= 0;
						payload_data_counter	<= 0;
						mac_receiver_state		<= TRANSMIT_ETHERNET_HEADER;
					end
				end
				TRANSMIT_ETHERNET_HEADER:
				begin
					if (eth_data_counter < ETHERNET_HEADER_BYTE_COUNT) begin
						temac_rx_tvalid			<= 1'b1;
						temac_rx_tdata			<= ethernet_header[eth_data_counter];
						temac_rx_tuser			<= 1'b0;
						temac_rx_filter_tuser	<= 1'b0;
						temac_rx_tlast			<= 1'b0;
						eth_data_counter		<= eth_data_counter + 1;
					end
					else begin	// Test to make sure the receiver can handle intermittent data
						temac_rx_tvalid			<= 1'b1;
						temac_rx_tdata			<= ip_data_buffer[ip_data_counter];
						temac_rx_tuser			<= 1'b0;
						temac_rx_filter_tuser	<= 1'b0;
						temac_rx_tlast			<= 1'b0;
						ip_data_counter			<= 1;
						lfsr_data_register		<= prbs_pattern_generator(1'b1, lfsr_data_register);
						mac_receiver_state		<= TRANSMIT_IP_HEADER;
					end	
				end
				TRANSMIT_IP_HEADER:
				begin
					if (ip_data_counter < IP_LAYER_BYTE_COUNT) begin
						temac_rx_tvalid			<= 1'b1;
						temac_rx_tdata			<= ip_data_buffer[ip_data_counter];
						temac_rx_tuser			<= 1'b0;
						temac_rx_filter_tuser	<= 1'b0;
						temac_rx_tlast			<= 1'b0;
						ip_data_counter			<= ip_data_counter + 1;
					end
					else begin
						lfsr_data_counter		<= 1;
						temac_rx_tvalid			<= 1'b1;
						temac_rx_tdata			<= lfsr_data_register[31:24];
						temac_rx_tlast			<= 1'b0;
						temac_rx_tuser			<= 1'b0;
						temac_rx_filter_tuser	<= 1'b0;
						lfsr_shift_register		<= lfsr_data_register << 8;
						lfsr_data_register		<= prbs_pattern_generator(1'b1, lfsr_data_register);
						mac_receiver_state		<= TRANSMIT_PAYLOAD;
					end
				end
				TRANSMIT_PAYLOAD:
				begin
					if (payload_data_counter < current_packet_size[packet_size_pointer]-1) begin
						temac_rx_tvalid			<= 1'b1;
						
						if (lfsr_data_counter == 3) begin
							lfsr_shift_register<= lfsr_data_register;
							lfsr_data_register <= prbs_pattern_generator(1'b1, lfsr_data_register);
						end
						else if (lfsr_data_counter < 4) begin
							lfsr_shift_register <= lfsr_shift_register << 8;
						end
							
						if (lfsr_data_counter == 3) begin
							lfsr_data_counter	<= 0;
						end
						else begin
							lfsr_data_counter	<= lfsr_data_counter + 1;
						end
							
						temac_rx_tdata			<= lfsr_shift_register[31:24];
						temac_rx_tuser			<= 1'b0;
						temac_rx_filter_tuser	<= 1'b0;

						if (payload_data_counter == current_packet_size[packet_size_pointer]-2) begin
							temac_rx_tlast			<= 1'b1;
						end
						else begin
							temac_rx_tlast			<= 1'b0;
						end

						payload_data_counter			<= payload_data_counter + 1;
					end
					else begin
						temac_rx_tvalid			<= 0;
						temac_rx_tdata			<= 0;
						temac_rx_tlast			<= 0;
						temac_rx_tuser			<= 0;
						temac_rx_filter_tuser	<= 0;
						
						if (packet_size_pointer < 9) begin
							packet_size_pointer	<= packet_size_pointer + 1;
						end
						else begin
							packet_size_pointer	<= 0;	
						end
						
						mac_receiver_state		<= START_OF_FRAME;
					end
				end
				default: mac_receiver_state		<= START_OF_FRAME;
			endcase
		end
	end
	
	always @(posedge clock or reset) begin
		if (reset) begin
			lfsr_test_vector	<= 32'h0f0f0f0f;
		end
		else begin
			lfsr_test_vector	<= prbs_pattern_generator(1'b1, lfsr_test_vector);
		end
	end
	
	// Emulate the ARP receiver module
	assign arp_rx_tready = 1'b1;
endmodule