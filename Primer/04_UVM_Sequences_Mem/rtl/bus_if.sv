interface bus_if(input logic clk);
  logic        rst_n;
  logic        valid;
  logic        we;
  logic        ready;
  logic [31:0] addr;
  logic [31:0] wdata;
  logic [31:0] rdata;

  modport DUT(input clk, rst_n, valid, we, addr, wdata, output ready, rdata);
endinterface
