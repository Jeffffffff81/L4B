`default_nettype none

/*
 * This FSM will initialize the contents of RAM to:
 * for(int i = 0; i < 256; i++) {
 *     s[i]
 * }
 *
 * Inputs:   clock: the clock it runs on
 *           start: tells it to start initializing
 *           
 * Outputs   finish: pulsed when FSM is done
 *           wren: set when we want to write 'data' to s_RAM
 *           address: the address into s_RAM
 *           data: data to be written to s_RAM
 */

module task1FSM(clock, start, finish, data, wren, address);
	input logic clock, start;
	output logic wren, finish;
	output logic [7:0] data, address;
	
	//state encoding {state bits}, {wren}, {inc}, {finish}
	logic[7:0] state;
	parameter idle = 8'b0000_0_0_0_0;
	parameter initialize_a = 8'b0001_1_1_0_0;
	parameter initialize_b = 8'b0010_1_0_1_0;
	parameter finished = 8'b0010_1_0_0_1;
	
	//internal/output logic:
	logic reset; assign reset = !state[3];
	assign wren = state[2];
	logic inc; assign inc = state[1];
	assign finish = state[0];
	
	reg[7:0] counter = 0;
	always_ff @(posedge clock) begin
		if(inc)
			counter <= counter + 1;
		else if (inc == 8'b1111_1111)
			counter <= 0;
		else if (reset)
			counter <= 0;
		else
			counter <= counter;
	end
	
	assign data = counter;
	assign address = counter;
	
	//state transition
	always_ff @(posedge clock) begin
		case(state) 
			idle: state <= (start) ? initialize_a : idle;
			
			initialize_a: state <= (counter == 8'b1111_1111) ? finished : initialize_b;
			
			initialize_b: state <= (counter == 8'b1111_1111) ? finished : initialize_a;
			
			finished: state <= idle;
			
			default: state <= idle;
		endcase
	end

endmodule
	