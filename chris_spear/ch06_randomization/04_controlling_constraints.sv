// 04_controlling_constraints.sv
// Book: Ch.6  6.6 Controlling Multiple Constraint Blocks, 6.7 Valid Constraints,
//              6.8 In-line Constraints, 6.9 pre/post_randomize,
//              6.10 Constraints Tips and Techniques
//       (Ex 6-21 constraint_mode, 6-22 valid constraint, 6-23 randomize() with,
//        6-24 bathtub distribution, 6-25/6-26 variable bounds/weights,
//        6-27 rand_mode, 6-30/6-31 extern constraint)
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_controlling_constraints;

  // Ex 6-21/6-22
  class Packet;
    rand int length;
    rand bit [7:0] payload[];
    int max_length = 100;                 // Ex 6-25: variable bound
    bit c_long_on;                        // no length limit in long-packet mode

    constraint c_short  { length inside {[1:32]}; }
    constraint c_long   { length inside {[1000:1023]}; }
    constraint c_valid  { length > 0; length <= max_length || c_long_on; }
    constraint c_size   { payload.size() == length % 8; }

    // Ex 6-30: constraint whose body is written OUTSIDE the class (in the test in the book)
    extern constraint c_extern;
  endclass

  constraint Packet::c_extern { length != 13; }

  // Ex 6-24: bathtub distribution -> computed inside pre_randomize
  class Bathtub;
    int value;
    int WIDTH = 50, DEPTH = 4, seed = 1;

    function void pre_randomize();
      // $dist_exponential: dense at the ends, sparse in the middle
      value = $dist_exponential(seed, DEPTH);
      if (value > WIDTH) value = WIDTH;
      if ($urandom_range(1)) value = WIDTH - value;  // mirror to the right edge
    endfunction
  endclass

  Packet  p;
  Bathtub bt;
  int     hist[0:50];

  initial begin
    p = new();

    // Ex 6-21: constraint_mode -> disable one of two conflicting blocks
    p.c_long.constraint_mode(0);          // short packet only
    assert (p.randomize());
    $display("kisa : length=%0d payload.size=%0d", p.length, p.payload.size());

    p.c_short.constraint_mode(0);
    p.c_long.constraint_mode(1);
    p.c_long_on = 1;
    assert (p.randomize());
    $display("uzun : length=%0d", p.length);

    p.constraint_mode(0);                 // disable ALL constraints
    p.c_short.constraint_mode(1);         // enable just one
    p.c_size.constraint_mode(1);
    p.c_long_on = 0;

    // Ex 6-23: inline constraint -> an extra rule for this call only
    assert (p.randomize() with { length == 8 * 3 + 1; });
    $display("with : length=%0d payload.size=%0d", p.length, p.payload.size());

    // Ex 6-27: rand_mode -> temporarily make a variable non-random
    p.length.rand_mode(0);
    p.length = 5;
    assert (p.randomize());
    $display("rand_mode(0): length=%0d (sabit)  payload.size=%0d", p.length, p.payload.size());
    p.length.rand_mode(1);

    // Conflicting constraint -> randomize returns 0, variables DO NOT change
    if (!p.randomize() with { length > 1000; })
      $display("celiskili constraint: randomize() = 0, length hala %0d", p.length);

    // Ex 6-24: bathtub histogram (buckets of 10)
    bt = new();
    repeat (2000) begin
      void'(bt.randomize());
      hist[bt.value]++;
    end
    for (int i = 0; i <= 50; i += 10) begin
      automatic int    sum = 0;
      automatic string bar = "";
      for (int j = i; j < i + 10 && j <= 50; j++) sum += hist[j];
      repeat (sum / 20) bar = {bar, "#"};
      $display("bathtub [%2d..%2d] %s", i, (i + 9 > 50) ? 50 : i + 9, bar);
    end
    $finish;
  end
endmodule
