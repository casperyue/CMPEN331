`timescale 1ns / 1ps

module CPU(clk, PCin, PCout);
    input clk;                  
    input [31:0] PCin;          
    output reg [31:0] PCout;
    initial begin
        PCout = 100;
    end  
    always @(posedge clk)       
    begin
        PCout <= PCin; //register output is assigned its input at clk cycle
    end
endmodule

module PCAdder(PCin, PCout);
    input [31:0] PCin;
    output reg [31:0] PCout;
    always @(PCin)
        begin
            PCout <= PCin + 4;
        end
endmodule

module InstructMem(if_idin,if_idout); //if_idin is 'PC input', if_idout is 'do'
    input [31:0] if_idin;
    output reg [31:0] if_idout;
    initial begin
        if_idout[100] = 32'h8c220000; //lw $v0 00($at)
        if_idout[104] = 32'h8c230004; //lw $v1 04($at)
        if_idout[108] = 32'h8c240008; //lw $a0 08($at)
        if_idout[112] = 32'h8c25000c; //lw $a1 12($at)
        if_idout[116] = 32'h004a3020; //add $a2 $v0 $t2
    end
    always @ (if_idin) begin
        if_idout <= if_idout[if_idin];
    end
    //assign if_idout = instr_mem[if_idin];
endmodule

module IFID(clk, do, op, rd, rs, rt, func, imm);
    input clk;
    input [31:0] do; //output from Instruction memory
    //setup R Type
    output reg [5:0] op, func; //output into Control Unit
    output reg [4:0] rd, rs, rt; // (rd,rt) into mux. (rs,rt) into regfile
    output reg [15:0] imm; //immediate value going into extender
    
    always@(posedge clk) begin
        op <= do[31:26]; // R-Type opcode
        func <= do[5:0]; // R-Type func
        rs <= do[25:21]; // R-Type first source
        rt <= do[20:16]; // R-Type target source
        rd <= do[15:11]; // R-Type destination register
        imm <= do[15:0]; // Address/Immediate Value
    end
endmodule

module ControlUnit(op, func, aluc, wreg, m2reg, wmem, aluimm, regrt);
    input [5:0] op;
    input [5:0] func;
    output reg [3:0] aluc;
    output reg wreg,m2reg,wmem,aluimm,regrt;
    
    initial begin
        wreg <= 0; //RegWrite
        m2reg <= 0; //Memory to Register
        wmem <= 0; //write memory
        aluimm <= 0; //alu source
        regrt <= 0; //reg destination
    end
    
    always@(op,func) begin
        if (op == 0)//if R-Type
        begin
            case(func)
                32: aluc <=2;
                34: aluc <= 6;  //Subtract
                    36: aluc <= 0;  //AND
                    37: aluc <= 1;  //OR
                    39: aluc <= 12; //nor 
                    42: aluc <= 7;  //SLT
                    default aluc <= 15; //should never run
            endcase
            wreg <= 1; //WriteReg
            m2reg <= 0; //MemoryToReg
            wmem <= 0; //Write Memory
            aluimm <= 0; //ALUsrc
            regrt <= 1; //RegDist
        end
    
        if(op == 6'b100011) //Load Word (LW)
        begin
            aluc <= 2;
            wreg <= 1;
            m2reg <= 1;
            wmem <= 0;
            aluimm <= 1;
            regrt <= 0;
        end
        if (op == 6'b101011) //Store Word (SW)
        begin
            aluc <= 2; //add
            wreg <= 0; //WriteReg
            wmem <= 1; //Write Memory
            aluimm <= 1; //ALUsrc
        end
        if (op == 6'b000100) // Branch Equal (BEQ)
        begin
            aluc <= 6; //subtract
            wreg <= 0; //WriteReg
            wmem <= 0; //Write Memory
            aluimm <= 0; //ALUsrc
        end
    end
endmodule

module ControlMux(
    input regrt,
    input [4:0] rd, rt,
    output [4:0] wn
    );
    assign wn = regrt?rt:rd; //Multiplexer operation
endmodule

module RegFile(
    input we,
    input [4:0] rna,
    input [4:0] rnb,
    input [4:0] wn,
    input [4:0] d,
    output reg [31:0] qa,
    output reg [31:0] qb
    );
    //initialize all registers to 0
    reg [31:0] registers [0:127];
    initial begin
        registers[0] = 0;
        registers[1] = 0;
        registers[2] = 0;
        registers[3] = 0;
        registers[4] = 0;
        registers[5] = 0;
        registers[6] = 0;
        registers[7] = 0;
        registers[8] = 0;
        registers[9] = 0;
        registers[10] = 0;
        registers[11] = 0;
        registers[12] = 0;
        registers[13] = 0;
        registers[14] = 0;
        registers[15] = 0;
    end
    always@(rna, rnb) begin
        qa = registers[rna];
        qb = registers[rnb];
    end
endmodule

module SignExtend(//input immediate value, extend to 32 bit value
    input [15:0] imm,
    output reg [31:0] long //extended value
    );
    always@(imm) begin
        if(imm[15] == 1) begin
            long[31:16] = 16'hffff;
            long[15:0] = imm;
        end
        else begin
            long[31:16] = 16'h0000;
            long[15:0] = imm;
        end
    end
endmodule

module IDEXE(
    input clk, wreg, m2reg, wmem, aluimm, //input to IDEXE
    input [3:0] aluc, //output from control unit
    input [31:0] qa, qb, //output from regfile
    input [4:0] mux, //output from mux into IDEXE
    input [31:0] extend, //output from signextender
    
    output reg ewreg, em2reg, ewmem, ealuimm, //outputs from control unit
    output reg [3:0] ealuc, //out from control unit, into ALU
    output reg [31:0] eqa, eqb, //outputs from regfile
    output reg [4:0] emux, //output from multiplexor
    output reg [31:0] eextend //output from sign extender
    );
    always@(posedge clk) begin
        ewreg = wreg;
        em2reg = m2reg;
        ewmem = wmem;
        ealuimm = aluimm;
        emux = mux;
        ealuc = aluc;
        eqa = qa;
        eqb = qb;
        eextend = extend;
    end
endmodule