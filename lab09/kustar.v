`include "mem_beh.v"
`include "regfile_beh.v"
`include "components.v"
`include "control_units.v"
`include "alu_beh.v"
`include "mux2to1_beh.v"

/* dat file : c:/Modeltech/examples */

module kustar;
reg clock, clear;

wire [5:0] Op ;
wire PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite,  ALUSrcA, RegWrite, RegDst;
wire [1:0] PCSource, ALUOp, ALUSrcB;

wire [2:0] ALUcontrol;
wire Zero;

wire [31:0] MuxtoPC, PCtoMux, MuxtoMem, MemtoInstReg, SigntoShift, ShifttoMux, MemdatatoMux, MuxtoWriteData;
wire [31:0] RegtoA, RegtoB, AtoMux, BtoMux, AMuxtoALU, BMuxtoALU, ALUtoALUOut, ALUOuttoMux , ShifttoConcat, ConcattoMux;
wire [4:0] Rs, Rt, MuxtoWriteReg;
wire [15:0] AddrorConst ;

single_register PC (MuxtoPC, PCtoMux, clock, clear, (Zero&PCWriteCond)|PCWrite); /* PC register */

/* new code start */

/* module single_register input outpout type : (datain, dataout, clk, clr, WE) */
single_register IR (MemtoInstReg, {Op,Rs,Rt,AddrorConst}, clock, clear, IRWrite); /* Instruction Register */
single_register MDR (MemtoInstReg, MemdatatoMux, clock, clear, 1'b1); /* Memory Data Register */
single_register RRA (RegtoA, AtoMux, clock, clear, 1'b1); /* Read Register A */
single_register RRB (RegtoB, BtoMux, clock, clear, 1'b1); /* Read Register B */
single_register ALUOut (ALUtoALUOut, ALUOuttoMux, clock, clear, 1'b1); /* ALUOut Register */

/* module mux2to1 input output type : (datain0,datain1, dataout, select) */
mux2to1 mux0 (PCtoMux, ALUOuttoMux, MuxtoMem, IorD); /* PC Mux */
mux2to1_5bit mux1 (Rt, AddrorConst[15:11], MuxtoWriteReg, RegDst); /* Inst Mux */
mux2to1 mux2 (ALUOuttoMux, MemdatatoMux, MuxtoWriteData, MemtoReg); /* MDR Mux */
mux2to1 mux3 (PCtoMux, AtoMux, AMuxtoALU, ALUSrcA); /* RRA Mux */

/* module mux4to1 input output type : (datain0, datain1, datain2, datain3, dataout, select) */
mux4to1 mux4 (BtoMux, 4, SigntoShift, ShifttoMux, BMuxtoALU, ALUSrcB); /* RRB Mux */
mux4to1 mux5 (ALUtoALUOut, ALUOuttoMux, ConcattoMux, 0, MuxtoPC, PCSource); /* MUX 3 to 1 */

/* module signextd input output type : (datain, dataout) */
signextd signextd (AddrorConst, SigntoShift); /* 16bit to 32bit */

/* module shiftleft2 input output type : (datain, dataout) */
shiftleft2 shiftleft0 ({6'd0,Rs,Rt,AddrorConst}, ShifttoConcat); 
shiftleft2 shiftleft1 (SigntoShift, ShifttoMux); 

/* module concatenate4to28 input output type : (datain, pcin, pcout) */
concatenate4to28 concatenate0(ShifttoConcat, PCtoMux, ConcattoMux); 
/* ConcattoMux consists of 4bits of PCtoMux's left side and 28bits of ShifttoConcat's right side */

/* module ALU input output type : (inputA, inputB, ALUop, result, zero) */
ALU ALU (AMuxtoALU, BMuxtoALU, ALUcontrol, ALUtoALUOut, Zero); /* AND, OR, ADD, ,SUB, SLT with a zero output */

/* module mcu input output type : (clk, clr, OP, PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst) */
mcu MainControlUnit (clock, clear, Op, PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst); /* changing states */

/* module acu input output type : (funct, ALUOp, ALUcontrol) */
acu ALUControlUnit (AddrorConst[5:0], ALUOp, ALUcontrol); /* changing operations according to ALUOp */

/* module registerfile input output type : (ADDA, DATAA, ADDB, DATAB, ADDC, DATAC, clk, clr, WE) */
registerfile RegisterFile(Rs, RegtoA, Rt, RegtoB, MuxtoWriteReg, MuxtoWriteData, clock, 1'b0, RegWrite); /* registerfile */

/* module mem input output type : (addr,datain,dataout, MemWrite, MemRead) */
mem Mem(MuxtoMem,BtoMux,MemtoInstReg, MemWrite, MemRead); /* memory */

/* new code end */

initial
   forever #50 clock = ~clock;

initial 
begin
   clock = 0;
   clear = 1;
   /* we may not connect clear to register file and memory because we don't want our initial data get cleared*/
   #10 clear = 0;
end

initial 
#10000 $stop;

endmodule