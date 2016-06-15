`default_nettype none

/*
 * This FSM will scramble the contents of s_RAM.
 * 
 * int j = 0;
 * for(int i = 0; i < 256; i++) {
 *   j = (j + s[i] + secret_key[i%3]) % 256;
 *   swap(s[i],s[j]);
 * }
 *
 * Inputs:   clock: the clock it runs on
 *           start: tells it to start scrambling
 *           secret_key: the secret key. Used to pseudo-randomize the RAM.
 *           q: data from s_RAM
 *           
 * Outputs   finish: pulsed when FSM is done
 *           wren: set when we want to write 'data' to s_RAM
 *           address: the address into s_RAM
 *           data: data to be written to s_RAM
 */
module task2aFSM(clock, start, finish, secret_key, wren, data, address, q);
	input logic clock, start;
	input logic[23:0] secret_key;
	input logic[7:0] q;

	output logic finish, wren;
	output logic[7:0] address, data;

	//internal wires:
	reg [7:0] j, si, sj;
	reg [8:0] i;
	logic enable_j, enable_si, enable_sj, i_inc, i_reset, j_reset, address_use_i, data_use_si;

	//counter. outputs i:
	always_ff @(posedge clock) begin
		if(i_reset || finish)
			i <= 0;
		else if(i_inc)
			i <= i + 1;
		else if (i == 9'b1_0000_0000)
			i <= 0;
		else	
			i <= i;
	end

	//logic for calculating j
	always_ff @(posedge clock) begin
		if(j_reset || finish)
			j <= 0;
		else if (enable_j) begin
			if(i%3 == 2)
				j <= (j + si + secret_key[7:0]);
			else if(i%3 == 1)
				j <= (j + si + secret_key[15:8]);
			else
				j <= (j + si + secret_key[23:16]);
		end
		else
			j <= j;
	end

	//logic for calculating si
	always_ff @(posedge clock) begin
		if (finish)
			si <= 0;
		else if (enable_si) 
			si <= q;
		else
			si <= si;
	end

	//logic for calculating sj
	always_ff @(posedge clock) begin
		if (finish)
			sj <= 0;
		else if (enable_sj) 
			sj <= q;
		else
			sj <= sj;
	end
		

//state encoding: {state bits}, {finish}, {enable_j}, {enable_si}, {enable_sj}, {i_inc}, {i_reset}, {j_reset}, {data_use_i}, {address_use_si}, {wren}
	reg[13:0] state = 0;
	parameter idle          = 14'b0000_0_0_0_0_0_0_0_0_0_0;
	parameter initialize    = 14'b0001_0_0_0_0_0_1_1_0_0_0;
	parameter check_if_done = 14'b0010_0_0_0_0_0_0_0_0_0_0;
	parameter get_si_1      = 14'b0011_0_0_0_0_0_0_0_0_1_0;
	parameter get_si_2      = 14'b0100_0_0_1_0_0_0_0_0_1_0;
	parameter calc_j        = 14'b0101_0_1_0_0_0_0_0_0_0_0;
	parameter get_sj_1      = 14'b0110_0_0_0_0_0_0_0_0_0_0;
	parameter get_sj_2      = 14'b0111_0_0_0_1_0_0_0_0_0_0;
	parameter write_sj_1    = 14'b1000_0_0_0_0_0_0_0_0_1_0;
	parameter write_sj_2    = 14'b1001_0_0_0_0_0_0_0_0_1_1;
	parameter write_si_1    = 14'b1010_0_0_0_0_0_0_0_1_0_0; 
	parameter write_si_2    = 14'b1011_0_0_0_0_0_0_0_1_0_1; 
	parameter increment_i   = 14'b1100_0_0_0_0_1_0_0_0_0_0; 
	parameter finished      = 14'b1101_1_0_0_0_0_0_0_0_0_0; 


	assign wren = state[0];
	assign address_use_i = state[1];
	assign data_use_si = state[2];
	assign j_reset = state[3];
	assign i_reset = state[4];
	assign i_inc = state[5];
	assign enable_sj = state[6];
	assign enable_si = state[7];
	assign enable_j = state[8];
	assign finish = state[9];

	//other output logic:
	assign address = (address_use_i) ? i[7:0] : j;
	assign data = (data_use_si) ? si : sj;

	//state transtition logic:	
	always_ff @(posedge clock) 
		case (state)
			idle:          state <= (start) ? initialize : idle;
			initialize:    state <= get_si_1;
			get_si_1:      state <= get_si_2;
			get_si_2:      state <= calc_j;
			calc_j:        state <= get_sj_1;
			get_sj_1:      state <= get_sj_2;
			get_sj_2:      state <= write_sj_1;
			write_sj_1:    state <= write_sj_2;
			write_sj_2:    state <= write_si_1;
			write_si_1:    state <= write_si_2;
			write_si_2:    state <= increment_i;
			increment_i:   state <= check_if_done;
			check_if_done: state <= (i == 9'd256) ? finished : get_si_1;
			
			finished:		state <= idle;
			default: state <= idle;
		endcase

endmodule
