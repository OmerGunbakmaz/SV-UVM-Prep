// 07_typedef_struct_union.sv
// Book: Ch.2  2.10 typedef, 2.11 User-Defined Structures, 2.13 Constants
//       (Ex 2-25..2-30, 2-38)
module tb_typedef_struct_union;

  // Ex 2-25/2-26: typedef
  parameter int OPSIZE = 8;
  typedef reg [OPSIZE-1:0] opreg_t;
  typedef bit [31:0] uint;         // the shorthand defined in the book

  // Ex 2-28: struct (unpacked by default)
  typedef struct {bit [7:0] r, g, b;} pixel_s;

  // Ex 2-30: packed struct -> behaves like a single vector
  typedef struct packed {bit [7:0] r, g, b;} pixel_p_s;

  // Ex 2-29: union -> viewing the same bits as different types
  typedef union {int i; real f;} num_u;

  // Ex 2-38: const
  const byte colon = ":";

  opreg_t   op_a, op_b;
  uint      u;
  pixel_s   my_pixel;
  pixel_p_s pp;
  num_u     un;

  initial begin
    op_a = 8'hA5;
    op_b = ~op_a;
    u    = 32'hFFFF_FFFF;
    $display("op_a=%h op_b=%h u=%0d", op_a, op_b, u);

    // struct: assign fields by name or with a literal
    my_pixel = '{8'h10, 8'h20, 8'h30};
    my_pixel.b = 8'hFF;
    $display("pixel = %p", my_pixel);

    // packed struct: can also be used as a single vector
    pp = 24'h11_22_33;
    $display("pp.r=%h pp.g=%h pp.b=%h  bits=%h", pp.r, pp.g, pp.b, pp);

    // union
    un.f = 0.0;
    un.i = 5;
    $display("un.i=%0d", un.i);

    $display("const colon = %s", colon);
    $finish;
  end
endmodule
