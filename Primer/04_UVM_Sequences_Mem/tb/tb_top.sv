`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
`include "uvm_macros.svh"
  import mem_pkg::*;

  logic clk = 0;
  always #5 clk = ~clk;

  bus_if bif(clk);

  simple_mem #(.DEPTH(256)) dut (.bif(bif));

  initial begin
    bif.rst_n = 0;
    repeat (3) @(posedge clk);
    bif.rst_n = 1;
  end

  initial begin
    uvm_config_db #(virtual bus_if)::set(null, "uvm_test_top.*", "vif", bif);
    run_test("write_read_test");
  end

endmodule : tb_top
