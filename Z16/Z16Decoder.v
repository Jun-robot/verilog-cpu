module Z16Decoder(
  input wire[15:0] i_instr,
  output wire[3:0] o_opcode,
  output wire[3:0] o_rd_addr,
  output wire[3:0] o_rs1_addr,
  output wire[3:0] o_rs2_addr,

  output wire[15:0] o_imm, //immediate value
  output wire o_rd_wen, //write enable for destination register
  output wire o_mem_wen, //write enable for memory
  output wire[3:0] o_alu_ctrl //ALU control signal
);

  assign o_opcode = i_instr[3:0];
  assign o_rd_addr = i_instr[7:4];
  assign o_rs1_addr = get_rs1_addr(i_instr);
  assign o_rs2_addr = i_instr[15:12];

  assign o_imm = get_imm(i_instr);
  assign o_rd_wen = get_rd_wen(i_instr);
  assign o_mem_wen = get_mem_wen(i_instr);
  assign o_alu_ctrl = get_alu_ctrl(i_instr);

  function[3:0] get_rs1_addr;
    input[15:0] i_instr;
    begin
      case(i_instr[3:0])
        4'h9 : get_rs1_addr = i_instr[7:4]; //add immediate
        default : get_rs1_addr = i_instr[11:8]; 
      endcase
    end
  endfunction

  function[15:0] get_imm;
    input[15:0] i_instr;
    begin
      case(i_instr[3:0]) //opcode
        4'h9 : get_imm = {{8{i_instr[15]}}, i_instr[15:8]}; //add immediate
        4'hA : get_imm = {{12{i_instr[15]}}, i_instr[15:12]};  //load
        4'hB : get_imm = {{12{i_instr[7]}}, i_instr[7:4]};  //store
        4'hC : get_imm = {{12{i_instr[15]}}, i_instr[15:12]};  //jal
        4'hD : get_imm = {{12{i_instr[15]}}, i_instr[15:12]};  //jrl
        default : get_imm = 16'h0000;
      endcase
    end
  endfunction

  function get_rd_wen;
    input[15:0] i_instr;
    begin 
      if(i_instr[3:0] <=4'hA) begin //culuclation, addi, load
        get_rd_wen = 1'b1;
      end else if((i_instr[3:0]==4'hC) || (i_instr[3:0]==4'hD)) begin //jal, jrl
        get_rd_wen = 1'b1;
      end else begin
        get_rd_wen = 1'b0;
      end
    end
  endfunction

  function get_mem_wen;
    input[15:0] i_instr;
    begin 
      if(4'hA == i_instr[3:0]) begin //load
        get_mem_wen = 1'b0;
      end else if(4'hB == i_instr[3:0]) begin //store
        get_mem_wen = 1'b1;
      end else begin
        get_mem_wen = 1'b0;
      end
    end
  endfunction

  function [3:0] get_alu_ctrl;
    input[15:0] i_instr;
    begin
      if(i_instr[3:0] <= 4'h8) begin //culuclation
        get_alu_ctrl = i_instr[3:0];
      end else begin
        get_alu_ctrl = 4'h0; //ADD
      end
    end
  endfunction

endmodule