// 01_simple_covergroup.sv
// Book: Ch.9  9.4 Simple Functional Coverage Example, 9.5 Anatomy of a Cover Group,
//              9.6 Triggering a Cover Group, 9.12 Coverage During Simulation
//       (Ex 9-2 simple object coverage, 9-5 covergroup inside a class,
//        9-8 covergroup triggered by an event)
//
// NOTE: covergroup requires an svverification license in Intel Questa FSE;
// run it on full Questa / VCS / Xcelium or EDA Playground.
`timescale 1ns/1ns

module tb_simple_covergroup;

  class Transaction;
    bit [31:0] data;
    bit [2:0]  port;                     // 8 ports
  endclass

  // Ex 9-2: module-level covergroup, manual sampling via sample()
  Transaction tr;

  covergroup CovPort;
    coverpoint tr.port;                  // 8 auto bins: auto[0]..auto[7]
  endgroup

  // Ex 9-5: define the covergroup INSIDE a class (embedded in a transactor)
  class Transactor;
    Transaction tr;

    covergroup CovPort;
      coverpoint tr.port;
    endgroup

    function new();
      CovPort = new();                   // an embedded covergroup is created with new()
    endfunction

    task run(int n);
      repeat (n) begin
        tr = new();
        tr.port = $urandom_range(0, 7);
        CovPort.sample();
      end
    endtask
  endclass

  // Ex 9-8: covergroup triggered automatically by an event
  event trans_ready;
  bit [2:0] last_port;

  covergroup CovEvent @(trans_ready);
    coverpoint last_port;
  endgroup

  CovPort    ck;
  CovEvent   ce;
  Transactor xtor;

  initial begin
    ck = new();
    ce = new();

    // 32 random transactions -> how many ports were covered?
    repeat (32) begin
      tr = new();
      tr.port = $urandom_range(0, 7);
      ck.sample();
      last_port = tr.port;
      -> trans_ready;                    // CovEvent samples on its own
      #1;
    end
    $display("CovPort  (modul)  : %0.2f%%", ck.get_coverage());
    $display("CovEvent (event)  : %0.2f%%", ce.get_coverage());

    xtor = new();
    xtor.run(4);                         // few samples -> low coverage
    $display("CovPort  (sinif)  : %0.2f%%", xtor.CovPort.get_coverage());

    // 9.12: measuring coverage during simulation and continuing to run
    while (xtor.CovPort.get_coverage() < 100.0) xtor.run(1);
    $display("CovPort  (sinif)  : %0.2f%% (100'e kadar kostu)", xtor.CovPort.get_coverage());
    $finish;
  end
endmodule
