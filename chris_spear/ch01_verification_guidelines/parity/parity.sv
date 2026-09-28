module parity (
  input  logic [7:0] din,
  output logic       parity
);
  assign parity = ^din;
endmodule