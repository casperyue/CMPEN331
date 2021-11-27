`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2019 12:57:27 PM
// Design Name: 
// Module Name: posEdgeDFFTest
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module posEdgeDFFTest;
    //inputs
    reg D;
    reg clk;
    reg reset;
    //output
    wire Q; //output Q
    
    posEdgeDFFwCLRN uut(D,clk,reset,Q);
    initial begin
        clk = 0;
            forever #10 clk = ~clk; //(flip clock every 10ns)
    end
    initial begin //testing of DFF
        reset=1;
        D <= 0;
        #100;
        reset=0;
        D <= 1;
        #100;
        D <= 0;
        #100;
        D <=1;
    end
endmodule