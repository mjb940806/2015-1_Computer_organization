// main control unit thant gets 
module mcu(clk, clr, OP, PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource, ALUOp, ALUSrcB, ALUSrcA, RegWrite, RegDst);
input clk, clr;
input [5:0] OP;
output PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, ALUSrcA, RegWrite, RegDst;
reg PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, ALUSrcA, RegWrite, RegDst;
output [1:0] PCSource, ALUOp, ALUSrcB;
reg [1:0] PCSource, ALUOp, ALUSrcB;
 
integer current_state;
integer next_state;

always @(current_state) /* whenever current_state is changed */
begin
   case(current_state)
   0: /* current_state 0 */
   begin
     MemWrite=0;
     IorD=0;
     MemRead=1;
     IRWrite=1;
     ALUSrcA=0;
     ALUSrcB=2'b01;
     ALUOp=2'b00;
     PCSource=2'b00;
     PCWrite=1;
     PCWriteCond=0;
     RegWrite=0;
     MemtoReg=0;
     RegDst=0;
   end
/* new code start */

   1: /* current_state 1 */
   begin
     MemRead=0;
     ALUSrcA=0;
     IRWrite=0;
     ALUSrcB=2'b11;
     ALUOp=2'b00;
     PCWrite=0;
   end

   2: /* current_state 2, OP="LW" or "SW" */
   begin
     ALUSrcA=1;
     ALUSrcB=2'b10;
     ALUOp=2'b00;
   end

   3: /* current_state 3, OP="LW" */
   begin
     MemRead=1;
     IorD=1;
   end

   4: /* current_state 4 */
   begin
     MemRead=0;
     MemtoReg=1;
     RegWrite=1;
     RegDst=0;
   end

   5: /* current_state 5, OP="SW" */
   begin
     IorD=1;
     MemWrite=1;
   end

   6: /* current_state 6, OP="R-Type" */
   begin
     ALUSrcA=1;
     ALUSrcB=2'b00;
     ALUOp=2'b10;
   end

   7: /* current_state 7 */
   begin
     MemtoReg=0;
     RegWrite=1;
     RegDst=1;
   end

   8: /*current_state 8, OP="BEQ" */
   begin
     ALUSrcA=1;
     ALUSrcB=2'b00;
     ALUOp=2'b01;
     PCSource=2'b01;
     PCWriteCond=1;
   end

   9: /* current_state 9, OP="J" */
   begin
     PCWrite=1;
     PCSource=2'b10;
   end
  
/* new code end */
   
   endcase
end

always @(posedge clk) /* whenever clock is positive edge */
begin
   //if (clr == 1'b0)
   if (clr == 1'b1)
      current_state = -1;
   else
      current_state = next_state;
end

always @(current_state or OP) /* whenever current_state or OP is changed */
begin
   next_state = -1; /* start */
   case (current_state)
   -1: /* default */
     next_state = 0;
   
   0:  /* current_state 0 */
     next_state = 1; /* next_state is 1 */

/* new code start */

   1: /* current_state 1 */
   begin
     if(OP==35||OP==43) next_state=2; /* if OP=="LW" or "SW", next_state is 2 */
     else if(OP==0) next_state=6; /* if OP=="R-Type", next_state is 6 */
     else if(OP==4) next_state=8; /* if OP=="BEQ", next_state is 8 */
     else if(OP==2) next_state=9; /* if OP=="J", next_state is 9 */
     else next_state=-1; /* default */
   end

   2: /* current_state 2 */
   begin
     if(OP==35) next_state=3; /* if OP=="LW", next_state is 3 */
     else if(OP==43) next_state=5; /* if OP=="SW", next_state is 5 */
     else next_state=-1; /* default */
   end

   3: /* current_state 3 */
     next_state=4; /* next_state is 4 */

   4: /* current_state 4 */
     next_state=0; /* next_state is 0 */

   5: /* current_state 5 */
     next_state=0; /* next_state is 0 */

   6: /* current_state 6 */
     next_state=7; /* next_state is 7 */

   7: /* current_state 7 */
     next_state=0; /* next_state is 0 */

   8: /* current_state 8 */
     next_state=0; /* next_state is 0 */

   9: /* current_state 9 */
     next_state=0; /* next_state is 0 */

/* new code end */

   default:
      next_state = -1;
   endcase
   
end

endmodule

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
	case(funct[5:0])
	  6'b100000: ALUcontrol = 3'b010; /* ADD */
	  6'b100010: ALUcontrol = 3'b110; /* SUB */
	  6'b100100: ALUcontrol = 3'b000; /* AND */
	  6'b100101: ALUcontrol = 3'b001; /* OR */
	  6'b101010: ALUcontrol = 3'b111; /* SLT */
	endcase
    2'b11: 
	case(funct[5:0])
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
