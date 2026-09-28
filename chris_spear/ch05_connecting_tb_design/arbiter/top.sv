// top.sv
// Book: Ch.5  5.6 Connecting It All Together, 5.7 Top-Level Scope
//       (Ex 5-5/5-25 top module, 5-24 clock generation must be in a module,
//        5-34 concurrent assertion checking X/Z)
`timescale 1ns/1ns

module top;
  bit clk;
  always #5 clk = ~clk;          // Ex 5-24: clock in the module, not the program

  arb_if arbif (clk);            // interface instance
  arb    a1    (arbif);          // DUT     -> modport DUT
  test   t1    (arbif);          // TB      -> modport TEST

  // Ex 5-34: outside of reset, request must never be X/Z
  a_no_x_request: assert property (@(posedge clk) disable iff (arbif.rst)
      !$isunknown(arbif.request))
    else $error("request X/Z oldu");
endmodule
