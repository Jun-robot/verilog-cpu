module neopixel_wrapper(
  input wire i_clk,
  input wire i_reset,

  // input wire[7:0] i_rd_addr,
  // input wire i_rd_wen,
  // input wire[23:0] i_rd_data,

  output wire o_led_out
);

  reg r_clk = 1'b0;
  reg [31:0] r_counter = 32'd0;

  wire w_reset;
  wire w_led_out;

  always @(posedge i_clk) begin
    if(r_counter == 32'd27) begin
      r_clk <= ~r_clk;
      r_counter <= 32'd0;
    end else begin
      r_counter <= r_counter + 32'd1;
      r_clk <= r_clk;
    end
  end

  assign w_reset = ~i_reset;
  assign o_led_out = ~w_led_out;

  neopixel_driver driver(
    .i_clk(r_clk),
    .i_reset(w_reset),

    // .i_rd_addr(i_rd_addr),
    // .i_rd_wen(i_rd_wen),
    // .i_rd_data(i_rd_data),

    .o_led_out(w_led_out)
  );

endmodule