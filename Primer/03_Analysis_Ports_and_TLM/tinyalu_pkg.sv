package tinyalu_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"

   typedef enum bit [2:0] {no_op  = 3'b000,
                           add_op = 3'b001,
                           and_op = 3'b010,
                           xor_op = 3'b011,
                           mul_op = 3'b100,
                           rst_op = 3'b111} operation_t;

   typedef struct {
      byte unsigned A;
      byte unsigned B;
      operation_t   op;
   } command_s;

`include "tester.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "scoreboard.svh"
`include "coverage.svh"
`include "env.svh"
`include "random_test.svh"

endpackage : tinyalu_pkg
