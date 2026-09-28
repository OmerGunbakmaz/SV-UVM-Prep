// 01_fork_join.sv
// Book: Ch.7  7.2 Working with Threads
//       (Ex 7-1/7-2 begin...end + fork...join, 7-3/7-4 join_none,
//        7-5/7-6 join_any)
`timescale 1ns/1ns

module tb_fork_join;

  initial begin
    // Ex 7-1: fork...join -> continue once ALL threads finish
    $display("@%0t: [join] basla", $time);
    #10 $display("@%0t: sirali 1", $time);
    fork
      $display("@%0t: paralel basla", $time);
      #50 $display("@%0t: paralel #50 bitti", $time);
      #10 $display("@%0t: paralel #10 bitti", $time);
      begin                                   // begin...end = ONE thread
        #30 $display("@%0t: sirali blok #30", $time);
        #10 $display("@%0t: sirali blok #10", $time);
      end
    join
    $display("@%0t: [join] sonrasi", $time);

    // Ex 7-3: join_none -> continue immediately without waiting
    fork
      #10 $display("@%0t: [join_none] cocuk #10", $time);
      #20 $display("@%0t: [join_none] cocuk #20", $time);
    join_none
    $display("@%0t: [join_none] sonrasi (hemen)", $time);
    #25;

    // Ex 7-5: join_any -> continue once the FIRST thread finishes, others keep running
    //   Typical use: timeout
    fork
      #10 $display("@%0t: [join_any] hizli thread", $time);
      #40 $display("@%0t: [join_any] yavas thread (arka planda)", $time);
    join_any
    $display("@%0t: [join_any] sonrasi", $time);

    fork : timeout_block
      begin
        #100 $display("@%0t: islem bitti", $time);
      end
      begin
        #20 $display("@%0t: TIMEOUT!", $time);
      end
    join_any
    disable timeout_block;               // kill the remaining thread

    #50 $finish;
  end
endmodule
