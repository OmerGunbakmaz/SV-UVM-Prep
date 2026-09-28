// arb_if.sv
// Book: Ch.5  5.3 The Interface Construct, 5.4 Stimulus Timing
//       (Ex 5-4 simple interface, 5-9 modport, 5-13 clocking block)
interface arb_if (input bit clk);
  logic [1:0] grant, request;
  logic       rst;

  // Ex 5-13: the TB side drives/samples through the clocking block.
  //   input  -> sampled 1 step BEFORE the clock (the DUT's old value)
  //   output -> driven after the clock (no race condition)
  clocking cb @(posedge clk);
    output request;
    input  grant;
  endclocking

  // Ex 5-9: modports set signal directions per connection
  modport TEST    (clocking cb, output rst);
  modport DUT     (input request, rst, clk, output grant);
  modport MONITOR (input request, grant, rst, clk);
endinterface
