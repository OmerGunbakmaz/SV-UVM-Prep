class scoreboard extends uvm_subscriber #(shortint);
   `uvm_component_utils(scoreboard)

   uvm_tlm_analysis_fifo #(command_s) cmd_f;
   int pass_cnt;
   int fail_cnt;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      cmd_f = new("cmd_f", this);
   endfunction : build_phase

   function shortint predict(command_s cmd);
      case (cmd.op)
         add_op  : return cmd.A + cmd.B;
         and_op  : return cmd.A & cmd.B;
         xor_op  : return cmd.A ^ cmd.B;
         mul_op  : return cmd.A * cmd.B;
         default : return 0;
      endcase
   endfunction : predict

   function void write(shortint t);
      command_s cmd;
      shortint  predicted;

      do
         if (!cmd_f.try_get(cmd))
            `uvm_fatal("SCOREBOARD", "sonuc geldi ama komut yok")
      while (cmd.op == no_op || cmd.op == rst_op);

      predicted = predict(cmd);
      if (predicted != t) begin
         fail_cnt++;
         `uvm_error("SCOREBOARD", $sformatf("FAIL A:%2h B:%2h op:%s result:%4h beklenen:%4h",
                    cmd.A, cmd.B, cmd.op.name(), t, predicted))
      end else begin
         pass_cnt++;
      end
   endfunction : write

   function void report_phase(uvm_phase phase);
      `uvm_info("SCOREBOARD", $sformatf("pass: %0d  fail: %0d", pass_cnt, fail_cnt), UVM_LOW)
   endfunction : report_phase

endclass : scoreboard
