
                                                                        
`include "e203_defines.v"

module e203_exu_dsp_mac_adder(
  
  
  
    input dsp_mac_op,
    input dsp_addsub_plex_mac_op,
    input dsp_mac_one_sp_two_addend_op,
    input [2:0] dsp_addsub_pb_sign,
    input dsp_concat_r1_op, 
    input dsp_rdw64_op, 
    input dsp_kmda_kmxda_op,
    input [`E203_XLEN-1:0] dsp_i_rs1,
    input dsp_rs1idx_lsb,
    input dsp_rdidx_lsb,
    input  dsp_mac_sub_src1_op,
    input  dsp_mac_sub_src2_op,
    input  sat_mac_rd_q31,
    input  sat_mac_rd_u64,
    input  sat_mac_rd_q63,
    input  [`E203_XLEN-1:0] dsp_mac_adder_src0,
    input  [`E203_XLEN-1:0] dsp_mac_adder_src0_1,
    input  [`E203_XLEN-1:0] dsp_mac_adder_src1,
    input  [`E203_XLEN-1:0] dsp_mac_adder_src2,
    input  [15:0] dsp_mac_adder_src3,
    input  [15:0] dsp_mac_adder_src4,
    input  dsp_unsign_op_flag,
    input  dsp_mul_rd_need_rnd,
    output [`E203_XLEN-1:0] dsp_mac_o_wbck_wdat, 
    output [`E203_XLEN-1:0] dsp_mac_o_wbck_wdat_1, 
  
  
  
  
    output dsp_mac_wbck_err,
    input  dsp_mac_mul_stage_ov,
    output dsp_mac_o_wbck_ov,
    input  clk,
    input  rst_n
);
    
    wire dsp_mac_adder_src0_r_64_op = dsp_rdw64_op | dsp_concat_r1_op;
    wire dsp_mac_adder_src0_idx_lsb = dsp_concat_r1_op ? dsp_rs1idx_lsb : dsp_rdidx_lsb; 
    wire dsp_mac_need_src0_op = dsp_concat_r1_op | dsp_mac_op; 
    assign dsp_mac_wbck_err = 1'b1;

    
localparam PIPE_PACK_W = 5*`E203_XLEN + `E203_ITAG_WIDTH + 17;

    wire [PIPE_PACK_W-2:0] dsp_mac_i_pack;
    wire [PIPE_PACK_W-2:0] i_pack;
    wire [`E203_XLEN-1:0]  i_adder_src1;
    wire [`E203_XLEN-1:0]  i_adder_src2;
    wire [15:0]  i_adder_src3;
    wire [15:0]  i_adder_src4;
    wire [`E203_XLEN-1:0]  i_adder_src0;
    wire [`E203_XLEN-1:0]  i_adder_src0_1;
    wire i_mac_need_src0_op;
    wire i_unsign_op_flag;
    wire i_mul_rd_need_rnd;
    wire i_mac_sub_src1_op;
    wire i_mac_sub_src2_op;
    wire i_sat_mac_rd_q31;
    wire i_sat_mac_rd_u64;
    wire i_sat_mac_rd_q63;
    wire i_adder_src0_r_64_op;
    wire i_adder_src0_idx_lsb;
    wire i_addsub_plex_mac_op;
    wire i_kmda_kmxda_op;
    wire i_mac_one_sp_two_addend_op;
    wire [2:0] i_addsub_pb_sign;
    wire i_mac_mul_stage_ov;
    
    assign dsp_mac_i_pack = {
                             dsp_mac_need_src0_op
                             ,dsp_addsub_plex_mac_op
                             ,dsp_mac_one_sp_two_addend_op
                             ,dsp_kmda_kmxda_op
                             ,dsp_addsub_pb_sign
                             ,dsp_mac_sub_src1_op
                             ,dsp_mac_sub_src2_op
                             ,dsp_mac_adder_src0_r_64_op
                             ,dsp_mac_adder_src0_idx_lsb
                             ,dsp_mac_adder_src0
                             ,dsp_mac_adder_src0_1
                             ,dsp_mac_adder_src1
                             ,dsp_mac_adder_src2
                             ,dsp_mac_adder_src3
                             ,dsp_mac_adder_src4
                             ,dsp_unsign_op_flag
                             ,dsp_mul_rd_need_rnd
                             ,sat_mac_rd_q31
                             ,sat_mac_rd_u64
                             ,sat_mac_rd_q63
                             ,dsp_mac_mul_stage_ov
    };

    assign                  {
                             i_mac_need_src0_op
                             ,i_addsub_plex_mac_op
                             ,i_mac_one_sp_two_addend_op
                             ,i_kmda_kmxda_op
                             ,i_addsub_pb_sign
                             ,i_mac_sub_src1_op
                             ,i_mac_sub_src2_op
                             ,i_adder_src0_r_64_op
                             ,i_adder_src0_idx_lsb
                             ,i_adder_src0
                             ,i_adder_src0_1
                             ,i_adder_src1
                             ,i_adder_src2
                             ,i_adder_src3
                             ,i_adder_src4
                             ,i_unsign_op_flag
                             ,i_mul_rd_need_rnd
                             ,i_sat_mac_rd_q31
                             ,i_sat_mac_rd_u64
                             ,i_sat_mac_rd_q63
                             ,i_mac_mul_stage_ov
                             } = i_pack;

 assign  i_pack = dsp_mac_i_pack;

  wire dsp_mac_cin0 = i_mac_sub_src1_op; 
  wire dsp_mac_cin1 = i_mac_sub_src2_op; 

  wire adder_src1_sign = i_unsign_op_flag ? 1'b0 : i_adder_src1[`E203_XLEN-1];
  wire adder_src2_sign = i_unsign_op_flag ? 1'b0 : i_adder_src2[`E203_XLEN-1];
  wire adder_src3_sign = i_unsign_op_flag ? 1'b0 : i_adder_src3[15];
  wire adder_src4_sign = i_unsign_op_flag ? 1'b0 : i_adder_src4[15];

  wire [63:0] adder_src0_r_64_res = i_adder_src0_idx_lsb ? {i_adder_src0, i_adder_src0_1} : {i_adder_src0_1, i_adder_src0};
  wire adder_src0_r_64_res_sign = i_unsign_op_flag ? 1'b0 : adder_src0_r_64_res[63]; 
  wire adder_src0_sign = i_unsign_op_flag ? 1'b0 : i_adder_src0[`E203_XLEN-1];
  wire [64:0] adder_src0_real = i_adder_src0_r_64_op ? {adder_src0_r_64_res_sign,adder_src0_r_64_res} : {{33{adder_src0_sign}}, i_adder_src0};

  wire [65:0] adder_src0_sign_extd = {66{i_mac_need_src0_op}} & {adder_src0_real,1'b0};

  wire op_exclud_merge_src1_src2 = ~(i_mac_one_sp_two_addend_op | i_mul_rd_need_rnd); 

  wire [65:0] adder_src1_sign_extd = 
                                     ({66{ i_mul_rd_need_rnd}} & {{2{adder_src2_sign}},i_adder_src2,i_adder_src1})
                                   | ({66{i_mac_one_sp_two_addend_op}} & {adder_src2_sign,i_adder_src2,i_adder_src1,1'b0})
                                   | ({66{op_exclud_merge_src1_src2}} & {{33{adder_src1_sign}}, i_adder_src1,1'b0});

  wire [65:0] adder_src1 = i_mac_sub_src1_op ? (~adder_src1_sign_extd ) : adder_src1_sign_extd;

  wire [33:0] adder_src2_sign_extd = {34{op_exclud_merge_src1_src2}} & {adder_src2_sign, i_adder_src2,1'b0} ;

  wire [33:0] adder_src2 =  i_mac_sub_src2_op ? (~adder_src2_sign_extd) : adder_src2_sign_extd;

  wire [17:0] adder_src3_sign_extd = {adder_src3_sign, i_adder_src3,1'b0};
  wire [17:0] adder_src3 = adder_src3_sign_extd;

  wire [17:0] adder_src4_sign_extd = {adder_src4_sign, i_adder_src4,1'b0};
  wire [17:0] adder_src4 = adder_src4_sign_extd;

  wire [4:0] plus1_32comp_op1 = {3'b0,dsp_mac_cin0,1'b0}
                              | ({5{i_addsub_plex_mac_op}} & {1'b0,i_addsub_pb_sign,1'b0})
                              ;

  wire [4:0] plus1_32comp_op2 = {3'b0,dsp_mac_cin1,1'b0};
  wire [4:0] plus1_32comp_op3 =  i_mac_sub_src1_op ? {5{i_mul_rd_need_rnd}} : {4'b0,i_mul_rd_need_rnd};
  wire [4:0] plus1_32comp_c;
  wire [4:0] plus1_32comp_s;
  wire [18:0] bmul_res_42comp_op1 = {{14{plus1_32comp_c[4]}}, plus1_32comp_c};
  wire [18:0] bmul_res_42comp_op2 = {{14{plus1_32comp_s[4]}}, plus1_32comp_s};
  wire [18:0] bmul_res_42comp_op3 = {adder_src3[17],adder_src3};
  wire [18:0] bmul_res_42comp_op4 = {adder_src4[17],adder_src4};
  wire [18:0] bmul_res_42comp_c;
  wire [18:0] bmul_res_42comp_s;
  wire [35:0] hmul_res_32comp_op1 = {{17{bmul_res_42comp_c[18]}}, bmul_res_42comp_c};
  wire [35:0] hmul_res_32comp_op2 = {{17{bmul_res_42comp_s[18]}}, bmul_res_42comp_s};
  wire [35:0] hmul_res_32comp_op3 = {{2{adder_src2[33]}}, adder_src2[33:1],1'b0};
  wire [35:0] hmul_res_32comp_c;
  wire [35:0] hmul_res_32comp_s;
  wire mac_adder_32comp_op2_lsb = i_mul_rd_need_rnd & adder_src1[0];
  wire [67:0] mac_adder_32comp_op1 = {{2{adder_src0_sign_extd[65]}},adder_src0_sign_extd}; 
  wire [67:0] mac_adder_32comp_op2 = {{2{adder_src1[65]}}, adder_src1[65:1],mac_adder_32comp_op2_lsb}; 
  wire [67:0] mac_adder_32comp_op3 = {{32{hmul_res_32comp_s[35]}}, hmul_res_32comp_s}; 
  wire [67:0] mac_adder_32comp_op4 = {{32{hmul_res_32comp_c[35]}}, hmul_res_32comp_c}; 
  wire [67:0] mac_adder_32comp_c;
  wire [67:0] mac_adder_32comp_s;
e203_dsp_32comp #(5) u_dsp_mac_plus1_32comp(.i0(plus1_32comp_op1), 
                                            .i1(plus1_32comp_op2), 
                                            .i2(plus1_32comp_op3), 
                                            .c (plus1_32comp_c), 
                                            .s (plus1_32comp_s));

e203_dsp_42comp #(19) u_dsp_mac_bmul_res_42comp(.i0(bmul_res_42comp_op1), 
                                                .i1(bmul_res_42comp_op2), 
                                                .i2(bmul_res_42comp_op3), 
                                                .i3(bmul_res_42comp_op4), 
                                                .c (bmul_res_42comp_c), 
                                                .s (bmul_res_42comp_s)); 

e203_dsp_32comp #(36) u_dsp_mac_hmul_res_32comp(.i0(hmul_res_32comp_op1), 
                                                .i1(hmul_res_32comp_op2), 
                                                .i2(hmul_res_32comp_op3), 
                                                .c (hmul_res_32comp_c  ), 
                                                .s (hmul_res_32comp_s )); 

e203_dsp_42comp #(68) u_dsp_mac_adder_42comp(.i0(mac_adder_32comp_op1), 
                                             .i1(mac_adder_32comp_op2), 
                                             .i2(mac_adder_32comp_op3), 
                                             .i3(mac_adder_32comp_op4), 
                                             .c (mac_adder_32comp_c), 
                                             .s (mac_adder_32comp_s));

  wire [68:0] dsp_mac_add_res = {mac_adder_32comp_c[67],mac_adder_32comp_c} + {mac_adder_32comp_s[67], mac_adder_32comp_s};
  wire [31:0] dsp_mac_pre_res0 = dsp_mac_add_res[32:1];                                                          
  wire [31:0] dsp_mac_pre_res1 = dsp_mac_add_res[64:33];                                                          
  wire [65:0] dsp_mac_pre_sat = dsp_mac_add_res[66:1]; 

  wire dsp_mac_q31_sat_neg_ov = i_sat_mac_rd_q31 & (dsp_mac_add_res[33] & (~dsp_mac_add_res[32]));
  wire dsp_mac_q63_sat_neg_ov = i_sat_mac_rd_q63 & (dsp_mac_add_res[65] & (~dsp_mac_add_res[64]));
  wire dsp_mac_u64_sat_neg_ov = i_sat_mac_rd_u64 & (dsp_mac_add_res[67]);

  wire dsp_mac_q31_sat_pos_ov = (i_sat_mac_rd_q31 | i_kmda_kmxda_op) & ((~dsp_mac_add_res[33]) & dsp_mac_add_res[32]); 
  wire dsp_mac_q63_sat_pos_ov = i_sat_mac_rd_q63 & ((~dsp_mac_add_res[65]) & dsp_mac_add_res[64]);
  wire dsp_mac_u64_sat_pos_ov = i_sat_mac_rd_u64 & ((~dsp_mac_add_res[67]) & dsp_mac_add_res[65]);
  wire dsp_mac_stage_ov =  
                        ( dsp_mac_q31_sat_neg_ov | dsp_mac_q63_sat_neg_ov | dsp_mac_u64_sat_neg_ov
                        | dsp_mac_q31_sat_pos_ov  |  dsp_mac_q63_sat_pos_ov | dsp_mac_u64_sat_pos_ov);

  wire dsp_mul_stage_ov =  i_mac_mul_stage_ov;

  assign dsp_mac_o_wbck_ov = dsp_mac_stage_ov | dsp_mul_stage_ov;                 
  wire  dsp_mac_rdw64_op = i_adder_src0_r_64_op;

  assign  dsp_mac_o_wbck_wdat = dsp_mac_stage_ov ? 
                                (
                                    ({32{dsp_mac_q31_sat_neg_ov}} & 32'h80000000)
                                  | ({32{dsp_mac_q31_sat_pos_ov }} & 32'h7fffffff)
                                  | ({32{dsp_mac_q63_sat_neg_ov | dsp_mac_u64_sat_neg_ov}}& 32'h0)
                                  | ({32{dsp_mac_q63_sat_pos_ov | dsp_mac_u64_sat_pos_ov}} & 32'hffffffff)
                                )
                                : dsp_mac_pre_res0;

  assign  dsp_mac_o_wbck_wdat_1 = {`E203_XLEN{dsp_mac_rdw64_op}} & (dsp_mac_stage_ov ?
                                                                    (
                                                                        ({32{dsp_mac_q63_sat_neg_ov}} & 32'h80000000)
                                                                      | ({32{dsp_mac_q63_sat_pos_ov}} & 32'h7fffffff)
                                                                      | ({32{dsp_mac_u64_sat_pos_ov}} & 32'hffffffff)
                                                                      | ({32{dsp_mac_u64_sat_neg_ov}} & 32'h0)
                                                                    )
                                                                    : dsp_mac_pre_res1);

endmodule
