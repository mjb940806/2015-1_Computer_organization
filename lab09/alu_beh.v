/* A alu module*/
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
