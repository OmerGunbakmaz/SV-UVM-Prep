// 02_coverpoint_bins.sv
// Book: Ch.9  9.7 Data Sampling
//       (Ex 9-11/9-13 auto_bin_max, 9-14 coverpoint on an expression,
//        9-15/9-17 named bins, 9-19 conditional coverage with iff,
//        9-20 stop/start, 9-21 enum, 9-23 transition, 9-24 wildcard,
//        9-25/9-26 ignore_bins, 9-27 illegal_bins)
//
// NOTE: covergroup requires an svverification license in Intel Questa FSE.
module tb_coverpoint_bins;

  typedef enum {INIT, DECODE, IDLE} fsmstate_e;

  bit        clk, bus_reset;
  bit [2:0]  port;
  bit [3:0]  hdr_len, payload_len;
  bit [7:0]  kind;
  fsmstate_e pstate;

  covergroup CovAll;
    // Ex 9-11: collapse 8 values into 2 bins
    cp_port_2bins : coverpoint port { option.auto_bin_max = 2; }

    // Ex 9-14: expression -> 5-bit result, 0..31 but only 0..23 meaningful
    cp_len : coverpoint (hdr_len + payload_len + 5'b0) {
      bins len[] = {[0:23]};             // a separate bin for each value
    }

    // Ex 9-17: named bins
    cp_kind : coverpoint kind {
      bins zero       = {0};             // one bin
      bins lo         = {[1:3], 5};      // one bin, multiple values
      bins hi[]       = {[8:$]};         // 8..255 each a separate bin
      bins misc       = default;         // everything else
    }

    // Ex 9-19: sample during reset
    cp_port_noreset : coverpoint port iff (!bus_reset);

    // Ex 9-21: enum -> one bin per member
    cp_state : coverpoint pstate;

    // Ex 9-23: transition bins
    cp_trans : coverpoint port {
      bins t1 = (0 => 1), (0 => 2), (0 => 3);
      bins t2 = (1, 2 => 3, 4);          // 1=>3, 1=>4, 2=>3, 2=>4
      bins rep = (0 [*3]);               // 0 three times in a row
    }

    // Ex 9-24: wildcard -> x/z/? any value
    cp_even_odd : coverpoint port {
      wildcard bins even = {3'b??0};
      wildcard bins odd  = {3'b??1};
    }

    // Ex 9-25: ignore_bins -> not counted in coverage
    cp_low_ports : coverpoint port {
      ignore_bins hi = {[6:7]};
    }

    // Ex 9-27: illegal_bins -> an ERROR if sampled
    cp_legal : coverpoint hdr_len {
      illegal_bins bad = {15};
    }
  endgroup

  CovAll cov = new();

  initial begin
    for (int i = 0; i < 64; i++) begin
      port        = $urandom_range(0, 7);
      hdr_len     = $urandom_range(0, 14);   // 15 = illegal
      payload_len = $urandom_range(0, 9);
      kind        = $urandom;
      pstate      = fsmstate_e'($urandom_range(0, 2));
      bus_reset   = (i < 4);
      cov.sample();
    end

    // Ex 9-20: stop/start
    cov.stop();
    port = 7; cov.sample();                  // not counted
    cov.start();

    $display("toplam kapsam       : %0.2f%%", cov.get_coverage());
    $display("cp_port_2bins       : %0.2f%%", cov.cp_port_2bins.get_coverage());
    $display("cp_len              : %0.2f%%", cov.cp_len.get_coverage());
    $display("cp_kind             : %0.2f%%", cov.cp_kind.get_coverage());
    $display("cp_state            : %0.2f%%", cov.cp_state.get_coverage());
    $display("cp_trans            : %0.2f%%", cov.cp_trans.get_coverage());
    $display("cp_even_odd         : %0.2f%%", cov.cp_even_odd.get_coverage());
    $display("cp_low_ports        : %0.2f%%", cov.cp_low_ports.get_coverage());
    $finish;
  end
endmodule
