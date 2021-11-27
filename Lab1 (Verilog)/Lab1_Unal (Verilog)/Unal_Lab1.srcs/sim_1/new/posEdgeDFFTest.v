`timescale 1ns / 1ps
module posEdgeDFFTest;//currentState,clk,reset,nextState
    //inputs
    reg [2:0] currentState;
    reg clk;
    reg reset;
    //output
    wire [2:0] nextState; //output Q
    
    posEdgeDFF uut(currentState,clk,reset,nextState);
    initial begin
        clk = 0;
            forever #10 clk = ~clk; //(flip clock every 10ns)
    end
    initial begin //testing of DFF
        reset=1;
        currentState <= 0;
        #100;
        reset=0;
        currentState <= 1;
        #100;
        currentState <= 0;
        #100;
        currentState <=1;
    end
endmodule
