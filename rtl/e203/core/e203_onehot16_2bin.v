
module e203_onehot16_2bin(
  input  [16-1:0]   onehot_i   ,
  output [5-1:0]    bin_o      
);


wire [5-1:0] onehot_cnt;

assign onehot_cnt[0] = onehot_i[1] | onehot_i[3] | onehot_i[5] | onehot_i[7] | onehot_i[9] |
                         onehot_i[11] | onehot_i[13] | onehot_i[15];

assign onehot_cnt[1] = onehot_i[1] | onehot_i[2] | onehot_i[5] | onehot_i[6] | onehot_i[9] |
                         onehot_i[10] | onehot_i[13] | onehot_i[14];

assign onehot_cnt[2] = onehot_i[1] | onehot_i[2] | onehot_i[3] | onehot_i[4] |
                         onehot_i[9] | onehot_i[10] | onehot_i[11] | onehot_i[12];

assign onehot_cnt[3] = onehot_i[1] | onehot_i[2] | onehot_i[3] | onehot_i[4] |
                         onehot_i[5] | onehot_i[6] | onehot_i[7] | onehot_i[8] ;

assign onehot_cnt[4] = onehot_i[0];

assign bin_o = onehot_cnt;

endmodule
