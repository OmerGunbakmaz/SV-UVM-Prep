class coverage extends uvm_subscriber #(command_s);
   `uvm_component_utils(coverage)

   byte unsigned A;
   byte unsigned B;
   operation_t   op_set;

   covergroup op_cov;
      coverpoint op_set {
         bins single_cycle[] = {[add_op:xor_op], rst_op, no_op};
         bins multi_cycle    = {mul_op};
         bins opn_rst[]      = ([add_op:mul_op] => rst_op);
         bins rst_opn[]      = (rst_op => [add_op:mul_op]);
      }
   endgroup

   covergroup data_cov;
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
      ops_x_ab : cross all_ops, a_leg, b_leg;
   endgroup

   function new(string name, uvm_component parent);
      super.new(name, parent);
      op_cov   = new();
      data_cov = new();
   endfunction : new

   function void write(command_s t);
      A      = t.A;
      B      = t.B;
      op_set = t.op;
      op_cov.sample();
      data_cov.sample();
   endfunction : write

   function void report_phase(uvm_phase phase);
      `uvm_info("COVERAGE", $sformatf("op_cov: %0.2f%%  data_cov: %0.2f%%",
                op_cov.get_coverage(), data_cov.get_coverage()), UVM_LOW)
   endfunction : report_phase

endclass : coverage
