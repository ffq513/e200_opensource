
                                                                     
`include "e203_defines.v"
module e203_exu_dsp_shift(

  
  
  
  

  input  [`E203_XLEN-1:0] dsp_i_rs1,
  input  [`E203_XLEN-1:0] dsp_i_rs2,
  input  [`E203_DECINFO_DSP_WIDTH-1:0] dsp_i_info,
  
  
  
  
  output round_req_o,
  output [`E203_DSP_BIGADDER_WIDTH-1:0] round_op1_o,
  output [`E203_DSP_BIGADDER_WIDTH-1:0] round_op2_o,
  input  [`E203_DSP_BIGADDER_WIDTH-1:0] round_res_i,
  
  
  
  
  output shift_right_req_o,
  output shift_left_req_o,
  output [`E203_XLEN-1:0] shift_op1_o,
  output [4:0] shift_op2_o,
  input  [`E203_XLEN-1:0] shift_right_res_i,
  input  [`E203_XLEN-1:0] shift_left_res_i,

  
  
  
    
  output [`E203_XLEN-1:0] dsp_o_wbck_wdat,
  output dsp_o_wbck_ov,
  output dsp_o_wbck_err

  );

wire sra8    = dsp_i_info[`E203_DECINFO_DSP_SRA8]; 
wire srai8   = dsp_i_info[`E203_DECINFO_DSP_SRAI8];
wire sra8u   = dsp_i_info[`E203_DECINFO_DSP_SRA8U];
wire srai8u  = dsp_i_info[`E203_DECINFO_DSP_SRA8IU];
wire srl8    = dsp_i_info[`E203_DECINFO_DSP_SRL8];
wire srli8   = dsp_i_info[`E203_DECINFO_DSP_SRLI8];
wire srl8u   = dsp_i_info[`E203_DECINFO_DSP_SRL8U];
wire srli8u  = dsp_i_info[`E203_DECINFO_DSP_SRLI8U];
wire sll8    = dsp_i_info[`E203_DECINFO_DSP_SLL8];
wire slli8   = dsp_i_info[`E203_DECINFO_DSP_SLLI8];
wire ksll8   = dsp_i_info[`E203_DECINFO_DSP_KSLL8];
wire kslli8  = dsp_i_info[`E203_DECINFO_DSP_KSLLI8];
wire kslra8  = dsp_i_info[`E203_DECINFO_DSP_KSLRA8];
wire kslra8u = dsp_i_info[`E203_DECINFO_DSP_KSLRA8U];
wire sra16   = dsp_i_info[`E203_DECINFO_DSP_SRA16];
wire srai16  = dsp_i_info[`E203_DECINFO_DSP_SRAI16];
wire sra16u  = dsp_i_info[`E203_DECINFO_DSP_SRA16U];
wire srai16u = dsp_i_info[`E203_DECINFO_DSP_SRA16IU];
wire srl16   = dsp_i_info[`E203_DECINFO_DSP_SRL16];
wire srli16  = dsp_i_info[`E203_DECINFO_DSP_SRLI16];
wire srl16u  = dsp_i_info[`E203_DECINFO_DSP_SRL16U];
wire srli16u = dsp_i_info[`E203_DECINFO_DSP_SRLI16U];
wire sll16   = dsp_i_info[`E203_DECINFO_DSP_SRLL16];
wire slli16  = dsp_i_info[`E203_DECINFO_DSP_SRLLI16];
wire ksll16  = dsp_i_info[`E203_DECINFO_DSP_KSLL16];
wire kslli16 = dsp_i_info[`E203_DECINFO_DSP_KSLLI16];
wire kslra16 = dsp_i_info[`E203_DECINFO_DSP_KSLRA16];
wire kslra16u= dsp_i_info[`E203_DECINFO_DSP_KSLRA16U];
wire srau    = dsp_i_info[`E203_DECINFO_DSP_SRAU];
wire sraiu   = dsp_i_info[`E203_DECINFO_DSP_SRAIU];
wire kslraw  = dsp_i_info[`E203_DECINFO_DSP_KSLRAW];
wire kslrawu = dsp_i_info[`E203_DECINFO_DSP_KSLRAWU];
wire ksllw   = dsp_i_info[`E203_DECINFO_DSP_KSLLW];
wire kslliw  = dsp_i_info[`E203_DECINFO_DSP_KSLLIW];

wire [4:0] shifter_imm = dsp_i_info[`E203_DECINFO_DSP_IMM];

wire need_imm8  = srai8 | srai8u | srli8 | srli8u | slli8 | kslli8;
wire need_imm16 = srai16 | srai16u | srli16 | srli16u | slli16 | kslli16;
wire need_imm32 = sraiu | kslliw;
wire rs2_8_0    = sra8 | sra8u | srl8 | srl8u | sll8 | ksll8;       
wire rs2_8_1    = kslra8 | kslra8u;                                 
wire rs2_16_0   = sra16 | sra16u | srl16 | srl16u | sll16 | ksll16; 
wire rs2_16_1   = kslra16 | kslra16u;                               
wire rs2_32_0   = srau | ksllw;                                     
wire rs2_32_1   = kslraw | kslrawu;                                 

wire [4:0] shifter_op2_32_1 = dsp_i_rs2[5] ? ((dsp_i_rs2[4:0] == 5'b0) ? 5'b11111 : ~dsp_i_rs2[4:0] + 1'b1) :
                              dsp_i_rs2[4:0];
wire [3:0] shifter_op2_16_1 = dsp_i_rs2[4] ? ((dsp_i_rs2[3:0] == 4'b0) ? 4'b1111 : ~dsp_i_rs2[3:0] + 1'b1) :
                              dsp_i_rs2[3:0];
wire [3:0] shifter_op2_8_1  = dsp_i_rs2[3] ? ((dsp_i_rs2[2:0] == 3'b0) ? 3'b111 : ~dsp_i_rs2[2:0] + 1'b1) :
                              dsp_i_rs2[2:0];

wire [4:0] shifter_op2  = ({5{need_imm8}} & {2'b0,shifter_imm[2:0]}) |
                          ({5{need_imm16}} & {1'b0,shifter_imm[3:0]}) |
                          ({5{need_imm32}} & {shifter_imm[4:0]}) |
                          ({5{rs2_8_0}} & {2'b0, dsp_i_rs2[2:0]}) |
                          ({5{rs2_8_1}} & {2'b0, shifter_op2_8_1[2:0]}) |
                          ({5{rs2_16_0}} & {1'b0, dsp_i_rs2[3:0]}) |
                          ({5{rs2_16_1}} & {1'b0, shifter_op2_16_1[3:0]}) |
                          ({5{rs2_32_0}} & {dsp_i_rs2[4:0]}) |
                          ({5{rs2_32_1}} & {shifter_op2_32_1[4:0]});

wire sat8  = kslli8 | ksll8 | (kslra8 | kslra8u) & ~dsp_i_rs2[3];
wire sat16 = kslli16 | ksll16 | (kslra16 | kslra16u) & ~dsp_i_rs2[4];
wire sat32 = ksllw | kslliw | ((kslraw | kslrawu) & ~dsp_i_rs2[5]);
wire op_sat = sat8 | sat16 | sat32;

wire round8_a  = srai8u | sra8u | (kslra8u & dsp_i_rs2[3]);
wire round8_l  = srli8u | srl8u;
wire round8    = round8_a | round8_l;
wire round16_a = srai16u | sra16u | (kslra16u & dsp_i_rs2[4]);
wire round16_l = srli16u | srl16u;
wire round16   = round16_a | round16_l;
wire round32   = srau | sraiu | (kslrawu & dsp_i_rs2[5]);
wire round_a   = round8_a | round16_a | round32;
wire round_l   = round8_l | round16_l;
wire op_round  = round8 | round16 | round32;

wire op_srl8  = srli8 | srli8u | srl8 | srl8u;
wire op_srl16 = srli16 | srli16u | srl16 | srl16u;
wire op_srl32 = 1'b0;
wire op_srl   = op_srl8 | op_srl16 | op_srl32;

wire op_sra8  = srai8 | srai8u | sra8 | sra8u | ((kslra8 | kslra8u) & dsp_i_rs2[3]);
wire op_sra16 = srai16 | srai16u | sra16 | sra16u | ((kslra16 | kslra16u) & dsp_i_rs2[4]);
wire op_sra32 = srau | sraiu | ((kslraw | kslrawu) & dsp_i_rs2[5]);
wire op_sra   = op_sra8 | op_sra16 | op_sra32;

wire op_sll8  = slli8 | sll8 | sat8;
wire op_sll16 = slli16 | sll16 | sat16;
wire op_sll32 = sat32;
wire op_sll   = op_sll8 | op_sll16 | op_sll32;

wire op_shift8 = op_srl8 | op_sra8 | op_sll8;
wire op_shift16 = op_srl16 | op_sra16 | op_sll16;
wire op_shift32 = op_srl32 | op_sra32 | op_sll32;

wire [`E203_XLEN-1:0] shifter_op1 = dsp_i_rs1;
assign shift_right_req_o = op_sra | op_srl;
assign shift_left_req_o = op_sll;
assign shift_op1_o = shifter_op1;
assign shift_op2_o = shifter_op2;

wire [`E203_XLEN-1:0] sll_res_pre;
wire [`E203_XLEN-1:0] sra_res_pre;
wire [`E203_XLEN-1:0] srl_res_pre;
wire [`E203_XLEN-1:0] eff_mask;
wire [`E203_XLEN-1:0] eff_mask_real;

assign eff_mask             = (~(`E203_XLEN'b0)) >> shifter_op2;
assign eff_mask_real[7:0]   = op_shift8 ? eff_mask[31:24] : op_shift16 ? eff_mask[23:16] : eff_mask[7:0];
assign eff_mask_real[15:8]  = (op_shift8 | op_shift16) ? eff_mask[31:24] : eff_mask[15:8];
assign eff_mask_real[23:16] = op_shift8 ? eff_mask[31:24] : eff_mask[23:16];
assign eff_mask_real[31:24] = eff_mask[31:24];

wire [`E203_XLEN-1:0] sra_sign_ext;
assign sra_sign_ext[31:24] = {8{shifter_op1[31]}};
assign sra_sign_ext[23:16] = op_shift8 ? {8{shifter_op1[23]}} : {8{shifter_op1[31]}};
assign sra_sign_ext[15:8]  = ~op_shift32 ? {8{shifter_op1[15]}} : {8{shifter_op1[31]}};
assign sra_sign_ext[7:0]   = op_shift8 ? {8{shifter_op1[7]}} : sra_sign_ext[15:8]; 

wire [`E203_XLEN-1:0] sll_mask = 
                 {
    eff_mask_real[00],eff_mask_real[01],eff_mask_real[02],eff_mask_real[03],
    eff_mask_real[04],eff_mask_real[05],eff_mask_real[06],eff_mask_real[07],
    eff_mask_real[08],eff_mask_real[09],eff_mask_real[10],eff_mask_real[11],
    eff_mask_real[12],eff_mask_real[13],eff_mask_real[14],eff_mask_real[15],
    eff_mask_real[16],eff_mask_real[17],eff_mask_real[18],eff_mask_real[19],
    eff_mask_real[20],eff_mask_real[21],eff_mask_real[22],eff_mask_real[23],
    eff_mask_real[24],eff_mask_real[25],eff_mask_real[26],eff_mask_real[27],
    eff_mask_real[28],eff_mask_real[29],eff_mask_real[30],eff_mask_real[31]
                 };

assign sll_res_pre = sll_mask & shift_left_res_i;
assign srl_res_pre = eff_mask_real & shift_right_res_i;
assign sra_res_pre = srl_res_pre | (sra_sign_ext & (~eff_mask_real));

wire op_shift = op_sra | op_sll | op_srl; 


wire [3:0]           shift8_t_ov;
wire [3:0]           shift8_b_ov;
wire [1:0]           shift16_t_ov;
wire [1:0]           shift16_b_ov;
wire                 shift32_t_ov;
wire                 shift32_b_ov;
wire [`E203_XLEN-1:0] shift_sat32_t =   ({`E203_XLEN{sat8 }} & {1'b0, eff_mask_real[31:17], 1'b0, eff_mask_real[15:9], 1'b0, eff_mask_real[7:1]}) 
                                     | ({`E203_XLEN{sat16}} & {1'b0, eff_mask_real[31:17], 1'b0, eff_mask_real[15:1]})
                                     | ({`E203_XLEN{sat32}} & {1'b0, eff_mask_real[31:1]});

wire [`E203_XLEN-1:0] shift_sat32_b = ~shift_sat32_t;

e203_dynamic_sat e203_dynamic_sat_u
(
	.dsat_op_i      ( shifter_op1   ),     
	.dsat32_cmp_t   ( shift_sat32_t ),     
	.dsat32_cmp_b   ( shift_sat32_b ),     
	.dsat32_t_ov    ( shift32_t_ov  ),     
	.dsat32_b_ov    ( shift32_b_ov  ),     
	.dsat16_t_ov    ( shift16_t_ov  ),     
	.dsat16_b_ov    ( shift16_b_ov  ),     
	.dsat8_t_ov     ( shift8_t_ov   ),     
	.dsat8_b_ov     ( shift8_b_ov   )      
);

wire [`E203_XLEN-1:0] sat8_res;
assign sat8_res[7:0]   = shift8_t_ov[0] ? 8'h7f : shift8_b_ov[0] ? 8'h80 : sll_res_pre[7:0];
assign sat8_res[15:8]  = shift8_t_ov[1] ? 8'h7f : shift8_b_ov[1] ? 8'h80 : sll_res_pre[15:8];
assign sat8_res[23:16] = shift8_t_ov[2] ? 8'h7f : shift8_b_ov[2] ? 8'h80 : sll_res_pre[23:16];
assign sat8_res[31:24] = shift8_t_ov[3] ? 8'h7f : shift8_b_ov[3] ? 8'h80 : sll_res_pre[31:24];

wire [`E203_XLEN-1:0] sat16_res;
assign sat16_res[15:0]  = shift16_t_ov[0] ? 16'h7fff : shift16_b_ov[0] ? 16'h8000 : sll_res_pre[15:0];
assign sat16_res[31:16] = shift16_t_ov[1] ? 16'h7fff : shift16_b_ov[1] ? 16'h8000 : sll_res_pre[31:16];

wire [`E203_XLEN-1:0] sat32_res;
assign sat32_res        = shift32_t_ov ? 32'h7fffffff : shift32_b_ov ? 32'h80000000 : sll_res_pre[31:0];

wire [`E203_XLEN-1:0] sat_res;
assign sat_res          = sat8 ? sat8_res :
                          sat16 ? sat16_res :
                          sat32_res;

wire [`E203_XLEN:0]   eff_mask_br_ext;  
wire [`E203_XLEN-1:0] eff_mask_br; 
wire [`E203_XLEN-1:0] onehot32_sr1;  
assign eff_mask_br = 
                 {
    eff_mask[00],eff_mask[01],eff_mask[02],eff_mask[03],
    eff_mask[04],eff_mask[05],eff_mask[06],eff_mask[07],
    eff_mask[08],eff_mask[09],eff_mask[10],eff_mask[11],
    eff_mask[12],eff_mask[13],eff_mask[14],eff_mask[15],
    eff_mask[16],eff_mask[17],eff_mask[18],eff_mask[19],
    eff_mask[20],eff_mask[21],eff_mask[22],eff_mask[23],
    eff_mask[24],eff_mask[25],eff_mask[26],eff_mask[27],
    eff_mask[28],eff_mask[29],eff_mask[30],eff_mask[31]
                 };

assign eff_mask_br_ext = {1'b1, eff_mask_br};

genvar i;
generate 
	for(i=0; i<`E203_XLEN; i=i+1) begin: gen_onehot_sr1
		assign onehot32_sr1[i] = (~eff_mask_br_ext[i] & eff_mask_br_ext[i+1]);
	end
endgenerate


wire [3:0] discard8_msb;
assign discard8_msb[0] = |(shifter_op1[7:0] & onehot32_sr1[7:0]);
assign discard8_msb[1] = |(shifter_op1[15:8] & onehot32_sr1[7:0]);
assign discard8_msb[2] = |(shifter_op1[23:16] & onehot32_sr1[7:0]);
assign discard8_msb[3] = |(shifter_op1[31:24] & onehot32_sr1[7:0]);

wire [1:0] discard16_msb;
assign discard16_msb[0] = (|(shifter_op1[15:8] & onehot32_sr1[15:8])) | discard8_msb[0];   
assign discard16_msb[1] = |(shifter_op1[31:16] & onehot32_sr1[15:0]);

wire discard32_msb;
assign discard32_msb = (|(shifter_op1[31:16] & onehot32_sr1[31:16])) | discard16_msb[0];   



assign round_op1_o =   ({`E203_DSP_BIGADDER_WIDTH{round8_a }} & {1'b0, sra_res_pre[31], sra_res_pre[31:24], 1'b0, sra_res_pre[23], sra_res_pre[23:16], 
                                                                1'b0, sra_res_pre[15], sra_res_pre[15:8], 1'b0, sra_res_pre[7], sra_res_pre[7:0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round8_l }} & {2'b0, srl_res_pre[31:24], 2'b0, srl_res_pre[23:16], 
                                                                2'b0, srl_res_pre[15:8], 2'b0, srl_res_pre[7:0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round16_a}} & {3'b0, sra_res_pre[31], sra_res_pre[31:16], 3'b0, sra_res_pre[15], sra_res_pre[15:0]}) 
                     | ({`E203_DSP_BIGADDER_WIDTH{round16_l}} & {4'b0, srl_res_pre[31:16], 4'b0, srl_res_pre[15:0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round32  }} & {7'b0, sra_res_pre[31], sra_res_pre[31:0]}) 
                     ;

assign round_op2_o =   ({`E203_DSP_BIGADDER_WIDTH{round8_a }} & {9'b0, discard8_msb[3], 9'b0, discard8_msb[2], 9'b0, discard8_msb[1], 9'b0, discard8_msb[0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round8_l }} & {9'b0, discard8_msb[3], 9'b0, discard8_msb[2], 9'b0, discard8_msb[1], 9'b0, discard8_msb[0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round16_a}} & {19'b0, discard16_msb[1], 19'b0, discard16_msb[0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round16_l}} & {19'b0, discard16_msb[1], 19'b0, discard16_msb[0]})
                     | ({`E203_DSP_BIGADDER_WIDTH{round32  }} & {39'b0, discard32_msb})
                     ;

assign round_req_o = op_round;
wire [`E203_XLEN-1:0] round_res;

assign round_res =   ({`E203_XLEN{round8 }} & {round_res_i[37:30], round_res_i[27:20], round_res_i[17:10], round_res_i[7:0]})
                   | ({`E203_XLEN{round16}} & {round_res_i[35:20], round_res_i[15:0]})
                   | ({`E203_XLEN{round32}} & {round_res_i[31:0]})
                   ;

assign dsp_o_wbck_wdat = op_sat ? sat_res :
                         op_round ? round_res : 
                         op_sll ? sll_res_pre :
                         op_srl ? srl_res_pre :
                         op_sra ? sra_res_pre : 32'b0;
						   
wire dsp_o_wbck_ov_pre = sat8 ? |{shift8_t_ov,shift8_b_ov} :
                         sat16 ? |{shift16_t_ov,shift16_b_ov} :
                         sat32 ? |{shift32_t_ov,shift32_b_ov} : 1'b0;

assign dsp_o_wbck_ov = dsp_o_wbck_ov_pre;

assign dsp_o_wbck_err = 1'b0;

endmodule
