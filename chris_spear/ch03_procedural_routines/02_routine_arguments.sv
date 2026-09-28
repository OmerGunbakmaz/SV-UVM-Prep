// 02_routine_arguments.sv
// Book: Ch.3  3.5 Routine Arguments, 3.6 Returning from a Routine
//       (Ex 3-7..3-9 argument directions, 3-10 ref/const ref, 3-11 ref thread,
//        3-12/3-13 default arguments, 3-17/3-18 return)
module tb_routine_arguments;

  //   ref  -> the array is not copied, written directly into the caller's
  //   const ref -> not copied but cannot be modified (the book's recommendation)
  function automatic void init_array(ref bit [3:0] array[16]);
    foreach (array[i])
      array[i] = $urandom % 16;
  endfunction

  function automatic void print_array(const ref bit [3:0] array[16]);
    $display("Array: %p", array);
  endfunction

  // Ex 3-9: sticky types -> a,b input logic; u,v output bit[15:0]
  task automatic t3(a, b, output bit [15:0] u, v);
    u = 16'(a + b);
    v = 16'(a - b);
  endtask

  // Ex 3-10: passing a large array with const ref
  function automatic void print_sum(const ref int a[]);
    int sum = 0;
    foreach (a[i]) sum += a[i];
    $display("sum = %0d", sum);
  endfunction

  // Ex 3-12/3-13: default argument values
  function automatic void print_checksum(const ref bit [31:0] a[],
                                         input bit [31:0] lo = 0,
                                         input int        hi = -1);
    bit [31:0] checksum = 0;
    if (hi == -1 || hi >= a.size()) hi = a.size() - 1;
    for (int i = lo; i <= hi; i++) checksum += a[i];
    $display("checksum[%0d:%0d] = %0d", lo, hi, checksum);
  endfunction

  // Ex 3-11: sharing across threads with ref -> the change is visible IMMEDIATELY
  task automatic bus_read(input logic [31:0] addr, ref logic [31:0] data);
    #10 data = addr + 32'h100;
    $display("@%0t bus_read: data yazildi", $time);
    #10;                               // the task is still running
    $display("@%0t bus_read: task bitti", $time);
  endtask

  // Ex 3-17/3-18: early exit with return
  function automatic bit transmit(int len);
    if (len <= 0) begin
      $display("transmit: gecersiz uzunluk %0d", len);
      return 0;
    end
    return 1;
  endfunction

  bit [3:0]    arr[16];
  bit [15:0]   u, v;
  int          d[] = '{1, 2, 3, 4};
  bit [31:0]   cs[] = '{10, 20, 30, 40};
  logic [31:0] rdata;

  initial begin
    init_array(arr);
    #1;
    print_array(arr);

    t3(1'b1, 1'b1, u, v);
    $display("t3: u=%0d v=%0d", u, v);

    print_sum(d);

    print_checksum(cs);               // whole array
    print_checksum(cs, 1);            // 1..end
    print_checksum(cs, , 2);          // 0..2   (lo defaulted)
    print_checksum(cs, .hi(1));       // named argument

    fork
      bus_read(32'h1, rdata);
      begin
        wait (rdata !== 'x);
        $display("@%0t diger thread rdata=%h goruyor", $time, rdata);
      end
    join

    void'(transmit(0));
    $display("transmit(5) = %0b", transmit(5));
    $finish;
  end
endmodule
