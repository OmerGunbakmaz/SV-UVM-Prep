module simple_mem#(parameter WIDTH=8,parameter DEPTH = 256) (bus_if.DUT bif);
    logic [WIDTH-1 : 0] mem [0:DEPTH-1];

    assign bif.ready = 1'b1;

    always_ff@(posedge bif.clk)begin
        if (!bif.rstn) begin
            bif.rdata <= '0;
        end
        else if(bif.valid)begin
            if(bif.we)begin
                mem[bif.addr] <= bif.wdata;
            end
            else bif.rdata <= mem[bif.addr];
        end
    end
endmodule