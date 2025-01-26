
module neopixel_driver(
  input wire i_clk,
  input wire i_reset, 

  input wire[7:0] i_rd_addr,
  input wire i_rd_wen,
  input wire[23:0] i_rd_data,

  output wire o_led_out
);

  wire[7:0] w_mem_addr;
  wire[23:0] w_mem_data;

  pixel_memory npx_mem(
    .i_clk(i_clk),
    .i_rd_addr(i_rd_addr),
    .i_rd_wen(i_rd_wen),
    .i_rd_data(i_rd_data),

    .i_rs_addr(w_mem_addr),
    .o_rs_data(w_mem_data)
  );

  neopixel_tx npx_tx(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_start(1'b1),

    .o_mem_addr(w_mem_addr),
    .i_mem_data(w_mem_data),

    .o_led_out(o_led_out)
  );

endmodule