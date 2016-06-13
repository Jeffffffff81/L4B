`default_nettype none

/*
 * This FSM Controls all other FSMs through start/stop signals
 */

module ControllerFSM(clock, startTask1, finishTask1, startTask2a, finishTask2a
,startTask2b, finishTask2b);
    input logic clock;

    output logic startTask1, startTask2a, startTask2b;
    input logic finishTask1, finishTask2a, finishTask2b;

     //state encoding: {state bits}, startTask1
     
    reg[6:0] state;
    parameter initialize                = 7'b0000_0_0_0;
    parameter start_task_1              = 7'b0001_0_0_1;
    parameter wait_for_task1_finish     = 7'b0010_0_0_0;
    parameter start_task_2a             = 7'b0011_0_1_0;
    parameter wait_for_task_2a_finish   = 7'b0100_0_0_0;
	 parameter start_task_2b             = 7'b0101_1_0_0;
	 parameter wait_for_task_2b_finish   = 7'b0110_0_0_0;
    
    //output logic:
    assign startTask1 = state[0];
    assign startTask2a = state[1];
	 assign startTask2b = state[2];

    //state transition logic:
    always_ff @(posedge clock) begin
		case (state)
			initialize: 					state <= start_task_1;  
			start_task_1: 					state <= wait_for_task1_finish;
			wait_for_task1_finish: 		state <= (finishTask1) ? start_task_2a : wait_for_task1_finish;
			start_task_2a: 				state <= wait_for_task_2a_finish;
			wait_for_task_2a_finish: 	state <= (finishTask2a) ? start_task_2b : wait_for_task_2a_finish;
			start_task_2b:					state <= wait_for_task_2b_finish;
			wait_for_task_2b_finish:	state <= wait_for_task_2b_finish;
				
			default: state <= initialize;
        endcase
    end
endmodule