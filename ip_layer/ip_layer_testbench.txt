`timescale 1ns/1ps

module ethernet_layer_testbench;
	localparam DATA_WIDTH =	8;
	localparam BROADCAST_MAC_ADDRESS = 48'hFFFFFFFFFFFF;
	localparam SOURCE_MAC_ADDRESS = 48'h112233445566;
	localparam DESTINATION_MAC_ADDRESS = 48'hF071AD9025B4;
	localparam ETHER_TYPE = 16'h0800;
	localparam HEADER_BYTE_COUNT = 14;
	localparam INTERPACKET_GAP_TIME = 12;
	wire [DATA_WIDTH-1:0] ethernet_header[HEADER_BYTE_COUNT-1:0]; 
																		  
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
	localparam TOTAL_BYTE_COUNT	= DATA_PAYLOAD_SIZE + HEADER_BYTE_COUNT;
	localparam TOTAL_WORD_COUNT = DATA_PAYLOAD_SIZE/4;
	localparam START_OF_FRAME = 4'b0001;
	localparam TRANSMIT_ETHERNET_HEADER = 4'b0010;
	localparam TRANSMIT_PAYLOAD = 4'b0100;

	integer current_packet_size[9:0];
	integer packet_size_pointer;
	
	reg clock;
	reg reset;
	reg temac_rx_tvalid;
	reg [DATA_WIDTH-1:0] temac_rx_tdata;
	reg temac_rx_tlast;
	reg [0:0] temac_rx_tuser;
	reg temac_rx_filter_tuser;
	reg ip_rx_tready;
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
	integer data_counter;
	reg [31:0] lfsr_data_register;
	reg [31:0] lfsr_shift_register;
	integer lfsr_data_counter;
	
	reg [31:0] lfsr_test_vector;
	integer i;
	
//	reg [31:0] ip_data_buffer [TOTAL_WORD_COUNT-1:0];
	reg [3:0] ip_data_state;		
	integer ip_byte_count;		
	reg [31:0] ip_rx_shift_register;
	reg latch_ip_data;		
	integer ip_input_pointer;	
	reg [31:0] ip_lfsr_register;
	reg ip_data_valid;
	reg ip_rx_tlast_reg;
	
	localparam WAIT_FOR_END_OF_FRAME = 4'b0001;
	localparam START_IP_VERIFICATION = 4'b0010;
	localparam VERIFY_IP_DATA = 4'b0100;
	
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
	
	ethernet_datagram_receiver #(DATA_WIDTH, BROADCAST_MAC_ADDRESS, HEADER_BYTE_COUNT) dut (reset, clock, temac_rx_tvalid, temac_rx_tdata, temac_rx_tlast, temac_rx_tuser, temac_rx_filter_tuser, ip_rx_tready, ip_rx_tvalid, ip_rx_tdata, ip_rx_tlast, arp_rx_tready, arp_rx_tvalid, arp_rx_tdata, arp_rx_tlast, temac_address, received_mac_address, valid_mac_address);
	
	initial begin
		current_packet_size[0]  = DATA_PAYLOAD_SIZE + HEADER_BYTE_COUNT;
		current_packet_size[1]  = DATA_PAYLOAD_SIZE/2 + HEADER_BYTE_COUNT;
		current_packet_size[2]  = DATA_PAYLOAD_SIZE/4 + HEADER_BYTE_COUNT;
		current_packet_size[3]  = DATA_PAYLOAD_SIZE/8 + HEADER_BYTE_COUNT;
		current_packet_size[4]  = DATA_PAYLOAD_SIZE/16 + HEADER_BYTE_COUNT;
		current_packet_size[5]  = DATA_PAYLOAD_SIZE + HEADER_BYTE_COUNT;
		current_packet_size[6]  = DATA_PAYLOAD_SIZE/2 + HEADER_BYTE_COUNT;
		current_packet_size[7]  = DATA_PAYLOAD_SIZE/4 + HEADER_BYTE_COUNT;
		current_packet_size[8]  = DATA_PAYLOAD_SIZE/8 + HEADER_BYTE_COUNT;
		current_packet_size[9]  = DATA_PAYLOAD_SIZE/16 + HEADER_BYTE_COUNT;
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
			data_counter			<= 0;
			lfsr_data_register		<= 0;
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
						data_counter			<= 0;
						mac_receiver_state		<= TRANSMIT_ETHERNET_HEADER;
					end
				end
				TRANSMIT_ETHERNET_HEADER:
				begin
					if (data_counter < HEADER_BYTE_COUNT) begin
						temac_rx_tvalid			<= 1'b1;
						temac_rx_tdata			<= ethernet_header[data_counter];
						temac_rx_tuser			<= 1'b0;
						temac_rx_filter_tuser	<= 1'b0;
						temac_rx_tlast			<= 1'b0;
						data_counter			<= data_counter + 1;
					end
					else begin	// Test to make sure the receiver can handle intermittent data
						temac_rx_tvalid			<= 0;
						temac_rx_tdata			<= 0;
						temac_rx_tlast			<= 0;
						temac_rx_tuser			<= 0;
						temac_rx_filter_tuser	<= 0;
						lfsr_data_register		= prbs_pattern_generator(1'b1, 32'h0FFFFFFF);
						lfsr_shift_register		<= lfsr_data_register;
						lfsr_data_register		= prbs_pattern_generator(1'b1, lfsr_data_register);
						lfsr_data_counter		<= 1;
						mac_receiver_state		<= TRANSMIT_PAYLOAD;
					end
				end
				TRANSMIT_PAYLOAD:
				begin
					if (data_counter < current_packet_size[packet_size_pointer]) begin
						temac_rx_tvalid			<= 1'b1;
						
						if (lfsr_data_counter == 0) begin
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

						if (data_counter == current_packet_size[packet_size_pointer]-1) begin
							temac_rx_tlast			<= 1'b1;
						end
						else begin
							temac_rx_tlast			<= 1'b0;
						end

						data_counter			<= data_counter + 1;
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
			lfsr_test_vector	<= 32'h0f0f0f0f0f0f0f0f;
		end
		else begin
			lfsr_test_vector	<= prbs_pattern_generator(1'b1, lfsr_test_vector);
		end
	end
	
	// Emulate the IP receiver module and verify the data
	always @(posedge clock or reset) begin
		if (reset) begin
			ip_data_state		<= WAIT_FOR_END_OF_FRAME;
		   	ip_rx_tready 		<= 1'b0;
		   	ip_byte_count		<= 0;
		   	ip_rx_shift_register<= 32'h00000000;
		   	latch_ip_data		<= 0;
		   	ip_input_pointer	<= 0;
		   	ip_lfsr_register	<= 0;
		   	
		   	for (i = 0; i < TOTAL_WORD_COUNT; i = i + 1) begin
		   		ip_data_buffer[i]	<= 32'h00000000;
		   	end
		   	ip_data_valid		<= 1'b0;
		   	ip_rx_tlast_reg		<= 0;
		end
		else begin
			ip_rx_tready = 1'b1;
			ip_rx_tlast_reg	<= ip_rx_tlast;
			
			case (ip_data_state)
				WAIT_FOR_END_OF_FRAME:
				begin
					if (ip_rx_tvalid) begin
						ip_rx_shift_register	<= {ip_rx_shift_register[23:0], ip_rx_tdata};

						if (ip_byte_count < 3) begin
							latch_ip_data	<= 1'b0;
							ip_byte_count	<= ip_byte_count + 1;
						end
						else begin
							latch_ip_data	<= 1'b1;
							ip_byte_count	<= 0;
						end
					end
			    
					if (latch_ip_data) begin
						ip_data_buffer[ip_input_pointer]	<= ip_rx_shift_register;
						ip_input_pointer	<= ip_input_pointer + 1;
					end
		  			
		  			if (ip_rx_tlast_reg) begin
		  				latch_ip_data		<= 0;
		  				ip_data_state		<= START_IP_VERIFICATION;
		  			end
		  		end	
				START_IP_VERIFICATION:
				begin
	  				ip_input_pointer	<= 0;
					ip_lfsr_register	<= prbs_pattern_generator(1'b1, 32'h0FFFFFFF);
					ip_data_state		<= VERIFY_IP_DATA;
				end
				VERIFY_IP_DATA:
				begin
					if (ip_data_buffer[ip_input_pointer] == ip_lfsr_register) begin
						ip_data_valid	<= 1'b1;
					end
					else begin
						ip_data_valid	<= 1'b0;
					end

					if (ip_input_pointer < TOTAL_WORD_COUNT-1) begin
						ip_lfsr_register 	<= prbs_pattern_generator(1'b1, ip_lfsr_register);
						ip_input_pointer	<= ip_input_pointer + 1;
					end
					else begin
						ip_input_pointer	<= 0;
						ip_data_state		<= WAIT_FOR_END_OF_FRAME;
					end
				end
				default: 	ip_data_state	<= WAIT_FOR_END_OF_FRAME;
			endcase
		end
	end
	
	// Emulate the ARP receiver module
	assign arp_rx_tready = 1'b1;
endmodule