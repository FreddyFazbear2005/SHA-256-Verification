`include "compression_if.sv"
`include "compression_tb_pkg.sv"

module compression_tb;
  logic i_clk;
  compression_if vif (.i_clk(i_clk));

  compression_core dut (
      .i_message_schedule(vif.i_message_schedule),
      .i_clk             (vif.i_clk),
      .i_reset           (vif.i_reset),
      .i_start           (vif.i_start),
      .o_digest          (vif.o_digest),
      .o_done            (vif.o_done)
  );

  compression_tb_pkg::compression_environment env;

  initial begin
    i_clk = 1'b0;
    forever begin
      #5 i_clk = ~i_clk;
    end
  end

  initial begin
    env = new(vif);
    env.run();
  end
endmodule
