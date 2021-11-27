`timescale 1ns / 1ps
module testbench;
    //INPUTS
    wire [2:0] currentState;
    reg clk;
    reg clrn;
    reg u;
    //OUTPUTS
    wire [2:0] nextState;//aka Next State
    wire [6:0] led;
   
    lab1 lab1(
        .u(u),
        .currentState(currentState),
        .clrn(clrn),
        .nextState(nextState),
        .led(led)
    );
    posEdgeDFF posEdgeDFF(
        .currentState(currentState),
        .clk(clk),
        .clrn(clrn),
        .nextState(nextState)//aka Next State
    );
    
    initial begin
        clk = 1;
        u = 1;
        clrn = 0;
        #1 clrn = 1;
        #15 u = 0;
        end
always
begin
 #1 clk = ~clk;
  end
  
endmodule
