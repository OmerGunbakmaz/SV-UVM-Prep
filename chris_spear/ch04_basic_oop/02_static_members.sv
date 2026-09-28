// 02_static_members.sv
// Book: Ch.4  4.9 Static Variables vs. Global Variables  (Ex 4-9, 4-10)
module tb_static_members;

  class packet;
    static int count = 0;   // a SINGLE copy for ALL objects
    int id;

    function new();
      count++;              // increments on every new object
      id = count;
    endfunction

    static function int get_count();   // static method
      return count;                    // can only access static members
    endfunction
  endclass

  // Ex 4-10: shared configuration via a static variable (e.g. log level)
  class Config;
    static int verbosity = 1;
  endclass

  class Driver;
    int id;
    function new(int id); this.id = id; endfunction
    function void talk(string msg);
      if (Config::verbosity > 0)
        $display("Driver%0d: %s", id, msg);
    endfunction
  endclass

  packet p1, p2;
  Driver d0, d1;

  initial begin
    $display("baslangicta count = %0d", packet::count);   // without an object

    p1 = new();   // count = 1
    p2 = new();   // count = 2
    $display("p1.id=%0d p2.id=%0d", p1.id, p2.id);
    $display("packet::count       = %0d", packet::count);        // 2
    $display("packet::get_count() = %0d", packet::get_count());  // 2
    $display("p1.count            = %0d (handle uzerinden de ayni)", p1.count);

    d0 = new(0);
    d1 = new(1);
    d0.talk("merhaba");
    Config::verbosity = 0;               // silence them all from one place
    d1.talk("bu gorunmeyecek");
    $display("verbosity=0 -> Driver1 sustu");
    $finish;
  end
endmodule
