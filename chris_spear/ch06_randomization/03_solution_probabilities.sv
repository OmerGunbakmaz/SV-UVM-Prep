// 03_solution_probabilities.sv
// Book: Ch.6  6.5 Solution Probabilities
//       (Ex 6-17 unconstrained, 6-18 implication, 6-20 solve...before)
//
// The solver distributes uniformly over all VALID solutions:
//   flag -> value == 0   and with value being 4 bits, the valid (flag,value) pairs are:
//     flag=0: 16 solutions (value 0..15)
//     flag=1:  1 solution  (value 0)
//   -> 17 solutions total, so P(flag=1) = 1/17 !
//
//   solve flag before value -> flag is picked first 50/50, then value.
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_solution_probabilities;

  class NoSolve;
    rand bit       flag;
    rand bit [3:0] value;
    constraint c { flag -> value == 0; }
  endclass

  class WithSolve;
    rand bit       flag;
    rand bit [3:0] value;
    constraint c {
      solve flag before value;   // flag first, then value
      flag -> value == 0;
    }
  endclass

  localparam int N = 17000;

  NoSolve   ns = new();
  WithSolve ws = new();
  int ns_flag1, ws_flag1;

  initial begin
    repeat (N) begin
      assert (ns.randomize());
      ns_flag1 += ns.flag;
      assert (ws.randomize());
      ws_flag1 += ws.flag;
    end
    $display("solve YOK : flag=1 orani = %0.3f  (beklenen 1/17 = %0.3f)",
             real'(ns_flag1) / N, 1.0 / 17);
    $display("solve VAR : flag=1 orani = %0.3f  (beklenen 0.5)",
             real'(ws_flag1) / N);
    $finish;
  end
endmodule
