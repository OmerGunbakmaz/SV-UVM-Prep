// 03_routines_and_scoping.sv
// Book: Ch.4  4.10 Class Routines, 4.11 Defining Routines Outside of the Class,
//              4.12 Scoping Rules, 4.13 Using One Class Inside Another
//       (Ex 4-11/4-12 extern, 4-14..4-16 name scope and this,
//        4-18/4-19 Statistics class, 4-20 typedef class)
module tb_routines_and_scoping;

  // Ex 4-20: needed when a class name is used before it is defined
  typedef class Statistics;

  // Ex 4-18: Statistics -> to be used INSIDE another class
  class Statistics;
    time startT, stopT;
    static int ntrans = 0;
    static time total_elapsed_time = 0;

    function void start;
      startT = $time;
    endfunction

    function void stop;
      stopT = $time;
      total_elapsed_time += stopT - startT;
      ntrans++;
    endfunction
  endclass

  // Ex 4-12: methods whose body is defined outside (extern)
  class Transaction;
    bit [31:0] addr, crc, data[8];
    Statistics stats;               // Ex 4-19: "has-a" (composition)

    extern function new(bit [31:0] addr = 0);
    extern function void display();
  endclass

  function Transaction::new(bit [31:0] addr = 0);
    // Ex 4-16: argument and class variable share a name -> disambiguate with this.
    this.addr = addr;
    stats = new();                  // don't forget to create the inner object too!
  endfunction

  function void Transaction::display();
    $display("@%0t: Transaction addr=%h", $time, addr);
  endfunction

  // Ex 4-14: name scope -> the name in the nearest scope wins
  int limit = 1;                    // module level

  class Foo;
    int limit;                      // class level
    function void print(int limit); // argument
      $display("arguman limit=%0d  this.limit=%0d", limit, this.limit);
    endfunction
  endclass

  Transaction t;
  Foo         f;

  initial begin
    t = new(32'h42);
    t.display();

    // Using Statistics
    repeat (3) begin
      t.stats.start();
      #10;
      t.stats.stop();
    end
    $display("ntrans=%0d  toplam sure=%0t", Statistics::ntrans,
             Statistics::total_elapsed_time);

    f = new();
    f.limit = 7;
    f.print(3);
    $display("module limit=%0d", limit);
    $finish;
  end
endmodule
