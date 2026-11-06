module top;
   import uvm_pkg::*;
`include "uvm_macros.svh"
   import tinyalu_pkg::*;

   tinyalu_bfm bfm();

   tinyalu DUT (.A(bfm.A), .B(bfm.B), .op(bfm.op),
                .clk(bfm.clk), .reset_n(bfm.reset_n),
                .start(bfm.start), .done(bfm.done), .result(bfm.result));

   initial begin
      uvm_config_db #(virtual tinyalu_bfm)::set(null, "*", "bfm", bfm);
      run_test();
   end

endmodule : top
