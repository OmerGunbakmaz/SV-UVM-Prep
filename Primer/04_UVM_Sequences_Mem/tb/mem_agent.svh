class mem_agent extends uvm_agent;
  `uvm_component_utils(mem_agent)

  uvm_sequencer #(mem_item) sqr;
  mem_driver                drv;
  mem_monitor               mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    mon = mem_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = uvm_sequencer #(mem_item)::type_id::create("sqr", this);
      drv = mem_driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass : mem_agent
