//Taylan Unal CMPEN 331.001 Lab5 Honors Option Testbench
`timescale 1ns / 1ps

module CPU_Test();
//WIRES ARE OUTPUTS, REGS ARE INPUTS. 
    reg clk; //global clock signal
    //IF STAGE
    wire [31:0] pcin; //PC output to PC register
    wire [31:0] pcout; //PC output to adder
    wire [31:0] do; //instruction to be executed (im_out)
    
    //ID STAGE
    wire [5:0] op, func; //opcode and func fields.
    wire [4:0] rd,rs,rt; //source, destination registers of instruction
    wire [15:0] imm; //immediate field (for i-type instructions)
    wire [3:0] aluc; //alucontrol to input into ALU to determine operation
    wire wreg; //(ID) write enable for IDEXE register
    wire m2reg; //(ID) write enable for IDEXE register from data memory
    wire wmem; //(ID) write enable for data memory
    wire aluimm; //(ID) sends either alu control signal or immediate value to ALUMUX
    wire regrt; // (ID) input to controlMux, chooses what to write rt/rd to IDEXEregister
    wire [4:0] rn; //(ID) ** output of controlMux, chooses to write reg number to IDEXE
    wire [31:0] qa,qb;//(ID) ** register file values for instruction. (Note register is now at end of WB)
    wire [31:0] immExt; // (ID)extended immediate value to 32 bits (I-type)
    
    //EXE STAGE
    wire [3:0] ealuc; //(EXE) ALUControl to determine ALU operation
    wire ewreg; //(EXE) write enable for EXEMEM register 
    wire em2reg; //(EXE) write enable for EXEMEM register from data memory
    wire ewmem; //(EXE) write enable for data memory
    wire ealuimm; //(EXE) sends either ALUcontrol signal or immediate value to ALUMUX
    wire [4:0] ern; //(EXE) **output of controlMux, chooses to write reg number to EXEMEM
    wire [31:0] eqa, eqb; //(EXE) **register file values for instruction
    wire [31:0] eimmExt; //(EXE) extended immediate value after written to IDEXE
    wire [31:0] muxImm; //(EXE) output of immediate mux
    wire [31:0] aluOut; //(EXE) output of ALU Module
    
    //MEM STAGE
    wire mwreg; //(MEM) write enable for MEMWB register 
    wire mm2reg; //(MEM) write enable for MEMWB register from data memory
    wire mwmem; //(MEM) write enable for data memory
    wire [4:0] mrn; //(MEM) **output of controlMux, chooses to write reg number to MEMWB
    wire [31:0] maluOut; //(MEM) output of ALU Module
    wire [31:0] mqb; //(MEM) qb value from regfile->IDEXEReg->EXEMEMReg
    wire [31:0] dmOut; //(MEM) data memory output
    
    //WB STAGE
    wire wwreg; //(WB) write enable for Regfile. (After all other stages enable values
    wire wm2reg; //(WB) write enable for Regfile from datamemory
    wire [4:0] wrn; //(WB) **output of controlMux, chooses to write reg number to Regfile
    wire [31:0] waluOut; //(WB) output of ALU Module
    wire [31:0] wdmOut; //(WB) data memory output
    wire [31:0] wbMuxOut;//(WB) output of Mem2Reg Mux for DataMem->Regfile
    
    //FORWARDING UNIT and MUXes (All in ID Stage)
    wire [1:0] fwda; //output signal from ControlUnit, input for ForwardAMux
    wire [31:0] fwdaOut; //output signal from ForwardAMux
    wire [1:0] fwdb; //output signal from ControlUnit, input for ForwardBMux
    wire [31:0] fwdbOut; //output signal from ForwardBMux
//////////////////////////////////////////////////////////////////////////////////////
    //START Testbench
    //IF STAGE
    PC PC(clk, pcin, pcout); //PCRegister: input clk, PCinput, outputs result from PCAdder
    PCAdder adder(pcout, pcin); //PCAdder: input PCOutput, increments by 4, outputs to input of 
    InstMem instmem(pcout, do); //InstMem: has instructions, outputs instruction from PCRegister
    
    //IFID REGISTER
    IFID ifid(clk,do,//inputs
              op,rd,rs,rt,func,imm);//outputs
    
    //ID STAGE
    ControlUnit CU(op,func,rs,rt,mrn,mm2reg,mwreg,ern,em2reg,ewreg, //inputs
                   aluc,wreg,m2reg,wmem,aluimm,fwda,fwdb,wpcir,regrt);//outputs
    ControlMux ctrmux(rd,rt,regrt,rn); //ControlMux: Selects whether to write rd/rt into RegWrite, outputs to IDEXE
    SignExtend extender(imm, immExt); //SignExtend: input is 16bit nonextended from instruction memory, output 32bit extended value.
    
    ForwardAMux fwdamux(fwda,qa,maluOut,mqb,dmOut,fwdaOut); //inputs: fwdb,qb,maluOut,mqb,dmOut outputs: fwda_out
    ForwardBMux fwdbmux(fwdb,qb,maluOut,mqb,dmOut,fwdbOut); //inputs: fwdb,qb,maluOut,mqb,dmOut outputs: fwdb_out
    
    
    //IDEXE REGISTER
    IDEXE idexe(clk,wreg,m2reg,wmem,aluc,aluimm,rn,qa,qb,immExt,//inputs
                ewreg,em2reg,ewmem,ealuc,ealuimm,ern,eqa,eqb,eimmExt);//outputs
    
    //EXE STAGE
    ALUMux alumux(eqb,eimmExt,ealuimm,muxImm);//ALUMux: selects qb reg output or immediate value
    ALU alu(eqa, muxImm, ealuc, aluOut);//ALU: executes operations for CPU using aluc control, a,b inputs
    
    //EXEMEM REGISTER
    EXEMEM exemem(clk,ewreg,em2reg,ewmem,ern,aluOut,eqb,//inputs
                  mwreg,mm2reg,mwmem,mrn,maluOut,mqb);//outputs
    
    //MEM STAGE
    DataMemory datamem(maluOut,mqb,mwmem,dmOut); //DataMemory: data memory handler, inputs from EXEMEM, out to dmOut
    
    //MEMWB REGISTER
    MEMWB memwb(clk,mwreg,mm2reg,mrn,maluOut,dmOut,//inputs
                wwreg,wm2reg,wrn,waluOut,wdmOut); //ouputs
    
    //WB STAGE
    WBMux wbmux(waluOut, wdmOut, wm2reg, wbMuxOut); //WBMux: selects what to write back into regfile
    RegFile regfile(clk,rs,rt,qa,qb,wrn,wbMuxOut); //RegFile: generates a 32x32 register file to read/write from
    
    initial begin //Clock signal loop.
        clk = 0;
    end            
    always begin
        #5 clk = !clk;
    end
endmodule