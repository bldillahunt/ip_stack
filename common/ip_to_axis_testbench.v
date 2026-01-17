`timescale 1ns/1ps

module fifo_to_axis_testbench;

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

	fifo_to_axis_top #(32, 7) dut0 (clock, reset);
	fifo_to_axis_top #(32, 8) dut1 (clock, reset);
	fifo_to_axis_top #(32, 9) dut2 (clock, reset);
	fifo_to_axis_top #(32, 10) dut3 (clock, reset);
	fifo_to_axis_top #(32, 11) dut4 (clock, reset);
	fifo_to_axis_top #(32, 12) dut5 (clock, reset);
endmodule