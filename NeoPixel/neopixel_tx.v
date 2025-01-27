module neopixel_tx(
  input wire i_clk, //27MHz 0.037us
  input wire i_reset,
  input wire i_start,

  output reg [7:0] o_mem_addr,
  input wire[23:0] i_mem_data,

  output reg o_led_out
);

  localparam NUM_PIXELS = 16'd8;

  localparam T0H_CYCLES = 16'd8;
  localparam T0L_CYCLES = 16'd24;
  localparam T1H_CYCLES = 16'd16;
  localparam T1L_CYCLES = 16'd16;
  localparam TRESET_CYCLES = 16'd2200;

  localparam S_IDLE  = 3'd0;
  localparam S_HIGH  = 3'd1;
  localparam S_LOW   = 3'd2;
  localparam S_RESET = 3'd3;
  localparam S_DONE  = 3'd4;
  
  //ステータス保持
  reg[2:0] r_state;
  //ステータス遷移用
  reg[2:0] r_next_state;

  //タイミングカウンタ
  reg [15:0] r_counter;

  //送信対象ピクセル番号
  reg[7:0] r_pixel_index; //0-255
  //ピクセル内ビット送信カウンタ
  reg[4:0] r_bit_index; //0-23
  //送信中ピクセルのシフトレジスタ
  reg[23:0] r_shift_reg;


  //-----------------------------------------------------
  // メイン
  //-----------------------------------------------------
  always @(posedge i_clk or posedge i_reset) begin
    if (i_reset) begin
      // リセット時初期化
      r_state       <= S_IDLE;
      o_led_out     <= 1'b0;
      o_mem_addr    <= 8'd0;
      r_counter     <= 16'd0;
      r_pixel_index <= 8'd0;
      r_bit_index   <= 5'd0;
      r_shift_reg   <= 24'd0;
    end else begin
      case (r_state)

      //----------------------------------------------
      // 送信待機状態
      //----------------------------------------------
      S_IDLE: begin
        o_led_out <= 1'b0;
        // スタート要求が来たら送信開始
        if (i_start) begin
          r_state       <= S_HIGH;
          r_pixel_index <= 8'd0;
          r_bit_index   <= 5'd0;
          o_mem_addr    <= 8'd0;       // ピクセル0 を読み出す
          r_shift_reg   <= i_mem_data;
          r_counter     <= 16'd0;
        end
      end

      //----------------------------------------------
      // ビットのHIGH区間
      //----------------------------------------------
      S_HIGH: begin
        // カウンタ0のタイミングで立ち上げる
        if (r_counter == 16'd0) begin
          o_led_out <= 1'b1;
        end

        r_counter <= r_counter + 16'd1;

        // 現在送信中のビット値を判定
        if (r_shift_reg[23] == 1'b1) begin
          // '1'ビット => T1H_CYCLESだけHIGH
          if (r_counter >= (T1H_CYCLES - 1)) begin
            r_state   <= S_LOW;
            r_counter <= 16'd0;
          end
        end else begin
          // '0'ビット => T0H_CYCLESだけHIGH
          if (r_counter >= (T0H_CYCLES - 1)) begin
            r_state   <= S_LOW;
            r_counter <= 16'd0;
          end
        end
      end

      //----------------------------------------------
      // ビットのLOW区間
      //----------------------------------------------
      S_LOW: begin
        // カウンタ0のタイミングで立ち下げる
        if (r_counter == 16'd0) begin
          o_led_out <= 1'b0;
        end

        r_counter <= r_counter + 16'd1;

        if (r_shift_reg[23] == 1'b1) begin
          // '1'ビット => T1L_CYCLESだけLOW
          if (r_counter >= (T1L_CYCLES - 1)) begin
            // 1ビット送信完了 -> シフト
            r_shift_reg <= {r_shift_reg[22:0], 1'b0};
            r_bit_index <= r_bit_index + 5'd1;
            r_counter   <= 16'd0;
            // 24ビット全部送った?
            if (r_bit_index == 5'd23) begin
              // 次のピクセルに移るか、リセットへ行くか
              if (r_pixel_index == (NUM_PIXELS - 1)) begin
                r_state <= S_RESET;  // すべて送信済み
              end else begin
                r_pixel_index <= r_pixel_index + 8'd1;
                o_mem_addr    <= r_pixel_index + 8'd1;
                r_bit_index   <= 5'd0;
                // 新ピクセルのデータを取り込む
                r_shift_reg   <= i_mem_data;
                r_state       <= S_HIGH;
              end
            end else begin
              // まだビットが残っている -> 次のビットHIGHへ
              r_state <= S_HIGH;
            end
          end
        end else begin
          // '0'ビット => T0L_CYCLESだけLOW
          if (r_counter >= (T0L_CYCLES - 1)) begin
            // 1ビット送信完了 -> シフト
            r_shift_reg <= {r_shift_reg[22:0], 1'b0};
            r_bit_index <= r_bit_index + 5'd1;
            r_counter   <= 16'd0;
            // 24ビット全部送った?
            if (r_bit_index == 5'd23) begin
              // 次のピクセルに移るか、リセットへ行くか
              if (r_pixel_index == (NUM_PIXELS - 1)) begin
                r_state <= S_RESET; 
              end else begin
                r_pixel_index <= r_pixel_index + 8'd1;
                o_mem_addr    <= r_pixel_index + 8'd1;
                r_bit_index   <= 5'd0;
                r_shift_reg   <= i_mem_data;
                r_state       <= S_HIGH;
              end
            end else begin
              // まだビットが残っている -> 次のビットHIGHへ
              r_state <= S_HIGH;
            end
          end
        end
      end

      //----------------------------------------------
      // 全ピクセル送信後のリセット期間 (LOW維持)
      //----------------------------------------------
      S_RESET: begin
        o_led_out <= 1'b0;
        r_counter <= r_counter + 16'd1;
        // 指定サイクル(50us以上)を経過したら送信完
        if (r_counter >= (TRESET_CYCLES - 1)) begin
          r_state   <= S_DONE;
          r_counter <= 16'd0;
        end
      end

      //----------------------------------------------
      // 送信完了状態
      //----------------------------------------------
      S_DONE: begin
        // 今回は簡単に1クロック後 IDLE に戻る
        r_state <= S_IDLE;
      end

      endcase
    end
  end


endmodule