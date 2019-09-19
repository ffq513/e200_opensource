/*                                                                      
 Copyright 2018 Nuclei System Technology, Inc.                
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */                                                                      
                                                                         
                                                                         
                                                                         
//=====================================================================
//
// Designer   : Bob Hu
//
// Description:
//  The ALU module to implement the compute function unit
//    and the AGU (address generate unit) for LSU is also handled by ALU
//    additionaly, the shared-impelmentation of MUL and DIV instruction 
//    is also shared by ALU in E200
//
// ==================================================================== 
`include "e203_defines.v"

module e203_exu_alu_dsp(
  
  input  [`E203_XLEN-1:0] i_rs1,
  input  [`E203_XLEN-1:0] i_rs2,
  input  [`E203_XLEN-1:0] i_rs1_1,
  input  [`E203_XLEN-1:0] i_rs2_1,
  input  [`E203_RFIDX_WIDTH-1:0] i_rdidx,
  input  [`E203_RFIDX_WIDTH-1:0] i_rs1idx, 

  //////////////////////////////////////////////////////////////
  // write back 
  //////////////////////////////////////////////////////////////
  // dsp write back of a 64bit data's high 32 bits, to exu_wbck
  output [`E203_XLEN-1:0] dsp_o_wbck_wdat,
  output [`E203_XLEN-1:0] dsp_o_wbck_wdat_1, //for 64bit write-back
  output dsp_o_wbck_err,
  output dsp_o_wbck_ov,                     // to csr

  input  [`E203_DECINFO_DSP_WIDTH-1:0] i_dsp_info,

  //////////////////////////////////////////////////////////////
  // DSP WEXT high word left shift signals, reuse regular alu shifter 
  //////////////////////////////////////////////////////////////
  output wext_hi_shift_left_req_o,
  output [`E203_XLEN-1:0] wext_hi_shift_op1_o,
  output [`E203_XLEN-1:0] wext_hi_shift_op2_o,
  input  [`E203_XLEN-1:0] wext_hi_shift_res_i,


  input  dsp_i_valid,         // handshake
  output dsp_i_ready,         // handshake

  output dsp_o_valid,         // handshake
  input  dsp_o_ready,         // handshake

  output [`E203_XLEN:0] dsp_mul_plex_alumul_rs1,
  output [`E203_XLEN:0] dsp_mul_plex_alumul_rs2,
  input  [`E203_XLEN*2-1:0] dsp_plex_alumul_res,

  //////////////////////////////////////////////////////////////
  // clock and reset
  //////////////////////////////////////////////////////////////
  input  clk,
  input  rst_n

  );


  assign dsp_o_valid = dsp_i_valid;
  assign dsp_i_ready = dsp_o_ready;

///////////////////////////////////////////////////////////////////////////////////////
// common used signals
///////////////////////////////////////////////////////////////////////////////////////
// dsp rs/rd
  wire [`E203_XLEN-1:0]              dsp_i_rs1    = i_rs1;
  wire [`E203_XLEN-1:0]              dsp_i_rs2    = i_rs2;
  wire [`E203_XLEN-1:0]              dsp_i_rs1_1  = i_rs1_1;
  wire [`E203_XLEN-1:0]              dsp_i_rs2_1  = i_rs2_1;
  wire [`E203_XLEN-1:0]              dsp_i_rd     = i_rs1_1;
  wire [`E203_XLEN-1:0]              dsp_i_rd_1   = i_rs2_1;
  wire [`E203_XLEN-1:0]              dsp_i_rc     = i_rs2_1;
  wire  [`E203_RFIDX_WIDTH-1:0]      dsp_i_rdidx  = i_rdidx;
  wire  [`E203_RFIDX_WIDTH-1:0]      dsp_i_rs1idx = i_rs1idx; 
  wire [`E203_DECINFO_DSP_WIDTH-1:0] dsp_i_info   = i_dsp_info;


  wire dsp_shift_op = i_dsp_info[`E203_DECINFO_DSP_SHIFT_OP];
  wire [`E203_XLEN-1:0] dsp_shift_o_wbck_wdat;
  wire dsp_shift_o_wbck_err;
  wire dsp_shift_o_wbck_ov;
 
  wire dsp_mul_op = i_dsp_info[`E203_DECINFO_DSP_MULOP];
  wire dsp_mac_op = i_dsp_info[`E203_DECINFO_DSP_LONGPOP];
  wire dsp_hmul_simd_o_op;
  wire [`E203_XLEN:0] dsp_mul16_adder_op1;
  wire [`E203_XLEN:0] dsp_mul16_adder_op2;
  wire [`E203_XLEN+1:0] dsp_mul16_adder_res;
  wire [`E203_XLEN-1:0] dsp_mul_o_wbck_wdat;
  wire [`E203_XLEN-1:0] dsp_mul_o_wbck_wdat_1;
  wire dsp_mul_o_wbck_err;

  wire [`E203_XLEN-1:0] dsp_mac_o_wbck_wdat;
  wire [`E203_XLEN-1:0] dsp_mac_o_wbck_wdat_1;
  wire dsp_mac_o_wbck_err;

  wire dsp_misc_op = i_dsp_info[`E203_DECINFO_DSP_MISC_OP];
  wire dsp_misc_i_ready;
  wire dsp_misc_o_ready;
  wire [`E203_XLEN-1:0] dsp_misc_o_wbck_wdat;
  wire dsp_misc_o_wbck_err;
  wire dsp_misc_o_wbck_ov;

  wire dsp_addsub_op = dsp_i_info[`E203_DECINFO_DSP_GPR_ADDSUB];


  wire [`E203_XLEN-1:0] dsp_addsub_wbck_wdat_o   ;
  wire [`E203_XLEN-1:0] dsp_addsub_wbck_wdat_1_o ;
  wire dsp_addsub_o_wbck_err;
  wire dsp_addsub_wbck_ov;



///////////////////////////////////////////////////////////////////////////////////////
// dsp_addsub
///////////////////////////////////////////////////////////////////////////////////////

  wire [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_addsub_big_op1   ;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_addsub_big_op2   ; 
  wire [`E203_DSP_LITADDER_WIDTH-1:0] dsp_addsub_little_op1;
  wire [`E203_DSP_LITADDER_WIDTH-1:0] dsp_addsub_little_op2;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_res        ; 
  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_res     ;
  wire [`E203_XLEN+2:0] dsp_addsub_pb_res    ;//{cin[2:0], abs[31:0]}
  wire                                dsp_adder_req        ;
  wire                                dsp_sub_en           ;

  e203_exu_dsp_addsub u_e203_exu_dsp_addsub(

      .dsp_addsub_rs1_i           ( dsp_i_rs1              ),
      .dsp_addsub_rs2_i           ( dsp_i_rs2              ),
      .dsp_addsub_rs1_1_i         ( dsp_i_rs1_1            ),
      .dsp_addsub_rs2_1_i         ( dsp_i_rs2_1            ),
      .dsp_addsub_info_i          ( dsp_i_info             ), 

      .dsp_addsub_big_res_i       ( adder_big_res          ),
      .dsp_addsub_little_res_i    ( adder_little_res       ),

      .dsp_addsub_pbs_o           ( dsp_addsub_pb_res      ),
      .dsp_addsub_wbck_wdat_o     ( dsp_addsub_wbck_wdat_o ),
      .dsp_addsub_wbck_wdat_1_o   ( dsp_addsub_wbck_wdat_1_o),
      .dsp_addsub_big_op1_o       ( dsp_addsub_big_op1     ),
      .dsp_addsub_big_op2_o       ( dsp_addsub_big_op2     ),
      .dsp_addsub_little_op1_o    ( dsp_addsub_little_op1  ),
      .dsp_addsub_little_op2_o    ( dsp_addsub_little_op2  ),
      .dsp_addsub_ov_wbck_o       ( dsp_addsub_wbck_ov     ),

      .dsp_adder_req_o            ( dsp_adder_req          ),
      .dsp_sub_en_o               ( dsp_sub_en             )
  );

///////////////////////////////////////////////////////////////////////////////////////
// dsp_addsub_dpath
// dsp mult & mac, dsp addsub and dsp shift reuse dsp addsub dpath
///////////////////////////////////////////////////////////////////////////////////////
  wire shift_add_req;
  wire addsub_op = dsp_adder_req | shift_add_req | dsp_hmul_simd_o_op;

  wire [`E203_DSP_BIGADDER_WIDTH-1:0] shift_add_big_op1;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] shift_add_big_op2;

  wire dsp_adder_sub_en =  
                          (dsp_adder_req & dsp_sub_en)
                        | (dsp_hmul_simd_o_op & 1'b0);

  wire [`E203_DSP_LITADDER_WIDTH-1:0] dsp_adder_little_op1  =
                                                          ({`E203_DSP_LITADDER_WIDTH{dsp_adder_req}} & dsp_addsub_little_op1)
                                                        | ({`E203_DSP_LITADDER_WIDTH{dsp_hmul_simd_o_op}} & `E203_DSP_LITADDER_WIDTH'b0)
                                                        ;

  wire [`E203_DSP_LITADDER_WIDTH-1:0] dsp_adder_little_op2  =
                                                          ({`E203_DSP_LITADDER_WIDTH{dsp_adder_req}} & dsp_addsub_little_op2)
                                                        | ({`E203_DSP_LITADDER_WIDTH{dsp_hmul_simd_o_op}} & `E203_DSP_LITADDER_WIDTH'b0)
                                                        ;

  wire [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_adder_big_op1 = 
                                                          ({`E203_DSP_BIGADDER_WIDTH{dsp_adder_req}} & dsp_addsub_big_op1)
                                                        | ({`E203_DSP_BIGADDER_WIDTH{dsp_hmul_simd_o_op}} &
                                                           {{(`E203_DSP_BIGADDER_WIDTH-`E203_XLEN-1){dsp_mul16_adder_op1[`E203_XLEN]}},dsp_mul16_adder_op1});

  wire [`E203_DSP_BIGADDER_WIDTH-1:0] dsp_adder_big_op2 = 
                                                          ({`E203_DSP_BIGADDER_WIDTH{dsp_adder_req}} & dsp_addsub_big_op2)
                                                        | ({`E203_DSP_BIGADDER_WIDTH{dsp_hmul_simd_o_op}} &
                                                           {{(`E203_DSP_BIGADDER_WIDTH-`E203_XLEN-1){dsp_mul16_adder_op2[`E203_XLEN]}},dsp_mul16_adder_op2});
  assign  dsp_mul16_adder_res = adder_big_res[`E203_XLEN+1:0];                                                       

  wire [`E203_DSP_ADDER_PACK_WIDTH-1:0] dsp_addsub_pack =  {
                                                             dsp_adder_sub_en     ,
                                                             dsp_adder_little_op1 ,
                                                             dsp_adder_little_op2 ,
                                                             dsp_adder_big_op1    ,
                                                             dsp_adder_big_op2    
                                                           };

  wire [`E203_DSP_ADDER_PACK_WIDTH-1:0] shift_add_pack  =  {
                                                             1'b0                        ,
                                                             `E203_DSP_LITADDER_WIDTH'b0 ,
                                                             `E203_DSP_LITADDER_WIDTH'b0 ,
                                                             shift_add_big_op1           ,
                                                             shift_add_big_op2            
                                                           };

  wire [`E203_DSP_ADDER_PACK_WIDTH-1:0] adder_pack      =  
                                                             ({`E203_DSP_ADDER_PACK_WIDTH{dsp_adder_req | dsp_hmul_simd_o_op}} & dsp_addsub_pack)
                                                           | ({`E203_DSP_ADDER_PACK_WIDTH{shift_add_req}} & shift_add_pack)
                                                           ; 

  wire sub_en = adder_pack[`E203_DSP_ADDER_PACK_WIDTH-1];
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_op1    = adder_pack[`E203_DSP_BIGADDER_OP1];
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_op2    = adder_pack[`E203_DSP_BIGADDER_OP2];
  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_op1 = adder_pack[`E203_DSP_LITADDER_OP1];
  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_op2 = adder_pack[`E203_DSP_LITADDER_OP2];

  e203_exu_dsp_adder u_e203_exu_dsp_adder(

      .dsp_req_addsub_i           ( addsub_op              ),
      .dsp_req_sub_en_i           ( sub_en                 ),

      .adder_big_op1_i            ( adder_big_op1          ),
      .adder_big_op2_i            ( adder_big_op2          ), 
      .adder_little_op1_i         ( adder_little_op1       ),
      .adder_little_op2_i         ( adder_little_op2       ),

      .adder_big_res_o            ( adder_big_res          ),
      .adder_little_res_o         ( adder_little_res       )
  );

///////////////////////////////////////////////////////////////////////////////////////
// dsp shift datapath
///////////////////////////////////////////////////////////////////////////////////////
// bitrev/wext/shift instructions resuse this datapath
// bitrev instructions reuse shifter(srl type)

////////////////////////////////////
// bitrev signals
  wire br_shift_right_req;
  wire br_shift_left_req = 1'b0;
  wire [`E203_XLEN-1:0] br_shift_op1;
  wire [4:0] br_shift_op2;
//  wire [`E203_XLEN-1:0] br_shift_res;
  wire br_shift_req = br_shift_right_req | br_shift_left_req;

////////////////////////////////////
// wext instructions's low word reuse shifter(srl type)
  wire wext_lo_shift_right_req;
  wire wext_lo_shift_left_req = 1'b0;
  wire [`E203_XLEN-1:0] wext_lo_shift_op1;
  wire [4:0] wext_lo_shift_op2;
//  wire [`E203_XLEN-1:0] wext_shift_res = `E203_XLEN'b0;
  wire wext_lo_shift_req = wext_lo_shift_right_req | wext_lo_shift_left_req;

////////////////////////////////////
// shift signals
  wire shift_right_req;
  wire shift_left_req;
  wire [`E203_XLEN-1:0] shift_op1;
  wire [4:0] shift_op2;
  wire [`E203_XLEN-1:0] shift_res;
  wire shift_req = shift_right_req | shift_left_req;

////////////////////////////////////
// shift datapath mux
  wire dp_shift_right_req;
  wire dp_shift_left_req;
  wire dp_shift_req;
  wire [`E203_XLEN-1:0] dp_shift_op1;
  wire [4:0] dp_shift_op2;
  wire [`E203_XLEN-1:0] dp_shift_right_res;
  wire [`E203_XLEN-1:0] dp_shift_left_res;
//  wire [`E203_XLEN-1:0] dp_shift_eff_mask;

  assign dp_shift_right_req = br_shift_right_req | wext_lo_shift_right_req | shift_right_req;
  assign dp_shift_left_req  = br_shift_left_req  | wext_lo_shift_left_req  | shift_left_req;
  assign dp_shift_req       = dp_shift_right_req | dp_shift_left_req;

  assign dp_shift_op1 =  
                          ({`E203_XLEN{br_shift_req      }} & br_shift_op1     )
						| ({`E203_XLEN{wext_lo_shift_req }} & wext_lo_shift_op1)
						| ({`E203_XLEN{shift_req         }} & shift_op1        )
						;

  assign dp_shift_op2 =  
                          ({5{br_shift_req      }} & br_shift_op2     )
						| ({5{wext_lo_shift_req }} & wext_lo_shift_op2)
						| ({5{shift_req         }} & shift_op2        )
						;

////////////////////////////////////
// inst shift datapath module
  e203_exu_dsp_shift_dp u_e203_exu_dsp_shift_dp(
  	.dp_shift_right_req_i         ( dp_shift_right_req     ),
  	.dp_shift_left_req_i          ( dp_shift_left_req      ),
  	.dp_shift_op1_i               ( dp_shift_op1           ),
  	.dp_shift_op2_i               ( dp_shift_op2           ),
  	.dp_shift_right_res_o         ( dp_shift_right_res     ),
  	.dp_shift_left_res_o          ( dp_shift_left_res      )
  );

///////////////////////////////////////////////////////////////////////////////////////
// dsp_shift
///////////////////////////////////////////////////////////////////////////////////////
  // shift module logic gating
  wire [`E203_XLEN-1:0] dsp_shift_rs1 = ({`E203_XLEN{dsp_shift_op}} & dsp_i_rs1);
  wire [`E203_XLEN-1:0] dsp_shift_rs2 = ({`E203_XLEN{dsp_shift_op}} & dsp_i_rs2);

  e203_exu_dsp_shift u_e203_exu_dsp_shift(
  	.dsp_i_rs1                    ( dsp_shift_rs1          ),
  	.dsp_i_rs2                    ( dsp_shift_rs2          ),  
  	.dsp_i_info                   ( dsp_i_info             ),
  	.round_req_o                  ( shift_add_req          ),
  	.round_op1_o                  ( shift_add_big_op1      ),
  	.round_op2_o                  ( shift_add_big_op2      ),
  	.round_res_i                  ( adder_big_res          ),
  	.shift_right_req_o            ( shift_right_req        ),
  	.shift_left_req_o             ( shift_left_req         ),
  	.shift_op1_o                  ( shift_op1              ),
  	.shift_op2_o                  ( shift_op2              ),
  	.shift_right_res_i            ( dp_shift_right_res     ),
  	.shift_left_res_i             ( dp_shift_left_res      ),
  	.dsp_o_wbck_wdat              ( dsp_shift_o_wbck_wdat  ),
  	.dsp_o_wbck_ov                ( dsp_shift_o_wbck_ov    ),
  	.dsp_o_wbck_err               ( dsp_shift_o_wbck_err   )
  );

///////////////////////////////////////////////////////////////////////////////////////
// dsp_misc
///////////////////////////////////////////////////////////////////////////////////////
  // misc module logic gating, only need to gate dsp_i_rs1 and dsp_i_rs2, 
  // others like dsp_i_rs1_64, dsp_i_rc and dsp_i_rd seem unneccesary to gate
  wire [`E203_XLEN-1:0] dsp_misc_rs1 = ({`E203_XLEN{dsp_misc_op}} & dsp_i_rs1);
  wire [`E203_XLEN-1:0] dsp_misc_rs2 = ({`E203_XLEN{dsp_misc_op}} & dsp_i_rs2);

  e203_exu_dsp_misc u_e203_exu_dsp_misc (
  	.dsp_i_rs1                    ( dsp_misc_rs1             ),
  	.dsp_i_rs1_64                 ( dsp_i_rs1_1              ), // high 32 bits of a 64 bit data
  	.dsp_i_rs2                    ( dsp_misc_rs2             ),
  	.dsp_i_rc                     ( dsp_i_rc                 ), // read rc read port, 
  	.dsp_i_rd                     ( dsp_i_rd                 ), // read rd read port
  	.dsp_i_info                   ( dsp_i_info               ),
  	.br_shift_right_req_o         ( br_shift_right_req       ),
  	.br_shift_op1_o               ( br_shift_op1             ),
  	.br_shift_op2_o               ( br_shift_op2             ),
  	.br_shift_res_i               ( dp_shift_right_res       ),
  	.wext_lo_shift_right_req_o    ( wext_lo_shift_right_req  ),
  	.wext_lo_shift_op1_o          ( wext_lo_shift_op1        ),
  	.wext_lo_shift_op2_o          ( wext_lo_shift_op2        ),
  	.wext_lo_shift_res_i          ( dp_shift_right_res       ),
  	.wext_hi_shift_left_req_o     ( wext_hi_shift_left_req_o ),
  	.wext_hi_shift_op1_o          ( wext_hi_shift_op1_o      ),
  	.wext_hi_shift_op2_o          ( wext_hi_shift_op2_o      ),
  	.wext_hi_shift_res_i          ( wext_hi_shift_res_i      ),  // shift left result input 
  	.dsp_o_wbck_wdat              ( dsp_misc_o_wbck_wdat     ),
  	.dsp_o_wbck_err               ( dsp_misc_o_wbck_err      ),
  	.dsp_o_wbck_ov                ( dsp_misc_o_wbck_ov       ),
  	.dsp_misc_op_i                ( dsp_misc_op              ),
  	.clk                          ( clk                      ),
  	.rst_n                        ( rst_n                    )
  );

///////////////////////////////////////////////////////////////////////////////////////
// dsp_mulmac
///////////////////////////////////////////////////////////////////////////////////////
  wire  dsp_mul_o_wbck_ov;
  wire  dsp_mac_o_wbck_ov;
  wire  dsp_unsign_op_flag;
  wire [`E203_XLEN-1:0] dsp_mul_rdw32_res;
  wire [`E203_XLEN*2-1:0] dsp_mul_raw_res;
//  wire [`E203_XLEN*2-1:0] dsp_plex_alumul_res;

  e203_exu_dsp_mul u_e203_exu_dsp_mul(
   .i_dsp_info              (i_dsp_info),
   .dsp_i_rs1               (dsp_i_rs1),
   .dsp_i_rs2               (dsp_i_rs2),
   .dsp_unsign_op_flag      (dsp_unsign_op_flag),
   .dsp_mul_plex_alumul_rs1 (dsp_mul_plex_alumul_rs1),
   .dsp_mul_plex_alumul_rs2 (dsp_mul_plex_alumul_rs2),
   .dsp_plex_alumul_res     (dsp_plex_alumul_res),
   .dsp_hmul_simd_o_op      (dsp_hmul_simd_o_op),
   .dsp_mul16_adder_op1     (dsp_mul16_adder_op1),
   .dsp_mul16_adder_op2     (dsp_mul16_adder_op2),
   .dsp_mul16_adder_res     (dsp_mul16_adder_res),
   .dsp_mul_rdw32_res       (dsp_mul_rdw32_res),
   .dsp_mul_raw_res         (dsp_mul_raw_res),
   .dsp_mul_o_wbck_ov       (dsp_mul_o_wbck_ov),
   .dsp_mul_o_wbck_wdat     (dsp_mul_o_wbck_wdat),        
   .dsp_mul_o_wbck_wdat_1   (dsp_mul_o_wbck_wdat_1),        
   .dsp_mul_o_wbck_err      (dsp_mul_o_wbck_err)
  );



  e203_exu_dsp_mac  u_e203_exu_dsp_mac(
  .dsp_unsign_op_flag        (dsp_unsign_op_flag),
  .dsp_mul_o_wbck_ov         (dsp_mul_o_wbck_ov),
  .dsp_i_rdidx               (dsp_i_rdidx),
  .dsp_i_rs1idx              (dsp_i_rs1idx),
  .dsp_i_rs1_1               (dsp_i_rs1_1),
  .dsp_i_rs1                 (dsp_i_rs1),
  .dsp_i_rd                  (dsp_i_rd),
  .dsp_i_rd_1                (dsp_i_rd_1),
  .dsp_mul_rdw32_res         (dsp_mul_rdw32_res),
  .dsp_mul_raw_res           (dsp_mul_raw_res),
  .dsp_addsub_pb_res         (dsp_addsub_pb_res),
  .i_dsp_info                (i_dsp_info),
  .dsp_mac_o_wbck_ov       (dsp_mac_o_wbck_ov),
  .dsp_mac_o_wbck_wdat     (dsp_mac_o_wbck_wdat),        
  .dsp_mac_o_wbck_wdat_1   (dsp_mac_o_wbck_wdat_1),        
  .dsp_mac_o_wbck_err      (dsp_mac_o_wbck_err),        
  .clk                       (clk),
  .rst_n                     (rst_n)
  );



///////////////////////////////////////////////////////////////////////////////////////
// 7. write back logic
///////////////////////////////////////////////////////////////////////////////////////

  assign dsp_o_wbck_wdat =  
                             ({`E203_XLEN{dsp_shift_op}} & dsp_shift_o_wbck_wdat)       
                           | ({`E203_XLEN{dsp_misc_op}} & dsp_misc_o_wbck_wdat)
                           | ({`E203_XLEN{dsp_addsub_op}} & dsp_addsub_wbck_wdat_o)
                           | ({`E203_XLEN{dsp_mul_op}} &  dsp_mul_o_wbck_wdat)
                           | ({`E203_XLEN{dsp_mac_op}} &  dsp_mac_o_wbck_wdat)
                           ;

  assign dsp_o_wbck_wdat_1 =  
                             ({`E203_XLEN{dsp_mul_op}} &  dsp_mul_o_wbck_wdat_1)
                           | ({`E203_XLEN{dsp_addsub_op}} & dsp_addsub_wbck_wdat_1_o)
                           | ({`E203_XLEN{dsp_mac_op}} & dsp_mac_o_wbck_wdat_1)
                             ;
  
  assign dsp_o_wbck_err = 
                            // ({1{dsp_mac_op}} & dsp_mac_o_wbck_err)
                            ({1{dsp_mul_op}} & dsp_mul_o_wbck_err)
                            | ({1{dsp_mac_op}} & dsp_mac_o_wbck_err)
						   ; 

  assign dsp_o_wbck_ov  = ((dsp_addsub_wbck_ov | dsp_shift_o_wbck_ov | dsp_misc_o_wbck_ov | dsp_mul_o_wbck_ov | dsp_mac_o_wbck_ov) & dsp_o_valid & dsp_o_ready) 
						  // mac ov already have its handshaked inside mac module
                        //| dsp_mac_o_wbck_ov
                        ; 

endmodule
