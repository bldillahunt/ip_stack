
module ip_datagram_receiver (reset, clock, eth_rx_tready, eth_rx_tvalid, eth_rx_tdata, eth_rx_tlast, udp_rx_tready, udp_rx_tvalid, udp_rx_tdata, udp_rx_tlast, tcp_rx_tready, tcp_rx_tvalid, tcp_rx_tdata, tcp_rx_tlast, icmp_rx_tready, icmp_rx_tvalid, icmp_rx_tdata, icmp_rx_tlast, local_ip_address, source_ip_address, dest_ip_address);
	// Parameters
	parameter DATA_WIDTH		= 8;
	parameter HEADER_BYTE_COUNT	= 20;

	localparam LENGTH_LOW_BYTE		= 2;
	localparam LENGTH_HIGH_BYTE		= 3;
	localparam ID_LOW_BYTE			= 4;
	localparam ID_HIGH_BYTE			= 5;
	localparam FRAGMENT_LOW_BYTE	= 6;
	localparam FRAGMENT_HIGH_BYTE	= 7;
	localparam CHECKSUM_LOW_BYTE	= 10;
	localparam CHECKSUM_HIGH_BYTE	= 11;
	localparam SOURCE_ADDRESS_BYTE0	= 12;
	localparam SOURCE_ADDRESS_BYTE1	= 13;
	localparam SOURCE_ADDRESS_BYTE2	= 14;
	localparam SOURCE_ADDRESS_BYTE3	= 15;
	localparam DEST_ADDRESS_BYTE0	= 16;
	localparam DEST_ADDRESS_BYTE1	= 17;
	localparam DEST_ADDRESS_BYTE2	= 18;
	localparam DEST_ADDRESS_BYTE3	= 19;
	localparam UDP_PROTOCOL			= 8'h11;
	localparam TCP_PROTOCOL			= 8'h06;
	localparam ICMP_PROTOCOL		= 8'h01;
	localparam INPUT_BUFFER_SIZE	= 32;
	
	input 	reset;
	input 	clock;
	input 	eth_rx_tvalid;
	input 	[DATA_WIDTH-1:0] eth_rx_tdata;
	input 	eth_rx_tlast;
	output 	eth_rx_tready;
	input	udp_rx_tready;
	output 	udp_rx_tvalid;
	output 	[DATA_WIDTH-1:0] udp_rx_tdata;
	output 	udp_rx_tlast;
	input	tcp_rx_tready;
	output 	tcp_rx_tvalid;
	output 	[DATA_WIDTH-1:0] tcp_rx_tdata;
	output 	tcp_rx_tlast;
	input	icmp_rx_tready;
	output 	icmp_rx_tvalid;
	output 	[DATA_WIDTH-1:0] icmp_rx_tdata;
	output 	icmp_rx_tlast;
	input	[31:0] local_ip_address;
	output 	[31:0] source_ip_address;
	output 	[31:0] dest_ip_address;
	
	// Input side registers
	reg eth_rx_tready;
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
	integer byte_counter;
	
	// Output side registers
	reg udp_rx_tvalid;
	reg [7:0] udp_rx_tdata;
	reg udp_rx_tlast;
	reg tcp_rx_tvalid;
	reg [7:0] tcp_rx_tdata;
	reg tcp_rx_tlast;
	reg icmp_rx_tvalid;
	reg [7:0] icmp_rx_tdata;
	reg icmp_rx_tlast;
	
	// State machine signals
	localparam WAIT_FOR_START_OF_FRAME			= 16'h0001;
	localparam CAPTURE_VERSION_LENGTH			= 16'h0002;
	localparam CAPTURE_DSCP_ECN					= 16'h0004;
	localparam CAPTURE_TOTAL_LENGTH				= 16'h0008;
	localparam CAPTURE_IDENTIFICATION			= 16'h0010;
	localparam CAPTURE_FRAGMENTATION			= 16'h0020;
	localparam CAPTURE_TTL						= 16'h0040;
	localparam CAPTURE_PROTOCOL					= 16'h0080;
	localparam CAPTURE_CHECKSUM					= 16'h0100;
	localparam CAPTURE_SOURCE_ADDRESS			= 16'h0200;
	localparam CAPTURE_DESTINATION_ADDRESS		= 16'h0400;
	localparam CALCULATE_CHECKSUM				= 16'h0800;
	localparam WAIT_FOR_CHECKSUM_DONE			= 16'h1000;
	localparam WAIT_FOR_END_OF_PAYLOAD			= 16'h2000;
	localparam ABORTED_PAYLOAD					= 16'h4000;
	
	reg [15:0] ip_receiver_state;
	reg enable_payload_buffer;	
	integer checksum_byte_counter;	
	reg start_of_frame;			
	reg end_of_frame;			
	reg enable_payload_transmit;	

	// Data capture signals
	reg [INPUT_BUFFER_SIZE-1:0] payload_buffer[7:0];
	reg [INPUT_BUFFER_SIZE-1:0] tlast_buffer;
	integer buffer_pointer;
	integer buffer_counter;
	
	// Checksum signals
	reg checksum_data_valid;
	reg [7:0] checksum_data;
	reg [15:0] checksum_expected;
	wire checksum_done;
	wire checksum_correct;
	wire [15:0] checksum_value;
	wire [15:0] checksum_input_array[9:0];
	reg [7:0] checksum_input_data[19:0];
	integer i;	
	
	// Output side signals
	reg end_of_payload;
	
	//---------- Input Side ----------//
	
	// State machine that keeps track of the fields in the datagram
	always @(posedge clock or reset) begin
		if (reset) begin
			ip_receiver_state	<= WAIT_FOR_START_OF_FRAME;
			eth_rx_tready		<= 1'b0;
			ip_version<= 0;
			ip_header_length<= 0;
			ip_dscp<= 0;
			ip_ecn<= 0;
			ip_total_length<= 0;
			ip_identification<= 0;
			ip_flags<= 0;
			ip_fragment_offset<= 0;
			ip_ttl<= 0;
			ip_protocol<= 0;
			ip_header_checksum<= 0;
			ip_source_address<= 0;
			ip_dest_address<= 0;
			enable_payload_buffer	<= 1'b0;
			checksum_byte_counter	<= 0;
			checksum_data_valid		<= 0;
			checksum_data			<= 0;
			start_of_frame			<= 0;
			end_of_frame			<= 0;
			enable_payload_transmit	<= 0;
			byte_counter			<= 0;
		end
		else begin
			start_of_frame			<= 0;
			end_of_frame			<= 0;
			
			case (ip_receiver_state)
				WAIT_FOR_START_OF_FRAME:
				begin
					eth_rx_tready		<= 1'b1;
					
					if (eth_rx_tvalid) begin
						byte_counter		<= 0;
						start_of_frame		<= 0;
						ip_receiver_state	<= CAPTURE_VERSION_LENGTH;
					end
				end
				CAPTURE_VERSION_LENGTH:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_version			<= eth_rx_tdata[7:4];
							ip_header_length	<= eth_rx_tdata[3:0];
							ip_receiver_state	<= CAPTURE_TOTAL_LENGTH;
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_DSCP_ECN:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_dscp				<= eth_rx_tdata[7:2];
							ip_ecn				<= eth_rx_tdata[1:0];
							ip_receiver_state	<= CAPTURE_TOTAL_LENGTH;
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_TOTAL_LENGTH:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_total_length		<= {ip_total_length[7:0], eth_rx_tdata};
							
							if (byte_counter == LENGTH_HIGH_BYTE) begin
								ip_receiver_state	<= CAPTURE_IDENTIFICATION;
							end
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_IDENTIFICATION:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_identification	<= {ip_identification[7:0], eth_rx_tdata};
							
							if (byte_counter == ID_HIGH_BYTE) begin
								ip_receiver_state	<= CAPTURE_FRAGMENTATION;
							end
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_FRAGMENTATION:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;

							if (byte_counter == FRAGMENT_LOW_BYTE) begin
								ip_fragment_offset	<= {3'b000, eth_rx_tdata[4:0]};
								ip_flags			<= eth_rx_tdata[7:5];
							end
							else if (byte_counter == FRAGMENT_HIGH_BYTE) begin
								ip_fragment_offset	<= {ip_fragment_offset[4:0], eth_rx_tdata};
								ip_receiver_state	<= CAPTURE_TTL;
							end
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_TTL:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_ttl				<= eth_rx_tdata;
							ip_receiver_state	<= CAPTURE_PROTOCOL;
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_PROTOCOL:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_protocol			<= eth_rx_tdata;
							ip_receiver_state	<= CAPTURE_CHECKSUM;
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_CHECKSUM:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_header_checksum	<= {ip_header_checksum[7:0], eth_rx_tdata};
							
							if (byte_counter == CHECKSUM_HIGH_BYTE) begin
								ip_receiver_state	<= CAPTURE_SOURCE_ADDRESS;
							end
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_SOURCE_ADDRESS:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_source_address	<= {ip_source_address[7:0], eth_rx_tdata};
							
							if (byte_counter == SOURCE_ADDRESS_BYTE3) begin
								ip_receiver_state	<= CAPTURE_DESTINATION_ADDRESS;
							end
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CAPTURE_DESTINATION_ADDRESS:
				begin
					if (eth_rx_tvalid) begin
						if (!eth_rx_tlast) begin
							byte_counter		<= byte_counter + 1;
							ip_dest_address	<= {ip_dest_address[7:0], eth_rx_tdata};
							
							if (byte_counter == DEST_ADDRESS_BYTE3) begin
								enable_payload_buffer	<= 1'b1;
								checksum_byte_counter	<= 0;
								ip_receiver_state		<= CALCULATE_CHECKSUM;
							end
						end
						else begin
							ip_receiver_state	<= ABORTED_PAYLOAD;
						end
					end
				end
				CALCULATE_CHECKSUM:
				begin
					if (eth_rx_tlast) begin
						enable_payload_buffer	<= 1'b0;
					end
					
					if (checksum_byte_counter < 20) begin
						checksum_data_valid		<= 1'b1;
						checksum_data			<= checksum_input_data[checksum_byte_counter];
						end_of_frame			<= 1'b0;
						checksum_byte_counter	<= checksum_byte_counter + 1;
					end
					else begin
						checksum_data_valid		<= 1'b0;
						checksum_data			<= 0;
						end_of_frame			<= 1'b1;
						ip_receiver_state		<= WAIT_FOR_CHECKSUM_DONE;
					end
				end
				WAIT_FOR_CHECKSUM_DONE:
				begin
					if (eth_rx_tlast || (checksum_done && !checksum_correct)) begin
						enable_payload_buffer	<= 1'b0;
					end
					
					if (checksum_done) begin
						if (checksum_correct) begin
							enable_payload_transmit	<= 1'b1;
							ip_receiver_state		<= WAIT_FOR_END_OF_PAYLOAD;
						end
						else begin
							enable_payload_transmit	<= 1'b0;
							ip_receiver_state		<= WAIT_FOR_START_OF_FRAME;	
						end
					end
				end
				WAIT_FOR_END_OF_PAYLOAD:
				begin
					if (end_of_payload) begin
						enable_payload_transmit	<= 1'b0;
						ip_receiver_state		<= WAIT_FOR_START_OF_FRAME;	
					end
					
					if (eth_rx_tlast) begin
						eth_rx_tready		<= 1'b0;
					end
				end
				ABORTED_PAYLOAD:
				begin
					ip_receiver_state	<= WAIT_FOR_START_OF_FRAME;
				end
				default: ip_receiver_state	<= WAIT_FOR_START_OF_FRAME;
			endcase
		end
	end

	always @(posedge clock) begin
		// Put the data into a buffer while waiting for the checksum
		if (enable_payload_buffer && eth_rx_tvalid) begin
			payload_buffer[0]	<= eth_rx_tdata;
			tlast_buffer[0]		<= eth_rx_tlast;
			
			for (i = 0; i < INPUT_BUFFER_SIZE; i = i + 1) begin
				payload_buffer[i]	<= payload_buffer[i-1];
				tlast_buffer[i]		<= tlast_buffer[i-1];
			end
			
			buffer_pointer		<= buffer_counter;	
			buffer_counter		<= buffer_counter + 1;
		end
		else if (start_of_frame) begin
			buffer_counter		<= 0;
		end
	end	
	
	// Parse out the header

	//---------- Checksum ----------//
	assign checksum_input_array[0] = {ip_version, ip_header_length, ip_dscp, ip_ecn};
	assign checksum_input_array[1] = ip_total_length;
	assign checksum_input_array[2] = ip_identification;
	assign checksum_input_array[3] = {ip_flags, ip_fragment_offset};
	assign checksum_input_array[4] = {ip_ttl, ip_protocol};
	assign checksum_input_array[5] = 0;
	assign checksum_input_array[6] = ip_source_address[31:16];
	assign checksum_input_array[7] = ip_source_address[15:0];
	assign checksum_input_array[8] = ip_dest_address[31:16];
	assign checksum_input_array[9] = ip_dest_address[15:0];

	always @(checksum_input_array) begin
		for (i = 0; i < 20; i = i + 2) begin
			checksum_input_data[i]		<= checksum_input_array[i/2][15:8];
			checksum_input_data[i+1]	<= checksum_input_array[i/2][7:0];
		end
	end
		
	checksum_16bit checksum_generator(clock, reset, checksum_data_valid, checksum_data, end_of_frame, ip_header_checksum, checksum_done, checksum_correct, checksum_value);

	//---------- Output Side ----------//
	
	always @(posedge clock) begin		
		// Forward the data to either the UDP, TCP or ICMP modules
		if (enable_payload_transmit) begin
			if (ip_protocol == UDP_PROTOCOL) begin
				if (udp_rx_tready) begin
					udp_rx_tvalid	<= 1'b1;
					udp_rx_tdata	<= payload_buffer[buffer_pointer];
					udp_rx_tlast	<= tlast_buffer[buffer_pointer];
				end
			end				   
			else begin
				udp_rx_tvalid	<= 1'b0;
				udp_rx_tdata	<= 8'h00;
				udp_rx_tlast	<= 1'b0;
			end
			
			if (ip_protocol == TCP_PROTOCOL) begin
				if (tcp_rx_tready) begin
					tcp_rx_tvalid	<= 1'b1;
					tcp_rx_tdata	<= payload_buffer[buffer_pointer];
					tcp_rx_tlast	<= tlast_buffer[buffer_pointer];
				end
			end
			else begin
				tcp_rx_tvalid	<= 1'b0;
				tcp_rx_tdata	<= 8'h00;
				tcp_rx_tlast	<= 1'b0;
			end
			
			if (ip_protocol == ICMP_PROTOCOL) begin
				if (icmp_rx_tready) begin
					icmp_rx_tvalid	<= 1'b1;
					icmp_rx_tdata	<= payload_buffer[buffer_pointer];
					icmp_rx_tlast	<= tlast_buffer[buffer_pointer];
				end
			end
			else begin
				icmp_rx_tvalid	<= 1'b0;
				icmp_rx_tdata	<= 8'h00;
				icmp_rx_tlast	<= 1'b0;
			end
		end
		
		end_of_payload	<= udp_rx_tlast | tcp_rx_tlast | icmp_rx_tlast;
	end		

	assign source_ip_address	= ip_source_address;
	assign dest_ip_address		= ip_dest_address;
endmodule