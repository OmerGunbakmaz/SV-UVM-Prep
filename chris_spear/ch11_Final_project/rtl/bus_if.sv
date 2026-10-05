`timescale 1ns/1ps

interface bus_if#(parameter WIDTH=8 , parameter DEPTH = 256)(input logic clk);
    logic rstn;
    logic we;
    logic [WIDTH -1 : 0]wdata;
    logic [WIDTH -1 : 0]rdata;
    logic [$clog2(DEPTH)-1 : 0]addr;
    logic ready;
    logic valid;
    modport DUT(
        input rstn,input clk,input we, input wdata, input addr, input valid,
        output ready, output rdata
    );
    clocking drv_cb @(posedge clk);
        default input #1step output #1ns;
        output rstn,we,wdata,addr,valid;
        input ready,rdata;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step output #1ns;
        input we,wdata,addr,valid,ready,rdata;
    endclocking
    
    modport MON(clocking mon_cb,input clk,rstn);
    modport DRV(clocking drv_cb,input clk,output rstn);

    task automatic do_reset;
        rstn = 1'b0;
        we = 1'b0;
        wdata = 0;
        valid = 1'b0;
        repeat(3) begin
            @(posedge clk);
        end
        rstn = 1'b1;
        @(posedge clk);
    endtask
endinterface
