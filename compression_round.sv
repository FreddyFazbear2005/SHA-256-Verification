module compression_round (
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_a,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_b,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_c,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_d,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_e,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_f,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_g,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_h,

    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_message_word,
    input logic [sha256_pkg::LP_WORD_SIZE-1:0] i_round_constant,


    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_a,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_b,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_c,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_d,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_e,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_f,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_g,
    output logic [sha256_pkg::LP_WORD_SIZE-1:0] o_h
);

  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_t1;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] w_t2;

  always_comb begin
    w_t1 = i_h + sha256_pkg::big_sigma_one_function(
      .i_x(i_e)
    ) + sha256_pkg::choice_function(
      .i_x(i_e),
      .i_y(i_f),
      .i_z(i_g)
    ) + i_message_word + i_round_constant;

    w_t2 = sha256_pkg::big_sigma_zero_function(
      .i_x(i_a)
    ) + sha256_pkg::majority_function(
      .i_x(i_a),
      .i_y(i_b),
      .i_z(i_c)
    );

    o_h = i_g;
    o_g = i_f;
    o_f = i_e;
    o_e = i_d + w_t1;
    o_d = i_c;
    o_c = i_b;
    o_b = i_a;
    o_a = w_t1 + w_t2;
  end

endmodule
