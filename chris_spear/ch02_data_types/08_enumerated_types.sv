// 08_enumerated_types.sv
// Book: Ch.2  2.12 Enumerated Types  (Ex 2-31..2-37)
module tb_enumerated_types;

  // Ex 2-32: enum typedef
  typedef enum {INIT, DECODE, IDLE} fsmstate_e;

  // Ex 2-33: assigning values
  typedef enum {BLUE, GREEN = 2, RED} color_e;          // 0, 2, 3

  // Ex 2-35: proper use -> make 0 also a valid member
  typedef enum {FIRST = 1, SECOND, THIRD} ordinal_e;
  typedef enum {BAD_O = 0, FIRST_O = 1, SECOND_O, THIRD_O} ordinal_ok_e;

  fsmstate_e   pstate, nstate;
  color_e      color, c2;
  ordinal_e    position;           // starts at 0 -> invalid!
  ordinal_ok_e position_ok;        // starts at 0 -> BAD_O
  int          c;

  initial begin
    pstate = IDLE;
    nstate = pstate.next();        // wraps around at the end
    $display("pstate=%s nstate=%s", pstate.name(), nstate.name());

    // Ex 2-34/2-35: initial value pitfall
    $display("position=%0d name='%s' (bos isim = gecersiz deger)",
             position, position.name());
    $display("position_ok=%s", position_ok.name());

    // Ex 2-36: iterate all members (do-while, because next() wraps)
    color = color.first();
    do begin
      $display("color = %0d / %s", color, color.name());
      color = color.next();
    end while (color != color.first());

    $display("num=%0d  last=%s", color.num(), color.last().name());

    // Ex 2-37: int <-> enum assignment
    color = GREEN;
    c = color;                     // enum -> int: free (c=2)
    c++;                           // 3 -> RED
    if (!$cast(color, c))          // int -> enum: checked via $cast
      $display("$cast basarisiz: %0d gecerli color degil", c);
    else
      $display("color=%s", color.name());

    c = 1;                         // 1 does not correspond to any member
    if (!$cast(c2, c))
      $display("$cast basarisiz: %0d gecerli color degil", c);

    c2 = color_e'(c);              // static cast: NO checking
    $display("statik cast: c2=%0d name='%s'", c2, c2.name());
    $finish;
  end
endmodule
