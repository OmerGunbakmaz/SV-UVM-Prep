class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  mem_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = mem_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass : base_test


class write_read_test extends base_test;
  `uvm_component_utils(write_read_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    write_read_seq seq;
    phase.raise_objection(this);
    seq = write_read_seq::type_id::create("seq");
    seq.start(env.agent.sqr);
    #100;
    phase.drop_objection(this);
  endtask

endclass : write_read_test


class random_test extends base_test;
  `uvm_component_utils(random_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    write_read_seq wr_seq;
    random_seq     rnd_seq;
    phase.raise_objection(this);
    wr_seq   = write_read_seq::type_id::create("wr_seq");
    rnd_seq  = random_seq::type_id::create("rnd_seq");
    wr_seq.n = 5;
    wr_seq.start(env.agent.sqr);
    rnd_seq.start(env.agent.sqr);
    #100;
    phase.drop_objection(this);
  endtask

endclass : random_test
