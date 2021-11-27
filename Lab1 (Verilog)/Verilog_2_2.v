//Example of 3 to 8 One-hot Decoder
/*
module decoder3to8(
input [2:0] in,
output [7:0] out
);
assign out[0] = ~in[2] & ~in[1] & ~in[0]
assign out[1] = ~in[2] & ~in[1] & in[0]
assign out[2] = ~in[2] & in[1] & ~in[0]
assign out[3] = ~in[2] & in[1] & in[0]
assign out[4] = in[2] & ~in[1] & ~in[0]
assign out[5] = in[2] & ~in[1] & in[0]
assign out[6] = in[2] & in[1] & ~in[0]
assign out[7] = in[2] & in[1] & in[0]
*/
/* D-FLIP FLOP
module dff(
always @ (posedge clk)
begin 
    Q <= D;
end
);
*/
/* DFF Pos Edge, Active High Reset
always @ (posedge clk, posedge reset)
begin
    if(reset == 'b1)
    begin
        Q <= 1'b0;
    end
    else
    begin
        Q <= D;
    end
end
*/

/* SWAPPING (NON Blocking Assignment)
module swap(
    input rst
    input clk
    output reg out1,
    output reg out0,
);
    always @ (posedge clk)
    begin
        if(rst)
        begin
            out0 <= 1'b0;
            out1 <= 1'b1;
        end
        else
        begin
            out0 <= out1;
            out1 <= out0;
        end
endmodule
*/

module top{
    reg[2:0] S0 = 3'b000
    reg[2:0] S1 = 3'b000
    reg[2:0] S2 = 3'b000
    reg[2:0] S3 = 3'b000
    reg[2:0] S4 = 3'b000
    reg[2:0] S5 = 3'b000


}