// 04_semaphores.sv
// Book: Ch.7  7.5 Semaphores  (Ex 7-25 access to a shared hardware resource)
//
// Semaphore = a key box. get() takes a key (waits if none),
// put() returns one, try_get() tries without waiting.
`timescale 1ns/1ns

module tb_semaphores;

  semaphore sem;               // will protect a single bus

  task automatic sequencer(string name, int n);
    repeat (n)
    begin
      sem.get(1);                          // acquire the bus
      $display("@%0t: %s bus'i aldi", $time, name);
      #10;                                 // bus transaction
      $display("@%0t: %s bus'i birakti", $time, name);
      sem.put(1);
      #1;                                  // give the other one a chance
    end
  endtask

  initial
  begin
    sem = new(1);                          // 1 key
    fork
      sequencer("A", 2);
      sequencer("B", 2);
    join

    // try_get: returns 0 if there is no key, does NOT wait
    sem.get(1);
    if (!sem.try_get(1))
      $display("@%0t: try_get basarisiz (anahtar kullanimda)", $time);
    sem.put(1);
    if (sem.try_get(1))
      $display("@%0t: try_get basarili", $time);
    $finish;
  end
endmodule
