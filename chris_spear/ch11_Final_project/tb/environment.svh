class environment;
    driver drv;
    monitor mon;
    generator gen;
    scoreboard sb;

    mailbox #(transaction) gen2drv;
    mailbox #(transaction) mon2sb;
    virtual bus_if vif;

    function new(virtual bus_if vif);
        this.vif = vif;
        gen2drv= new();
        mon2sb= new();
        gen = new(gen2drv);
        drv = new(vif,gen2drv);
        mon = new(vif,mon2sb);
        sb = new(mon2sb);
        //cov;
    endfunction

    virtual task run();
        fork
            drv.run();
            mon.run();
            sb.run();
        join_none
        gen.run();
        wait (sb.txn_count == gen.num_txn);
    endtask

    virtual function void report();
        $display("[ENV] generated : %0d drived : %0d monitored : %0d",gen.num_txn,drv.drv_count,mon.mon_count);
        sb.report();
        //cov.report();
    endfunction
endclass
