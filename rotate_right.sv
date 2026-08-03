module rotate_right(
    input     logic       [31:0]      i_input_word                  ,
    input     logic       [4:0]       i_shift_amount                 ,
    output    logic       [31:0]      o_output_word
);

assign o_output_word = i_shift_amount == 0 ? i_input_word : {i_input_word[i_shift_amount-1:0], i_input_word[31:i_shift_amount]
};

endmodule
