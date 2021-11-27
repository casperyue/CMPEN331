`timescale 1ns / 1ps

module CPU_Test();
    //Start PC
    reg clk, rst;
    reg [31:0] pcin;
    wire [31:0] pcout;
    //End PC
    //Start InstructMem
  //wire[31:0] pcout;
    wire [31:0] dowire;
    //End InstructMem
    //Start IFID
  //reg clk
  //wire [31:0] dowire
    wire [5:0] opwire;
    wire [5:0] funcwire;
    wire [4:0] rdwire, rtwire, rswire;
    wire [15:0] immwire;
    //End IFID
    //Start ControlUnit
  //wire [5:0] opwire;
  //wire [5:0] funcwire;
    wire wregwire, m2regwire, wmemwire, aluimmwire;
    wire regrtwire;
    wire [3:0] alucwire;
    //End ControlUnit
    //Start RegFile
    reg wewire;
  //wire [4:0] rtwire, rswire;
    wire [4:0] wnwire;
    wire [4:0] dwire;
    wire [31:0] qawire, qbwire;
    //End RegFile
    //Start ControlMux
  //wire regrtwire;
  //wire [4:0] rdwire, rtwire;
    wire [4:0] muxwire;
    //End ControlMux
    //Start SignExtend
  //wire [15:0] immwire;
    wire [31:0] longwire;
    //End SignExtend
    //Start IDEXE
  //reg clk;
  //wire wregwire, m2regwire, wmemwire, aluimmwire;
  //wire [3:0] alucwire;
  //wire [31:0] qawire, qbwire;
  //wire [4:0] muxwire;
  //wire [31:0] longwire;
    wire ewregwire, em2regwire, ewmemwire, ealuimmwire;
    wire [3:0] ealucwire;
    wire [31:0] eqbwire, eqawire, Extenderwire;
    wire [4:0] emuxwire;
    //End IDEXE

//////////////////////////////////////////////////////////////////////////////////////
    PC pc(clk,rst,pcin, pcout);
    InstructMem instmem(pcin, dowire);
    IFID ifid(clk, dowire, opwire, funcwire, rdwire, rswire, rtwire, immwire);
    ControlUnit ctrunit(opwire, funcwire, wregwire, m2regwire, wmemwire, 
                        aluimmwire, regrtwire, alucwire);
    RegFile regfile(wewire, rswire, rtwire, wnwire, dwire, qawire, qbwire);
    ControlMux ctrmux(regrtwire, rdwire, rtwire,muxwire);
    SignExtend extender(immwire, longwire);
    IDEXE idexe(clk, wregwire, m2regwire, wmemwire, aluimmwire, alucwire,
                qawire, qbwire, muxwire, longwire, ewregwire, em2regwire,
                ewmemwire, ealuimmwire, ealucwire, eqawire, eqbwire, 
                emuxwire, Extenderwire);

    initial begin
        clk = 1;
        pcin = 100;
        rst = 1;
        #1 rst = 0;     
    end

    always begin
        #5 clk = !clk;
    end
endmodule
