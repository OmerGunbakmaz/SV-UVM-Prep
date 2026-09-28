// 06_deep_copy.sv
// Book: Ch.4  4.15 Copying Objects  (Ex 4-29..4-31: copy() function)
module tb_deep_copy;

  class first;
    int data = 5;
    function first copy();
      copy = new();
      copy.data = this.data;
    endfunction
  endclass

  // Version 1: works but there is a wasted object.
  //   the copy = new() line already creates an object for f in the constructor,
  //   then copy.f = f.copy() assigns yet another new object.
  class v1_second;
    first f;
    int data = 7;
    function new();
      f = new();
    endfunction

    function v1_second copy();
      copy = new();
      copy.data = this.data;
      copy.f    = f.copy();
    endfunction
  endclass

  // Version 2: skip creating the inner object with new(0) -> no waste
  class v2_second;
    first f;
    int data = 7;
    function new(int alloc = 1);
      if (alloc)
        f = new();
    endfunction

    function v2_second copy();
      copy = new(0);
      copy.data = this.data;
      copy.f    = f.copy();
    endfunction
  endclass

  v1_second a1, a2;
  v2_second b1, b2;

  initial begin
    a1 = new();
    a2 = a1.copy();
    a1.data   = 9;
    a1.f.data = 30;
    a2.f.data = 0;           // no longer AFFECTS a1.f
    $display("--- v1 ---");
    $display("a1.data : %0d  a2.data : %0d", a1.data, a2.data);       // 9  7
    $display("a1.f.data : %0d  a2.f.data : %0d", a1.f.data, a2.f.data); // 30 0

    b1 = new();
    b2 = b1.copy();
    b1.f.data = 30;
    b2.f.data = 0;
    $display("--- v2 ---");
    $display("b1.f.data : %0d  b2.f.data : %0d", b1.f.data, b2.f.data); // 30 0
    $finish;
  end
endmodule
