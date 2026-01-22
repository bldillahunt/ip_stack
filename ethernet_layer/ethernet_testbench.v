`timescale 1ns/1ps
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module ethernet_testbench;
	localparam TOTAL_BYTE_COUNT = 1024;
	localparam HEADER_SIZE = 112;
	localparam BITS_PER_BEAT = 64;
	localparam PIPELINE_DEPTH = 32;
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BROADCAST_MAC_ADDRESS = 48'hFFFFFFFFFFFF;
	localparam SOURCE_MAC_ADDRESS = 48'h112233445566;
	localparam DESTINATION_MAC_ADDRESS = 48'hF071AD9025B4;
	localparam ETHER_TYPE = 16'h0800;
	localparam HEADER_BYTE_COUNT = 14;
	localparam INTERPACKET_GAP_TIME = 12;

	localparam TOTAL_BIT_COUNT = TOTAL_BYTE_COUNT*8;
	localparam BYTES_PER_HEADER = HEADER_SIZE/8;
	localparam BEATS_PER_BURST = TOTAL_BIT_COUNT/BITS_PER_BEAT + HEADER_SIZE/BITS_PER_BEAT;
	localparam BLANK_BYTES = 12;
	localparam PACKET_BYTE_COUNT = TOTAL_BYTE_COUNT;
	localparam [47:0] SRC_MAC_ADDRESS = SOURCE_MAC_ADDRESS;
	localparam [47:0] DEST_MAC_ADDRESS = DESTINATION_MAC_ADDRESS;
	localparam [15:0] ETH_TYPE = 16'h0800;
	localparam PRBS_SIZE = 32;
	localparam PRBS_LEFT_OVER = ((BITS_PER_BEAT - HEADER_SIZE) % 32);
	localparam TKEEP_LEFT_OVER = BYTES_PER_BEAT - BYTES_PER_HEADER;
	
	localparam real header_size_real = HEADER_SIZE;
	localparam real bits_per_beat_real = BITS_PER_BEAT;
	localparam real header_leftover_real = $ceil(header_size_real/bits_per_beat_real) * bits_per_beat_real - header_size_real;
	localparam real header_leftover_real_bytes = header_leftover_real/8;
	
	localparam integer header_leftover_int = header_leftover_real;
	localparam integer header_leftover_int_bytes = header_leftover_real_bytes;
	
	localparam real bytes_per_header_real = BYTES_PER_HEADER;
	localparam real bytes_per_beat_real = BYTES_PER_BEAT;
	localparam real header_beat_count_floor_real = $floor(bytes_per_header_real/bytes_per_beat_real)*bytes_per_beat_real;
	localparam real header_beat_count_ceil_real = $ceil(bytes_per_header_real/bytes_per_beat_real)*bytes_per_beat_real;
	localparam integer header_beat_count_floor_int = header_beat_count_floor_real;
	localparam integer header_beat_count_ceil_int = header_beat_count_ceil_real;
	
	reg clock;
	reg reset;

	reg tvalid_in;
	reg [BITS_PER_BEAT-1:0] tdata_in;
	reg tlast_in;
	reg [BITS_PER_BEAT/8-1:0] tkeep_in;
	reg tready_tx_in;
	wire tready_out;
	assign tready_out = 1'b1;

	integer beat_counter;
	reg [PRBS_SIZE-1:0] prbs_register;
	reg [PRBS_SIZE-1:0] prbs_verifier;
	reg data_valid;
	
	localparam IDLE = 8'b00000001;
	localparam SETUP_DATA_STREAM = 8'b00000010;
	localparam FINISH_HEADER = 8'b00000100;
	localparam WAIT_FOR_READY = 8'b00001000;
	localparam END_OF_BUS_TRANSACTION = 8'b00010000;
	localparam CHECK_HEADER_CAPTURE_OUTPUT = 8'b00100000;
	
	reg [7:0] header_capture_state;
	integer i;
	reg [BITS_PER_BEAT-1:0] tdata_shift_register;
	integer packet_byte_counter;
	integer header_byte_counter;
	reg [HEADER_SIZE-1:0] header_shift_register;
	wire [47:0] temac_address;
	wire [HEADER_SIZE-1:0] header_data_112bit;
	assign temac_address = DEST_MAC_ADDRESS;
	localparam WAIT_FOR_DATA = 4'h1;
	localparam REMOVE_HEADER_DATA = 4'h2;
	localparam VERIFY_REMAINING_DATA = 4'h4;
	
	reg [3:0] verification_state;
	
	// IP emulation section

	reg mac_rx_tvalid;
	reg [BITS_PER_BEAT-1:0] mac_rx_tdata;
	reg [BYTES_PER_BEAT-1:0] mac_rx_tkeep;
	reg mac_rx_tlast;
	reg [0:0] mac_rx_tuser;
	reg mac_rx_filter_tuser;
	wire ip_rx_tready;
	wire ip_rx_tvalid;
	wire [BITS_PER_BEAT-1:0] ip_rx_tdata;
	wire [BYTES_PER_BEAT-1:0] ip_rx_tkeep;
	wire ip_rx_tlast;
	wire arp_rx_tready;
	wire arp_rx_tvalid;
	wire [BITS_PER_BEAT-1:0] arp_rx_tdata;
	wire [BYTES_PER_BEAT-1:0] arp_rx_tkeep;
	wire arp_rx_tlast;
	wire [47:0] received_mac_address;
	wire valid_mac_address;
	reg mac_tx_tready;
	wire mac_tx_tvalid;
	wire [BITS_PER_BEAT-1:0] mac_tx_tdata;
	wire [BYTES_PER_BEAT-1:0] mac_tx_tkeep;
	wire mac_tx_tlast;
	wire [0:0] mac_tx_tuser;
	wire mac_tx_filter_tuser;
	
	wire tvalid_out;
	wire [BITS_PER_BEAT-1:0] tdata_out;
	wire tlast_out;
	wire [BITS_PER_BEAT/8-1:0] tkeep_out;
	wire [HEADER_SIZE-1:0] header_data;
	
	wire [47:0] source_mac_address;
	wire [47:0] destination_mac_address;
	wire [15:0] ethernet_type;
	wire [HEADER_SIZE-1:0] datagram_header;
	wire tvalid_tx_out;
	wire [BITS_PER_BEAT-1:0] tdata_tx_out;
	wire tlast_tx_out;
	wire [BYTES_PER_BEAT-1:0] tkeep_tx_out;

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

	// Create an array of 32 bit PRBS data
	function [BITS_PER_BEAT-1:0] prbs_beat_array;
		input [31:0] previous_prbs_input;
		integer i;
		reg [BITS_PER_BEAT-1:0] shift_register;
		reg [31:0] current_prbs_data;
		
		begin
			shift_register[(BITS_PER_BEAT-1)-:32] = prbs_pattern_generator(1'b1, previous_prbs_input);
			current_prbs_data = shift_register[(BITS_PER_BEAT-1)-:32];
			
			for (i = 0; i < (BITS_PER_BEAT/32)-1; i = i + 1) begin
				shift_register	= shift_register >> 32;
				shift_register[(BITS_PER_BEAT-1)-:32] = prbs_pattern_generator(1'b1, current_prbs_data);
				current_prbs_data = shift_register[(BITS_PER_BEAT-1)-:32];
			end
			
			prbs_beat_array = shift_register;
		end
	endfunction
	
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
	
	ethernet_receiver #(BITS_PER_BEAT, PIPELINE_DEPTH) dut_rx (.reset(reset), .clock(clock), .temac_rx_tvalid(tvalid_in), .temac_rx_tdata(tdata_in), .temac_rx_tkeep(tkeep_in), .temac_rx_tlast(tlast_in), .temac_rx_tuser(mac_rx_tuser), .temac_rx_filter_tuser(mac_rx_filter_tuser), .ip_rx_tready(ip_rx_tready), .ip_rx_tvalid(ip_rx_tvalid), .ip_rx_tdata(ip_rx_tdata), .ip_rx_tkeep(ip_rx_tkeep), .ip_rx_tlast(ip_rx_tlast), .arp_rx_tready(arp_rx_tready), .arp_rx_tvalid(arp_rx_tvalid), .arp_rx_tdata(arp_rx_tdata), .arp_rx_tkeep(arp_rx_tkeep), .arp_rx_tlast(arp_rx_tlast), .temac_address(temac_address), .received_mac_address(received_mac_address), .valid_mac_address(valid_mac_address));
	ethernet_transmitter #(BITS_PER_BEAT, PIPELINE_DEPTH) dut_tx (.reset(reset), .clock(clock), .source_mac_address(DESTINATION_MAC_ADDRESS), .destination_mac_address(SOURCE_MAC_ADDRESS), .ip_tx_tready(ip_rx_tready), .ip_tx_tvalid(ip_rx_tvalid), .ip_tx_tdata(ip_rx_tdata), .ip_tx_tkeep(ip_rx_tkeep), .ip_tx_tlast(ip_rx_tlast), .arp_tx_tready(arp_rx_tready), .arp_tx_tvalid(arp_rx_tvalid), .arp_tx_tdata(arp_rx_tdata), .arp_tx_tkeep(arp_rx_tkeep), .arp_tx_tlast(arp_rx_tlast), .temac_tx_tready(tready_tx_in), .temac_tx_tvalid(tvalid_tx_out), .temac_tx_tdata(tdata_tx_out), .temac_tx_tkeep(tkeep_tx_out), .temac_tx_tlast(tlast_tx_out), .temac_tx_tuser(mac_tx_tuser), .temac_tx_filter_tuser(mac_tx_filter_tuser));	
	
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

	byte_swap #(.WIDTH(48))	src_mac (.data_in(SRC_MAC_ADDRESS),	.data_out(source_mac_address));	
	byte_swap #(.WIDTH(48))	dest_mac (.data_in(DEST_MAC_ADDRESS), .data_out(destination_mac_address));	
	byte_swap #(.WIDTH(16))	type_len (.data_in(ETH_TYPE), .data_out(ethernet_type));	

	assign header_data_112bit = {ethernet_type, destination_mac_address, source_mac_address};
	assign datagram_header = header_data_112bit;		

	generate
		if (BITS_PER_BEAT == HEADER_SIZE) begin : same_size
			reg [HEADER_SIZE-1:0] tdata_leftover;
			reg [BYTES_PER_BEAT-1:0] tkeep_leftover;
			reg [TOTAL_BIT_COUNT-1:0] verifier_shift_register;
		
			// Send random data
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= IDLE;
					tvalid_in				<= 1'b0;
					tdata_in				<= 0;
					tlast_in				<= 1'b0;
					tkeep_in				<= 0;
					tready_tx_in			<= 1'b0;
					prbs_register			<= 32'hFFFFFFFF;
					beat_counter			<= 0;
					data_valid				<= 1'b0;
				end
				else begin
					tready_tx_in			<= 1'b1;
					
					case (header_capture_state)
						IDLE: 
						begin
							header_capture_state	<= SETUP_DATA_STREAM;
						end
						SETUP_DATA_STREAM:
						begin
							tvalid_in			<= 1'b1;
							tdata_in			<= datagram_header;
							tlast_in			<= 1'b0;
							tkeep_in			<= 0;

							if (tready_out) begin	// Already captured the header
								beat_counter	<= beat_counter + 1;
								tdata_in		= prbs_beat_array(prbs_register);
								prbs_register	= tdata_in[(BITS_PER_BEAT-1)-:PRBS_SIZE];
							end
							else begin
								beat_counter		<= 0;
		//						prbs_register		<= 32'hFFFFFFFF;
							end

							header_capture_state	<= WAIT_FOR_READY;
						end
						WAIT_FOR_READY:
						begin
							if (tready_out) begin
								if (beat_counter < BEATS_PER_BURST-2) begin
									tdata_in			= prbs_beat_array(prbs_register);
									prbs_register		= tdata_in[(BITS_PER_BEAT-1)-:PRBS_SIZE];
									tvalid_in			<= 1'b1;
									tlast_in			<= 1'b0;
									tkeep_in			<= 32'hFFFFFFFF;
									beat_counter		<= beat_counter + 1;
								end
								else if (beat_counter < BEATS_PER_BURST-1) begin
									tdata_in			= prbs_beat_array(prbs_register);
									prbs_register		= tdata_in[(BITS_PER_BEAT-1)-:PRBS_SIZE];
									tvalid_in			<= 1'b1;
									tlast_in			<= 1'b1;
									tkeep_in			<= 32'hFFFFFFFF;
									beat_counter		<= beat_counter + 1;
									header_capture_state<= END_OF_BUS_TRANSACTION;
								end
							end
						end
						END_OF_BUS_TRANSACTION:
						begin
							tdata_in			<= 0;
							tvalid_in			<= 1'b0;
							tlast_in			<= 1'b0;
							tkeep_in			<= 0;

							// Enable data out now to check the operation of the FIFO
							header_capture_state<= CHECK_HEADER_CAPTURE_OUTPUT;
						end
						CHECK_HEADER_CAPTURE_OUTPUT:
						begin
							if ((ip_rx_tready && ip_rx_tvalid && ip_rx_tlast) || (arp_rx_tready && arp_rx_tvalid && arp_rx_tlast)) begin
								header_capture_state	<= SETUP_DATA_STREAM;
							end
						end
						default : header_capture_state	<= SETUP_DATA_STREAM;
					endcase
				end
			end

			always @(posedge clock or reset) begin
				if (reset) begin
					verification_state		<= WAIT_FOR_DATA;
					prbs_verifier			= {PRBS_SIZE{1'b1}};
					data_valid				<= 1'b0;
					verifier_shift_register	= 0;
					tready_tx_in			<= 1'b0;
				end
				else begin
					case (verification_state)
						WAIT_FOR_DATA:
						begin
							if (tvalid_tx_out) begin
								tready_tx_in			<= 1'b1;
								verifier_shift_register	= prbs_data_array(prbs_verifier);
								prbs_verifier			= verifier_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
								verification_state		<= REMOVE_HEADER_DATA;
							end
							else begin
								tready_tx_in			<= 1'b0;
							end
						end
						REMOVE_HEADER_DATA:
						begin
							tready_tx_in			<= 1'b1;
							
							if (tvalid_tx_out) begin
								verification_state		<= VERIFY_REMAINING_DATA;
							end
						end
						VERIFY_REMAINING_DATA:
						begin
							if (tvalid_tx_out) begin
								if (tdata_tx_out == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
									data_valid		<= 1'b1;
								end
								else begin
									data_valid		<= 1'b0;
								end
								
								verifier_shift_register	<= verifier_shift_register >> BITS_PER_BEAT;
								
								if (tlast_tx_out) begin
									tready_tx_in			<= 1'b0;
									verification_state		<= WAIT_FOR_DATA;
								end
								else begin
									tready_tx_in			<= 1'b1;
								end
							end
						end
						default:	verification_state		<= IDLE;
					endcase
				end
			end
		end
		else if (BITS_PER_BEAT > HEADER_SIZE) begin : large_beat_size
			reg [HEADER_SIZE-1:0] tdata_leftover;
			reg [BYTES_PER_BEAT-1:0] tkeep_leftover;
			reg [BYTES_PER_BEAT-1:0] tkeep_shift_register;
			reg [TOTAL_BIT_COUNT-1:0] verifier_shift_register;
		
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= IDLE;
					tvalid_in				<= 1'b0;
					tdata_in				<= 0;
					tlast_in				<= 1'b0;
					tkeep_in				<= 0;
//					tready_tx_in			<= 1'b0;
					prbs_register			<= 32'hFFFFFFFF;
					beat_counter			<= 0;
					data_valid				<= 1'b0;
					tdata_shift_register	= 0;
					tkeep_shift_register	<= 0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
					packet_byte_counter		<= 0;
				end
				else begin
//					tready_tx_in			<= 1'b1;
					
					case (header_capture_state)
						IDLE: 
						begin
							header_capture_state	<= SETUP_DATA_STREAM;
						end
						SETUP_DATA_STREAM:
						begin
							tdata_shift_register		= prbs_beat_array(prbs_register);
							prbs_register				= tdata_shift_register[BITS_PER_BEAT-1-:32];
							tdata_in[HEADER_SIZE-1:0]	<= datagram_header;
							tdata_in[BITS_PER_BEAT-1:HEADER_SIZE]	<= tdata_shift_register[BITS_PER_BEAT-HEADER_SIZE-1:0];
							tkeep_shift_register[BYTES_PER_HEADER-1:0]	= {BYTES_PER_HEADER{8'hFF}};
							tkeep_shift_register[BYTES_PER_BEAT-1:BYTES_PER_HEADER] = {TKEEP_LEFT_OVER{8'hFF}};
							tdata_leftover				<= tdata_shift_register[BITS_PER_BEAT-1:BITS_PER_BEAT-HEADER_SIZE];
							tkeep_leftover				<= {{TKEEP_LEFT_OVER{8'h00}}, {BYTES_PER_HEADER{8'hFF}}};
							
							tvalid_in					<= 1'b1;
							tlast_in					<= 1'b0;
							tkeep_in					<= {BYTES_PER_BEAT{8'hFF}};
							packet_byte_counter			<= BYTES_PER_BEAT - BYTES_PER_HEADER;
							header_capture_state		<= WAIT_FOR_READY;
						end
						WAIT_FOR_READY:
						begin
							if (tready_out) begin
//								tdata_shift_register		= tdata_shift_register >> (BITS_PER_BEAT-HEADER_SIZE);
								packet_byte_counter			<= packet_byte_counter + BYTES_PER_BEAT;
								
//								if (beat_counter < BEATS_PER_BURST-2) begin
								if (packet_byte_counter < (PACKET_BYTE_COUNT-BYTES_PER_BEAT)) begin
									tdata_shift_register= prbs_beat_array(prbs_register);
									prbs_register		= tdata_shift_register[BITS_PER_BEAT-1-:32];
									tdata_in[HEADER_SIZE-1:0]	<= tdata_leftover;
									tdata_in[BITS_PER_BEAT-1:HEADER_SIZE]	<= tdata_shift_register[(BITS_PER_BEAT-HEADER_SIZE)-1:0];
									tvalid_in			<= 1'b1;
									tlast_in			<= 1'b0;
									tkeep_in			<= {BYTES_PER_BEAT{1'b1}};
									tdata_leftover		<= tdata_shift_register[BITS_PER_BEAT-1:BITS_PER_BEAT-HEADER_SIZE];
									beat_counter		<= beat_counter + 1;
								end 
								else begin
//								else if (beat_counter < BEATS_PER_BURST-1) begin
									tdata_in[HEADER_SIZE-1:0]	<= tdata_leftover;
									tdata_in[BITS_PER_BEAT-1:HEADER_SIZE]	<= {TKEEP_LEFT_OVER{8'h00}};
									tvalid_in			<= 1'b1;
									tlast_in			<= 1'b1;
									tkeep_in			<= {{TKEEP_LEFT_OVER{1'b0}}, {BYTES_PER_HEADER{1'b1}}};
									beat_counter		<= beat_counter + 1;
									header_capture_state<= END_OF_BUS_TRANSACTION;
								end
							end
						end
						END_OF_BUS_TRANSACTION:
						begin
							tdata_in			<= 0;
							tvalid_in			<= 1'b0;
							tlast_in			<= 1'b0;
							tkeep_in			<= 0;

							// Enable data out now to check the operation of the FIFO
							header_capture_state	<= CHECK_HEADER_CAPTURE_OUTPUT;
						end
						CHECK_HEADER_CAPTURE_OUTPUT:
						begin
							if ((ip_rx_tready && ip_rx_tvalid && ip_rx_tlast) || (arp_rx_tready && arp_rx_tvalid && arp_rx_tlast)) begin
								beat_counter			<= 0;
								header_capture_state	<= SETUP_DATA_STREAM;
							end
						end
						default : header_capture_state	<= SETUP_DATA_STREAM;
					endcase
				end
			end
			
			reg [BITS_PER_BEAT-HEADER_SIZE-1:0] verification_data_leftover;
			reg [(BITS_PER_BEAT-HEADER_SIZE)/8-1:0] verification_keep_leftover;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					verification_state		<= WAIT_FOR_DATA;
					prbs_verifier			= {PRBS_SIZE{1'b1}};
					data_valid				<= 1'b0;
					verifier_shift_register	= 0;
					tready_tx_in			<= 1'b0;
					verification_data_leftover	<= 0;
					verification_keep_leftover	<= 0;
				end
				else begin
					case (verification_state)
						WAIT_FOR_DATA:
						begin
							if (tvalid_tx_out) begin
								tready_tx_in			<= 1'b1;
								verifier_shift_register	= prbs_data_array(prbs_verifier);
								prbs_verifier			= verifier_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
								verification_state		<= REMOVE_HEADER_DATA;
							end
							else begin
								tready_tx_in			<= 1'b0;
							end
						end
						REMOVE_HEADER_DATA:
						begin
							tready_tx_in			<= 1'b1;
							
							if (tvalid_tx_out) begin
								verification_data_leftover<= tdata_tx_out[(BITS_PER_BEAT-1)-:BITS_PER_BEAT-HEADER_SIZE];
								verification_keep_leftover<= tkeep_tx_out[(BYTES_PER_BEAT-1)-:BYTES_PER_BEAT-BYTES_PER_HEADER];
								verification_state		<= VERIFY_REMAINING_DATA;
							end
						end
						VERIFY_REMAINING_DATA:
						begin
							if (tvalid_tx_out) begin
								verification_data_leftover		<= tdata_tx_out[(BITS_PER_BEAT-1)-:BITS_PER_BEAT-HEADER_SIZE];
								verification_keep_leftover		<= tkeep_tx_out[(BYTES_PER_BEAT-1)-:BYTES_PER_BEAT-BYTES_PER_HEADER];
								
								if ({tdata_tx_out[HEADER_SIZE-1:0], verification_data_leftover} == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
									data_valid		<= 1'b1;
								end
								else begin
									data_valid		<= 1'b0;
								end
								
								verifier_shift_register	<= verifier_shift_register >> BITS_PER_BEAT;
								if (tlast_tx_out) begin
									tready_tx_in			<= 1'b0;
									verification_state		<= WAIT_FOR_DATA;
								end
								else begin
									tready_tx_in			<= 1'b1;
								end
							end
						end
						default:	verification_state		<= IDLE;
					endcase
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) != 0) begin : medium_data_size_uneven
			reg [PRBS_SIZE-header_leftover_int-1:0] tdata_leftover;
			reg [BYTES_PER_BEAT-1:0] tkeep_leftover;
			reg [TOTAL_BIT_COUNT-1:0] prbs_shift_register;
			reg [TOTAL_BIT_COUNT/8-1:0] tkeep_shift_register;
			reg [TOTAL_BIT_COUNT-1:0] verifier_shift_register;
			reg [header_leftover_int-1:0] leftover_prbs_data;
			integer byte_counter;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= IDLE;
					tvalid_in				<= 1'b0;
					tdata_in				<= 0;
					tlast_in				<= 1'b0;
					tkeep_in				<= 0;
					prbs_register			<= 32'hFFFFFFFF;
					beat_counter			<= 0;
					data_valid				<= 1'b0;
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
					header_shift_register	<= 0;
					packet_byte_counter		<= 0;
					header_byte_counter		<= 0;
					prbs_shift_register		<= 0;
					tkeep_shift_register	<= 0;
				end
				else begin
					
					case (header_capture_state)
						IDLE: 
						begin
							header_capture_state	<= SETUP_DATA_STREAM;
						end
						SETUP_DATA_STREAM:
						begin
							prbs_shift_register		= prbs_data_array(prbs_register);
							prbs_register			= prbs_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
							tkeep_shift_register	<= {(PACKET_BYTE_COUNT){1'b1}};
							tdata_in				<= datagram_header[BITS_PER_BEAT-1:0];
							tvalid_in				<= 1'b1;
							tlast_in				<= 1'b0;
							tkeep_in				<= {BYTES_PER_BEAT{1'b1}};
							tdata_leftover			<= 0;
							tkeep_leftover			<= 0;
							header_byte_counter		<= header_byte_counter + BYTES_PER_BEAT;
							header_shift_register	<= datagram_header >> BITS_PER_BEAT;
							header_capture_state	<= FINISH_HEADER;
						end
						FINISH_HEADER:
						begin
							if (tready_out) begin
								if (header_byte_counter < header_beat_count_floor_int) begin
									tdata_in				<= header_shift_register[BITS_PER_BEAT-1:0];
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b0;
									tkeep_in				<= {BYTES_PER_BEAT{1'b1}};
									header_byte_counter		<= header_byte_counter + BYTES_PER_BEAT;
									header_shift_register	<= header_shift_register >> BITS_PER_BEAT;
								end
								else if (packet_byte_counter == 0) begin
									tdata_in				<= {prbs_shift_register[header_leftover_int-1:0], header_shift_register[BITS_PER_BEAT-header_leftover_int-1:0]};
									prbs_shift_register		<= prbs_shift_register >> header_leftover_int;
									tkeep_shift_register	<= tkeep_shift_register >> (header_leftover_int/8);
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b0;
									tkeep_in				<= {tkeep_shift_register[header_leftover_int/8:0], {((BITS_PER_BEAT-header_leftover_int)/8){1'b1}}};
									tdata_leftover			<= tdata_shift_register[(BITS_PER_BEAT-1)-:(PRBS_SIZE-header_leftover_int)];
									tkeep_leftover			<= {BYTES_PER_BEAT{1'b1}};
									packet_byte_counter		<= packet_byte_counter + header_leftover_int/8;
								end
								else if (packet_byte_counter < PACKET_BYTE_COUNT-BYTES_PER_BEAT) begin
									tdata_in				<= prbs_shift_register[BITS_PER_BEAT-1:0];
									prbs_shift_register		<= prbs_shift_register >> BITS_PER_BEAT;
									tkeep_shift_register	<= tkeep_shift_register >> BYTES_PER_BEAT;
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b0;
									tkeep_in				<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
									tdata_leftover			<= tdata_shift_register[(BITS_PER_BEAT-1)-:(PRBS_SIZE-header_leftover_int)];
									tkeep_leftover			<= {BYTES_PER_BEAT{1'b1}};
									packet_byte_counter		<= packet_byte_counter + BYTES_PER_BEAT;
								end
								else begin
									tdata_in				<= prbs_shift_register[BITS_PER_BEAT-1:0];
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b1;
									tkeep_in				<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
									header_capture_state	<= END_OF_BUS_TRANSACTION;
								end
							end
						end
						END_OF_BUS_TRANSACTION:
						begin
							tdata_in			<= 0;
							tvalid_in			<= 1'b0;
							tlast_in			<= 1'b0;
							tkeep_in			<= 0;

							// Enable data out now to check the operation of the FIFO
							header_capture_state	<= CHECK_HEADER_CAPTURE_OUTPUT;
						end
						CHECK_HEADER_CAPTURE_OUTPUT:
						begin
							if ((ip_rx_tready && ip_rx_tvalid && ip_rx_tlast) || (arp_rx_tready && arp_rx_tvalid && arp_rx_tlast)) begin
								packet_byte_counter		<= 0;
								header_byte_counter		<= 0;
								header_capture_state	<= SETUP_DATA_STREAM;
							end
						end
						default : header_capture_state	<= IDLE;
					endcase
				end
			end

			always @(posedge clock or reset) begin
				if (reset) begin
					verification_state		<= WAIT_FOR_DATA;
					prbs_verifier			= {PRBS_SIZE{1'b1}};
					data_valid				<= 1'b0;
					verifier_shift_register	= 0;
					tready_tx_in			<= 1'b0;
					byte_counter			<= 0;
					leftover_prbs_data		<= 0;
				end
				else begin
					case (verification_state)
						WAIT_FOR_DATA:
						begin
							if (tvalid_tx_out) begin
								tready_tx_in			<= 1'b1;
								verifier_shift_register	= prbs_data_array(prbs_verifier);
								prbs_verifier			= verifier_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
								byte_counter			<= 0;
								verification_state		<= REMOVE_HEADER_DATA;
							end
							else begin
								tready_tx_in			<= 1'b0;
							end
						end
						REMOVE_HEADER_DATA:
						begin
							tready_tx_in			<= 1'b1;
							
							if (tvalid_tx_out) begin
								if (byte_counter < BYTES_PER_HEADER-BYTES_PER_BEAT) begin
									byte_counter			<= byte_counter + BYTES_PER_BEAT;
								end
								else begin
									leftover_prbs_data		<= tdata_tx_out[(BITS_PER_BEAT-1)-:header_leftover_int];
									verification_state		<= VERIFY_REMAINING_DATA;
								end	
							end
						end
						VERIFY_REMAINING_DATA:
						begin
							if (tvalid_tx_out) begin
								tready_tx_in			<= 1'b1;
								
								if ({tdata_tx_out[BITS_PER_BEAT-header_leftover_int-1:0], leftover_prbs_data} == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
									data_valid			<= 1'b1;
								end
								else begin
									data_valid			<= 1'b0;
								end
								
								verifier_shift_register	<= verifier_shift_register >> BITS_PER_BEAT;
								leftover_prbs_data		<= tdata_tx_out[(BITS_PER_BEAT-1)-:header_leftover_int];
								
								if (tlast_tx_out) begin
									tready_tx_in			<= 1'b0;
									verification_state		<= WAIT_FOR_DATA;
								end
								else begin
									tready_tx_in			<= 1'b1;
								end
							end
//							else begin
//								tready_tx_in			<= 1'b0;
//							end
						end
						default:	verification_state		<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : small_data_size_even
			reg [TOTAL_BIT_COUNT-1:0] prbs_shift_register;
			reg [TOTAL_BIT_COUNT/8-1:0] tkeep_shift_register;
			reg [TOTAL_BIT_COUNT-1:0] verifier_shift_register;
			integer byte_counter;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= IDLE;
					tvalid_in				<= 1'b0;
					tdata_in				<= 0;
					tlast_in				<= 1'b0;
					tkeep_in				<= 0;
					tready_tx_in			<= 1'b0;
					prbs_register			<= 32'hFFFFFFFF;
					beat_counter			<= 0;
					data_valid				<= 1'b0;
					header_shift_register	<= 0;
					packet_byte_counter		<= 0;
					header_byte_counter		<= 0;
					prbs_shift_register		<= 0;
					tkeep_shift_register	<= 0;
				end
				else begin
					tready_tx_in			<= 1'b1;
					
					case (header_capture_state)
						IDLE: 
						begin
							header_capture_state	<= SETUP_DATA_STREAM;
						end
						SETUP_DATA_STREAM:
						begin
							prbs_shift_register		= prbs_data_array(prbs_register);
							prbs_register			= prbs_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
							tkeep_shift_register	<= {(PACKET_BYTE_COUNT){1'b1}};
							tdata_in				<= datagram_header[BITS_PER_BEAT-1:0];
							tvalid_in				<= 1'b1;
							tlast_in				<= 1'b0;
							tkeep_in				<= {BYTES_PER_BEAT{1'b1}};
							header_byte_counter		<= header_byte_counter + BYTES_PER_BEAT;
							header_shift_register	<= datagram_header >> BITS_PER_BEAT;
							header_capture_state	<= FINISH_HEADER;
						end
						FINISH_HEADER:
						begin
							if (tready_out) begin
								if (header_byte_counter < header_beat_count_floor_int) begin
									tdata_in				<= header_shift_register[BITS_PER_BEAT-1:0];
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b0;
									tkeep_in				<= {BYTES_PER_BEAT{1'b1}};
									header_byte_counter		<= header_byte_counter + BYTES_PER_BEAT;
									header_shift_register	<= header_shift_register >> BITS_PER_BEAT;
								end
								else if (packet_byte_counter < PACKET_BYTE_COUNT-BYTES_PER_BEAT) begin
									tdata_in				<= prbs_shift_register[BITS_PER_BEAT-1:0];
									prbs_shift_register		<= prbs_shift_register >> BITS_PER_BEAT;
									tkeep_shift_register	<= tkeep_shift_register >> BYTES_PER_BEAT;
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b0;
									tkeep_in				<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
									packet_byte_counter		<= packet_byte_counter + BYTES_PER_BEAT;
								end
								else begin
									tdata_in				<= prbs_shift_register[BITS_PER_BEAT-1:0];
									tvalid_in				<= 1'b1;
									tlast_in				<= 1'b1;
									tkeep_in				<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
									header_capture_state	<= END_OF_BUS_TRANSACTION;
								end
							end
						end
						END_OF_BUS_TRANSACTION:
						begin
							tdata_in			<= 0;
							tvalid_in			<= 1'b0;
							tlast_in			<= 1'b0;
							tkeep_in			<= 0;

							// Enable data out now to check the operation of the FIFO
							header_capture_state	<= CHECK_HEADER_CAPTURE_OUTPUT;
						end
						CHECK_HEADER_CAPTURE_OUTPUT:
						begin
							if (tvalid_out == 1'b1) begin
								if (tdata_out == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
									data_valid		<= 1'b1;
								end
								else begin
									data_valid		<= 1'b0;
								end
								
								verifier_shift_register		<= verifier_shift_register >> BITS_PER_BEAT;
							end

							if ((ip_rx_tready && ip_rx_tvalid && ip_rx_tlast) || (arp_rx_tready && arp_rx_tvalid && arp_rx_tlast)) begin
								packet_byte_counter		<= 0;
								header_byte_counter		<= 0;
								header_capture_state	<= SETUP_DATA_STREAM;
							end
						end
						default : header_capture_state	<= IDLE;
					endcase
				end
			end

			always @(posedge clock or reset) begin
				if (reset) begin
					verification_state		<= WAIT_FOR_DATA;
					prbs_verifier			= {PRBS_SIZE{1'b1}};
					data_valid				<= 1'b0;
					verifier_shift_register	= 0;
					tready_tx_in			<= 1'b0;
					byte_counter			<= 0;
				end
				else begin
					case (verification_state)
						WAIT_FOR_DATA:
						begin
							if (tvalid_tx_out) begin
								tready_tx_in			<= 1'b1;
								verifier_shift_register	= prbs_data_array(prbs_verifier);
								prbs_verifier			= verifier_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
								byte_counter			<= 0;
								verification_state		<= REMOVE_HEADER_DATA;
							end
							else begin
								tready_tx_in			<= 1'b0;
							end
						end
						REMOVE_HEADER_DATA:
						begin
							tready_tx_in			<= 1'b1;
							
							if (tvalid_tx_out) begin
								if (byte_counter < BYTES_PER_HEADER-BYTES_PER_BEAT) begin
									byte_counter			<= byte_counter + BYTES_PER_BEAT;
								end
								else begin
									verification_state		<= VERIFY_REMAINING_DATA;
								end	
							end
						end
						VERIFY_REMAINING_DATA:
						begin
							if (tvalid_tx_out) begin
								tready_tx_in			<= 1'b1;
								
								if (tdata_tx_out == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
									data_valid		<= 1'b1;
								end
								else begin
									data_valid		<= 1'b0;
								end
								
								verifier_shift_register	<= verifier_shift_register >> BITS_PER_BEAT;
								
								if (tlast_tx_out) begin
									tready_tx_in			<= 1'b0;
									verification_state		<= WAIT_FOR_DATA;
								end
								else begin
									tready_tx_in			<= 1'b1;
								end
							end
//							else begin
//								tready_tx_in			<= 1'b0;
//							end
						end
						default:	verification_state		<= WAIT_FOR_DATA;
					endcase
				end
			end
		end
	endgenerate
endmodule