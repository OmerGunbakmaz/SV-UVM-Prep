//=============================================================================
// fifo_pair.sv -- icinde 2 tane sync_fifo barindiran ara katman.
// Tek amaci: hiyerarsiyi derinlestirip gercek bir tasarima benzetmek.
//=============================================================================
module fifo_pair #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    parameter int N          = 2
  )(
    input  logic clk,
    input  logic rst_n,
    input  logic [N-1:0] wr_en,
    input  logic [N-1:0] rd_en,
    output logic [N-1:0] full,
    output logic [N-1:0] empty
  );

  generate
    for (genvar i = 0; i < N; i++) begin : g_fifo
      sync_fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH)
      ) u_fifo (
        .clk          (clk),
        .rst_n        (rst_n),
        .wr_en        (wr_en[i]),
        .wr_data      ('0),
        .full         (full[i]),
        .almost_full  (),
        .rd_en        (rd_en[i]),
        .rd_data      (),
        .rd_valid     (),
        .empty        (empty[i]),
        .almost_empty (),
        .count        ()
      );
    end
  endgenerate

endmodule
