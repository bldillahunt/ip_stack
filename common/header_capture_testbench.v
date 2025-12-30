`timescale 1ns/1ps
`define ETHERNET_PROTOCOL
// `define UDP_PROTOCOL
// `define IP_PROTOCOL

module header_capture_testbench;

`ifdef ETHERNET_PROTOCOL
	localparam HEADER_SIZE = 112;
`endif

`ifdef UDP_PROTOCOL
	localparam HEADER_SIZE = 64;
`endif

`ifdef IP_PROTOCOL
	localparam HEADER_SIZE = 160;
`endif

	localparam BITS_PER_BEAT = 128;
	localparam TOTAL_BYTE_COUNT = 2048;
	localparam TOTAL_BIT_COUNT = TOTAL_BYTE_COUNT*8;
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BYTES_PER_HEADER = HEADER_SIZE/8;
	localparam BEATS_PER_BURST = 16;
	localparam BLANK_BYTES = 12;
	localparam PACKET_BYTE_COUNT = TOTAL_BYTE_COUNT;
	localparam [47:0] SRC_MAC_ADDRESS = 48'h001122334455;
	localparam [47:0] DEST_MAC_ADDRESS = 48'h554433221100;
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

	wire tready_out;
	reg tvalid_in;
	reg [BITS_PER_BEAT-1:0] tdata_in;
	reg tlast_in;
	reg [BITS_PER_BEAT/8-1:0] tkeep_in;
	wire tready_in;
	wire tvalid_out;
	wire [BITS_PER_BEAT-1:0] tdata_out;
	wire tlast_out;
	wire [BITS_PER_BEAT/8-1:0] tkeep_out;
	wire [HEADER_SIZE-1:0] header_data;
	
	wire [47:0] source_mac_address;
	wire [47:0] destination_mac_address;
	wire [15:0] ethernet_type;
	
	wire [127:0] header_data_112bit;
	wire [63:0]  header_data_64bit;
	wire [31:0]  header_data_32bit;
	integer beat_counter;
	reg [PRBS_SIZE-1:0] prbs_register;
	reg [PRBS_SIZE-1:0] prbs_verifier;
	reg data_valid;
	
	localparam SETUP_DATA_STREAM = 8'b00000001;
	localparam FINISH_HEADER = 8'b00000010;
	localparam WAIT_FOR_READY = 8'b00000100;
	localparam END_OF_BUS_TRANSACTION = 8'b00001000;
	localparam CHECK_HEADER_CAPTURE_OUTPUT = 8'b00010000;
	
	reg [7:0] header_capture_state;
	integer i;
	reg [BITS_PER_BEAT-1:0] tdata_shift_register;
	integer packet_byte_counter;
	integer header_byte_counter;
	reg [HEADER_SIZE-1:0] header_shift_register;
	
	// UDP section
	localparam UDP_HEADER_LENGTH = 64;	// Bits
	localparam UDP_HEADER_BYTES = UDP_HEADER_LENGTH/8;
	localparam CHECKSUM_SIZE = 16;
	reg [CHECKSUM_SIZE-1:0] udp_checksum;
	localparam [15:0] UDP_LENGTH = UDP_HEADER_BYTES + PACKET_BYTE_COUNT;
	localparam [15:0] DESTINATION_PORT = 16'h1001;
	localparam [15:0] SOURCE_PORT = 16'h1000;
	localparam CHECKSUM_DATA_SIZE = 16;
	localparam CHECKSUM_ARRAY_SIZE = (UDP_HEADER_LENGTH + TOTAL_BIT_COUNT)/CHECKSUM_SIZE;
	reg [TOTAL_BIT_COUNT-1:0] udp_payload_data;
	reg [(UDP_HEADER_LENGTH+TOTAL_BIT_COUNT)-1:0] checksum_data_input;
	wire [CHECKSUM_SIZE-1:0] udp_checksum_swapped;
	wire [15:0] udp_length_swapped;
	wire [15:0] udp_destination_swapped;
	wire [15:0] udp_source_swapped;
	reg enable_verification;
	
	// Transmit section
	reg tready_tx_in;
	wire tvalid_tx_out;
	wire [BITS_PER_BEAT-1:0] tdata_tx_out;
	wire tlast_tx_out;
	wire [BYTES_PER_BEAT-1:0] tkeep_tx_out;
	
	localparam WAIT_FOR_DATA = 4'h1;
	localparam REMOVE_HEADER_DATA = 4'h2;
	localparam VERIFY_REMAINING_DATA = 4'h4;
	
	reg [3:0] verification_state;

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
			end
			
			while (primary_sum[31:16] != 0) begin
				primary_sum		= primary_sum[31:16] + primary_sum[15:0];
			end

			checksum_temp	= primary_sum[15:0];
			
			if (checksum_temp != 16'hFFFF) begin
				checksum_16bit	= ~checksum_temp;
			end
			else begin
				checksum_16bit	= checksum_temp;
			end
		end
	endfunction
	
	// Used to perform byte swapping
	byte_swap #(.WIDTH(48))	src_mac (.data_in(SRC_MAC_ADDRESS),	.data_out(source_mac_address));	
	byte_swap #(.WIDTH(48))	dest_mac (.data_in(DEST_MAC_ADDRESS), .data_out(destination_mac_address));	
	byte_swap #(.WIDTH(16))	type_len (.data_in(ETH_TYPE), .data_out(ethernet_type));	

	assign header_data_112bit = {ethernet_type, destination_mac_address, source_mac_address};
	assign header_data_32bit = 32'h01234567;

	reg clock;
	reg reset;

	header_capture #(BITS_PER_BEAT, HEADER_SIZE) dut_rx (.clock(clock), .reset(reset), .tready_out(tready_out), .tvalid_in(tvalid_in), .tdata_in(tdata_in), .tlast_in(tlast_in), .tkeep_in(tkeep_in), .tready_in(tready_in), .tvalid_out(tvalid_out), .tdata_out(tdata_out), .tlast_out(tlast_out), .tkeep_out(tkeep_out), .header_data(header_data));
	
	header_insertion #(BITS_PER_BEAT, HEADER_SIZE) dut_tx (.clock(clock), .reset(reset), .tready_out(tready_in), .tvalid_in(tvalid_out), .tdata_in(tdata_out), .tlast_in(tlast_out), .tkeep_in(tkeep_out), .tready_in(tready_tx_in), .tvalid_out(tvalid_tx_out), .tdata_out(tdata_tx_out), .tlast_out(tlast_tx_out), .tkeep_out(tkeep_tx_out), .header_data(header_data));
	
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

	wire [HEADER_SIZE-1:0] datagram_header;

	initial begin
		// First, create the PRBS data array
		udp_payload_data = prbs_data_array(32'hFFFFFFFF);
		
		// Add the UDP header
		checksum_data_input = {SOURCE_PORT, DESTINATION_PORT, 16'h0000, UDP_LENGTH, udp_payload_data};
		
		// Generate the checksum
		udp_checksum = checksum_16bit(checksum_data_input);
	end

	// Perform the byte swapping
	byte_swap #(.WIDTH(16))	src_port (.data_in(SOURCE_PORT), .data_out(udp_source_swapped));	
	byte_swap #(.WIDTH(16))	dest_port (.data_in(DESTINATION_PORT), .data_out(udp_destination_swapped));	
	byte_swap #(.WIDTH(16))	udp_len (.data_in(UDP_LENGTH), .data_out(udp_length_swapped));	
	byte_swap #(.WIDTH(16))	udp_chksum (.data_in(udp_checksum), .data_out(udp_checksum_swapped));	
	
	assign header_data_64bit = {udp_checksum_swapped, udp_length_swapped, udp_destination_swapped, udp_source_swapped};
	
	generate
		if (HEADER_SIZE == 112) begin
			assign datagram_header = header_data_112bit;
		end
		else if (HEADER_SIZE == 64) begin
			assign datagram_header = header_data_64bit;
		end
		else if (HEADER_SIZE == 32) begin
			assign datagram_header = header_data_32bit;
		end
	endgenerate
	
	generate
		if (BITS_PER_BEAT == HEADER_SIZE) begin : same_size
			reg [HEADER_SIZE-1:0] tdata_leftover;
			reg [BYTES_PER_BEAT-1:0] tkeep_leftover;
		
			// Send random data
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= SETUP_DATA_STREAM;
					tvalid_in				<= 1'b0;
					tdata_in				<= 0;
					tlast_in				<= 1'b0;
					tkeep_in				<= 0;
					tready_tx_in			<= 1'b0;
					prbs_register			<= 32'hFFFFFFFF;
					beat_counter			<= 0;
					data_valid				<= 1'b0;
					enable_verification		<= 1'b0;
				end
				else begin
					tready_tx_in			<= 1'b1;
					enable_verification		<= 1'b0;
					
					case (header_capture_state)
						SETUP_DATA_STREAM:
						begin
							tvalid_in			<= 1'b1;
							tdata_in			<= header_data_32bit;
							tlast_in			<= 1'b0;
							tkeep_in			<= 0;

							if (tready_out) begin	// Already captured the header
								beat_counter		<= beat_counter + 1;
								prbs_register		= prbs_pattern_generator(1'b1, prbs_register);
								tdata_in			<= prbs_register;
							end
							else begin
								beat_counter		<= 0;
		//						prbs_register		<= 32'hFFFFFFFF;
							end

							enable_verification		<= 1'b1;
							header_capture_state	<= WAIT_FOR_READY;
						end
						WAIT_FOR_READY:
						begin
							if (tready_out) begin
								if (beat_counter < BEATS_PER_BURST-2) begin
									prbs_register		= prbs_pattern_generator(1'b1, prbs_register);
									tdata_in			<= prbs_register;
									tvalid_in			<= 1'b1;
									tlast_in			<= 1'b0;
									tkeep_in			<= 32'hFFFFFFFF;
									beat_counter		<= beat_counter + 1;
								end
								else if (beat_counter < BEATS_PER_BURST-1) begin
									prbs_register		= prbs_pattern_generator(1'b1, prbs_register);
									tdata_in			<= prbs_register;
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
							if (tvalid_out) begin
								if (tlast_out) begin
									header_capture_state	<= SETUP_DATA_STREAM;
								end
							end
						end
						default : header_capture_state	<= SETUP_DATA_STREAM;
					endcase
				end
			end

			always @(posedge clock or reset) begin
				if (reset) begin
					prbs_verifier	<= {PRBS_SIZE{1'b1}};
					data_valid		<= 1'b0;
				end
				else begin
					if (tvalid_out) begin
						prbs_verifier	= prbs_pattern_generator(1'b1, prbs_verifier);

						if (tdata_out == prbs_verifier) begin
							data_valid		<= 1'b1;
						end
						else begin
							data_valid		<= 1'b0;
						end
					end
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
					header_capture_state	<= SETUP_DATA_STREAM;
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
					enable_verification		<= 1'b0;
				end
				else begin
//					tready_tx_in			<= 1'b1;
					enable_verification		<= 1'b0;
					
					case (header_capture_state)
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
							enable_verification			<= 1'b1;
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
							if (tlast_out) begin
								beat_counter			<= 0;
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
					tdata_leftover			<= 0;
					tkeep_leftover			<= 0;
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
								tdata_leftover			<= tdata_tx_out[(BITS_PER_BEAT-1)-:BITS_PER_BEAT-HEADER_SIZE];
								tkeep_leftover			<= tkeep_tx_out[(BYTES_PER_BEAT-1)-:BYTES_PER_BEAT-BYTES_PER_HEADER];
								verification_state		<= VERIFY_REMAINING_DATA;
							end
						end
						VERIFY_REMAINING_DATA:
						begin
							if (tvalid_tx_out) begin
								tdata_leftover			<= tdata_tx_out[(BITS_PER_BEAT-1)-:BITS_PER_BEAT-HEADER_SIZE];
								tkeep_leftover			<= tkeep_tx_out[(BYTES_PER_BEAT-1)-:BYTES_PER_BEAT-BYTES_PER_HEADER];
								
								if ({tdata_tx_out[HEADER_SIZE-1:0], tdata_leftover} == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
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
						default:	verification_state		<= WAIT_FOR_DATA;
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
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= SETUP_DATA_STREAM;
					tvalid_in				<= 1'b0;
					tdata_in				<= 0;
					tlast_in				<= 1'b0;
					tkeep_in				<= 0;
					tready_tx_in			<= 1'b0;
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
					enable_verification		<= 1'b0;
				end
				else begin
					tready_tx_in			<= 1'b1;
					enable_verification		<= 1'b0;
					
					case (header_capture_state)
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
							enable_verification		<= 1'b1;
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
							if (tlast_out) begin
								packet_byte_counter		<= 0;
								header_byte_counter		<= 0;
								header_capture_state	<= SETUP_DATA_STREAM;
							end
						end
						default : header_capture_state	<= SETUP_DATA_STREAM;
					endcase
				end
			end
			
			always @(posedge clock) begin
				if (reset) begin
					prbs_verifier	<= {PRBS_SIZE{1'b1}};
					data_valid		<= 1'b0;
					verifier_shift_register	<= 0;
				end
				else begin
					if (enable_verification) begin
						verifier_shift_register	= prbs_data_array(prbs_verifier);
						prbs_verifier			= verifier_shift_register[TOTAL_BIT_COUNT-1-:PRBS_SIZE];
					end
					else if (tvalid_out == 1'b1) begin
						if (tdata_out == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
							data_valid		<= 1'b1;
						end
						else begin
							data_valid		<= 1'b0;
						end

						verifier_shift_register		<= verifier_shift_register >> BITS_PER_BEAT;
					end
				end
			end
		end
		else if ((HEADER_SIZE % BITS_PER_BEAT) == 0) begin : small_data_size_even
			reg [TOTAL_BIT_COUNT-1:0] prbs_shift_register;
			reg [TOTAL_BIT_COUNT/8-1:0] tkeep_shift_register;
			reg [TOTAL_BIT_COUNT-1:0] verifier_shift_register;
			
			always @(posedge clock or reset) begin
				if (reset) begin
					header_capture_state	<= SETUP_DATA_STREAM;
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
					enable_verification		<= 1'b0;
				end
				else begin
					tready_tx_in			<= 1'b1;
					enable_verification		<= 1'b0;
					
					case (header_capture_state)
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
							enable_verification		<= 1'b1;
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
							
							if (tlast_out) begin
								packet_byte_counter		<= 0;
								header_byte_counter		<= 0;
								header_capture_state	<= SETUP_DATA_STREAM;
							end
						end
						default : header_capture_state	<= SETUP_DATA_STREAM;
					endcase
				end
			end
			
			always @(posedge clock or reset) begin
				if (reset) begin
					data_valid		<= 1'b0;
					verifier_shift_register	<= 0;
					prbs_verifier	<= {PRBS_SIZE{1'b1}};
				end
				else begin
					if (enable_verification) begin
						verifier_shift_register	= prbs_data_array(prbs_verifier);
						prbs_verifier			= verifier_shift_register[(TOTAL_BIT_COUNT-1)-:PRBS_SIZE];
					end
					else if (tvalid_out == 1'b1) begin
						if (tdata_out == verifier_shift_register[BITS_PER_BEAT-1:0]) begin
							data_valid		<= 1'b1;
						end
						else begin
							data_valid		<= 1'b0;
						end

						verifier_shift_register		<= verifier_shift_register >> BITS_PER_BEAT;
					end
				end
			end
		end
	endgenerate
endmodule

module byte_swap #(parameter WIDTH = 8) // Declare the parameter with a default value
(
	input wire [WIDTH-1:0] data_in,
	output wire [WIDTH-1:0] data_out
);

    // The function uses the module's parameter 'WIDTH'
    function [WIDTH-1:0] parametizable_byte_swap (input [WIDTH-1:0] input_data);
    	integer i;
    	reg [WIDTH-1:0] shift_register;
    	
        begin
       		shift_register = input_data;
       		
        	for (i = 0; i < WIDTH/8; i = i + 1) begin
        		parametizable_byte_swap[i*8+:8] = shift_register[WIDTH-1:WIDTH-8];
        		shift_register = shift_register << 8;
        	end
        end
    endfunction

    // Use the function
    assign data_out = parametizable_byte_swap(data_in);
endmodule
