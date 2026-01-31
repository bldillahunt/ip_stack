`timescale 1ns/1ps
`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module arp_layer_testbench;

	localparam ETH_HEADER_SIZE = 112;
	localparam ARP_HEADER_SIZE = 224;
	localparam BITS_PER_BEAT = 64;
	localparam PIPELINE_DEPTH = 32;
	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	localparam BROADCAST_MAC_ADDRESS = 48'hFFFFFFFFFFFF;
	localparam SOURCE_MAC_ADDRESS = 48'h112233445566;
	localparam DESTINATION_MAC_ADDRESS = 48'hF071AD9025B4;
	localparam HEADER_BYTE_COUNT = 14;
	localparam INTERPACKET_GAP_TIME = 12;
	localparam DATAGRAM_SIZE = ETH_HEADER_SIZE + ARP_HEADER_SIZE;
	localparam BYTES_PER_DATAGRAM = DATAGRAM_SIZE/8;

	localparam BYTES_PER_HEADER = ETH_HEADER_SIZE/8;
	localparam [47:0] SRC_MAC_ADDRESS = SOURCE_MAC_ADDRESS;
	localparam [47:0] DEST_MAC_ADDRESS = DESTINATION_MAC_ADDRESS;
	localparam [15:0] ETH_TYPE = 16'h0806;
	
	localparam real header_size_real = ETH_HEADER_SIZE;
	localparam real bits_per_beat_real = BITS_PER_BEAT;
	localparam real datagram_size_real = DATAGRAM_SIZE;
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
	
	// ARP parameters
	localparam [15:0] HARDWARE_TYPE = 16'h0001;
	localparam [15:0] PROTOCOL_TYPE = 16'h0800;
	localparam [7:0]  HARDWARE_LENGTH = 8'h06;
	localparam [7:0]  PROTOCOL_LENGTH = 8'h04;
	localparam [15:0] OPERATION = 16'h0001;
	localparam [47:0] SOURCE_HARDWARE_ADDRESS = 48'h001122334455;
	localparam [31:0] SOURCE_PROTOCOL_ADDRESS = 32'hA9FEA811;
	localparam [47:0] DESTINATION_HARDWARE_ADDRESS = 48'h554433221100;
	localparam [31:0] DESTINATION_PROTOCOL_ADDRESS = 32'hA9FEA812;
	
	reg clock;
	reg reset;
	wire [ETH_HEADER_SIZE-1:0] header_data_112bit;
	wire [47:0] source_mac_address;
	wire [47:0] destination_mac_address;
	wire [15:0] ethernet_type;
	wire [ETH_HEADER_SIZE-1:0] eth_datagram_header;
	wire [ARP_HEADER_SIZE-1:0] arp_datagram_header;
	wire [15:0] hw_type_swapped;
	wire [15:0] protocol_swapped;
	wire [15:0] operation_swapped;
	wire [47:0] sha_swapped;
	wire [31:0] spa_swapped;
	wire [47:0] dha_swapped;
	wire [31:0] dpa_swapped;
	
	reg eth_rx_tvalid;
	reg [BITS_PER_BEAT-1:0] eth_rx_tdata;
	reg [BYTES_PER_BEAT-1:0] eth_rx_tkeep;
	reg eth_rx_tlast;
	wire [0:0] mac_rx_tuser;
	wire mac_rx_filter_tuser;

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
	wire arp_header_tready;
	wire arp_header_tvalid;
	wire [BITS_PER_BEAT-1:0] arp_header_tdata;
	wire [BYTES_PER_BEAT-1:0] arp_header_tkeep;
	wire arp_header_tlast;
	wire [15:0] rx_ethernet_type;
	wire [15:0] rx_protocol_type;
	wire [7:0] rx_hardware_length;
	wire [7:0] rx_protocol_length;
	wire [15:0] rx_operation;
	wire [47:0] rx_src_hw_address;
	wire [31:0] rx_src_ip_address;
	wire [47:0] rx_dest_hw_address;
	wire [31:0] rx_dest_ip_address;
	wire ip_tx_tready;
	wire eth_tx_tready;
	wire eth_tx_tvalid;
	wire [BITS_PER_BEAT-1:0] eth_tx_tdata;
	wire [BYTES_PER_BEAT-1:0] eth_tx_tkeep;
	wire eth_tx_tlast;
	reg tready_tx_in;
	wire tvalid_tx_out;
	wire [BITS_PER_BEAT-1 :0] tdata_tx_out;
	wire [BYTES_PER_BEAT-1:0] tkeep_tx_out;
	wire tlast_tx_out;
	wire [0:0] mac_tx_tuser;
	wire mac_tx_filter_tuser;

	wire arp_data_ready;
	wire arp_data_received;
	
	reg [DATAGRAM_SIZE-1:0] tdata_shift_register;
	reg [BYTES_PER_DATAGRAM-1:0] tkeep_shift_register;
	wire [47:0] temac_address;
	wire [47:0] received_mac_address;
	wire valid_mac_address;
	assign temac_address = DESTINATION_MAC_ADDRESS;
	
	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] START_ETHERNET_PACKET = 8'h02;
	localparam [7:0] CHECK_FOR_END_OF_DATA = 8'h04;
	localparam [7:0] CLEAR_BUS_COMMAND = 8'h08;
	localparam [7:0] WAIT_FOR_TRANSFER_COMPLETE = 8'h10;
	
	reg [7:0] arp_command_state;
	reg data_valid_out;
	
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
	assign eth_datagram_header = header_data_112bit;		
	
	byte_swap #(.WIDTH(16))	hw_type (.data_in(HARDWARE_TYPE),	.data_out(hw_type_swapped));	
	byte_swap #(.WIDTH(16))	prot_type (.data_in(PROTOCOL_TYPE),	.data_out(protocol_swapped));	
//	byte_swap #(.WIDTH(8))	src_mac (.data_in(),	.data_out());	
//	byte_swap #(.WIDTH(8))	src_mac (.data_in(),	.data_out());	
	byte_swap #(.WIDTH(16))	arp_oper (.data_in(OPERATION),	.data_out(operation_swapped));	
	byte_swap #(.WIDTH(48))	arp_sha (.data_in(SOURCE_HARDWARE_ADDRESS),	.data_out(sha_swapped));	
	byte_swap #(.WIDTH(32))	arp_spa (.data_in(SOURCE_PROTOCOL_ADDRESS),	.data_out(spa_swapped));	
	byte_swap #(.WIDTH(48))	arp_dha (.data_in(DESTINATION_HARDWARE_ADDRESS), .data_out(dha_swapped));	
	byte_swap #(.WIDTH(32))	arp_dpa (.data_in(DESTINATION_PROTOCOL_ADDRESS), .data_out(dpa_swapped));	
	
	assign arp_datagram_header =   {dpa_swapped,
									dha_swapped,
									spa_swapped,
									sha_swapped,
									operation_swapped,
									PROTOCOL_LENGTH,
									HARDWARE_LENGTH,
									protocol_swapped,
									hw_type_swapped};
	
	ethernet_receiver #(BITS_PER_BEAT, PIPELINE_DEPTH) eth_rx (.reset(reset), .clock(clock), .temac_rx_tvalid(eth_rx_tvalid), .temac_rx_tdata(eth_rx_tdata), .temac_rx_tkeep(eth_rx_tkeep), .temac_rx_tlast(eth_rx_tlast), .temac_rx_tuser(mac_rx_tuser), .temac_rx_filter_tuser(mac_rx_filter_tuser), .ip_rx_tready(ip_rx_tready), .ip_rx_tvalid(ip_rx_tvalid), .ip_rx_tdata(ip_rx_tdata), .ip_rx_tkeep(ip_rx_tkeep), .ip_rx_tlast(ip_rx_tlast), .arp_rx_tready(arp_rx_tready), .arp_rx_tvalid(arp_rx_tvalid), .arp_rx_tdata(arp_rx_tdata), .arp_rx_tkeep(arp_rx_tkeep), .arp_rx_tlast(arp_rx_tlast), .temac_address(temac_address), .received_mac_address(received_mac_address), .valid_mac_address(valid_mac_address));
	arp_receiver #(BITS_PER_BEAT, PIPELINE_DEPTH) arp_rx (.reset(reset),  .clock(clock), .arp_data_ready(arp_data_ready), .arp_data_received(arp_data_received),  .eth_rx_tready(arp_rx_tready),  .eth_rx_tvalid(arp_rx_tvalid),  .eth_rx_tdata(arp_rx_tdata), .eth_rx_tkeep(arp_rx_tkeep), .eth_rx_tlast(arp_rx_tlast), .arp_rx_tready(arp_header_tready),  .arp_rx_tvalid(arp_header_tvalid),  .arp_rx_tdata(arp_header_tdata),  .arp_rx_tkeep(arp_header_tkeep),  .arp_rx_tlast(arp_header_tlast),  .ethernet_type(rx_ethernet_type),  .protocol_type(rx_protocol_type),  .hardware_length(rx_hardware_length),  .protocol_length(rx_protocol_length),  .arp_operation(rx_operation),  .source_hardware_address(rx_src_hw_address),  .source_protocol_address(rx_src_ip_address),  .target_hardware_address(rx_dest_hw_address),  .target_protocol_address(rx_dest_ip_address));
	arp_transmitter #(BITS_PER_BEAT, PIPELINE_DEPTH) arp_tx (.reset(reset), .clock(clock), .arp_data_ready(arp_data_ready), .arp_data_received(arp_data_received), .eth_tx_tready(eth_tx_tready), .eth_tx_tvalid(eth_tx_tvalid), .eth_tx_tdata(eth_tx_tdata), .eth_tx_tkeep(eth_tx_tkeep), .eth_tx_tlast(eth_tx_tlast), .ethernet_type(rx_ethernet_type), .protocol_type(rx_protocol_type), .hardware_length(rx_hardware_length), .protocol_length(rx_protocol_length), .arp_operation(rx_operation), .source_hardware_address(rx_src_hw_address), .source_protocol_address(rx_src_ip_address), .target_hardware_address(rx_dest_hw_address), .target_protocol_address(rx_dest_ip_address));
	ethernet_transmitter #(BITS_PER_BEAT, PIPELINE_DEPTH) eth_tx (.reset(reset), .clock(clock), .source_mac_address(SOURCE_MAC_ADDRESS), .destination_mac_address(DESTINATION_MAC_ADDRESS), .ip_tx_tready(ip_tx_tready), .ip_tx_tvalid(1'b0), .ip_tx_tdata({BITS_PER_BEAT{1'b0}}), .ip_tx_tkeep({BYTES_PER_BEAT{1'b0}}), .ip_tx_tlast(1'b0), .arp_tx_tready(eth_tx_tready), .arp_tx_tvalid(eth_tx_tvalid), .arp_tx_tdata(eth_tx_tdata), .arp_tx_tkeep(eth_tx_tkeep), .arp_tx_tlast(eth_tx_tlast), .temac_tx_tready(tready_tx_in), .temac_tx_tvalid(tvalid_tx_out), .temac_tx_tdata(tdata_tx_out), .temac_tx_tkeep(tkeep_tx_out), .temac_tx_tlast(tlast_tx_out), .temac_tx_tuser(mac_tx_tuser), .temac_tx_filter_tuser(mac_tx_filter_tuser));	
																	 
	generate
		if (BITS_PER_BEAT == DATAGRAM_SIZE) begin : same_size
			always @(posedge clock or reset)
			begin
				if (reset) begin
					arp_command_state	<= IDLE;
					eth_rx_tvalid		<= 1'b0;
					eth_rx_tdata		<= 0;
					eth_rx_tkeep		<= 0;
					eth_rx_tlast		<= 1'b0;
					tdata_shift_register<= 0;
					tkeep_shift_register<= 0;
					tready_tx_in		<= 1'b0;
				end
				else begin
					case (arp_command_state)
						IDLE:
						begin
							tdata_shift_register<= {arp_datagram_header, eth_datagram_header};
							tkeep_shift_register<= {BYTES_PER_DATAGRAM{1'b1}};
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							arp_command_state	<= START_ETHERNET_PACKET;
						end
						START_ETHERNET_PACKET:
						begin
							eth_rx_tvalid		<= 1'b1;
							eth_rx_tdata		<= tdata_shift_register;
							eth_rx_tkeep		<= tkeep_shift_register;
							eth_rx_tlast		<= 1'b1;
							arp_command_state	<= CLEAR_BUS_COMMAND;
						end
						CLEAR_BUS_COMMAND:
						begin
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							tready_tx_in		<= 1'b1;
							arp_command_state	<= WAIT_FOR_TRANSFER_COMPLETE;
						end
						WAIT_FOR_TRANSFER_COMPLETE:
						begin
							if (tvalid_tx_out && tlast_tx_out) begin
								tready_tx_in		<= 1'b0;
								arp_command_state	<= IDLE;
							end
						end
						default: arp_command_state	<= IDLE;
					endcase
				end
			end
			
			always @(posedge clock)
			begin
				if (tready_tx_in && tvalid_tx_out) begin
					if (tdata_tx_out == tdata_shift_register) begin
						data_valid_out	<= 1'b1;
					end
					else begin
						data_valid_out	<= 1'b0;
					end
				end
			end
		end
		else if (BITS_PER_BEAT > DATAGRAM_SIZE) begin : large_data_size
			always @(posedge clock or reset)
			begin
				if (reset) begin
					arp_command_state	<= IDLE;
					eth_rx_tvalid		<= 1'b0;
					eth_rx_tdata		<= 0;
					eth_rx_tkeep		<= 0;
					eth_rx_tlast		<= 1'b0;
					tdata_shift_register<= 0;
					tkeep_shift_register<= 0;
					tready_tx_in		<= 1'b0;
				end
				else begin
					case (arp_command_state)
						IDLE:
						begin
							tdata_shift_register<= {{(BITS_PER_BEAT-DATAGRAM_SIZE){1'b0}}, arp_datagram_header, eth_datagram_header};
							tkeep_shift_register<= {{(BITS_PER_BEAT-DATAGRAM_SIZE)/8{1'b0}}, {BYTES_PER_DATAGRAM{1'b1}}};
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							arp_command_state	<= START_ETHERNET_PACKET;
						end
						START_ETHERNET_PACKET:
						begin
							eth_rx_tvalid		<= 1'b1;
							eth_rx_tdata		<= tdata_shift_register;
							eth_rx_tkeep		<= tkeep_shift_register;
							eth_rx_tlast		<= 1'b1;
							arp_command_state	<= CLEAR_BUS_COMMAND;
						end
						CLEAR_BUS_COMMAND:
						begin
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							tready_tx_in		<= 1'b1;
							arp_command_state	<= WAIT_FOR_TRANSFER_COMPLETE;
						end
						WAIT_FOR_TRANSFER_COMPLETE:
						begin
							if (tvalid_tx_out && tlast_tx_out) begin
								tready_tx_in		<= 1'b0;
								arp_command_state	<= IDLE;
							end
						end
						default: arp_command_state	<= IDLE;
					endcase
				end
			end
			
			always @(posedge clock)
			begin
				if (tready_tx_in && tvalid_tx_out) begin
					if (tdata_tx_out == tdata_shift_register) begin
						data_valid_out	<= 1'b1;
					end
					else begin
						data_valid_out	<= 1'b0;
					end
				end
			end
		end
		else if ((DATAGRAM_SIZE % BITS_PER_BEAT) == 0) begin : small_data_size_even
			integer byte_counter;
			reg latch_header;
			reg [DATAGRAM_SIZE-1:0] datagram_shift_register;
			
			always @(posedge clock or reset)
			begin
				if (reset) begin
					arp_command_state	<= IDLE;
					eth_rx_tvalid		<= 1'b0;
					eth_rx_tdata		<= 0;
					eth_rx_tkeep		<= 0;
					eth_rx_tlast		<= 1'b0;
					tdata_shift_register<= 0;
					tkeep_shift_register<= 0;
					tready_tx_in		<= 1'b0;
					byte_counter		<= 0;
					latch_header		<= 1'b0;
				end
				else begin
					latch_header		<= 1'b0;
					
					case (arp_command_state)
						IDLE:
						begin
							tdata_shift_register<= {arp_datagram_header, eth_datagram_header};
							tkeep_shift_register<= {BYTES_PER_DATAGRAM{1'b1}};
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							latch_header		<= 1'b1;
							byte_counter		<= 0;
							arp_command_state	<= START_ETHERNET_PACKET;
						end
						START_ETHERNET_PACKET:
						begin
							eth_rx_tvalid		<= 1'b1;
							eth_rx_tdata		<= tdata_shift_register[BITS_PER_BEAT-1:0];
							eth_rx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
							eth_rx_tlast		<= 1'b0;
							tdata_shift_register<= tdata_shift_register >> BITS_PER_BEAT;
							tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
							byte_counter		<= byte_counter + BYTES_PER_BEAT;
							arp_command_state	<= CHECK_FOR_END_OF_DATA;
						end
						CHECK_FOR_END_OF_DATA:
						begin
							if (byte_counter < (BYTES_PER_DATAGRAM-BYTES_PER_BEAT)) begin
								eth_rx_tvalid		<= 1'b1;
								eth_rx_tdata		<= tdata_shift_register[BITS_PER_BEAT-1:0];
								eth_rx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
								eth_rx_tlast		<= 1'b0;
								tdata_shift_register<= tdata_shift_register >> BITS_PER_BEAT;
								tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
								byte_counter		<= byte_counter + BYTES_PER_BEAT;
							end
							else if (byte_counter < BYTES_PER_DATAGRAM) begin
								eth_rx_tvalid		<= 1'b1;
								eth_rx_tdata		<= tdata_shift_register[BITS_PER_BEAT-1:0];
								eth_rx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
								eth_rx_tlast		<= 1'b1;
								tdata_shift_register<= tdata_shift_register >> BITS_PER_BEAT;
								tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
								byte_counter		<= byte_counter + BYTES_PER_BEAT;
								arp_command_state	<= CLEAR_BUS_COMMAND;
							end
						end
						CLEAR_BUS_COMMAND:
						begin
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							tready_tx_in		<= 1'b1;
							arp_command_state	<= WAIT_FOR_TRANSFER_COMPLETE;
						end
						WAIT_FOR_TRANSFER_COMPLETE:
						begin
							if (tvalid_tx_out && tlast_tx_out) begin
								tready_tx_in		<= 1'b0;
								arp_command_state	<= IDLE;
							end
						end
						default: arp_command_state	<= IDLE;
					endcase
				end
			end
			
			always @(posedge clock)
			begin
				if (latch_header) begin
					datagram_shift_register	<= {arp_datagram_header, eth_datagram_header};
				end
				else if (tready_tx_in && tvalid_tx_out) begin
					if (tdata_tx_out == datagram_shift_register[BITS_PER_BEAT-1:0]) begin
						data_valid_out	<= 1'b1;						
					end
					else begin
						data_valid_out	<= 1'b0;
					end
					
					datagram_shift_register	<= datagram_shift_register >> BITS_PER_BEAT;
				end
			end
		end
		else if ((DATAGRAM_SIZE % BITS_PER_BEAT) != 0) begin : small_data_size_odd
			localparam remainder_real = $ceil(datagram_size_real/bits_per_beat_real) * bits_per_beat_real - datagram_size_real;
			localparam integer REMAINDER = remainder_real;
			integer byte_counter;
			reg latch_header;
			reg [DATAGRAM_SIZE-1:0] datagram_shift_register;
			
			always @(posedge clock or reset)
			begin
				if (reset) begin
					arp_command_state	<= IDLE;
					eth_rx_tvalid		<= 1'b0;
					eth_rx_tdata		<= 0;
					eth_rx_tkeep		<= 0;
					eth_rx_tlast		<= 1'b0;
					tdata_shift_register<= 0;
					tkeep_shift_register<= 0;
					tready_tx_in		<= 1'b0;
					byte_counter		<= 0;
					latch_header		<= 1'b0;
				end
				else begin
					latch_header		<= 1'b0;
					
					case (arp_command_state)
						IDLE:
						begin
							tdata_shift_register<= {arp_datagram_header, eth_datagram_header};
							tkeep_shift_register<= {BYTES_PER_DATAGRAM{1'b1}};
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							latch_header		<= 1'b1;
							byte_counter		<= 0;
							arp_command_state	<= START_ETHERNET_PACKET;
						end
						START_ETHERNET_PACKET:
						begin
							eth_rx_tvalid		<= 1'b1;
							eth_rx_tdata		<= tdata_shift_register[BITS_PER_BEAT-1:0];
							eth_rx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
							eth_rx_tlast		<= 1'b0;
							tdata_shift_register<= tdata_shift_register >> BITS_PER_BEAT;
							tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
							byte_counter		<= byte_counter + BYTES_PER_BEAT;
							arp_command_state	<= CHECK_FOR_END_OF_DATA;
						end
						CHECK_FOR_END_OF_DATA:
						begin
							if (byte_counter < (BYTES_PER_DATAGRAM-BYTES_PER_BEAT)) begin
								eth_rx_tvalid		<= 1'b1;
								eth_rx_tdata		<= tdata_shift_register[BITS_PER_BEAT-1:0];
								eth_rx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
								eth_rx_tlast		<= 1'b0;
								tdata_shift_register<= tdata_shift_register >> BITS_PER_BEAT;
								tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
								byte_counter		<= byte_counter + BYTES_PER_BEAT;
							end
							else if (byte_counter < BYTES_PER_DATAGRAM) begin
								eth_rx_tvalid		<= 1'b1;
								eth_rx_tdata		<= {{REMAINDER{1'b0}}, tdata_shift_register[BITS_PER_BEAT-REMAINDER-1:0]};
								eth_rx_tkeep		<= {{(REMAINDER/8){1'b0}},tkeep_shift_register[BYTES_PER_BEAT-(REMAINDER/8)-1:0]};
								eth_rx_tlast		<= 1'b1;
								tdata_shift_register<= tdata_shift_register >> BITS_PER_BEAT;
								tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
								byte_counter		<= byte_counter + BYTES_PER_BEAT;
								arp_command_state	<= CLEAR_BUS_COMMAND;
							end
						end
						CLEAR_BUS_COMMAND:
						begin
							eth_rx_tvalid		<= 1'b0;
							eth_rx_tdata		<= 0;
							eth_rx_tkeep		<= 0;
							eth_rx_tlast		<= 1'b0;
							tready_tx_in		<= 1'b1;
							arp_command_state	<= WAIT_FOR_TRANSFER_COMPLETE;
						end
						WAIT_FOR_TRANSFER_COMPLETE:
						begin
							if (tvalid_tx_out && tlast_tx_out) begin
								tready_tx_in		<= 1'b0;
								arp_command_state	<= IDLE;
							end
						end
						default: arp_command_state	<= IDLE;
					endcase
				end
			end
			
			always @(posedge clock)
			begin
				if (latch_header) begin
					datagram_shift_register	<= {arp_datagram_header, eth_datagram_header};
				end
				else if (tready_tx_in && tvalid_tx_out) begin
					if (tdata_tx_out == datagram_shift_register[BITS_PER_BEAT-1:0]) begin
						data_valid_out	<= 1'b1;						
					end
					else begin
						data_valid_out	<= 1'b0;
					end
					
					datagram_shift_register	<= datagram_shift_register >> BITS_PER_BEAT;
				end
			end
		end
	endgenerate
endmodule