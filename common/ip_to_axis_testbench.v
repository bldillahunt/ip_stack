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

	fifo_to_axis_top #(32, 1) dut0 (clock, reset);
	fifo_to_axis_top #(32, 2) dut1 (clock, reset);
	fifo_to_axis_top #(32, 3) dut2 (clock, reset);
	fifo_to_axis_top #(32, 4) dut3 (clock, reset);
	fifo_to_axis_top #(32, 5) dut4 (clock, reset);
	fifo_to_axis_top #(32, 6) dut5 (clock, reset);
endmodule