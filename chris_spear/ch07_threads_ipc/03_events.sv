// 03_events.sv
// Book: Ch.7  7.4 Events
//       (Ex 7-17/7-18 blocking with @ -> race, 7-19/7-20 wait(e.triggered),
//        7-21 passing an event to a constructor, 7-23 counting triggers)
`timescale 1ns/1ns

module tb_events;

  event e1, e2;

  // Ex 7-21: passing an event handle to a class
  class Generator;
    event done;
    int   id;
    function new(event done, int id);
      this.done = done;
      this.id   = id;
    endfunction
    task run();
      fork
        begin
          #(id * 10 + 10);
          $display("@%0t: Generator%0d bitti", $time, id);
          -> done;
        end
      join_none
    endtask
  endclass

  event     gen_done[3];
  Generator gen[3];

  initial begin
    // Ex 7-17: waiting with @. The two blocks trigger each other AT THE SAME TIME:
    // whichever runs first, the other misses its trigger -> deadlock risk
    fork
      begin
        $display("@%0t: 1: e1 tetikle", $time);
        -> e1;
        @e2;
        $display("@%0t: 1: e2 geldi", $time);
      end
      begin
        $display("@%0t: 2: e2 tetikle", $time);
        -> e2;
        @e1;                               // e1 was already triggered -> MISSED
        $display("@%0t: 2: e1 geldi (bu satir gorunmez)", $time);
      end
    join_none
    #1 $display("@%0t: @ ile: ikinci blok e1'i kacirdi", $time);
    disable fork;

    // Ex 7-19: wait(e.triggered) -> sees it if triggered in the same time step
    fork
      begin
        -> e1;
        wait (e2.triggered);
        $display("@%0t: 1: e2.triggered", $time);
      end
      begin
        -> e2;
        wait (e1.triggered);
        $display("@%0t: 2: e1.triggered", $time);
      end
    join

    // Ex 7-21/7-23: wait for several generators with events
    foreach (gen[i]) begin
      gen[i] = new(gen_done[i], i);
      gen[i].run();
    end
    foreach (gen[i]) wait (gen_done[i].triggered);
    $display("@%0t: tum generator'lar bitti", $time);
    $finish;
  end
endmodule
