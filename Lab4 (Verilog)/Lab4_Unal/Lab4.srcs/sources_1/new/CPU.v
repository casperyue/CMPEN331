//Taylan Unal CMPEN 331.001 LAB4 Top Module
`timescale 1ns / 1ps
module PC(clk, PCin, PCout);
    input clk;                  
    input [31:0] PCin;
    reg[31:0] PCmem;          
    output reg [31:0] PCout;
    initial begin
        PCout = 0;
        PCmem = 100;
    end  
    
    always @(posedge clk) begin       
        PCmem <= PCin; //register output is saved as its input at clk cycle
    end
    always @(negedge clk) begin       
        PCout <= PCmem; //register output is assigned its input at clk cycle
    end
endmodule

module PCAdder(PCin, PCout);
    input [31:0] PCin;
    output reg [31:0] PCout;
    
    always @(PCin) begin
        PCout <= PCin + 4;
    end
endmodule

module InstructMem(a, do); //a is 'PC input', do is 'IM output'
    input [31:0] a;
    output reg [31:0] do;
    reg [31:0] IM[0:511]; //load word from memory, leaving room for more instructions later.
    initial begin
        IM[32'd100] = 32'h8c220000; //lw $v0 00($at)
        IM[32'd104] = 32'h8c230004; //lw $v1 04($at)
        IM[32'd108] = 32'h8c240008; //lw $a0 08($at)
        IM[32'd112] = 32'h8c25000c; //lw $a1 12($at)
    end
    
    always @ (a) begin
        do <= IM[a];
    end
endmodule

module IFID(clk, instIn, instOut);//defining instruction input and instruction out from IM
    input clk;
    input [31:0] instIn;
    reg [31:0] IF; //IF memory
    output reg [31:0] instOut; //defines the R-type
    
    always @ (posedge clk) begin
        IF <= instIn; //save value of input until negedge.
    end
    always @ (negedge clk) begin
        instOut <= IF; //pull from stored value
    end
endmodule

module ControlUnit(inst_CU, wreg, m2reg, wmem, aluc, aluimm, regrt);
    input [31:0] inst_CU; //ifid_out. Includes op, func.
    wire [5:0] op, func;
    output reg wreg, m2reg, wmem, aluimm, regrt;
    output reg [3:0] aluc;
    assign op = inst_CU[31:26];
    
    initial begin
        wreg <= 0; //RegWrite
        m2reg <= 0; //Mem2Reg
        wmem <= 0; //Write Memory
        aluimm <= 0; //ALU source
        regrt <= 0; //Reg Destination
    end

    always @ (op) begin
        if(op == 6'b100011) begin //Load Word (LW)
            wreg <= 1'b1;
            m2reg <= 1'b1;
            wmem <= 1'b0;
            aluimm <= 1'b1;
            regrt <= 1'b1; //important part
            aluc <= 4'b0010;
        end
    end
endmodule

module ControlMux(inst_Mux, regrt, rd_rt);
    input [31:0] inst_Mux;
    input regrt;
    output reg [4:0] rd_rt;
    wire [4:0] rd, rt;
    
    assign rd = inst_Mux[15:11];
    assign rt = inst_Mux[20:16];
    
    always @(rd, rt) begin 
        case (regrt)
            1'b1:
                rd_rt = rt;
            1'b0:
                rd_rt = rd;
        endcase
    end
endmodule

module RegFile(inst_RF, qa, qb); //if_idout is inst_RF, qa is RS out, qb is RT out
    input [31:0] inst_RF;
    reg [31:0] regs [0:31]; //32 x 32 register file. Store all the registers.
    wire [4:0] rs, rt;
    output reg [31:0] qa, qb;

    assign rs = inst_RF[25:21];
    assign rt = inst_RF[20:16];
    
    initial begin //initialize all 32 registers to 0.
        {regs[0], regs[1], regs[2], regs[3], regs[4], regs[5], regs[6], regs[7],
        regs[8], regs[9], regs[10], regs[11], regs[12], regs[13], regs[14], regs[15],
        regs[16], regs[17], regs[18], regs[19], regs[20], regs[21], regs[22], regs[23],
        regs[24], regs[25], regs[26], regs[27], regs[28], regs[29], regs[30], regs[31]} = 0;//32'h00000000;
    end
    
    always @(rs, rt) begin
        qa <= regs[rs]; //register output 1 = val in register rs
        qb <= regs[rt]; //register output 2 = val in register rt
    end
endmodule

module SignExtend(inst_IF, immOut);//input IF instruct value, output an extended 32 bit value
    input [31:0] inst_IF; //short value
    output reg [31:0] immOut; //extended value
    wire [15:0] imm; //save wire for main values
    
    assign imm = inst_IF[15:0]; //save first 16 bits.
    always @(imm) begin
        immOut = {{16{imm[15]}},imm}; //extends 16bit number to 32bits.
    end
endmodule

module IDEXE(clk, wreg, m2reg, wmem, aluc, aluimm, mux, qa, qb, extend,
            ewreg, em2reg, ewmem, ealuc, ealuimm, emux, eqa, eqb, eextend);
    input clk; 
    input wreg, m2reg, wmem, aluimm; //input to IDEXE
    input [4:0] mux; //output from mux into IDEXE
    input [3:0] aluc; //output from control unit
    input [31:0] extend, qa, qb; //output from regfile
    
    //Use these to store values for later assignment using posedge, negedge.
    reg wreg2, m2reg2, wmem2, aluimm2;
    reg [4:0] mux2;
    reg [3:0] aluc2;
    reg [31:0] qa2, qb2;
    reg [31:0] extend2;
    
    output reg ewreg, em2reg, ewmem, ealuimm; //extended outputs from control unit
    output reg [3:0] ealuc; //extended outputs from control unit, into ALU
    output reg [4:0] emux; //extended outputs from multiplexer
    output reg [31:0] eqa, eqb; //extended outputs from regfile
    output reg [31:0] eextend; //extended outputs from sign extender

    always@(posedge clk) begin //pass values into middle save values. (save regs <= input)
        wreg2 <= wreg;
        m2reg2 <= m2reg;
        wmem2 <= wmem;
        aluimm2 <= aluimm;
        mux2 <= mux;
        aluc2 <= aluc;
        qa2 <= qa;
        qb2 <= qb;
        extend2 <= extend;
    end
    
    always@(negedge clk) begin //output values from saved values. (output <= save regs)
        ewreg <= wreg2;
        em2reg <= m2reg2;
        ewmem <= wmem2;
        ealuimm <= aluimm2;
        emux <= mux2;
        ealuc <= aluc2;
        eqa <= qa2;
        eqb <= qb2;
        eextend <= extend2;
    end
endmodule

module ALUMux(ealuimm, eqb, eextend, alumux_out);
    input ealuimm;
    input [31:0] eqb, eextend; //qb value and immExtended
    
    output reg [31:0] alumux_out;
    
    always @ (eqb, eextend) begin
        case (ealuimm)
            1'b0: alumux_out = eqb;
            1'b1: alumux_out = eextend;
        endcase
    end
endmodule

module ALU (ALUcontrol, eqa , eqb, alu_out);
    input [3:0] ALUcontrol; //4bit number
    input [31:0] eqa, eqb;
    output reg [31:0] alu_out;

    always @ (eqa, eqb) begin
        case (ALUcontrol)
            4'b0010: alu_out <= eqa + eqb;
        endcase
    end
endmodule

module EXEMEM (clock, eWREG, eM2REG, eWMEM, eMUX, eALU_OUT, eQB, eWREG_out, 
               eM2REG_out, eWMEM_out, eMUX_out, eALU_out, eQB_out);
    input clock, eWREG, eM2REG, eWMEM;
    input [4:0] eMUX;
    input [31:0] eQB, eALU_OUT;
    
    reg ewreg, em2reg, ewmem;
    reg [4:0] emux;
    reg [31:0] ealu_out, eqb;
    
    output reg eWREG_out, eM2REG_out, eWMEM_out;
    output reg [4:0] eMUX_out;
    output reg [31:0] eALU_out, eQB_out;

    always @ (posedge clock) begin
        ewreg <= eWREG;
        em2reg <= eM2REG;
        ewmem <= eWMEM;
        emux <= eMUX;
        ealu_out <= eALU_OUT;
        eqb <= eQB;
    end

    always @ (negedge clock) begin
        eWREG_out <= ewreg;
        eM2REG_out <= em2reg;
        eWMEM_out <= ewmem;
        eMUX_out <= emux;
        eALU_out <= ealu_out;
        eQB_out <= eqb;
    end
endmodule

module DataMemory (MEMWRITE, ALUDATA_IN ,QBDATA_IN, DMDATA_OUT);
    input MEMWRITE;
    input [31:0] ALUDATA_IN, QBDATA_IN;

    reg [31:0] DM [0:36];

    output reg [31:0] DMDATA_OUT;

    initial begin //set first 10 words to data memory
        DM[32'd0] = 32'hA00000AA;
        DM[32'd4] = 32'h10000011;
        DM[32'd8] = 32'h20000022;
        DM[32'd12] = 32'h30000033;
        DM[32'd16] = 32'h40000044;
        DM[32'd20] = 32'h50000055;
        DM[32'd24] = 32'h60000066;
        DM[32'd28] = 32'h70000077;
        DM[32'd32] = 32'h80000088;
        DM[32'd36] = 32'h90000099;
    end
    
    always @ (ALUDATA_IN, QBDATA_IN) begin
        case (MEMWRITE)
            1'b0: DMDATA_OUT <= DM[ALUDATA_IN];
            1'b1: DMDATA_OUT <= DM[QBDATA_IN];  
        endcase
    end
endmodule

module MemWB(clock, mWREG, mM2REG, mMUX, mALU, mDM);
    input clock, mWREG, mM2REG;
    input [4:0] mMUX;
    input [31:0] mALU, mDM; 

    reg mwreg,mm2reg;
    reg [4:0] mmux;
    reg [31:0] malu,mdm;

    always @(posedge clock) begin
        mwreg <= mWREG;
        mm2reg <= mM2REG;
        mmux <= mMUX;
        malu <= mALU;
        mdm <= mDM;
    end
endmodule