// 04_copying_objects.sv
// Book: Ch.8  8.6 Copying an Object
//       (Ex 8-19/8-20 virtual copy, 8-21..8-23 split copying via copy_data)
//
// Problem: in every subclass copy() has to re-copy all fields.
// Solution: split the copying into copy_data(); each class copies only ITS OWN
// fields and calls super.copy_data(). copy() just creates the right-typed object.
module tb_copying_objects;

  class Transaction;
    bit [31:0] src, dst, data[4];

    // Ex 8-21: this class's fields only
    virtual function void copy_data(Transaction copy);
      copy.src  = src;
      copy.dst  = dst;
      copy.data = data;
    endfunction

    // Ex 8-23: copy() optionally copies into an existing target
    virtual function Transaction copy(Transaction to = null);
      if (to == null) copy = new();
      else            copy = to;
      copy_data(copy);
    endfunction

    virtual function string convert2string();
      return $sformatf("src=%0h dst=%0h data=%p", src, dst, data);
    endfunction
  endclass

  class BadTr extends Transaction;
    bit bad_crc;

    // Ex 8-22: base class fields first, then its own fields
    virtual function void copy_data(Transaction copy);
      BadTr bad;
      super.copy_data(copy);
      $cast(bad, copy);                 // access to the subclass fields
      bad.bad_crc = bad_crc;
    endfunction

    virtual function Transaction copy(Transaction to = null);
      BadTr bad;
      if (to == null) bad = new();
      else            $cast(bad, to);
      copy_data(bad);
      return bad;
    endfunction

    virtual function string convert2string();
      return $sformatf("%s bad_crc=%0b", super.convert2string(), bad_crc);
    endfunction
  endclass

  BadTr       b1;
  Transaction t2;

  initial begin
    b1 = new();
    b1.src = 1; b1.dst = 2; b1.data = '{1, 2, 3, 4}; b1.bad_crc = 1;

    t2 = b1.copy();                     // type: BadTr (virtual)
    b1.src = 99;                        // does not affect the copy
    $display("orijinal: %s", b1.convert2string());
    $display("kopya   : %s", t2.convert2string());
    $finish;
  end
endmodule
