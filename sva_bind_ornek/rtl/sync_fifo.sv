//=============================================================================
// sync_fifo.sv  --  Senkron FIFO (tek clock domain)
//
// Bu dosya SADECE tasarim. Icinde assertion YOK.
// Assertion'lar sva/sync_fifo_sva.sv icinde, bind ile disaridan baglaniyor.
//=============================================================================
module sync_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    parameter int AF_TRESH   = DEPTH - 2,   // almost_full  esigi
    parameter int AE_TRESH   = 2,           // almost_empty esigi
    parameter bit FWFT       = 1'b1         // 1: First-Word-Fall-Through
  )(
    input  logic clk,
    input  logic rst_n,

    // yazma tarafi
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,
    output logic                    full,
    output logic                    almost_full,

    // okuma tarafi
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

  //---------------------------------------------------------------------------
  // Bellek yazma
  //---------------------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (push)
      mem[wr_ptr] <= wr_data;
  end

  //---------------------------------------------------------------------------
  // Pointer'lar
  //   DIKKAT: wr_ptr push ile, rd_ptr pop ile artar. Ikisi bagimsiz.
  //---------------------------------------------------------------------------
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

  //---------------------------------------------------------------------------
  // Doluluk sayaci
  //---------------------------------------------------------------------------
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

  //---------------------------------------------------------------------------
  // Okuma yolu
  //---------------------------------------------------------------------------
  generate
    if (FWFT) begin : g_fwft
      // Veri FIFO'ya girer girmez cikista hazir. rd_en sadece "tukettim" der.
      assign rd_data  = mem[rd_ptr];
      assign rd_valid = ~empty;
    end
    else begin : g_std
      // Klasik: rd_en'den 1 clock sonra veri gelir.
      always_ff @(posedge clk) begin
        if (pop) rd_data <= mem[rd_ptr];
      end
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rd_valid <= 1'b0;
        else        rd_valid <= pop;
      end
    end
  endgenerate

  //---------------------------------------------------------------------------
  // ORNEK 1: `ifndef SYNTHESIS
  //
  // Bu blok elaborasyon-zamani parametre kontrolu yapar. Sentez araci
  // SYNTHESIS makrosunu otomatik tanimladigi icin bu blogu HIC gormez.
  // Simulatorde ise makro tanimsizdir -> blok derlenir ve calisir.
  //
  // Not: parametre sanity-check'i tasarima ait bir sey oldugu icin burada
  // duruyor. Protokol kurallarini denetleyen assertion'lar ise ayri dosyada.
  //---------------------------------------------------------------------------
`ifndef SYNTHESIS
  initial begin
    if (DEPTH < 2)
      $fatal(1, "sync_fifo: DEPTH en az 2 olmali (DEPTH=%0d)", DEPTH);
    if (AF_TRESH > DEPTH || AE_TRESH > DEPTH)
      $fatal(1, "sync_fifo: esik degerleri DEPTH'i asamaz");
  end
`endif

endmodule
