`timescale 1ns / 1ps

module posEdgeDFF(currentState,clk,clrn,nextState);

    input [2:0] nextState; //Data input
    input clk;//clock
    input clrn;//reset
    output reg [2:0] currentState; //output Q
      
    always @(posedge clk or clrn)//DFF 1
        if(~clrn) begin //1bit value of 1
            currentState <= 3'b0; //1bit value of 0
        end else begin
            currentState <= nextState;
        end
endmodule
