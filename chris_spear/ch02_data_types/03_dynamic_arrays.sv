// 03_dynamic_arrays.sv
// Book: Ch.2  2.4 Dynamic Arrays  (Ex 2-15, 2-16)
module tb_dynamic_arrays;

  int arr[];
  int dyn[], d2[];
  bit [7:0] mask[] = '{8'b0000_0000, 8'b0000_0001,
                       8'b0000_0011, 8'b0000_0111,
                       8'b0000_1111, 8'b0001_1111};

  initial begin
    // 1) new[30]  -> old contents are DISCARDED
    arr = new[20];
    for (int i = 0; i < 20; i++) arr[i] = i * 2;
    $display("arr (20)          : %0p\n", arr);
    arr = new[30];
    $display("new[30]           : %0p\n", arr);

    // 2) new[30](arr) -> old contents are PRESERVED, remaining elements 0
    arr = new[20];
    for (int i = 0; i < 20; i++) arr[i] = i * 2;
    arr = new[30](arr);
    $display("new[30](arr)      : %0p\n", arr);

    // Ex 2-15: dynamic array operations
    dyn = new[5];
    foreach (dyn[j]) dyn[j] = j;
    d2 = dyn;                 // copy (d2 gets its own storage)
    d2[0] = 5;
    $display("dyn[0]=%0d d2[0]=%0d", dyn[0], d2[0]);
    dyn = new[20](dyn);       // grow + preserve
    dyn = new[100];           // 100 fresh elements, old ones gone
    $display("dyn.size()=%0d", dyn.size());
    dyn.delete();
    $display("delete sonrasi size=%0d", dyn.size());

    // Ex 2-16: unsized list -> size comes from the literal
    $display("mask.size()=%0d  mask=%p", mask.size(), mask);
    $finish;
  end
endmodule
