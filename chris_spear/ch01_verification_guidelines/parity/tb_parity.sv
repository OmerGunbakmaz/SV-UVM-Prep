module tb;
  logic [7:0] din;
  logic       parity;

  parity dut (.din(din), .parity(parity));

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);

    din = 8'h00; #10;
    din = 8'h01; #10;
    din = 8'h03; #10;
    din = 8'hAA; #10;
    din = 8'hFF; #10;
    $finish;
  end
endmodule