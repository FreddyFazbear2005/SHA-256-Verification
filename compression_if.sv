interface compression_if (
    input logic i_clk
);
  logic i_reset;
  logic i_start;
  logic [sha256_pkg::LP_WORD_SIZE-1:0] i_message_schedule[0:63];
  logic [255:0] o_digest;
  logic o_done;
endinterface
