module
  Z16RegisterFile(
    input wire i_clk,
    input wire [3:0] i_rs1_addr, //register source 1
    output wire [15:0] o_rs1_data,

    input wire [3:0] i_rs2_addr, //register source 2
    output wire [15:0] o_rs2_data,

    input wire [3:0] i_rd_addr, //register destination
    input wire i_rd_wen, //write enable
    input wire [15:0] i_rd_data
  );

  //register file
  reg [15:0] mem[15:0];

  //read data
  //address 0 is always 0
  assign o_rs1_data = (i_rs1_addr == 4'h0) ? 16'h0000 : mem[i_rs1_addr];
  assign o_rs2_data = (i_rs2_addr == 4'h0) ? 16'h0000 : mem[i_rs2_addr];

  //write data
  always @(posedge i_clk) begin
    if(i_rd_wen) begin
      mem[i_rd_addr] <= i_rd_data;
    end else begin
      mem[i_rd_addr] <= mem[i_rd_addr]; //ここの必要性が不明
    end
  end
endmodule