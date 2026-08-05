module message_scheduler (
    input  logic [511:0] i_message_block,
    output logic [ 31:0] o_message_schedule[64]
);

  always_comb begin
    for (int i = 0; i < 64; i = i + 1) begin
      if (i < 16) begin
        o_message_schedule[i] = i_message_block[(15-i)*32+:32];
      end else begin
        o_message_schedule[i] = sha256_pkg::small_sigma_one_function(.i_x(o_message_schedule[i-2]))
            + o_message_schedule[i-7] + sha256_pkg::small_sigma_zero_function
            (.i_x(o_message_schedule[i-15])) + o_message_schedule[i-16];
      end
    end
  end
endmodule
