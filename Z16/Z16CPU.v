module Z16CPU(
  input wire i_clk,
  input wire i_rst
);

  //program counter
  reg[15:0] r_pc;

  wire[15:0] w_instr;
  wire[3:0] w_rd_addr; //destination register address
  wire[3:0] w_rs1_addr; //source register address
  wire[3:0] w_rs2_addr; //source register address

  wire[15:0] w_imm; //immediate value
  wire w_rd_wen; //write enable for destination register
  wire w_mem_wen; //write enable for memory
  wire[3:0] w_alu_ctrl; //ALU control signal
  
  wire[3:0] w_opcode;
  wire[15:0] w_data_b;

  wire[15:0] w_rs1_data; //source register data
  wire[15:0] w_rs2_data; //source register data
  wire[15:0] w_rd_data;

  wire[15:0] w_alu_data; //ALU output
  wire[15:0] w_mem_rdata; //memory data

  always @(posedge i_clk) begin
    if(i_rst) begin
      r_pc <= 16'h0000;
    end else begin
      r_pc <= r_pc + 16'h0002;
    end
  end


  Z16InstrMemory InstrMem(
    .i_addr (r_pc),
    .o_instr(w_instr)
  );

  Z16Decoder Decoder(
    .i_instr (w_instr),
    .o_opcode (w_opcode),
    .o_rd_addr (w_rd_addr),
    .o_rs1_addr (w_rs1_addr),
    .o_rs2_addr (w_rs2_addr),
    .o_imm (w_imm),
    .o_rd_wen (w_rd_wen),
    .o_mem_wen (w_mem_wen),
    .o_alu_ctrl (w_alu_ctrl)
  );

  assign w_rd_data = (w_opcode[3:0]==4'hA) ? w_mem_rdata : w_alu_data;
  Z16RegisterFile RegFile(
    .i_clk (i_clk),
    .i_rs1_addr (w_rs1_addr),
    .o_rs1_data (w_rs1_data),
    .i_rs2_addr (w_rs2_addr),
    .o_rs2_data (w_rs2_data),
    .i_rd_data  (w_rd_data),
    .i_rd_addr  (w_rd_addr),
    .i_rd_wen   (w_rd_wen)
  );

  assign w_data_b = (w_opcode <= 4'h8) ? w_rs2_data : w_imm; //select data_b
  Z16ALU ALU(
    .i_data_a (w_rs1_data),
    .i_data_b (w_data_b),
    .i_ctrl   (w_alu_ctrl),
    .o_data   (w_alu_data)
  );

  Z16DataMemory DataMem(
    .i_clk (i_clk),
    .i_addr (w_alu_data),
    .i_wen (w_mem_wen),
    .i_data (w_rs2_data),
    .o_data (w_mem_rdata)
  );
endmodule