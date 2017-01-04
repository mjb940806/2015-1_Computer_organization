`include "buffer.v"
`include "components.v"
`include "control.v"
`include "mem.v"
`include "regfile.v"

module kudragon;

reg clock,clear;

/* main control unit wire */
wire MemRead, MemWrite, MemtoReg, ALUSrc, RegWrite, RegDst, Branch, PCWrite, PCSrc, Jump;
wire [1:0] ALUOp;
wire [2:0] ALUcontrol;

/* component wire */
wire Stall, Zero, IFID_Write;
wire [31:0] PC_Out, MUX0_Out, MUX1_Out, MUX3_Out, MUX4_Out, MUX5_Out, MUX7_Out;
wire [31:0] ADD0_Out, ADD1_Out, ALU_Out;
wire [31:0] Sign_Out, Shift_Out1, Shift_Out2, IMem_Out, DMem_Out;
wire [31:0] ReadData1, ReadData2, JDDR;
wire [8:0] ControlSignal, MUX6_Out;
wire [4:0] MUX2_Out;
wire [1:0]ForwardA, ForwardB;

/* IFID buffer wire */
wire [31:0] IFID_Out1, Inst; /* IFID_Out2=Inst */
/* R-type : [31:26]0, [25:21]Rs, [20:16]Rt, [15:11]Rd, [10:6]Shamt, [5:0]funct
   Load or Store : [31:26]35 or 43, [25:21]Rs, [20:16]Rt, [15:0]address
   Branch : [31:26]4, [25:21]Rs, [20:16]Rt, [15:0]address */

/* IDEX buffer wire */
wire [31:0] IDEX_Out1, IDEX_Out2, IDEX_Out3, IDEX_Out4; 
wire [4:0] IDEX_Out5, IDEX_Out6;
wire [8:0] IDEX_Signal;

/* EXMEM buffer wire */
wire [31:0] EXMEM_Out1, EXMEM_Out2, EXMEM_Out3; 
wire [4:0] EXMEM_Out4, EXMEM_Signal;
wire EXMEM_Out5; /* Zero */

/* MEMWB buffer wire */
wire [31:0] MEMWB_Out1, MEMWB_Out2; 
wire [4:0] MEMWB_Out3;
wire [1:0] MEMWB_Signal;

/* Code Start ! */

/* IF Step */
assign PCSrc=Branch&Zero; 
mux2to1 MUX0 (ADD0_Out, EXMEM_Out1, MUX0_Out, PCSrc); /* for new PC*/
single_register PC (MUX7_Out, PC_Out, clock, clear, PCWrite); 
ALU ADD0 (PC_Out, 4, 3'b010, ADD0_Out, ); /* Adder for PC+4 */
mem I_Mem (PC_Out, ,IMem_Out, 1'b0, 1'b1); /* Always read mem.dat */

IFID IFID_buffer(ADD0_Out, IMem_Out, IFID_Out1, Inst, clock, clear, 1'b1);

/* ID Step */
registerfile RF (Inst[25:21], ReadData1, Inst[20:16], ReadData2, MEMWB_Out3, MUX3_Out, clock, clear, RegWrite); /* for R-type ALU operation */
signextd SE (Inst[15:0], Sign_Out); /* for load and store */

mcu MCU0(clock, clear, Inst[31:26], MemRead, MemWrite, MemtoReg, ALUOp, ALUSrc, RegWrite, RegDst, Branch, Jump);
assign ControlSignal={Branch, RegDst, RegWrite, ALUSrc, ALUOp, MemtoReg, MemWrite, MemRead};

ForwardingUnit FU (Inst[25:21], Inst[20:16], EXMEM_Signal[3], MUX2_Out, MEMWB_Signal[1], MEMWB_Out3, IDEX_Signal[4:3], ForwardA, ForwardB);

HazardDetectionUnit HDU(Inst[25:21], Inst[20:16], IDEX_Signal[0], IDEX_Out5, IFID_Write, PCWrite, Stall);
mux2to1_9bit MUX6 (ControlSignal, 0, MUX6_Out, Stall); /* new MUX - p319 */

IDEX IDEX_buffer(IFID_Out1, ReadData1, ReadData2, Sign_Out, Inst[20:16], Inst[15:11], IDEX_Out1, IDEX_Out2, IDEX_Out3, IDEX_Out4, IDEX_Out5, IDEX_Out6, clock, clear, 1'b1, ControlSignal, IDEX_Signal);

/* EX Step */
shiftleft2 SL0 (IDEX_Out4, Shift_Out1);
ALU ADD1 (IDEX_Out1, Shift_Out1, 3'b010, ADD1_Out, ); /* ADD1_Out : branch target */
mux2to1 MUX1 (MUX5_Out, IDEX_Out3, MUX1_Out, ALUSrc);
mux2to1_5bit MUX2 (IDEX_Out5, IDEX_Out6, MUX2_Out, RegDst);
acu ACU(IDEX_Out4[5:0], ALUOp, ALUcontrol); 
ALU ALU0 (MUX4_Out, MUX5_Out, ALUcontrol, ALU_Out, Zero); /* Zero : to branch control unit */

mux4to1 MUX4 (IDEX_Out1, MUX3_Out, EXMEM_Out2, 0, MUX4_Out, ForwardA); /* new MUX for Forwarding - p314 */
mux4to1 MUX5 (IDEX_Out2, MUX3_Out, EXMEM_Out2, 0, MUX5_Out, ForwardB); /* new MUX for Forwarding - p314 */

EXMEM EXMEM_buffer(ADD1_Out, ALU_Out, IDEX_Out3, MUX2_Out, Zero, EXMEM_Out1, EXMEM_Out2, EXMEM_Out3, EXMEM_Out4, EXMEM_Out5, clock, clear, 1'b1, {IDEX_Signal[8], IDEX_Signal[6], IDEX_Signal[2:0]}, EXMEM_Signal);

/* MEM Step */
mem D_Mem (EXMEM_Out2, EXMEM_Out3, DMem_Out, MemWrite, MemRead); /* for load and store */

MEMWB MEMWB_buffer (DMem_Out, EXMEM_Out2, EXMEM_Out4, MEMWB_Out1, MEMWB_Out2, MEMWB_Out3, clock, clear, 1'b1, {EXMEM_Signal[3], EXMEM_Signal[2]}, MEMWB_Signal);

/* WB Step */
mux2to1 MUX3 (MEMWB_Out1, MEMWB_Out2, MUX3_Out, MemtoReg);

/* for Jump Operation - p272 */
shiftleft2 SL1 ({6'b0,Inst[25:0]}, Shift_Out2);
concatenate4to28 Con(Shift_Out2, ADD0_Out, JDDR);
mux2to1 MUX7 (MUX0_Out, JDDR, MUX7_Out, Jump);

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
