class mem_driver extends uvm_driver #(mem_item);
  `uvm_component_utils(mem_driver)

  virtual bus_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db #(virtual bus_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRIVER", "vif alinamadi")
  endfunction

  task run_phase(uvm_phase phase);
    vif.valid <= 0;
    vif.we    <= 0;
    wait (vif.rst_n === 1'b1);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task drive(mem_item it);
    @(negedge vif.clk);
    vif.valid <= 1;
    vif.we    <= it.we;
    vif.addr  <= it.addr;
    vif.wdata <= it.wdata;
    @(negedge vif.clk);
    vif.valid <= 0;
    vif.we    <= 0;
    if (!it.we) it.rdata = vif.rdata;
  endtask

endclass : mem_driver
