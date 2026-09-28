// 02_factory_pattern.sv
// Book: Ch.8  8.3 Factory Patterns
//       (Ex 8-4 Driver, 8-5 Generator, 8-6 generator with a blueprint,
//        8-7 Environment, 8-8 default test, 8-9 test that injects an
//        extended transaction)
//
// Idea: if the Generator writes "new Transaction" every time, the test cannot
// change the type. Instead it keeps a "blueprint" object and sends a COPY of it.
// The test injects new behavior by swapping the blueprint for a subclass,
// without touching the generator code.
module tb_factory_pattern;

  class Transaction;
    bit [7:0] addr, data;
    virtual function void randomize_me();
      addr = $urandom;
      data = $urandom;
    endfunction
    virtual function Transaction copy();
      copy = new();
      copy.addr = addr;
      copy.data = data;
    endfunction
    virtual function string convert2string();
      return $sformatf("Transaction addr=%h data=%h", addr, data);
    endfunction
  endclass

  // Subclass defined on the test side: produces bad packets
  class BadTr extends Transaction;
    bit bad_crc = 1;
    virtual function void randomize_me();
      super.randomize_me();
      addr = 8'hFF;                         // always the same "bad" address
    endfunction
    virtual function Transaction copy();
      BadTr b = new();
      b.addr = addr; b.data = data; b.bad_crc = bad_crc;
      return b;
    endfunction
    virtual function string convert2string();
      return $sformatf("BadTr       addr=%h data=%h bad_crc=%0b", addr, data, bad_crc);
    endfunction
  endclass

  // Ex 8-6: generator with a blueprint
  class Generator;
    mailbox #(Transaction) gen2drv;
    Transaction blueprint;                  // the factory template

    function new(mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
      blueprint = new();                    // default type
    endfunction

    task run(int n);
      Transaction tr;
      repeat (n) begin
        blueprint.randomize_me();
        tr = blueprint.copy();              // virtual copy -> the right type
        gen2drv.put(tr);
      end
    endtask
  endclass

  // Ex 8-4
  class Driver;
    mailbox #(Transaction) gen2drv;
    function new(mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
    endfunction
    task run(int n);
      Transaction tr;
      repeat (n) begin
        gen2drv.get(tr);
        $display("  driver: %s", tr.convert2string());
      end
    endtask
  endclass

  // Ex 8-7
  class Environment;
    Generator gen;
    Driver    drv;
    mailbox #(Transaction) gen2drv;
    function void build();
      gen2drv = new();
      gen = new(gen2drv);
      drv = new(gen2drv);
    endfunction
    task run(int n);
      fork
        gen.run(n);
        drv.run(n);
      join
    endtask
  endclass

  Environment env;
  BadTr       bad;

  initial begin
    // Ex 8-8: default test
    $display("--- test 1: varsayilan blueprint ---");
    env = new();
    env.build();
    env.run(3);

    // Ex 8-9: swap the blueprint between build and run
    $display("--- test 2: BadTr enjekte edildi ---");
    env = new();
    env.build();
    bad = new();
    env.gen.blueprint = bad;                // without touching the generator code!
    env.run(3);
    $finish;
  end
endmodule
