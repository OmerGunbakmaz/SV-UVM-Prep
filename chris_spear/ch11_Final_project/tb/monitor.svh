
class monitor;
    virtual bus_if.MON vif;
    mailbox #(transaction) mon2sb;
    int mon_count = 0;

    function new(virtual bus_if.MON vif, mailbox #(transaction) mon2sb);
        this.vif = vif;
        this.mon2sb = mon2sb;
    endfunction

    virtual task run();
        transaction t;
        if (vif == null) $fatal(1, "[MON] virtual interface is null!");
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.valid && vif.mon_cb.ready) begin
                t = new(0);
                t.id = mon_count;
                t.addr = vif.mon_cb.addr;
                t.op = vif.mon_cb.we ? OP_WRITE : OP_READ;
                t.data = vif.mon_cb.wdata;
                if (t.op == OP_READ) begin
                    @(vif.mon_cb);
                    t.data = vif.mon_cb.rdata;
                end
                $display("[MON] %s", t.convert2string());
                mon2sb.put(t.copy);
                mon_count++;
            end
        end
    endtask
endclass
