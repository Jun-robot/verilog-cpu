module pixel_memory(
  input wire i_clk,
  input wire[7:0] i_rd_addr,
  input wire i_rd_wen,
  input wire[23:0] i_rd_data, //distination register

  input wire[7:0] i_rs_addr, //source register
  output wire[23:0] o_rs_data
);

  reg[23:0] mem[0:255];
  
  assign o_rs_data = mem[i_rs_addr];

  always @(posedge i_clk) begin
    if(i_rd_wen) begin
      mem[i_rd_addr] <= i_rd_data;
    end else begin
      mem[i_rd_addr] <= mem[i_rd_addr];
    end
  end
endmodule