`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/global_parameters.vh"
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module ip_receiver (reset, clock, eth_rx_tready, eth_rx_tvalid, eth_rx_tdata, eth_rx_tkeep, eth_rx_tlast, udp_rx_tready, udp_rx_tvalid, udp_rx_tdata, udp_rx_tkeep, udp_rx_tlast, tcp_rx_tready, tcp_rx_tvalid, tcp_rx_tdata, tcp_rx_tkeep, tcp_rx_tlast, icmp_rx_tready, icmp_rx_tvalid, icmp_rx_tdata, icmp_rx_tkeep, icmp_rx_tlast, local_ip_address, source_ip_address, dest_ip_address);
	// Parameters
	parameter BITS_PER_BEAT		= 128;
	parameter PIPELINE_DEPTH 	= 16;
	
	localparam BYTES_PER_HEADER	= 20;
	localparam BITS_PER_HEADER= BYTES_PER_HEADER*8;
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam CHECKSUM_ARRAY_SIZE = `IP_HEADER_SIZE/`CHECKSUM_SIZE;

	input 	reset;
	input 	clock;
	output 	eth_rx_tready;
	input 	eth_rx_tvalid;
	input 	[BITS_PER_BEAT-1:0] eth_rx_tdata;
	input	[BYTES_PER_BEAT-1:0] eth_rx_tkeep;
	input 	eth_rx_tlast;
	input	udp_rx_tready;
	output reg	udp_rx_tvalid;
	output reg 	[BITS_PER_BEAT-1:0] udp_rx_tdata;
	output reg	[BYTES_PER_BEAT-1:0] udp_rx_tkeep;
	output reg 	udp_rx_tlast;
	input	tcp_rx_tready;
	output reg 	tcp_rx_tvalid;
	output reg 	[BITS_PER_BEAT-1:0] tcp_rx_tdata;
	output reg	[BYTES_PER_BEAT-1:0] tcp_rx_tkeep;
	output reg 	tcp_rx_tlast;
	input	icmp_rx_tready;
	output reg 	icmp_rx_tvalid;
	output reg 	[BITS_PER_BEAT-1:0] icmp_rx_tdata;
	output reg	[BYTES_PER_BEAT-1:0] icmp_rx_tkeep;
	output reg 	icmp_rx_tlast;
	input	[31:0] local_ip_address;
	output 	[31:0] source_ip_address;
	output 	[31:0] dest_ip_address;
	
	reg [3:0]  ip_version;				
	reg [3:0]  ip_length;				
	reg [5:0]  ip_dscp;					
	reg [1:0]  ip_ecn;					
	reg [15:0] ip_total_length;			
	reg [15:0] ip_identification;		
	reg [2:0]  ip_flags;				
	reg [12:0] ip_offset;				
	reg [7:0]  ip_ttl;					
	reg [7:0]  ip_protocol;				
	reg [15:0] ip_checksum;				
	reg [31:0] ip_source_address;		
	reg [31:0] ip_destination_address;
	
	reg capture_tready;
	wire capture_tvalid;
	wire [BITS_PER_BEAT-1:0] capture_tdata;
	wire capture_tlast;
	wire [BYTES_PER_BEAT-1:0] capture_tkeep;
	wire [BITS_PER_HEADER-1:0] header_data;
	wire header_data_valid;

	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] WAIT_FOR_DATA_CAPTURED = 8'h02;
	localparam [7:0] VERIFY_CHECKSUM = 8'h04;
	localparam [7:0] WAIT_FOR_CHECKSUM_DONE = 8'h08;
	localparam [7:0] SELECT_OUTPUT_PATH = 8'h10;
	localparam [7:0] WAIT_FOR_PAYLOAD_DATA = 8'h20;
	localparam [7:0] WAIT_FOR_PENDING_CLEAR = 8'h40;
	localparam [7:0] CLEAR_DATAGRAM = 8'h80;
	
	reg [7:0] ip_rx_state;				
	reg latch_header_data;		
	reg [`IP_HEADER_SIZE-1:0] current_header_data;
	reg clear_header_captured;
	reg enable_udp_interface;	
	reg enable_icmp_interface;	
	reg enable_tcp_interface;	
	reg checksum_data_valid;		
	reg [`CHECKSUM_SIZE-1:0] checksum_data;			
	reg end_of_frame;			
	reg [`CHECKSUM_SIZE-1:0] checksum_expected;		
	integer checksum_counter;
	reg clear_tlast_pending;
	reg capture_tlast_pending;
	reg [`CHECKSUM_SIZE-1:0] checksum_data_array[CHECKSUM_ARRAY_SIZE-1:0];
	reg invalid_datagram;
	reg header_captured;
	
	integer i;
	
	byte_swap #(.WIDTH(32))	src_ip (.data_in(ip_source_address), .data_out(source_ip_address));	
	byte_swap #(.WIDTH(32))	dest_ip (.data_in(ip_destination_address), .data_out(dest_ip_address));	

	header_capture #(BITS_PER_BEAT, BITS_PER_HEADER, PIPELINE_DEPTH) ipv4_rx (.clock(clock), .reset(reset), .tready_out(eth_rx_tready), .tvalid_in(eth_rx_tvalid), .tdata_in(eth_rx_tdata), .tlast_in(eth_rx_tlast), .tkeep_in(eth_rx_tkeep), .tready_in(capture_tready), .tvalid_out(capture_tvalid), .tdata_out(capture_tdata), .tlast_out(capture_tlast), .tkeep_out(capture_tkeep), .header_data(header_data), .header_data_valid(header_data_valid));
	checksum_16bit (clock, reset, checksum_data_valid, checksum_data, end_of_frame, checksum_expected, checksum_done, checksum_correct, checksum_value);
	
	// Wait for the header capture module to remove the header and then decide where to send the payload
	always @(posedge clock or reset) begin
		if (reset) begin
			ip_rx_state				<= IDLE;
			latch_header_data		<= 1'b0;
			current_header_data		<= 0;
			clear_header_captured	<= 1'b0;
			enable_udp_interface	<= 1'b0;
			enable_icmp_interface	<= 1'b0;
			enable_tcp_interface	<= 1'b0;
			checksum_data_valid		<= 1'b0;
			checksum_data			<= 0;
			end_of_frame			<= 1'b0;
			checksum_expected		<= 0;
			checksum_counter		<= 0;
			enable_udp_interface	<= 1'b0;
			enable_icmp_interface	<= 1'b0;
			enable_tcp_interface	<= 1'b0;
			clear_tlast_pending		<= 1'b0;
			invalid_datagram		<= 1'b0;
		end
		else begin
			latch_header_data		<= 1'b0;
			
			case (ip_rx_state)
				IDLE:
				begin
					enable_udp_interface	<= 1'b0;
					enable_icmp_interface	<= 1'b0;
					enable_tcp_interface	<= 1'b0;
					invalid_datagram		<= 1'b0;

					if (header_data_valid) begin
						latch_header_data	<= 1'b1;
						current_header_data	<= header_data;
						ip_rx_state			<= WAIT_FOR_DATA_CAPTURED;
					end
				end
				WAIT_FOR_DATA_CAPTURED:
				begin
					if (header_captured) begin
						clear_header_captured	<= 1'b1;	
						checksum_counter		<= 0;
						ip_rx_state				<= VERIFY_CHECKSUM;
					end
				end
				VERIFY_CHECKSUM:
				begin
					clear_header_captured	<= 1'b0;
					
					if (checksum_counter < CHECKSUM_ARRAY_SIZE-2) begin
						checksum_data_valid		<= 1'b1;
						checksum_data			<= checksum_data_array[checksum_counter];
						end_of_frame			<= 1'b0;
						checksum_counter		<= checksum_counter + 1;
					end
					else if (checksum_counter < CHECKSUM_ARRAY_SIZE-1) begin
						checksum_data_valid		<= 1'b1;
						checksum_data			<= checksum_data_array[checksum_counter];
						end_of_frame			<= 1'b1;
						checksum_counter		<= checksum_counter + 1;
					end
					else begin
						checksum_data_valid		<= 1'b0;
						checksum_data			<= 0;
						end_of_frame			<= 1'b0;
						ip_rx_state				<= WAIT_FOR_CHECKSUM_DONE;
					end
				end
				WAIT_FOR_CHECKSUM_DONE:
				begin
					if (checksum_done) begin
						if ((checksum_correct) && (ip_destination_address == local_ip_address)) begin
							ip_rx_state				<= SELECT_OUTPUT_PATH;
						end
						else begin
							invalid_datagram		<= 1'b1;
							ip_rx_state				<= CLEAR_DATAGRAM;
						end
					end
				end
				SELECT_OUTPUT_PATH:
				begin
					if (ip_protocol == `UDP_PROTOCOL) begin
						enable_udp_interface	<= 1'b1;
						ip_rx_state				<= WAIT_FOR_PAYLOAD_DATA;
					end
					else if (ip_protocol == `ICMP_PROTOCOL) begin
						enable_icmp_interface	<= 1'b1;
						ip_rx_state				<= WAIT_FOR_PAYLOAD_DATA;
					end
					else if (ip_protocol == `TCP_PROTOCOL) begin
						enable_tcp_interface	<= 1'b1;
						ip_rx_state				<= WAIT_FOR_PAYLOAD_DATA;
					end
					else begin
						invalid_datagram		<= 1'b1;
						ip_rx_state				<= CLEAR_DATAGRAM;
					end
				end
				WAIT_FOR_PAYLOAD_DATA:
				begin
					if (capture_tlast_pending) begin
						clear_tlast_pending		<= 1'b1;
						ip_rx_state				<= WAIT_FOR_PENDING_CLEAR;
					end
				end
				WAIT_FOR_PENDING_CLEAR:
				begin
					if (!capture_tlast_pending) begin
						clear_tlast_pending		<= 1'b0;
						ip_rx_state				<= IDLE;
					end
				end
				CLEAR_DATAGRAM:
				begin
					if (capture_tlast_pending) begin
						clear_tlast_pending		<= 1'b1;
						ip_rx_state				<= WAIT_FOR_PENDING_CLEAR;
					end
				end
				default: ip_rx_state			<= IDLE;
			endcase
		end
	end

	always @(posedge clock) begin
		if (latch_header_data) begin
			ip_version				<= current_header_data[3:0];
			ip_length				<= current_header_data[7:4];
			ip_dscp					<= current_header_data[13:8];
			ip_ecn					<= current_header_data[15:14];
			ip_total_length			<= current_header_data[31:16];
			ip_identification		<= current_header_data[47:32];
			ip_flags				<= current_header_data[50:48];
			ip_offset				<= current_header_data[63:51];
			ip_ttl					<= current_header_data[71:64];
			ip_protocol				<= current_header_data[79:72];
			ip_checksum				<= current_header_data[95:80];
			ip_source_address		<= current_header_data[127:96];
			ip_destination_address	<= current_header_data[159:128];
	
			for (i = 0; i < 5; i = i + 1) begin
				checksum_data_array[i]	<= current_header_data[(i*`CHECKSUM_SIZE+`CHECKSUM_SIZE-1)-:`CHECKSUM_SIZE];
			end
			
			checksum_data_array[5]	<= 0;
			
			for (i = 6; i < CHECKSUM_ARRAY_SIZE; i = i + 1) begin
				checksum_data_array[i]	<= current_header_data[(i*`CHECKSUM_SIZE+`CHECKSUM_SIZE-1)-:`CHECKSUM_SIZE];
			end
		end	
	
		if (latch_header_data) begin
			header_captured	<= 1'b1;
		end
		else if (clear_header_captured) begin
			header_captured	<= 1'b0;
		end
		
		if (capture_tlast) begin
			capture_tlast_pending	<= 1'b1;
		end
		else if (clear_tlast_pending) begin
			capture_tlast_pending	<= 1'b0;
		end
	end
	
	always @(enable_udp_interface, enable_icmp_interface, enable_tcp_interface, udp_rx_tready, icmp_rx_tready, tcp_rx_tready, capture_tvalid, capture_tdata, capture_tkeep, capture_tlast)
	begin
		if (enable_udp_interface) begin
			capture_tready			<= udp_rx_tready;
			udp_rx_tvalid			<= capture_tvalid;
			udp_rx_tdata			<= capture_tdata;
			udp_rx_tkeep			<= capture_tkeep;
			udp_rx_tlast			<= capture_tlast;
		end
		else if (enable_icmp_interface) begin
			capture_tready			<= icmp_rx_tready;
			icmp_rx_tvalid			<= capture_tvalid;
			icmp_rx_tdata			<= capture_tdata;
			icmp_rx_tkeep			<= capture_tkeep;
			icmp_rx_tlast			<= capture_tlast;
		end
		else if (enable_tcp_interface) begin
			capture_tready			<= tcp_rx_tready;
			tcp_rx_tvalid			<= capture_tvalid;
			tcp_rx_tdata			<= capture_tdata;
			tcp_rx_tkeep			<= capture_tkeep;
			tcp_rx_tlast			<= capture_tlast;
		end
		else if (invalid_datagram) begin
			capture_tready			<= 1'b1;
		end
		else begin
			capture_tready			<= 1'b0;
			udp_rx_tvalid			<= 1'b0;
			udp_rx_tdata			<= 0;
			udp_rx_tkeep			<= 0;
			udp_rx_tlast			<= 1'b0;
			icmp_rx_tvalid			<= 1'b0;
			icmp_rx_tdata			<= 0;
			icmp_rx_tkeep			<= 0;
			icmp_rx_tlast			<= 1'b0;
			tcp_rx_tvalid			<= 1'b0;
			tcp_rx_tdata			<= 0;
			tcp_rx_tkeep			<= 0;
			tcp_rx_tlast			<= 1'b0;
		end
	end
endmodule