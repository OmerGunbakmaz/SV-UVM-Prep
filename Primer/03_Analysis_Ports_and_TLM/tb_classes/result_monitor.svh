class result_monitor extends uvm_component;
   `uvm_component_utils(result_monitor)

   uvm_analysis_port #(shortint) ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual tinyalu_bfm bfm;
      if (!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*", "bfm", bfm))
         `uvm_fatal("RESULT_MONITOR", "bfm alinamadi")
      bfm.result_monitor_h = this;
      ap = new("ap", this);
   endfunction : build_phase

   function void write_to_monitor(shortint r);
      `uvm_info("RESULT_MONITOR", $sformatf("result:%4h", r), UVM_HIGH)
      ap.write(r);
   endfunction : write_to_monitor

endclass : result_monitor
