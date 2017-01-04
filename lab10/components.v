module ALU(inputA, inputB, ALUop, result, zero);
input [31:0] inputA, inputB; /* 32bit input */
input [2:0] ALUop; /* 3bit ALUoperation */

output [31:0] result; /* 32bit output */
reg [31:0] result;
output zero; /* for checking whether inputA and inputB are same */
reg zero;

/*whenever input or ALUop changes*/
always @(inputA or inputB or ALUop) /* when inputA or inputB or ALUop changes */
begin 
/*it supports AND, OR, ADD, ,SUB, SLT with a zero output*/

/* new code start */
   
	case(ALUop) /* according to ALUop */
		3'b000: result=inputA&inputB; /* when ALUop value is X00, do and operation */ 
		3'b100: result=inputA&inputB;
		3'b001: result=inputA|inputB;  /* when ALUop value is X01, do or operation */ 
		3'b101: result=inputA|inputB;
		3'b010: result=inputA+inputB; /* when ALUop value is 010, do add operation */ 
		3'b110: result=inputA-inputB; /* when ALUop value is 110, do sub operation */ 
		3'b011: if(inputA<inputB)result=1; /* when ALUop value is X11, do SLT operation */
			else result=0;
		3'b111: if(inputA<inputB)result=1; /* if inputA is less than inputB, change the result value to 1 */
			else result=0;
		default: result=1'bx; /* if ALUop value is not in range */

/* new code end */

	endcase

   if (inputA == inputB) /* if inputA and inputB are same */
       zero = 1; /* change the zero value to 1 */
   else /* if inputA and inputB are not same */
       zero = 0; /* change the zero value to 0 */

end 
endmodule

module single_register(datain, dataout, clk, clr, WE);
    input [31:0] datain; /* 32bit input */
    output [31:0] dataout; /* 32bit output */
    input clk, clr, WE; /* clk:clock signal, clr:clear signal, WE:Write Enable */

    reg [31:0] register;

    /* new code start */

    always @(posedge clk or posedge clr) /* when clk or clr is positive */
    begin
	if(clr) register=0; /* if clr is 0, change the register value to 0 */
	else if(WE) register=datain; /* else if WE is true (1), change the register value to datain */
    end

    assign dataout=register; /* assign the register value to the dataout */

    /* new code end */
       
endmodule

module mux4to1(datain0, datain1, datain2, datain3, dataout, select);
    input [31:0] datain0, datain1, datain2, datain3; /* 32bit input */
    input[1:0] select; /* 2bit select */
    output [31:0] dataout; /* 32bit output */
    reg [31:0] data;

    /* new code start */

    always @(datain0 or datain1 or datain2 or datain3 or select) /* when any of inputs changes */
    begin

    case(select) /* according to select */
	2'b00: data=datain0; /* if select value is 00, then change dataout to datain0 */
	2'b01: data=datain1; /* if select value is 01, then change dataout to datain1 */
	2'b10: data=datain2; /* if select value is 10, then change dataout to datain2 */
	2'b11: data=datain3; /* if select value is 11, then change dataout to datain3 */
    endcase

    end

    assign dataout=data;

    /* new code end */

endmodule

module signextd(datain, dataout);
    input [15:0] datain; /* 16bit input */
    output [31:0] dataout; /* 32bit output */
    reg [31:0] dataout;

    /* new code start */

    always @(datain) /* when datain changes */
    begin
	dataout={{16{datain[15]}},datain[15:0]}; /* append digits to the most significant side of number, dependent on the signed number */
    end

    /* new code end */
   
endmodule

module shiftleft2(datain, dataout);
    input [31:0] datain; /* 32 bit input */
    output [31:0] dataout; /* 32 bit output */
    reg [31:0] dataout;

    /* new code start */

    always @(datain) /* when the datain changes */
 
    begin
	dataout=datain<<2; /* dataout = shift left datain by 2bit */ 
    end

    /* new code end */

endmodule

/* concatenate pcin[31-28] with datain[27-0] to form a jump address*/
module concatenate4to28(datain, pcin, pcout);
    input [31:0] datain, pcin; /* 32bit input and pcin */
    output [31:0] pcout; /* 32bit output */
    reg [31:0] pcout;

/* new code start */

    always @(datain or pcin) /* when datain or pcin changes */
    begin
	pcout={pcin[31:28],datain[27:0]}; /* pcout consists of 4bits of pcin's left side and 28bits of datain's right side */
    end

/*new code end */

endmodule

/* new code start */
module ForwardingUnit(IDEX_Rs, IDEX_Rt, EXMEM_RegWrite, EXMEM_Rd, MEMWB_RegWrite, MEMWB_Rd, ALUOp, ForwardA, ForwardB);

input [4:0] IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd; /* 5bit input */
input EXMEM_RegWrite, MEMWB_RegWrite; /* 1bit input */
input [1:0] ALUOp; /* 2bit input for OP checking */

output [1:0] ForwardA, ForwardB; /* 2bit output */

reg [1:0] A,B; /* 2bit register for output */

always @(IDEX_Rs or IDEX_Rt or EXMEM_RegWrite or EXMEM_Rd or MEMWB_RegWrite or MEMWB_Rd) /* whenever any of inputs changes */
begin

/* initiate regiters */

  A=2'b00;
  B=2'b00;

/* EX hazard -p311 */

  if((EXMEM_RegWrite==1'b1)&&(EXMEM_Rd!=0)&&(EXMEM_Rd==IDEX_Rs))
  begin
    if(ALUOp==2'b10) 
	A=2'b11;
    else
	A=2'b10;
  end

  if((EXMEM_RegWrite==1'b1)&&(EXMEM_Rd!=0)&&(EXMEM_Rd==IDEX_Rt))
  begin
    if(ALUOp==2'b10)
	B=2'b11;
    else
	B=2'b10;
  end

/* MEM hazard -p314 */

  if(/* for EX hazard */(MEMWB_RegWrite==1'b1)&&(MEMWB_Rd!=0)&&(MEMWB_Rd==IDEX_Rs)&&/* for MEM hazard */(EXMEM_Rd!=IDEX_Rs))
  begin
    A=2'b01;
  end

  if(/* for EX hazard */(MEMWB_RegWrite==1'b1)&&(MEMWB_Rd!=0)&&(MEMWB_Rd==IDEX_Rt)&&/* for MEM hazard */(EXMEM_Rd!=IDEX_Rt))
  begin
    B=2'b01;
  end
end

assign ForwardA=A;
assign ForwardB=B;

endmodule

module HazardDetectionUnit(IFID_Rs, IFID_Rt, IDEX_MemRead, IDEX_Rt, IFID_Write, PC_Write, Stall);

/* p315 */
input [4:0] IFID_Rs, IFID_Rt, IDEX_Rt; /* 5bit input */
input IDEX_MemRead; /* 1bit input */

output IFID_Write, PC_Write, Stall; /* 1bit output */

reg IFID_Write_reg, PC_Write_reg, Stall_reg; /* 1bit register for output */

always @(IFID_Rs, IFID_Rt, IDEX_MemRead, IDEX_Rt) /* whenever any of inputs cahnges */
begin

/* initiate registers */

  IFID_Write_reg=1;
  PC_Write_reg=1;
  Stall_reg=0;

  if((IDEX_MemRead==1)&&((IDEX_Rt==IFID_Rs)||(IDEX_Rt==IFID_Rt)))
  begin

/* stall the pipeline */

    IFID_Write_reg=0;
    PC_Write_reg=0;
    Stall_reg=1;

  end
end

assign IFID_Write=IFID_Write_reg;
assign PC_Write=PC_Write_reg;
assign Stall=Stall_reg;

endmodule

/* new code end */

/* 2 to 1 MUX, select from two 32-bit input*/
module mux2to1(datain0,datain1, dataout, select);
input [31:0] datain0, datain1;
input select;
output [31:0] dataout; 
reg [31:0] dataout;

/*whenever datain0 or datain1 or select signals is changed*/
    always @(datain0 or datain1 or select) /* when any of inputs or select changes */
    begin 
    if (select == 0) /* if select value is 0, select datain0 */
       dataout = datain0;
    else /* if select value is 1, select datain1 */
       dataout = datain1;
    end 
endmodule

module mux2to1_5bit(datain0, datain1, dataout, select);
  
input [4:0] datain0, datain1;
input select;
output reg [4:0] dataout;

/*whenever datain0 or datain1 or select signals is changed*/

/* new code start */

    always @(datain0 or datain1 or select) /* when any of inputs or select changes */
    begin 
    if (select == 0) /* if select value is 0, select datain0 */
       dataout = datain0;
    else /* if select value is 1, select datain1 */
       dataout = datain1;
    end 

/* new code end */

endmodule

module mux2to1_9bit(datain0, datain1, dataout, select);
  
input [8:0] datain0, datain1;
input select;
output reg [8:0] dataout;

/*whenever datain0 or datain1 or select signals is changed*/

/* new code start */

    always @(datain0 or datain1 or select) /* when any of inputs or select changes */
    begin 
    if (select == 0) /* if select value is 0, select datain0 */
       dataout = datain0;
    else /* if select value is 1, select datain1 */
       dataout = datain1;
    end 

/* new code end */

endmodule
