
`include "e203_defines.v"

module e203_exu_dsp_mac(
  input dsp_unsign_op_flag,
  input dsp_mul_o_wbck_ov,
  input [`E203_RFIDX_WIDTH-1:0]  dsp_i_rdidx,
  input [`E203_RFIDX_WIDTH-1:0] dsp_i_rs1idx,
  input [`E203_XLEN-1:0] dsp_i_rs1_1,
  input [`E203_XLEN-1:0] dsp_i_rs1,
  input [`E203_XLEN-1:0] dsp_i_rd,
  input [`E203_XLEN-1:0] dsp_i_rd_1,
  input [`E203_XLEN-1:0]  dsp_mul_rdw32_res,
  input [`E203_XLEN*2-1:0] dsp_mul_raw_res,
  input [`E203_XLEN+2:0] dsp_addsub_pb_res,
  input [`E203_DECINFO_DSP_WIDTH-1:0] i_dsp_info,
  output [`E203_XLEN-1:0] dsp_mac_o_wbck_wdat,        
  output [`E203_XLEN-1:0] dsp_mac_o_wbck_wdat_1,        
  output dsp_mac_o_wbck_ov,
  output dsp_mac_o_wbck_err,        
  input clk,
  input rst_n
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

  wire dsp_addsub_plex_mac_op = i_dsp_info[`E203_DECINFO_DSP_ADDSUB_PLEX_LONGPOP];
  wire dsp_mac_op      = i_dsp_info[`E203_DECINFO_DSP_MACOP];
  wire dsp_macl_op    = i_dsp_info[`E203_DECINFO_DSP_LONGPOP];
  wire dsp_rnd_op_need_mul_sat = i_kwmmulu  | i_kmmwb2u | i_kmmawt2u | i_kmmwt2u | i_kmmawb2u;
  wire dsp_mac_mul_stage_ov = dsp_mul_o_wbck_ov & (               
                                  dsp_rnd_op_need_mul_sat 
                                | i_kdmabb |i_kdmabt  |i_kdmatt |i_kmmawt2 |i_kmmawb2);

  wire dsp_mul_rd_need_rnd   =
                                 
                                ((~dsp_mul_o_wbck_ov) & dsp_rnd_op_need_mul_sat)
                             |  (i_smmulu | i_kmmacu  | i_kmmsbu | i_smmwbu | i_smmwtu | i_kmmawbu | i_kmmawtu)
                             ;
                             
    wire dsp_rdw64_op = 
                            i_smalbb | i_smalbt | i_smaltt | i_smslda | i_smslxda
                            | i_smalda | i_smalxda | i_smalds | i_smaldrs | i_smalxds
                            | i_smar64 | i_smsr64 | i_ukmar64 | i_ukmsr64 | i_kmar64
                            | i_kmsr64 | i_umar64 | i_umsr64
                            ;

  wire dsp_mac_one_sp_two_addend_op = 
                                    | i_smar64 | i_smsr64 | i_kmsr64 | i_kmar64 | i_ukmsr64
                                    | i_ukmar64 | i_umar64 | i_umsr64 
                                    ;
  wire dsp_mac_two_addend_op = 
                               i_kmda   | i_kmxda | i_smds | i_smdrs
                             | i_smxds  | i_kmada | i_kmaxda | i_kmads
                             | i_kmadrs | i_kmaxds | i_kmsda | i_kmsxda
                             | i_smslda | i_smslxda | i_smalda | i_smalxda
                             | i_smalds | i_smaldrs | i_smalxds 
                             
                             
                             | dsp_mac_one_sp_two_addend_op 
                             ;

  wire dsp_mac_four_addend_op = i_smaqa |  i_umaqa |  i_smaqasu ; 

  wire dsp_mac_one_addend_op = dsp_macl_op 
                             & (~dsp_mac_two_addend_op) 
                             & (~dsp_mac_four_addend_op) 
                             & (~dsp_addsub_plex_mac_op)
                             & (~dsp_mul_rd_need_rnd)
                             ;

  wire dsp_mac_sub_src1_op = 
                             i_smalxds | i_smalds | i_kmads | i_kmaxds
                           | i_smds | i_smxds | i_kmmsb | i_kmmsbu | i_kmsda
                           | i_msubr32  | i_kmsxda | i_smslda | i_smslxda
                           
                           | i_ukmsr64 | i_kmsr64 | i_smsr64 | i_umsr64 
                           ;
                            
                           

  wire dsp_mac_sub_src2_op =
                           | i_kmsda | i_kmsxda | i_smslda | i_smslxda
                           | i_kmadrs | i_smdrs | i_smaldrs 
                           ;

  wire dsp_concat_r1_op = i_smal;

  wire dsp_kmda_kmxda_op = i_kmda | i_kmxda;

  wire dsp_alu_plex_mac_op = i_dsp_info[`E203_DECINFO_DSP_MUL_PLEX_LONGPOP];

  wire sat_mac_rd_q31 =     
                        
                         |i_kmmawbu |i_kmmawt  |i_kmmawtu  |i_kmmawb |i_kmmac
                         |i_kmmacu  |i_kmmsb    |i_kmmsbu
                         |i_kmada   |i_kmaxda 
                         |i_kmads   |i_kmadrs   |i_kmaxds  |i_kmsda |i_kmsxda
                         |i_kmabb   |i_kmabt    |i_kmatt
                        
                         |i_kdmabb |i_kdmabt  |i_kdmatt |i_kmmawt2 |i_kmmawb2 
                        
                        
                         |i_kmmawb2u  |i_kmmawt2u 
                        ;
  wire sat_mac_rd_u64 = i_ukmsr64 | i_ukmar64;
  wire sat_mac_rd_q63 = i_kmsr64 | i_kmar64;


  wire dsp_mul_raw_res0_sign = dsp_unsign_op_flag ? 1'b0 : dsp_mul_raw_res[15];
  wire dsp_mul_raw_res1_sign = dsp_unsign_op_flag ? 1'b0 : dsp_mul_raw_res[31];
  wire dsp_mul_raw_res2_sign = dsp_unsign_op_flag ? 1'b0 : dsp_mul_raw_res[47];
  wire dsp_mul_raw_res3_sign = dsp_unsign_op_flag ? 1'b0 : dsp_mul_raw_res[63];

  
  
  wire [`E203_XLEN:0] rnd_pre_res1 = 
                                      ({33{(i_smmwtu | i_kmmawbu | i_kmmawtu | i_smmwbu)}} & dsp_mul_raw_res[47:15])
                                    | ({33{(i_kmmwb2u | i_kmmwt2u)}} & dsp_mul_raw_res[46:14])
                                    | ({33{(i_smmulu | i_kmmacu | i_kmmsbu)}} & dsp_mul_raw_res[63:31]); 
  wire [`E203_XLEN+1:0] rnd_pre_res2 =  
                                       ({34{i_kwmmulu}} & dsp_mul_raw_res[63:30])                                    
                                     | ({34{(i_kmmawb2u | i_kmmawt2u)}} & dsp_mul_raw_res[47:14]);

  wire [`E203_XLEN+1:0] rnd_pre_rd = {rnd_pre_res1[`E203_XLEN],rnd_pre_res1} | rnd_pre_res2;

  wire [`E203_XLEN-1:0] dsp_mac_rd = dsp_i_rd;
  wire [`E203_XLEN-1:0] dsp_mac_rd_1 = dsp_i_rd_1;
  wire [`E203_XLEN-1:0] dsp_mac_adder_src0   = i_smal ? dsp_i_rs1   :  dsp_mac_rd;
  wire [`E203_XLEN-1:0] dsp_mac_adder_src0_1 = i_smal ? dsp_i_rs1_1 :  dsp_mac_rd_1;
  wire [`E203_XLEN-1:0] dsp_mac_adder_src1 = 
                                                    ({`E203_XLEN{dsp_mac_one_addend_op}}  & dsp_mul_rdw32_res) 
                                                |   ({`E203_XLEN{dsp_mac_two_addend_op}}  & dsp_mul_raw_res[`E203_XLEN-1:0]) 
                                                |   ({`E203_XLEN{dsp_mac_four_addend_op}} & {{16{dsp_mul_raw_res0_sign}},dsp_mul_raw_res[15:0]})
                                                |   ({`E203_XLEN{dsp_addsub_plex_mac_op}} & {24'b0,dsp_addsub_pb_res[7:0]})
                                                |   ({`E203_XLEN{dsp_mul_rd_need_rnd   }} & rnd_pre_rd[`E203_XLEN-1:0])
                                                ;
                                                   
  wire [`E203_XLEN-1:0] dsp_mac_adder_src2 = 
                                                    ({`E203_XLEN{dsp_mac_two_addend_op}}  & dsp_mul_raw_res[63:32])
                                                |   ({`E203_XLEN{dsp_mac_four_addend_op}} & {{16{dsp_mul_raw_res1_sign}},dsp_mul_raw_res[31:16]})
                                                |   ({`E203_XLEN{dsp_addsub_plex_mac_op}} & {24'b0,dsp_addsub_pb_res[15:8]})
                                                |   ({`E203_XLEN{dsp_mul_rd_need_rnd   }} & {{30{rnd_pre_rd[`E203_XLEN+1]}},rnd_pre_rd[`E203_XLEN+1:`E203_XLEN]})
                                                    ; 
  wire [15:0] dsp_mac_adder_src3 = 
                                    ({16{dsp_mac_four_addend_op}} & dsp_mul_raw_res[47:32])
                                 |  ({16{dsp_addsub_plex_mac_op}} & {8'b0,dsp_addsub_pb_res[23:16]})
                                 ;
  wire [15:0] dsp_mac_adder_src4 = 
                                    ({16{dsp_mac_four_addend_op}} & dsp_mul_raw_res[63:48])
                                 |  ({16{dsp_addsub_plex_mac_op}} & {8'b0,dsp_addsub_pb_res[31:24]})
                                 ;
  wire dsp_rs1idx_lsb = dsp_i_rs1idx[0];
  wire dsp_rdidx_lsb = dsp_i_rdidx[0];
  wire [2:0] dsp_addsub_pb_sign = dsp_addsub_pb_res[34:32];

  e203_exu_dsp_mac_adder u_e203_exu_dsp_mac_adder(
    .dsp_mac_op                     (dsp_mac_op          ),
    .dsp_addsub_plex_mac_op       (dsp_addsub_plex_mac_op),
    .dsp_mac_one_sp_two_addend_op (dsp_mac_one_sp_two_addend_op),
    .dsp_addsub_pb_sign             (dsp_addsub_pb_sign),
    .dsp_mul_rd_need_rnd            (dsp_mul_rd_need_rnd),     
    .dsp_concat_r1_op               (dsp_concat_r1_op    ),
    .dsp_rdw64_op                   (dsp_rdw64_op    ),
    .dsp_kmda_kmxda_op              (dsp_kmda_kmxda_op),
    .dsp_mac_sub_src1_op          (dsp_mac_sub_src1_op ),
    .dsp_mac_sub_src2_op          (dsp_mac_sub_src2_op ),
    .sat_mac_rd_q31               (sat_mac_rd_q31      ),   
    .sat_mac_rd_u64               (sat_mac_rd_u64      ),   
    .sat_mac_rd_q63               (sat_mac_rd_q63      ),   
    .dsp_i_rs1                      (dsp_i_rs1           ),
    .dsp_rs1idx_lsb                 (dsp_rs1idx_lsb     ),
    .dsp_rdidx_lsb                  (dsp_rdidx_lsb      ),
    .dsp_mac_adder_src0           (dsp_mac_adder_src0  ),
    .dsp_mac_adder_src0_1         (dsp_mac_adder_src0_1),
    .dsp_mac_adder_src1           (dsp_mac_adder_src1  ),
    .dsp_mac_adder_src2           (dsp_mac_adder_src2  ),
    .dsp_mac_adder_src3           (dsp_mac_adder_src3  ),
    .dsp_mac_adder_src4           (dsp_mac_adder_src4  ),
    .dsp_unsign_op_flag             (dsp_unsign_op_flag  ),
    .dsp_mac_o_wbck_wdat          (dsp_mac_o_wbck_wdat),
    .dsp_mac_o_wbck_wdat_1        (dsp_mac_o_wbck_wdat_1),
    .dsp_mac_wbck_err             (dsp_mac_o_wbck_err    ),
    .dsp_mac_mul_stage_ov         (dsp_mac_mul_stage_ov),
    .dsp_mac_o_wbck_ov            (dsp_mac_o_wbck_ov        ),   
    .clk                            (clk                 ),
    .rst_n                          (rst_n               )
  );
endmodule
