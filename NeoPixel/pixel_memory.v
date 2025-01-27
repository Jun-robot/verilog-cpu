module pixel_memory(
  input wire i_clk,
  input wire[7:0] i_rd_addr,
  input wire i_rd_wen,
  input wire[23:0] i_rd_data, //distination register

  input wire[7:0] i_rs_addr, //source register
  output wire[23:0] o_rs_data
);

  reg[23:0] mem[0:255];

  wire[23:0] wmem[0:7];  // 8個のメモリデータ
  
  assign wmem[0] = 24'hFF0000;
  assign wmem[1] = 24'h00FF00;
  assign wmem[2] = 24'h0000FF;
  assign wmem[3] = 24'hFF00FF;
  assign wmem[4] = 24'h00FFFF;
  assign wmem[5] = 24'hFFFF00;
  assign wmem[6] = 24'hFFFFFF;
  assign wmem[7] = 24'h000000;

  
  assign o_rs_data = i_rs_addr>3'b111 ? mem[i_rs_addr] : wmem[i_rs_addr];

  always @(posedge i_clk) begin
    if(i_rd_wen) begin
      mem[i_rd_addr] <= i_rd_data;
    end else begin
      mem[i_rd_addr] <= mem[i_rd_addr];
    end
  end
endmodule