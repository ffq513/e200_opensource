
module e203_onehot8_2bin(
  input  [8-1:0]   onehot_i   ,
  output [4-1:0]    bin_o      
);


wire [4-1:0] onehot_cnt;

assign onehot_cnt[0] = onehot_i[1] | onehot_i[3] | onehot_i[5] | onehot_i[7];

assign onehot_cnt[1] = onehot_i[1] | onehot_i[2] | onehot_i[5] | onehot_i[6];

assign onehot_cnt[2] = onehot_i[1] | onehot_i[2] | onehot_i[3] | onehot_i[4];

assign onehot_cnt[3] = onehot_i[0];

assign bin_o = onehot_cnt;

endmodule
