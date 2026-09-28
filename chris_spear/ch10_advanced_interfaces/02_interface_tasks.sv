// 02_interface_tasks.sv
// Book: Ch.10  10.4 Procedural Code in an Interface
//       (Ex 10-14 parallel protocol tasks, 10-15 serial protocol tasks)
//
// Put the protocol detail inside the interface: the testbench just says
// "sendData(x)" and does not know how the bits go out. The same test code runs
// with a parallel or serial protocol by only swapping the interface.
`timescale 1ns/1ns

// Ex 10-14: parallel protocol -> 8 bits in one clock
interface simple_if_par (input logic clk);
  logic [7:0] data;
  logic       valid;

  task automatic sendData(input logic [7:0] d);
    @(negedge clk);
    data  = d;
    valid = 1;
    @(negedge clk);
    valid = 0;
  endtask

  task automatic rcvData(output logic [7:0] d);
    @(posedge clk iff valid);
    d = data;
  endtask
endinterface

// Ex 10-15: serial protocol -> 1 bit per clock over 8 clocks (LSB first)
interface simple_if_ser (input logic clk);
  logic data, start;

  task automatic sendData(input logic [7:0] d);
    @(negedge clk);
    start = 1;
    for (int i = 0; i < 8; i++) begin
      data = d[i];
      @(negedge clk);
      start = 0;
    end
  endtask

  task automatic rcvData(output logic [7:0] d);
    @(posedge clk iff start);
    for (int i = 0; i < 8; i++) begin
      d[i] = data;
      @(posedge clk);
    end
  endtask
endinterface


module tb_interface_tasks;
  bit clk;
  always #5 clk = ~clk;

  simple_if_par par (clk);
  simple_if_ser ser (clk);

  logic [7:0] rx;

  initial begin
    par.valid = 0;
    ser.start = 0;

    // The same "test", two different protocols
    fork
      par.sendData(8'hA5);
      par.rcvData(rx);
    join
    $display("@%0t: paralel alindi = %h", $time, rx);

    fork
      ser.sendData(8'h3C);
      ser.rcvData(rx);
    join
    $display("@%0t: seri    alindi = %h", $time, rx);
    $finish;
  end
endmodule
