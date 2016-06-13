`default_nettype none

/*
 * This FSM will decrypt the message stored in ROM, and output it to the decrypted RAM. 
 * It uses a 8x256 working RAM. 
 *
 * Inputs:   clock: the clock which this FSM runs on.
 *           halt: tells the FSM to stop
 *           s_q: data from the working s_RAM
 *           rom_q: data from the ROM (which contains the secret message)
 *           decrypt_q: data from the RAM which contains the decrpyted message
 * 
 * Outputs:  found: set if the message is cracked
 *           not_found: set if message could not be cracked
 *           display_key: the key which is currently being tried.
 *           s_address: the address into s_RAM
 *           s_data: the data to be given to s_RAM
 *           s_wren: write enable for s_RAM
 *           rom_address: the address we want to read from ROM
 *           decrypt_address: the address we want to read or write to the decrypted output RAM
 *           decrypt_data: the data we want to write to decrypted output RAM
 *           decryt_wren: write enable for decrypted output RAM
 */
module task3FSM(clock, halt, found, not_found, display_key, 
s_address, s_data, s_q, s_wren, rom_address, rom_q, decrypt_address, decrypt_data, decrypt_q, decrypt_wren);
	parameter MIN_KEY = 24'h00_00_00;
	parameter MAX_KEY = 24'h3F_FF_FF; //two MSB's are 0.

	input logic clock, halt;

	output logic found, not_found;
	output logic [23:0] display_key;

	output logic [7:0] s_address, s_data, decrypt_data;
	output logic [4:0] rom_address, decrypt_address;
	output logic s_wren, decrypt_wren;
	input logic [7:0] s_q, rom_q, decrypt_q;
	
	//internal wires:
	logic [23:0] key;
	logic reset; 
	logic key_inc;
	logic start_setup, start_scramble, start_decode, start_check;
	logic finish_setup, finish_scramble, finish_decode, finish_check;
	logic enable_found, enable_not_found;
	logic valid;
	
	//logic for the key:
	always_ff @(posedge clock) begin
		if(reset)
			key <= 24'b0;
		else if (key_inc)
			key <= key + 1;
		else
			key <= key;
 	end

	//remember found:
	always_ff @(posedge clock) begin
		if(reset)
			found <= 0;	
		else if (enable_found)
			found <= 1;
		else
			found <= found;
	end
	//remember not_found:
	always_ff @(posedge clock) begin
		if(reset)
			not_found <= 0;	
		else if (enable_not_found)
			not_found <= 1;
		else
			not_found <= not_found;
	end

	//sub modules:
	logic [7:0] task1_data, task1_address;
	logic task1_s_wren;
	task1FSM setup(
		.clock(clock),
		.start(start_setup),
		.finish(finish_setup),
		.data(task1_data),
		.wren(task1_s_wren),
		.address(task1_address)
	);

	logic [7:0] task2a_data, task2a_address;
	logic task2a_s_wren;
	task2aFSM scramble(
		.clock(clock),
		.start(start_scramble),
		.finish(finish_scramble),
		.secret_key(key),
		.q(s_q),
		.wren(task2a_s_wren),
		.address(task2a_address),
		.data(task2a_data)
	);

	logic [7:0] task2b_address, task2b_data;
	logic task2b_s_wren, task2b_decrypt_wren;
	task2bFSM decode(
		.clock(clock),
		.start(start_decode),
		.finish(finish_decode),
		.s_q(s_q),
		.rom_q(rom_q),
		.s_wren(task2b_s_wren),
		.decrypt_wren(task2b_decrypt_wren),
		.address(task2b_address),
		.data(task2b_data)
	);

	logic [4:0] check_address;
	checkASCII check(
		.clock(clock),
		.start(start_check),
		.finish(finish_check),
		.ram_address(check_address),
		.ram_q(decrypt_q),
		.valid(valid)
	);
	
//state encoding: {state bits},{finish},{found_enable},{not_found_enable},{reset},{key_inc},{start_setup},{start_scramble},{start_decode},{start_check}
	reg [12:0] state = 13'b0;
	parameter s_idle           = 14'b00000_0_0_0_0_0_0_0_0;
	parameter s_initialize     = 14'b00001_0_0_1_0_0_0_0_0;
	parameter s_start_setup    = 14'b00010_0_0_0_0_1_0_0_0;
	parameter s_wait_setup     = 14'b00011_0_0_0_0_0_0_0_0;
	parameter s_start_scramble = 14'b00100_0_0_0_0_0_1_0_0;
	parameter s_wait_scramble  = 14'b00101_0_0_0_0_0_0_0_0;
	parameter s_start_decode   = 14'b00110_0_0_0_0_0_0_1_0;
	parameter s_wait_decode    = 14'b00111_0_0_0_0_0_0_0_0;
	parameter s_start_check    = 14'b01000_0_0_0_0_0_0_0_1;
	parameter s_wait_check     = 14'b01001_0_0_0_0_0_0_0_0;
	parameter s_is_it_valid    = 14'b01010_0_0_0_0_0_0_0_0;
	parameter s_is_key_lt_max  = 14'b01011_0_0_0_0_0_0_0_0;
	parameter s_inc_key        = 14'b01100_0_0_0_1_0_0_0_0;
	parameter s_not_found      = 14'b01101_0_1_0_0_0_0_0_0;
	parameter s_found          = 14'b01110_1_0_0_0_0_0_0_0;
	parameter s_finished       = 14'b01111_0_0_0_0_0_0_0_0;
	parameter s_done           = 14'b10000_0_0_0_0_0_0_0_0;

	//output logic/internal wire logic
	assign start_check = state[0];
	assign start_decode = state[1];
	assign start_scramble = state[2];
	assign start_setup = state[3];
	assign key_inc = state[4];
	assign reset = state[5];
	assign enable_not_found = state[6];
	assign enable_found = state[7];

	assign display_key = key;
	assign s_wren = task1_s_wren | task2a_s_wren | task2b_s_wren;
	assign decrypt_wren = task2b_decrypt_wren;
	assign s_data = task1_data | task2a_data | task2b_data;
	assign decrypt_data = task2b_data;
	assign s_address = task1_address | task2a_address | task2b_address;
	assign rom_address = task2b_address[4:0];
	assign decrypt_address = task2b_address[4:0] | check_address;

	//next state logic:
	always_ff @(posedge clock) begin
	if(halt)
		state <= s_done;
	else begin
		case (state)
			s_idle:            state <= s_initialize;
			s_initialize:      state <= s_start_setup;
			s_start_setup:     state <= s_wait_setup;    
                        s_wait_setup:      state <= (finish_setup)? s_start_scramble : s_wait_setup;
			s_start_scramble:  state <= s_wait_scramble;
			s_wait_scramble:   state <= (finish_scramble)? s_start_decode : s_wait_scramble;
			s_start_decode:    state <= s_wait_decode;
			s_wait_decode:     state <= (finish_decode)? s_start_check : s_wait_decode;
			s_start_check:     state <= s_wait_check;
			s_wait_check:      state <= (finish_check)? s_is_it_valid: s_wait_check;
			s_is_it_valid:     state <= (valid)? s_found : s_is_key_lt_max;
			s_found:           state <= s_done;
			s_is_key_lt_max:   state <= (key <= MAX_KEY)? s_inc_key : s_not_found;
			s_inc_key:         state <= s_start_setup;
			s_not_found:       state <= s_done;
			s_done:            state <= s_done;
			default:           state <= s_idle;
		endcase
	end
	end
endmodule
