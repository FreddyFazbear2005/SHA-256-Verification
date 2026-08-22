module sha256_top (
    input logic i_clk,
    input logic i_reset,
    input logic i_start,

    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_message_word,
    input logic [5:0] i_word_index,
    input logic i_message_valid,

    input logic [2:0] i_digest_index,

    output logic [31:0] o_digest_word,
    output logic o_done
);

  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_message_schedule[0:sha256_pkg::LP_NUMBER_OF_ROUNDS-1];
  logic [255:0] r_digest;

  always_ff @(posedge i_clk) begin
    if (i_reset) begin
      for (int unsigned i = 0; i < sha256_pkg::LP_NUMBER_OF_ROUNDS; i++) begin
        r_message_schedule[i] <= '0;
      end
    end else if (i_message_valid) begin
      r_message_schedule[i_word_index] <= i_message_word;
    end
  end

  compression_core compression_core (
      .i_message_schedule(r_message_schedule),
      .i_clk             (i_clk),
      .i_reset           (i_reset),
      .i_start           (i_start),
      .o_digest          (r_digest),
      .o_done            (o_done)
  );

  always_comb begin
    case (i_digest_index)
      3'd0: o_digest_word = r_digest[255:224];
      3'd1: o_digest_word = r_digest[223:192];
      3'd2: o_digest_word = r_digest[191:160];
      3'd3: o_digest_word = r_digest[159:128];
      3'd4: o_digest_word = r_digest[127:96];
      3'd5: o_digest_word = r_digest[95:64];
      3'd6: o_digest_word = r_digest[63:32];
      3'd7: o_digest_word = r_digest[31:0];
      default: o_digest_word = '0;
    endcase
  end

endmodule
