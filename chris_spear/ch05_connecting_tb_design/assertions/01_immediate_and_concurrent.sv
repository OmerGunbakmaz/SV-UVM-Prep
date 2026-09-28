// 01_immediate_and_concurrent.sv
// Book: Ch.5  5.9 SystemVerilog Assertions
//       (Ex 5-28 check with if, 5-29..5-33 procedural (immediate) assertion
//        and custom messages, 5-34 concurrent assertion)
`timescale 1ns/1ns

module tb_assertions;
  bit       clk;
  logic     request, grant;
  logic [3:0] bus;

  always #5 clk = ~clk;

  // Simple DUT behavior: grant 1 clock after request
  always_ff @(posedge clk) grant <= request;

  // Ex 5-34: concurrent assertion -> checked continuously on every clock
  //   "if request comes, grant must come on the next clock"
  a_req_gnt: assert property (@(posedge clk) request |=> grant)
    else $error("request'ten sonra grant gelmedi");

  // X/Z check
  a_bus_known: assert property (@(posedge clk) !$isunknown(bus))
    else $warning("bus X/Z: %b", bus);

  initial begin
    request = 0; bus = '0;
    @(negedge clk);

    // Ex 5-28: classic Verilog-style check
    request = 1;
    @(negedge clk);
    if (grant != 1'b1)
      $display("@%0t: HATA grant != 1", $time);

    // Ex 5-29/5-31: immediate assertion + pass/fail blocks
    a1: assert (grant == 1'b1)
      $display("@%0t: a1 gecti", $time);
    else
      $error("a1 kaldi: grant=%b", grant);

    // Ex 5-33: severity levels -> $info / $warning / $error / $fatal
    request = 0;
    @(negedge clk);
    a2: assert (grant == 1'b1)
    else $warning("a2 (kasitli): grant dustu, uyari olarak raporla");

    // Deliberately trigger the concurrent assertion:
    // set request=1 and force grant to stay at 0
    request = 1;
    force grant = 0;
    repeat (2) @(negedge clk);
    release grant;
    request = 0;

    bus = 4'b10x1;                       // a_bus_known warning
    @(negedge clk);
    bus = '0;
    repeat (2) @(negedge clk);
    $finish;
  end
endmodule
