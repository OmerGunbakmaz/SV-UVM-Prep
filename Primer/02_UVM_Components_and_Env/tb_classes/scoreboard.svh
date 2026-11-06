class scoreboard extends uvm_component;
   `uvm_component_utils(scoreboard)

   virtual tinyalu_bfm bfm;
   int pass_cnt;
   int fail_cnt;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*", "bfm", bfm))
         `uvm_fatal("SCOREBOARD", "bfm alinamadi")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      shortint predicted;
      forever begin
         @(posedge bfm.done);
         #1;
         case (bfm.op_set)
            add_op : predicted = bfm.A + bfm.B;
            and_op : predicted = bfm.A & bfm.B;
            xor_op : predicted = bfm.A ^ bfm.B;
            mul_op : predicted = bfm.A * bfm.B;
         endcase
         if (bfm.op_set != no_op && bfm.op_set != rst_op) begin
            if (predicted != bfm.result) begin
               fail_cnt++;
               `uvm_error("SCOREBOARD", $sformatf("FAIL A:%2h B:%2h op:%s result:%4h beklenen:%4h",
                          bfm.A, bfm.B, bfm.op_set.name(), bfm.result, predicted))
            end else begin
               pass_cnt++;
            end
         end
      end
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      `uvm_info("SCOREBOARD", $sformatf("pass: %0d  fail: %0d", pass_cnt, fail_cnt), UVM_LOW)
   endfunction : report_phase

endclass : scoreboard
