// 01_procedural_statements.sv
// Book: Ch.3  3.2 Procedural Statements, 3.3 Tasks, Functions, Void Functions
//       (Ex 3-1 new operators, 3-2 break/continue, 3-3 void', 3-4, 3-5)
module tb_procedural_statements;

  // Ex 3-4: void function for debugging
  function automatic void print_state(int i, int sum);
    $display("@%0t: i=%0d sum=%0d", $time, i, sum);
  endfunction

  // Function with a return value
  function automatic int add3(int a, int b, int c);
    return a + b + c;
  endfunction

  // Ex 3-5: task with multiple statements without begin...end
  task automatic multiple_lines;
    $display("Ilk satir");
    $display("Ikinci satir");
  endtask

  int sum;

  initial begin
    // Ex 3-1: variable in a for, ++, +=, named block
    begin : example
      int array[10];
      sum = 0;
      for (int i = 0; i < 10; i++) begin
        array[i] = i;
        sum += array[i];
      end
      print_state(10, sum);
    end : example

    // Ex 3-2: break / continue (file reading in the book; a list here)
    begin
      automatic string cmds[$] = {"", "# yorum", "WRITE", "READ", "done", "HATA"};
      foreach (cmds[i]) begin
        if (cmds[i].len() == 0) continue;     // empty line: skip
        if (cmds[i][0] == "#")  continue;     // comment:    skip
        if (cmds[i] == "done")  break;        // done:       exit
        $display("komut: %s", cmds[i]);
      end
    end

    // Ex 3-3: deliberately ignore a function's return value
    void'(add3(1, 2, 3));
    $display("add3 = %0d", add3(1, 2, 3));

    multiple_lines();

    // Other useful constructs: do-while, unique case, inside
    begin
      automatic int k = 0;
      do k++; while (k < 3);
      $display("do-while sonrasi k=%0d", k);
      unique case (k) inside
        [0:2]: $display("kucuk");
        [3:9]: $display("orta");
      endcase
    end
    $finish;
  end
endmodule
