class mem_scoreboard extends uvm_subscriber #(mem_item);
  `uvm_component_utils(mem_scoreboard)

  bit [31:0] model [bit [31:0]];
  int pass_cnt;
  int fail_cnt;
  int skip_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void write(mem_item t);
    if (t.we) begin
      model[t.addr] = t.wdata;
    end else if (!model.exists(t.addr)) begin
      skip_cnt++;
    end else if (model[t.addr] !== t.rdata) begin
      fail_cnt++;
      `uvm_error("SCOREBOARD", $sformatf("FAIL addr:%3h okunan:%8h beklenen:%8h",
                 t.addr, t.rdata, model[t.addr]))
    end else begin
      pass_cnt++;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SCOREBOARD", $sformatf("pass: %0d  fail: %0d  skip: %0d",
              pass_cnt, fail_cnt, skip_cnt), UVM_LOW)
  endfunction

endclass : mem_scoreboard
