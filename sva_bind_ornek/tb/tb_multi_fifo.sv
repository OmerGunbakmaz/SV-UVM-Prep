//=============================================================================
// tb_multi_fifo.sv -- "bind neden var?" sorusunun cevabi
//
// Tasarimda 3 tane sync_fifo var ve UCU DE farkli derinlikte:
//     tb_multi_fifo.u_solo
//     tb_multi_fifo.u_pair.g_fifo[0].u_fifo
//     tb_multi_fifo.u_pair.g_fifo[1].u_fifo
//
// Ucunde de ayni hatayi yaptiriyoruz: bos FIFO'dan okuma.
// Ucunu de yakalayan sey: EN ALTTAKI TEK SATIR.
//=============================================================================
`timescale 1ns/1ps

module tb_multi_fifo;

  localparam int DATA_WIDTH = 32;
  localparam int DEPTH      = 16;
  localparam int PTR_W      = $clog2(DEPTH);

  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk;

  //--------------------------------------------------------------------------
  // 1) Dogrudan tb altinda duran FIFO
  //--------------------------------------------------------------------------
  logic solo_wr_en, solo_rd_en, solo_full, solo_empty;

  sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) u_solo (
    .clk(clk), .rst_n(rst_n),
    .wr_en(solo_wr_en), .wr_data('0), .full(solo_full), .almost_full(),
    .rd_en(solo_rd_en), .rd_data(), .rd_valid(), .empty(solo_empty),
    .almost_empty(), .count()
  );

  //--------------------------------------------------------------------------
  // 2) Ara katmanin icinde, generate dongusunde duran 2 FIFO daha
  //--------------------------------------------------------------------------
  logic [1:0] pair_wr_en, pair_rd_en, pair_full, pair_empty;

  fifo_pair #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .N(2)) u_pair (
    .clk(clk), .rst_n(rst_n),
    .wr_en(pair_wr_en), .rd_en(pair_rd_en),
    .full(pair_full),   .empty(pair_empty)
  );

  //--------------------------------------------------------------------------
  // Senaryo: ucunde de bos FIFO'dan okuma dene
  //--------------------------------------------------------------------------
  initial begin
    solo_wr_en = 0; solo_rd_en = 0;
    pair_wr_en = '0; pair_rd_en = '0;
    rst_n = 0;
    repeat (3) @(negedge clk);
    rst_n = 1;
    repeat (2) @(negedge clk);

    $display("\n--- 3 FIFO'nun da BOS halinde okuma deniyoruz ---\n");
    @(negedge clk);
    solo_rd_en = 1'b1;
    pair_rd_en = 2'b11;
    @(negedge clk);
    solo_rd_en = 1'b0;
    pair_rd_en = 2'b00;

    repeat (3) @(negedge clk);
    $display("\n--- bitti: yukaridaki Scope satirlarina bak ---\n");
    $finish;
  end

  //--------------------------------------------------------------------------
  //  TEK SATIR. Uc FIFO'nun ucune birden takiliyor.
  //
  //  ".*" kullanabiliyoruz cunku sync_fifo_sva'nin port isimleri
  //  (clk, rst_n, wr_en, rd_en, full, empty, count, wr_ptr, rd_ptr)
  //  sync_fifo'nun icindeki isimlerle birebir ayni.
  //--------------------------------------------------------------------------
  bind sync_fifo sync_fifo_sva #(.DEPTH(DEPTH), .PTR_W(PTR_W)) u_sva (.*);

  //--------------------------------------------------------------------------
  //  bind OLMASAYDI ayni isi TB'den yapmak icin sunu yazman gerekirdi
  //  -- her instance icin ayri ayri, yolu elle:
  //
  //  always @(posedge clk) if (rst_n && solo_rd_en && solo_empty)
  //      $error("underflow: u_solo");
  //  always @(posedge clk) if (rst_n && u_pair.g_fifo[0].u_fifo.rd_en
  //                                  && u_pair.g_fifo[0].u_fifo.empty)
  //      $error("underflow: pair 0");
  //  always @(posedge clk) if (rst_n && u_pair.g_fifo[1].u_fifo.rd_en
  //                                  && u_pair.g_fifo[1].u_fifo.empty)
  //      $error("underflow: pair 1");
  //
  //  ...ve bu SADECE bir kural icin. sync_fifo_sva'da 5 kural var -> 15 blok.
  //  N=2 yerine N=8 olsa -> 45 blok. Instance adi degisse -> hepsi bozulur.
  //--------------------------------------------------------------------------

endmodule
