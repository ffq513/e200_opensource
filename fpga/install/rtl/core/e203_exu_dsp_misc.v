
                                                                      
`include "e203_defines.v"

module e203_exu_dsp_misc(

  
  
  
  input  [`E203_XLEN-1:0] dsp_i_rs1,       
  input  [`E203_XLEN-1:0] dsp_i_rs1_64,    
  input  [`E203_XLEN-1:0] dsp_i_rs2,
  input  [`E203_XLEN-1:0] dsp_i_rc,
  input  [`E203_XLEN-1:0] dsp_i_rd,        
  input  [`E203_DECINFO_DSP_WIDTH-1:0] dsp_i_info,

  
  
  
  
  output br_shift_right_req_o, 
  output [`E203_XLEN-1:0] br_shift_op1_o,
  output [4:0] br_shift_op2_o,
  input  [`E203_XLEN-1:0] br_shift_res_i,

  
  
  
  
  output wext_lo_shift_right_req_o, 
  output [`E203_XLEN-1:0] wext_lo_shift_op1_o,
  output [4:0] wext_lo_shift_op2_o,
  input  [`E203_XLEN-1:0] wext_lo_shift_res_i,

  
  
  
  
  output wext_hi_shift_left_req_o, 
  output [`E203_XLEN-1:0] wext_hi_shift_op1_o,
  output [`E203_XLEN-1:0] wext_hi_shift_op2_o,
  input  [`E203_XLEN-1:0] wext_hi_shift_res_i,

  
  
  
  output [`E203_XLEN-1:0] dsp_o_wbck_wdat,
  output dsp_o_wbck_err,
    
  output dsp_o_wbck_ov,
    
  input  dsp_misc_op_i, 

  
  
  input  clk,
  input  rst_n 

  );

wire sclip8     = dsp_i_info[`E203_DECINFO_DSP_SCLIP8];
wire uclip8     = dsp_i_info[`E203_DECINFO_DSP_UCLIP8];
wire sclip16    = dsp_i_info[`E203_DECINFO_DSP_SCLIP16];
wire uclip16    = dsp_i_info[`E203_DECINFO_DSP_UCLIP16];
wire sclip32    = dsp_i_info[`E203_DECINFO_DSP_SCLIP32];
wire uclip32    = dsp_i_info[`E203_DECINFO_DSP_UCLIP32];
wire [4:0] clip_imm = dsp_i_info[`E203_DECINFO_DSP_IMM];

wire [4:0] onehot_id;
wire [`E203_XLEN-1:0] clip32_onehot;

assign onehot_id[2:0] = clip_imm[2:0];
assign onehot_id[4:3] = {
                         ({2{(sclip8 | uclip8)}} & {2'b0}) |
                         ({2{(sclip16 | uclip16)}} & {1'b0,clip_imm[3]}) |
                         ({2{(sclip32 | uclip32)}} & {clip_imm[4:3]})
						};

genvar i;
generate 
	for(i=0; i<`E203_XLEN; i=i+1) begin: gen_onehot
		assign clip32_onehot[i] = (onehot_id==i);    
	end
endgenerate

wire [`E203_XLEN-1:0] clip32_cmp_t;

wire [`E203_XLEN-1:0] clip32_cmp_b;

generate 
	for(i=0; i<`E203_XLEN; i=i+1) begin: gen_clip32_b
		assign clip32_cmp_b[i] = |clip32_onehot[i:0];
	end
endgenerate

assign clip32_cmp_t = ~clip32_cmp_b;
wire [`E203_XLEN-1:0] clip_op1 = dsp_i_rs1;

wire [3:0] clip8_t_ov;
wire [3:0] clip8_b_ov;

wire [1:0]  clip16_t_ov;
wire [1:0]  clip16_b_ov;

wire [`E203_XLEN-1:0] clip32_op2_t = clip32_cmp_t;
wire [`E203_XLEN-1:0] clip32_op2_b = clip32_cmp_b;
wire clip32_t_ov;
wire clip32_b_ov;

e203_dynamic_sat e203_dynamic_sat_u
(
	.dsat_op_i      ( clip_op1      ),     
	.dsat32_cmp_t   ( clip32_op2_t  ),     
	.dsat32_cmp_b   ( clip32_op2_b  ),     
	.dsat32_t_ov    ( clip32_t_ov   ),     
	.dsat32_b_ov    ( clip32_b_ov   ),     
	.dsat16_t_ov    ( clip16_t_ov   ),     
	.dsat16_b_ov    ( clip16_b_ov   ),     
	.dsat8_t_ov     ( clip8_t_ov    ),     
	.dsat8_b_ov     ( clip8_b_ov    )      
);

wire clip32_op1_n = clip_op1[`E203_XLEN-1];
wire [1:0] clip16_op1_n = {clip_op1[`E203_XLEN-1], clip_op1[15]};
wire [3:0] clip8_op1_n = {clip_op1[`E203_XLEN-1], clip_op1[23], clip_op1[15],clip_op1[7]};
wire clip32_wdat_rs1;
wire clip32_wdat_top;
wire clip32_wdat_buttom;
wire clip32_wdat_zero;
wire [`E203_XLEN-1:0] clip32_o_wbck_wdat;
wire [1:0] clip16_wdat_rs1;
wire [1:0] clip16_wdat_top;
wire [1:0] clip16_wdat_buttom;
wire [1:0] clip16_wdat_zero;
wire [15:0] clip16_o_wbck_wdat[1:0];
wire [3:0] clip8_wdat_rs1;
wire [3:0] clip8_wdat_top;
wire [3:0] clip8_wdat_buttom;
wire [3:0] clip8_wdat_zero;
wire [7:0] clip8_o_wbck_wdat[3:0];

assign clip32_wdat_rs1     = (uclip32 & ~clip32_op1_n & ~clip32_t_ov) | 
                             (sclip32 & ~clip32_op1_n & ~clip32_t_ov) |
                             (sclip32 & clip32_op1_n  & ~clip32_b_ov);

assign clip32_wdat_top     = (uclip32 & ~clip32_op1_n & clip32_t_ov) |
                             (sclip32 & ~clip32_op1_n & clip32_t_ov); 

assign clip32_wdat_buttom  = (sclip32 & clip32_op1_n & clip32_b_ov);

assign clip32_wdat_zero    = (uclip32 & clip32_op1_n);

assign clip32_o_wbck_wdat  = clip32_wdat_rs1 ? clip_op1 :
                             clip32_wdat_top ? clip32_cmp_t :
                             clip32_wdat_buttom ? clip32_cmp_b : {(`E203_XLEN){1'b0}};

wire [15:0] clip16_i_rs1[1:0];
assign clip16_i_rs1[0] = clip_op1[15:0];
assign clip16_i_rs1[1] = clip_op1[31:16];

generate 
	for(i=0; i<2; i=i+1) begin: gen_clip16_wdat
		assign clip16_wdat_rs1[i]  = (uclip16 & ~clip16_op1_n[i] & ~clip16_t_ov[i]) | 
		                             (sclip16 & ~clip16_op1_n[i] & ~clip16_t_ov[i]) |
		                             (sclip16 & clip16_op1_n[i]  & ~clip16_b_ov[i]);
 
		assign clip16_wdat_top[i]  = (uclip16 & ~clip16_op1_n[i] & clip16_t_ov[i]) |
		                             (sclip16 & ~clip16_op1_n[i] & clip16_t_ov[i]); 

		assign clip16_wdat_buttom[i]= (sclip16 & clip16_op1_n[i] & clip16_b_ov[i]);

		assign clip16_wdat_zero[i]  = (uclip16 & clip16_op1_n[i]);

		assign clip16_o_wbck_wdat[i]= clip16_wdat_rs1[i] ? clip16_i_rs1[i] :
		                              clip16_wdat_top[i] ? clip32_cmp_t[15:0] :
		                              clip16_wdat_buttom[i] ? clip32_cmp_b[15:0] : 16'h0;
	end

endgenerate

wire [7:0] clip8_i_rs1[3:0];
assign clip8_i_rs1[0] = clip_op1[7:0];
assign clip8_i_rs1[1] = clip_op1[15:8];
assign clip8_i_rs1[2] = clip_op1[23:16];
assign clip8_i_rs1[3] = clip_op1[31:24];

generate 
	for(i=0; i<4; i=i+1) begin: gen_clip8_wdat
		assign clip8_wdat_rs1[i]   = (uclip8 & ~clip8_op1_n[i] & ~clip8_t_ov[i]) | 
		                             (sclip8 & ~clip8_op1_n[i] & ~clip8_t_ov[i]) |
		                             (sclip8 & clip8_op1_n[i]  & ~clip8_b_ov[i]);
 
		assign clip8_wdat_top[i]   = (uclip8 & ~clip8_op1_n[i] & clip8_t_ov[i]) |
		                             (sclip8 & ~clip8_op1_n[i] & clip8_t_ov[i]); 

		assign clip8_wdat_buttom[i]= (sclip8 & clip8_op1_n[i] & clip8_b_ov[i]);

		assign clip8_wdat_zero[i]  = (uclip8 & clip8_op1_n[i]);

		assign clip8_o_wbck_wdat[i]= clip8_wdat_rs1[i] ? clip8_i_rs1[i] :
		                             clip8_wdat_top[i] ? clip32_cmp_t[7:0] :
		                             clip8_wdat_buttom[i] ? clip32_cmp_b[7:0] : 8'h0;
	end

endgenerate

wire clip32 = (uclip32 | sclip32);
wire clip16 = (uclip16 | sclip16);
wire clip8  = (uclip8  | sclip8 );

wire [`E203_XLEN-1:0] clip_o_wbck_wdat;
assign clip_o_wbck_wdat = clip32 ? clip32_o_wbck_wdat :
                          clip16 ? {clip16_o_wbck_wdat[1],clip16_o_wbck_wdat[0]} :
                          {clip8_o_wbck_wdat[3],clip8_o_wbck_wdat[2],clip8_o_wbck_wdat[1],clip8_o_wbck_wdat[0]};

wire clip_o_cmt_ov;
assign clip_o_cmt_ov    = clip32 ? ~clip32_wdat_rs1 :
                          clip16 ? ~(&clip16_wdat_rs1[1:0]) :
						  clip8 ? ~(&clip8_wdat_rs1[3:0]) :
						  1'b0;

wire dsp_o_cmt_clip = sclip8 | uclip8 | sclip16 | uclip16 | sclip32 | uclip32;

wire sunpkd810 = dsp_i_info[`E203_DECINFO_DSP_SUNPKD810];
wire sunpkd820 = dsp_i_info[`E203_DECINFO_DSP_SUNPKD820];
wire sunpkd830 = dsp_i_info[`E203_DECINFO_DSP_SUNPKD830];
wire sunpkd831 = dsp_i_info[`E203_DECINFO_DSP_SUNPKD831];
wire sunpkd832 = dsp_i_info[`E203_DECINFO_DSP_SUNPKD832];
wire zunpkd810 = dsp_i_info[`E203_DECINFO_DSP_ZUNPKD810];
wire zunpkd820 = dsp_i_info[`E203_DECINFO_DSP_ZUNPKD820];
wire zunpkd830 = dsp_i_info[`E203_DECINFO_DSP_ZUNPKD830];
wire zunpkd831 = dsp_i_info[`E203_DECINFO_DSP_ZUNPKD831];
wire zunpkd832 = dsp_i_info[`E203_DECINFO_DSP_ZUNPKD832];

wire [15:0] se_byte0 = {{8{dsp_i_rs1[7]}}, dsp_i_rs1[7:0]};
wire [15:0] se_byte1 = {{8{dsp_i_rs1[15]}}, dsp_i_rs1[15:8]};
wire [15:0] se_byte2 = {{8{dsp_i_rs1[23]}}, dsp_i_rs1[23:16]};
wire [15:0] se_byte3 = {{8{dsp_i_rs1[31]}}, dsp_i_rs1[31:24]};

wire [15:0] ze_byte0 = {8'h0, dsp_i_rs1[7:0]};
wire [15:0] ze_byte1 = {8'h0, dsp_i_rs1[15:8]};
wire [15:0] ze_byte2 = {8'h0, dsp_i_rs1[23:16]};
wire [15:0] ze_byte3 = {8'h0, dsp_i_rs1[31:24]};

wire [`E203_XLEN-1:0] unpack_o_wbck_wdat;
assign unpack_o_wbck_wdat = ({`E203_XLEN{sunpkd810}} & {se_byte1,se_byte0}) |
                            ({`E203_XLEN{sunpkd820}} & {se_byte2,se_byte0}) |
                            ({`E203_XLEN{sunpkd830}} & {se_byte3,se_byte0}) |
                            ({`E203_XLEN{sunpkd831}} & {se_byte3,se_byte1}) |
                            ({`E203_XLEN{sunpkd832}} & {se_byte3,se_byte2}) |
                            ({`E203_XLEN{zunpkd810}} & {ze_byte1,ze_byte0}) |
                            ({`E203_XLEN{zunpkd820}} & {ze_byte2,ze_byte0}) |
                            ({`E203_XLEN{zunpkd830}} & {ze_byte3,ze_byte0}) |
                            ({`E203_XLEN{zunpkd831}} & {ze_byte3,ze_byte1}) |
                            ({`E203_XLEN{zunpkd832}} & {ze_byte3,ze_byte2}) ;

wire dsp_o_cmt_unpack = 
                          sunpkd810 |
                          sunpkd820 |
                          sunpkd830 |
                          sunpkd831 |
                          sunpkd832 |
                          zunpkd810 |
                          zunpkd820 |
                          zunpkd830 |
                          zunpkd831 |
                          zunpkd832;

wire packbb16 = dsp_i_info[`E203_DECINFO_DSP_PKBB16];
wire packbt16 = dsp_i_info[`E203_DECINFO_DSP_PKBT16];
wire packtb16 = dsp_i_info[`E203_DECINFO_DSP_PKTB16];
wire packtt16 = dsp_i_info[`E203_DECINFO_DSP_PKTT16];

wire [`E203_XLEN-1:0] pack_o_wbck_wdat;
assign pack_o_wbck_wdat = ({`E203_XLEN{packbb16}} & {dsp_i_rs1[15:0],dsp_i_rs2[15:0]})  |
                          ({`E203_XLEN{packbt16}} & {dsp_i_rs1[15:0],dsp_i_rs2[31:16]}) |
                          ({`E203_XLEN{packtb16}} & {dsp_i_rs1[31:16],dsp_i_rs2[15:0]}) |
                          ({`E203_XLEN{packtt16}} & {dsp_i_rs1[31:16],dsp_i_rs2[31:16]});

wire dsp_o_cmt_pack = 
                        packbb16 |
                        packbt16 |
                        packtb16 |
                        packtt16;

wire clrs8  = dsp_i_info[`E203_DECINFO_DSP_CLRS8];
wire clz8   = dsp_i_info[`E203_DECINFO_DSP_CRZ8];
wire clo8   = dsp_i_info[`E203_DECINFO_DSP_CLO8];
wire clrs16 = dsp_i_info[`E203_DECINFO_DSP_CLRS16];
wire clz16  = dsp_i_info[`E203_DECINFO_DSP_CLZ16];
wire clo16  = dsp_i_info[`E203_DECINFO_DSP_CLO16];
wire clrs32 = dsp_i_info[`E203_DECINFO_DSP_CLRS32];
wire clz32  = dsp_i_info[`E203_DECINFO_DSP_CLZ32];
wire clo32  = dsp_i_info[`E203_DECINFO_DSP_CLO32];

wire [`E203_XLEN-1:0] cl32_rs1;
wire [`E203_XLEN-1:0] cl32_rs1_real;
wire [`E203_XLEN-1:0] cl32_xor;
wire [`E203_XLEN-1:0] cl32_or;
wire [`E203_XLEN:0] cl33_or;
wire [`E203_XLEN-1:0] cl32_onehot;

wire rs1_bit15 = clz16 ? 1'b1 : clrs16 ? ~dsp_i_rs1[`E203_XLEN-1] : 1'b0; 
wire rs1_bit23 = clz8 ? 1'b1 : clrs8 ? ~dsp_i_rs1[`E203_XLEN-1] : 1'b0;   

wire cl8 = clrs8 | clz8 | clo8;
wire cl16 = clrs16 | clz16 | clo16;
wire cl32 = clrs32 | clz32 | clo32;
wire clrs_16_8 = clrs8 | clrs16;
wire clrs = clrs_16_8 | clrs32;

assign cl32_rs1 =   ({`E203_XLEN{cl8 }} & {dsp_i_rs1[`E203_XLEN-1:24], rs1_bit23, dsp_i_rs1[22:0]})
                  | ({`E203_XLEN{cl16}} & {dsp_i_rs1[`E203_XLEN-1:16], rs1_bit15,  dsp_i_rs1[14:0]})
                  | ({`E203_XLEN{cl32}} & dsp_i_rs1);

assign cl32_rs1_real = clrs ? {cl32_rs1[`E203_XLEN-2:0], ~cl32_rs1[`E203_XLEN-1]} : cl32_rs1;

wire cl32_cmp_bit = (clz32 | clz16 | clz8) ? 1'b0 : (clrs32 | clrs16 | clrs8) ? dsp_i_rs1[`E203_XLEN-1] : 1'b1;
assign cl33_or = {cl32_or,1'b1};

generate 
	for(i=0; i<`E203_XLEN; i=i+1) begin: cl_32
		assign cl32_xor[i] = cl32_cmp_bit ^ cl32_rs1_real[i];
		assign cl32_or[i] = |cl32_xor[`E203_XLEN-1:i];
		assign cl32_onehot[i] = ~cl33_or[i+1] & cl33_or[i];
	end
endgenerate


wire [5:0] onehot32_cnt;

e203_onehot32_2bin cl_onehot32_2bin_u
(
	.onehot_i  ( cl32_onehot  ),
	.bin_o     ( onehot32_cnt ) 
);

wire rs1_bit7;
wire [16:0] cl17_or;
wire [15:0] cl16_half0_rs1;
wire [15:0] cl16_half0_rs1_real;
wire [15:0] cl16_or;
wire [15:0] cl16_xor;
wire [15:0] cl16_onehot;

assign rs1_bit7 = clz8 ? 1'b1 : clrs8 ? ~dsp_i_rs1[15] : 1'b0;   

assign cl16_half0_rs1 =   ({16{cl8 }} & {dsp_i_rs1[15:8], rs1_bit7, dsp_i_rs1[6:0]})
                        | ({16{cl16}} & dsp_i_rs1[15:0]);

assign cl16_half0_rs1_real = clrs_16_8 ? {cl16_half0_rs1[14:0], ~cl16_half0_rs1[15]} : cl16_half0_rs1;

wire cl16_cmp_bit = (clz16 | clz8) ? 1'b0 : clrs_16_8 ? dsp_i_rs1[15] : 1'b1;
assign cl17_or = {cl16_or,1'b1};

generate 
	for(i=0; i<16; i=i+1) begin: cl_16
		assign cl16_xor[i] = cl16_cmp_bit ^ cl16_half0_rs1_real[i];
		assign cl16_or[i] = |cl16_xor[15:i];
		assign cl16_onehot[i] = ~cl17_or[i+1] & cl17_or[i];
	end
endgenerate


wire [4:0] onehot16_cnt;

e203_onehot16_2bin cl_onehot16_2bin_u
(
	.onehot_i  ( cl16_onehot  ),
	.bin_o     ( onehot16_cnt ) 
);

wire [8:0] cl9_byte0_or;
wire [7:0] cl8_byte0_rs1;
wire [7:0] cl8_byte0_rs1_real;
wire [7:0] cl8_byte0_or;
wire [7:0] cl8_byte0_xor;
wire [7:0] cl8_byte0_onehot;

assign cl8_byte0_rs1 = dsp_i_rs1[7:0];
assign cl8_byte0_rs1_real = clrs8 ? {cl8_byte0_rs1[6:0], ~cl8_byte0_rs1[7]} : cl8_byte0_rs1;

wire cl8_byte0_cmp_bit = clz8 ? 1'b0 : clrs8 ? dsp_i_rs1[7] : 1'b1;
assign cl9_byte0_or = {cl8_byte0_or,1'b1};

generate 
	for(i=0; i<8; i=i+1) begin: cl8_byte0
		assign cl8_byte0_xor[i] = cl8_byte0_cmp_bit ^ cl8_byte0_rs1_real[i];
		assign cl8_byte0_or[i] = |cl8_byte0_xor[7:i];
		assign cl8_byte0_onehot[i] = ~cl9_byte0_or[i+1] & cl9_byte0_or[i];
	end
endgenerate


wire [3:0] onehot8_byte0_cnt;

e203_onehot8_2bin cl_onehot8_2bin_u0
(
	.onehot_i  ( cl8_byte0_onehot  ),
	.bin_o     ( onehot8_byte0_cnt ) 
);

wire [8:0] cl9_byte2_or;
wire [7:0] cl8_byte2_rs1;
wire [7:0] cl8_byte2_rs1_real;
wire [7:0] cl8_byte2_or;
wire [7:0] cl8_byte2_xor;
wire [7:0] cl8_byte2_onehot;

assign cl8_byte2_rs1 = dsp_i_rs1[23:16];
assign cl8_byte2_rs1_real = clrs8 ? {cl8_byte2_rs1[6:0], ~cl8_byte2_rs1[7]} : cl8_byte2_rs1;

wire cl8_byte2_cmp_bit = clz8 ? 1'b0 : clrs8 ? dsp_i_rs1[23] : 1'b1;
assign cl9_byte2_or = {cl8_byte2_or,1'b1};

generate 
	for(i=0; i<8; i=i+1) begin: cl8_byte2
		assign cl8_byte2_xor[i] = cl8_byte2_cmp_bit ^ cl8_byte2_rs1_real[i];
		assign cl8_byte2_or[i] = |cl8_byte2_xor[7:i];
		assign cl8_byte2_onehot[i] = ~cl9_byte2_or[i+1] & cl9_byte2_or[i];
	end
endgenerate


wire [3:0] onehot8_byte2_cnt;

e203_onehot8_2bin cl_onehot8_2bin_u2
(
	.onehot_i  ( cl8_byte2_onehot  ),
	.bin_o     ( onehot8_byte2_cnt ) 
);

wire [`E203_XLEN-1:0] cl_o_wbck_wdat;
assign cl_o_wbck_wdat = cl8 ?  {2'b0, onehot32_cnt, 4'b0, onehot8_byte2_cnt, 3'b0, onehot16_cnt, 4'b0, onehot8_byte0_cnt} :
                        cl16 ? {10'b0, onehot32_cnt, 11'b0, onehot16_cnt} :
                        {26'b0,onehot32_cnt};

wire dsp_o_cmt_cl = 
                      clrs8  | 
                      clz8   | 
                      clo8   | 
                      clrs16 | 
                      clz16  | 
                      clo16  | 
                      clrs32 | 
                      clz32  | 
                      clo32  ;


wire bitrev  = dsp_i_info[`E203_DECINFO_DSP_BITREV];
wire bitrevi = dsp_i_info[`E203_DECINFO_DSP_BITREVI];
wire [4:0] br_imm = dsp_i_info[`E203_DECINFO_DSP_IMM];
wire [4:0] br_rs2 = dsp_i_rs2[4:0];

wire [4:0] br_op2 = ({5{bitrev}} & br_rs2) |
                    ({5{bitrevi}} & br_imm);


wire [`E203_XLEN-1:0] br_shift_op1;
generate 
	for(i=0; i<`E203_XLEN; i=i+1) begin: gen_br_shift_op1
		assign br_shift_op1[i] = dsp_i_rs1[`E203_XLEN-1-i];
	end
endgenerate

wire dsp_o_cmt_br;
assign br_shift_right_req_o = dsp_o_cmt_br;
assign br_shift_op1_o = br_shift_op1;
assign br_shift_op2_o = ~br_op2;

wire [`E203_XLEN-1:0] br_o_wbck_wdat;
assign br_o_wbck_wdat = br_shift_res_i;
assign dsp_o_cmt_br = bitrevi | bitrev;

wire wext  = dsp_i_info[`E203_DECINFO_DSP_WEXT];
wire wexti = dsp_i_info[`E203_DECINFO_DSP_WEXTI];
wire [4:0] wext_imm = dsp_i_info[`E203_DECINFO_DSP_IMM];
wire dsp_o_cmt_wext;

wire [4:0] wext_shift_op2 = ({5{wext}} & dsp_i_rs2[4:0]) |
                            ({5{wexti}} & wext_imm[4:0]);
assign wext_lo_shift_right_req_o = dsp_o_cmt_wext;
assign wext_lo_shift_op1_o       = dsp_i_rs1;
assign wext_lo_shift_op2_o       = wext_shift_op2;

assign wext_hi_shift_left_req_o = dsp_o_cmt_wext;
assign wext_hi_shift_op1_o = {dsp_i_rs1_64[`E203_XLEN-2:0], 1'b0};    
assign wext_hi_shift_op2_o = {27'b0, ~wext_shift_op2};


wire [`E203_XLEN-1:0] we_o_wbck_wdat;
assign we_o_wbck_wdat = wext_hi_shift_res_i | wext_lo_shift_res_i;
assign dsp_o_cmt_wext = wext | wexti;

wire bpick = dsp_i_info [`E203_DECINFO_DSP_BPICK];

wire [`E203_XLEN-1:0] bp_o_wbck_wdat;
assign bp_o_wbck_wdat = (dsp_i_rc & dsp_i_rs1) | (~dsp_i_rc & dsp_i_rs2);

wire dsp_o_cmt_bp = bpick;

wire insb = dsp_i_info[`E203_DECINFO_DSP_INSB];
wire [4:0] insb_imm = dsp_i_info [`E203_DECINFO_DSP_IMM];
wire insb_byte0 = (insb_imm[1:0] == 2'b00) & insb;
wire insb_byte1 = (insb_imm[1:0] == 2'b01) & insb;
wire insb_byte2 = (insb_imm[1:0] == 2'b10) & insb;
wire insb_byte3 = (insb_imm[1:0] == 2'b11) & insb;
wire [`E203_XLEN-1:0] insb_mask = {{8{insb_byte3}}, {8{insb_byte2}}, {8{insb_byte1}}, {8{insb_byte0}}};
wire [`E203_XLEN-1:0] insb_byte_ext = {4{dsp_i_rs1[7:0]}};

wire [`E203_XLEN-1:0] insb_o_wbck_wdat;
assign insb_o_wbck_wdat = (insb_mask & insb_byte_ext) | (~insb_mask & dsp_i_rd);
wire dsp_o_cmt_insb = insb;

wire swap8  = dsp_i_info[`E203_DECINFO_DSP_SWAP8];
wire swap16 = dsp_i_info[`E203_DECINFO_DSP_SWAP16];

wire [`E203_XLEN-1:0] swap_o_wbck_wdat;
assign swap_o_wbck_wdat = ({`E203_XLEN{swap8}} & {dsp_i_rs1[23:16],dsp_i_rs1[31:24],dsp_i_rs1[7:0],dsp_i_rs1[15:8]}) |
                          ({`E203_XLEN{swap16}} & {dsp_i_rs1[15:0],dsp_i_rs1[31:16]});

wire dsp_o_cmt_swap = swap8 | swap16;

assign dsp_o_wbck_err = 1'b0;

assign dsp_o_wbck_wdat = ({`E203_XLEN{dsp_o_cmt_clip}}   & clip_o_wbck_wdat   ) |
                         ({`E203_XLEN{dsp_o_cmt_unpack}} & unpack_o_wbck_wdat ) | 
                         ({`E203_XLEN{dsp_o_cmt_pack}}   & pack_o_wbck_wdat   ) | 
                         ({`E203_XLEN{dsp_o_cmt_cl}}     & cl_o_wbck_wdat     ) | 
                         ({`E203_XLEN{dsp_o_cmt_br}}     & br_o_wbck_wdat     ) | 
                         ({`E203_XLEN{dsp_o_cmt_wext}}   & we_o_wbck_wdat     ) | 
                         ({`E203_XLEN{dsp_o_cmt_bp}}     & bp_o_wbck_wdat     ) | 
                         ({`E203_XLEN{dsp_o_cmt_insb}}   & insb_o_wbck_wdat   ) |
                         ({`E203_XLEN{dsp_o_cmt_swap}}   & swap_o_wbck_wdat   ) ;

assign dsp_o_wbck_ov = dsp_o_cmt_clip & clip_o_cmt_ov;    



`ifndef FPGA_SOURCE
`ifndef SYNTHESIS
`ifndef DISABLE_SV_ASSERTION
wire [`E203_XLEN*2-1:0] wext_shift_op1 = {dsp_i_rs1_64,dsp_i_rs1};

wire [`E203_XLEN*2-1:0] wext_shift_res = (wext_shift_op1) >> wext_shift_op2; 
  
  
    CHECK_WEXT_OP_CORRECT:
      assert property (@(negedge clk) disable iff (~rst_n)  ((dsp_o_cmt_wext ? (wext_shift_res[`E203_XLEN-1:0] == we_o_wbck_wdat) : 1'b1)))
      else $fatal ("\n Error: wext instrutions' results are not the same as the golden model. \n");

`endif
`endif
`endif

endmodule
