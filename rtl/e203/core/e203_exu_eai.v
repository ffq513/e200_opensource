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
//  The EAI module to implement the
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_eai(

  input  eai_i_xs_off,
  input  eai_i_valid, // Handshake valid
  output eai_i_ready, // Handshake ready
  input [`E203_XLEN-1:0]   eai_i_instr,
  input [`E203_XLEN-1:0]   eai_i_rs1,
  input [`E203_XLEN-1:0]   eai_i_rs2,
  //input                    eai_i_mmode , // O: current insns' mmode 
  input  [`E203_ITAG_WIDTH-1:0] eai_i_itag,
  output eai_o_longpipe,

  // The eai Commit Interface
  output                        eai_o_valid, // Handshake valid
  input                         eai_o_ready, // Handshake ready

  //////////////////////////////////////////////////////////////
  // The eai write-back Interface
  output                        eai_o_itag_valid, // Handshake valid
  input                         eai_o_itag_ready, // Handshake ready
  output [`E203_ITAG_WIDTH-1:0] eai_o_itag,   

  //////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////
  // The eai Request Interface
  input                          eai_rsp_multicyc_valid , //I: current insn is multi-cycle.
  output                         eai_rsp_multicyc_ready , //O:                             

  output                         eai_req_valid, // Handshake valid
  input                          eai_req_ready, // Handshake ready
  output [`E203_XLEN-1:0]        eai_req_instr,
  output [`E203_XLEN-1:0]        eai_req_rs1,
  output [`E203_XLEN-1:0]        eai_req_rs2,
  //output                         eai_req_mmode , // O: current insns' mmode 


  input  clk,
  input  rst_n
  );

  //assign eai_req_mmode = eai_i_mmode;

  wire  eai_i_hsked = eai_i_valid & eai_i_ready;
  // when there is a valid insn and the cmt is ready, then send out the insn.
  wire   eai_req_valid_pos = eai_i_valid & eai_o_ready;
  assign eai_req_valid = ~eai_i_xs_off &  eai_req_valid_pos;
  // when eai is disable, its req_ready is assumed to 1.
  wire   eai_req_ready_pos = eai_i_xs_off ? 1'b1 : eai_req_ready;
  // eai reports ready to decode when its cmt is ready and the eai core is ready.
  assign eai_i_ready   = eai_req_ready_pos & eai_o_ready  ;
  // the eai isns is about to cmt when it is truly a valid eai insn and the eai core has accepted.
  assign eai_o_valid   = eai_i_valid   & eai_req_ready_pos;

  wire   fifo_o_vld;
  assign eai_rsp_multicyc_ready = eai_o_itag_ready & fifo_o_vld;


  assign eai_req_instr = eai_i_instr;
  assign eai_req_rs1 = eai_i_rs1;
  assign eai_req_rs2 = eai_i_rs2;

  assign eai_o_longpipe = ~eai_i_xs_off;


 wire itag_fifo_wen = eai_o_longpipe & (eai_req_valid & eai_req_ready); 
 wire itag_fifo_ren = eai_rsp_multicyc_valid & eai_rsp_multicyc_ready; 

wire          fifo_i_vld  = itag_fifo_wen;
wire          fifo_i_rdy;
wire [`E203_ITAG_WIDTH-1:0] fifo_i_dat = eai_i_itag;

wire          fifo_o_rdy = itag_fifo_ren;
wire [`E203_ITAG_WIDTH-1:0] fifo_o_dat; 
assign eai_o_itag_valid = fifo_o_vld & eai_rsp_multicyc_valid;
//assign eai_o_itag = {`E203_ITAG_WIDTH{eai_o_itag_valid}} & fifo_o_dat;
//ctrl path must be independent with data path to avoid timing-loop.
assign eai_o_itag = fifo_o_dat;

 sirv_gnrl_fifo # (
       .DP(4),
       .DW(`E203_ITAG_WIDTH),
       .CUT_READY(1) 
  ) u_eai_itag_fifo(
    .i_vld   (fifo_i_vld),
    .i_rdy   (fifo_i_rdy),
    .i_dat   (fifo_i_dat),
    .o_vld   (fifo_o_vld),
    .o_rdy   (fifo_o_rdy),
    .o_dat   (fifo_o_dat),
    .clk     (clk  ),
    .rst_n   (rst_n)
  );
  
endmodule                                      
