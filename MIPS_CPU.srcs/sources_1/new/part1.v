`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2020 15:58:45
// Design Name: 
// Module Name: part1
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


module PC(clk, PCin, PCout);

input clk;
input   [31:0] PCin;
output reg [31:0] PCout;

always @ (posedge clk)
begin
    PCout <= PCin;
end
endmodule


module PCadder (PC, PCnext);
input  [31:0] PC;
output reg [31:0] PCnext;

initial begin
PCnext = 32'd100;
end

always @(*)
begin
PCnext = PC + 4;
end
endmodule

module InstructionMemory (address, instruction);
input  [31:0] address;
output reg [31:0] instruction;

reg [31:0] IM [0:511];


initial begin
    IM[100] = 32'b10001100001000100000000000000000 ;
    IM[104] = 32'b10001100001000110000000000000100 ;
    IM[108] = 32'b10001100001001000000000000001000 ;
    IM[112] = 32'b10001100001001100000000000001100 ;    
end

always @ (address) begin
    instruction = IM[address];
end
endmodule


module IF(clk, instructionIn, instructionOut);
input clk;
input  [31:0] instructionIn;
output reg [31:0] instructionOut;

always @ (posedge clk)
begin
    instructionOut <= instructionIn;
end

endmodule

module registerFile(
    rna, rnb, wn, d, we, qa, qb, clk
    );
    
    input [4:0] rna, rnb, wn;
    input [31:0] d;
    input clk, we;
    output  [31:0] qa, qb;
    integer i;
    
    reg [31:0] RF [31:0];   //32 register array each 32 bits long
    
    initial begin
    for (i = 0; i <32; i = i+1) begin
        RF[i] = 0;
    end
    end
    
    assign qa = RF[rna];
    assign qb = RF[rnb];
    
    
    always @ (posedge clk)
    begin
        if(we)
            RF[wn] <= d; 
    end
endmodule


module signExtend (constantIn, constantOut);
input [15:0] constantIn;
output reg [31:0] constantOut;

always @ (*) begin

constantOut = {{32{constantIn[15]}}, constantIn[15:0]};
end
endmodule

module addressMux (regrt, rd, rt, selectedAddress);
input regrt;
input [4:0] rd, rt;
output reg [4:0] selectedAddress;

always @ (*) begin
case(regrt) 
0: begin
selectedAddress = rd;
end

1: begin
selectedAddress = rt;
end

endcase
end
endmodule

module ControlUnit (op, func, wreg, m2reg, wmem, aluc, aluimm, regrt);

input [5:0] op, func;
output reg wreg, m2reg, wmem, aluimm, regrt;
output reg [3:0] aluc;



always@(*) begin
    case(op)
        6'b000000: begin    //r-format
            regrt = 1'b1;
            aluimm = 1'b0;
            m2reg = 1'b0;
            wreg = 1'b1;
            wmem = 1'b0;
            case(func)
                6'b100000: begin //add
                    aluc = 4'b0010;
                end
                
                6'b100010: begin    //subtract
                    aluc = 4'b0110;
                end
                
                6'b100100: begin    //AND
                    aluc = 4'b0000;
                end
                
                6'b100101: begin    //OR
                    aluc = 4'b0001;
                end
                
                6'b101010: begin    //slt
                    aluc = 4'b0111;
                end
            endcase
            
        end
        
        6'b100011 : begin   //lw
            regrt = 1'b0;
            aluimm = 1'b1;
            m2reg = 1'b1;
            wmem = 1'b0;
            wreg = 1'b1;
            aluc = 4'b0010;
        end
        
        6'b101011 : begin //sw
            regrt = 1'b0;   //dont care?
            aluimm = 1'b1;
            m2reg = 1'b0;
            wreg = 1'b0;
            wmem = 1'b1;
            aluc = 4'b0010;        
        end
        
        6'b000100 : begin   //beq
            regrt = 1'b0;
            aluimm = 1'b0;
            m2reg = 1'b0;
            wreg = 1'b0;
            wmem = 1'b0;
            aluc = 4'b0110;
        end
    endcase
    
end
endmodule


module ID (clk, wreg, m2reg, wmem, aluc, aluimm, destAddress, qa, qb, constant,IDout);
    input clk, wreg, m2reg, wmem, aluimm;
    input [3:0] aluc;
    input [4:0] destAddress;
    input [31:0] qa, qb, constant;
    output reg [108:0] IDout;
    
    always @ (posedge clk) begin
        IDout<= {wreg, m2reg, wmem, aluc, aluimm, destAddress, qa,qb, constant};
    end
    
endmodule


module ALUmux (ealuimm, regin, shiftin, bout);

    input ealuimm;
    input [31:0] regin, shiftin;
    output reg [31:0] bout;
    
    always@(*) begin
        case(ealuimm)
            1'b0: begin
                bout = regin;
            end
            1'b1: begin
                bout =shiftin;
            end
        endcase
    end
endmodule


module ALU (ealuc, a, b, r);
    input [3:0] ealuc;
    input [31:0] a,b;
    output reg [31:0] r;
    
    always@(*) begin
        case(ealuc)
            4'b0000: begin  //bitewise AND
                r = a&b;
            end
            4'b0001: begin  //bitewise OR
                r = a|b;
            end
            4'b0010: begin  // Add
                r = a+b;
            end
            4'b0110: begin //subtract
                r = a-b;
            end
            4'b0111: begin  //a<b
                r = (a<b)? 1'b1 : 1'b0;
            end
            4'b1100: begin // NOR
                r = ~(a|b);
            end
        endcase
    end
endmodule

module EXE(clk, ewreg, em2reg, ewmem, edestAddress, aluOut, regoutB, exeOut );
    input clk, ewreg, em2reg, ewmem;
    input [4:0] edestAddress;
    input [31:0] aluOut, regoutB;
    output reg [71:0] exeOut;
    
    always@(posedge clk) begin
        exeOut<= {ewreg, em2reg, ewmem, edestAddress, aluOut, regoutB};
    end    
endmodule

module DataMem (we, in_a, di, do);
    input we;
    input [31:0] in_a, di;
    output reg [31:0] do;
    
    reg [31:0] DF [0:1023]; 
    
    initial begin
        DF[0] = 32'hA00000AA;
        DF[4] = 32'h10000011;
        DF[8] = 32'h20000022;
        DF[12] = 32'h30000033;
        DF[16] = 32'h40000044;
        DF[20] = 32'h50000055;
        DF[24] = 32'h60000066;
        DF[28] = 32'h70000077;
        DF[32] = 32'h80000088;
        DF[36] = 32'h90000099;
    end
    
    always@(*)begin
        if(we == 1'b1) begin
            DF[in_a] = di;
        end
        else begin
            do = DF[in_a];
        end
    end
endmodule

module MEM (clk, mwreg, mm2reg, mdestAddress, mALUout, mDout,  MEMout );
    input clk, mwreg, mm2reg;
    input [4:0] mdestAddress;
    input [31:0] mALUout, mDout;
    output reg [70:0] MEMout;
    
    always@(posedge clk) begin
        MEMout<= {mwreg, mm2reg, mdestAddress, mALUout, mDout};
    end 

endmodule


module writeBackMux (wm2reg, wALUout, wDout, writeBackMuxOut);
    input wm2reg, wALUout, wDout;
    output reg [31:0] writeBackMuxOut;
    
    always@(*) begin
        case (wm2reg)
            1'b0: begin
                writeBackMuxOut = wALUout;
            end
            
            1'b1: begin
                writeBackMuxOut = wDout;
            end
        endcase
    end
endmodule
