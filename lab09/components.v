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

    always @(datain0 or datain1 or datain2 or datain3 or select) /* when any of inputs change */
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
