module IFID(datain0, datain1, dataout0, dataout1, clk, clr, WE);
/* buffer from IF to ID */

input clk,clr,WE;
input [31:0] datain0, datain1; /* 32bit input */
output [31:0] dataout0, dataout1; /* 32bit output */

reg [31:0] reg0, reg1; /* 32bit register for output */

always@(posedge clk) /* only when clock is positive */
begin

  if(clr==1'b1) /* reset */
	begin
	 reg0=32'b0;
	 reg1=32'b0;
        end

  else if(WE==1'b1) /* Write Enable */
	begin
	 reg0=datain0;
	 reg1=datain1;
	end

end

assign dataout0=reg0;
assign dataout1=reg1;

endmodule

module IDEX(datain0, datain1, datain2, datain3, datain4, datain5, dataout0, dataout1, dataout2, dataout3, dataout4, dataout5, clk, clr, WE, Signal_In, Signal_Out);
/* buffer from ID to EX */

input clk,clr,WE;
input [31:0] datain0, datain1, datain2, datain3; /* 32bit input */
input [4:0] datain4, datain5; /* 5bit input */
input [8:0] Signal_In; /* 9bit input - Signal_In : Branch, RegDst, RegWrite, ALUSrc, ALUOp(2), MemtoReg, MemWrite, MemRead */

output [31:0] dataout0, dataout1, dataout2, dataout3; /* 32bit output */
output [4:0] dataout4, dataout5; /* 5bit output */
output [8:0] Signal_Out; /* 9bit output */

reg [31:0] reg0, reg1, reg2, reg3; /* 32bit register for output */
reg [4:0] reg4, reg5; /* 5bit register for output */
reg [8:0] signal; /* 9bit register for output */

always@(posedge clk) /* only when clock is positive */
begin

  if(clr==1'b1) /* reset */
	begin
	 reg0=32'b0;
	 reg1=32'b0;
	 reg2=32'b0;
	 reg3=32'b0;
	 reg4=5'b0;
	 reg5=5'b0;
	 signal=Signal_In;
        end

  else if(WE==1'b1) /* Write Enable */
	begin
	 reg0=datain0;
	 reg1=datain1;
	 reg2=datain2;
	 reg3=datain3;
	 reg4=datain4;
	 reg5=datain5;
	 signal=Signal_In;
	end

end

assign dataout0=reg0;
assign dataout1=reg1;
assign dataout2=reg2;
assign dataout3=reg3;
assign dataout4=reg4;
assign dataout5=reg5;
assign Signal_Out=signal;

endmodule
	
module EXMEM(datain0, datain1, datain2, datain3, datain4, dataout0, dataout1, dataout2, dataout3, dataout4, clk, clr, WE, Signal_In, Signal_Out);
/* buffer from EX to MEM */

input clk,clr,WE;
input [31:0] datain0, datain1, datain2; /* 32bit input */
input [4:0] datain3, Signal_In; /* 5bit input - Signal_In : Branch, RegWrite, MemtoReg, MemWrite, MemRead */
input datain4; /* 1bit input */ 

output [31:0] dataout0, dataout1, dataout2; /* 32bit output */
output [4:0] dataout3, Signal_Out; /* 5bit output */
output dataout4; /* 1bit output */

reg [31:0] reg0, reg1, reg2; /* 32bit register for output */
reg [4:0] reg3, signal; /* 5bit register for output */
reg reg4; /* 1bit register for output */

always@(posedge clk) /* only when clock is positive */
begin

  if(clr==1'b1) /* reset */
	begin
	 reg0=32'b0;
	 reg1=32'b0;
	 reg2=32'b0;
	 reg3=5'b0;
	 reg4=1'b0;
	 signal=Signal_In;
        end

  else if(WE==1'b1) /* Write Enable */
	begin
	 reg0=datain0;
	 reg1=datain1;
	 reg2=datain2;
	 reg3=datain3;
	 reg4=datain4;
	 signal=Signal_In;
	end

end

assign dataout0=reg0;
assign dataout1=reg1;
assign dataout2=reg2;
assign dataout3=reg3;
assign dataout4=reg4;
assign Signal_Out=signal;


endmodule

module MEMWB(datain0, datain1, datain2, dataout0, dataout1, dataout2, clk, clr, WE, Signal_In, Signal_Out);
/* buffer from MEM to WB */

input clk,clr,WE;
input [31:0] datain0, datain1; /* 32bit input */
input [4:0] datain2; /* 5bit input */
input [1:0] Signal_In; /* 2bit input - Signal_In : RegWrite, MemtoReg */

output [31:0] dataout0, dataout1; /* 32bit output */
output [4:0] dataout2; /* 5bit output */
output [1:0] Signal_Out; /* 2bit output */

reg [31:0] reg0, reg1; /* 32bit register for output */
reg [4:0] reg2; /* 5bit register for output */
reg [1:0] signal; /* 2bit register for output */

always@(posedge clk) /* only when clock is positive */
begin

  if(clr==1'b1) /* reset */
	begin
	 reg0=32'b0;
	 reg1=32'b0;
	 reg2=5'b0;
	 signal=Signal_In;
        end

  else if(WE==1'b1) /* Write Enable */
	begin
	 reg0=datain0;
	 reg1=datain1;
	 reg2=datain2;
	 signal=Signal_In;
	end

end

assign dataout0=reg0;
assign dataout1=reg1;
assign dataout2=reg2;
assign Signal_Out=signal;

endmodule

