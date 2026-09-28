// 05_callbacks.sv
// Book: Ch.8  8.7 Callbacks
//       (Ex 8-24 base callback class, 8-25 Driver with callbacks,
//        8-26 error-injection callback, 8-27 scoreboard callback)
//
// Adding a "hook" to a Driver's behavior without modifying it:
// the Driver calls all callback objects in a queue at certain points.
// The test adds its own callback subclass to the queue.
module tb_callbacks;

  class Transaction;
    static int count;
    int        id;
    bit [7:0]  data;
    bit        corrupted;
    function new(); id = count++; data = $urandom; endfunction
  endclass

  // Ex 8-24: empty (default) callbacks -> a subclass overrides only what it needs
  virtual class Driver_cbs;
    virtual task pre_tx(ref Transaction tr, ref bit drop);
    endtask
    virtual task post_tx(ref Transaction tr);
    endtask
  endclass

  // Ex 8-25
  class Driver;
    Driver_cbs cbs[$];

    task run(int n);
      Transaction tr;
      bit drop;
      repeat (n) begin
        tr   = new();
        drop = 0;
        foreach (cbs[i]) cbs[i].pre_tx(tr, drop);
        if (drop) begin
          $display("  driver: tr#%0d DUSURULDU", tr.id);
          continue;
        end
        $display("  driver: tr#%0d data=%h%0s", tr.id, tr.data,
                 tr.corrupted ? "  (bozuk)" : "");
        foreach (cbs[i]) cbs[i].post_tx(tr);
      end
    endtask
  endclass

  // Ex 8-26: corrupt every 3rd packet, drop the 5th
  class Driver_cbs_drop extends Driver_cbs;
    virtual task pre_tx(ref Transaction tr, ref bit drop);
      if (tr.id % 3 == 2) begin
        tr.data      = ~tr.data;
        tr.corrupted = 1;
      end
      drop = (tr.id == 4);
    endtask
  endclass

  // Ex 8-27: report every sent packet to the scoreboard
  class Scoreboard;
    int expected[$];
    function void save_expected(Transaction tr);
      expected.push_back(tr.id);
    endfunction
  endclass

  class Driver_cbs_scoreboard extends Driver_cbs;
    Scoreboard scb;
    function new(Scoreboard scb);
      this.scb = scb;
    endfunction
    virtual task post_tx(ref Transaction tr);
      scb.save_expected(tr);
    endtask
  endclass

  Driver                drv;
  Driver_cbs_drop       dcd;
  Scoreboard            scb;
  Driver_cbs_scoreboard dcs;

  initial begin
    drv = new();
    scb = new();
    dcd = new();
    dcs = new(scb);
    drv.cbs.push_back(dcd);   // error injection
    drv.cbs.push_back(dcs);   // scoreboard connection
    drv.run(6);
    $display("scoreboard'a giden id'ler: %p", scb.expected);
    $finish;
  end
endmodule
