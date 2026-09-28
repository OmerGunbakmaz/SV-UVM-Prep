// 01_apb_directed_test.sv
// Book: Ch.1  1.6 Directed Testing, 1.12 Layered Testbench
//       (Ex 1-1 .. 1-3: driving APB pins -> turning it into a task)
//
// We do the same job at two levels:
//   1) Pin level : every signal driven by hand (repetitive, error-prone)
//   2) Task level: apb_write/apb_read -> first step of the "command layer"
`timescale 1ns/1ps

// Simple APB slave: 16-word memory
module apb_mem (
  input  logic        pclk, presetn,
  input  logic [7:0]  paddr,
  input  logic        psel, penable, pwrite,
  input  logic [31:0] pwdata,
  output logic [31:0] prdata
);
  logic [31:0] mem [16];

  always_ff @(posedge pclk or negedge presetn)
    if (!presetn)
      foreach (mem[i]) mem[i] <= '0;
    else if (psel && penable && pwrite)
      mem[paddr[3:0]] <= pwdata;

  assign prdata = mem[paddr[3:0]];
endmodule


module tb_apb_directed;
  logic        pclk = 0, presetn;
  logic [7:0]  paddr;
  logic        psel, penable, pwrite;
  logic [31:0] pwdata, prdata;
  int          errors = 0;

  always #5 pclk = ~pclk;

  apb_mem dut (.*);

  // Ex 1-2: collect the pin driving into a task
  task automatic apb_write(input logic [7:0] addr, input logic [31:0] data);
    @(negedge pclk);
    paddr = addr; pwdata = data; pwrite = 1; psel = 1; penable = 0;
    @(negedge pclk);
    penable = 1;
    @(negedge pclk);
    psel = 0; penable = 0;
  endtask

  task automatic apb_read(input logic [7:0] addr, output logic [31:0] data);
    @(negedge pclk);
    paddr = addr; pwrite = 0; psel = 1; penable = 0;
    @(negedge pclk);
    penable = 1;
    #1 data = prdata;
    @(negedge pclk);
    psel = 0; penable = 0;
  endtask

  // A small "checker": compare against the expected value
  task automatic check_read(input logic [7:0] addr, input logic [31:0] exp);
    logic [31:0] got;
    apb_read(addr, got);
    if (got !== exp) begin
      $error("addr=%0h beklenen=%h alinan=%h", addr, exp, got);
      errors++;
    end
    else
      $display("[%0t] OK  addr=%0h data=%h", $time, addr, got);
  endtask

  initial begin
    {psel, penable, pwrite, paddr, pwdata} = '0;
    presetn = 0;
    repeat (2) @(negedge pclk);
    presetn = 1;

    // Ex 1-1: single write at pin level (we would have to rewrite this
    // for every test)
    @(negedge pclk);
    paddr = 8'h0; pwdata = 32'hDEAD_BEEF; pwrite = 1; psel = 1; penable = 0;
    @(negedge pclk);
    penable = 1;
    @(negedge pclk);
    psel = 0; penable = 0;

    // Ex 1-3: same thing with a task -> readable, reusable
    apb_write(8'h1, 32'h1111_1111);
    apb_write(8'h2, 32'h2222_2222);

    check_read(8'h0, 32'hDEAD_BEEF);
    check_read(8'h1, 32'h1111_1111);
    check_read(8'h2, 32'h2222_2222);
    check_read(8'h3, 32'h0);          // never written -> reset value

    $display("%s (%0d hata)", errors ? "TEST KALDI" : "TEST GECTI", errors);
    $finish;
  end
endmodule
