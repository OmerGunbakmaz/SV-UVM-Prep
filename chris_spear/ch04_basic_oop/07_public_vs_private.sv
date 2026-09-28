// 07_public_vs_private.sv
// Book: Ch.4  4.16 Public vs. Private
//
//   (default) public -> from anywhere
//   local            -> THIS class only
//   protected        -> this class + subclasses
//
// The book's advice: in a testbench mostly leave things public; for cases
// like error injection the test needs to reach the internal variables.
module tb_public_vs_private;

  class packet;
    bit [31:0] addr;          // default: public
    local int  secret;        // THIS class only
    protected int semi;       // this class + subclasses

    function new();
      secret = 42;
      semi   = 7;
    endfunction

    function int get_secret();   // controlled access to local
      return secret;
    endfunction
  endclass

  class ext_packet extends packet;
    function void show();
      $display("alt sinif semi=%0d", semi);   // protected: OK
      // $display("%0d", secret);             // ERROR: local
    endfunction
  endclass

  packet     p;
  ext_packet e;

  initial begin
    p = new();
    p.addr = 32'h1000;                          // public: OK
    $display("addr=%h secret=%0d", p.addr, p.get_secret());
    // p.secret = 1;                            // ERROR: local
    // p.semi   = 1;                            // ERROR: protected
    e = new();
    e.show();
    $finish;
  end
endmodule
