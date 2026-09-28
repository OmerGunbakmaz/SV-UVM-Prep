// 05_array_constraints.sv
// Book: Ch.6  6.11 Common Randomization Problems, 6.12 Iterative and Array Constraints
//       (Ex 6-32..6-34 sign/width problems, 6-35 dynamic array size,
//        6-38..6-48 sum pitfalls, 6-49 increasing array, 6-50..6-52 unique array)
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_array_constraints;

  typedef bit [31:0] uint;

  // Ex 6-32: signed pitfall -> byte is signed, the solver can pick a negative length
  //          (e.g. -63 + 127 == 64)
  // Ex 6-34: fix -> use unsigned and narrow-enough types
  class SignedVars;
    rand byte pkt1_len, pkt2_len;
    constraint total_len { pkt1_len + pkt2_len == 64; }
  endclass

  class Vars8;
    rand bit [7:0] pkt1_len, pkt2_len;
    constraint total_len { pkt1_len + pkt2_len == 64; }
  endclass

  // Ex 6-35/6-36: dynamic array size + element constraints
  //   Ex 6-45 bad_sum4 -> the sum() of 1-bit elements is 1 bit!
  //   Ex 6-47 good_sum5 -> force the width with sum() with
  class StrobePat;
    rand bit strobe[10];
    constraint c_set_four { strobe.sum() with (int'(item)) == 4; }  // exactly 4 of them are 1
  endclass

  class GoodSum;
    rand uint len[];
    constraint c_len {
      foreach (len[i]) len[i] inside {[1:255]};
      len.sum() < 1024;
      len.size() inside {[1:8]};
    }
  endclass

  // Ex 6-49: increasing array with foreach
  class Ascend;
    rand uint d[10];
    constraint c {
      foreach (d[i])
        if (i > 0) d[i] > d[i-1];
      foreach (d[i]) d[i] < 100;
    }
  endclass

  // Ex 6-50..6-52: array of unique values -> via a helper randc variable
  class RandcRange;
    randc bit [7:0] value;
    int max_value;
    function new(int max_value = 10);
      this.max_value = max_value;
    endfunction
    constraint c_max { value < max_value; }
  endclass

  class UniqueArray;
    int max_array_size, max_value;
    rand bit [7:0] a[];
    constraint c_size { a.size() inside {[1:max_array_size]}; }

    function new(int max_array_size = 2, max_value = 2);
      this.max_array_size = max_array_size;
      // if max_value is smaller than the array size, no unique solution exists
      if (max_value < max_array_size) this.max_value = max_array_size;
      else                            this.max_value = max_value;
    endfunction

    // The array size was picked by a constraint; fill the elements with randc
    function void post_randomize();
      RandcRange rr = new(max_value);
      foreach (a[i]) begin
        assert (rr.randomize());
        a[i] = rr.value;
      end
    endfunction
  endclass

  SignedVars  sv = new();
  Vars8       v8 = new();
  StrobePat   sp = new();
  GoodSum     gs = new();
  Ascend      as = new();
  UniqueArray ua = new(8, 10);

  initial begin
    repeat (3) begin
      assert (sv.randomize());
      $display("signed  : %4d + %4d = 64  (negatif uzunluk olabilir!)", sv.pkt1_len, sv.pkt2_len);
    end
    repeat (3) begin
      assert (v8.randomize());
      $display("unsigned: %4d + %4d = %0d", v8.pkt1_len, v8.pkt2_len, v8.pkt1_len + v8.pkt2_len);
    end

    assert (sp.randomize());
    $display("strobe = %p  (tam 4 adet 1)", sp.strobe);

    repeat (3) begin
      assert (gs.randomize());
      $display("GoodSum: size=%0d sum=%0d len=%p", gs.len.size(),
               gs.len.sum() with (int'(item)), gs.len);
    end

    assert (as.randomize());
    $display("Ascend : %p", as.d);

    repeat (3) begin
      assert (ua.randomize());
      $display("Unique : %p", ua.a);
    end
    $finish;
  end
endmodule
