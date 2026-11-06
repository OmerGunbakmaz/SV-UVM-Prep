class write_read_seq extends uvm_sequence #(mem_item);
  `uvm_object_utils(write_read_seq)

  int n = 20;

  function new(string name = "write_read_seq");
    super.new(name);
  endfunction

  task body();
    mem_item wr, rd;
    repeat (n) begin
      wr = mem_item::type_id::create("wr");
      start_item(wr);
      assert(wr.randomize() with {we == 1;});
      finish_item(wr);

      rd = mem_item::type_id::create("rd");
      start_item(rd);
      assert(rd.randomize() with {we == 0; addr == wr.addr;});
      finish_item(rd);
    end
  endtask

endclass : write_read_seq


class random_seq extends uvm_sequence #(mem_item);
  `uvm_object_utils(random_seq)

  int n = 100;

  function new(string name = "random_seq");
    super.new(name);
  endfunction

  task body();
    repeat (n) begin
      req = mem_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {addr < 64;});
      finish_item(req);
    end
  endtask

endclass : random_seq
