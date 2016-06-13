module ControllerFSM_tb();
    logic clock;

    logic startTask1, startTask2a;
    logic stopTask1, stopTask2a;

    ControllerFSM dut(
	.clock(clock),
        .startTask1(startTask1),
        .stopTask1(stopTask1),
        .startTask2a(startTask2a),
        .stopTask2a(stopTask2a)
    );

    initial begin
        forever begin
            clock = 1; #1;
            clock = 0; #1;
         end
    end

    initial begin
        stopTask1 = 0;
        stopTask2a = 0;
        #19;

        stopTask1 = 1;
	#2;
        stopTask1 = 0;
        #20;
        $stop;
    end
endmodule
