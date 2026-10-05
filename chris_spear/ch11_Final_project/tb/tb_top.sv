`include "bus_if.sv"
`include "tb_pkg.sv"



`timescale 1ns/1ps

module tb_top;
    import tb_pkg::*;

    logic clk = 1'b0;
    always #5 clk = ~clk;

    bus_if bif(clk);
    simple_mem dut (bif);

    base_test test;

    initial begin
        //$display("SEED = %0d", $get_initial_random_seed());
        test = new(bif);
        test.run();
        $finish;
    end
    initial begin
        #200_000;
        $error("GLOBAL TIMEOUT — deadlock?");
        $finish;
    end

endmodule
