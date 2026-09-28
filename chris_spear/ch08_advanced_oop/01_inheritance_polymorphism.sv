// 01_inheritance_polymorphism.sv
// Book: Ch.8  8.2 Introduction to Inheritance, 8.4 Virtual Methods
//       (Ex 8-1 base Transaction, 8-2 extended class,
//        8-3 constructor with arguments and super.new)
module tb_inheritance_polymorphism;

  class base_txn;
    rand bit [31:0] addr;
    static int count;
    int id;

    function new();
      id = count++;
    endfunction

    virtual function string convert2string();
      return $sformatf("[%0d] BASE addr=0x%0h", id, addr);
    endfunction

    virtual function base_txn copy();
      base_txn c = new();
      c.addr = addr;
      return c;
    endfunction
  endclass

  class write_txn extends base_txn;
    rand bit [31:0] data;

    function new();
      super.new();              // the base class constructor on the FIRST line
    endfunction

    // extend the base class version by calling it via super.xxx()
    virtual function string convert2string();
      return $sformatf("%s data=0x%0h", super.convert2string(), data);
    endfunction

    virtual function base_txn copy();
      write_txn c = new();
      c.addr = addr;
      c.data = data;
      return c;
    endfunction
  endclass

  // Ex 8-3: if the base constructor takes arguments, the subclass must pass them
  class Base;
    int val;
    function new(int val);
      this.val = val;
    endfunction
  endclass

  class Extended extends Base;
    function new(int val);
      super.new(val);
    endfunction
  endclass

  // Polymorphism: a list of base handles, each element runs its own version
  base_txn  list[$];
  base_txn  b, c;
  write_txn w;
  Extended  e;

  initial begin
    b = new();
    w = new();
    b.addr = 32'h10;
    w.addr = 32'h20;
    w.data = 32'hCAFE;

    list.push_back(b);
    list.push_back(w);          // automatic upcast

    foreach (list[i])
      $display("%s", list[i].convert2string());  // virtual -> the right version
    // [0] BASE addr=0x10
    // [1] BASE addr=0x20 data=0xcafe

    c = list[1].copy();         // write_txn::copy runs
    $display("copy : %s", c.convert2string());

    e = new(5);
    $display("Extended.val=%0d", e.val);
    $finish;
  end
endmodule
