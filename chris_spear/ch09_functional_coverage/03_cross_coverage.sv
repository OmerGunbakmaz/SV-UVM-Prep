// 03_cross_coverage.sv
// Book: Ch.9  9.8 Cross Coverage
//       (Ex 9-28 basic cross, 9-30 named bins in a cross,
//        9-32 excluding with binsof, 9-33 weight,
//        9-35 desired combinations with binsof, 9-36 emulating with concatenation)
//
// NOTE: covergroup requires an svverification license in Intel Questa FSE.
module tb_cross_coverage;

  bit [2:0] port;
  bit [3:0] kind;

  // Ex 9-28/9-30/9-32
  covergroup CovPortKind;
    kind_cp : coverpoint kind {
      bins zero = {0};
      bins lo   = {[1:3]};
      bins hi[] = {[8:$]};
      bins misc = default;
    }
    port_cp : coverpoint port {
      bins port[] = {[0:$]};
    }
    cross kind_cp, port_cp {
      // Ex 9-32: some combinations are meaningless -> exclude from coverage
      ignore_bins hi_port7 = binsof(port_cp) intersect {7} &&
                             binsof(kind_cp.hi);
      ignore_bins md       = binsof(port_cp) intersect {0} &&
                             binsof(kind_cp) intersect {[9:10]};
    }
  endgroup

  // Ex 9-33/9-35: only the combinations of interest, weight on the cross
  bit a, b;
  covergroup CrossBinNames;
    a_cp : coverpoint a { bins a0 = {0}; bins a1 = {1};
                          option.weight = 0; }       // not counted on its own
    b_cp : coverpoint b { bins b0 = {0}; bins b1 = {1};
                          option.weight = 0; }
    ab   : cross a_cp, b_cp {
      bins a0b0 = binsof(a_cp.a0) && binsof(b_cp.b0);
      bins a1b0 = binsof(a_cp.a1) && binsof(b_cp.b0);
      bins b1   = binsof(b_cp.b1);                   // whatever a is
    }
  endgroup

  // Ex 9-36: doing the same thing with concatenation instead of a cross
  covergroup CrossManual;
    ab : coverpoint {a, b} {
      bins a0b0 = {2'b00};
      bins a1b0 = {2'b10};
      wildcard bins b1 = {2'b?1};
    }
  endgroup

  CovPortKind   cpk = new();
  CrossBinNames cbn = new();
  CrossManual   cm  = new();

  initial begin
    repeat (400) begin
      port = $urandom;
      kind = $urandom;
      cpk.sample();
    end
    $display("CovPortKind   : %0.2f%%", cpk.get_coverage());

    repeat (3) begin
      {a, b} = $urandom;
      cbn.sample();
      cm.sample();
    end
    $display("CrossBinNames : %0.2f%%", cbn.get_coverage());
    $display("CrossManual   : %0.2f%%", cm.get_coverage());
    $finish;
  end
endmodule
