// 01_builtin_types.sv
// Book: Ch.2  2.2 Built-in Data Types, 2.15 Expression Width
//       (Ex 2-1 logic, 2-2 signed types, 2-3 $isunknown, 2-40 width)
module tb_builtin_types;

  // Ex 2-1: logic replaces both reg and wire (as long as there is a single driver)
  logic       q, q_l, d, clk = 0;
  initial forever #5 clk = ~clk;
  always_ff @(posedge clk) q <= d;
  assign q_l = ~q;

  // Ex 2-2: 2-state types
  bit              b;     // 2-state, unsigned, 1 bit
  bit      [31:0]  b32;   // 2-state, unsigned
  int unsigned     ui;    // 2-state, 32 bit, unsigned
  int              i;     // 2-state, 32 bit, signed
  byte             bt;    // 2-state, 8 bit, signed   (-128..127)
  shortint         si;    // 2-state, 16 bit, signed
  longint          li;    // 2-state, 64 bit, signed
  integer          ig;    // 4-state, 32 bit, signed
  time             t;     // 4-state, 64 bit, unsigned
  real             r;

  logic [3:0] port;
  bit   [7:0] w8;
  bit         one = 1'b1;

  initial begin
    // 2-state vs 4-state: assigning X/Z to a 2-state var gives 0 (silently!)
    port = 4'b10xz;
    b32  = port;
    $display("logic port=%b  -> bit b32=%0b  (X/Z kayboldu)", port, b32[3:0]);

    // Ex 2-3: X/Z check
    if ($isunknown(port))
      $display("port icinde X veya Z var: %b", port);

    // signed / unsigned pitfall
    bt = 8'hFF;
    $display("byte 8'hFF = %0d (signed!)", bt);
    bt = 127; bt++;
    $display("byte 127+1 = %0d (tasma)", bt);

    // Ex 2-40: expression width depends on the context
    $display("1'b1 + 1'b1              = %0d", one + one);          // 0
    b32 = one + one;
    $display("b32 = 1'b1 + 1'b1        = %0d", b32);                // 2
    $display("one + 1                  = %0d", one + 1);            // 2 (1 is 32 bit)
    w8 = 8'hF0;
    $display("w8 + w8 (8 bit baglam)   = %0h", 8'(w8 + w8));        // E0
    $display("w8 + w8 (32 bit baglam)  = %0h", w8 + w8 + 32'd0);    // 1E0

    // logic can take continuous assignment + always_ff on the same variable
    d = 1; @(posedge clk); #1;
    $display("q=%b q_l=%b", q, q_l);
    $finish;
  end
endmodule
