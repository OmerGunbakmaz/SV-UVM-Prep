// 04_dynamic_objects.sv
// Book: Ch.4  4.14 Understanding Dynamic Objects
//       (Ex 4-21 passing objects, 4-22/4-23 handle without/with ref,
//        4-24/4-25 buggy generator that creates one object vs the correct one)
module tb_dynamic_objects;

  class Transaction;
    static int count = 0;
    int id;
    bit [31:0] addr;
    function new(); id = count++; endfunction
  endclass

  // Ex 4-21: handle passed as input -> the OBJECT can be modified
  function automatic void set_addr(Transaction t, bit [31:0] a);
    t.addr = a;                     // the caller's object changes
  endfunction

  // Ex 4-22: WRONG -> the handle is not ref, the new object never reaches the caller
  function automatic void create_bad(Transaction tr);
    tr = new();
    tr.addr = 42;
  endfunction

  // Ex 4-23: CORRECT -> with ref the handle itself changes
  function automatic void create_good(ref Transaction tr);
    tr = new();
    tr.addr = 42;
  endfunction

  // Ex 4-24: WRONG generator -> one object "sent" 3 times
  task automatic generator_bad(ref Transaction q[$], input int n);
    Transaction t = new();
    repeat (n) begin
      t.addr = $urandom_range(0, 255);
      q.push_back(t);               // always the SAME handle
    end
  endtask

  // Ex 4-25: CORRECT generator -> a new object each iteration
  task automatic generator_good(ref Transaction q[$], input int n);
    Transaction t;
    repeat (n) begin
      t = new();
      t.addr = $urandom_range(0, 255);
      q.push_back(t);
    end
  endtask

  Transaction t, qb[$], qg[$];

  initial begin
    t = new();
    set_addr(t, 32'hABCD);
    $display("set_addr sonrasi t.addr=%h", t.addr);

    t = null;
    create_bad(t);
    $display("create_bad  sonrasi t %s", (t == null) ? "== null  (BUG)" : "!= null");
    create_good(t);
    $display("create_good sonrasi t.addr=%0d", t.addr);

    generator_bad(qb, 3);
    foreach (qb[i]) $display("bad [%0d] id=%0d addr=%0d", i, qb[i].id, qb[i].addr);
    generator_good(qg, 3);
    foreach (qg[i]) $display("good[%0d] id=%0d addr=%0d", i, qg[i].id, qg[i].addr);
    $finish;
  end
endmodule
