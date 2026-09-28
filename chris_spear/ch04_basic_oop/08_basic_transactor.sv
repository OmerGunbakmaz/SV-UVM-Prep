// 08_basic_transactor.sv
// Book: Ch.4  4.18 Building a Testbench  (Ex 4-32 Basic Transactor)
//
// Transactor = a component that takes input, processes it and produces output
// (Driver, Monitor, Scoreboard ...). Here the Generator -> Transactor(Agent)
// -> Driver chain is built with simple queues instead of mailboxes (mailbox: Ch.7).
module tb_basic_transactor;

  class Transaction;
    static int count = 0;
    int        id;
    bit [7:0]  addr, data;
    function new();
      id   = count++;
      addr = $urandom;
      data = $urandom;
    endfunction
    function string convert2string();
      return $sformatf("tr#%0d addr=%h data=%h", id, addr, data);
    endfunction
  endclass

  // Ex 4-32: basic transactor skeleton
  class Transactor;
    Transaction in_q[$], out_q[$];
    string      name;

    function new(string name);
      this.name = name;
    endfunction

    task run();
      Transaction tr;
      while (in_q.size() > 0) begin
        tr = in_q.pop_front();
        #5;                                   // "processing" time
        $display("@%0t %s: %s", $time, name, tr.convert2string());
        out_q.push_back(tr);
      end
    endtask
  endclass

  Transactor agent, driver;

  initial begin
    agent  = new("Agent ");
    driver = new("Driver");

    repeat (3) begin
      automatic Transaction tr = new();
      agent.in_q.push_back(tr);
    end

    agent.run();
    driver.in_q = agent.out_q;               // connect the layers together
    driver.run();
    $finish;
  end
endmodule
