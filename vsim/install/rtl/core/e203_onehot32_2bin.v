
                                                                     
`include "e203_defines.v"

module e203_onehot32_2bin(
  input  [32-1:0]   onehot_i   ,
  output [6-1:0]    bin_o      
);

wire [6-1:0] onehot_cnt;

genvar i;

assign onehot_cnt[0] = onehot_i[1] | onehot_i[3] | onehot_i[5] | onehot_i[7] | onehot_i[9] |
                         onehot_i[11] | onehot_i[13] | onehot_i[15] | onehot_i[17] | onehot_i[19] |
                         onehot_i[21] | onehot_i[23] | onehot_i[25] | onehot_i[27] | onehot_i[29] |
                         onehot_i[31];

assign onehot_cnt[1] = onehot_i[1] | onehot_i[2] | onehot_i[5] | onehot_i[6] | onehot_i[9] |
                         onehot_i[10] | onehot_i[13] | onehot_i[14] | onehot_i[17] | onehot_i[18] |
                         onehot_i[21] | onehot_i[22] | onehot_i[25] | onehot_i[26] | onehot_i[29] |
                         onehot_i[30];

assign onehot_cnt[2] = onehot_i[1] | onehot_i[2] | onehot_i[3] | onehot_i[4] |
                         onehot_i[9] | onehot_i[10] | onehot_i[11] | onehot_i[12] | 
                         onehot_i[17] | onehot_i[18] | onehot_i[19] | onehot_i[20] |
                         onehot_i[25] | onehot_i[26] | onehot_i[27] | onehot_i[28];

assign onehot_cnt[3] = onehot_i[1] | onehot_i[2] | onehot_i[3] | onehot_i[4] |
                         onehot_i[5] | onehot_i[6] | onehot_i[7] | onehot_i[8] | 
                         onehot_i[17] | onehot_i[18] | onehot_i[19] | onehot_i[20] |
                         onehot_i[21] | onehot_i[22] | onehot_i[23] | onehot_i[24];

assign onehot_cnt[4] = onehot_i[1] | onehot_i[2] | onehot_i[3] | onehot_i[4] |
                         onehot_i[5] | onehot_i[6] | onehot_i[7] | onehot_i[8] | 
                         onehot_i[9] | onehot_i[10] | onehot_i[11] | onehot_i[12] |
                         onehot_i[13] | onehot_i[14] | onehot_i[15] | onehot_i[16];

assign onehot_cnt[5] = onehot_i[0];

assign bin_o = onehot_cnt;

endmodule
