// 01_virtual_interface_array.sv
// Book: Ch.10  10.2 Virtual Interfaces, 10.3 Connecting to Multiple Design
//               Configurations
//       (Ex 10-5 counter interface, 10-6 counter using the interface,
//        10-7/10-8 array of virtual interfaces, 10-9 Driver using a vif,
//        10-10/10-11 typedef virtual interface, 10-12 global parameter)
//
// A class (Driver) cannot connect to a static interface; a "virtual interface"
// is a HANDLE pointing to an interface instance. This lets the same Driver class
// connect to N different counters.
`timescale 1ns/1ns

// Ex 10-5
interface X_if (input logic clk);
  logic [7:0] din, dout;
  logic       reset_l, load;

  clocking cb @(posedge clk);
    output din, load;
    input  dout;
  endclocking

  modport DUT (input clk, din, reset_l, load, output dout);
  modport TB  (clocking cb, output reset_l);
endinterface

// Ex 10-6: 8-bit loadable counter
module counter (X_if.DUT xi);
  always_ff @(posedge xi.clk or negedge xi.reset_l)
    if (!xi.reset_l)   xi.dout <= '0;
    else if (xi.load)  xi.dout <= xi.din;
    else               xi.dout <= xi.dout + 1'b1;
endmodule


// Ex 10-12: a parameter shared by the whole testbench
package cnt_pkg;
  parameter int NUM_XI = 3;
endpackage


module tb_virtual_interface_array;
  import cnt_pkg::*;

  bit clk;
  always #5 clk = ~clk;

  // Ex 10-8: arrays of interfaces and DUTs (with generate)
  X_if xi[NUM_XI] (clk);
  for (genvar i = 0; i < NUM_XI; i++) begin : g_cnt
    counter c (xi[i]);
  end

  // Ex 10-10: typedef for the virtual interface -> readable code
  typedef virtual X_if.TB vXi_t;

  // Ex 10-9/10-11: Driver using a virtual interface
  class Driver;
    vXi_t xi;
    int   id;

    function new(vXi_t xi, int id);
      this.xi = xi;
      this.id = id;
    endfunction

    task reset();
      xi.reset_l <= 0;
      xi.cb.load <= 0;
      xi.cb.din  <= 0;
      repeat (2) @(xi.cb);
      xi.reset_l <= 1;
    endtask

    task load(logic [7:0] val);
      @(xi.cb);
      xi.cb.din  <= val;
      xi.cb.load <= 1;
      @(xi.cb);
      xi.cb.load <= 0;
    endtask

    task check(int cycles);
      repeat (cycles) @(xi.cb);
      $display("@%0t: Driver%0d dout=%0d", $time, id, xi.cb.dout);
    endtask
  endclass

  // Ex 10-7: array of virtual interfaces
  vXi_t  vxi[NUM_XI];
  Driver driver[NUM_XI];

  initial begin
    // an interface array needs a generate index -> assign with constant indices
    vxi = '{xi[0], xi[1], xi[2]};

    foreach (driver[i]) driver[i] = new(vxi[i], i);

    foreach (driver[i])
      fork
        automatic int j = i;
        begin
          driver[j].reset();
          driver[j].load(8'(10 * (j + 1)));  // start counting from 10, 20, 30
          driver[j].check(5);
        end
      join_none
    wait fork;
    $finish;
  end
endmodule
