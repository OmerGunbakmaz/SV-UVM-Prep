// 01_first_class.sv
// Book: Ch.4  4.3 Your First Class, 4.6 Creating New Objects, 4.8 Using Objects
//       (Ex 4-1 BusTran, 4-2 handle, 4-3..4-5 new(), 4-6/4-7 multiple objects,
//        4-26 handle array)
module tb_first_class;

  // Ex 4-1: a simple transaction class
  class BusTran;
    bit [31:0] addr, crc, data[8];

    // Ex 4-4: constructor with arguments and default values
    function new(bit [31:0] addr = 3, d = 5);
      this.addr = addr;
      foreach (data[i]) data[i] = d;
    endfunction

    function void calc_crc;
      crc = addr ^ data.xor;
    endfunction : calc_crc

    function void display;
      $display("BusTran: addr=%h crc=%h data[0]=%0d", addr, crc, data[0]);
    endfunction : display
  endclass : BusTran

  BusTran b, b1, b2;         // Ex 4-2: handle declaration (no object yet)
  BusTran barray[4];         // Ex 4-26: array of handles

  initial begin
    // handle is null until new() is called
    if (b == null) $display("b == null (nesne yok)");

    b = new();               // default arguments: addr=3, d=5
    b.calc_crc();
    b.display();

    b = new(10);             // addr=10, d=5 -> previous object goes to GC
    b.display();

    b = new(.addr(20), .d(7));
    b.display();

    // Ex 4-6: two handles, two objects; then both point to the SAME object
    b1 = new(1);
    b2 = new(2);
    b1 = b2;                 // b1's old object is now unreachable
    b2.addr = 99;
    $display("b1.addr=%0d (b2 ile ayni nesne)", b1.addr);

    // Ex 4-26: array of handles -> a separate new() for each element
    foreach (barray[i]) begin
      barray[i] = new(i * 4);
      barray[i].calc_crc();
    end
    foreach (barray[i]) barray[i].display();

    // Set the handle to null to release the object
    b = null;
    $finish;
  end
endmodule
