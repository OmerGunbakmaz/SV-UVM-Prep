class generator;
    mailbox #(transaction) gen2drv;
    int num_txn = 50;
    event done;
    
    function new(mailbox #(transaction) gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    virtual task run();
        transaction t, r;
        assert (num_txn%2==0)
        else $fatal(1, "[GEN] num_txn has to be even number!");
        repeat (num_txn/2) begin
            t = new();
            assert (t.randomize() with {
                op == OP_WRITE;
            })
            else $fatal(1, "[GEN] write randomize failed!");
            $display("[GEN] %s", t.convert2string());
            gen2drv.put(t.copy);

            r = new();
            assert (r.randomize() with {
                op == OP_READ ;
                addr == t.addr;
            })
            else $fatal(1, "[GEN] read randomize failed!");
            $display("[GEN] %s", r.convert2string());
            gen2drv.put(r.copy);
        end
        ->done;
    endtask
endclass
