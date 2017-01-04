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
