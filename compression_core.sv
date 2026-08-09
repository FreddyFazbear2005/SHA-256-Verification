module compression_core (
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_message_schedule[0:63],
    input logic i_clk,
    input logic i_reset,
    input logic i_start,

    output logic [255:0] o_digest,
    output logic o_done
);

  typedef enum logic [1:0] {
    IDLE,
    RUN,
    DIGEST,
    DONE
  } compression_state_e;
  compression_state_e r_current_state;
  compression_state_e r_next_state;

  logic [$clog2(sha256_pkg::LP_NUMBER_OF_ROUNDS)-1:0] r_current_round;


  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_a;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_b;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_c;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_d;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_e;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_f;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_g;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] r_h;


  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_a;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_b;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_c;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_d;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_e;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_f;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_g;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_h;


  logic [255:0] r_digest;

  always_ff @(posedge i_clk) begin
    if (i_reset) begin
      r_current_state <= IDLE;
    end else begin
      r_current_state <= r_next_state;
    end
  end

  always_comb begin
    case (r_current_state)
      IDLE: r_next_state = (i_start) ? RUN : IDLE;
      RUN: r_next_state = (r_current_round == sha256_pkg::LP_NUMBER_OF_ROUNDS - 1) ? DIGEST : RUN;
      DIGEST: r_next_state = DONE;
      DONE: r_next_state = IDLE;
      default: r_next_state = IDLE;
    endcase
  end


  always_ff @(posedge i_clk) begin
    if (i_reset) begin
      r_current_round <= '0;
      r_a <= '0;
      r_b <= '0;
      r_c <= '0;
      r_d <= '0;
      r_e <= '0;
      r_f <= '0;
      r_g <= '0;
      r_h <= '0;
      r_digest <= '0;
    end else begin
      unique case (r_current_state)
        IDLE: begin
          if (i_start) begin
            r_digest <= '0;
            r_current_round <= '0;
            r_a <= sha256_pkg::LP_INITIAL_HASH[0];
            r_b <= sha256_pkg::LP_INITIAL_HASH[1];
            r_c <= sha256_pkg::LP_INITIAL_HASH[2];
            r_d <= sha256_pkg::LP_INITIAL_HASH[3];
            r_e <= sha256_pkg::LP_INITIAL_HASH[4];
            r_f <= sha256_pkg::LP_INITIAL_HASH[5];
            r_g <= sha256_pkg::LP_INITIAL_HASH[6];
            r_h <= sha256_pkg::LP_INITIAL_HASH[7];
          end
        end
        RUN: begin
          r_current_round <= r_current_round + 1;
          r_a <= w_a;
          r_b <= w_b;
          r_c <= w_c;
          r_d <= w_d;
          r_e <= w_e;
          r_f <= w_f;
          r_g <= w_g;
          r_h <= w_h;
        end
        DIGEST: begin
          r_current_round <= '0;
          r_digest <= {
            sha256_pkg::LP_INITIAL_HASH[0] + r_a,
            sha256_pkg::LP_INITIAL_HASH[1] + r_b,
            sha256_pkg::LP_INITIAL_HASH[2] + r_c,
            sha256_pkg::LP_INITIAL_HASH[3] + r_d,
            sha256_pkg::LP_INITIAL_HASH[4] + r_e,
            sha256_pkg::LP_INITIAL_HASH[5] + r_f,
            sha256_pkg::LP_INITIAL_HASH[6] + r_g,
            sha256_pkg::LP_INITIAL_HASH[7] + r_h
          };
        end
        DONE: begin
          r_current_round <= '0;
        end
      endcase
    end
  end

  assign o_digest = r_digest;

  assign o_done   = (r_current_state == DONE);

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
