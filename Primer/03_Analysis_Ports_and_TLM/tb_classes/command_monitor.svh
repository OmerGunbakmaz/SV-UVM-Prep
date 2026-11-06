class command_monitor extends uvm_component;
   `uvm_component_utils(command_monitor)

   uvm_analysis_port #(command_s) ap;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      virtual tinyalu_bfm bfm;
      if (!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*", "bfm", bfm))
         `uvm_fatal("COMMAND_MONITOR", "bfm alinamadi")
      bfm.command_monitor_h = this;
      ap = new("ap", this);
   endfunction : build_phase

   function void write_to_monitor(byte A, byte B, operation_t op);
      command_s cmd;
      cmd.A  = A;
      cmd.B  = B;
      cmd.op = op;
      `uvm_info("COMMAND_MONITOR", $sformatf("A:%2h B:%2h op:%s", A, B, op.name()), UVM_HIGH)
      ap.write(cmd);
   endfunction : write_to_monitor

endclass : command_monitor
