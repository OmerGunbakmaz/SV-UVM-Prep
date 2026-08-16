//=============================================================================
// tb_sync_fifo.sv  --  basit yonlendirilmis (directed) testbench
//
// Burada gorulecek asil sey en asagidaki `bind` satiri.
//=============================================================================
`timescale 1ns/1ps

module tb_sync_fifo;

  localparam int DATA_WIDTH = 32;
  localparam int DEPTH      = 16;
  localparam int PTR_W      = $clog2(DEPTH);   // = 4

  logic clk = 0;
  logic rst_n;

  logic                  wr_en, rd_en;
  logic [DATA_WIDTH-1:0] wr_data, rd_data;
  logic                  full, almost_full, empty, almost_empty, rd_valid;
  logic [$clog2(DEPTH+1)-1:0] count;

  // referans model: FIFO'ya ne yazdiysak burada da tutuyoruz
  logic [DATA_WIDTH-1:0] ref_q [$];
  int errors = 0;

  //---------------------------------------------------------------------------
  // Saat
  //---------------------------------------------------------------------------
  always #5 clk = ~clk;          // 100 MHz

  //---------------------------------------------------------------------------
  // DUT
  //---------------------------------------------------------------------------
  sync_fifo #(
    .DATA_WIDTH (DATA_WIDTH),
    .DEPTH      (DEPTH),
    .FWFT       (1'b1)
  ) dut (
    .clk          (clk),
    .rst_n        (rst_n),
    .wr_en        (wr_en),
    .wr_data      (wr_data),
    .full         (full),
    .almost_full  (almost_full),
    .rd_en        (rd_en),
    .rd_data      (rd_data),
    .rd_valid     (rd_valid),
    .empty        (empty),
    .almost_empty (almost_empty),
    .count        (count)
  );

  //---------------------------------------------------------------------------
  // Surucu task'lari (negedge'de surup posedge'de DUT'un ornekleme yapmasini
  // saglıyoruz -> yaris kosulu yok)
  //---------------------------------------------------------------------------
  task automatic do_write(input logic [DATA_WIDTH-1:0] d);
    @(negedge clk);
    wr_en   = 1'b1;
    wr_data = d;
    ref_q.push_back(d);
    @(negedge clk);
    wr_en   = 1'b0;
  endtask

  task automatic do_read();
    logic [DATA_WIDTH-1:0] got, exp;
    @(negedge clk);
    rd_en = 1'b1;
    got   = rd_data;              // FWFT: veri zaten cikista hazir
    @(negedge clk);
    rd_en = 1'b0;

    exp = ref_q.pop_front();
    if (got !== exp) begin
      $error("MISMATCH: beklenen=%0h alinan=%0h", exp, got);
      errors++;
    end
    else
      $display("  [%0t] okundu: %0h  (count=%0d)", $time, got, count);
  endtask

  //---------------------------------------------------------------------------
  // Test senaryosu
  //---------------------------------------------------------------------------
  initial begin
    wr_en = 0; rd_en = 0; wr_data = '0;
    rst_n = 0;
    repeat (3) @(negedge clk);
    rst_n = 1;
    @(negedge clk);

    $display("\n--- 1) 5 adet yazma ---");
    for (int i = 0; i < 5; i++)
      do_write(32'hA000_0000 + i);
    $display("  count=%0d empty=%0b full=%0b", count, empty, full);

    $display("\n--- 2) 5 adet okuma ---");
    repeat (5) do_read();
    $display("  count=%0d empty=%0b", count, empty);

    $display("\n--- 3) FIFO'yu tamamen doldur (%0d yazma) ---", DEPTH);
    for (int i = 0; i < DEPTH; i++)
      do_write(32'hB000_0000 + i);
    $display("  count=%0d full=%0b almost_full=%0b", count, full, almost_full);
    if (!full) begin
      $error("FIFO dolmasi gerekirken full=0"); errors++;
    end

    $display("\n--- 4) Tamamen bosalt ---");
    repeat (DEPTH) do_read();
    $display("  count=%0d empty=%0b almost_empty=%0b", count, empty, almost_empty);

    // Bu blok sadece "vsim ... +VIOLATE" ile calisir.
    // Amaci: bind edilmis assertion'in gercekten atesledigini gormek.
    if ($test$plusargs("VIOLATE")) begin
      $display("\n--- 5) KASITLI HATA: bos FIFO'dan okuma ---");
      @(negedge clk);
      rd_en = 1'b1;              // empty=1 iken -> a_no_rd_when_empty patlar
      @(negedge clk);
      rd_en = 1'b0;
    end

    repeat (5) @(negedge clk);
    if (errors == 0) $display("\n*** TEST GECTI ***\n");
    else             $display("\n*** TEST KALDI (%0d hata) ***\n", errors);
    $finish;
  end

  //---------------------------------------------------------------------------
  //                        >>>  ISTE BURASI  <<<
  //
  //  bind  <hedef modul>  <yerlestirilecek modul> <ornek adi> (<portlar>);
  //
  //  Parantezin ICINDEKI isimler (clk, wr_ptr, rd_ptr ...) tb'nin degil,
  //  HEDEFIN yani sync_fifo'nun kendi ic isim uzayindan cozuluyor.
  //  Bu yuzden wr_ptr/rd_ptr gibi disari cikmayan sinyallere erisebiliyoruz.
  //
  //  "sync_fifo" yazdigimiz icin tasarimdaki TUM sync_fifo kopyalarina
  //  takilir. Tek bir tanesini istesek: bind tb_sync_fifo.dut ...
  //---------------------------------------------------------------------------
  bind sync_fifo sync_fifo_sva #(
      .DEPTH (DEPTH),
      .PTR_W (PTR_W)
  ) u_sva (
      .clk    (clk),
      .rst_n  (rst_n),
      .wr_en  (wr_en),
      .rd_en  (rd_en),
      .full   (full),
      .empty  (empty),
      .count  (count),
      .wr_ptr (wr_ptr),     // <-- sync_fifo'nun IC sinyali
      .rd_ptr (rd_ptr)      // <-- sync_fifo'nun IC sinyali
  );

endmodule
