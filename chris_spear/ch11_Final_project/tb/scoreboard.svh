class scoreboard;
    mailbox#(transaction) mon2sb;
    logic [WIDTH-1 : 0] ref_mem [bit [$clog2(DEPTH)-1:0]];
    int pass_count;
    int fail_count;
    int txn_count;
    int skip_count;
    int exp_txn=50;
    int read_count;

    function new(mailbox#(transaction) mbx);
        this.mon2sb = mbx;
    endfunction

    virtual task run();
        transaction t;
        forever begin
            mon2sb.get(t);
            check(t);
        end
    endtask
    
    virtual function bit ok();
        return (fail_count == 0)
        && (pass_count > 0)
        && (txn_count == exp_txn);
    endfunction

    virtual function void check(transaction t);
        logic [WIDTH-1:0]exp;
        txn_count++;
        if($isunknown(t.addr )|| $isunknown(t.op))begin
            fail_count++;
            $error("[SB] @%0t X in addr/op: %s ",$time(),t.convert2string());
            return;
        end
        if(t.op == OP_WRITE)begin
            if($isunknown(t.data))begin
                fail_count++;
                $error("[SB] @%0t X in wdata: %s ",$time(),t.convert2string());
                return;
            end
            ref_mem[t.addr] = t.data;
            return;
        end
        //read
        read_count++;
        if(!ref_mem.exists(t.addr))begin
            skip_count++;
            return;
        end
        exp=ref_mem[t.addr];
        if(exp === t.data) begin
            pass_count++;
        end
        else begin
            fail_count++;
            $error("[SB] @%0t mismatch exp:0x%0h got:0x%0h | %s",
                $time, exp, t.data, t.convert2string());
        end
    endfunction
    virtual function real skip_pct();
        return read_count ?(100.0 * skip_count/read_count):0.0;
    endfunction
    virtual function void report();
        $display("\n================ SCOREBOARD ================");
        $display("  TXN  : %0d / %0d beklenen", txn_count, exp_txn);
        $display("  PASS : %0d", pass_count);
        $display("  FAIL : %0d", fail_count);
        $display("  SKIP : %0d / %0d read (%%%0.1f)", skip_count, read_count, skip_pct());
        $display("  RESULT: %s", ok() ? "*** TEST PASSED ***" : "*** TEST FAILED ***");
        $display("============================================\n");
    endfunction
endclass
