`default_nettype none

/*
 * This will (try) to decrypt the message stored in "encrypted rom", and output
 * the result to "decrypted ram". It uses the "s ram". Note: message_length is 32
 * for us.
 * 
 * int i, j = 0;
 * 
 * for(int k = 0; k < message_length; k++) {
 *   i = (i+1) % 256;
 *   j = (j + s[i]) % 256;
 *   swap(s[i], s[j]);
 *   f = s[(s[i]+s[j]) % 256];
 *   decrypted_output[k] = f XOR rom[k] //8 bit wide XOR
 * }
 *
 *
 * Inputs:   clock: the clock it runs on
 *           start: tells it to start decrypting
 *           s_q: data from s_ram
 *	     rom_q: data from rom
 * 
 * Outputs   finish: pulsed when FSM is done
 *           s_wren: set when we want to write 'data' to s_RAM
 *           decrypt_wren: set when we want to write 'data' to decrypted RAM.
 *           data: data output
 *           address: address output
 */
module task2bFSM(clock, start, finish, s_q, rom_q, s_wren, decrypt_wren, data, address);
	parameter MESSAGE_LENGTH = 32; //DEBUG
	
	input logic clock, start;
	input logic[7:0] s_q, rom_q;

	output logic finish, s_wren, decrypt_wren;
	output logic[7:0] data, address;

	//internal wires:
	logic[7:0] i, j, si, sj, k, f;
	logic enable_f, enable_i, enable_j, enable_si, enable_sj, k_inc, k_reset, i_reset, j_reset;
	logic[1:0] address_to_use, data_to_use;

	//The counter, which goes up to MESSAGE_LENGTH
	always_ff @(posedge clock) begin
		if(k_reset || finish)
			k <= 0;
		else if (k_inc)
			k <= k + 8'd1;
		else if (k == MESSAGE_LENGTH)
			k <= 0;
		else
			k <= k;
	end

	//remember i:
	always_ff @(posedge clock) begin
		if (i_reset || finish)
			i <= 0;
		else if (enable_i) 
			i <= (i+1);
		else
			i <= i;
	end

	//remember j:
	always_ff @(posedge clock) begin
		if (j_reset || finish)
			j <= 0;
		else if (enable_j) 
			j <= (j+si);
		else
			j <= j;
	end

	//remember si:
	always_ff @(posedge clock) begin
		if (finish)
			si <= 0;
		else if (enable_si) 
			si <= s_q; //ensure address is set to i
		else
			si <= si;
	end

	//remember sj:
	always_ff @(posedge clock) begin
		if (finish)
			sj <= 0;
		else if (enable_sj) 
			sj <= s_q; //ensure address is set to j
		else
			sj <= sj;
	end

	//remember f:
	always_ff @(posedge clock) begin
		if (finish)
			f <= 0;
		else if (enable_f)
			f <= s_q; //address should be (si + sj)%256
		else
			f <= f;		
	end

//{state bits},{finish},{enable_f},{enable_i},{enable_j},{enable_si},{enable_sj},{k_inc},{k_reset},{i_reset},{j_reset},{address},{data},{s_wren},{decrypt_wren}
	reg[20:0] state = 21'b0;
	parameter idle                    = 21'b00000_0_0_0_0_0_0_0_0_0_0_00_00_0_0;
	parameter initialize              = 21'b00001_0_0_0_0_0_0_0_1_1_1_00_00_0_0;
	parameter check_if_done           = 21'b00010_0_0_0_0_0_0_0_0_0_0_00_00_0_0;
	parameter get_i                   = 21'b00011_0_0_1_0_0_0_0_0_0_0_00_00_0_0;
	parameter set_addr_to_i           = 21'b00100_0_0_0_0_0_0_0_0_0_0_00_00_0_0;
	parameter get_si                  = 21'b00101_0_0_0_0_1_0_0_0_0_0_00_00_0_0;
	parameter get_j                   = 21'b00110_0_0_0_1_0_0_0_0_0_0_00_00_0_0;
	parameter set_addr_to_j           = 21'b00111_0_0_0_0_0_0_0_0_0_0_01_00_0_0;
	parameter get_sj                  = 21'b01000_0_0_0_0_0_1_0_0_0_0_01_00_0_0;
	//begin swap:
	parameter si_gets_sj_1            = 21'b01001_0_0_0_0_0_0_0_0_0_0_00_01_0_0;
	parameter si_gets_sj_2            = 21'b01010_0_0_0_0_0_0_0_0_0_0_00_01_1_0;
	parameter sj_gets_si_1            = 21'b01011_0_0_0_0_0_0_0_0_0_0_01_00_0_0;
	parameter sj_gets_si_2            = 21'b01100_0_0_0_0_0_0_0_0_0_0_01_00_1_0;
	//end swap
	parameter set_addr_to_si_plus_sj  = 21'b01101_0_0_0_0_0_0_0_0_0_0_10_00_0_0;
	parameter get_f                   = 21'b01110_0_1_0_0_0_0_0_0_0_0_10_00_0_0;
	parameter set_addr_and_data_final = 21'b01111_0_0_0_0_0_0_0_0_0_0_11_10_0_0;
	parameter output_decrypt          = 21'b10000_0_0_0_0_0_0_0_0_0_0_11_10_0_1;
	parameter inc_k                   = 21'b10001_0_0_0_0_0_0_1_0_0_0_00_00_0_0;

	parameter finished                = 21'b10010_1_0_0_0_0_0_0_0_0_0_00_00_0_0;

	//output logic and internal wires:
	assign decrypt_wren = state[0];
	assign s_wren = state[1];
	assign j_reset = state[6];
	assign i_reset = state[7];
	assign k_reset = state[8];
	assign k_inc = state[9];
	assign enable_sj = state[10];
	assign enable_si = state[11];
	assign enable_j = state[12];
	assign enable_i = state[13];
	assign enable_f = state[14];
	assign finish = state[15];

	always_comb begin
		case(state[5:4]) 
			2'b00: address = i;
			2'b01: address = j;
			2'b10: address = (si + sj) % 256;
			2'b11: address = k;
		endcase
	end

	always_comb begin
		case(state[3:2])
			2'b00: data = si;
			2'b01: data = sj;
			2'b10: data = f ^ rom_q; //address should be k for this
			default: data = 0;
		endcase
	end

	//next state logic:
	always_ff @(posedge clock) begin
		case (state)
			idle:                   state <= (start) ? initialize : idle;
			initialize:             state <= check_if_done;
			check_if_done:          state <= (k < MESSAGE_LENGTH) ? get_i : finished; //DEBUG
			get_i:                  state <= set_addr_to_i;
			set_addr_to_i:          state <= get_si;
			get_si:                 state <= get_j;
			get_j:                  state <= set_addr_to_j;
			set_addr_to_j:          state <= get_sj;
			get_sj:                 state <= si_gets_sj_1;
			si_gets_sj_1:           state <= si_gets_sj_2;
			si_gets_sj_2:           state <= sj_gets_si_1;
			sj_gets_si_1:           state <= sj_gets_si_2;
			sj_gets_si_2:           state <= set_addr_to_si_plus_sj;
			set_addr_to_si_plus_sj: state <= get_f;
			get_f:                  state <= set_addr_and_data_final;
			set_addr_and_data_final:state <= output_decrypt;
			output_decrypt:         state <= inc_k;
			inc_k:                  state <= check_if_done;
			default:                state <= idle;
		endcase
	end

endmodule