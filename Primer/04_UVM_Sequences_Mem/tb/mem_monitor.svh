class mem_monitor extends uvm_monitor;
  `uvm_component_utils(mem_monitor)

  virtual bus_if vif;
  uvm_analysis_port #(mem_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db #(virtual bus_if)::get(this, "", "vif", vif))
      `uvm_fatal("MONITOR", "vif alinamadi")
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    mem_item tr;
    forever begin
      @(posedge vif.clk);
      if (vif.rst_n && vif.valid && vif.ready) begin
        tr       = mem_item::type_id::create("tr");
        tr.we    = vif.we;
        tr.addr  = vif.addr;
        tr.wdata = vif.wdata;
        @(negedge vif.clk);
        if (!tr.we) tr.rdata = vif.rdata;
        `uvm_info("MONITOR", tr.convert2string(), UVM_HIGH)
        ap.write(tr);
      end
    end
  endtask

endclass : mem_monitor
