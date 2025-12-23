module ethernet_receiver (reset, clock, temac_rx_tvalid, temac_rx_tdata, temac_rx_tlast, temac_rx_tuser, temac_rx_filter_tuser, ip_rx_tready, ip_rx_tvalid, ip_rx_tdata, ip_rx_tlast, arp_rx_tready, arp_rx_tvalid, arp_rx_tdata, arp_rx_tlast, temac_address, received_mac_address, valid_mac_address);
	// Parameters
	parameter DATA_WIDTH				= 8;							// The size of one octet
	parameter BITS_PER_BEAT				= 512;							// The number of bits per beat of data
	parameter BYTES_PER_BEAT			= BITS_PER_BEAT/DATA_WIDTH;		// The number of bytes to process on each clock cycle
	parameter HEADER_BYTE_COUNT			= 14;
	parameter JUMBO_FRAME_SIZE			= 8192;							// Number of bytes in a jumbo frame
	parameter MAXIMUM_STORAGE_SIZE		= JUMBO_FRAME_SIZE/(BITS_PER_BEAT/DATA_WIDTH);	// Size of the FIFO
	parameter BROADCAST_MAC_ADDRESS		= 48'hFFFFFFFFFFFF;
	
	localparam MAC_ADDRESS_BYTE_COUNT	= 6;
	localparam MAC_SHIFT_COUNT			= MAC_ADDRESS_BYTE_COUNT/BYTES_PER_BEAT;
	localparam MAC_ADDRESS_SIZE			= (DATA_WIDTH * MAC_ADDRESS_BYTE_COUNT);
	localparam MAC_ADDRESS_LEFT_OVER 	= MAC_ADDRESS_SIZE - BITS_PER_BEAT;
	localparam LEFT_OVER_BYTES			= MAC_ADDRESS_LEFT_OVER/DATA_WIDTH;
	localparam LOWER_MAC_BYTES			= MAC_ADDRESS_BYTE_COUNT - MAC_ADDRESS_LEFT_OVER_BYTES;
	localparam ETHER_TYPE_BYTE_COUNT	= 2;
	localparam ETHER_TYPE_SIZE			= (DATA_WIDTH * ETHER_TYPE_BYTE_COUNT);
	localparam ETHERNET_HEADER_SIZE		= (2*MAC_ADDRESS_SIZE + ETHER_TYPE_SIZE);
	localparam SOURCE_ADDRESS_OFFSET	= MAC_ADDRESS_BYTE_COUNT;
	localparam DEST_ADDRESS_OFFSET		= 2*MAC_ADDRESS_BYTE_COUNT;
	localparam ETHER_TYPE_OFFSET		= (DEST_ADDRESS_OFFSET + ETHER_TYPE_BYTE_COUNT);
	localparam ARP_HEADER_TYPE			= 16'h0806;
	localparam IP_HEADER_TYPE			= 16'h0800;

	// Local parameters
	localparam INPUT_BUFFER_BYTE_COUNT = HEADER_BYTE_COUNT;
	localparam INPUT_BUFFER_SIZE = DATA_WIDTH * INPUT_BUFFER_BYTE_COUNT;
	
	// I/O ports
	input reset;
	input clock;
	input temac_rx_tvalid;
	input [DATA_WIDTH-1:0] temac_rx_tdata;
	input temac_rx_tlast;
	input [0:0] temac_rx_tuser;
	input temac_rx_filter_tuser;
	input ip_rx_tready;
	output ip_rx_tvalid;
	output [DATA_WIDTH-1:0] ip_rx_tdata;
	output ip_rx_tlast;
	input arp_rx_tready;
	output arp_rx_tvalid;
	output [DATA_WIDTH-1:0] arp_rx_tdata;
	output arp_rx_tlast;
	input [47:0] temac_address;
	output reg [47:0] received_mac_address;
	output reg valid_mac_address;
	
	generic_fifo #(BITS_PER_BEAT, MAXIMUM_STORAGE_SIZE) input_storage (clock, reset, fifo_write_enable, fifo_data_in, fifo_read_enable, fifo_data_out, fifo_data_valid, fifo_empty, fifo_full);
	// Input side registers
	
	always @(posedge clock) begin
		// Store the AXIS bus data in a generic FIFO
		if (!fifo_full) begin
			fifo_write_enable	<= temac_rx_tvalid;
			fifo_data_in		<= temac_rx_tdata;
		end
		else begin
			fifo_write_enable	<= 0;
			fifo_data_in		<= 0;
		end
	end
	
	
	always @(posedge clock or reset) begin
		if (reset) begin
			ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
		end
		else begin
			case (ethernet_receive_state)
				WAIT_FOR_ETHERNET_DATA:
				begin
				end
				TRANSMIT_PAYLOAD:
				begin
					
				end
				default : ethernet_receive_state	<= WAIT_FOR_ETHERNET_DATA;
			endcase
		end
	end
endmodule
