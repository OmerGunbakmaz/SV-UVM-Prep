//=============================================================================
// sync_fifo_sva.sv  --  sync_fifo icin assertion modulu
//
// ORNEK 2: bind
//
// Bu SIRADAN bir modul. Ozel bir sey yok. Ozel olan, nasil instantiate
// edildigi: tb/tb_sync_fifo.sv icindeki `bind` satiri bunu sync_fifo'nun
// ICINE yerlestiriyor -- sync_fifo.sv dosyasina tek karakter dokunmadan.
//
// Elaborasyondan sonra hiyerarsi:
//     tb_sync_fifo
//     └── dut          (sync_fifo)
//         └── u_sva    (sync_fifo_sva)   <-- bind bunu enjekte etti
//=============================================================================
module sync_fifo_sva #(
    parameter int DEPTH = 16,
    parameter int PTR_W = 4
  )(
    input logic clk,
    input logic rst_n,

    input logic wr_en,
    input logic rd_en,
    input logic full,
    input logic empty,

    input logic [$clog2(DEPTH+1)-1:0] count,

    // Bunlar sync_fifo'nun PORTU DEGIL, IC sinyalleri.
    // bind sayesinde onlara da erisebiliyoruz.
    input logic [PTR_W-1:0] wr_ptr,
    input logic [PTR_W-1:0] rd_ptr
  );

  //---------------------------------------------------------------------------
  // Protokol kurallari
  //---------------------------------------------------------------------------
  a_no_wr_when_full: assert property (@(posedge clk) disable iff (!rst_n)
      !(wr_en && full))
    else $error("[SVA] FIFO doluyken yazma denendi (overflow)");

  a_no_rd_when_empty: assert property (@(posedge clk) disable iff (!rst_n)
      !(rd_en && empty))
    else $error("[SVA] FIFO bosken okuma denendi (underflow)");

  //---------------------------------------------------------------------------
  // Ic tutarlilik -- bunlari ancak bind ile yazabilirsin,
  // cunku wr_ptr/rd_ptr disaridan gorunmuyor.
  //---------------------------------------------------------------------------
  a_count_range: assert property (@(posedge clk) disable iff (!rst_n)
      count <= DEPTH)
    else $error("[SVA] count DEPTH'i asti: %0d", count);

  a_ptr_range: assert property (@(posedge clk) disable iff (!rst_n)
      (wr_ptr < DEPTH) && (rd_ptr < DEPTH))
    else $error("[SVA] pointer DEPTH disina cikti");

  // full ve empty ayni anda olamaz
  a_not_full_and_empty: assert property (@(posedge clk) disable iff (!rst_n)
      !(full && empty))
    else $error("[SVA] full ve empty ayni anda aktif");

  //---------------------------------------------------------------------------
  // Cover: bu durumlar testte gercekten olustu mu?
  // Assertion "olmamali" der, cover "oldu mu?" diye sorar.
  //---------------------------------------------------------------------------
  c_fifo_full:  cover property (@(posedge clk) disable iff (!rst_n) full);
  c_fifo_empty: cover property (@(posedge clk) disable iff (!rst_n) empty);

endmodule
