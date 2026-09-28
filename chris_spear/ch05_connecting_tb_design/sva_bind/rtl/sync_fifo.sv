// sync_fifo.sv  --  Synchronous FIFO (single clock domain)
//
// This file is design ONLY. There are no assertions inside it.
// The assertions live in sva/sync_fifo_sva.sv, attached from outside via bind.
module sync_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    parameter int AF_TRESH   = DEPTH - 2,   // almost_full  threshold
    parameter int AE_TRESH   = 2,           // almost_empty threshold
    parameter bit FWFT       = 1'b1         // 1: First-Word-Fall-Through
  )(
    input  logic clk,
    input  logic rst_n,

    // write side
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,
    output logic                    almost_full,

    // read side
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1:0]   rd_data,
    output logic                    rd_valid,
    output logic                    empty,
    output logic                    almost_empty,

    output logic [$clog2(DEPTH+1)-1:0] count
  );

  localparam int PTR_W = (DEPTH > 1) ? $clog2(DEPTH) : 1;

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  logic [PTR_W-1:0]      wr_ptr, rd_ptr;

  logic push, pop;
  assign push = wr_en & ~full;
  assign pop  = rd_en & ~empty;

  // Memory write
  always_ff @(posedge clk) begin
    if (push)
      mem[wr_ptr] <= wr_data;
  end

  // Pointers
  //   NOTE: wr_ptr increments on push, rd_ptr on pop. The two are independent.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr <= '0;
      rd_ptr <= '0;
    end
    else begin
      if (push)
        wr_ptr <= (wr_ptr == PTR_W'(DEPTH-1)) ? '0 : wr_ptr + 1'b1;
      if (pop)
        rd_ptr <= (rd_ptr == PTR_W'(DEPTH-1)) ? '0 : rd_ptr + 1'b1;
    end
  end

  // Occupancy counter
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= '0;
    else if (push & ~pop)
      count <= count + 1'b1;
    else if (~push & pop)
      count <= count - 1'b1;
  end

  assign full         = (count == DEPTH[$bits(count)-1:0]);
  assign empty        = (count == '0);
  assign almost_full  = (count >= AF_TRESH[$bits(count)-1:0]);
  assign almost_empty = (count <= AE_TRESH[$bits(count)-1:0]);

  // Read path
  generate
    if (FWFT) begin : g_fwft
      // Data is ready at the output as soon as it enters the FIFO. rd_en just says "consumed".
      assign rd_data  = mem[rd_ptr];
      assign rd_valid = ~empty;
    end
    else begin : g_std
      // Classic: data appears 1 clock after rd_en.
      always_ff @(posedge clk) begin
        if (pop) rd_data <= mem[rd_ptr];
      end
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rd_valid <= 1'b0;
        else        rd_valid <= pop;
      end
    end
  endgenerate

  // EXAMPLE 1: `ifndef SYNTHESIS
  //
  // This block does elaboration-time parameter checking. The synthesis tool
  // defines the SYNTHESIS macro automatically, so it NEVER sees this block.
  // In simulation the macro is undefined -> the block is compiled and runs.
  //
  // Note: the parameter sanity-check belongs to the design, so it stays here.
  // The assertions that check protocol rules live in a separate file.
`ifndef SYNTHESIS
  initial begin
    if (DEPTH < 2)
      $fatal(1, "sync_fifo: DEPTH en az 2 olmali (DEPTH=%0d)", DEPTH);
    if (AF_TRESH > DEPTH || AE_TRESH > DEPTH)
      $fatal(1, "sync_fifo: esik degerleri DEPTH'i asamaz");
  end
`endif

endmodule
