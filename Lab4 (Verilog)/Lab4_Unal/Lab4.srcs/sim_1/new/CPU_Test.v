//Taylan Unal CMPEN 331.001 LAB4 Testbench
`timescale 1ns / 1ps

module CPU_Test();
//WIRES ARE OUTPUTS, REGS ARE INPUTS
    reg clk; //could be clk = 0;
    wire [31:0] pcin, pcout, im_out, if_idout, qawire, qbwire, sign_extendedout,
                eqawire, eqbwire, eimmnext_out, alumux_out, alu_out, e2mALU, qb2DM, dm_out;
    wire [3:0] aluc_out, ealuc_out;
    wire wregwire, m2regwire, wmemwire, aluimmwire, regrtwire, ewregwire, 
         em2regwire, ewmemwire, ealuimmwire, e2mwreg, e2mM2reg, wmemDM;
    wire [4:0] muxwire, emuxwire, e2mMux; //e2mMux;
    
//////////////////////////////////////////////////////////////////////////////////////
    PC PC(clk, pcin, pcout); //done
    PCAdder adder(pcout, pcin); //done
    InstructMem instmem(pcout, im_out); //done
    IFID ifid(clk, im_out, if_idout); //needs clk, im_out is Ifid_in, if_idout is output
    ControlUnit ctrunit(if_idout, wregwire, m2regwire, wmemwire, //if_idout is op and func
                        aluc_out, aluimmwire, regrtwire); //done                 
    ControlMux ctrmux(if_idout, regrtwire, muxwire); // inst_Mux contains ifid, regrt from control unit, muxwire contains rd_rt
    RegFile regfile(if_idout, qawire, qbwire); //if_id is inst_RF, qawire is RS output, qbwire is RT output
    SignExtend extender(if_idout, sign_extendedout); //input 32 bit non sign extended, output 32 bit extended.
    IDEXE idexe(clk, wregwire, m2regwire, wmemwire, aluc_out, aluimmwire, muxwire, qawire, qbwire,
                sign_extendedout, ewregwire, em2regwire, ewmemwire, ealuc_out, ealuimmwire, emuxwire, eqawire, eqbwire, eimmnext_out); //working on it
    ALUMux alumux(ealuimmwire, eqbwire, eimmnext_out, alumux_out);
    ALU alu(ealuc_out, eqawire, alumux_out, alu_out);
    EXEMEM exemem(clk, ewregwire, em2regwire, ewmemwire, emuxwire, alu_out, eqbwire, 
                  e2mwreg, e2mM2reg, wmemDM, e2mMux, e2mALU, qb2DM);
    DataMemory datamem(wmemDM, e2mALU, qb2DM, dm_out); //memwrite, alu input, qbdata input, DM output
    MemWB memwb(clk, e2mwreg, e2mM2reg, e2mMux, e2mALU, dm_out); //clk, memwrite reg, mem Mux, mem ALU, mem DM
    
    initial begin
        clk = 0;
    end            
    always begin
        #5 clk = !clk;
    end
endmodule
