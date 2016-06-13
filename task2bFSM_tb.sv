module task2bFSM_tb();
	logic clock, start, finish, s_wren, decrypt_wren;
	logic[7:0] s_q, rom_q, data, address;

	task2bFSM dut(
		.clock(clock),
		.start(start),
		.finish(finish),
		.s_wren(s_wren),
		.decrypt_wren(decrypt_wren),
		.s_q(s_q),
		.rom_q(rom_q),
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
		rom_q = 8'hAF;
		s_q = 7'h12;
		#1;

		start = 1;
		#2;
		start = 0;

		#1300;
		$stop;
	end

endmodule
	
	