module mcu(clk, clr, OP, MemRead, MemWrite, MemtoReg, ALUOp, ALUSrc, RegWrite, RegDst, Branch, Jump);
input clk, clr;
input [5:0] OP; /* 6bit input */
output MemRead, MemWrite, MemtoReg, ALUSrc, RegWrite, RegDst, Branch, Jump; /* 1bit output */
reg MemRead, MemWrite, MemtoReg, ALUSrc, RegWrite, RegDst, Branch, Jump; /* 1bit register for output */
output [1:0] ALUOp; /* 2bit output */
reg [1:0] ALUOp; /*2bit register for output */

/* new code start */

assign clr=1'b0; /* initiate clear */

always @(clk or clr or OP) /* whenever clock or clear or OP changes */
begin

	if(clr==1'b1) /* initiate control signal */
	begin
	    MemRead=1'b0;
	    MemWrite=1'b0;
	    MemtoReg=1'b0;
	    ALUSrc=1'b0;
	    RegWrite=1'b0;
	    RegDst=1'b0;
	    Branch=1'b0;
	    Jump=1'b0;
	    ALUOp=2'b00;
	end

	else
	case(OP) /* p266 */
	  0: /* R-format */
	    begin
	    RegDst=1'b1;
	    ALUSrc=1'b0;
	    MemtoReg=1'b0;
	    RegWrite=1'b1;
	    MemRead=1'b0;
	    MemWrite=1'b0;
	    Branch=1'b0;
	    Jump=1'b0;
	    ALUOp=2'b10;
	    end
	  35: /* LW */
	    begin
	    RegDst=1'b0;
	    ALUSrc=1'b1;
	    MemtoReg=1'b1;
	    RegWrite=1'b1;
	    MemRead=1'b1;
	    MemWrite=1'b0;
	    Branch=1'b0;
	    Jump=1'b0;
	    ALUOp=2'b00;
	    end
	  43: /* SW */
	    begin
	    RegDst=1'bx;
	    ALUSrc=1'b1;
	    MemtoReg=1'bx;
	    RegWrite=1'b0;
	    MemRead=1'b0;
	    MemWrite=1'b1;
	    Branch=1'b0;
	    Jump=1'b0;
	    ALUOp=2'b00;
	    end
	  4: /* BEQ */
	    begin
	    RegDst=1'bx;
	    ALUSrc=1'b0;
	    MemtoReg=1'bx;
	    RegWrite=1'b0;
	    MemRead=1'b0;
	    MemWrite=1'b0;
	    Branch=1'b1;
	    Jump=1'b0;
	    ALUOp=2'b01;
	    end
	  2: /* JUMP */
	    begin
	    RegDst=1'b0;
	    ALUSrc=1'bx;
	    MemtoReg=1'bx;
	    RegWrite=1'b0;
	    MemRead=1'bx;
	    MemWrite=1'b0;
	    Branch=1'b0;
	    Jump=1'b1;
	    ALUOp=2'bxx;
	    end
	  default:
	    begin	
	    end
	endcase
end

endmodule

/* new code end */

module acu(funct, ALUOp, ALUcontrol);
input [5:0] funct;
input [1:0] ALUOp;
output [2:0] ALUcontrol;

reg [2:0] ALUcontrol;

always @(funct or ALUOp) /* whenever funct or ALUOp is changed */
begin
  case(ALUOp)
    2'b00: ALUcontrol = 3'b010; /* LW or SW */
/* new code start */
    2'b01: ALUcontrol = 3'b110; /* BEQ */
    2'b10: 
	case(funct)
	  6'b100000: ALUcontrol = 3'b010; /* ADD */
	  6'b100010: ALUcontrol = 3'b110; /* SUB */
	  6'b100100: ALUcontrol = 3'b000; /* AND */
	  6'b100101: ALUcontrol = 3'b001; /* OR */
	  6'b101010: ALUcontrol = 3'b111; /* SLT */
	endcase

/* new code end */
  
  endcase
end

endmodule
