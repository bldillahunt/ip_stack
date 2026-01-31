`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module arp_receiver (reset, clock, arp_data_ready, arp_data_received, eth_rx_tready, eth_rx_tvalid, eth_rx_tdata, eth_rx_tkeep, eth_rx_tlast, arp_rx_tready, arp_rx_tvalid, arp_rx_tdata, arp_rx_tkeep, arp_rx_tlast, ethernet_type, protocol_type, hardware_length, protocol_length, arp_operation, source_hardware_address, source_protocol_address, target_hardware_address, target_protocol_address);
	// Parameters
	parameter BITS_PER_BEAT		= 512;					// The number of bits per beat of data
	parameter PIPELINE_DEPTH 	= 8;					// Maximum number of clock cycles between tvalid and tready
	localparam BYTES_PER_BEAT	= BITS_PER_BEAT/8;
	localparam ARP_HEADER_SIZE = 224;	// Number of bits
	
	input reset;
	input clock;
	output reg arp_data_ready;
	input arp_data_received;
	output eth_rx_tready;
	input eth_rx_tvalid;
	input [BITS_PER_BEAT-1:0] eth_rx_tdata;
	input [BYTES_PER_BEAT-1:0] eth_rx_tkeep;
	input eth_rx_tlast;
	input arp_rx_tready;
	output arp_rx_tvalid;
	output [BITS_PER_BEAT-1:0] arp_rx_tdata;
	output [BYTES_PER_BEAT-1:0] arp_rx_tkeep;
	output arp_rx_tlast;
	
	wire tvalid_arp;
	wire [BITS_PER_BEAT-1:0] tdata_arp;
	wire [BYTES_PER_BEAT-1:0] tkeep;
	wire tlast_arp;
	wire header_data_valid;
	output reg [15:0] ethernet_type;
	output reg [15:0] protocol_type;
	output reg [7:0]  hardware_length;
	output reg [7:0]  protocol_length;
	output reg [15:0] arp_operation;
	output reg [47:0] source_hardware_address;
	output reg [31:0] source_protocol_address;
	output reg [47:0] target_hardware_address;
	output reg [31:0] target_protocol_address;
	
	wire [ARP_HEADER_SIZE-1:0] current_header;
	reg header_valid_reg;
	reg header_data_pending = 0;
	
	wire [15:0] ether_type_swapped;
	wire [15:0] protocol_swapped;	
	wire [15:0] operation_swapped;
	wire [47:0] sha_swapped;	
	wire [31:0] spa_swapped;	
	wire [47:0] tha_swapped;	
	wire [31:0] tpa_swapped;	
	
	byte_swap #(.WIDTH(16)) ether_type	(.data_in(current_header[15:0]), .data_out(ether_type_swapped));	
	byte_swap #(.WIDTH(16)) protocol	(.data_in(current_header[31:16]), .data_out(protocol_swapped));	
	byte_swap #(.WIDTH(16)) operation  	(.data_in(current_header[63:48]), .data_out(operation_swapped));	
	byte_swap #(.WIDTH(48)) sha  		(.data_in(current_header[111:64]),  .data_out(sha_swapped));	
	byte_swap #(.WIDTH(32)) spa	 		(.data_in(current_header[143:112]), .data_out(spa_swapped));	
	byte_swap #(.WIDTH(48))	tha 		(.data_in(current_header[191:144]), .data_out(tha_swapped));	
	byte_swap #(.WIDTH(32))	tpa 		(.data_in(current_header[223:192]), .data_out(tpa_swapped));	
																											
	command_capture #(BITS_PER_BEAT, ARP_HEADER_SIZE, PIPELINE_DEPTH) eth_rx (.clock(clock), .reset(reset), .tready_out(eth_rx_tready), .tvalid_in(eth_rx_tvalid), .tdata_in(eth_rx_tdata), .tlast_in(eth_rx_tlast), .tkeep_in(eth_rx_tkeep), .header_data(current_header), .header_data_valid(header_data_valid));
	
	always @(posedge clock) begin
		header_valid_reg			<= header_data_valid;
			
		if (header_data_valid && !header_valid_reg) begin
			header_data_pending		<= 1'b1;
		end
		else if (arp_data_received) begin
			header_data_pending		<= 1'b0;
		end
			
		if (header_data_valid) begin
			ethernet_type				<= ether_type_swapped;
			protocol_type				<= protocol_swapped;
			hardware_length 			<= current_header[39:32];
			protocol_length 			<= current_header[47:40];
			arp_operation 				<= operation_swapped;
			source_hardware_address		<= sha_swapped;
			source_protocol_address		<= spa_swapped;
			target_hardware_address		<= tha_swapped;
			target_protocol_address		<= tpa_swapped;
		end

		arp_data_ready				<= header_data_pending;
	end
endmodule