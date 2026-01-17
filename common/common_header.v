`define TRUE = 1'b1;
`define FALSE = 1'b0;

module common_header (tkeep_size_in, tkeep_size_out);
	input tkeep_size_in;
	output integer tkeep_size_out;
	
	function integer tkeep_data_size;
		input tkeep_size_in;
		real quotient;
		real product;
		
		begin		
			quotient		= tkeep_size_in/8;
			product			= $ceil(quotient);
			tkeep_data_size	= product * 8;
		end
	endfunction
	
	always @* begin
		tkeep_size_out = tkeep_data_size(tkeep_size_in);
	end
endmodule
