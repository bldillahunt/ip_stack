`timescale 1ns/1ps

module header_management_testbench;

	parameter ETH_BITS_PER_BEAT = 32;
	parameter ETH_TOTAL_BYTE_COUNT = 16;
	parameter ETH_HEADER_SIZE = 112;

	parameter IP_BITS_PER_BEAT = 64;
	parameter IP_TOTAL_BYTE_COUNT = 16;
	parameter IP_HEADER_SIZE = 160;

	parameter UDP_BITS_PER_BEAT = 128;
	parameter UDP_TOTAL_BYTE_COUNT = 16;
	parameter UDP_HEADER_SIZE = 64;

	reg clock;
	reg reset;

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
	
	// Ethernet header, bit depth < header size, not evenly divisible
	header_management #(ETH_BITS_PER_BEAT, ETH_TOTAL_BYTE_COUNT, ETH_HEADER_SIZE) dut_eth (clock, reset);
	
	// IPv4 header, bit depth < header size, not evenly divisible
	header_management #(IP_BITS_PER_BEAT, IP_TOTAL_BYTE_COUNT, IP_HEADER_SIZE) dut_ip (clock, reset);
	
	// UDP header, bit depth > header size, evenly divisible
	header_management #(UDP_BITS_PER_BEAT, UDP_TOTAL_BYTE_COUNT, UDP_HEADER_SIZE) dut_udp (clock, reset);
	
endmodule
