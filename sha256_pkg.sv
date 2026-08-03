package sha256_pkg;
localparam int unsigned LP_WORD_SIZE = 32;
localparam int unsigned LP_NUMBER_OF_ROUNDS = 64;

// Initial hash values (H0-H7)

function automatic logic [LP_WORD_SIZE-1:0] rotate_right_function(
    input logic [LP_WORD_SIZE-1:0] i_input_word,
    input int unsigned i_shift_amount
);
    rotate_right_function = (i_input_word >> i_shift_amount) | (i_input_word << (LP_WORD_SIZE - i_shift_amount));
endfunction // SHA-256 never performs ROTR by 0 bits

function automatic logic [LP_WORD_SIZE-1:0] choice_function(
    input logic [LP_WORD_SIZE-1:0] i_x,
    input logic [LP_WORD_SIZE-1:0] i_y,
    input logic [LP_WORD_SIZE-1:0] i_z
);
    choice_function = (i_x & i_y) ^ (~i_x & i_z);
endfunction

function automatic logic [LP_WORD_SIZE-1:0] majority_function(
    input logic [LP_WORD_SIZE-1:0] i_x,
    input logic [LP_WORD_SIZE-1:0] i_y,
    input logic [LP_WORD_SIZE-1:0] i_z
);
    majority_function = (i_x & i_y) ^ (i_y & i_z) ^ (i_z & i_x);
endfunction

function automatic logic [LP_WORD_SIZE-1:0] big_sigma_zero_function(
    input logic [LP_WORD_SIZE-1:0] i_x
);
    big_sigma_zero_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(2)) ^ rotate_right_function(.i_input_word(i_x),
                                                                                                                    .i_shift_amount(13)) ^ rotate_right_function(.i_input_word(i_x), .i_shift_amount(22));
endfunction

function automatic logic [LP_WORD_SIZE-1:0] big_sigma_one_function(
    input logic [LP_WORD_SIZE-1:0] i_x
);
    big_sigma_one_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(6)) ^ rotate_right_function(.i_input_word(i_x),
                                                                                                                   .i_shift_amount(11)) ^ rotate_right_function(.i_input_word(i_x), .i_shift_amount(25));
endfunction

function automatic logic [LP_WORD_SIZE-1:0] small_sigma_zero_function(
    input logic [LP_WORD_SIZE-1:0] i_x
);
    small_sigma_zero_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(7)) ^ rotate_right_function(.i_input_word(i_x),
                                                                                                                      .i_shift_amount(18)) ^ (i_x >> 3);
endfunction

function automatic logic [LP_WORD_SIZE-1:0] small_sigma_one_function(
    input logic [LP_WORD_SIZE-1:0] i_x
);
    small_sigma_one_function = rotate_right_function(.i_input_word(i_x), .i_shift_amount(17)) ^ rotate_right_function(.i_input_word(i_x),
                                                                                                                      .i_shift_amount(19)) ^ (i_x >> 10);
endfunction

endpackage
