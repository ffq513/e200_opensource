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

  assign dsp_o_wbck_wdat = `E203_XLEN'h0;
  assign dsp_o_wbck_wdat_1 =`E203_XLEN'h0; //for 64bit write-back
  assign dsp_o_wbck_err = 1'b0 ;
  assign dsp_o_wbck_ov = 1'b0;   

  assign wext_hi_shift_left_req_o = 1'b0;

  assign wext_hi_shift_op1_o = `E203_XLEN'h0;
  assign wext_hi_shift_op2_o = `E203_XLEN'h0;
  assign dsp_i_ready = 1'b1;         // handshake
  assign dsp_o_valid = 1'b0;         // handshake
  assign dsp_mul_plex_alumul_rs1 = `E203_XLEN'h0;
  assign dsp_mul_plex_alumul_rs2 = `E203_XLEN'h0;



endmodule
