`include "compression_if.sv"
package compression_tb_pkg;
  class compression_transaction;
    bit [ 31:0] message_schedule[0:63];
    bit [255:0] expected_digest;

    function automatic void display();
      $display("Expected Digest = %0h", expected_digest);
    endfunction
  endclass

  class compression_result;
    bit [255:0] actual_digest;

    function automatic void display();
      $display("Actual Digest = %0h", actual_digest);
    endfunction
  endclass

  class compression_generator;
    mailbox #(compression_transaction) gen_to_drv;
    mailbox #(compression_transaction) expected_mb;

    function automatic new(mailbox#(compression_transaction) gen_to_drv,
      mailbox#(compression_transaction) expected_mb);
      this.gen_to_drv = gen_to_drv;
      this.expected_mb = expected_mb;
    endfunction

    task automatic run();
      compression_transaction transaction;
      transaction = new();
    endtask
  endclass

  class compression_driver;
    virtual compression_if vif;
    mailbox #(compression_transaction) gen_to_drv;
    function automatic new(
      virtual compression_if vif,
      mailbox #(compression_transaction) gen_to_drv
      );
      this.vif = vif;
      this.gen_to_drv = gen_to_drv;
    endfunction

    task automatic run();
      compression_transaction transaction;
      forever begin
        gen_to_drv.get(transaction);
        drive_transaction(.transaction(transaction));
      end
    endtask

    task automatic drive_transaction(
      compression_transaction transaction
      );
    endtask
  endclass
  class compression_monitor;
    virtual compression_if vif;
    mailbox #(compression_result) actual_mb;

    function automatic new(
      virtual compression_if vif,
      mailbox #(compression_result) actual_mb
      );
      this.vif = vif;
      this.actual_mb = actual_mb;
    endfunction

    task automatic run();
      compression_result result;
      forever begin
        //Later
      end
    endtask
  endclass

  class compression_scoreboard;
    mailbox #(compression_transaction) expected_mb;
    mailbox #(compression_result) actual_mb;
    function automatic new(
      mailbox #(compression_transaction) expected_mb,
      mailbox #(compression_result) actual_mb
      );

      this.expected_mb = expected_mb;
      this.actual_mb = actual_mb;
    endfunction
    task automatic run();
      compression_transaction expected;
      compression_result actual;
      forever begin
        expected_mb.get(expected);
        actual_mb.get(actual);
        //To do later
      end
    endtask
  endclass

  class compression_environment;
    virtual compression_if vif;
    mailbox #(compression_transaction) gen_to_drv;
    mailbox #(compression_transaction) expected_mb;
    mailbox #(compression_result) actual_mb;

    compression_generator generator;
    compression_driver driver;
    compression_monitor monitor;
    compression_scoreboard scoreboard;

    function automatic new(
      virtual compression_if vif
      );
      this.vif = vif;

      gen_to_drv = new();
      expected_mb = new();
      actual_mb = new();

      generator = new(.gen_to_drv(gen_to_drv),.expected_mb(expected_mb));
      driver = new(.vif(vif),.gen_to_drv(gen_to_drv));
      monitor = new(.vif(vif),.actual_mb(actual_mb));
      scoreboard = new(.expected_mb(expected_mb),.actual_mb(actual_mb));
    endfunction

    task automatic run();
      fork
        generator.run();
        driver.run();
        monitor.run();
        scoreboard.run();
      join_none
    endtask
  endclass
endpackage
