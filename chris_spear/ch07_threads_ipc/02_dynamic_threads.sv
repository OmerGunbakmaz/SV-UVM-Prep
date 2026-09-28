// 02_dynamic_threads.sv
// Book: Ch.7  7.2.4 Creating Threads Dynamically, 7.2.5 Automatic Variables,
//              7.2.6..7.2.9 Disabling and Waiting for Threads
//       (Ex 7-8 dynamic thread, 7-9/7-10 buggy join_none in a loop,
//        7-11/7-12 fix with automatic, 7-13..7-15 disable,
//        7-16 wait fork)
`timescale 1ns/1ns

module tb_dynamic_threads;

  // Ex 7-8: for each transaction, start a background "check" thread
  task automatic check_trans(int id, int delay);
    fork
      begin
        #delay;
        $display("@%0t: check_trans %0d tamam", $time, id);
      end
    join_none                      // don't block the caller
  endtask

  initial begin
    // Ex 7-9/7-10: WRONG -> j is the loop variable, by the time the threads run
    //              the loop is already done: they all see j=3
    $display("--- hatali join_none dongusu ---");
    for (int j = 0; j < 3; j++)
      fork
        $write("%0d ", j);
      join_none
    #0 $display("");

    // Ex 7-11: CORRECT -> each thread gets its own automatic copy
    $display("--- automatic ile ---");
    for (int j = 0; j < 3; j++)
      fork
        automatic int k = j;
        $write("%0d ", k);
      join_none
    #0 $display("");

    // Ex 7-8 + Ex 7-16: start threads, wait for all with wait fork
    $display("--- dinamik thread + wait fork ---");
    for (int i = 0; i < 3; i++) check_trans(i, 10 * (3 - i));
    wait fork;                          // let ALL children in this scope finish
    $display("@%0t: tum kontroller bitti", $time);

    // Ex 7-14: disable fork -> kill only the children of this scope
    $display("--- disable fork ---");
    fork
      begin
        check_trans(10, 5);
        check_trans(11, 50);            // will be killed before it finishes
        fork
          #10 $display("@%0t: bekleyen thread", $time);
        join_none
        #20 disable fork;               // number 11 is killed
        $display("@%0t: disable fork cagrildi", $time);
      end
    join

    #100 $finish;
  end
endmodule
