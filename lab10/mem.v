// a memory module
// note that addr is a byte address. To simplify our implementation
// we use addr>>2 to index the memory array. 

module mem(addr,datain,dataout, MemWrite, MemRead);

// currently the memory has 128 32-bit words
parameter mem_capacity = 4096;

input [31:0] addr, datain; /* 32bit input */
output [31:0] dataout; /* 32bit output */
reg [31:0] dataout;

// controls when writing and when readiing
input  MemWrite, MemRead; 

// memory cells are defined here
// reg [31:0] memory [mem_capacity-1:0];
reg [31:0] memory [mem_capacity-1:0];
integer i;

// reset it at the beginning
initial begin
   for (i=0; i<mem_capacity-1; i=i+1)
      memory[i] = 0;

// read initial data into the memory
// pls refer to http://www.asic-world.com/verilog/memory_fsm1.html
   $readmemh("mem.dat", memory);
end

// whenever the any of sigals (addr or datain or memwrite or memread) changes 
always @(addr or datain or MemWrite or MemRead)
begin 
   if (MemRead) /* if MemRead is true(1), do read operation */
      dataout = memory[addr>>2];
   if (MemWrite) /* if MemWrite is true(1), do write operation */
      #1 memory[addr>>2] = datain;
end 

endmodule

