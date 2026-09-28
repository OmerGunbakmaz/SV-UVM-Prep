// 04_coverage_options.sv
// Book: Ch.9  9.9 Coverage Options, 9.10 Parameterized Cover Groups,
//              9.11 Analyzing Coverage Data
//       (Ex 9-37 comment, 9-38 per_instance, 9-39 cross_num_print_missing,
//        9-40 goal, 9-41 parameterized covergroup, 9-42 argument by ref,
//        9-43/9-44 solve...before to fix the distribution)
//
// NOTE: covergroup requires an svverification license in Intel Questa FSE.
module tb_coverage_options;

  bit [2:0] port_a, port_b;
  bit [7:0] len;

  // Ex 9-41/9-42: parameterized covergroup
  //   - mid : value argument for the sampling boundaries
  //   - ref : which signal is sampled (a DIFFERENT signal per instance)
  covergroup CoverPort (ref bit [2:0] port, input int mid, input string name);
    option.per_instance = 1;                     // Ex 9-38: per-instance report
    option.comment      = name;                  // Ex 9-37
    option.goal         = 90;                    // Ex 9-40: 90% is enough
    option.cross_num_print_missing = 1000;       // Ex 9-39: print the missing ones
    cp : coverpoint port {
      bins lo = {[0:mid-1]};
      bins hi = {[mid:$]};
    }
  endgroup

  // 9.11: coverage usually fails to fill quickly because of the distribution.
  // Track length coverage in buckets; make 0 and the max end their own bins.
  covergroup CovLen;
    coverpoint len {
      bins zero        = {0};
      bins short_len[] = {[1:3]};
      bins mid         = {[4:254]};
      bins max         = {255};
    }
  endgroup

  CoverPort cpa, cpb;
  CovLen    cl;

  initial begin
    cpa = new(port_a, 4, "port_a");
    cpb = new(port_b, 2, "port_b");
    cl  = new();

    repeat (10) begin
      port_a = $urandom_range(0, 3);             // the hi bin is never seen
      port_b = $urandom;
      len    = $urandom;                         // hard to hit 0 and 255
      cpa.sample();
      cpb.sample();
      cl.sample();
    end
    $display("%s : %0.2f%%", cpa.option.comment, cpa.get_inst_coverage());
    $display("%s : %0.2f%%", cpb.option.comment, cpb.get_inst_coverage());
    $display("len    : %0.2f%%  (uc degerler icin directed test ya da", cl.get_coverage());
    $display("          dist/solve...before ile agirlik gerekir: Ex 9-44)");
    $finish;
  end
endmodule
