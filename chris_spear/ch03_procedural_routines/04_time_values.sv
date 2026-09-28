// 04_time_values.sv
// Book: Ch.3  3.8 Time Values  (Ex 3-22 time literals and $timeformat)
module tb_time_values;
  timeunit      1ns;
  timeprecision 1ps;

  real   rdelay = 800ps;     // 0.8 (stored in ns)
  time   t;

  initial begin
    $timeformat(-9, 3, "ns", 8);   // unit=ns, 3 decimals, suffix, width

    #1       $display("%t", $realtime);   //    1.000ns
    #2ns     $display("%t", $realtime);   //    3.000ns
    #0.1ns   $display("%t", $realtime);   //    3.100ns
    #41ps    $display("%t", $realtime);   //    3.141ns
    #rdelay  $display("%t", $realtime);   //    3.941ns

    // $time rounds to an integer, $realtime keeps the fractional part
    t = $time;
    $display("$time=%0t  $realtime=%t", t, $realtime);
    $finish;
  end
endmodule
