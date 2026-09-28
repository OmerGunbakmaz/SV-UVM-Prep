// sync_fifo_sva.sv  --  assertion module for sync_fifo
//
// EXAMPLE 2: bind
//
// This is an ORDINARY module. Nothing special about it. What is special is how
// it gets instantiated: the `bind` line in tb/tb_sync_fifo.sv places it INSIDE
// sync_fifo -- without touching a single character of sync_fifo.sv.
//
// After elaboration the hierarchy is:
//     tb_sync_fifo
//     └── dut          (sync_fifo)
//         └── u_sva    (sync_fifo_sva)   <-- bind injected this
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

    // These are NOT ports of sync_fifo, they are its INTERNAL signals.
    // Thanks to bind we can reach them too.
    input logic [PTR_W-1:0] wr_ptr,
    input logic [PTR_W-1:0] rd_ptr
  );

  // Protocol rules
  a_no_wr_when_full: assert property (@(posedge clk) disable iff (!rst_n)
      !(wr_en && full))
    else $error("[SVA] FIFO doluyken yazma denendi (overflow)");

  a_no_rd_when_empty: assert property (@(posedge clk) disable iff (!rst_n)
      !(rd_en && empty))
    else $error("[SVA] FIFO bosken okuma denendi (underflow)");

  // Internal consistency -- you can only write these with bind,
  // because wr_ptr/rd_ptr are not visible from outside.
  a_count_range: assert property (@(posedge clk) disable iff (!rst_n)
      count <= DEPTH)
    else $error("[SVA] count DEPTH'i asti: %0d", count);

  a_ptr_range: assert property (@(posedge clk) disable iff (!rst_n)
      (wr_ptr < DEPTH) && (rd_ptr < DEPTH))
    else $error("[SVA] pointer DEPTH disina cikti");

  // full and empty cannot be active at the same time
  a_not_full_and_empty: assert property (@(posedge clk) disable iff (!rst_n)
      !(full && empty))
    else $error("[SVA] full ve empty ayni anda aktif");

  // Cover: did these situations actually occur in the test?
  // An assertion says "must not happen", cover asks "did it happen?".
  c_fifo_full:  cover property (@(posedge clk) disable iff (!rst_n) full);
  c_fifo_empty: cover property (@(posedge clk) disable iff (!rst_n) empty);

endmodule
