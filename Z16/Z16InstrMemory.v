module Z16InstrMemory(
  input wire[15:0] i_addr,
  output wire[15:0] o_instr
);

  wire[15:0] mem[10:0];

  assign o_instr = mem[i_addr[15:1]];

  // assign mem[0] = 16'h0A19;
  // assign mem[1] = 16'h1220;
  // assign mem[2] = 16'hFF19;
  // assign mem[3] = 16'hFC4F;
  // assign mem[4] = 16'h00FD;
  

  assign mem[0] = 16'h0040; // ADD ZR ZR G0
  assign mem[1] = 16'h605D; // JRL 6 ZR G1
  assign mem[2] = 16'h0000; // ADD ZR ZR ZR
  assign mem[3] = 16'h0000; // ADD ZR ZR ZR
  assign mem[4] = 16'h006C; // JAL 0 ZR G2


endmodule