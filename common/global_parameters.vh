`define TRUE 1'b1
`define FALSE 1'b0
`define ETHERNET_HEADER_SIZE 112
`define ARP_HEADER_SIZE 224
`define IP_HEADER_SIZE 160
`define UDP_PROTOCOL 8'h11
`define ICMP_PROTOCOL 8'h01
`define TCP_PROTOCOL 8'h06
`define CHECKSUM_SIZE 16

module checksum_calculation(checksum_data_in, checksum_data_out);
	parameter CHECKSUM_DATA_SIZE = 16;
	parameter CHECKSUM_ARRAY_SIZE = 10;
	
	input [CHECKSUM_DATA_SIZE-1:0] checksum_data_in;
	output [CHECKSUM_DATA_SIZE-1:0] checksum_data_out;
	
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
	//			$display("input = %04H\n", addend_data[i*CHECKSUM_DATA_SIZE +: CHECKSUM_DATA_SIZE]);			
			end

	//		$display("primary sum = %08H\n", primary_sum);			

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
	
	assign  checksum_data_out = checksum_16bit(checksum_data_in);
endmodule