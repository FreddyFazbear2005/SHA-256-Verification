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

      int schedule_file;
      int digest_file;
      int status;
      int unsigned vector_count = 0;

      schedule_file = $fopen("message_schedule.txt","r");
      digest_file = $fopen("expected_digest.txt","r");

      if(schedule_file == 0) begin
        $fatal(1,"Could not open message_schedule.txt");
      end
      if(digest_file == 0) begin
        $fatal(1,"Could not open expected_digest.txt");
      end

      forever begin
        transaction = new();

        for(int i = 0; i < 64; i++) begin
          status = $fscanf(schedule_file,"%h",transaction.message_schedule[i]);
          if(status != 1) begin
            $fclose(schedule_file);
            $fclose(digest_file);
            $display("Generated %0d test vectors.",vector_count);
            return;
          end
        end

        status = $fscanf(digest_file,"%h",transaction.expected_digest);

        if(status != 1) begin
          $fclose(schedule_file);
          $fclose(digest_file);
          $fatal(1,"Failed to read expected digest");
        end

        vector_count++;
        gen_to_drv.put(transaction);
        expected_mb.put(transaction);
      end
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
      reset_dut();
      forever begin
        gen_to_drv.get(transaction);
        drive_transaction(.transaction(transaction));
      end
    endtask

    task automatic drive_transaction(
      compression_transaction transaction
      );
      vif.i_reset = 1'b0;
      vif.i_start = 1'b0;

      for(int i = 0; i < 64; i = i + 1) begin
        vif.i_message_schedule[i] = transaction.message_schedule[i];
      end

      @(negedge vif.i_clk);
      vif.i_start = 1'b1;

      @(negedge vif.i_clk);
      vif.i_start = 1'b0;
      

      @(posedge vif.o_done);
      @(posedge vif.i_clk);

    endtask

    task automatic reset_dut();
      vif.i_reset = 1'b1;
      vif.i_start = 1'b0;

      @(negedge vif.i_clk);
      @(negedge vif.i_clk);

      vif.i_reset = 1'b0;
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
        @(posedge vif.o_done)
        result = new();
        result.actual_digest = vif.o_digest;
        actual_mb.put(result);
      end
    endtask
  endclass

  class compression_scoreboard;
    mailbox #(compression_transaction) expected_mb;
    mailbox #(compression_result) actual_mb;

    int unsigned pass_count = 0;
    int unsigned fail_count = 0;
    int unsigned expected_vectors;

    function automatic new(
      mailbox #(compression_transaction) expected_mb,
      mailbox #(compression_result) actual_mb,
      int unsigned expected_vectors
      );

      this.expected_mb = expected_mb;
      this.actual_mb = actual_mb;
      this.expected_vectors = expected_vectors;
    endfunction
    task automatic run();
      compression_transaction expected;
      compression_result actual;
      $display("SCOREBOARD: STARTED");
      for(int unsigned i = 0; i < expected_vectors; i++) begin
        expected_mb.get(expected);
        actual_mb.get(actual);

        if(expected.expected_digest === actual.actual_digest) begin
          pass_count++;
        end else begin
          fail_count++;
          $display("FAIL");
          expected.display();
          actual.display();
        end
      end
    $display("");
    $display("========================================");
    $display("       SHA-256 VERIFICATION SUMMARY");
    $display("========================================");
    $display("Vectors Tested : %0d", expected_vectors);
    $display("Passed         : %0d", pass_count);
    $display("Failed         : %0d", fail_count);
    $display("========================================");

    if(fail_count == 0) begin
      $display("SHA-256 VERIFICATION PASSED");
      $finish;
    end
    else begin
      $fatal(1, "SHA-256 VERIFICATION FAILED");
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
      scoreboard = new(.expected_mb(expected_mb),.actual_mb(actual_mb),.expected_vectors(1000));
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
