class tester extends uvm_component;
   `uvm_component_utils(tester)

   uvm_put_port #(command_s) command_port;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction : new

   function void build_phase(uvm_phase phase);
      command_port = new("command_port", this);
   endfunction : build_phase

   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
         3'b000, 3'b101 : return no_op;
         3'b001         : return add_op;
         3'b010         : return and_op;
         3'b011         : return xor_op;
         3'b100         : return mul_op;
         default        : return rst_op;
      endcase
   endfunction : get_op

   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)      return 8'h00;
      else if (zero_ones == 2'b11) return 8'hFF;
      else                         return $random;
   endfunction : get_data

   task run_phase(uvm_phase phase);
      command_s command;

      phase.raise_objection(this);
      command.op = rst_op;
      command_port.put(command);
      repeat (300) begin
         command.op = get_op();
         command.A  = get_data();
         command.B  = get_data();
         command_port.put(command);
      end
      #500;
      phase.drop_objection(this);
   endtask : run_phase

endclass : tester
