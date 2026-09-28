// 07_random_device_config.sv
// Book: Ch.6  6.16 Random Device Configuration
//       (Ex 6-58 Ethernet switch configuration class,
//        6-59 building the environment from a random config,
//        6-60/6-61 tests that use / override the random config)
//
// NOTE: randomize()/randcase/randsequence require an svverification license in
// Intel Questa FSE; use full Questa / VCS / Xcelium or EDA Playground.
module tb_random_device_config;

  // Ex 6-58
  class eth_cfg;
    rand bit [3:0] in_use;        // which ports will be used
    rand bit [47:0] mac_addr[4];  // each port's MAC address
    rand bit [3:0] is_100;        // 100 Mb mode
    rand int  run_for_n_frames;   // test length

    constraint c_local_mac {      // not multicast, a local address
      foreach (mac_addr[i]) mac_addr[i][41:40] == 2'b00;
    }
    constraint reasonable {
      run_for_n_frames inside {[1:100]};
    }
    constraint at_least_one { in_use != 0; }
  endclass

  // Ex 6-59: creates a config and builds components based on it
  class Environment;
    eth_cfg cfg;

    function new();
      cfg = new();
    endfunction

    function void gen_cfg();
      assert (cfg.randomize());
    endfunction

    function void build();
      foreach (cfg.mac_addr[i])
        if (cfg.in_use[i])
          $display("  port%0d: MAC=%h  %s", i, cfg.mac_addr[i],
                   cfg.is_100[i] ? "100Mb" : "10Mb");
      $display("  %0d frame gonderilecek", cfg.run_for_n_frames);
    endfunction

    task run();
      #(cfg.run_for_n_frames * 10);
    endtask
  endclass

  Environment env;

  initial begin
    // Ex 6-60: fully random config
    $display("--- test 1: rastgele konfigurasyon ---");
    env = new();
    env.gen_cfg();
    env.build();
    env.run();

    // Ex 6-61: the test fixes part of the config
    $display("--- test 2: sadece port0, 100Mb, 5 frame ---");
    env = new();
    env.cfg.in_use.rand_mode(0);
    env.cfg.in_use = 4'b0001;
    assert (env.cfg.randomize() with { is_100[0] == 1; run_for_n_frames == 5; });
    env.build();
    env.run();
    $finish;
  end
endmodule
