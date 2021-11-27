`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2019 11:27:34 AM
// Design Name: 
// Module Name: decoder3to8Test
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


module decoder3to8Test;
    //inputs
    reg in0;
    reg in1;
    reg in2;
    //outputs
    wire out0;
    wire out1;
    wire out2;
    wire out3;
    wire out4;
    wire out5;
    wire out6;
    wire out7;
    
    decoder3to8 uut(//Instantiate unit test for 3to8 decoder.
        .in0 (in0),
        .in1 (in1),
        .in2 (in2),
        
        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3),
        .out4(out4),
        .out5(out5),
        .out6(out6),
        .out7(out7)
    );
    initial begin
        //initialize inputs
        in0 = 0;
        in1 = 0;
        in2 = 0;
        //wait 100ns for full reset on timer
        #100;
        in0 = 1;
        in1 = 0;
        in2 = 1;
        //wait another 100ns for another full reset
        #100;
    end    
endmodule
