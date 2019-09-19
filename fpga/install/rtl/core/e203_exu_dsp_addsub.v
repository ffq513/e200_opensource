
                                                                        
`include "e203_defines.v"

module e203_exu_dsp_addsub(

  
  
  
  input  [`E203_XLEN-1:0] dsp_addsub_rs1_i  ,
  input  [`E203_XLEN-1:0] dsp_addsub_rs2_i  ,
  input  [`E203_XLEN-1:0] dsp_addsub_rs1_1_i,
  input  [`E203_XLEN-1:0] dsp_addsub_rs2_1_i,
  input  [`E203_DECINFO_DSP_WIDTH-1:0] dsp_addsub_info_i,

  
  
  
  
  output [`E203_XLEN+2:0] dsp_addsub_pbs_o,
  output [`E203_XLEN-1:0] dsp_addsub_wbck_wdat_o,
  output [`E203_XLEN-1:0] dsp_addsub_wbck_wdat_1_o,
  output dsp_addsub_ov_wbck_o, 


  
  
  
  
  
  output [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_addsub_big_op1_o   ,
  output [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_addsub_big_op2_o   ,
  output [`E203_DSP_LITADDER_WIDTH-1:0] dsp_addsub_little_op1_o,
  output [`E203_DSP_LITADDER_WIDTH-1:0] dsp_addsub_little_op2_o,
  output dsp_adder_req_o,
  output dsp_sub_en_o,

  input  [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_addsub_big_res_i   ,
  input  [`E203_DSP_LITADDER_WIDTH-1:0] dsp_addsub_little_res_i 

  );


  wire op_add8     = dsp_addsub_info_i[`E203_DECINFO_DSP_ADD8   ];
  wire op_radd8    = dsp_addsub_info_i[`E203_DECINFO_DSP_RADD8  ];
  wire op_uradd8   = dsp_addsub_info_i[`E203_DECINFO_DSP_URADD8 ];
  wire op_kadd8    = dsp_addsub_info_i[`E203_DECINFO_DSP_KADD8  ];
  wire op_ukadd8   = dsp_addsub_info_i[`E203_DECINFO_DSP_UKADD8 ];
  wire op_sub8     = dsp_addsub_info_i[`E203_DECINFO_DSP_SUB8   ];
  wire op_rsub8    = dsp_addsub_info_i[`E203_DECINFO_DSP_RSUB8  ];
  wire op_ursub8   = dsp_addsub_info_i[`E203_DECINFO_DSP_URSUB8 ];
  wire op_ksub8    = dsp_addsub_info_i[`E203_DECINFO_DSP_KSUB8  ];
  wire op_uksub8   = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSUB8 ];
  wire op_cmpeq8   = dsp_addsub_info_i[`E203_DECINFO_DSP_CMPEQ8 ];
  wire op_scmplt8  = dsp_addsub_info_i[`E203_DECINFO_DSP_SCMPLT8];
  wire op_scmple8  = dsp_addsub_info_i[`E203_DECINFO_DSP_SCMPLE8];
  wire op_ucmplt8  = dsp_addsub_info_i[`E203_DECINFO_DSP_UCMPLT8];
  wire op_ucmple8  = dsp_addsub_info_i[`E203_DECINFO_DSP_UCMPLE8];
  wire op_smax8    = dsp_addsub_info_i[`E203_DECINFO_DSP_SMAX8  ];
  wire op_smin8    = dsp_addsub_info_i[`E203_DECINFO_DSP_SMIN8  ];
  wire op_umax8    = dsp_addsub_info_i[`E203_DECINFO_DSP_UMAX8  ];
  wire op_umin8    = dsp_addsub_info_i[`E203_DECINFO_DSP_UMIN8  ];
  wire op_kabs8    = dsp_addsub_info_i[`E203_DECINFO_DSP_KABS8  ];
  wire op_add16    = dsp_addsub_info_i[`E203_DECINFO_DSP_ADD16   ];
  wire op_radd16   = dsp_addsub_info_i[`E203_DECINFO_DSP_RADD16  ];
  wire op_uradd16  = dsp_addsub_info_i[`E203_DECINFO_DSP_URADD16 ];
  wire op_kadd16   = dsp_addsub_info_i[`E203_DECINFO_DSP_KADD16  ];
  wire op_ukadd16  = dsp_addsub_info_i[`E203_DECINFO_DSP_UKADD16 ];
  wire op_sub16    = dsp_addsub_info_i[`E203_DECINFO_DSP_SUB16   ];
  wire op_rsub16   = dsp_addsub_info_i[`E203_DECINFO_DSP_RSUB16  ];
  wire op_ursub16  = dsp_addsub_info_i[`E203_DECINFO_DSP_URSUB16 ];
  wire op_ksub16   = dsp_addsub_info_i[`E203_DECINFO_DSP_KSUB16  ];
  wire op_uksub16  = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSUB16 ];
  wire op_cras16   = dsp_addsub_info_i[`E203_DECINFO_DSP_CRAS16   ];
  wire op_rcras16  = dsp_addsub_info_i[`E203_DECINFO_DSP_RCRAS16  ];
  wire op_urcras16 = dsp_addsub_info_i[`E203_DECINFO_DSP_URCRAS16 ];
  wire op_kcras16  = dsp_addsub_info_i[`E203_DECINFO_DSP_KCRAS16  ];
  wire op_ukcras16 = dsp_addsub_info_i[`E203_DECINFO_DSP_UKCRAS16];
  wire op_crsa16   = dsp_addsub_info_i[`E203_DECINFO_DSP_CRSA16  ];
  wire op_rcrsa16  = dsp_addsub_info_i[`E203_DECINFO_DSP_RCRSA16 ];
  wire op_urcrsa16 = dsp_addsub_info_i[`E203_DECINFO_DSP_URCRSA16];
  wire op_kcrsa16  = dsp_addsub_info_i[`E203_DECINFO_DSP_KCRSA16 ];
  wire op_ukcrsa16 = dsp_addsub_info_i[`E203_DECINFO_DSP_UKCRSA16];
  wire op_stas16   = dsp_addsub_info_i[`E203_DECINFO_DSP_STAS16  ];
  wire op_rstas16  = dsp_addsub_info_i[`E203_DECINFO_DSP_RSTAS16 ];
  wire op_urstas16 = dsp_addsub_info_i[`E203_DECINFO_DSP_URSTAS16];
  wire op_kstas16  = dsp_addsub_info_i[`E203_DECINFO_DSP_KSTAS16 ];
  wire op_ukstas16 = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSTAS16];
  wire op_stsa16   = dsp_addsub_info_i[`E203_DECINFO_DSP_STSA16  ];
  wire op_rstsa16  = dsp_addsub_info_i[`E203_DECINFO_DSP_RSTSA16 ];
  wire op_urstsa16 = dsp_addsub_info_i[`E203_DECINFO_DSP_URSTSA16];
  wire op_kstsa16  = dsp_addsub_info_i[`E203_DECINFO_DSP_KSTSA16 ];
  wire op_ukstsa16 = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSTSA16];
  wire op_cmpeq16  = dsp_addsub_info_i[`E203_DECINFO_DSP_CMPEQ16 ];
  wire op_scmplt16 = dsp_addsub_info_i[`E203_DECINFO_DSP_SCMPLT16];
  wire op_scmple16 = dsp_addsub_info_i[`E203_DECINFO_DSP_SCMPLE16];
  wire op_ucmplt16 = dsp_addsub_info_i[`E203_DECINFO_DSP_UCMPLT16];
  wire op_ucmple16 = dsp_addsub_info_i[`E203_DECINFO_DSP_UCMPLE16];
  wire op_smax16   = dsp_addsub_info_i[`E203_DECINFO_DSP_SMAX16  ];
  wire op_smin16   = dsp_addsub_info_i[`E203_DECINFO_DSP_SMIN16  ];
  wire op_umax16   = dsp_addsub_info_i[`E203_DECINFO_DSP_UMAX16  ];
  wire op_umin16   = dsp_addsub_info_i[`E203_DECINFO_DSP_UMIN16  ];
  wire op_kabs16   = dsp_addsub_info_i[`E203_DECINFO_DSP_KABS16  ];
  wire op_kaddh    = dsp_addsub_info_i[`E203_DECINFO_DSP_KADDH   ];
  wire op_ukaddh   = dsp_addsub_info_i[`E203_DECINFO_DSP_UKADDH  ];
  wire op_ksubh    = dsp_addsub_info_i[`E203_DECINFO_DSP_KSUBH   ];
  wire op_uksubh   = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSUBH  ];
  wire op_kaddw    = dsp_addsub_info_i[`E203_DECINFO_DSP_KADDW   ];
  wire op_ukaddw   = dsp_addsub_info_i[`E203_DECINFO_DSP_UKADDW  ];
  wire op_raddw    = dsp_addsub_info_i[`E203_DECINFO_DSP_RADDW   ];
  wire op_uraddw   = dsp_addsub_info_i[`E203_DECINFO_DSP_URADDW  ];
  wire op_ksubw    = dsp_addsub_info_i[`E203_DECINFO_DSP_KSUBW   ];
  wire op_uksubw   = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSUBW  ];
  wire op_rsubw    = dsp_addsub_info_i[`E203_DECINFO_DSP_RSUBW   ];
  wire op_ursubw   = dsp_addsub_info_i[`E203_DECINFO_DSP_URSUBW  ];
  wire op_maxw     = dsp_addsub_info_i[`E203_DECINFO_DSP_MAXW    ];
  wire op_minw     = dsp_addsub_info_i[`E203_DECINFO_DSP_MINW    ];
  wire op_kabsw    = dsp_addsub_info_i[`E203_DECINFO_DSP_KABSW   ];
  wire op_pbsad    = dsp_addsub_info_i[`E203_DECINFO_DSP_PBSAD   ];
  wire op_pbsada   = dsp_addsub_info_i[`E203_DECINFO_DSP_PBSADA  ];
  wire op_add64    = dsp_addsub_info_i[`E203_DECINFO_DSP_ADD64   ];
  wire op_radd64   = dsp_addsub_info_i[`E203_DECINFO_DSP_RADD64  ];
  wire op_uradd64  = dsp_addsub_info_i[`E203_DECINFO_DSP_URADD64 ];
  wire op_kadd64   = dsp_addsub_info_i[`E203_DECINFO_DSP_KADD64  ];
  wire op_ukadd64  = dsp_addsub_info_i[`E203_DECINFO_DSP_UKADD64 ];
  wire op_sub64    = dsp_addsub_info_i[`E203_DECINFO_DSP_SUB64   ];
  wire op_rsub64   = dsp_addsub_info_i[`E203_DECINFO_DSP_RSUB64  ];
  wire op_ursub64  = dsp_addsub_info_i[`E203_DECINFO_DSP_URSUB64 ];
  wire op_ksub64   = dsp_addsub_info_i[`E203_DECINFO_DSP_KSUB64  ];
  wire op_uksub64  = dsp_addsub_info_i[`E203_DECINFO_DSP_UKSUB64 ];
  wire op_ave      = dsp_addsub_info_i[`E203_DECINFO_DSP_AVE     ];

  wire op_addsub8   = op_add8   | op_sub8; 
  wire op_raddsub8  = op_radd8  | op_rsub8 ; 
  wire op_uraddsub8 = op_uradd8 | op_ursub8; 
  wire op_kaddsub8  = op_kadd8  | op_ksub8 ; 
  wire op_ukaddsub8 = op_ukadd8 | op_uksub8; 

  wire op_addsub16   = op_add16   | op_sub16   | op_cras16  | op_crsa16   | op_stas16  | op_stsa16  ; 
  wire op_raddsub16  = op_radd16  | op_rsub16  | op_rcras16 | op_rcrsa16  | op_rstas16 | op_rstsa16 ; 
  wire op_uraddsub16 = op_uradd16 | op_ursub16 | op_urcras16| op_urcrsa16 | op_urstas16| op_urstsa16; 
  wire op_kaddsub16  = op_kadd16  | op_ksub16  | op_kcras16 | op_kcrsa16  | op_kstas16 | op_kstsa16 ; 
  wire op_ukaddsub16 = op_ukadd16 | op_uksub16 | op_ukcras16| op_ukcrsa16 | op_ukstas16| op_ukstsa16; 
  
  wire op_kaddsubh   = op_kaddh  | op_ksubh ;
  wire op_ukaddsubh  = op_ukaddh | op_uksubh;

  wire op_kaddsubw   = op_kaddw  | op_ksubw ;
  wire op_ukaddsubw  = op_ukaddw | op_uksubw;
  wire op_raddsubw   = op_raddw  | op_rsubw ;
  wire op_uraddsubw  = op_uraddw | op_ursubw;

  wire op_addsub64   = op_add64   | op_sub64  ; 
  wire op_raddsub64  = op_radd64  | op_rsub64 ; 
  wire op_uraddsub64 = op_uradd64 | op_ursub64; 
  wire op_kaddsub64  = op_kadd64  | op_ksub64 ; 
  wire op_ukaddsub64 = op_ukadd64 | op_uksub64; 

  wire op_cmp_lt8  = op_ucmplt8 | op_ucmple8 | op_scmplt8 | op_scmple8 ;
  wire op_cmp_lt16 = op_ucmplt16 | op_ucmple16 | op_scmplt16 | op_scmple16;
  wire op_cmp_eq = op_cmpeq8| op_ucmple8| op_scmple8 | op_cmpeq16| op_ucmple16| op_scmple16;

  wire op_cmp     =  op_cmp_lt8 | op_cmp_lt16 | op_cmp_eq;
  wire op_maxmin8  = op_umax8  | op_umin8   | op_smax8   | op_smin8 ; 
  wire op_maxmin16 = op_umax16 | op_umin16  | op_smax16  | op_smin16;
  wire op_maxminw = op_maxw | op_minw;
  wire op_maxmin = op_maxmin8 | op_maxmin16 | op_maxminw;

  wire op_kabs = op_kabs8 | op_kabs16 | op_kabsw;
 
  wire op_pbs = op_pbsad | op_pbsada;


  wire adder_sadd8  = op_add8 | op_radd8  | op_kadd8 ;
  wire adder_uadd8  = op_uradd8 | op_ukadd8;
  wire adder_add8 = adder_sadd8 | adder_uadd8;

  wire adder_sadd16 = op_add16 | op_radd16 | op_kadd16;
  wire adder_uadd16 = op_uradd16 | op_ukadd16;
  wire adder_add16 = adder_sadd16 | adder_uadd16;
  
  wire adder_saddh  = op_kaddh ;
  wire adder_uaddh  = op_ukaddh;
  wire adder_addh  = adder_saddh | adder_uaddh;

  wire adder_saddw  = op_kaddw |  op_raddw  ;
  wire adder_uaddw  = op_ukaddw |  op_uraddw;
  wire adder_addw  = adder_saddw | adder_uaddw;

  wire adder_sadd64 = op_add64   | op_radd64  | op_kadd64 ;
  wire adder_uadd64 = op_uradd64 | op_ukadd64 ;
  wire adder_add64 = adder_sadd64 | adder_uadd64 ; 

  wire adder_scrxas16 = op_cras16 | op_rcras16 | op_kcras16 ;
  wire adder_ucrxas16 = op_urcras16 | op_ukcras16;
  wire adder_crxas16 = adder_scrxas16 | adder_ucrxas16;

  wire adder_scrxsa16 = op_crsa16 | op_rcrsa16 | op_kcrsa16 ;
  wire adder_ucrxsa16 = op_urcrsa16 | op_ukcrsa16;
  wire adder_crxsa16 = adder_scrxsa16 | adder_ucrxsa16;

  wire adder_sstas16  = op_stas16 | op_rstas16| op_kstas16;
  wire adder_ustas16  = op_urstas16 | op_ukstas16;
  wire adder_stas16  = adder_sstas16 | adder_ustas16;

  wire adder_sstsa16  = op_stsa16 | op_rstsa16 | op_kstsa16;
  wire adder_ustsa16  = op_urstsa16 | op_ukstsa16;
  wire adder_stsa16  = adder_sstsa16 | adder_ustsa16;
  
  wire adder_ssub8 = op_sub8   | op_rsub8  | op_ksub8 | op_scmplt8 | op_scmple8 | op_smin8 | op_smax8;
  wire adder_usub8 = op_ursub8 | op_uksub8 | op_ucmplt8 | op_ucmple8 | op_umin8 | op_umax8 | op_pbs;
  wire adder_sub8 = adder_ssub8 | adder_usub8 ;
  
  wire adder_ssub16 = op_sub16 | op_rsub16 |  op_ksub16 | op_scmplt16 | op_scmple16 | op_smin16 | op_smax16;
  wire adder_usub16 = op_ursub16 | op_uksub16 | op_ucmplt16 | op_ucmple16 | op_umin16 | op_umax16 ;
  wire adder_sub16 = adder_ssub16 | adder_usub16;
  
  wire adder_ssubh =  op_ksubh  ;
  wire adder_usubh =  op_uksubh ;
  wire adder_subh =  adder_ssubh | adder_usubh ;

  wire adder_ssubw = op_rsubw  | op_ksubw | op_maxminw;
  wire adder_usubw = op_ursubw | op_uksubw;
  wire adder_subw = adder_ssubw | adder_usubw;

  wire adder_ssub64 = op_sub64   | op_rsub64  | op_ksub64 ;
  wire adder_usub64 = op_ursub64 | op_uksub64 ;
  wire adder_sub64 = adder_ssub64 | adder_usub64 ;
  wire adder_op64 = adder_add64 | adder_sub64; 

  wire op_add = adder_add8 | adder_add16 | adder_crxsa16 | adder_stsa16 |
                adder_addh | adder_addw | op_kabs | adder_add64 | op_ave;

  wire op_sub = adder_sub8 | adder_sub16 | adder_crxas16 | adder_stas16 |
                adder_subh | adder_subw | adder_sub64;

  wire [`E203_XLEN-1:0] misc_op1   = dsp_addsub_rs1_i  ;
  wire [`E203_XLEN-1:0] misc_op2   = dsp_addsub_rs2_i  ;
  wire [`E203_XLEN-1:0] misc_op1_1 = dsp_addsub_rs1_1_i;
  wire [`E203_XLEN-1:0] misc_op2_1 = dsp_addsub_rs2_1_i;

  wire [`E203_DSP_BIGADDER_WIDTH-1:0] misc_adder_op1 =
      ({`E203_DSP_BIGADDER_WIDTH{adder_sadd8}} & {1'b0,misc_op1[31],misc_op1[31:24],  1'b0,misc_op1[23],misc_op1[23:16],
                                               1'b0,misc_op1[15],misc_op1[15:8] ,  1'b0,misc_op1[7 ],misc_op1[7:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{adder_uadd8}} & {2'b00,misc_op1[31:24],  2'b00,misc_op1[23:16], 2'b00,misc_op1[15:8] ,  2'b00,misc_op1[7:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ssub8}} & {1'b0,misc_op1[31],misc_op1[31:24],1'b1,misc_op1[23],misc_op1[23:16],
                                               1'b1,misc_op1[15],misc_op1[15:8 ],1'b1,misc_op1[7 ],misc_op1[7:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_usub8}} & {2'b00,misc_op1[31:24], 2'b10,misc_op1[23:16], 2'b10,misc_op1[15:8 ], 2'b10,misc_op1[7:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_sadd16}}& {3'h0,misc_op1[31],misc_op1[31:16],3'h0,misc_op1[15],misc_op1[15:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{adder_uadd16}}& {4'h0,misc_op1[31:16],4'h0,misc_op1[15:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ssub16}}& {3'b000,misc_op1[31],misc_op1[31:16],3'b100,misc_op1[15],misc_op1[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_usub16}}& {4'b0000,misc_op1[31:16],4'b1000,misc_op1[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_scrxas16 | adder_sstas16)}}
                                            & {3'b000, misc_op1[31], misc_op1[31:16],  3'b000, misc_op1[15], misc_op1[15:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_ucrxas16 | adder_ustas16)}}
                                            & {3'b000, 1'b0,         misc_op1[31:16],  3'b000, 1'b0,         misc_op1[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_scrxsa16 | adder_sstsa16)}}
                                            & {3'b000, misc_op1[31], misc_op1[31:16],  3'b100, misc_op1[15], misc_op1[15:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_ucrxsa16 | adder_ustsa16)}}
                                            & {3'b000, 1'b0,         misc_op1[31:16],  3'b100, 1'b0,         misc_op1[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_saddh    | adder_saddw | adder_ssubh | adder_ssubw)}}
                                            & {7'b0,misc_op1[31], misc_op1}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_uaddh    | adder_uaddw | adder_usubh | adder_usubw)}}
                                            & {7'b0,1'b0,         misc_op1})  
    | ({`E203_DSP_BIGADDER_WIDTH{op_kabs8}}    & {2'b00,misc_op1[31:24],2'b0,misc_op1[23:16],2'b0,misc_op1[15:8],2'b0,misc_op1[7:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{op_kabs16}}   & {4'b0000,misc_op1[31:16],4'b0000,misc_op1[15:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{op_kabsw}}    & {8'b0,misc_op1}) 
    | ({`E203_DSP_BIGADDER_WIDTH{op_ave     }} & {7'b0,misc_op1[31],misc_op1})  
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_sadd64 | adder_ssub64 | adder_uadd64 | adder_usub64)}} & {1'b0,misc_op1_1[6:0],misc_op1})
    ;

  wire[7:0] misc_op2_byte3_inv = ~misc_op2[31:24];  
  wire[7:0] misc_op2_byte2_inv = ~misc_op2[23:16];
  wire[7:0] misc_op2_byte1_inv = ~misc_op2[15:8 ];
  wire[7:0] misc_op2_byte0_inv = ~misc_op2[7 :0 ];
  wire misc_op2_31_inv = ~misc_op2[31];
  wire misc_op2_23_inv = ~misc_op2[23];
  wire misc_op2_15_inv = ~misc_op2[15];
  wire misc_op2_07_inv = ~misc_op2[7 ];
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] misc_adder_op2 =
      ({`E203_DSP_BIGADDER_WIDTH{adder_sadd8}} & {1'b0,misc_op2[31],misc_op2[31:24],  1'b0,misc_op2[23],misc_op2[23:16],
                                               1'b0,misc_op2[15],misc_op2[15:8] ,  1'b0,misc_op2[7 ],misc_op2[7:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_uadd8}} & {2'b00,misc_op2[31:24],  2'b00,misc_op2[23:16], 2'b00,misc_op2[15:8] ,  2'b00,misc_op2[7:0]})  
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ssub8}} & {1'b0,misc_op2_31_inv,misc_op2_byte3_inv,1'b1,misc_op2_23_inv,misc_op2_byte2_inv,
                                               1'b1,misc_op2_15_inv,misc_op2_byte1_inv,1'b1,misc_op2_07_inv,misc_op2_byte0_inv})  
    | ({`E203_DSP_BIGADDER_WIDTH{adder_usub8}} & {2'b01,misc_op2_byte3_inv,2'b11,misc_op2_byte2_inv,2'b11,misc_op2_byte1_inv,2'b11,misc_op2_byte0_inv}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_sadd16  }} & {3'b000 , misc_op2[31],misc_op2[31:16],
                                                  3'b000 , misc_op2[15],misc_op2[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_uadd16  }} & {4'b0000, misc_op2[31:16],4'b0000, misc_op2[15:0]})
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ssub16  }} & {3'b000 ,misc_op2_31_inv,{misc_op2_byte3_inv,misc_op2_byte2_inv},
                                                  3'b100 ,misc_op2_15_inv,{misc_op2_byte1_inv,misc_op2_byte0_inv}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_usub16  }} & {4'b0001,{misc_op2_byte3_inv,misc_op2_byte2_inv},
                                                  4'b1001,{misc_op2_byte1_inv,misc_op2_byte0_inv}})
    | ({`E203_DSP_BIGADDER_WIDTH{adder_scrxas16}} & {3'b000 , misc_op2[15]   ,  misc_op2[15:0 ],  
                                                  3'b000 , misc_op2_31_inv, {misc_op2_byte3_inv,misc_op2_byte2_inv}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ucrxas16}} & {3'b000 ,  1'b0,          misc_op2[15:0 ],  
                                                  3'b000 ,  1'b1,         {misc_op2_byte3_inv,misc_op2_byte2_inv}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_scrxsa16}} & {3'b000 , misc_op2_15_inv, {misc_op2_byte1_inv,misc_op2_byte0_inv},  
                                                  3'b100 , misc_op2[31],     misc_op2[31:16]} ) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ucrxsa16}} & {3'b000 ,  1'b1,         {misc_op2_byte1_inv,misc_op2_byte0_inv},
                                                  3'b100 ,  1'b0,          misc_op2[31:16]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_sstas16 }} & {3'b000 ,  misc_op2[31],  misc_op2[31:16],  
                                                  3'b000 , misc_op2_15_inv, {misc_op2_byte1_inv,misc_op2_byte0_inv}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ustas16 }} & {3'b000 ,  1'b0,          misc_op2[31:16],  
                                                  3'b000 ,  1'b1,         {misc_op2_byte1_inv,misc_op2_byte0_inv}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_sstsa16 }} & {3'b000 , misc_op2_31_inv, {misc_op2_byte3_inv,misc_op2_byte2_inv},  
                                                  3'b100 ,  misc_op2[15],          misc_op2[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{adder_ustsa16 }} & {3'b000 ,  1'b1,         {misc_op2_byte3_inv,misc_op2_byte2_inv},
                                                  3'b100 ,  1'b0,          misc_op2[15:0]}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_saddh | adder_saddw)}} & {7'b0,misc_op2[31],misc_op2}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_uaddh | adder_uaddw)}} & {7'b0,1'b0,        misc_op2})
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_ssubh | adder_ssubw)}} & {7'b0,misc_op2_31_inv,{misc_op2_byte3_inv,misc_op2_byte2_inv,
                                                                                     misc_op2_byte1_inv,misc_op2_byte0_inv}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_usubh | adder_usubw )}} & {7'b0,1'b1,           {misc_op2_byte3_inv,misc_op2_byte2_inv,
                                                                                     misc_op2_byte1_inv,misc_op2_byte0_inv}}) 
       
    | ({`E203_DSP_BIGADDER_WIDTH{op_kabs8}}  & {2'b0,{8{misc_op1[31]}},2'b0,{8{misc_op1[23]}},2'b0,{8{misc_op1[15]}},2'b0,{8{misc_op1[7]}}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{op_kabs16}} & {4'b000,{16{misc_op1[31]}},4'b0000,{16{misc_op1[15]}}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{op_kabsw}}  & {8'b0,{32{misc_op1[31]}}}) 
    | ({`E203_DSP_BIGADDER_WIDTH{op_ave  }}  & {7'b0,misc_op2[31],misc_op2}) 
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_sadd64 | adder_uadd64)}} & {1'b0,misc_op2_1[6:0],misc_op2})
    | ({`E203_DSP_BIGADDER_WIDTH{(adder_ssub64 | adder_usub64)}} & {1'b0,~misc_op2_1[6:0],{misc_op2_byte3_inv,misc_op2_byte2_inv,misc_op2_byte1_inv,misc_op2_byte0_inv}})
       ;

  wire [`E203_DSP_LITADDER_WIDTH-1:0] misc_adder_op1_1 = 
      ({`E203_DSP_LITADDER_WIDTH{(adder_sadd64 | adder_ssub64)}} & {misc_op1_1[31],misc_op1_1[31:7]}) 
    | ({`E203_DSP_LITADDER_WIDTH{(adder_uadd64 | adder_usub64)}} & {1'b0,          misc_op1_1[31:7]})
       ;

  wire [`E203_DSP_LITADDER_WIDTH-1:0] misc_adder_op2_1 =
      ({`E203_DSP_LITADDER_WIDTH{adder_sadd64}} & {misc_op2_1[31],  misc_op2_1[31:7]}) 
    | ({`E203_DSP_LITADDER_WIDTH{adder_uadd64}} & {1'b0,            misc_op2_1[31:7]}) 
    | ({`E203_DSP_LITADDER_WIDTH{adder_ssub64}} & {~misc_op2_1[31],~misc_op2_1[31:7]})
    | ({`E203_DSP_LITADDER_WIDTH{adder_usub64}} & {1'b1,           ~misc_op2_1[31:7]})
       ;

  assign dsp_addsub_big_op1_o    = misc_adder_op1;
  assign dsp_addsub_big_op2_o    = misc_adder_op2;
  assign dsp_addsub_little_op1_o = misc_adder_op1_1;
  assign dsp_addsub_little_op2_o = misc_adder_op2_1;


  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_res = dsp_addsub_big_res_i; 
  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_res_1 = dsp_addsub_little_res_i; 
  
  
  
  
  
  wire op_cmplt8  = op_scmplt8 | op_ucmplt8;
  wire op_cmple8  = op_scmple8 | op_ucmple8;
  wire op_cmplt16 = op_scmplt16 | op_ucmplt16;
  wire op_cmple16 = op_scmple16 | op_ucmple16;
     
  wire [`E203_XLEN-1:0] cmpeq_in1 = {`E203_XLEN{op_cmp_eq}} & misc_op1;
  wire [`E203_XLEN-1:0] cmpeq_in2 = {`E203_XLEN{op_cmp_eq}} & misc_op2;

  
  wire cmpeq8_res3 = ~(|(cmpeq_in1[31:24] ^ cmpeq_in2[31:24]));
  wire cmpeq8_res2 = ~(|(cmpeq_in1[23:16] ^ cmpeq_in2[23:16]));
  wire cmpeq8_res1 = ~(|(cmpeq_in1[15:8 ] ^ cmpeq_in2[15:8 ]));
  wire cmpeq8_res0 = ~(|(cmpeq_in1[7 :0 ] ^ cmpeq_in2[7 :0 ]));

  wire [31:0] cmpeq8_res = {({8{cmpeq8_res3}}),
                            ({8{cmpeq8_res2}}),
                            ({8{cmpeq8_res1}}),
                            ({8{cmpeq8_res0}})};
  
  wire [31:0] cmplt8_res = {{8{adder_res[38]}},
                            {8{adder_res[28]}},
                            {8{adder_res[18]}},
                            {8{adder_res[8 ]}} };

  wire [31:0] cmple8_res = cmpeq8_res | cmplt8_res;

  
  wire cmpeq16_res1 = ~(|(cmpeq_in1[31:16] ^ cmpeq_in2[31:16]));
  wire cmpeq16_res0 = ~(|(cmpeq_in1[15:0 ] ^ cmpeq_in2[15:0 ]));

  wire [31:0] cmpeq16_res = {{16{cmpeq16_res1}},
                             {16{cmpeq16_res0}}};

  
  wire [31:0] cmplt16_res = {{16{adder_res[36]}},
                             {16{adder_res[16]}}};

  wire [31:0] cmple16_res = cmpeq16_res | cmplt16_res;

  wire [31:0] cmp_res = ({`E203_XLEN{op_cmpeq8}}  & cmpeq8_res )  
                       |({`E203_XLEN{op_cmplt8}}  & cmplt8_res ) 
                       |({`E203_XLEN{op_cmple8}}  & cmple8_res )
                       |({`E203_XLEN{op_cmpeq16}} & cmpeq16_res)  
                       |({`E203_XLEN{op_cmplt16}} & cmplt16_res) 
                       |({`E203_XLEN{op_cmple16}} & cmple16_res)
                       ;

  
  
  
  
  wire[31:0] abs8_res = {32{op_kabs8}} & 
                  {(({8{misc_op1[31]}} & (~adder_res[37:30])) | ({8{~misc_op1[31]}} & misc_op1[31:24])) ,
                   (({8{misc_op1[23]}} & (~adder_res[27:20])) | ({8{~misc_op1[23]}} & misc_op1[23:16])) ,
                   (({8{misc_op1[15]}} & (~adder_res[17:10])) | ({8{~misc_op1[15]}} & misc_op1[15:8 ])) ,
                   (({8{misc_op1[7 ]}} & (~adder_res[ 7: 0])) | ({8{~misc_op1[7 ]}} & misc_op1[7 :0 ]))};

  wire[31:0] abs16_res = {32{op_kabs16}} & 
                  {(({16{misc_op1[31]}} & (~adder_res[35:20])) | ({16{~misc_op1[31]}} & misc_op1[31:16])) ,
                   (({16{misc_op1[15]}} & (~adder_res[15: 0])) | ({16{~misc_op1[7 ]}} & misc_op1[15:0 ]))};

  wire[31:0] absw_res = {32{op_kabsw}} & 
                  {(({32{misc_op1[31]}} & (~adder_res[31: 0])) | ({32{~misc_op1[31]}} & misc_op1[31: 0]))};
  
  
  wire [31:0] max8_res = {(adder_res[38] ? misc_op2[31:24] : misc_op1[31:24]),
                          (adder_res[28] ? misc_op2[23:16] : misc_op1[23:16]),
                          (adder_res[18] ? misc_op2[15:8 ] : misc_op1[15:8 ]),
                          (adder_res[8 ] ? misc_op2[7 :0 ] : misc_op1[7 :0 ])};

  wire [31:0] min8_res = {(adder_res[38] ? misc_op1[31:24] : misc_op2[31:24]),
                          (adder_res[28] ? misc_op1[23:16] : misc_op2[23:16]),
                          (adder_res[18] ? misc_op1[15:8 ] : misc_op2[15:8 ]),
                          (adder_res[8 ] ? misc_op1[7 :0 ] : misc_op2[7 :0 ])};

  wire [`E203_XLEN-1:0] maxmin8_res  =  ({`E203_XLEN{op_smax8 | op_umax8 }} & max8_res)
                                     |  ({`E203_XLEN{op_smin8 | op_umin8 }} & min8_res);  
  
  wire [31:0] max16_res = {(adder_res[36] ? misc_op2[31:16] : misc_op1[31:16]),
                           (adder_res[16] ? misc_op2[15:0 ] : misc_op1[15:0 ])};

  wire [31:0] min16_res = {(adder_res[36] ? misc_op1[31:16] : misc_op2[31:16]),
                           (adder_res[16] ? misc_op1[15:0 ] : misc_op2[15:0 ])};

  wire [`E203_XLEN-1:0] maxmin16_res  =  ({`E203_XLEN{op_smax16 | op_umax16 }} & max16_res)
                                        |({`E203_XLEN{op_smin16 | op_umin16 }} & min16_res);  
  
  wire [31:0] maxw_res =  adder_res[32] ? misc_op2 : misc_op1;
  wire [31:0] minw_res =  adder_res[32] ? misc_op1 : misc_op2; 

  wire [`E203_XLEN-1:0] maxminw_res  =  ({`E203_XLEN{op_maxw}} & maxw_res)
                                       |({`E203_XLEN{op_minw}} & minw_res);  



  wire [`E203_XLEN-1:0] maxmin_res = ({32{op_maxmin8 }} & maxmin8_res ) |
                                     ({32{op_maxmin16}} & maxmin16_res) |
                                     ({32{op_maxminw }} & maxminw_res );
  
  

  
  
  
  
  


  wire comn_ind_res = op_kaddsub8  | op_ukaddsub8  | op_kaddsub16 | op_ukaddsub16
               | op_kaddsubh  | op_ukaddsubh | op_kaddsubw  
               | op_ukaddsubw | op_kaddsub64  | op_ukaddsub64;
  
  
  
  
  
  
  

  
  

  

  wire sat_dfmt8  = op_kaddsub8  | op_ukaddsub8 | op_kabs8;
  wire sat_dfmt16 = op_kaddsub16 | op_ukaddsub16| op_kabs16;
  wire sat_dfmt32 = op_kaddsubw  | op_ukaddsubw | op_kaddsubh  | op_ukaddsubh| op_kabsw;
  wire sat_dfmt64 = op_kaddsub64 | op_ukaddsub64;                
  wire sat_enable = comn_ind_res | op_kabs;
  wire[2:0] sat_dform = ({3{sat_dfmt8 }} & 3'b00) 
                      | ({3{sat_dfmt16}} & 3'b01) 
                      | ({3{sat_dfmt32}} & 3'b10)
                      | ({3{sat_dfmt64}} & 3'b11)
                         ;

  wire sat_q7  = op_kaddsub8;
  wire sat_u8  = op_ukaddsub8;
  wire sat_q15 = op_kaddsub16 | op_kaddsubh;
  wire sat_u16 = op_ukadd16 | op_uksub16 | op_ukaddh | op_uksubh;
  wire sat_q31 = op_kaddsubw;
  wire sat_u32 = op_ukaddsubw;
  wire sat_abs = op_kabs;
  wire sat_uxas = op_ukcras16 | op_ukstas16; 
  wire sat_uxsa = op_ukcrsa16 | op_ukstsa16; 
  wire sat_q63 = op_kaddsub64;
  wire sat_u64 = op_ukaddsub64;
  wire[3:0] sat_type  = ({4{sat_q7  }} & 4'b0000)  
                      | ({4{sat_u8  }} & 4'b0001)  
                      | ({4{sat_q15 }} & 4'b0010)  
                      | ({4{sat_u16 }} & 4'b0011) 
                      | ({4{sat_q31 }} & 4'b0100)  
                      | ({4{sat_u32 }} & 4'b0101)  
                      | ({4{sat_abs }} & 4'b0110) 
                      | ({4{sat_uxas}} & 4'b0111) 
                      | ({4{sat_uxsa}} & 4'b1000)  
                      | ({4{sat_q63 }} & 4'b1001)  
                      | ({4{sat_u64 }} & 4'b1010)  
                        ;
  
  wire usflag = (op_kaddsub8 | op_uksub8  
                | op_kaddsub16 | op_uksub16 
                | op_kcras16 | op_ukcras16 |  op_kcrsa16 | op_ukcrsa16   
                | op_kstas16 | op_ukstas16 |  op_kstsa16 | op_ukstsa16   
                | op_kaddsubh |  op_uksubh   
                | op_kaddsubw |  op_uksubw   
                | op_kaddsub64 |  op_uksub64   
               );
  wire dsp_sat_ov;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_sat_res  ;
  wire [`E203_DSP_LITADDER_WIDTH-1:0] dsp_sat_res_1;
  e203_exu_dsp_sat u_e203_exu_dsp_sat (
      
      .dsp_sat_idata_i       (adder_res),
      .dsp_sat_idata_1_i     (adder_res_1),
      .dsp_sat_dform_i       (sat_dform     ), 
      .dsp_sat_type_i        (sat_type      ), 
      .dsp_sat_usflag_i      (usflag        ), 
      .dsp_sat_enable_i      (sat_enable      ), 
      .dsp_sat_odata_o       (dsp_sat_res   ),
      .dsp_sat_odata_1_o     (dsp_sat_res_1 ),
      .dsp_sat_ov_o          (dsp_sat_ov    )
  );


  wire rv32_dsp_op = op_addsub8 | op_raddsub8 | op_uraddsub8 | op_cmp | op_maxmin | op_addsub16  
                 | op_raddsub16 | op_uraddsub16 | op_raddsubw | op_uraddsubw | op_ave; 
  wire [`E203_XLEN-1:0] rv32_dsp_res =  
        ({`E203_XLEN{op_addsub8   }} & {adder_res[37:30],adder_res[27:20],adder_res[17:10],adder_res[7:0]})
      | ({`E203_XLEN{op_raddsub8  }} & {adder_res[38:31],adder_res[28:21],adder_res[18:11],adder_res[8:1]})
      | ({`E203_XLEN{op_uraddsub8 }} & {adder_res[38:31],adder_res[28:21],adder_res[18:11],adder_res[8:1]})
      | ({`E203_XLEN{op_cmp       }} & cmp_res )
      | ({`E203_XLEN{op_maxmin    }} & maxmin_res)
      | ({`E203_XLEN{op_addsub16  }} & {adder_res[35:20],adder_res[15:0]})
      | ({`E203_XLEN{op_raddsub16 }} & {adder_res[36:21],adder_res[16:1]})
      | ({`E203_XLEN{op_uraddsub16}} & {adder_res[36:21],adder_res[16:1]})
      | ({`E203_XLEN{op_raddsubw  }} & {adder_res[32: 1]})
      | ({`E203_XLEN{op_uraddsubw }} & {adder_res[32: 1]})
      | ({`E203_XLEN{op_ave       }} & {adder_res[32: 1]})
        ;
  wire rv32_dsp_sat_en = sat_dfmt8 | sat_dfmt16 | sat_dfmt32;
  wire [`E203_XLEN-1:0] rv32_dsp_sat_res =  
        ({`E203_XLEN{rv32_dsp_sat_en}} & {dsp_sat_res[31:24],dsp_sat_res[23:16],dsp_sat_res[15: 8],dsp_sat_res[7:0]})
        ;

  wire rv64_dsp_op = op_addsub64 | op_raddsub64 | op_uraddsub64; 
  wire [`E203_XLEN-1:0] rv64_dsp_res =  
        ({`E203_XLEN{op_addsub64  }} & adder_res[31: 0])
      | ({`E203_XLEN{op_raddsub64 }} & adder_res[32: 1])
      | ({`E203_XLEN{op_uraddsub64}} & adder_res[32: 1])
        ;
  wire [`E203_XLEN-1:0] rv64_dsp_res_1 =  
        ({`E203_XLEN{op_addsub64  }} & {adder_res_1[24:0],adder_res[38:32]})
      | ({`E203_XLEN{op_raddsub64 }} & {adder_res_1[25:0],adder_res[38:33]})
      | ({`E203_XLEN{op_uraddsub64}} & {adder_res_1[25:0],adder_res[38:33]})
        ;

  wire rv64_dsp_sat_en = op_kaddsub64 | op_ukaddsub64;
  wire [`E203_XLEN-1:0] rv64_dsp_sat_res =  
        ({`E203_XLEN{op_kaddsub64  }} & {dsp_sat_res[31: 0]})
      | ({`E203_XLEN{op_ukaddsub64 }} & {dsp_sat_res[31: 0]})
        ;
  wire [`E203_XLEN-1:0] rv64_dsp_sat_res_1 =  
        ({`E203_XLEN{op_kaddsub64  }} & {dsp_sat_res_1[24:0],dsp_sat_res[38:32]})
      | ({`E203_XLEN{op_ukaddsub64 }} & {dsp_sat_res_1[24:0],dsp_sat_res[38:32]})
        ;


  assign dsp_adder_req_o = op_sub | op_add | op_pbs;
  assign dsp_sub_en_o = op_sub | op_ave | op_pbs;

  
  
  wire [7:0] pbs_byt3 = ({8{adder_res[38]}} & (~adder_res[37:30])) | ({8{~adder_res[38]}} & adder_res[37:30]) ; 
  wire [7:0] pbs_byt2 = ({8{adder_res[28]}} & (~adder_res[27:20])) | ({8{~adder_res[28]}} & adder_res[27:20]) ; 
  wire [7:0] pbs_byt1 = ({8{adder_res[18]}} & (~adder_res[17:10])) | ({8{~adder_res[18]}} & adder_res[17:10]) ; 
  wire [7:0] pbs_byt0 = ({8{adder_res[ 8]}} & (~adder_res[ 7: 0])) | ({8{~adder_res[ 8]}} & adder_res[ 7: 0]) ; 

  wire [3:0] pbs_neg = {adder_res[38], adder_res[28], adder_res[18], adder_res[ 8]};
  wire [2:0] pbs_cin = ({3{(pbs_neg == 4'b0000)}} & 3'b000) | ({3{(pbs_neg == 4'b0001)}} & 3'b001)   
                     | ({3{(pbs_neg == 4'b0010)}} & 3'b001) | ({3{(pbs_neg == 4'b0011)}} & 3'b010)   
                     | ({3{(pbs_neg == 4'b0100)}} & 3'b001) | ({3{(pbs_neg == 4'b0101)}} & 3'b010)   
                     | ({3{(pbs_neg == 4'b0110)}} & 3'b010) | ({3{(pbs_neg == 4'b0111)}} & 3'b011)   
                     | ({3{(pbs_neg == 4'b1000)}} & 3'b001) | ({3{(pbs_neg == 4'b1001)}} & 3'b010)   
                     | ({3{(pbs_neg == 4'b1010)}} & 3'b010) | ({3{(pbs_neg == 4'b1011)}} & 3'b011)   
                     | ({3{(pbs_neg == 4'b1100)}} & 3'b010) | ({3{(pbs_neg == 4'b1101)}} & 3'b011)   
                     | ({3{(pbs_neg == 4'b1110)}} & 3'b011) | ({3{(pbs_neg == 4'b1111)}} & 3'b100);   
  assign dsp_addsub_pbs_o = ({`E203_XLEN+3{op_pbs}} & {pbs_cin,pbs_byt3,pbs_byt2,pbs_byt1,pbs_byt0});

  wire [`E203_XLEN-1:0]  dsp_addsub_o_wbck_wdat = ({`E203_XLEN{rv32_dsp_op}} & rv32_dsp_res) 
                                                | ({`E203_XLEN{rv64_dsp_op}} & rv64_dsp_res) 
                                                | ({`E203_XLEN{rv32_dsp_sat_en}}  & rv32_dsp_sat_res) 
                                                | ({`E203_XLEN{rv64_dsp_sat_en}}  & rv64_dsp_sat_res);

  wire [`E203_XLEN-1:0]  dsp_addsub_o_wbck_wdat_1 = ({`E203_XLEN{rv64_dsp_op}} & rv64_dsp_res_1)
                                                | ({`E203_XLEN{rv64_dsp_sat_en}}  & rv64_dsp_sat_res_1);
  assign dsp_addsub_wbck_wdat_o   = dsp_addsub_o_wbck_wdat;
  assign dsp_addsub_wbck_wdat_1_o = dsp_addsub_o_wbck_wdat_1;
  assign dsp_addsub_ov_wbck_o = dsp_sat_ov;


endmodule
