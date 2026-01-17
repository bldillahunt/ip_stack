
	function integer tkeep_data_size;
		input integer tkeep_size_in;
		reg [DATA_SIZE/8-1:0] tkeep_data;
		real quotient;
		real product;
		
		begin		
			quotient		<= tkeep_size_in/8;
			product			<= $ceil(quotient);
			tkeep_data_size	<= product * 8;
		end
	endfunction
