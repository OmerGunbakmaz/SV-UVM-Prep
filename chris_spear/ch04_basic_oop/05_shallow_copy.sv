// 05_shallow_copy.sv
// Book: Ch.4  4.15 Copying Objects  (Ex 4-27, 4-28: copying with new)
//
// "s2 = new s1" -> s1's variables are copied BUT the handles inside it
// (f) are copied only as handles: s1.f and s2.f point to the SAME object.
module tb_shallow_copy;

  class first;
    int data = 5;
  endclass

  class second;
    first f;
    int data = 7;
    function new();
      f = new();
    endfunction
  endclass

  second s1, s2;

  initial begin
    s1 = new();
    s2 = new s1;          // shallow copy
    s1.data   = 9;        // only s1 changes
    s1.f.data = 30;
    s2.f.data = 0;        // s1.f.data becomes 0 too -> shared object!
    $display("s1.data   : %0d", s1.data);     // 9
    $display("s2.data   : %0d", s2.data);     // 7
    $display("s1.f.data : %0d", s1.f.data);   // 0
    $display("s2.f.data : %0d", s2.f.data);   // 0
    $finish;
  end
endmodule
