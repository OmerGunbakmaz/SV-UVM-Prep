// arb.sv  --  simple 2-request priority arbiter (request[0] has priority)
// Book: Ch.5  (Ex 5-10 arbiter using a modport interface)
//
// A single interface instead of 6 signals in the port list: adding a new
// signal only requires changing arb_if.sv.
module arb (arb_if.DUT arbif);

  always_ff @(posedge arbif.clk or posedge arbif.rst) begin
    if (arbif.rst)
      arbif.grant <= 2'b00;
    else if (arbif.request[0])
      arbif.grant <= 2'b01;
    else if (arbif.request[1])
      arbif.grant <= 2'b10;
    else
      arbif.grant <= 2'b00;
  end

endmodule
