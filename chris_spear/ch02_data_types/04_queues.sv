// 04_queues.sv
// Book: Ch.2  2.5 Queues  (Ex 2-17 Queue operations)
module tb_queues;

  int arr[$];
  int q[$] = {3, 4};
  int j = 1;

  initial begin
    // push_front / push_back / insert
    arr = {1, 2, 3};
    $display("arr               : %0p", arr);
    arr.push_front(0);
    $display("push_front(0)     : %0p", arr);
    arr.push_back(4);
    $display("push_back(4)      : %0p", arr);
    arr.insert(2, 10);                        // insert 10 at index 2
    $display("insert(2,10)      : %0p\n", arr);

    // Ex 2-17: queue operations
    q = {0, 2, 5};
    q.insert(1, j);           // {0,1,2,5}
    q.delete(1);              // {0,2,5}
    q.push_front(6);          // {6,0,2,5}
    j = q.pop_back();         // {6,0,2}   j=5
    q.push_back(8);           // {6,0,2,8}
    j = q.pop_front();        // {0,2,8}   j=6
    $display("q=%p j=%0d", q, j);

    // $ = last index: slicing
    $display("q[0:$-1] = %p", q[0:$-1]);      // drop the last one
    $display("q[1:$]   = %p", q[1:$]);        // drop the first one

    // Insert via concatenation (instead of a method)
    q = {q[0], 1, q[1:$]};
    $display("birlestirme ile insert: %p", q);

    q.delete();               // clear completely  (or q = {};)
    $display("bos kuyruk size=%0d", q.size());
    $finish;
  end
endmodule
