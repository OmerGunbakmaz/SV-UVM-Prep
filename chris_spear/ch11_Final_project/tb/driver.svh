class driver;
    virtual bus_if.DRV vif;
    mailbox #(transaction) gen2drv; 
    int drv_count = 0;

    function new(virtual bus_if.DRV vif,mailbox #(transaction) gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    virtual task run();
        transaction t;
        if (vif == null) $fatal(1, "[DRV] virtual interface is null!");
        forever begin
            gen2drv.get(t); 
            repeat (t.delay) begin
                @(vif.drv_cb);
            end
            drive(t);
            drv_count++;
        end
    endtask

    virtual task drive(transaction t);
        @(vif.drv_cb);
        vif.drv_cb.addr  <= t.addr;
        vif.drv_cb.wdata <= t.data;
        vif.drv_cb.we    <= (t.op == OP_WRITE);
        vif.drv_cb.valid <= 1'b1;
        @(vif.drv_cb);
        vif.drv_cb.valid <= 1'b0;
        vif.drv_cb.we    <= 1'b0;
    endtask
endclass
