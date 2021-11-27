`timescale 1ns / 1ps
//CMPEN 331 Lab1 Taylan Unal FA19
module lab1( // module contains State machine.
    input u, 
    input [2:0] currentState, 
    input clrn,
    output reg [6:0] led,
    output reg [2:0] nextState
    );
    
    reg [2:0] S0 = 3'b000;
    reg [2:0] S1 = 3'b001;
    reg [2:0] S2 = 3'b010;
    reg [2:0] S3 = 3'b011;
    reg [2:0] S4 = 3'b100;
    reg [2:0] S5 = 3'b101;

    always @(*)
    begin
           case(currentState)//depending on current state, determines next state. Defined on lab sheet.
              S0: begin
                 if (u == 1)
                    nextState = S1;
                 else
                    nextState = S5;
              end
              S1: begin
                 if (u == 1)
                    nextState = S2;
                 else
                    nextState = S0;
              end
              S2: begin
                 if (u == 1)
                    nextState = S3;
                 else
                    nextState = S1;
              end
              S3: begin
                 if (u == 1)
                    nextState = S4;
                 else
                    nextState = S2;
              end
              S4: begin
                 if (u == 1)
                    nextState = S5;
                 else
                    nextState = S3;
              end
              S5: begin
                 if (u == 1)
                    nextState = S0;
                 else
                    nextState = S4;
              end
           endcase
     end  
     
    always @(*)
    begin
        case(currentState)// letters for LED are gfedcba because bits go from [bit6 to bit0] MSB first.
            S0: begin // S0=000
                led <= 7'b1000000; //each represents the letters lit up
            end
            S1: begin // S1=001
                led <= 7'b1111001;
            end
            S2: begin // S2=010
                led <= 7'b0100100;
            end
            S3: begin // S3 = 011
                led <= 7'b0110000;
            end
            S4: begin //S4 = 100
                led <= 7'b0011001;
            end
            S5: begin //S5 = 101
                led <= 7'b0010010;
            end
        endcase
    end
endmodule
