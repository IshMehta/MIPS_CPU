`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2020 15:55:46
// Design Name: 
// Module Name: testbench
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


module testbench(
    );
    
    reg clk_tb;
    wire [31:0] PCout_tb ;
    wire [31:0] adderout ;
    wire [31:0] instruction_tb;
    wire [31:0] IFout_tb;
    wire [31:0] ALUmuxout_tb;
    wire [31:0] ALUout_tb;
    wire [31:0] DMout_tb;
    wire [71:0] EXEout_tb;
    wire [70:0] MEMout_tb;
    
    

    wire wreg, m2reg, aluimm, regrt, wmem;
    wire [3:0] aluc;
    wire [4:0] destAddress;
    wire [31:0] regOuta_tb, regOutb_tb, constant;
    wire [108:0] IDout_tb;
    wire [31:0] writeBackMuxOut_tb;
    
    
    
    
    PC PC_tb(clk_tb , adderout, PCout_tb);
    PCadder PCadder_tb(PCout_tb, adderout);
    InstructionMemory IM_tb(PCout_tb, instruction_tb);
    IF IF_tb(clk_tb, instruction_tb, IFout_tb);
    
    ControlUnit ControlUnit_tb (IFout_tb[31:26], IFout_tb[5:0],wreg, m2reg, wmem, aluc, aluimm, regrt);
    registerFile RF_tb (IFout_tb[25:21], IFout_tb[20:16], MEMout_tb[68:64], writeBackMuxOut_tb, MEMout_tb[70],regOuta_tb, regOutb_tb, clk_tb);
    ID ID_tb(clk_tb, wreg, m2reg, wmem, aluc, aluimm,destAddress,regOuta_tb, regOutb_tb, constant, IDout_tb   );
    addressMux addressMux_tb(regrt, IFout_tb[15:11], IFout_tb[20:16], destAddress);
    signExtend signExtend_tb(IFout_tb[15:0],constant);
    ALUmux ALUmux_tb (IDout_tb[101], IDout_tb[63:32], IDout_tb[31:0], ALUmuxout_tb );
    ALU ALU_tb(IDout_tb[105:102], IDout_tb[95:64],ALUmuxout_tb ,ALUout_tb);
    EXE EXE_tb (clk_tb, IDout_tb[108], IDout_tb[107], IDout_tb[106], IDout_tb[100:96], ALUout_tb, IDout_tb[63:32], EXEout_tb );
    DataMem DM_tb (EXEout_tb[69], EXEout_tb[63:32], EXEout_tb[31:0],DMout_tb);
    MEM MEM_tb (clk_tb, EXEout_tb[71], EXEout_tb[70], EXEout_tb[68:64], ALUout_tb, DMout_tb, MEMout_tb);
    writeBackMux writeBackMux_tb (MEMout_tb[69], MEMout_tb[63:32], MEMout_tb[31:0], writeBackMuxOut_tb );
 
    initial begin
    clk_tb = 1;
    #100 $finish;
    end
    
    always begin

    #5;
    clk_tb = ~clk_tb;
    end
endmodule