// 05_associative_arrays.sv
// Book: Ch.2  2.6 Associative Arrays  (Ex 2-18, 2-19)
//
// For modeling sparse memory: only the written addresses take up space.
module tb_associative_arrays;

  bit [63:0] assoc[bit [63:0]];   // Ex 2-18: 64-bit address space
  bit [63:0] idx = 1;

  int switch_tbl[string];          // Ex 2-19: string-indexed

  initial begin
    // Write to addresses 1,2,4,8,16 ... (sparse)
    repeat (64) begin
      assoc[idx] = idx;
      idx = idx << 1;
    end
    $display("assoc.num()=%0d", assoc.num());

    // Iterate with foreach
    foreach (assoc[i])
      if (i < 64) $display("assoc[%0h] = %0h", i, assoc[i]);

    // Iterate with first / next
    if (assoc.first(idx))
      do
        if (idx > 64'h1_0000_0000 && idx < 64'h8_0000_0000)
          $display("assoc[%h] = %h", idx, assoc[idx]);
      while (assoc.next(idx));

    // Find and delete the first element
    void'(assoc.first(idx));
    assoc.delete(idx);
    $display("ilk silindi, num=%0d", assoc.num());

    // Ex 2-19: string index (e.g. a configuration table)
    switch_tbl["min_address"] = 42;
    switch_tbl["max_address"] = 1492;

    // Check with exists(): reading a missing key returns the default value
    if (!switch_tbl.exists("min_address")) switch_tbl["min_address"] = 0;
    if (!switch_tbl.exists("max_address")) switch_tbl["max_address"] = 1000;

    foreach (switch_tbl[s])
      $display("switch_tbl[\"%s\"] = %0d", s, switch_tbl[s]);
    $finish;
  end
endmodule
