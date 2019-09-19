                                                                    
`include "e203_defines.v"

module e203_exu_dsp_mul(

  
  
  
  input [`E203_DECINFO_DSP_WIDTH-1:0] i_dsp_info,
  input [`E203_XLEN-1:0] dsp_i_rs1,
  input [`E203_XLEN-1:0] dsp_i_rs2,
  output dsp_unsign_op_flag,
  output [`E203_XLEN:0] dsp_mul_plex_alumul_rs1,
  output [`E203_XLEN:0] dsp_mul_plex_alumul_rs2,
  input [`E203_XLEN*2-1:0] dsp_plex_alumul_res,
  output dsp_hmul_simd_o_op,
  output [`E203_XLEN:0] dsp_mul16_adder_op1,
  output [`E203_XLEN:0] dsp_mul16_adder_op2,
  input  [`E203_XLEN+1:0]   dsp_mul16_adder_res,
  output [`E203_XLEN-1:0]  dsp_mul_rdw32_res,
  output [`E203_XLEN*2-1:0] dsp_mul_raw_res,
  output  dsp_mul_o_wbck_ov,
  output [`E203_XLEN-1:0] dsp_mul_o_wbck_wdat,        
  output [`E203_XLEN-1:0] dsp_mul_o_wbck_wdat_1,        
  output dsp_mul_o_wbck_err
  );


  wire i_khm8       = i_dsp_info[`E203_DECINFO_DSP_KHM8]; 
  wire i_khmx8      = i_dsp_info[`E203_DECINFO_DSP_KHMX8]; 
  wire i_khm16      = i_dsp_info[`E203_DECINFO_DSP_KHM16];
  wire i_khmx16     = i_dsp_info[`E203_DECINFO_DSP_KHMX16];
  wire i_kmmac      = i_dsp_info[`E203_DECINFO_DSP_KMMAC];
  wire i_kmmacu     = i_dsp_info[`E203_DECINFO_DSP_KMMACU];
  wire i_smul16     = i_dsp_info[`E203_DECINFO_DSP_SMUL16];
  wire i_smulx16    = i_dsp_info[`E203_DECINFO_DSP_SMULX16];
  wire i_umul16     = i_dsp_info[`E203_DECINFO_DSP_UMUL16];
  wire i_umulx16    = i_dsp_info[`E203_DECINFO_DSP_UMULX16];
  wire i_smul8      = i_dsp_info[`E203_DECINFO_DSP_SMUL8];
  wire i_smulx8     = i_dsp_info[`E203_DECINFO_DSP_SMULX8];
  wire i_umul8      = i_dsp_info[`E203_DECINFO_DSP_UMUL8];
  wire i_umulx8     = i_dsp_info[`E203_DECINFO_DSP_UMULX8];
  wire i_smmul      = i_dsp_info[`E203_DECINFO_DSP_SMMUL];
  wire i_smmulu     = i_dsp_info[`E203_DECINFO_DSP_SMMULU];
  wire i_kmmsb      = i_dsp_info[`E203_DECINFO_DSP_KMMSB];
  wire i_kmmsbu     = i_dsp_info[`E203_DECINFO_DSP_KMMSBU];
  wire i_kwmmul     = i_dsp_info[`E203_DECINFO_DSP_KWMMUL];
  wire i_kwmmulu    = i_dsp_info[`E203_DECINFO_DSP_KWMMULU];
  wire i_smmwb      = i_dsp_info[`E203_DECINFO_DSP_SMMWB];
  wire i_smmwbu     = i_dsp_info[`E203_DECINFO_DSP_SMMWBU];
  wire i_smmwt      = i_dsp_info[`E203_DECINFO_DSP_SMMWT];
  wire i_smmwtu     = i_dsp_info[`E203_DECINFO_DSP_SMMWTU];
  wire i_kmmawb     = i_dsp_info[`E203_DECINFO_DSP_KMMAWB];
  wire i_kmmawbu    = i_dsp_info[`E203_DECINFO_DSP_KMMAWBU];
  wire i_kmmawt     = i_dsp_info[`E203_DECINFO_DSP_KMMAWT];
  wire i_kmmawtu    = i_dsp_info[`E203_DECINFO_DSP_KMMAWTU];
  wire i_kmmwb2     = i_dsp_info[`E203_DECINFO_DSP_KMMWB2];
  wire i_kmmwb2u    = i_dsp_info[`E203_DECINFO_DSP_KMMWB2U];
  wire i_kmmwt2     = i_dsp_info[`E203_DECINFO_DSP_KMMWT2];
  wire i_kmmwt2u    = i_dsp_info[`E203_DECINFO_DSP_KMMWT2U];
  wire i_kmmawb2    = i_dsp_info[`E203_DECINFO_DSP_KMMAWB2];
  wire i_kmmawb2u   = i_dsp_info[`E203_DECINFO_DSP_KMMAWB2U];
  wire i_kmmawt2    = i_dsp_info[`E203_DECINFO_DSP_KMMAWT2];
  wire i_kmmawt2u   = i_dsp_info[`E203_DECINFO_DSP_KMMAWT2U];
  wire i_smslda     = i_dsp_info[`E203_DECINFO_DSP_SMSLDA];
  wire i_smslxda    = i_dsp_info[`E203_DECINFO_DSP_SMSLXDA];
  wire i_smbb16     = i_dsp_info[`E203_DECINFO_DSP_SMBB16];
  wire i_smbt16     = i_dsp_info[`E203_DECINFO_DSP_SMBT16];
  wire i_smtt16     = i_dsp_info[`E203_DECINFO_DSP_SMTT16];
  wire i_kmda       = i_dsp_info[`E203_DECINFO_DSP_KMDA];
  wire i_kmxda      = i_dsp_info[`E203_DECINFO_DSP_KMXDA];
  wire i_smds       = i_dsp_info[`E203_DECINFO_DSP_SMDS];
  wire i_smdrs      = i_dsp_info[`E203_DECINFO_DSP_SMDRS];
  wire i_smxds      = i_dsp_info[`E203_DECINFO_DSP_SMXDS];
  wire i_kmabb      = i_dsp_info[`E203_DECINFO_DSP_KMABB];
  wire i_kmabt      = i_dsp_info[`E203_DECINFO_DSP_KMABT];
  wire i_kmatt      = i_dsp_info[`E203_DECINFO_DSP_KMATT];
  wire i_kmada      = i_dsp_info[`E203_DECINFO_DSP_KMADA];
  wire i_kmaxda     = i_dsp_info[`E203_DECINFO_DSP_KMAXDA];
  wire i_kmads      = i_dsp_info[`E203_DECINFO_DSP_KMADS];
  wire i_kmadrs     = i_dsp_info[`E203_DECINFO_DSP_KMADRS];
  wire i_kmaxds     = i_dsp_info[`E203_DECINFO_DSP_KMAXDS];
  wire i_kmsda      = i_dsp_info[`E203_DECINFO_DSP_KMSDA];
  wire i_kmsxda     = i_dsp_info[`E203_DECINFO_DSP_KMSXDA];
  wire i_smaqa      = i_dsp_info[`E203_DECINFO_DSP_SMAQA];
  wire i_umaqa      = i_dsp_info[`E203_DECINFO_DSP_UMAQA];
  wire i_smaqasu    = i_dsp_info[`E203_DECINFO_DSP_SMAQASU];
  wire i_khmbb      = i_dsp_info[`E203_DECINFO_DSP_KHMBB];
  wire i_khmbt      = i_dsp_info[`E203_DECINFO_DSP_KHMBT];
  wire i_khmtt      = i_dsp_info[`E203_DECINFO_DSP_KHMTT];
  wire i_kdmbb      = i_dsp_info[`E203_DECINFO_DSP_KDMBB];
  wire i_kdmbt      = i_dsp_info[`E203_DECINFO_DSP_KDMBT];
  wire i_kdmtt      = i_dsp_info[`E203_DECINFO_DSP_KDMTT];
  wire i_kdmabb     = i_dsp_info[`E203_DECINFO_DSP_KDMABB];
  wire i_kdmabt     = i_dsp_info[`E203_DECINFO_DSP_KDMABT];
  wire i_kdmatt     = i_dsp_info[`E203_DECINFO_DSP_KDMATT];
  wire i_maddr32    = i_dsp_info[`E203_DECINFO_DSP_MADDR32];
  wire i_msubr32    = i_dsp_info[`E203_DECINFO_DSP_MSUBR32];
  wire i_mulr64     = i_dsp_info[`E203_DECINFO_DSP_MULR64];
  wire i_mulsr64    = i_dsp_info[`E203_DECINFO_DSP_MULSR64];
  wire i_smal       = i_dsp_info[`E203_DECINFO_DSP_SMAL];
  wire i_smalbb     = i_dsp_info[`E203_DECINFO_DSP_SMALBB];
  wire i_smalbt     = i_dsp_info[`E203_DECINFO_DSP_SMALBT];
  wire i_smaltt     = i_dsp_info[`E203_DECINFO_DSP_SMALTT];
  wire i_smalda     = i_dsp_info[`E203_DECINFO_DSP_SMALDA];
  wire i_smalxda    = i_dsp_info[`E203_DECINFO_DSP_SMALXDA];
  wire i_smalds     = i_dsp_info[`E203_DECINFO_DSP_SMALDS];
  wire i_smaldrs    = i_dsp_info[`E203_DECINFO_DSP_SMALDRS];
  wire i_smalxds    = i_dsp_info[`E203_DECINFO_DSP_SMALXDS];
  wire i_smar64     = i_dsp_info[`E203_DECINFO_DSP_SMAR64];
  wire i_smsr64     = i_dsp_info[`E203_DECINFO_DSP_SMSR64];
  wire i_kmsr64     = i_dsp_info[`E203_DECINFO_DSP_KMSR64];
  wire i_kmar64     = i_dsp_info[`E203_DECINFO_DSP_KMAR64];
  wire i_ukmsr64    = i_dsp_info[`E203_DECINFO_DSP_UKMSR64];
  wire i_ukmar64    = i_dsp_info[`E203_DECINFO_DSP_UKMAR64];
  wire i_umar64     = i_dsp_info[`E203_DECINFO_DSP_UMAR64];
  wire i_umsr64     = i_dsp_info[`E203_DECINFO_DSP_UMSR64];
  wire i_pbsada     = i_dsp_info[`E203_DECINFO_DSP_PBSADA];
        

  wire bmul_simd_op = i_khm8 | i_khmx8 | i_smul8 | i_smulx8 | i_umul8
                      | i_umulx8 | i_smaqa | i_umaqa | i_smaqasu
                      ;

  wire hmul_simd_op = 
                      i_khm16 | i_khmx16 | i_smul16 | i_smulx16 | i_umul16 | i_umulx16
                    | i_kmda | i_kmxda | i_smds | i_smdrs | i_smxds | i_kmada | i_kmaxda
                    | i_kmads | i_kmadrs | i_kmaxds | i_kmsda | i_kmsxda | i_smslda
                    | i_smslxda | i_smalda | i_smalxda | i_smalds | i_smaldrs | i_smalxds ;

  assign dsp_hmul_simd_o_op = hmul_simd_op;

  wire dsp_mul_rdw64_op = i_mulr64 |  i_mulsr64 |  i_smul8 |  i_smulx8 |  i_umul8 |  i_umulx8
                        |  i_smul16 |  i_smulx16 |  i_umul16 |  i_umulx16 ;

  wire simd_cross_mul_op_flag = i_khmx8 | i_smulx8 | i_umulx8 | i_khmx16 | i_smulx16 | i_umulx16
                                | i_smbt16 | i_kmxda | i_smxds | i_kmaxda | i_kmaxds | i_kmsxda
                                | i_smslxda | i_smalxda | i_smalxds ;


  wire dsp_mul_plex_alumul_op = i_dsp_info[`E203_DECINFO_DSP_MUL_PLEX_ALUMULOP]; 
  wire dsp_mul_op      = i_dsp_info[`E203_DECINFO_DSP_MULOP];


    wire sat_mul_rd_q7 = i_khm8 | i_khmx8;
   wire sat_mul_rd_q15 = i_khmbb |i_khmbt |i_khmtt |i_khm16 |i_khmx16;

   wire sat_mul_rd_q31 = i_kmmwb2 |i_kmmwt2 |i_kwmmul |i_kdmbb |i_kdmbt |i_kdmtt
                        
                        
                       | i_kwmmulu |i_kmmwt2u  |i_kmmwb2u
                        
                       | i_kdmabb |i_kdmabt  |i_kdmatt |i_kmmawt2 |i_kmmawb2 
                       | i_kmmawt2u |i_kmmawb2u
                        ; 

  wire rd_need_sat = sat_mul_rd_q31 | sat_mul_rd_q15 | sat_mul_rd_q7;
  wire [`E203_XLEN-1:0] dsp_mul_i_rs1 = dsp_i_rs1;
  wire [`E203_XLEN-1:0] dsp_mul_i_rs2 = dsp_i_rs2;
  
  
  assign dsp_mul_plex_alumul_rs1 = 
                            ({33{i_smmwb | i_smmwt | i_kmmwb2 | i_kmmwt2 | i_kwmmul | i_smmul
                            | i_mulsr64 | i_smmulu | i_kwmmulu | i_kmmwt2u | i_kmmwb2u
                            | i_smmwtu | i_smmwbu | i_maddr32 | i_msubr32 | i_kmmawbu | i_kmmawt
                            | i_kmmawtu | i_kmmawb2 | i_kmmawb2u | i_kmmawt2 | i_kmmawt2u | i_kmmawb
                            | i_kmmac | i_kmmacu | i_kmmsb | i_kmmsbu | i_smar64 | i_smsr64
                            | i_kmsr64 | i_kmar64 }}                                               & {dsp_i_rs1[31], dsp_i_rs1}) 
                          | ({33{(i_mulr64 | i_ukmsr64 | i_ukmar64 | i_umar64 | i_umsr64)}}        & {1'b0,dsp_i_rs1})
                          | ({33{(i_smbb16 | i_smbt16 | i_khmbt | i_khmbb | i_smalbb | i_smalbt
                            | i_kmabb | i_kmabt | i_kdmabb | i_kdmabt | i_kdmbb  | i_kdmbt )}}     & {{17{dsp_i_rs1[15]}},dsp_i_rs1[15:0]})
                          | ({33{(i_smtt16 | i_khmtt | i_kdmtt | i_smaltt | i_kmatt | i_kdmatt )}} & {{17{dsp_i_rs1[31]}},dsp_i_rs1[31:16]})
                          | ({33{i_smal}}                                                          & {{17{dsp_i_rs2[15]}},dsp_i_rs2[15:0]})
                          ;

  
  assign dsp_mul_plex_alumul_rs2 = 
                            ({33{(i_kwmmul | i_smmul | i_mulsr64 | i_smmulu | i_kwmmulu
                            | i_maddr32 | i_msubr32 | i_kmmac | i_kmmacu | i_kmmsb | i_kmmsbu   
                            | i_smar64 | i_smsr64 | i_kmsr64 | i_kmar64)}}                        & {dsp_i_rs2[31],dsp_i_rs2})
                          | ({33{(i_mulr64 | i_ukmsr64 | i_ukmar64 | i_umar64 | i_umsr64)}}       & {1'b0,dsp_i_rs2})
                          | ({33{(  i_smbb16 | i_khmbb | i_kdmbb | i_smalbb | i_kmabb | i_kdmabb
                              | i_smmwb  | i_kmmwb2| i_kmmwb2u | i_smmwbu | i_kmmawb| i_kmmawbu 
                              |i_kmmawb2 | i_kmmawb2u)}}                                          & {{17{dsp_i_rs2[15]}},dsp_i_rs2[15:0]})
                          | ({33{(  i_smbt16 | i_khmbt | i_kdmbt | i_smalbt | i_kmabt | i_kdmabt
                              | i_smtt16 | i_khmtt | i_kdmtt | i_smaltt | i_kmatt | i_kdmatt
                              | i_smmwt  | i_kmmwt2| i_kmmwt2u | i_smmwtu | i_kmmawt| i_kmmawtu 
                              |i_kmmawt2 | i_kmmawt2u | i_smal)}}                                 & {{17{dsp_i_rs2[31]}},dsp_i_rs2[31:16]})
                          ;

  

  assign dsp_unsign_op_flag =
                             i_umaqa  | i_umul8 | i_umulx8 | i_umul16
                           | i_umulx16 | i_mulr64 | i_ukmsr64 | i_ukmar64 
                           | i_umar64  | i_umsr64  
                           ;

  wire dsp_rs2_unsign_op_flag = i_smaqasu;                           
  wire [`E203_XLEN*2-1 : 0] dsp_simd_mul_res;           


  e203_exu_dsp_simd_mul u_e203_exu_dsp_simd_mul(
    .dsp_mul_i_rs1              (dsp_mul_i_rs1),
    .dsp_mul_i_rs2              (dsp_mul_i_rs2),
    .dsp_mul16_adder_op1        (dsp_mul16_adder_op1),
    .dsp_mul16_adder_op2        (dsp_mul16_adder_op2),
    .dsp_mul16_adder_res        (dsp_mul16_adder_res),
    .dsp_unsign_op_flag         (dsp_unsign_op_flag),
    .bmul_simd_op               (bmul_simd_op),
    .hmul_simd_op               (hmul_simd_op),
    .simd_cross_mul_op_flag     (simd_cross_mul_op_flag),
    .dsp_mul_o_wbck_err         (dsp_mul_o_wbck_err),
    .dsp_simd_mul_res           (dsp_simd_mul_res),
    .dsp_rs2_unsign_op_flag     (dsp_rs2_unsign_op_flag) 
  );

  wire [`E203_XLEN-1:0]  dsp_mul_rdw64_res_0;
  wire [`E203_XLEN-1:0]  dsp_mul_rdw64_res_1;
  assign dsp_mul_raw_res = dsp_mul_plex_alumul_op ? dsp_plex_alumul_res : dsp_simd_mul_res;




  wire [2:0] dsp_mul_rd_sat_ignr_type;
  assign dsp_mul_rd_sat_ignr_type[0] = 
                                        
                                          i_smbb16 | i_smbt16 | i_smtt16
                                        
                                        | i_smalbb | i_smalbt | i_smaltt | i_kmabb | i_kmabt
                                        | i_kmatt |  i_maddr32 | i_msubr32 | i_smal 
                                        ;
  assign dsp_mul_rd_sat_ignr_type[1] = 
                                        
                                          i_smmwt | i_smmwb 
                                        
                                        | i_kmmawb | i_kmmawt
                                        ;
  assign dsp_mul_rd_sat_ignr_type[2] =  
                                        
                                        i_smmul 
                                        
                                        | i_kmmac | i_kmmsb
                                        ;
  wire [`E203_XLEN-1:0] sat_ignr_rd = 
                                         ({32{dsp_mul_rd_sat_ignr_type[0]}} & dsp_mul_raw_res[31:0])  
                                       | ({32{dsp_mul_rd_sat_ignr_type[1]}} & dsp_mul_raw_res[47:16]) 
                                       | ({32{dsp_mul_rd_sat_ignr_type[2]}} & dsp_mul_raw_res[63:32]) 
                                       ;

  wire [31:0] dsp_sat7_res;                
  wire [31:0] dsp_sat15_res;                

  wire [3:0] q7_res_ov_flag;
  assign  q7_res_ov_flag[0] = sat_mul_rd_q7 & ((~dsp_mul_raw_res[15]) & dsp_mul_raw_res[14]);
  assign  q7_res_ov_flag[1] = sat_mul_rd_q7 & ((~dsp_mul_raw_res[31]) & dsp_mul_raw_res[30]);
  assign  q7_res_ov_flag[2] = sat_mul_rd_q7 & ((~dsp_mul_raw_res[47]) & dsp_mul_raw_res[46]);
  assign  q7_res_ov_flag[3] = sat_mul_rd_q7 & ((~dsp_mul_raw_res[63]) & dsp_mul_raw_res[62]);
  assign dsp_sat7_res[7:0]    = {8{sat_mul_rd_q7}} & (q7_res_ov_flag[0] ? 8'h7f : dsp_mul_raw_res[14:7] );
  assign dsp_sat7_res[15:8]   = {8{sat_mul_rd_q7}} & (q7_res_ov_flag[1] ? 8'h7f : dsp_mul_raw_res[30:23]); 
  assign dsp_sat7_res[23:16]  = {8{sat_mul_rd_q7}} & (q7_res_ov_flag[2] ? 8'h7f : dsp_mul_raw_res[46:39]);
  assign dsp_sat7_res[31:24]  = {8{sat_mul_rd_q7}} & (q7_res_ov_flag[3] ? 8'h7f : dsp_mul_raw_res[62:55]);

  wire [1:0] q15_res_ov_flag;
  assign  q15_res_ov_flag[0] =   sat_mul_rd_q15 & ((~dsp_mul_raw_res[31]) &  dsp_mul_raw_res[30]);
  assign  q15_res_ov_flag[1] =  (i_khm16 | i_khmx16) & ((~dsp_mul_raw_res[63]) &  dsp_mul_raw_res[62]);
  assign dsp_sat15_res[15:0]  =  {16{sat_mul_rd_q15}} & (q15_res_ov_flag[0] ? 16'h7fff : dsp_mul_raw_res[30:15]);

  assign dsp_sat15_res[31:16] = {16{sat_mul_rd_q15}} & (q15_res_ov_flag[1] ? 16'h7fff :
                                                       (({16{i_khm16 | i_khmx16}} & dsp_mul_raw_res[62:47])
                                                       | ({16{(i_khmbb | i_khmbt | i_khmtt) &  dsp_sat15_res[15]}})))
                                                       ;
  wire q31_res_ov_flag = ((i_kdmbb | i_kdmbt | i_kdmtt 
                          |i_kdmabb |i_kdmabt  |i_kdmatt)       & ((~dsp_mul_raw_res[31]) & dsp_mul_raw_res[30]))                                
                       | ((i_kmmwb2 | i_kmmwt2 | i_kmmwb2u 
                          |i_kmmwt2u |i_kmmawt2 |i_kmmawb2
                          |i_kmmawt2u |i_kmmawb2u )             & ((~dsp_mul_raw_res[47]) & dsp_mul_raw_res[46]))
                       | ((i_kwmmul | i_kwmmulu)                & ((~dsp_mul_raw_res[63]) & dsp_mul_raw_res[62]))
                       ;
  wire [31:0] dsp_sat31_res =   {32{sat_mul_rd_q31}} & (q31_res_ov_flag ? 32'h7fffffff :
                                                       ( ({32{ i_kdmbb | i_kdmbt | i_kdmtt
                                                             | i_kdmabb | i_kdmabt | i_kdmatt}} & {dsp_mul_raw_res[30:0],1'b0})
                                                       | ({32{(i_kmmwb2 | i_kmmwt2 |i_kmmawt2 
                                                              |i_kmmawb2)}}                     & {dsp_mul_raw_res[46:15]})  
                                                       | ({32{(i_kwmmul)}}                      & {dsp_mul_raw_res[62:31]})
                                                       )
                                                       )
                                ;

  wire [`E203_XLEN-1:0] dsp_sat_res_rd = dsp_sat7_res | dsp_sat15_res | dsp_sat31_res;
 
  assign dsp_mul_rdw32_res = rd_need_sat ? dsp_sat_res_rd : sat_ignr_rd;
  assign dsp_mul_rdw64_res_0 = dsp_mul_raw_res[31:0];
  assign dsp_mul_rdw64_res_1 = dsp_mul_raw_res[63:32];
  assign dsp_mul_o_wbck_ov = (|q7_res_ov_flag) | (|q15_res_ov_flag) | (|q31_res_ov_flag);
 
  wire dsp_mul_rdw32_op = dsp_mul_op & (~dsp_mul_rdw64_op);
  assign dsp_mul_o_wbck_wdat   = ({`E203_XLEN{dsp_mul_rdw64_op}} & dsp_mul_rdw64_res_0)
                               | ({`E203_XLEN{dsp_mul_rdw32_op}} & dsp_mul_rdw32_res);

  assign dsp_mul_o_wbck_wdat_1 = ({`E203_XLEN{dsp_mul_rdw64_op}}  & dsp_mul_rdw64_res_1);

endmodule  
