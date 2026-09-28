// 05_mailboxes.sv
// Book: Ch.7  7.6 Mailboxes
//       (Ex 7-26 generator -> driver object passing, 7-27/7-28 bounded mailbox,
//        7-29..7-31 producer-consumer without synchronization,
//        7-32..7-34 with an event, 7-35/7-36 synchronization with a second mailbox)
`timescale 1ns/1ns

module tb_mailboxes;

  class Transaction;
    int id;
    function new(int id); this.id = id; endfunction
  endclass

  // Ex 7-26: create a NEW object each round, put its handle in the mailbox
  class Generator;
    mailbox #(Transaction) gen2drv;
    function new(mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
    endfunction
    task run(int n);
      Transaction tr;
      for (int i = 0; i < n; i++) begin
        tr = new(i);
        gen2drv.put(tr);
      end
    endtask
  endclass

  class Driver;
    mailbox #(Transaction) gen2drv;
    function new(mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
    endfunction
    task run(int n);
      Transaction tr;
      repeat (n) begin
        gen2drv.get(tr);
        $display("@%0t: Driver tr#%0d aldi", $time, tr.id);
        #5;
      end
    endtask
  endclass

  mailbox #(Transaction) mbx = new();
  mailbox #(int)         bounded, sync_mbx, data_mbx;
  Generator gen;
  Driver    drv;
  int       v;

  initial begin
    $display("--- 7-26: generator -> driver ---");
    gen = new(mbx);
    drv = new(mbx);
    fork
      gen.run(3);
      drv.run(3);
    join

    // Ex 7-27/7-28: bounded mailbox -> put() blocks when full
    $display("--- 7-27: bounded mailbox (boyut 1) ---");
    bounded = new(1);
    fork
      for (int i = 1; i < 4; i++) begin
        $display("@%0t: producer put(%0d)", $time, i);
        bounded.put(i);
        $display("@%0t: producer put(%0d) tamam", $time, i);
      end
      repeat (3) begin
        #10 bounded.get(v);
        $display("@%0t: consumer get -> %0d", $time, v);
      end
    join

    // Ex 7-35: fully synchronized producer-consumer with a second mailbox
    //   the producer does not produce the next value until the consumer says "got it"
    $display("--- 7-35: mailbox ile senkronizasyon ---");
    data_mbx = new();
    sync_mbx = new();
    fork
      for (int i = 1; i < 4; i++) begin          // producer
        $display("@%0t: producer %0d gonderiyor", $time, i);
        data_mbx.put(i);
        sync_mbx.get(v);                        // wait for ack
      end
      repeat (3) begin                          // consumer
        int j;
        #3 data_mbx.get(j);
        $display("@%0t: consumer %0d aldi", $time, j);
        sync_mbx.put(1);                        // ack
      end
    join

    // peek / try_get / num
    data_mbx.put(42);
    $display("num=%0d", data_mbx.num());
    void'(data_mbx.try_peek(v)); $display("try_peek -> %0d (mailbox'ta kalir)", v);
    void'(data_mbx.try_get(v));  $display("try_get  -> %0d  num=%0d", v, data_mbx.num());
    $finish;
  end
endmodule
