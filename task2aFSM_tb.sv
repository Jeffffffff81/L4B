
module task2aFSM_tb();
	logic clock, start;
	logic[7:0] address, data, q;
	logic[23:0] secret_key;
	
	task2aFSM dut(
		.clock(clock),
		.start(start),
		.secret_key(secret_key),
		.q(q),
		.finish(finish),
		.wren(wren),
		.address(address),
		.data(data)
	);
	
	initial begin
		forever begin
			clock = 1; #1;
			clock = 0; #1;
		end
	end

	initial begin
		start = 0;
		secret_key = 24'b00000000_00000000_00000000;
		q = 8'hAF;
		
		#1;

		start = 1;
		#2;
		start = 0;

		#11100;
		$stop;
	end

endmodule
	
	
