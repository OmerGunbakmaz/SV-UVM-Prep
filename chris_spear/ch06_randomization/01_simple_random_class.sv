// 01_simple_random_class.sv
// Book: Ch.6  6.3 Randomization in SystemVerilog, 6.9 pre/post_randomize
//       (Ex 6-1 simple random class, 6-2 constraint on a non-rand variable,
//        6-3 constrained-random class)
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_simple_random_class;

  // Ex 6-1
  class Packet;
    rand  bit [31:0] src, dst, data[8];
    randc bit [7:0]  kind;                 // randc: no repeat until all values are used

    bit verbose = 1;

    constraint c { src > 10;
                   src < 15; }

    // 6.9: called automatically before / after randomize()
    function void pre_randomize();
      if (verbose) $display("pre_randomize : kind (onceki) = %0d", kind);
    endfunction

    function void post_randomize();
      if (verbose) $display("post_randomize: src=%0d kind=%0d", src, kind);
    endfunction
  endclass

  // Ex 6-2: non-rand variable -> the constraint only CHECKS it
  class Stim;
    const bit [31:0] CONGEST_ADDR = 42;
    typedef enum {READ, WRITE, CONTROL} stim_e;
    randc stim_e kind;
    rand  bit [31:0] len, src, dst;
    bit   congestion_test;

    constraint c_stim {
      len < 1000;
      len > 0;
      if (congestion_test) {
        dst inside {[CONGEST_ADDR - 10 : CONGEST_ADDR + 10]};
        src == CONGEST_ADDR;
      }
      else
        src inside {0, [2:10], [100:107]};
    }
  endclass

  Packet p;
  Stim   s;
  bit [7:0] seen[$];

  initial begin
    p = new();
    // randomize() can fail -> ALWAYS check it
    assert (p.randomize())
    else $fatal(1, "Packet::randomize basarisiz");

    // randc: all 256 values appear once per round
    // (new object -> new randc round; verbose off)
    p = new();
    p.verbose = 0;
    repeat (256) begin
      void'(p.randomize());
      seen.push_back(p.kind);
    end
    $display("randc 256 cekilis, benzersiz deger sayisi = %0d",
             seen.unique().size());

    s = new();
    repeat (3) begin
      assert (s.randomize());
      $display("normal    : kind=%s len=%0d src=%0d dst=%0d", s.kind.name(), s.len, s.src, s.dst);
    end
    s.congestion_test = 1;
    repeat (3) begin
      assert (s.randomize());
      $display("congestion: kind=%s len=%0d src=%0d dst=%0d", s.kind.name(), s.len, s.src, s.dst);
    end
    $finish;
  end
endmodule
