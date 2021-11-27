//Taylan Unal CMPEN 331.001 LAB5 Top Module
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

module InstMem(pcin, do); //a is 'PC input', do is 'IM output'
    input [31:0] pcin;
    output reg [31:0] do;
    reg [31:0] IM[0:127]; //load word from memory, leaving room for more instructions later.
    initial begin
        IM[32'd100] = 32'h8c220000; //lw $v0 00($at)
        IM[32'd104] = 32'h8c230004; //lw $v1 04($at)
        IM[32'd108] = 32'h8c240008; //lw $a0 08($at)
        IM[32'd112] = 32'h8c25000c; //lw $a1 12($at)
        IM[32'd116] = 32'h012E6820; //add $t5,$1,$t6 (adding $6,$2,$10)
    end
    
    always @ (pcin) begin //good
        do <= IM[pcin];
    end
endmodule

module IFID(clk, do, op, rd, rs, rt, func, imm);
    input clk;
    input [31:0] do;//instruction input
    output reg [5:0] op,func;//I-type values
    output reg [5:0] rd,rs,rt;//I-type values
    output reg [15:0] imm;//immediate value
    reg [31:0] IF; //IFID  temporarymemory
    always @ (posedge clk) begin
        IF <= do; //save value of input until negedge
    end
    
    always @(negedge clk)
        begin
            op <= IF[31:26];
            rs <= IF[25:21];
            rt <= IF[20:16];
            rd <= IF[15:11];
            func <= IF[5:0];
            imm <= IF[15:0]; //hmmm
        end
endmodule


module ControlUnit(op,func,aluc,wreg,m2reg,wmem,aluimm,regrt);
    input [5:0] op,func;
    output reg [3:0] aluc;
    output reg wreg, m2reg, wmem, aluimm, regrt;
    
    initial begin
        wreg <= 0; //RegWrite
        m2reg <= 0; //Mem2Reg
        wmem <= 0; //Write Memory
        aluimm <= 0; //ALU source
        regrt <= 0; //Reg Destination
    end
    always @ (op,func) begin //adding func
        if(op == 0) begin //R-Type instruction
            case(func)
                32: aluc <= 2; //Register ADD
                34: aluc <= 6; //Register SUB
                36: aluc <= 0; //Register AND
                37: aluc <= 1; //Register OR
                39: aluc <= 12;//Register XOR
             endcase
             wreg <= 1;//RegWrite
             m2reg <= 0;//Mem2Reg
             wmem <= 0;//WriteMem
             aluimm <= 0; //AluSrc
             regrt <= 1; //input to ControlMux
        end
        if(op == 6'b100011) begin //Load Word (LW) I-type
            aluc <= 2;//add
            wreg <= 1;//RegWrite
            m2reg <= 1;//Mem2Reg
            wmem <= 0;//WriteMem
            aluimm <= 1;//AluSrc
            regrt <= 0; //input to ControlMux
        end
    end
endmodule

module ControlMux(rd,rt,regrt,rn);
    input [4:0] rd,rt; //output from IFIDReg
    input regrt; //from controlunit, enable write
    output reg [4:0] rn; //output

    always @(regrt,rt,rd) begin
        case (regrt)
            0:
                rn <= rt;
            1:
                rn <= rd;
        endcase
    end
endmodule

module SignExtend(immIn, immOut);//input IF instruct value, output an extended 32 bit value
    input [15:0] immIn; //short (nonextended) value
    output reg [31:0] immOut; //extended value

    always @(immIn) begin
        immOut <= {{16{immIn[15]}},immIn[15:0]}; //extends 16bit number to 32bits.
    end
endmodule

module IDEXE(clk, wreg, m2reg, wmem, aluc, aluimm, rn, qa, qb, imm,
            ewreg, em2reg, ewmem, ealuc, ealuimm, ern, eqa, eqb, eimm);
    input clk; 
    input wreg, m2reg, wmem, aluimm; //input to IDEXE
    input [3:0] aluc; //output from control unit
    input [4:0] rn; //output from mux into IDEXE
    input [31:0] qa, qb; //output from regfile
    input [31:0] imm; //extended immediate value 
    
    //Use these to store values for later assignment using posedge, negedge.
    reg wreg2, m2reg2, wmem2, aluimm2;
    reg [4:0] rn2;
    reg [3:0] aluc2;
    reg [31:0] qa2, qb2;
    reg [31:0] imm2;
    
    output reg ewreg, em2reg, ewmem, ealuimm; //extended outputs from control unit
    output reg [3:0] ealuc; //extended outputs from control unit, into ALU
    output reg [4:0] ern; //extended outputs from mux
    output reg [31:0] eqa, eqb; //extended outputs from regfile
    output reg [31:0] eimm; //extended outputs from sign extender

    always@(posedge clk) begin //pass values into middle save values. (save regs <= input)
        wreg2 <= wreg;
        m2reg2 <= m2reg;
        wmem2 <= wmem;
        aluimm2 <= aluimm;
        rn2 <= rn;
        aluc2 <= aluc;
        qa2 <= qa;
        qb2 <= qb;
        imm2 <= imm;
    end
    
    always@(negedge clk) begin //output values from saved values. (output <= save regs)
        ewreg <= wreg2;
        em2reg <= m2reg2;
        ewmem <= wmem2;
        ealuimm <= aluimm2;
        ern <= rn2;
        ealuc <= aluc2;
        eqa <= qa2;
        eqb <= qb2;
        eimm <= imm2;
    end
endmodule

module ALUMux(eqb, eimmExt, ealuimm, muxImm);
    input [31:0] eqb, eimmExt; //qb value and immExt from IDEXE
    input ealuimm;//selector from IDEXE
    output reg [31:0] muxImm; //output of ALUMux
    
    always @ (eqb, eimmExt) begin
        case (ealuimm)
            0: muxImm = eqb;
            1: muxImm = eimmExt;
        endcase
    end
endmodule

module ALU (eqa, eqb, ealuc, aluOut);
    input [31:0] eqa, eqb;
    input [3:0] ealuc; //4bit number
    
    output reg [31:0] aluOut;

    always @ (eqa, eqb) begin
        case (ealuc)
            4'b0010: aluOut <= eqa + eqb;
        endcase
    end
endmodule

module EXEMEM (clock, ewreg, em2reg, ewmem, ern, aluOut, eqb, 
               mwreg, mm2reg, mwmem, mrn, maluOut, mqb);
    input clock, ewreg, em2reg, ewmem;
    input [4:0] ern;
    input [31:0] aluOut, eqb;
    
    //Temporary store values for posedge/negedge
    reg ewreg2, em2reg2, ewmem2;
    reg [4:0] ern2;
    reg [31:0] aluOut2, eqb2;
    
    output reg mwreg, mm2reg, mwmem; //outputs on memory side of register
    output reg [4:0] mrn;
    output reg [31:0] maluOut, mqb;
    
    always @ (posedge clock) begin //pass values into middle save (save regs <= input)
        ewreg2 <= ewreg;
        em2reg2 <= em2reg;
        ewmem2 <= ewmem;
        ern2 <= ern;
        aluOut2 <= aluOut;
        eqb2 <= eqb;
    end

    always @ (negedge clock) begin
        mwreg <= ewreg2;
        mm2reg <= em2reg;
        mwmem <= ewmem;
        mrn <= ern2;
        maluOut <= aluOut2;
        mqb <= eqb2;
    end
endmodule

module DataMemory (maluOut, mqb, mwmem, dmOut);//wm, aludata_in, qbdata_in, dmdata_out);
    input [31:0] maluOut, mqb; //input alu output value, qb value
    input mwmem;//write memory
    output reg [31:0] dmOut;
    
    reg [31:0] DM [0:36];

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
    
    always @ (maluOut, mqb) begin
        case (mwmem)
            1'b0: dmOut <= DM[maluOut];
            1'b1: dmOut <= DM[mqb];  
        endcase
    end
endmodule

module MEMWB(clk, mwreg, mm2reg, mrn, maluOut, dmOut,
             wwreg, wm2reg, wrn, waluOut, wdmOut);//adding WB outputs
    input clk, mwreg, mm2reg;
    input [31:0] maluOut, dmOut; 
    input [4:0] mrn;
    
    //Temporary store values between posedge/negedge
    reg mwreg2, mm2reg2;
    reg [31:0] maluOut2, dmOut2;
    reg [4:0] mrn2;
    
    output reg wwreg, wm2reg;
    output reg [31:0] waluOut, wdmOut;
    output reg [4:0] wrn;

    always @(posedge clk) begin //stores into temporary regs
        mwreg2 <= mwreg;
        mm2reg2 <= mm2reg;
        maluOut2 <= maluOut;
        dmOut2 <= dmOut;
        mrn2 <= mrn;
    end
    
    always @(negedge clk) begin
        wwreg <= mwreg2;
        wm2reg <= mm2reg2;
        waluOut <= maluOut2;
        wdmOut <= dmOut2;
        wrn <= mrn2;
    end
endmodule

module WBMux(waluOut, wdmOut, wm2reg, wbMuxOut);
    input [31:0] waluOut, wdmOut;//takes in aluresult and data memory address
    input wm2reg; //write enable memory to register
    output reg [31:0] wbMuxOut; //output to regfile
    
    always @(waluOut, wdmOut, wm2reg) begin
        case(wm2reg)
            0: wbMuxOut <= waluOut; //if wm2reg=0, output alu value
            1: wbMuxOut <= wdmOut; //if wm2reg=1, output datamem value.
        endcase
    end
endmodule

module RegFile(clk, rs, rt, qa, qb, wrn, wbmuxOut); //(clk,rs,rt,qa,qb,wrn,wbmuxOut)
    input clk;
    input [31:0] wbmuxOut; //data to write to register
    input [4:0] rs, rt, wrn; //rs val in, rt val in, rd val in
    reg [31:0] regs [0:31]; //32 x 32 register file. Store all the registers.

    output reg [31:0] qa, qb; //qa->rt out, qb->rs

    initial begin //initialize all 32 registers to 0.
        {regs[0], regs[1], regs[2], regs[3], regs[4], regs[5], regs[6], regs[7],
        regs[8], regs[9], regs[10], regs[11], regs[12], regs[13], regs[14], regs[15],
        regs[16], regs[17], regs[18], regs[19], regs[20], regs[21], regs[22], regs[23],
        regs[24], regs[25], regs[26], regs[27], regs[28], regs[29], regs[30], regs[31]} = 0;//32'h00000000;
    end
    
    always @(posedge clk) begin //write during first half of cycle
        if(wrn != 0) begin//write operation
            regs[wrn] <= wbmuxOut;
        end
    end
    
    always @(rs, rt) begin//read during second half of cycle
        qa <= regs[rs]; //register val in register rs
        qb <= regs[rt]; //register val in register rt
    end
endmodule