
                                                                    
`include "e203_defines.v"

module e203_exu_dsp_simd_mul(
    input [`E203_XLEN-1:0] dsp_mul_i_rs1,
    input [`E203_XLEN-1:0] dsp_mul_i_rs2,
    output [`E203_XLEN:0] dsp_mul16_adder_op1,
    output [`E203_XLEN:0] dsp_mul16_adder_op2,
    input [`E203_XLEN+1:0]   dsp_mul16_adder_res,
    input dsp_unsign_op_flag,

    input bmul_simd_op,
    input hmul_simd_op,
    input simd_cross_mul_op_flag,
    output dsp_mul_o_wbck_err,
    output [63:0] dsp_simd_mul_res,
    input dsp_rs2_unsign_op_flag 
);

  wire [1:0] dsp_hmul_rs1_sign;
  wire [1:0] dsp_hmul_rs2_sign;
  wire [3:0] dsp_bmul_rs1_sign;
  wire [3:0] dsp_bmul_rs2_sign;
  wire [16:0] dsp_hmul_op1_l;
  wire [16:0] dsp_hmul_op2_l; 
  wire [8:0] dsp_bmul_op1_raw [0:4-1];
  wire [8:0] dsp_bmul_op2_raw [0:4-1];
  wire [8:0] dsp_bmul_op1 [0:4-1];
  wire [8:0] dsp_bmul_op2 [0:4-1];
  wire [31:0] dsp_hmul_res[0:2-1];
  wire [15:0] dsp_bmul_res[0:4-1];
  wire [7:0] dsp_bmul_rs1[0:4-1];
  wire [7:0] dsp_bmul_rs2[0:4-1];
  wire [15:0] dsp_hmul_rs1[0:2-1];
  wire [15:0] dsp_hmul_rs2[0:2-1];
  wire [16:0] dsp_bmul_res_signed[0:4-1];
  wire signed [32:0] dsp_hmul_res_signed[0:2-1];
  assign dsp_mul_o_wbck_err = 1'b0;

  wire [7:0] rs1_byte_0 = dsp_mul_i_rs1[7:0];
  wire [7:0] rs1_byte_1 = dsp_mul_i_rs1[15:8];
  wire [7:0] rs1_byte_2 = dsp_mul_i_rs1[23:16];
  wire [7:0] rs1_byte_3 = dsp_mul_i_rs1[31:24];
  wire [7:0] rs2_byte_0 = dsp_mul_i_rs2[7:0];
  wire [7:0] rs2_byte_1 = dsp_mul_i_rs2[15:8];
  wire [7:0] rs2_byte_2 = dsp_mul_i_rs2[23:16];
  wire [7:0] rs2_byte_3 = dsp_mul_i_rs2[31:24];


  assign dsp_bmul_rs1_sign[0] = dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ? dsp_mul_i_rs1[7]  : 1'b0;
  assign dsp_bmul_rs1_sign[1] = dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ? dsp_mul_i_rs1[15] : 1'b0;
  assign dsp_bmul_rs1_sign[2] = dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ? dsp_mul_i_rs1[23] : dsp_mul_i_rs1[31]; 
  assign dsp_bmul_rs1_sign[3] = dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ? dsp_mul_i_rs1[31] : dsp_mul_i_rs1[31]; 
  assign dsp_bmul_rs2_sign[0] = dsp_rs2_unsign_op_flag ? 1'b0 : dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ?
                                (simd_cross_mul_op_flag ? dsp_mul_i_rs2[15] : dsp_mul_i_rs2[7])  : 1'b0;
  assign dsp_bmul_rs2_sign[1] = dsp_rs2_unsign_op_flag ? 1'b0 : dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ? 
                                (simd_cross_mul_op_flag ? dsp_mul_i_rs2[7] : dsp_mul_i_rs2[15]) :
                                (simd_cross_mul_op_flag ? dsp_mul_i_rs2[15] : dsp_mul_i_rs2[31]);
  assign dsp_bmul_rs2_sign[2] = dsp_rs2_unsign_op_flag ? 1'b0 : dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ?
                                (simd_cross_mul_op_flag ? dsp_mul_i_rs2[31] : dsp_mul_i_rs2[23]) : 1'b0;
  assign dsp_bmul_rs2_sign[3] = dsp_rs2_unsign_op_flag ? 1'b0 : dsp_unsign_op_flag ? 1'b0 : bmul_simd_op ?
                                (simd_cross_mul_op_flag ? dsp_mul_i_rs2[23] : dsp_mul_i_rs2[31]) :
                                (simd_cross_mul_op_flag ? dsp_mul_i_rs2[15] : dsp_mul_i_rs2[31]);
  

  assign dsp_hmul_rs1_sign[0] = dsp_unsign_op_flag ? 1'b0 : dsp_mul_i_rs1[15];
  assign dsp_hmul_rs1_sign[1] = dsp_unsign_op_flag ? 1'b0 : dsp_mul_i_rs1[31];
  assign dsp_hmul_rs2_sign[0] = dsp_rs2_unsign_op_flag ? 1'b0 : dsp_unsign_op_flag ? 1'b0 :  dsp_mul_i_rs2[15];
  assign dsp_hmul_rs2_sign[1] = dsp_rs2_unsign_op_flag ? 1'b0 : dsp_unsign_op_flag ? 1'b0 :  dsp_mul_i_rs2[31];

  assign dsp_bmul_rs1[0] = hmul_simd_op ? rs1_byte_2 : rs1_byte_0;
  assign dsp_bmul_rs1[1] = hmul_simd_op ?  rs1_byte_2 : rs1_byte_1;
  assign dsp_bmul_rs1[2] = hmul_simd_op ? rs1_byte_3 : rs1_byte_2;
  assign dsp_bmul_rs1[3] = hmul_simd_op ? rs1_byte_3 : rs1_byte_3;
  assign dsp_bmul_rs2[0] = hmul_simd_op ? (simd_cross_mul_op_flag ? rs2_byte_0 : rs2_byte_2) 
                                        : (simd_cross_mul_op_flag ? rs2_byte_1 : rs2_byte_0);
  assign dsp_bmul_rs2[1] = hmul_simd_op ? (simd_cross_mul_op_flag ? rs2_byte_1 : rs2_byte_3) 
                                        : (simd_cross_mul_op_flag ? rs2_byte_0 : rs2_byte_1);
  assign dsp_bmul_rs2[2] = hmul_simd_op ? (simd_cross_mul_op_flag ? rs2_byte_0 : rs2_byte_2) 
                                        : (simd_cross_mul_op_flag ? rs2_byte_3 : rs2_byte_2);
  assign dsp_bmul_rs2[3] = hmul_simd_op ? (simd_cross_mul_op_flag ? rs2_byte_1 : rs2_byte_3) 
                                        : (simd_cross_mul_op_flag ? rs2_byte_2 : rs2_byte_3);
  assign dsp_hmul_rs1[0] = dsp_mul_i_rs1[15:0];
  assign dsp_hmul_rs1[1] = dsp_mul_i_rs1[31:16];
  assign dsp_hmul_rs2[0] = dsp_mul_i_rs2[15:0];
  assign dsp_hmul_rs2[1] = dsp_mul_i_rs2[31:16];

  assign dsp_bmul_op1_raw[0] = {dsp_bmul_rs1_sign[0],dsp_bmul_rs1[0]};
  assign dsp_bmul_op1_raw[1] = {dsp_bmul_rs1_sign[1],dsp_bmul_rs1[1]};
  assign dsp_bmul_op1_raw[2] = {dsp_bmul_rs1_sign[2],dsp_bmul_rs1[2]};
  assign dsp_bmul_op1_raw[3] = {dsp_bmul_rs1_sign[3],dsp_bmul_rs1[3]};

  assign dsp_bmul_op2_raw[0] = {dsp_bmul_rs2_sign[0],dsp_bmul_rs2[0]};
  assign dsp_bmul_op2_raw[1] = {dsp_bmul_rs2_sign[1],dsp_bmul_rs2[1]};
  assign dsp_bmul_op2_raw[2] = {dsp_bmul_rs2_sign[2],dsp_bmul_rs2[2]};
  assign dsp_bmul_op2_raw[3] = {dsp_bmul_rs2_sign[3],dsp_bmul_rs2[3]};

  assign dsp_bmul_op1[0] = dsp_bmul_op1_raw[0];
  assign dsp_bmul_op1[1] = dsp_bmul_op1_raw[1];
  assign dsp_bmul_op1[2] = dsp_bmul_op1_raw[2];
  assign dsp_bmul_op1[3] = dsp_bmul_op1_raw[3];
  assign dsp_bmul_op2[0] = dsp_bmul_op2_raw[0];
  assign dsp_bmul_op2[1] = dsp_bmul_op2_raw[1];
  assign dsp_bmul_op2[2] = dsp_bmul_op2_raw[2];
  assign dsp_bmul_op2[3] = dsp_bmul_op2_raw[3];

  assign dsp_hmul_op1_l = {dsp_hmul_rs1_sign[0],dsp_hmul_rs1[0]};
  assign dsp_hmul_op2_l = simd_cross_mul_op_flag ? {dsp_hmul_rs2_sign[1],dsp_hmul_rs2[1]} :
                                                    {dsp_hmul_rs2_sign[0],dsp_hmul_rs2[0]} ;

  assign dsp_bmul_res_signed[0] = $signed(dsp_bmul_op1[0]) * $signed(dsp_bmul_op2[0]); 
  assign dsp_bmul_res_signed[1] = $signed(dsp_bmul_op1[1]) * $signed(dsp_bmul_op2[1]); 
  assign dsp_bmul_res_signed[2] = $signed(dsp_bmul_op1[2]) * $signed(dsp_bmul_op2[2]); 
  assign dsp_bmul_res_signed[3] = $signed(dsp_bmul_op1[3]) * $signed(dsp_bmul_op2[3]); 
  assign dsp_hmul_res_signed[0] = $signed(dsp_hmul_op1_l) * $signed(dsp_hmul_op2_l);

wire dsp_mul16_pp0_sign = dsp_unsign_op_flag ? 1'b0 : dsp_bmul_res_signed[0][16];                                    
wire dsp_mul16_pp1_sign = dsp_unsign_op_flag ? 1'b0 : dsp_bmul_res_signed[1][16];                                    
wire dsp_mul16_pp2_sign = dsp_unsign_op_flag ? 1'b0 : dsp_bmul_res_signed[2][16];                                    

wire [`E203_XLEN:0] dsp_mul16_pp0 =  {{16{dsp_mul16_pp0_sign}},dsp_bmul_res_signed[0]};
wire [`E203_XLEN:0] dsp_mul16_pp1 =  {{ 8{dsp_mul16_pp1_sign}},dsp_bmul_res_signed[1],8'b0};
wire [`E203_XLEN:0] dsp_mul16_pp2 =  {{ 8{dsp_mul16_pp2_sign}},dsp_bmul_res_signed[2],8'b0};
wire [`E203_XLEN:0] dsp_mul16_pp3 =  {                         dsp_bmul_res_signed[3],16'b0};
e203_dsp_42comp #(`E203_XLEN+1) u_dsp_mul16_42comp(
                                        .i0(dsp_mul16_pp0), 
                                        .i1(dsp_mul16_pp1), 
                                        .i2(dsp_mul16_pp2), 
                                        .i3(dsp_mul16_pp3), 
                                        .c(dsp_mul16_adder_op1), 
                                        .s(dsp_mul16_adder_op2)
                                        );

  assign dsp_hmul_res_signed[1] = dsp_mul16_adder_res[`E203_XLEN-1:0];
  assign dsp_bmul_res[0] = $unsigned(dsp_bmul_res_signed[0][15:0]);
  assign dsp_bmul_res[1] = $unsigned(dsp_bmul_res_signed[1][15:0]);
  assign dsp_bmul_res[2] = $unsigned(dsp_bmul_res_signed[2][15:0]);
  assign dsp_bmul_res[3] = $unsigned(dsp_bmul_res_signed[3][15:0]);
  assign dsp_hmul_res[0] = $unsigned(dsp_hmul_res_signed[0][`E203_XLEN-1:0]);
  assign dsp_hmul_res[1] = $unsigned(dsp_hmul_res_signed[1][`E203_XLEN-1:0]);
  assign dsp_simd_mul_res = hmul_simd_op ? {dsp_hmul_res[1],dsp_hmul_res[0]} :
                       bmul_simd_op ? {dsp_bmul_res[3],dsp_bmul_res[2],dsp_bmul_res[1],dsp_bmul_res[0]} :
                       64'b0;
endmodule
