// 03_casting_virtual_methods.sv
// Book: Ch.8  8.4 Type Casting and Virtual Methods
//       (Ex 8-10 Base/Extended, 8-11 extended -> base (free),
//        8-12 base -> extended (compile error), 8-13 $cast,
//        8-14/8-15 calling a virtual vs non-virtual method)
module tb_casting_virtual_methods;

  class Transaction;
    bit [31:0] src = 32'h1;
    virtual function void display_v(string prefix = "");
      $display("%sTransaction(virtual)     src=%0h", prefix, src);
    endfunction
    function void display_nv(string prefix = "");
      $display("%sTransaction(non-virtual) src=%0h", prefix, src);
    endfunction
  endclass

  class BadTr extends Transaction;
    bit bad_crc = 1;
    virtual function void display_v(string prefix = "");
      $display("%sBadTr(virtual)           bad_crc=%0b", prefix, bad_crc);
    endfunction
    function void display_nv(string prefix = "");
      $display("%sBadTr(non-virtual)       bad_crc=%0b", prefix, bad_crc);
    endfunction
  endclass

  Transaction tr;
  BadTr       bad, bad2;

  initial begin
    // Ex 8-11: subclass handle -> base class handle (upcast): free
    bad = new();
    tr  = bad;
    $display("tr.src=%0h", tr.src);
    // $display(tr.bad_crc);          // ERROR: Transaction has no bad_crc

    // Ex 8-15: handle type is Transaction, object is BadTr
    //   virtual     -> based on the OBJECT's type  (BadTr)
    //   non-virtual -> based on the HANDLE's type  (Transaction)
    tr.display_v("tr -> ");
    tr.display_nv("tr -> ");

    // Ex 8-12/8-13: base -> subclass (downcast)
    //   bad2 = tr;                    // COMPILE ERROR
    //   $cast checks the object's real type at run time
    if ($cast(bad2, tr))
      $display("$cast basarili: bad2.bad_crc=%0b", bad2.bad_crc);

    tr = new();                        // now a real Transaction
    if (!$cast(bad2, tr))
      $display("$cast basarisiz: nesne BadTr degil");
    $finish;
  end
endmodule
