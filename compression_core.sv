module compression_core (
    input logic [31:0] i_message_schedule[64],
    input logic i_clk,
    input logic i_reset,
    input logic i_suspend,

    output logic [255:0] o_hashed_output,
    output logic o_done
);

  logic [$clog2(sha256_pkg::LP_NUMBER_OF_ROUNDS)-1:0] r_current_round;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_hash_state[0:7];

  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_a;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_b;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_c;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_d;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_e;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_f;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_g;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_h;

  logic r_done;

  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_a;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_b;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_c;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_d;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_e;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_f;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_g;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_h;

  always_ff @(posedge i_clk) begin
    if (i_reset) begin
      r_current_round <= 0;
      r_hash_state <= sha256_pkg::LP_INITIAL_HASH;
      r_a <= sha256_pkg::LP_INITIAL_HASH[0];
      r_b <= sha256_pkg::LP_INITIAL_HASH[1];
      r_c <= sha256_pkg::LP_INITIAL_HASH[2];
      r_d <= sha256_pkg::LP_INITIAL_HASH[3];
      r_e <= sha256_pkg::LP_INITIAL_HASH[4];
      r_f <= sha256_pkg::LP_INITIAL_HASH[5];
      r_g <= sha256_pkg::LP_INITIAL_HASH[6];
      r_h <= sha256_pkg::LP_INITIAL_HASH[7];
      r_done <= 0;
    end else if (i_suspend == 1) begin
      r_current_round <= r_current_round;
      r_hash_state <= r_hash_state;
      r_a <= r_a;
      r_b <= r_b;
      r_c <= r_c;
      r_d <= r_d;
      r_e <= r_e;
      r_f <= r_f;
      r_g <= r_g;
      r_h <= r_h;
      r_done <= r_done;
    end else begin
      if (r_current_round == 63) begin
        r_a <= w_a + r_hash_state[0];
        r_b <= w_b + r_hash_state[1];
        r_c <= w_c + r_hash_state[2];
        r_d <= w_d + r_hash_state[3];
        r_e <= w_e + r_hash_state[4];
        r_f <= w_f + r_hash_state[5];
        r_g <= w_g + r_hash_state[6];
        r_h <= w_h + r_hash_state[7];
        r_current_round <= 0;
        r_done <= 1;
        r_hash_state[0] <= w_a + r_hash_state[0];
        r_hash_state[1] <= w_b + r_hash_state[1];
        r_hash_state[2] <= w_c + r_hash_state[2];
        r_hash_state[3] <= w_d + r_hash_state[3];
        r_hash_state[4] <= w_e + r_hash_state[4];
        r_hash_state[5] <= w_f + r_hash_state[5];
        r_hash_state[6] <= w_g + r_hash_state[6];
        r_hash_state[7] <= w_h + r_hash_state[7];
      end else begin
        r_a <= w_a;
        r_b <= w_b;
        r_c <= w_c;
        r_d <= w_d;
        r_e <= w_e;
        r_f <= w_f;
        r_g <= w_g;
        r_h <= w_h;
        r_done <= 0;
        r_current_round <= r_current_round + 1;
        r_hash_state <= r_hash_state;
      end
    end
  end

  assign o_hashed_output = {
    r_hash_state[0],
    r_hash_state[1],
    r_hash_state[2],
    r_hash_state[3],
    r_hash_state[4],
    r_hash_state[5],
    r_hash_state[6],
    r_hash_state[7]
  };
  assign o_done = r_done;

  compression_round compression_round (
      .i_a             (r_a),
      .i_b             (r_b),
      .i_c             (r_c),
      .i_d             (r_d),
      .i_e             (r_e),
      .i_f             (r_f),
      .i_g             (r_g),
      .i_h             (r_h),
      .i_message_word  (i_message_schedule[r_current_round]),
      .i_round_constant(sha256_pkg::LP_ROUND_CONSTANT[r_current_round]),
      .o_a             (w_a),
      .o_b             (w_b),
      .o_c             (w_c),
      .o_d             (w_d),
      .o_e             (w_e),
      .o_f             (w_f),
      .o_g             (w_g),
      .o_h             (w_h)
  );

endmodule
