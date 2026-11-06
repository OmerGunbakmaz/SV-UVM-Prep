interface tinyalu_bfm;
   import tinyalu_pkg::*;

   byte unsigned A;
   byte unsigned B;
   bit           clk;
   bit           reset_n;
   wire [2:0]    op;
   bit           start;
   wire          done;
   wire [15:0]   result;
   operation_t   op_set;

   command_monitor command_monitor_h;
   result_monitor  result_monitor_h;

   assign op = op_set;

   initial begin
      clk = 0;
      forever #10 clk = ~clk;
   end

   task reset_alu();
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start   = 1'b0;
   endtask : reset_alu

   task send_op(input byte iA, input byte iB, input operation_t iop, output shortint alu_result);
      if (iop == rst_op) begin
         @(negedge clk);
         op_set = iop;
         @(posedge clk);
         reset_n = 1'b0;
         start   = 1'b0;
         @(posedge clk);
         #1;
         reset_n = 1'b1;
      end else begin
         @(negedge clk);
         op_set = iop;
         A      = iA;
         B      = iB;
         start  = 1'b1;
         if (iop == no_op) begin
            @(posedge clk);
            #1;
            start = 1'b0;
         end else begin
            do
               @(negedge clk);
            while (done == 0);
            start = 1'b0;
         end
         alu_result = result;
      end
   endtask : send_op

   always @(posedge clk) begin : cmd_monitor
      static bit in_command = 0;
      if (start) begin
         if (!in_command) begin
            command_monitor_h.write_to_monitor(A, B, op_set);
            in_command = (op_set != no_op);
         end
      end else begin
         in_command = 0;
      end
   end : cmd_monitor

   always @(negedge reset_n) begin : rst_monitor
      if (command_monitor_h != null)
         command_monitor_h.write_to_monitor(A, B, rst_op);
   end : rst_monitor

   always @(posedge clk) begin : res_monitor
      if (done)
         result_monitor_h.write_to_monitor(result);
   end : res_monitor

endinterface : tinyalu_bfm
