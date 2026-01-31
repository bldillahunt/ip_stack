`include "C:/Users/ambig/source/RTL/Verilog/IP_stack/common/common_header.v"

module arp_transmitter (reset, clock, arp_data_ready, arp_data_received, eth_tx_tready, eth_tx_tvalid, eth_tx_tdata, eth_tx_tkeep, eth_tx_tlast, ethernet_type, protocol_type, hardware_length, protocol_length, arp_operation, source_hardware_address, source_protocol_address, target_hardware_address, target_protocol_address);
	parameter BITS_PER_BEAT = 64;
	parameter PIPELINE_DEPTH = 8;

	localparam BYTES_PER_BEAT = BITS_PER_BEAT/8;
	
	input reset;
	input clock;
	input arp_data_ready;
	output reg arp_data_received;
	input eth_tx_tready;
	output eth_tx_tvalid;
	output [BITS_PER_BEAT-1:0] eth_tx_tdata;
	output [BYTES_PER_BEAT-1:0] eth_tx_tkeep;
	output eth_tx_tlast;
	input [15:0] ethernet_type;
	input [15:0] protocol_type;
	input [7:0] hardware_length;
	input [7:0] protocol_length;
	input [15:0] arp_operation;
	input [47:0] source_hardware_address;
	input [31:0] source_protocol_address;
	input [47:0] target_hardware_address;
	input [31:0] target_protocol_address;
	
	// Number of bits in the ARP header
	localparam ARP_HEADER_SIZE = 224;				
	
	// Number of bits of padding when using a large bus value
	localparam ARP_DATAGRAM_PADDING = ((BITS_PER_BEAT >= ARP_HEADER_SIZE) ? BITS_PER_BEAT - ARP_HEADER_SIZE : 0);
	
	localparam PADDING_SIZE = BITS_PER_BEAT - ARP_HEADER_SIZE;
	localparam BYTES_PER_HEADER = ARP_HEADER_SIZE/8;
	
	localparam real bits_per_beat_real = BITS_PER_BEAT;
	localparam real arp_size_real = ARP_HEADER_SIZE;
	
	// The total number of beats per transaction
	localparam real beats_per_transaction_real = ((BITS_PER_BEAT >= ARP_HEADER_SIZE) ? 1 : $ceil(arp_size_real/bits_per_beat_real));
	localparam integer BEATS_PER_TRANSACTION = beats_per_transaction_real; 
	
	// Number of header bits in the last beat of data
	localparam HEADER_REMAINDER = ARP_HEADER_SIZE % BITS_PER_BEAT;

	// Connections to the header insertion module
	wire arp_tx_tready;
	reg arp_tx_tvalid;
	reg [BITS_PER_BEAT-1:0] arp_tx_tdata;
	reg arp_tx_tlast;
	reg [BYTES_PER_BEAT-1:0] arp_tx_tkeep;
	reg [ARP_HEADER_SIZE-1:0] header_data;
	wire [15:0] ethernet_type_swapped;
	wire [15:0] protocol_type_swapped;
	wire [7:0] hardware_length_swapped;
	wire [7:0] protocol_length_swapped;
	wire [15:0] arp_operation_swapped;
	wire [47:0] sha_swapped;
	wire [31:0] spa_swapped;
	wire [47:0] tha_swapped;
	wire [31:0] tpa_swapped;
	
	// State machine signals
	localparam [7:0] IDLE = 8'h01;
	localparam [7:0] WAIT_FOR_PENDING_CLEAR = 8'h02;
	localparam [7:0] START_DATA_TRANSFER = 8'h04;
	localparam [7:0] WAIT_FOR_ETH_READY = 8'h08;
	localparam [7:0] WAIT_FOR_REQUEST_CLEAR = 8'h10;
	
	reg [7:0] arp_tx_state;
	reg [ARP_HEADER_SIZE-1:0] arp_shift_register;	
	reg [ARP_HEADER_SIZE/8-1:0] tkeep_shift_register;
	reg clear_arp_pending;
	reg arp_data_pending = 0;
	reg arp_data_ready_reg;

	byte_swap #(.WIDTH(16)) ether_type	(.data_in(ethernet_type), .data_out(ethernet_type_swapped));	
	byte_swap #(.WIDTH(16)) protocol	(.data_in(protocol_type), .data_out(protocol_type_swapped));	
	assign hardware_length_swapped = hardware_length;
	assign protocol_length_swapped = protocol_length;
	byte_swap #(.WIDTH(16)) operation  	(.data_in(arp_operation), .data_out(arp_operation_swapped));	
	byte_swap #(.WIDTH(48)) sha  		(.data_in(source_hardware_address), .data_out(sha_swapped));	
	byte_swap #(.WIDTH(32)) spa	 		(.data_in(source_protocol_address), .data_out(spa_swapped));	
	byte_swap #(.WIDTH(48))	tha 		(.data_in(target_hardware_address), .data_out(tha_swapped));	
	byte_swap #(.WIDTH(32))	tpa 		(.data_in(target_protocol_address), .data_out(tpa_swapped));	
	
	assign eth_tx_tvalid = arp_tx_tvalid;
	assign eth_tx_tdata = arp_tx_tdata;
	assign eth_tx_tkeep = arp_tx_tkeep;
	assign eth_tx_tlast = arp_tx_tlast;
	
	generate
		if (BITS_PER_BEAT == ARP_HEADER_SIZE) begin : same_data_size
			always @(posedge clock or reset) begin
				if (reset) begin					
					arp_tx_state		<= IDLE;						   
					arp_data_received	<= 1'b0;						   
					arp_tx_tvalid		<= 1'b0;						   
					arp_tx_tdata		<= 0;							   
					arp_tx_tlast		<= 1'b0;						   
					arp_tx_tkeep		<= 0;							   
					arp_shift_register	<= 0;							   
					tkeep_shift_register<= 0;
					clear_arp_pending	<= 1'b0;
				end
				else begin
					case (arp_tx_state)
						IDLE:
						begin
							arp_data_received	<= 1'b0;

							if (arp_data_pending) begin
								arp_shift_register	<= {tpa_swapped,
														tha_swapped,
														spa_swapped,
														sha_swapped,
														arp_operation_swapped,
														protocol_length_swapped,
														hardware_length_swapped,
														protocol_type_swapped,
														ethernet_type_swapped};
														
								tkeep_shift_register<= {BYTES_PER_HEADER{1'b1}};
								clear_arp_pending	<= 1'b1;
								arp_tx_state		<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR: 
						begin
							if (!arp_data_pending) begin
								clear_arp_pending	<= 1'b0;
								arp_tx_state		<= START_DATA_TRANSFER;
							end
						end
						START_DATA_TRANSFER:
						begin
							arp_tx_tvalid		<= 1'b1;
							arp_tx_tdata		<= arp_shift_register;
							arp_tx_tlast		<= 1'b1;
							arp_tx_tkeep		<= tkeep_shift_register;		
							arp_tx_state		<= WAIT_FOR_ETH_READY;
						end
						WAIT_FOR_ETH_READY:
						begin
							if (eth_tx_tready || arp_data_pending) begin
								arp_tx_tvalid		<= 1'b0;
								arp_tx_tdata		<= 0;
								arp_tx_tlast		<= 1'b0;
								arp_tx_tkeep		<= 0;		
								arp_data_received	<= 1'b1;
								arp_tx_state		<= WAIT_FOR_REQUEST_CLEAR;
							end
						end
						WAIT_FOR_REQUEST_CLEAR:
						begin
							arp_tx_tvalid		<= 1'b0;
							arp_tx_tdata		<= 0;
							arp_tx_tlast		<= 1'b0;
							arp_tx_tkeep		<= 0;	

							if (!arp_data_ready) begin
								arp_data_received	<= 1'b0;
								arp_tx_state		<= IDLE;
							end
						end
						default: arp_tx_state	<= IDLE;
					endcase
				end
			end

			always @(posedge clock) begin
				arp_data_ready_reg	<= arp_data_ready;
				
				if (arp_data_ready && !arp_data_ready_reg) begin
					arp_data_pending	<= 1'b1;
				end
				else if (clear_arp_pending) begin
					arp_data_pending	<= 1'b0;
				end
			end
		end
		else if (BITS_PER_BEAT > ARP_HEADER_SIZE) begin : large_data_size
			always @(posedge clock or reset) begin
				if (reset) begin					
					arp_tx_state		<= IDLE;						   
					arp_data_received	<= 1'b0;						   
					arp_tx_tvalid		<= 1'b0;						   
					arp_tx_tdata		<= 0;							   
					arp_tx_tlast		<= 1'b0;						   
					arp_tx_tkeep		<= 0;							   
					arp_shift_register	<= 0;
					tkeep_shift_register<= 0;
					clear_arp_pending	<= 1'b0;
				end
				else begin
					case (arp_tx_state)
						IDLE:
						begin
							arp_data_received	<= 1'b0;

							if (arp_data_pending) begin
								arp_shift_register	<= {tpa_swapped,
														tha_swapped,
														spa_swapped,
														sha_swapped,
														arp_operation_swapped,
														protocol_length_swapped,
														hardware_length_swapped,
														protocol_type_swapped,
														ethernet_type_swapped};
														
								tkeep_shift_register<= {BYTES_PER_HEADER{1'b1}};
								clear_arp_pending	<= 1'b1;
								arp_tx_state		<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR: 
						begin
							if (!arp_data_pending) begin
								clear_arp_pending	<= 1'b0;
								arp_tx_state		<= START_DATA_TRANSFER;
							end
						end
						START_DATA_TRANSFER:
						begin
							arp_tx_tvalid		<= 1'b1;
							arp_tx_tdata		<= {{PADDING_SIZE{1'b0}}, arp_shift_register};
							arp_tx_tlast		<= 1'b1;
							arp_tx_tkeep		<= {{(PADDING_SIZE/8){1'b0}}, tkeep_shift_register};		
							arp_tx_state		<= WAIT_FOR_ETH_READY;
						end
						WAIT_FOR_ETH_READY:
						begin
							if (eth_tx_tready || arp_data_pending) begin
								arp_tx_tvalid		<= 1'b0;
								arp_tx_tdata		<= 0;
								arp_tx_tlast		<= 1'b0;
								arp_tx_tkeep		<= 0;		
								arp_data_received	<= 1'b1;
								arp_tx_state		<= WAIT_FOR_REQUEST_CLEAR;
							end
						end
						WAIT_FOR_REQUEST_CLEAR:
						begin
							arp_tx_tvalid		<= 1'b0;
							arp_tx_tdata		<= 0;
							arp_tx_tlast		<= 1'b0;
							arp_tx_tkeep		<= 0;	

							if (!arp_data_ready) begin
								arp_data_received	<= 1'b0;
								arp_tx_state		<= IDLE;
							end
						end
						default: arp_tx_state	<= IDLE;
					endcase
				end
			end

			always @(posedge clock) begin
				arp_data_ready_reg	<= arp_data_ready;
				
				if (arp_data_ready && !arp_data_ready_reg) begin
					arp_data_pending	<= 1'b1;
				end
				else if (clear_arp_pending) begin
					arp_data_pending	<= 1'b0;
				end
			end
		end
		else if ((ARP_HEADER_SIZE % BITS_PER_BEAT) == 0) begin : small_data_even
			integer beat_counter;
			
			always @(posedge clock or reset) begin
				if (reset) begin					
					arp_tx_state		<= IDLE;						   
					arp_data_received	<= 1'b0;						   
					arp_tx_tvalid		<= 1'b0;						   
					arp_tx_tdata		<= 0;							   
					arp_tx_tlast		<= 1'b0;						   
					arp_tx_tkeep		<= 0;							   
					arp_shift_register	<= 0;							   
					tkeep_shift_register<= 0;
					beat_counter		<= 0;
					clear_arp_pending	<= 1'b0;
				end
				else begin
					case (arp_tx_state)
						IDLE:
						begin
							arp_data_received	<= 1'b0;

							if (arp_data_pending) begin
								beat_counter		<= 0;
								clear_arp_pending	<= 1'b1;
								arp_shift_register	<= {tpa_swapped,
														tha_swapped,
														spa_swapped,
														sha_swapped,
														arp_operation_swapped,
														protocol_length_swapped,
														hardware_length_swapped,
														protocol_type_swapped,
														ethernet_type_swapped};
														
								tkeep_shift_register<= {BYTES_PER_HEADER{1'b1}};
								arp_tx_state		<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR: 
						begin
							if (!arp_data_pending) begin
								clear_arp_pending	<= 1'b0;
								arp_tx_state		<= START_DATA_TRANSFER;
							end
						end
						START_DATA_TRANSFER:
						begin
							arp_tx_tvalid		<= 1'b1;
							arp_tx_tdata		<= arp_shift_register[BITS_PER_BEAT-1:0];
							arp_shift_register	<= arp_shift_register >> BITS_PER_BEAT;
							arp_tx_tlast		<= 1'b0;
							arp_tx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];		
							tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
							
							if (eth_tx_tready) begin
								beat_counter		<= beat_counter + 1;
							end
							
							arp_tx_state		<= WAIT_FOR_ETH_READY;
						end
						WAIT_FOR_ETH_READY:
						begin
							if (eth_tx_tready) begin
								if (beat_counter < BEATS_PER_TRANSACTION-2) begin
									beat_counter		<= beat_counter + 1;
									arp_tx_tvalid		<= 1'b1;
									arp_tx_tdata		<= arp_shift_register[BITS_PER_BEAT-1:0];
									arp_tx_tlast		<= 1'b0;
									arp_tx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];	
									arp_shift_register	<= arp_shift_register >> BITS_PER_BEAT;
									tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
								end
								else if (beat_counter < BEATS_PER_TRANSACTION-1) begin
									arp_tx_tvalid		<= 1'b1;
									arp_tx_tdata		<= arp_shift_register[BITS_PER_BEAT-1:0];
									arp_tx_tlast		<= 1'b1;
									arp_tx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];
									arp_data_received	<= 1'b1;
									arp_tx_state		<= WAIT_FOR_REQUEST_CLEAR;
								end
							end
						end
						WAIT_FOR_REQUEST_CLEAR:
						begin
							arp_tx_tvalid		<= 1'b0;
							arp_tx_tdata		<= 0;
							arp_tx_tlast		<= 1'b0;
							arp_tx_tkeep		<= 0;	
							
							if (!arp_data_ready) begin
								arp_data_received	<= 1'b0;
								arp_tx_state		<= IDLE;
							end
						end
						default: arp_tx_state	<= IDLE;
					endcase
				end
			end

			always @(posedge clock) begin
				arp_data_ready_reg	<= arp_data_ready;
				
				if (arp_data_ready && !arp_data_ready_reg) begin
					arp_data_pending	<= 1'b1;
				end
				else if (clear_arp_pending) begin
					arp_data_pending	<= 1'b0;
				end
			end
		end
		else if ((ARP_HEADER_SIZE % BITS_PER_BEAT) != 0) begin : small_data_odd
			integer beat_counter;
			
			always @(posedge clock or reset) begin
				if (reset) begin					
					arp_tx_state		<= IDLE;						   
					arp_data_received	<= 1'b0;						   
					arp_tx_tvalid		<= 1'b0;						   
					arp_tx_tdata		<= 0;							   
					arp_tx_tlast		<= 1'b0;						   
					arp_tx_tkeep		<= 0;							   
					arp_shift_register	<= 0;							   
				end
				else begin
					case (arp_tx_state)
						IDLE:
						begin
							arp_data_received	<= 1'b0;

							if (arp_data_pending) begin
								beat_counter		<= 0;
								clear_arp_pending	<= 1'b1;
								arp_shift_register	<= {tpa_swapped,
														tha_swapped,
														spa_swapped,
														sha_swapped,
														arp_operation_swapped,
														protocol_length_swapped,
														hardware_length_swapped,
														protocol_type_swapped,
														ethernet_type_swapped};
														
								tkeep_shift_register<= {BYTES_PER_HEADER{1'b1}};
								arp_tx_state		<= WAIT_FOR_PENDING_CLEAR;
							end
						end
						WAIT_FOR_PENDING_CLEAR: 
						begin
							if (!arp_data_pending) begin
								clear_arp_pending	<= 1'b0;
								arp_tx_state		<= START_DATA_TRANSFER;
							end
						end
						START_DATA_TRANSFER:
						begin
							arp_tx_tvalid		<= 1'b1;
							arp_tx_tdata		<= arp_shift_register[BITS_PER_BEAT-1:0];
							arp_shift_register	<= arp_shift_register >> BITS_PER_BEAT;
							arp_tx_tlast		<= 1'b0;
							arp_tx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];		
							tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
							
							if (eth_tx_tready) begin
								beat_counter		<= beat_counter + 1;
							end
							
							arp_tx_state		<= WAIT_FOR_ETH_READY;
						end
						WAIT_FOR_ETH_READY:
						begin
							if (eth_tx_tready) begin
								if (beat_counter < BEATS_PER_TRANSACTION-2) begin
									beat_counter		<= beat_counter + 1;
									arp_tx_tvalid		<= 1'b1;
									arp_tx_tdata		<= arp_shift_register[BITS_PER_BEAT-1:0];
									arp_tx_tlast		<= 1'b0;
									arp_tx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];	
									arp_shift_register	<= arp_shift_register >> BITS_PER_BEAT;
									tkeep_shift_register<= tkeep_shift_register >> BYTES_PER_BEAT;
								end
								else if (beat_counter < BEATS_PER_TRANSACTION-1) begin
									arp_tx_tvalid		<= 1'b1;
									arp_tx_tdata		<= arp_shift_register[BITS_PER_BEAT-1:0];
									arp_tx_tlast		<= 1'b1;
									arp_tx_tkeep		<= tkeep_shift_register[BYTES_PER_BEAT-1:0];	
									arp_data_received	<= 1'b1;
									arp_tx_state		<= WAIT_FOR_REQUEST_CLEAR;
								end
							end
						end
						WAIT_FOR_REQUEST_CLEAR:
						begin
							arp_tx_tvalid		<= 1'b0;
							arp_tx_tdata		<= 0;
							arp_tx_tlast		<= 1'b0;
							arp_tx_tkeep		<= 0;	
							
							if (!arp_data_ready) begin
								arp_data_received	<= 1'b0;
								arp_tx_state		<= IDLE;
							end
						end
						default: arp_tx_state	<= IDLE;
					endcase
				end
			end

			always @(posedge clock) begin
				arp_data_ready_reg	<= arp_data_ready;
				
				if (arp_data_ready && !arp_data_ready_reg) begin
					arp_data_pending	<= 1'b1;
				end
				else if (clear_arp_pending) begin
					arp_data_pending	<= 1'b0;
				end
			end
		end
	endgenerate
endmodule