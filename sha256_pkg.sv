package sha256_pkg;
  localparam int unsigned LP_WORD_SIZE = 32;
  localparam int unsigned LP_NUMBER_OF_ROUNDS = 64;

  // Initial hash values (H0-H7)
  localparam logic [LP_WORD_SIZE-1:0] LP_INITIAL_HASH[0:7] = '{
      32'h6A09E667,
      32'hBB67AE85,
      32'h3C6EF372,
      32'hA54FF53A,
      32'h510E527F,
      32'h9B05688C,
      32'h1F83D9AB,
      32'h5BE0CD19
  };
  // SHA-256 Round Constants (K0-K63)
  localparam logic [LP_WORD_SIZE-1:0] LP_ROUND_CONSTANT[0:63] = '{
      32'h428A2F98,
      32'h71374491,
      32'hB5C0FBCF,
      32'hE9B5DBA5,
      32'h3956C25B,
      32'h59F111F1,
      32'h923F82A4,
      32'hAB1C5ED5,
      32'hD807AA98,
      32'h12835B01,
      32'h243185BE,
      32'h550C7DC3,
      32'h72BE5D74,
      32'h80DEB1FE,
      32'h9BDC06A7,
      32'hC19BF174,
      32'hE49B69C1,
      32'hEFBE4786,
      32'h0FC19DC6,
      32'h240CA1CC,
      32'h2DE92C6F,
      32'h4A7484AA,
      32'h5CB0A9DC,
      32'h76F988DA,
      32'h983E5152,
      32'hA831C66D,
      32'hB00327C8,
      32'hBF597FC7,
      32'hC6E00BF3,
      32'hD5A79147,
      32'h06CA6351,
      32'h14292967,
      32'h27B70A85,
      32'h2E1B2138,
      32'h4D2C6DFC,
      32'h53380D13,
      32'h650A7354,
      32'h766A0ABB,
      32'h81C2C92E,
      32'h92722C85,
      32'hA2BFE8A1,
      32'hA81A664B,
      32'hC24B8B70,
      32'hC76C51A3,
      32'hD192E819,
      32'hD6990624,
      32'hF40E3585,
      32'h106AA070,
      32'h19A4C116,
      32'h1E376C08,
      32'h2748774C,
      32'h34B0BCB5,
      32'h391C0CB3,
      32'h4ED8AA4A,
      32'h5B9CCA4F,
      32'h682E6FF3,
      32'h748F82EE,
      32'h78A5636F,
      32'h84C87814,
      32'h8CC70208,
      32'h90BEFFFA,
      32'hA4506CEB,
      32'hBEF9A3F7,
      32'hC67178F2
  };

  function automatic logic [LP_WORD_SIZE-1:0] rotate_right_function(
      input logic [LP_WORD_SIZE-1:0] i_input_word, input int unsigned i_shift_amount);
    rotate_right_function = (i_input_word >> i_shift_amount) | (i_input_word << (LP_WORD_SIZE - i_shift_amount));
  endfunction  // SHA-256 never performs ROTR by 0 bits

  function automatic logic [LP_WORD_SIZE-1:0] choice_function(input logic [LP_WORD_SIZE-1:0] i_x,
                                                              input logic [LP_WORD_SIZE-1:0] i_y,
                                                              input logic [LP_WORD_SIZE-1:0] i_z);
    choice_function = (i_x & i_y) ^ (~i_x & i_z);
  endfunction

  function automatic logic [LP_WORD_SIZE-1:0] majority_function(input logic [LP_WORD_SIZE-1:0] i_x,
                                                                input logic [LP_WORD_SIZE-1:0] i_y,
                                                                input logic [LP_WORD_SIZE-1:0] i_z);
    majority_function = (i_x & i_y) ^ (i_y & i_z) ^ (i_z & i_x);
  endfunction

  function automatic logic [LP_WORD_SIZE-1:0] big_sigma_zero_function(
      input logic [LP_WORD_SIZE-1:0] i_x);
    big_sigma_zero_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(2)) ^
        rotate_right_function(.i_input_word(i_x), .i_shift_amount(13)) ^
        rotate_right_function(.i_input_word(i_x), .i_shift_amount(22));
  endfunction

  function automatic logic [LP_WORD_SIZE-1:0] big_sigma_one_function(
      input logic [LP_WORD_SIZE-1:0] i_x);
    big_sigma_one_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(6)) ^
        rotate_right_function(.i_input_word(i_x), .i_shift_amount(11)) ^
        rotate_right_function(.i_input_word(i_x), .i_shift_amount(25));
  endfunction

  function automatic logic [LP_WORD_SIZE-1:0] small_sigma_zero_function(
      input logic [LP_WORD_SIZE-1:0] i_x);
    small_sigma_zero_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(7)) ^
        rotate_right_function(.i_input_word(i_x), .i_shift_amount(18)) ^ (i_x >> 3);
  endfunction

  function automatic logic [LP_WORD_SIZE-1:0] small_sigma_one_function(
      input logic [LP_WORD_SIZE-1:0] i_x);
    small_sigma_one_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(17)) ^
        rotate_right_function(.i_input_word(i_x), .i_shift_amount(19)) ^ (i_x >> 10);
  endfunction

endpackage
