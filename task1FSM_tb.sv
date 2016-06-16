module task1FSM_tb();
	logic clock, start;
	logic wren, finish;
	logic [7:0] data, address;

	task1FSM dut(
		.clock(clock),
		.start(start),
		.wren(wren),
		.finish(finish),
		.data(data),
		.address(address)
	);
	
	initial begin
		forever begin
			clock = 1; #1;
			clock = 0; #1;
		end
	end
	
	initial begin
		start = 0;
		#5;
		start = 1;
		#2;
		start = 0;
		#100;
		$stop;
	end

endmodule