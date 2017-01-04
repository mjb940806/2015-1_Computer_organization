// Supports 2 reading ports, 1 writing port
// ADDA: reading address of A, ADDB: reading addr of B
// ADDC:  writing address of C
// clk: clock signal
// clr: clear signal
// WE:  Write Enable

module registerfile(ADDA, DATAA, ADDB, DATAB, ADDC, DATAC, clk, clr, WE);
    input [4:0]  ADDA, ADDB, ADDC; /* 5bit input */
    input [31:0] DATAC; /* 32bit input */
    input clk, clr, WE;
    output [31:0] DATAA, DATAB; /* 32bit output */

    reg [31:0] register [31:0];
    
    integer i;

    //clear all the registers in the register file
    initial begin
       for (i=0; i<32; i=i+1)
          register[i] = 0;
       $readmemh("reg.dat", register);
    end
    
    //only when a positive(rising) edge occurs
    always @(posedge clk or posedge clr) 
    begin
    
    // clear signal will reset all register as well
    if (clr)
       for (i=0; i<32; i=i+1)
          register[i] = 0;
    else
       // only when WE is 1, we write the register file 
       if (WE == 1)
       begin
          register[ADDC] = DATAC;
          register[0] = 0;
       end
    end
    
    // we always reading content of A and B
    assign DATAA = register[ADDA];
    assign DATAB = register[ADDB];
       
endmodule

