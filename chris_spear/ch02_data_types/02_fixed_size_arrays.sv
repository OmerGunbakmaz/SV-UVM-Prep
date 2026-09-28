// 02_fixed_size_arrays.sv
// Book: Ch.2  2.3 Fixed-Size Arrays
//       (Ex 2-4..2-14: declaration, initialization, foreach, copy/compare,
//        packed / unpacked / mixed arrays)
module tb_fixed_size_arrays;

  int lo_hi [0:15];          // Ex 2-4: 16 elements
  int c_style [16];          // same thing, C style
  int array2 [0:7][0:3];     // Ex 2-5: multi-dimensional
  int md [2][3] = '{'{0,1,2}, '{3,4,5}};   // Ex 2-7: init with a literal

  bit [31:0] src[5] = '{0,1,2,3,4};
  bit [31:0] dst[5] = '{5,4,3,2,1};

  bit [3:0][7:0] bytes;      // Ex 2-13: packed -> a single 32 bit vector
  bit [3:0][7:0] barray[3];  // Ex 2-14: 3 packed 32 bit words

  initial begin
    // Ex 2-8: for and foreach
    for (int i = 0; i < $size(c_style); i++) c_style[i] = i * i;
    foreach (c_style[i]) lo_hi[i] = c_style[i];
    $display("lo_hi = %p", lo_hi);

    // Ex 2-9: multi-dimensional foreach -> [i,j] syntax (not [i][j]!)
    foreach (md[i, j])
      $display("md[%0d][%0d] = %0d", i, j, md[i][j]);

    // Iterate only the first dimension
    foreach (md[i]) begin
      $write("%0d:", i);
      foreach (md[, j]) $write(" %0d", md[i][j]);
      $display;
    end

    // Ex 2-11: copy and compare (no loop needed)
    if (src == dst) $display("src == dst");
    else            $display("src != dst");

    dst = src;                 // copy the whole array
    dst[0] = 5;
    $display("src[1:4] %s dst[1:4]", (src[1:4] == dst[1:4]) ? "==" : "!=");

    // Ex 2-12: use word and bit indices together
    $display("src[4]=%b  src[4][0]=%b  src[4][2:1]=%b", src[4], src[4][0], src[4][2:1]);

    // Ex 2-13/2-14: packed arrays
    bytes = 32'hCAFE_DADA;
    $display("bytes=%h  bytes[3]=%h  bytes[3][7]=%b", bytes, bytes[3], bytes[3][7]);

    barray[0] = 32'h0123_4567;   // write the whole word at once
    barray[0][3] = 8'hAB;        // a single byte
    barray[0][1][6] = 1'b1;      // a single bit
    $display("barray[0]=%h", barray[0]);

    // System functions on arrays
    $display("$size(array2)=%0d  $dimensions(array2)=%0d",
             $size(array2), $dimensions(array2));
    $finish;
  end
endmodule
