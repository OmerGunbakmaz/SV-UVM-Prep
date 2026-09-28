// 09_strings.sv
// Book: Ch.2  2.14 Strings  (Ex 2-39 String methods)
module tb_strings;

  string s;

  // Helper that produces a formatted message via $sformatf
  function automatic void my_log(string message);
    $display("@%0t: %s", $time, message);
  endfunction

  initial begin
    s = "IEEE ";
    $display("getc(0) = %0d ('%s')", s.getc(0), string'(s.getc(0)));
    $display("tolower = %s", s.tolower());

    s.putc(s.len() - 1, "-");     // space -> '-'
    s = {s, "P1800"};             // concatenation
    $display("s = %s  len=%0d", s, s.len());

    $display("substr(2,5) = %s", s.substr(2, 5));   // "EE-P"

    // compare: 0 if equal
    $display("compare = %0d", s.compare("IEEE-P1800"));

    // conversion to / from a number
    s = "1800";
    $display("atoi = %0d", s.atoi());
    s.itoa(2017);
    $display("itoa = %s", s);

    my_log($sformatf("%s %0d", "IEEE", 1800));
    $finish;
  end
endmodule
