// test.sv  --  testbench as a program block
// Book: Ch.5  5.4.2 program, 5.5 Interface Driving and Sampling
//       (Ex 5-11 modport, 5-15/5-18 test with a clocking block,
//        5-19..5-21 synchronous driving: @cb, cb.x <=)
//
// program block: TB code runs in the Reactive region -> no race with the DUT.
// Simulation ends automatically once all initial blocks finish.
//
// NOTE: Intel Questa FSE (free edition) requires an svverification license
// for "program". So "module" is compiled by default; to see/run the book's
// program form: vlog +define+USE_PROGRAM ...
// (thanks to the clocking block there is no race condition either way.)
`ifdef USE_PROGRAM
program automatic test (arb_if.TEST arbif);
`else
module automatic test (arb_if.TEST arbif);
`endif

  int errors = 0;

  task automatic reset();
    arbif.rst <= 1;
    arbif.cb.request <= 2'b00;
    repeat (2) @arbif.cb;
    arbif.rst <= 0;
    @arbif.cb;
  endtask

  // Drive a request, check grant 2 clocks later
  task automatic check_grant(input logic [1:0] req, input logic [1:0] exp);
    arbif.cb.request <= req;     // driven on the next clock edge
    repeat (2) @arbif.cb;        // DUT responds in 1 clock, cb sees it 1 later
    if (arbif.cb.grant !== exp) begin
      $display("@%0t: HATA request=%b grant=%b (beklenen %b)",
               $time, req, arbif.cb.grant, exp);
      errors++;
    end
    else
      $display("@%0t: OK   request=%b grant=%b", $time, req, arbif.cb.grant);
  endtask

  initial begin
    reset();
    check_grant(2'b01, 2'b01);
    check_grant(2'b10, 2'b10);
    check_grant(2'b11, 2'b01);   // priority is on request[0]
    check_grant(2'b00, 2'b00);

    // Ex 5-20: waiting in units of the clocking block's clock.
    // The book's "##3" form needs a "default clocking" in this scope;
    // here the equivalent repeat(3) @cb is used.
    arbif.cb.request <= 2'b10;
    repeat (3) @arbif.cb;
    $display("@%0t: 3 clock sonra grant=%b", $time, arbif.cb.grant);

    $display("%s (%0d hata)", errors ? "TEST KALDI" : "TEST GECTI", errors);
    $finish;     // needed since in module the clock never stops
  end

`ifdef USE_PROGRAM
endprogram
`else
endmodule
`endif
