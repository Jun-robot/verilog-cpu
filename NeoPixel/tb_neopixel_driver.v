// `timescale 1ns/1ps

module tb_neopixel_driver();

    // クロック/リセット/メモリアクセス信号
    reg         clk;
    reg         reset;
    reg  [7:0]  rd_addr;  // 書き込みアドレス
    reg         rd_wen;   // 書き込みイネーブル
    reg  [23:0] rd_data;  // 書き込みデータ

    // NeoPixel ドライバ出力
    wire        led_out;

    // neopixel_driver
    neopixel_driver driver(
        .i_clk    (clk),
        .i_reset  (reset),
        .i_rd_addr(rd_addr),
        .i_rd_wen (rd_wen),
        .i_rd_data(rd_data),
        .o_led_out(led_out)
    );

    // クロック生成 (10MHz: 100ns周期)
    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;  // 50nsごとに反転 → 100nsで1周期=10MHz
    end

    // テストシナリオ
    initial begin
        // 波形ダンプ (Icarus Verilog/Verilator など)
        $dumpfile("tb_neopixel_driver.vcd");
        $dumpvars(0, tb_neopixel_driver);

        // 初期状態
        reset   = 1'b1;
        rd_addr = 8'd0;
        rd_wen  = 1'b0;
        rd_data = 24'h000000;

        // リセット解除まで少し待機
        #200;
        reset = 1'b0;

        // メモリにピクセルデータ(24bit)を書き込む
        // 例: アドレス0→赤(0xFF0000)、アドレス1→緑(0x00FF00)、アドレス2→青(0x0000FF)
        #100;
        rd_addr = 8'd0;
        rd_data = 24'hFF0000; // 赤
        rd_wen  = 1'b1;
        #100;
        rd_wen  = 1'b0;

        #100;
        rd_addr = 8'd1;
        rd_data = 24'h00FF00; // 緑
        rd_wen  = 1'b1;
        #100;
        rd_wen  = 1'b0;

        #100;
        rd_addr = 8'd2;
        rd_data = 24'h0000FF; // 青
        rd_wen  = 1'b1;
        #100;
        rd_wen  = 1'b0;

        // さらに必要なら他のアドレスにも書き込み

        // しばらく待機してLED出力波形を観察
        #8000;

        // シミュレーション終了
        $finish;
    end

endmodule
