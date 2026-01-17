`timescale 1ns/1ps

module header_management_testbench;

	parameter ETH_BITS_PER_BEAT = 8;
	parameter ETH_TOTAL_BYTE_COUNT = 2048;
	parameter ETH_HEADER_SIZE = 112;
	parameter ETH_PIPELINE_DEPTH = 40;				// Maximum number of clock cycles between tvalid and tready

	parameter IP_BITS_PER_BEAT = 512;
	parameter IP_TOTAL_BYTE_COUNT = 64;
	parameter IP_HEADER_SIZE = 160;
	parameter IP_PIPELINE_DEPTH = 8;				// Maximum number of clock cycles between tvalid and tready

	parameter UDP_BITS_PER_BEAT = 16;
	parameter UDP_TOTAL_BYTE_COUNT = 128;
	parameter UDP_HEADER_SIZE = 64;
	parameter UDP_PIPELINE_DEPTH = 32;				// Maximum number of clock cycles between tvalid and tready

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
	header_management #(ETH_BITS_PER_BEAT, ETH_TOTAL_BYTE_COUNT, ETH_HEADER_SIZE, ETH_PIPELINE_DEPTH) dut_eth (clock, reset);
	
	// IPv4 header, bit depth < header size, not evenly divisible
	header_management #(IP_BITS_PER_BEAT, IP_TOTAL_BYTE_COUNT, IP_HEADER_SIZE, IP_PIPELINE_DEPTH) dut_ip (clock, reset);
	
	// UDP header, bit depth > header size, evenly divisible
	header_management #(UDP_BITS_PER_BEAT, UDP_TOTAL_BYTE_COUNT, UDP_HEADER_SIZE, UDP_PIPELINE_DEPTH) dut_udp (clock, reset);
	
endmodule
