class base_test;
    environment env;
    virtual bus_if vif;

    function new(virtual bus_if vif);
        this.vif = vif;
        env= new(vif);
    endfunction

    virtual task run();
        configure();
        env.sb.exp_txn= env.gen.num_txn;
        vif.do_reset();
        env.run();
        env.report();
    endtask

    virtual function void configure();
        env.gen.num_txn = 50;
    endfunction
endclass