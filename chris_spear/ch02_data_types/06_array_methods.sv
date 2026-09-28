// 06_array_methods.sv
// Book: Ch.2  2.8 Array Methods, 2.9 Choosing a Storage Type
//       (Ex 2-20 sum, 2-21 min/max/unique, 2-22/2-23 find + with)
module tb_array_methods;

  bit on[10];
  int total;
  int f[6] = '{1, 6, 2, 6, 8, 6};
  int d[]  = '{2, 4, 6, 8, 10};
  int q[$] = {1, 3, 5, 7};
  int tq[$];

  initial begin
    // Ex 2-20: sum -> the result width is the element width!
    foreach (on[i]) on[i] = i;       // on[i] = 0/1
    $display("on.sum = %0d  (1 bit!)", on.sum);
    total = on.sum with (int'(item)); // force the width
    $display("on.sum with int = %0d", total);

    // Ex 2-21: min, max, unique -> all return a QUEUE
    tq = q.min();    $display("min    = %p", tq);
    tq = d.max();    $display("max    = %p", tq);
    tq = f.unique(); $display("unique = %p", tq);

    // Ex 2-22: the find family
    tq = d.find with (item > 3);            $display("find >3          = %p", tq);
    tq = d.find_index with (item > 3);      $display("find_index >3    = %p", tq);
    tq = d.find_first with (item > 99);     $display("find_first >99   = %p (bos)", tq);
    tq = d.find_first_index with (item == 8); $display("find_first_index = %p", tq);
    tq = d.find_last with (item == 4);      $display("find_last ==4    = %p", tq);

    // Ex 2-23: condition inside with -> counting
    total = d.sum with (int'(item > 7));    // 8 and 10 -> 2
    $display("7'den buyuk eleman sayisi = %0d", total);
    total = d.sum with ((item > 7) ? item : 0);
    $display("7'den buyuklerin toplami  = %0d", total);

    // Sorting methods (unpacked/dynamic/queue only, in place)
    f.reverse();  $display("reverse = %p", f);
    f.sort();     $display("sort    = %p", f);
    f.rsort();    $display("rsort   = %p", f);
    f.shuffle();  $display("shuffle = %p", f);
    $finish;
  end
endmodule
