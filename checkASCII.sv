module checkASCII(start, clock, finish, ram_address, ram_q, valid);

	//inputs to FSM 
	input logic start; 
	input logic clock; 
	input logic [7:0] ram_q; 
	
	
	//outputs from FSM 
	output logic finish; 
	output logic [4:0] ram_address; 
	output logic valid; 
	
	
	//wires 
	logic init, inc_count, choose_count_address, store_in_ram_count, passed_test; 
	logic [9:0] state; 
	
	//logic for count 
	logic [4:0] count; 
	always_ff @(posedge clock) begin 
		if(init) 			count <= 0; 
		else if(inc_count)	count <= (count + 1); 
		else 				count <= count; 
	end
	
	
	//ram address logic 
	assign ram_address = choose_count_address ? count : 5'b00000;
	
	//retrieved data from ram logic 
	logic [7:0] ram_count;
	always_ff @(posedge clock) begin 
		if(store_in_ram_count)	ram_count <= ram_q; 
		else 					ram_count <= ram_count; 
	end 
	
	//valid logic
	always_ff @(posedge clock) begin 
        if(init)                valid <= 1'b0;
		else if(passed_test)	valid <= 1'b1; 
		else 			        valid <= valid; 
	end
	
	//the condition
	logic it_is_ASCII; 
	assign it_is_ASCII = ((ram_count == 32) || ((ram_count < 123) && (ram_count > 96))); 
	
	
	//output state bits  
	assign init = state[0]; 
	assign inc_count = state[1]; 
	assign choose_count_address = state[2]; 
	assign store_in_ram_count = state[3];
	assign passed_test = state[4]; 
	assign finish = state[5]; 
	
								//         5 4 3 2 1 0		
	parameter idle 				= 10'b0000_0_0_0_0_0_0; 
	parameter initialize 		= 10'b0001_0_0_0_0_0_1;
	parameter set_ram_count 	= 10'b0010_0_0_0_1_0_0;
	parameter read_ram_count 	= 10'b0011_0_0_1_1_0_0;
	parameter wait_for_cond		= 10'b0100_0_0_0_0_0_0;
								//         5 4 3 2 1 0	
	parameter increment_count	= 10'b0101_0_0_0_0_1_0;
	parameter check_count		= 10'b0110_0_0_0_0_0_0;
	parameter set_valid 		= 10'b0111_0_1_0_0_0_0;
	parameter done			= 10'b1000_1_0_0_0_0_0; 
	
	//next state logic 	
	always_ff @(posedge clock) begin 
		case(state) 
			idle: 	if(start)	state <= initialize; 
					else 	  	state <= idle; 
			initialize:			state <= set_ram_count; 
			set_ram_count: 		state <= read_ram_count; 
			read_ram_count: 	state <= wait_for_cond; 
			wait_for_cond:	if(it_is_ASCII)	state <= increment_count; 
							else			state <= done; 
			
			increment_count: 	state <= check_count; 
			check_count: 	if(count == 0)	state <= set_valid; 
							else 			state <= set_ram_count; 
			set_valid: 	state <= done; 
			done: 		state <= idle; 
			default: 	state <= idle; 
		endcase 
	end 

endmodule 
