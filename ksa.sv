`default_nettype none

module ksa(
	CLOCK_50,
	KEY,
	SW,
	LEDR,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5
);

	//////////// CLOCK //////////
	input logic                      CLOCK_50;

	//////////// KEY //////////
	input logic           [3:0]      KEY;

	//////////// SW //////////
	input logic           [9:0]      SW;

	//////////// LED //////////
	output  logic         [9:0]      LEDR;

	//////////// SEG7 //////////
	output   logic        [6:0]      HEX0;
	output   logic        [6:0]      HEX1;
	output   logic        [6:0]      HEX2;
	output   logic        [6:0]      HEX3;
	output   logic        [6:0]      HEX4;
	output   logic        [6:0]      HEX5;

	/*
	 * General wires:
	 */
	logic clk;
	assign clk = CLOCK_50;
	logic halt;
	assign halt = found_1 || found_2 || found_3 || found_4;
	assign LEDR[1] = not_found_1 || not_found_2 || not_found_3 || not_found_4;
	assign LEDR[0] = found_1 || found_2 || found_3 || found_4;

	logic[23:0] display_key;
	always_comb begin
		if(found_1)
			display_key = key_1;
		else if(found_2)
			display_key = key_2;
		else if(found_3)
			display_key = key_3;
		else if(found_4)
			display_key = key_4;
		else
			display_key = 24'h00_00_00;
	end
	/*
         * Each of the cores and their wires:
         * and their memory which they work on
         */
	//*****************CORE 1*****************//
	wire found_1, not_found_1;
	wire[23:0] key_1;
	wire s_wren_1, decrypt_wren_1;
	wire[7:0] s_data_1, s_q_1, s_address_1, decrypt_data_1, decrypt_q_1, rom_q_1;
	wire[4:0] decrypt_address_1, rom_address_1;
	task3FSM core1(
		.clock(clk),
		.halt(halt),
		.found(found_1),
		.not_found(not_found_1),
		.display_key(key_1),
		.s_q(s_q_1),
		.rom_q(rom_q_1),
		.decrypt_q(decrypt_q_1),
		.s_address(s_address_1),
		.s_data(s_data_1),
		.s_wren(s_wren_1),
		.rom_address(rom_address_1),
		.decrypt_address(decrypt_address_1),
		.decrypt_data(decrypt_data_1),
		.decrypt_wren(decrypt_wren_1)
	);

	s_memory working_memory_1(
		.clock(clk),
		.address(s_address_1),
		.data(s_data_1),
		.q(s_q_1),
		.wren(s_wren_1)
	);

	rom_memory encrypted_message_1 (
		.clock(clk),
		.address(rom_address_1),
		.q(rom_q_1)
	);

	s_memory decrypted_message_1(
		.clock(clk),
		.address(decrypt_address_1),
		.data(decrypt_data_1),
		.q(decrypt_q_1),
		.wren(decrypt_wren_1)
	);

	//*****************CORE 2*****************//
	wire found_2, not_found_2;
	wire[23:0] key_2;
	wire s_wren_2, decrypt_wren_2;
	wire[7:0] s_data_2, s_q_2, s_address_2, decrypt_data_2, decrypt_q_2, rom_q_2;
	wire[4:0] decrypt_address_2, rom_address_2;
	task3FSM core2(
		.clock(clk),
		.halt(halt),
		.found(found_2),
		.not_found(not_found_2),
		.display_key(key_2),
		.s_q(s_q_2),
		.rom_q(rom_q_2),
		.decrypt_q(decrypt_q_2),
		.s_address(s_address_2),
		.s_data(s_data_2),
		.s_wren(s_wren_2),
		.rom_address(rom_address_2),
		.decrypt_address(decrypt_address_2),
		.decrypt_data(decrypt_data_2),
		.decrypt_wren(decrypt_wren_2)
	);

	s_memory working_memory_2(
		.clock(clk),
		.address(s_address_2),
		.data(s_data_2),
		.q(s_q_2),
		.wren(s_wren_2)
	);

	rom_memory encrypted_message_2 (
		.clock(clk),
		.address(rom_address_2),
		.q(rom_q_2)
	);

	s_memory decrypted_message_2(
		.clock(clk),
		.address(decrypt_address_2),
		.data(decrypt_data_2),
		.q(decrypt_q_2),
		.wren(decrypt_wren_2)
	);

	//*****************CORE 3*****************//
	wire found_3, not_found_3;
	wire[23:0] key_3;
	wire s_wren_3, decrypt_wren_3;
	wire[7:0] s_data_3, s_q_3, s_address_3, decrypt_data_3, decrypt_q_3, rom_q_3;
	wire[4:0] decrypt_address_3, rom_address_3;
	task3FSM core3(
		.clock(clk),
		.halt(halt),
		.found(found_3),
		.not_found(not_found_3),
		.display_key(key_3),
		.s_q(s_q_3),
		.rom_q(rom_q_3),
		.decrypt_q(decrypt_q_3),
		.s_address(s_address_3),
		.s_data(s_data_3),
		.s_wren(s_wren_3),
		.rom_address(rom_address_3),
		.decrypt_address(decrypt_address_3),
		.decrypt_data(decrypt_data_3),
		.decrypt_wren(decrypt_wren_3)
	);

	s_memory working_memory_3(
		.clock(clk),
		.address(s_address_3),
		.data(s_data_3),
		.q(s_q_3),
		.wren(s_wren_3)
	);

	rom_memory encrypted_message_3 (
		.clock(clk),
		.address(rom_address_3),
		.q(rom_q_3)
	);

	s_memory decrypted_message_3(
		.clock(clk),
		.address(decrypt_address_3),
		.data(decrypt_data_3),
		.q(decrypt_q_3),
		.wren(decrypt_wren_3)
	);

	//*****************CORE 4*****************//
	wire found_4, not_found_4;
	wire[23:0] key_4;
	wire s_wren_4, decrypt_wren_4;
	wire[7:0] s_data_4, s_q_4, s_address_4, decrypt_data_4, decrypt_q_4, rom_q_4;
	wire[4:0] decrypt_address_4, rom_address_4;
	task3FSM core4(
		.clock(clk),
		.halt(halt),
		.found(found_4),
		.not_found(not_found_4),
		.display_key(key_4),
		.s_q(s_q_4),
		.rom_q(rom_q_4),
		.decrypt_q(decrypt_q_4),
		.s_address(s_address_4),
		.s_data(s_data_4),
		.s_wren(s_wren_4),
		.rom_address(rom_address_4),
		.decrypt_address(decrypt_address_4),
		.decrypt_data(decrypt_data_4),
		.decrypt_wren(decrypt_wren_4)
	);

	s_memory working_memory_4(
		.clock(clk),
		.address(s_address_4),
		.data(s_data_4),
		.q(s_q_4),
		.wren(s_wren_4)
	);

	rom_memory encrypted_message_4 (
		.clock(clk),
		.address(rom_address_4),
		.q(rom_q_4)
	);

	s_memory decrypted_message_4(
		.clock(clk),
		.address(decrypt_address_4),
		.data(decrypt_data_4),
		.q(decrypt_q_4),
		.wren(decrypt_wren_4)
	);
	//*********************************//


	/*
	 * Seven Segment Displays
	 */	 
	 SevenSegmentDisplayDecoder byte_0a(
		.nIn(display_key[3:0]),
		.ssOut(HEX0)
	 );
	 
	 SevenSegmentDisplayDecoder byte_0b(
		.nIn(display_key[7:4]),
		.ssOut(HEX1)
	 );
	 
	 SevenSegmentDisplayDecoder byte_1a(
		.nIn(display_key[11:8]),
		.ssOut(HEX2)
	 );
	 
	 SevenSegmentDisplayDecoder byte_1b(
		.nIn(display_key[15:12]),
		.ssOut(HEX3)
	 );
	 
	SevenSegmentDisplayDecoder byte_2a(
		.nIn(display_key[19:16]),
		.ssOut(HEX4)
	 );
	 
	 SevenSegmentDisplayDecoder byte_2b(
		.nIn(display_key[23:20]),
		.ssOut(HEX5)
	 );

	//***************************************//

	 
	
endmodule