module task3FSM_tb();
	logic clock, found, not_found, s_wren, decrypt_wren; 
	logic[23:0] display_key;
	logic[7:0] s_address, s_data, decrypt_data, s_q, rom_q, decrypt_q;
	logic[4:0] decrypt_address, rom_address;

	task3FSM dut(
		.clock(clock),
		.found(found),
		.not_found(not_found),
		.s_wren(s_wren),
		.decrypt_wren(decrypt_wren),
		.display_key(display_key),
		.s_address(s_address),
		.s_data(s_data),
		.rom_address(rom_address),
		.decrypt_address(decrypt_address),
		.decrypt_data(decrypt_data),
		.s_q(s_q),
		.rom_q(rom_q),
		.decrypt_q(decrypt_q)
	);
	
	initial begin
		forever begin
			clock = 1; #1;
			clock = 0; #1;
		end
	end

	initial begin
		s_q = 0;
		rom_q = 0;
		decrypt_q = 99;
		#10000;
		$stop;
	end
endmodule
