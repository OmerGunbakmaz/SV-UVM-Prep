// 06_testbench_with_threads.sv
// Book: Ch.7  7.7 Building a Testbench with Threads and IPC
//       (Ex 7-37 Basic Transactor, 7-38 Environment, 7-39 test)
//
// Layers: Generator -> (mbx) -> Driver -> DUT(adder) -> Monitor -> (mbx)
//         -> Scoreboard.  The Environment builds them all: build / run / wrap_up
`timescale 1ns/1ns

module adder (input  logic clk,
              input  logic [7:0] a, b,
              input  logic valid_in,
              output logic [8:0] sum,
              output logic valid_out);
  always_ff @(posedge clk) begin
    sum       <= a + b;
    valid_out <= valid_in;
  end
endmodule


module tb_testbench_with_threads;

  logic       clk = 0;
  logic [7:0] a, b;
  logic       valid_in = 0, valid_out;
  logic [8:0] sum;

  always #5 clk = ~clk;
  adder dut (.*);

  class Transaction;
    bit [7:0] a, b;
    bit [8:0] sum;
    function string convert2string();
      return $sformatf("a=%0d b=%0d sum=%0d", a, b, sum);
    endfunction
  endclass

  class Generator;
    mailbox #(Transaction) gen2drv;
    int n;
    function new(mailbox #(Transaction) m, int n);
      gen2drv = m; this.n = n;
    endfunction
    task run();
      Transaction tr;
      repeat (n) begin
        tr = new();
        tr.a = $urandom; tr.b = $urandom;   // (with randomize() in Ch.6)
        gen2drv.put(tr);
      end
    endtask
  endclass

  // Ex 7-37: transactor skeleton -> get from mailbox, process, drive
  class Driver;
    mailbox #(Transaction) gen2drv;
    mailbox #(Transaction) drv2sb;          // expected results
    function new(mailbox #(Transaction) g, mailbox #(Transaction) s);
      gen2drv = g; drv2sb = s;
    endfunction
    task run();
      Transaction tr;
      forever begin
        gen2drv.get(tr);
        @(negedge clk);
        a = tr.a; b = tr.b; valid_in = 1;
        @(negedge clk);
        valid_in = 0;
        tr.sum = tr.a + tr.b;               // reference model
        drv2sb.put(tr);
      end
    endtask
  endclass

  class Monitor;
    mailbox #(Transaction) mon2sb;
    function new(mailbox #(Transaction) m); mon2sb = m; endfunction
    task run();
      Transaction tr;
      forever begin
        @(posedge clk);
        #1;
        if (valid_out) begin
          tr = new();
          tr.sum = sum;
          mon2sb.put(tr);
        end
      end
    endtask
  endclass

  class Scoreboard;
    mailbox #(Transaction) exp_mbx, act_mbx;
    int n, errors;
    function new(mailbox #(Transaction) e, mailbox #(Transaction) a, int n);
      exp_mbx = e; act_mbx = a; this.n = n;
    endfunction
    task run();
      Transaction exp, act;
      repeat (n) begin
        exp_mbx.get(exp);
        act_mbx.get(act);
        if (exp.sum !== act.sum) begin
          $error("MISMATCH %s  got=%0d", exp.convert2string(), act.sum);
          errors++;
        end
        else
          $display("@%0t: OK %s", $time, exp.convert2string());
      end
    endtask
  endclass

  // Ex 7-38: Environment
  class Environment;
    Generator  gen;
    Driver     drv;
    Monitor    mon;
    Scoreboard sb;
    mailbox #(Transaction) gen2drv, drv2sb, mon2sb;
    int n;

    function new(int n = 5); this.n = n; endfunction

    function void build();
      gen2drv = new(); drv2sb = new(); mon2sb = new();
      gen = new(gen2drv, n);
      drv = new(gen2drv, drv2sb);
      mon = new(mon2sb);
      sb  = new(drv2sb, mon2sb, n);
    endfunction

    task run();
      fork
        gen.run();
        drv.run();
        mon.run();
      join_none
      sb.run();                     // ends once the scoreboard checks n items
      disable fork;                 // stop the forever loops
    endtask

    function void wrap_up();
      $display("%s (%0d hata)", sb.errors ? "TEST KALDI" : "TEST GECTI", sb.errors);
    endfunction
  endclass

  // Ex 7-39: test
  Environment env;
  initial begin
    env = new(8);
    env.build();
    env.run();
    env.wrap_up();
    $finish;
  end
endmodule
