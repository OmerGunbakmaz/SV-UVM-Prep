// 06_random_control.sv
// Book: Ch.6  6.13 Atomic Stimulus Generation vs. Scenario Generation,
//              6.14 Random Control, 6.15 Random Generators
//       (Ex 6-53 randsequence, 6-54 randcase + $urandom_range,
//        6-56 randcase decision tree)
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_random_control;

  int len;

  task automatic cmd(string name);
    $write("%s ", name);
  endtask

  initial begin
    // Ex 6-54: randcase -> weighted branch selection (no class needed)
    repeat (8) begin
      randcase
        1: len = $urandom_range(0, 2);      // 10% short
        8: len = $urandom_range(3, 5);      // 80% medium
        1: len = $urandom_range(6, 7);      // 10% long
      endcase
      $write("%0d ", len);
    end
    $display(" <- randcase uzunluklari");

    // Ex 6-53: randsequence -> scenario (command sequence) generation
    //   stream : generates 4 kinds of sequences, weighted
    //   cfg_read / io_read / mem_read : their own sub-sequences
    repeat (3) begin
      randsequence (stream)
        stream   : cfg_read := 1 |
                   io_read  := 2 |
                   mem_read := 5 ;
        cfg_read : { cmd("CFG_READ"); } | { cmd("CFG_READ"); } cfg_read ;
        mem_read : { cmd("MEM_READ"); } | { cmd("MEM_READ"); } mem_read ;
        io_read  : { cmd("IO_READ");  } | { cmd("IO_READ");  } io_read  ;
      endsequence
      $display("");
    end

    // Ex 6-56: nested randcase -> a decision tree
    repeat (4) begin
      randcase
        1: randcase
             10: $display("tree: one_one");
             20: $display("tree: one_two");
           endcase
        4: randcase
             1: $display("tree: two_one");
             2: $display("tree: two_two");
           endcase
      endcase
    end

    // 6.15: difference between $urandom / $urandom_range / $random
    $display("$urandom=%0d  $urandom_range(10)=%0d  $urandom_range(5,9)=%0d",
             $urandom, $urandom_range(10), $urandom_range(5, 9));
    $finish;
  end
endmodule
