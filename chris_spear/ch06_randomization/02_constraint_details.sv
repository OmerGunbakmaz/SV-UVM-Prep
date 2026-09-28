// 02_constraint_details.sv
// Book: Ch.6  6.4 Constraint Details
//       (Ex 6-4 ordered variables, 6-5..6-9 inside, 6-10/6-11 dist,
//        6-12 bidirectional constraint, 6-13/6-14 implication and if-else)
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_constraint_details;

  typedef enum {READ, WRITE} op_e;
  typedef enum {SINGLE, BURST} mode_e;

  // Ex 6-4 / 6-5 / 6-6: ordering and sets
  class Order;
    rand bit [7:0] lo, med, hi;
    rand bit [7:0] c, not_c;
    constraint c_order { lo < med; med < hi; }        // a < b < c cannot be written!
    constraint c_set   { c inside {[1:5], 8, [10:12]};
                         !(not_c inside {[0:250]}); }  // Ex 6-6: inverted set
  endclass

  // Ex 6-8: selecting from values in an array
  class Fib;
    int fib[5] = '{1, 2, 3, 5, 8};
    rand int f;
    constraint c_fib { f inside {fib}; }
  endclass

  // Ex 6-10: dist  ->  :=  weight per value,  :/  total weight over a range
  // Ex 6-11: weights can be variables
  class Dist;
    rand int src, dst;
    int w_small = 1, w_big = 5;
    rand bit [1:0] size;
    constraint c_dist {
      src dist {0 := 40, [1:3] := 60};    // 0:40, 1:60, 2:60, 3:60  (total 220)
      dst dist {0 :/ 40, [1:3] :/ 60};    // 0:40, 1:20, 2:20, 3:20  (total 100)
      size dist {0 := w_small, [1:3] := w_big};
    }
  endclass

  // Ex 6-12: constraints are bidirectional -> all solved AT ONCE
  class Bidir;
    rand bit [7:0] r, s, t;
    constraint c_bidir { r < t; s == r; t < 10; s > 5; }  // r,s: 6..8
  endclass

  // Ex 6-13/6-14: implication (->) and if-else
  class Impl;
    rand op_e       op;
    rand mode_e     mode;
    rand bit [7:0]  data;
    rand bit [4:0]  len;

    constraint c_impl {
      // if A then B   (no else: if not WRITE, data is free)
      (op == WRITE) -> (data != 0);

      // Chain: if BURST then length 4..16
      (mode == BURST) -> (len inside {[4:16]});
    }
  endclass

  // Adding else is a DIFFERENT rule: if not WRITE, data MUST be 0
  class ImplElse;
    rand op_e      op;
    rand bit [7:0] data;
    constraint c_ifelse {
      if (op == WRITE)
        data != 0;
      else
        data == 0;
    }
  endclass

  Order    o  = new();
  Fib      fb = new();
  Dist     d  = new();
  Bidir    b  = new();
  Impl     im = new();
  ImplElse ie = new();

  int src_hist[4], dst_hist[4];

  initial begin
    repeat (3) begin
      assert (o.randomize());
      $display("Order: lo=%0d med=%0d hi=%0d  c=%0d not_c=%0d", o.lo, o.med, o.hi, o.c, o.not_c);
    end

    repeat (5) begin
      assert (fb.randomize());
      $write("%0d ", fb.f);
    end
    $display(" <- Fib degerleri");

    repeat (2200) begin
      assert (d.randomize());
      src_hist[d.src]++;
      dst_hist[d.dst]++;
    end
    $display("src (:=) histogram = %p  (beklenen ~400,600,600,600)", src_hist);
    $display("dst (:/) histogram = %p  (beklenen ~880,440,440,440)", dst_hist);

    repeat (3) begin
      assert (b.randomize());
      $display("Bidir: r=%0d s=%0d t=%0d", b.r, b.s, b.t);
    end

    repeat (4) begin
      assert (im.randomize());
      $display("Impl    : op=%s mode=%s data=%0d len=%0d", im.op.name(), im.mode.name(), im.data, im.len);
    end
    repeat (4) begin
      assert (ie.randomize());
      $display("ImplElse: op=%s data=%0d", ie.op.name(), ie.data);
    end
    $finish;
  end
endmodule
