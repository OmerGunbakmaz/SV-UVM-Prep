
class transaction;
    rand op_e op;
    rand logic [WIDTH-1:0] data;
    rand logic [$clog2(DEPTH)-1:0] addr;
    rand int delay;

    static int count;
    int id;

  function new(bit new_flag = 1 );
    if(new_flag)
  		this.id = count++;  
    endfunction
    constraint addr_c {
        addr inside {[0 : DEPTH-1]};
        addr[1:0] == 2'b00;
    }
    constraint delay_c {
        delay inside {[0:5]};
    }


    function transaction copy();
      copy = new(0);
        copy.op = op;
        copy.data = data;
        copy.addr = addr;
      	copy.id = this.id;
        copy.delay = delay;
    endfunction

    function bit compare(transaction rhs);
        return (op === rhs.op) && (data === rhs.data) && (addr === rhs.addr);
    endfunction

    function string convert2string();
        return $sformatf("[%0d] %-8s addr:0x%08h data:0x%08h delay:%0d",
            id, op.name(), addr, data, delay);
    endfunction
endclass
