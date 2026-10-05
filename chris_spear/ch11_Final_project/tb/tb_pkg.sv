package tb_pkg;
    parameter int WIDTH = 8;
    parameter int DEPTH = 256;
    typedef enum logic{OP_WRITE = 1'b1,OP_READ = 1'b0}op_e;
    `include "transaction.svh"
    `include "generator.svh"
    `include "driver.svh"
    `include "monitor.svh"
    `include "scoreboard.svh"
    `include "environment.svh"
    `include "base_test.svh"
endpackage : tb_pkg
