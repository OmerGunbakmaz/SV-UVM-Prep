class mem_item extends uvm_sequence_item;
  `uvm_object_utils(mem_item)

  rand bit        we;
  rand bit [31:0] addr;
  rand bit [31:0] wdata;
       bit [31:0] rdata;

  constraint addr_c {
    addr[1:0] == 2'b00;
    addr < 1024;
  }

  function new(string name = "mem_item");
    super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
    mem_item rhs_;
    if (!$cast(rhs_, rhs))
      `uvm_fatal("MEM_ITEM", "cast basarisiz")
    super.do_copy(rhs);
    we    = rhs_.we;
    addr  = rhs_.addr;
    wdata = rhs_.wdata;
    rdata = rhs_.rdata;
  endfunction

  function string convert2string();
    if (we) return $sformatf("WRITE addr:%3h data:%8h", addr, wdata);
    else    return $sformatf("READ  addr:%3h data:%8h", addr, rdata);
  endfunction

endclass : mem_item
