// 03_automatic_storage.sv
// Book: Ch.3  3.7 Local Data Storage
//       (Ex 3-19 automatic, 3-20 static initialization bug, 3-21 fix)
//
// In Verilog (and inside an SV module/program) routines are STATIC by default:
// local variables have a single copy shared by all calls.
module tb_automatic_storage;

  logic [7:0] addr;

  // STATIC task: if called twice at once, the local variable is clobbered
  task static wait_static(input int id, input int delay);
    int my_id;
    my_id = id;
    #delay;
    $display("@%0t static    : cagiran=%0d  my_id=%0d", $time, id, my_id);
  endtask

  task automatic wait_auto(input int id, input int delay);
    int my_id;
    my_id = id;
    #delay;
    $display("@%0t automatic : cagiran=%0d  my_id=%0d", $time, id, my_id);
  endtask

  // Ex 3-20: static initialization bug
  //   'local_addr = addr << 2' initial value is computed once at the START
  //   of simulation (addr is X then), not on every call!
  task static bug_static;
    static logic [7:0] local_addr = addr << 2;   // BUG
    $display("static    local_addr = %h", local_addr);
  endtask

  // Ex 3-21: automatic -> the initial value is recomputed on every call
  task automatic fix_auto;
    logic [7:0] local_addr = addr << 2;
    $display("automatic local_addr = %h", local_addr);
  endtask

  initial begin
    // static: everything, including the arguments (id, delay), is a single
    // copy -> the second call clobbers the first, both lines show "2".
    fork
      wait_static(1, 20);
      wait_static(2, 10);
    join
    fork
      wait_auto(1, 20);
      wait_auto(2, 10);
    join

    addr = 8'h11;
    bug_static();
    fix_auto();
    $finish;
  end
endmodule
