// tb_multi_fifo.sv -- the answer to "why does bind exist?"
//
// The design has 3 sync_fifo instances, ALL at different depths:
//     tb_multi_fifo.u_solo
//     tb_multi_fifo.u_pair.g_fifo[0].u_fifo
//     tb_multi_fifo.u_pair.g_fifo[1].u_fifo
//
// We make the same mistake in all three: reading from an empty FIFO.
// What catches all three: THE SINGLE LINE AT THE BOTTOM.
`timescale 1ns/1ps

module tb_multi_fifo;

  localparam int DATA_WIDTH = 32;
  localparam int DEPTH      = 16;
  localparam int PTR_W      = $clog2(DEPTH);

  logic clk = 0;
  logic rst_n;
  always #5 clk = ~clk;

  // 1) A FIFO sitting directly under the tb
  logic solo_wr_en, solo_rd_en, solo_full, solo_empty;

  sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) u_solo (
    .clk(clk), .rst_n(rst_n),
    .wr_en(solo_wr_en), .wr_data('0), .full(solo_full), .almost_full(),
    .rd_en(solo_rd_en), .rd_data(), .rd_valid(), .empty(solo_empty),
    .almost_empty(), .count()
  );

  // 2) 2 more FIFOs inside the intermediate layer, in a generate loop
  logic [1:0] pair_wr_en, pair_rd_en, pair_full, pair_empty;

  fifo_pair #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .N(2)) u_pair (
    .clk(clk), .rst_n(rst_n),
    .wr_en(pair_wr_en), .rd_en(pair_rd_en),
    .full(pair_full),   .empty(pair_empty)
  );

  // Scenario: try reading from an empty FIFO on all three
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

  //  ONE LINE. It attaches to all three FIFOs at once.
  //
  //  We can use ".*" because sync_fifo_sva's port names
  //  (clk, rst_n, wr_en, rd_en, full, empty, count, wr_ptr, rd_ptr)
  //  match the names inside sync_fifo exactly.
  bind sync_fifo sync_fifo_sva #(.DEPTH(DEPTH), .PTR_W(PTR_W)) u_sva (.*);

  //  WITHOUT bind you would have to write this from the TB to do the same
  //  -- for each instance separately, spelling out the path by hand:
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
  //  ...and that is for ONE rule only. sync_fifo_sva has 5 rules -> 15 blocks.
  //  N=8 instead of N=2 -> 45 blocks. Change an instance name -> all broken.

endmodule
