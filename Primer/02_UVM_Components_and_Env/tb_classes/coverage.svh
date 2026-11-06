class coverage extends uvm_component;
   `uvm_component_utils(coverage)

   virtual tinyalu_bfm bfm;

   byte unsigned A;
   byte unsigned B;
   operation_t   op_set;

   covergroup op_cov;
      coverpoint op_set {
         bins single_cycle[] = {[add_op:xor_op], rst_op, no_op};
         bins multi_cycle    = {mul_op};
         bins opn_rst[]      = ([add_op:mul_op] => rst_op);
         bins rst_opn[]      = (rst_op => [add_op:mul_op]);
         bins twoops[]       = ([add_op:mul_op] [* 2]);
      }
   endgroup

   covergroup zeros_or_ones;
      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op, no_op};
      }
      a_leg : coverpoint A {
         bins zeros  = {'h00};
         bins others = {['h01:'hFE]};
         bins ones   = {'hFF};
      }
      b_leg : coverpoint B {
         bins zeros  = {'h00};
         bins others = {['h01:'hFE]};
         bins ones   = {'hFF};
      }
      ops_x_a : cross all_ops, a_leg;
      ops_x_b : cross all_ops, b_leg;
   endgroup

   function new(string name, uvm_component parent);
      super.new(name, parent);
      op_cov        = new();
      zeros_or_ones = new();
   endfunction : new

   function void build_phase(uvm_phase phase);
      if (!uvm_config_db #(virtual tinyalu_bfm)::get(null, "*", "bfm", bfm))
         `uvm_fatal("COVERAGE", "bfm alinamadi")
   endfunction : build_phase

   task run_phase(uvm_phase phase);
      forever begin
         @(negedge bfm.clk);
         A      = bfm.A;
         B      = bfm.B;
         op_set = bfm.op_set;
         op_cov.sample();
         zeros_or_ones.sample();
      end
   endtask : run_phase

   function void report_phase(uvm_phase phase);
      `uvm_info("COVERAGE", $sformatf("op_cov: %0.2f%%  zeros_or_ones: %0.2f%%",
                op_cov.get_coverage(), zeros_or_ones.get_coverage()), UVM_LOW)
   endfunction : report_phase

endclass : coverage
