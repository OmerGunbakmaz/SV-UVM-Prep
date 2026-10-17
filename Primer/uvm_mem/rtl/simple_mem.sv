module simple_mem #(parameter DEPTH = 256) (bus_if.DUT bif);

  logic [31:0] mem [0:DEPTH-1];

  assign bif.ready = 1'b1;    // her zaman hazir (basit versiyon)

  always_ff @(posedge bif.clk or negedge bif.rst_n) begin
    if (!bif.rst_n) begin
      bif.rdata <= 32'h0;
    end else if (bif.valid) begin
      if (bif.we) mem[bif.addr[9:2]] <= bif.wdata;
      else        bif.rdata          <= mem[bif.addr[9:2]];
    end
  end

endmodule