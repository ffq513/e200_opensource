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
// Designer   : zaixin
//
// Description:
//  The Module to realize a simple eai core
//
// ====================================================================
`include "e203_defines.v"

module sirv_eai_core (
    // System	
    input                         eai_clk             ,
    input                         eai_rst_n	          ,
    output                        eai_active	      ,
    output                        eai_mem_holdup	  ,
    // Control cmd_req
    input                         eai_req_valid       ,
    output                        eai_req_ready       ,
    input  [`E203_XLEN-1:0]       eai_req_inst        ,
    input  [`E203_XLEN-1:0]       eai_req_rs1         ,
    input  [`E203_XLEN-1:0]       eai_req_rs2         ,
    // Control cmd_rsp	
    output                        eai_rsp_valid       ,
    input                         eai_rsp_ready       ,
    output [`E203_XLEN-1:0]       eai_rsp_rdat        ,
    output                        eai_rsp_err    	  ,
    // Memory lsu_req	
    output                        eai_icb_cmd_valid   ,
    input                         eai_icb_cmd_ready   ,
    output [`E203_ADDR_SIZE-1:0]  eai_icb_cmd_addr    ,
    output                        eai_icb_cmd_read    ,
    output [`E203_XLEN-1:0]       eai_icb_cmd_wdata   ,
    output [1:0]                  eai_icb_cmd_size    ,
    // Memory lsu_rsp	
    input                         eai_icb_rsp_valid   ,
    output                        eai_icb_rsp_ready   ,
    input  [`E203_XLEN-1:0]       eai_icb_rsp_rdata   ,
    input                         eai_icb_rsp_err	

);

   ////////////////////////////////////////////////////////////
   // decode
   ////////////////////////////////////////////////////////////
   wire [6:0] opcode      = {7{eai_req_valid}} & eai_req_inst[6:0];
   wire [2:0] rv32_func3  = {3{eai_req_valid}} & eai_req_inst[14:12];
   wire [6:0] rv32_func7  = {7{eai_req_valid}} & eai_req_inst[31:25];

   wire opcode_custom0 = (opcode == 7'b0001011); 
   wire opcode_custom1 = (opcode == 7'b0101011); 
   wire opcode_custom2 = (opcode == 7'b1011011); 
   wire opcode_custom3 = (opcode == 7'b1111011); 

   wire rv32_func3_000 = (rv32_func3 == 3'b000); 
   wire rv32_func3_001 = (rv32_func3 == 3'b001); 
   wire rv32_func3_010 = (rv32_func3 == 3'b010); 
   wire rv32_func3_011 = (rv32_func3 == 3'b011); 
   wire rv32_func3_100 = (rv32_func3 == 3'b100); 
   wire rv32_func3_101 = (rv32_func3 == 3'b101); 
   wire rv32_func3_110 = (rv32_func3 == 3'b110); 
   wire rv32_func3_111 = (rv32_func3 == 3'b111); 

   wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000); 
   wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001); 
   wire rv32_func7_0000010 = (rv32_func7 == 7'b0000010); 
   wire rv32_func7_0000011 = (rv32_func7 == 7'b0000011); 
   wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
   wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101); 
   wire rv32_func7_0000110 = (rv32_func7 == 7'b0000110); 
   wire rv32_func7_0000111 = (rv32_func7 == 7'b0000111);
   wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000);
   wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
   wire rv32_func7_0001010 = (rv32_func7 == 7'b0001010);
   wire rv32_func7_0001011 = (rv32_func7 == 7'b0001011);

   wire eai_req_hsked     = eai_req_valid & eai_req_ready;
   wire eai_rsp_hsked     = eai_rsp_valid & eai_rsp_ready;
   wire eai_icb_rsp_hsked = eai_icb_rsp_valid & eai_icb_rsp_ready;

   wire custom0_setup    = opcode_custom0 & rv32_func3_011 & rv32_func7_0000000;//0
   wire custom0_rowsum   = opcode_custom0 & rv32_func3_110 & rv32_func7_0000001;//1
   wire custom0_colsum   = opcode_custom0 & rv32_func3_110 & rv32_func7_0000010;//2
   wire custom0_jj_init_ch   = opcode_custom0 & rv32_func3_011 & rv32_func7_0000011;//3
   wire custom0_jj_init_im   = opcode_custom0 & rv32_func3_011 & rv32_func7_0000100;//4
   wire custom0_jj_init_fs   = opcode_custom0 & rv32_func3_011 & rv32_func7_0000101;//5
   wire custom0_jj_init_pw   = opcode_custom0 & rv32_func3_011 & rv32_func7_0000110;//6
   wire custom0_jj_init_imaddr   = opcode_custom0 & rv32_func3_011 & rv32_func7_0000111;//7
   wire custom0_jj_loop   = opcode_custom0 & rv32_func3_100 & rv32_func7_0001000;//8
   wire custom0_jj_relu_q7   = opcode_custom0 & rv32_func3_100 & rv32_func7_0001001;//9
   wire custom0_jj_relu_size   = opcode_custom0 & rv32_func3_011 & rv32_func7_0001010;//10
   wire custom0_jj_init_bias   = opcode_custom0 & rv32_func3_011 & rv32_func7_0001011;//11
   

   parameter EAI_FSM = 4;
   parameter IDLE    = 4'h0;
   parameter SETUP   = 4'h1;
   parameter ROWSUM  = 4'h2;
   parameter COLSUM  = 4'h3;
   parameter JJ_INIT_CH  = 4'h4;
   parameter JJ_INIT_IM  = 4'h5;
   parameter JJ_INIT_FS  = 4'h6;
   parameter JJ_INIT_PW  = 4'h7;
   parameter JJ_INIT_IMADDR  = 4'h8;
   parameter JJ_LOOP  = 4'h9;
   parameter JJ_RELU_Q7  = 4'ha;
   parameter JJ_RELU_SIZE  = 4'hb;
   parameter JJ_INIT_BIAS  = 4'hc;
   
   wire [EAI_FSM-1:0] state_r;

   wire state_is_idle   = (state_r == IDLE);
   wire state_is_setup  = (state_r == SETUP);
   wire state_is_rowsum = (state_r == ROWSUM);
   wire state_is_colsum = (state_r == COLSUM);
   wire state_is_jj_init_ch = (state_r == JJ_INIT_CH);
   wire state_is_jj_init_im = (state_r == JJ_INIT_IM);
   wire state_is_jj_init_fs = (state_r == JJ_INIT_FS);
   wire state_is_jj_init_pw = (state_r == JJ_INIT_PW);
   wire state_is_jj_init_imaddr = (state_r == JJ_INIT_IMADDR);
   wire state_is_jj_loop = (state_r == JJ_LOOP);
   wire state_is_jj_relu_q7 = (state_r == JJ_RELU_Q7);
   wire state_is_jj_relu_size = (state_r == JJ_RELU_SIZE);
   wire state_is_jj_init_bias = (state_r == JJ_INIT_BIAS);


   wire custom0_setup_ena  = custom0_setup  & eai_req_hsked;
   wire custom0_rowsum_ena = custom0_rowsum & eai_req_hsked;
   wire custom0_colsum_ena = custom0_colsum & eai_req_hsked;
   wire custom0_jj_init_ch_ena = custom0_jj_init_ch & eai_req_hsked;
   wire custom0_jj_init_im_ena = custom0_jj_init_im & eai_req_hsked;
   wire custom0_jj_init_fs_ena = custom0_jj_init_fs & eai_req_hsked;
   wire custom0_jj_init_pw_ena = custom0_jj_init_pw & eai_req_hsked;
   wire custom0_jj_init_imaddr_ena = custom0_jj_init_imaddr & eai_req_hsked;
   wire custom0_jj_loop_ena = custom0_jj_loop & eai_req_hsked;
   wire custom0_jj_relu_q7_ena = custom0_jj_relu_q7 & eai_req_hsked;
   wire custom0_jj_relu_size_ena = custom0_jj_relu_size & eai_req_hsked;
   wire custom0_jj_init_bias_ena = custom0_jj_init_bias & eai_req_hsked;

   wire [EAI_FSM-1:0] next_state_idle  = custom0_setup_ena  ? SETUP  : 
                                         custom0_rowsum_ena ? ROWSUM :
                                         custom0_colsum_ena ? COLSUM : 
                                         custom0_jj_init_ch_ena ? JJ_INIT_CH : 
                                         custom0_jj_init_im_ena ? JJ_INIT_IM : 
                                         custom0_jj_init_fs_ena ? JJ_INIT_FS : 
                                         custom0_jj_init_pw_ena ? JJ_INIT_PW : 
                                         custom0_jj_init_imaddr_ena ? JJ_INIT_IMADDR : 
                                         custom0_jj_loop_ena ? JJ_LOOP :
                                         custom0_jj_relu_q7_ena ? JJ_RELU_Q7 :
                                         custom0_jj_relu_size_ena ? JJ_RELU_SIZE :
                                         custom0_jj_init_bias_ena ? JJ_INIT_BIAS :
                                                                IDLE   ;
   wire [EAI_FSM-1:0] next_state_setup  = IDLE;
   wire [EAI_FSM-1:0] next_state_rowsum = IDLE;
   wire [EAI_FSM-1:0] next_state_colsum = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_init_ch = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_init_im = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_init_fs = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_init_pw = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_init_imaddr = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_loop = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_relu_q7 = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_relu_size = IDLE;
   wire [EAI_FSM-1:0] next_state_jj_init_bias = IDLE;

   wire [EAI_FSM-1:0] next_state =   {EAI_FSM{state_is_idle}}   & next_state_idle   
                                   | {EAI_FSM{state_is_setup}}  & next_state_setup  
                                   | {EAI_FSM{state_is_rowsum}} & next_state_rowsum 
                                   | {EAI_FSM{state_is_colsum}} & next_state_colsum
                                   | {EAI_FSM{state_is_jj_init_ch}} & next_state_jj_init_ch
                                   | {EAI_FSM{state_is_jj_init_im}} & next_state_jj_init_im
                                   | {EAI_FSM{state_is_jj_init_fs}} & next_state_jj_init_fs
                                   | {EAI_FSM{state_is_jj_init_pw}} & next_state_jj_init_pw
                                   | {EAI_FSM{state_is_jj_init_imaddr}} & next_state_jj_init_imaddr
                                   | {EAI_FSM{state_is_jj_loop}} & next_state_jj_loop
                                   | {EAI_FSM{state_is_jj_relu_q7}} & next_state_jj_relu_q7
                                   | {EAI_FSM{state_is_jj_relu_size}} & next_state_jj_relu_size
                                   | {EAI_FSM{state_is_jj_init_bias}} & next_state_jj_init_bias
                                   ;

   
   //=================custom0_jj_init_bias start=========================//
   wire custom0_jj_init_bias_ret_next = custom0_jj_init_bias_ena;
   wire custom0_jj_init_bias_ret_r;
   wire custom0_jj_init_bias_ret = custom0_jj_init_bias_ret_r & state_is_jj_init_bias;
   sirv_gnrl_dffrs #(1) custom0_jj_init_bias_ret_dffrs (custom0_jj_init_bias_ret_next,custom0_jj_init_bias_ret_r, eai_clk, eai_rst_n);

   wire init_bias_ena  = custom0_jj_init_bias_ena;
   wire [`E203_XLEN-1:0] init_bias_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] init_bias_r ;
   wire [15:0] bias_shift = init_bias_r[15:0];
   wire [15:0] out_shift = init_bias_r[31:16];

   sirv_gnrl_dfflr #(32) init_bias_dfflr (init_bias_ena, init_bias_nxt, init_bias_r, eai_clk, eai_rst_n);


   wire bias_addr_ena  = custom0_jj_init_bias_ena;
   wire [`E203_XLEN-1:0] bias_addr_nxt  = eai_req_rs2;
   wire [`E203_XLEN-1:0] bias_addr_r ;
   sirv_gnrl_dfflr #(32) bias_addr_dfflr (bias_addr_ena, bias_addr_nxt, bias_addr_r, eai_clk, eai_rst_n);



   //=================custom0_jj_relu_size start=========================//
   wire custom0_jj_relu_size_ret_next = custom0_jj_relu_size_ena;
   wire custom0_jj_relu_size_ret_r;
   wire custom0_jj_relu_size_ret = custom0_jj_relu_size_ret_r & state_is_jj_relu_size;
   sirv_gnrl_dffrs #(1) custom0_jj_relu_size_ret_dffrs (custom0_jj_relu_size_ret_next,custom0_jj_relu_size_ret_r, eai_clk, eai_rst_n);

   wire relu_size_ena  = custom0_jj_relu_size_ena;
   wire [`E203_XLEN-1:0] relu_size_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] relu_size_r ;
   sirv_gnrl_dfflr #(32) relu_size_dfflr (relu_size_ena, relu_size_nxt, relu_size_r, eai_clk, eai_rst_n);


   wire relu_addr_ena  = custom0_jj_relu_size_ena;
   wire [`E203_XLEN-1:0] relu_addr_nxt  = eai_req_rs2;
   wire [`E203_XLEN-1:0] relu_addr_r ;
   sirv_gnrl_dfflr #(32) relu_addr_dfflr (relu_addr_ena, relu_addr_nxt, relu_addr_r, eai_clk, eai_rst_n);
   //=================custom0_jj_relu_q7===============================//



   //=================custom0_jj_init_ch start=========================//
   wire custom0_jj_init_ch_ret_next = custom0_jj_init_ch_ena;
   wire custom0_jj_init_ch_ret_r;
   wire custom0_jj_init_ch_ret = custom0_jj_init_ch_ret_r & state_is_jj_init_ch;
   sirv_gnrl_dffrs #(1) custom0_jj_init_ch_ret_dffrs (custom0_jj_init_ch_ret_next,custom0_jj_init_ch_ret_r, eai_clk, eai_rst_n);

   wire ch_im_in_ena  = custom0_jj_init_ch_ena;
   wire [`E203_XLEN-1:0] ch_im_in_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] ch_im_in_r ;
   sirv_gnrl_dfflr #(32) ch_im_in_dfflr (ch_im_in_ena, ch_im_in_nxt, ch_im_in_r, eai_clk, eai_rst_n);

   wire ch_im_out_ena  = custom0_jj_init_ch_ena;
   wire [`E203_XLEN-1:0] ch_im_out_nxt    = eai_req_rs2;
   wire [`E203_XLEN-1:0] ch_im_out_r ;
   sirv_gnrl_dfflr #(32) ch_im_out_dfflr (ch_im_out_ena, ch_im_out_nxt, ch_im_out_r, eai_clk, eai_rst_n);


   //=================custom0_jj_init_im start=========================//
   wire custom0_jj_init_im_ret_next = custom0_jj_init_im_ena;
   wire custom0_jj_init_im_ret_r;
   wire custom0_jj_init_im_ret = custom0_jj_init_im_ret_r & state_is_jj_init_im;
   sirv_gnrl_dffrs #(1) custom0_jj_init_im_ret_dffrs (custom0_jj_init_im_ret_next,custom0_jj_init_im_ret_r, eai_clk, eai_rst_n);

   wire dim_im_in_ena  = custom0_jj_init_im_ena;
   wire [`E203_XLEN-1:0] dim_im_in_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] dim_im_in_r ;
   sirv_gnrl_dfflr #(32) dim_im_in_dfflr (dim_im_in_ena, dim_im_in_nxt, dim_im_in_r, eai_clk, eai_rst_n);

   wire dim_im_out_ena  = custom0_jj_init_im_ena;
   wire [`E203_XLEN-1:0] dim_im_out_nxt    = eai_req_rs2;
   wire [`E203_XLEN-1:0] dim_im_out_r ;
   sirv_gnrl_dfflr #(32) dim_im_out_dfflr (dim_im_out_ena, dim_im_out_nxt, dim_im_out_r, eai_clk, eai_rst_n);

   //=================custom0_jj_init_fs start=========================//
   wire custom0_jj_init_fs_ret_next = custom0_jj_init_fs_ena;
   wire custom0_jj_init_fs_ret_r;
   wire custom0_jj_init_fs_ret = custom0_jj_init_fs_ret_r & state_is_jj_init_fs;
   sirv_gnrl_dffrs #(1) custom0_jj_init_fs_ret_dffrs (custom0_jj_init_fs_ret_next,custom0_jj_init_fs_ret_r, eai_clk, eai_rst_n);

   wire filter_size_ena  = custom0_jj_init_fs_ena;
   wire [`E203_XLEN-1:0] filter_size_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] filter_size_r ;
   sirv_gnrl_dfflr #(32) filter_size_dfflr (filter_size_ena, filter_size_nxt, filter_size_r, eai_clk, eai_rst_n);

   wire stride_ena  = custom0_jj_init_fs_ena;
   wire [`E203_XLEN-1:0] stride_nxt    = eai_req_rs2;
   wire [`E203_XLEN-1:0] stride_r ;
   sirv_gnrl_dfflr #(32) stride_dfflr (stride_ena, stride_nxt, stride_r, eai_clk, eai_rst_n);
 
   //=================custom0_jj_init_pw start=========================//
   wire custom0_jj_init_pw_ret_next = custom0_jj_init_pw_ena;
   wire custom0_jj_init_pw_ret_r;
   wire custom0_jj_init_pw_ret = custom0_jj_init_pw_ret_r & state_is_jj_init_pw;
   sirv_gnrl_dffrs #(1) custom0_jj_init_pw_ret_dffrs (custom0_jj_init_pw_ret_next,custom0_jj_init_pw_ret_r, eai_clk, eai_rst_n);

   wire padding_ena  = custom0_jj_init_pw_ena;
   wire [`E203_XLEN-1:0] padding_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] padding_r ;
   sirv_gnrl_dfflr #(32) padding_dfflr (padding_ena, padding_nxt, padding_r, eai_clk, eai_rst_n);

   wire wt_addr_ena  = custom0_jj_init_pw_ena;
   wire [`E203_XLEN-1:0] wt_addr_nxt    = eai_req_rs2;
   wire [`E203_XLEN-1:0] wt_addr_r ;
   sirv_gnrl_dfflr #(32) wt_addr_dfflr (wt_addr_ena, wt_addr_nxt, wt_addr_r, eai_clk, eai_rst_n);

   //=================custom0_jj_init_imaddr start=========================//
   wire custom0_jj_init_imaddr_ret_next = custom0_jj_init_imaddr_ena;
   wire custom0_jj_init_imaddr_ret_r;
   wire custom0_jj_init_imaddr_ret = custom0_jj_init_imaddr_ret_r & state_is_jj_init_imaddr;
   sirv_gnrl_dffrs #(1) custom0_jj_init_imaddr_ret_dffrs (custom0_jj_init_imaddr_ret_next,custom0_jj_init_imaddr_ret_r, eai_clk, eai_rst_n);

   wire im_in_addr_ena  = custom0_jj_init_imaddr_ena;
   wire [`E203_XLEN-1:0] im_in_addr_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] im_in_addr_r ;
   sirv_gnrl_dfflr #(32) im_in_addr_dfflr (im_in_addr_ena, im_in_addr_nxt, im_in_addr_r, eai_clk, eai_rst_n);

   wire im_out_addr_ena  = custom0_jj_init_imaddr_ena;
   wire [`E203_XLEN-1:0] im_out_addr_nxt    = eai_req_rs2;
   wire [`E203_XLEN-1:0] im_out_addr_r ;
   sirv_gnrl_dfflr #(32) im_out_addr_dfflr (im_out_addr_ena, im_out_addr_nxt, im_out_addr_r, eai_clk, eai_rst_n);



   //=================custom0_setup start=========================//
   wire custom0_setup_ret_next = custom0_setup_ena;
   wire custom0_setup_ret_r;
   wire custom0_setup_ret = custom0_setup_ret_r & state_is_setup;
   sirv_gnrl_dffrs #(1) custom0_setup_ret_dffrs (custom0_setup_ret_next,custom0_setup_ret_r, eai_clk, eai_rst_n);

   wire matrix_entry_addr_ena  = custom0_setup_ena;
   wire [`E203_XLEN-1:0] matrix_entry_addr_nxt  = eai_req_rs1;
   wire [`E203_XLEN-1:0] matrix_entry_addr_r ;
   sirv_gnrl_dfflr #(32) matrix_entry_addr_dfflr (matrix_entry_addr_ena, matrix_entry_addr_nxt, matrix_entry_addr_r, eai_clk, eai_rst_n);

   wire matrix_size_ena  = custom0_setup_ena;
   wire [`E203_XLEN-1:0] matrix_size_nxt    = eai_req_rs2;
   wire [`E203_XLEN-1:0] matrix_size_r ;
   sirv_gnrl_dfflr #(32) matrix_size_dfflr (matrix_size_ena, matrix_size_nxt, matrix_size_r, eai_clk, eai_rst_n);

   //==================custom0_jj_loop start===========================//
   //
   //

   wire store_im_out;
   wire re_conv_out;

   wire [`E203_ADDR_SIZE-1:0] in_row ;
   wire [`E203_ADDR_SIZE-1:0] in_col ;
   wire in_row_is_not_negative = (in_row >= 0);
   wire in_col_is_not_negative = (in_col >= 0);

   wire in_row_loop = (in_row < dim_im_in_r);
   wire in_col_loop = (in_col < dim_im_in_r);

   wire cnt_l_start = in_row_is_not_negative & in_col_is_not_negative & in_row_loop & in_col_loop;

   wire [`E203_ADDR_SIZE-1:0] cnt_l_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_l_max = ch_im_in_r - 32'b1;
   wire cnt_l_loop = (cnt_l_r < cnt_l_max);
   wire cnt_l_end =  (cnt_l_r == cnt_l_max);  
   wire [`E203_ADDR_SIZE-1:0] cnt_l_nxt = (cnt_l_loop) ? cnt_l_r + 1'b1 : 32'b0;

   wire [1:0] cnt_load_dat_r;
   wire load_dat_end = (cnt_load_dat_r == 2'b1);
   wire cnt_load_dat_ena = state_is_jj_loop & cnt_l_start & (~store_im_out) & (~re_conv_out);
   wire [1:0] cnt_load_dat_nxt = (load_dat_end) ? 2'b0 : cnt_load_dat_r + 2'b1;
   sirv_gnrl_dfflr #(2) cnt_load_dat_dfflr (cnt_load_dat_ena, cnt_load_dat_nxt, cnt_load_dat_r, eai_clk, eai_rst_n);

   wire load_dat_fi = load_dat_end & (~store_im_out) & (~re_conv_out);
   wire cnt_l_ena = state_is_jj_loop & ( cnt_l_end | cnt_l_start & cnt_l_loop ) & load_dat_fi;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_l_dfflr (cnt_l_ena, cnt_l_nxt, cnt_l_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_n_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_n_max = filter_size_r - 32'b1;
   wire cnt_n_loop = (cnt_n_r <  cnt_n_max);
   wire cnt_n_end =  (cnt_n_r == cnt_n_max);
   wire [`E203_ADDR_SIZE-1:0] cnt_n_nxt = (cnt_n_loop) ? cnt_n_r + 1'b1 : 32'b0;
   wire cnt_n_ena = state_is_jj_loop & (cnt_l_end & cnt_l_start & load_dat_fi | ~(cnt_l_start));
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_n_dfflr (cnt_n_ena, cnt_n_nxt, cnt_n_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_m_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_m_max = cnt_n_max;
   wire cnt_m_loop = (cnt_m_r < cnt_m_max);
   wire cnt_m_end = (cnt_m_r == cnt_m_max);
   wire cnt_nl_end = (cnt_n_end & cnt_l_end & cnt_l_start & load_dat_fi ) | cnt_n_end & (~cnt_l_start);
   wire [`E203_ADDR_SIZE-1:0] cnt_m_nxt = (cnt_m_loop) ? cnt_m_r + 1'b1 : 32'b0;
   wire cnt_m_ena = state_is_jj_loop & cnt_nl_end ;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_m_dfflr (cnt_m_ena, cnt_m_nxt, cnt_m_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_k_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_k_max = dim_im_out_r - 32'b1;
   wire cnt_k_loop = (cnt_k_r < cnt_k_max);
   wire cnt_k_end = (cnt_k_r == cnt_k_max);
   wire cnt_mnl_end = cnt_m_end & cnt_nl_end;
   wire [`E203_ADDR_SIZE-1:0] cnt_k_nxt = (cnt_k_loop) ? cnt_k_r + 1'b1 : 32'b0;
   wire cnt_k_ena = state_is_jj_loop & cnt_mnl_end ;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_k_dfflr (cnt_k_ena, cnt_k_nxt, cnt_k_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_j_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_j_max = cnt_k_max;
   wire cnt_j_loop = (cnt_j_r < cnt_j_max);
   wire cnt_j_end = (cnt_j_r == cnt_j_max);
   wire cnt_kmnl_end = cnt_k_end & cnt_mnl_end;
   wire [`E203_ADDR_SIZE-1:0] cnt_j_nxt = (cnt_j_loop) ? cnt_j_r + 1'b1 : 32'b0;
   wire cnt_j_ena = state_is_jj_loop & cnt_kmnl_end;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_j_dfflr (cnt_j_ena, cnt_j_nxt, cnt_j_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_i_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_i_max = ch_im_out_r - 32'b1;
   wire cnt_i_loop = (cnt_i_r < cnt_i_max);
   wire cnt_i_end = (cnt_i_r == cnt_i_max);
   wire cnt_jkmnl_end = cnt_j_end & cnt_kmnl_end;
   wire [`E203_ADDR_SIZE-1:0] cnt_i_nxt = (cnt_i_loop) ? cnt_i_r + 1'b1 : 32'b0;
   wire cnt_i_ena = state_is_jj_loop & cnt_jkmnl_end ;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_i_dfflr (cnt_i_ena, cnt_i_nxt, cnt_i_r, eai_clk, eai_rst_n);

   wire cnt_ijkmnl_end = cnt_jkmnl_end & cnt_i_end;
   assign in_row = stride_r * cnt_j_r + cnt_m_r - padding_r;
   assign in_col = stride_r * cnt_k_r + cnt_n_r - padding_r;
   wire [`E203_ADDR_SIZE-1:0] im_in_real_addr = im_in_addr_r + (in_row * dim_im_in_r + in_col) * ch_im_in_r + cnt_l_r;
   wire [`E203_ADDR_SIZE-1:0] wt_real_addr = wt_addr_r + (cnt_i_r * ch_im_in_r * filter_size_r * filter_size_r + (cnt_m_r * filter_size_r + cnt_n_r) * ch_im_in_r + cnt_l_r);
   wire [`E203_ADDR_SIZE-1:0] bias_real_addr = bias_addr_r + cnt_i_r;


   wire [`E203_ADDR_SIZE-1:0] im_in_real_addr_r;
   wire [`E203_ADDR_SIZE-1:0] im_in_real_addr_nxt = im_in_real_addr;
   sirv_gnrl_dffr #(`E203_ADDR_SIZE) im_in_real_addr_dffr (im_in_real_addr_nxt, im_in_real_addr_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] wt_real_addr_r;
   wire [`E203_ADDR_SIZE-1:0] wt_real_addr_nxt = wt_real_addr;
   sirv_gnrl_dffr #(`E203_ADDR_SIZE) wt_real_addr_dffr (wt_real_addr_nxt, wt_real_addr_r, eai_clk, eai_rst_n);


   wire [`E203_ADDR_SIZE-1:0] cnt_im_out_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_im_out_nxt = cnt_i_r + (cnt_j_r * dim_im_out_r + cnt_k_r) * ch_im_out_r;
   wire cnt_im_out_ena = cnt_k_ena;

   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_im_out_dfflr (cnt_im_out_ena, cnt_im_out_nxt, cnt_im_out_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] im_out_real_addr = im_out_addr_r + cnt_im_out_r;


   wire load_start = state_is_jj_loop & cnt_l_start & (~store_im_out) & (~re_conv_out);
   wire load_im_valid = (cnt_load_dat_r == 2'b0) & load_start;
   wire load_wt_valid = (cnt_load_dat_r == 2'b1) & load_start;

   wire load_data_valid = load_im_valid | load_wt_valid ;

   wire load_im_valid_r;
   wire load_im_valid_nxt = load_im_valid;
   sirv_gnrl_dffr #(1) load_im_valid_dffr (load_im_valid_nxt, load_im_valid_r, eai_clk, eai_rst_n);

   wire load_wt_valid_r;
   wire load_wt_valid_nxt = load_wt_valid;
   sirv_gnrl_dffr #(1) load_wt_valid_dffr (load_wt_valid_nxt, load_wt_valid_r, eai_clk, eai_rst_n);
   

   wire wr_value_ena =  eai_icb_rsp_hsked & (~store_im_out) & (~re_conv_out);
   wire in_im_value_en = load_im_valid_r & wr_value_ena;
   wire wt_value_en = load_wt_valid_r & wr_value_ena;

   wire [31:0] im_in_value_r1;
   wire im_in_value_r1_ena = store_im_out | re_conv_out;
   wire [31:0] im_in_value_r1_nxt = eai_icb_rsp_rdata;
   sirv_gnrl_dfflr #(32) im_in_value_r1_dfflr (im_in_value_r1_ena , im_in_value_r1_nxt, im_in_value_r1, eai_clk, eai_rst_n);

  // wire wt_value_r1;
  // wire wt_value_r1_nxt = load_wt_valid_r & eai_icb_rsp_hsked & store_im_out;
  // sirv_gnrl_dffr #(1) wt_value_r1_dffr (wt_value_r1_nxt, wt_value_r1, eai_clk, eai_rst_n);



   wire [`E203_ADDR_SIZE-1:0] wt_value_r;
   wire wt_value_ena = wt_value_en ;
   wire [`E203_ADDR_SIZE-1:0] wt_value_nxt = eai_icb_rsp_rdata;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) wt_value_dfflr (wt_value_ena, wt_value_nxt, wt_value_r, eai_clk, eai_rst_n);



   wire conv_out_valid_r;
   wire conv_out_valid_nxt = wt_value_ena;
   sirv_gnrl_dffr #(1) conv_out_valid_dffr (conv_out_valid_nxt, conv_out_valid_r, eai_clk, eai_rst_n);


   wire conv_init_valid_r1;
   wire conv_init_valid_nxt1 = cnt_mnl_end;
   sirv_gnrl_dffr #(1) conv_init_valid1_dffr (conv_init_valid_nxt1, conv_init_valid_r1, eai_clk, eai_rst_n);

   wire conv_init_valid_r2;
   wire conv_init_valid_nxt2 = conv_init_valid_r1;
   sirv_gnrl_dffr #(1) conv_init_valid2_dffr (conv_init_valid_nxt2, conv_init_valid_r2, eai_clk, eai_rst_n);

   wire conv_init_valid_r3;
   wire conv_init_valid_nxt3 = conv_init_valid_r2;
   sirv_gnrl_dffr #(1) conv_init_valid3_dffr (conv_init_valid_nxt3, conv_init_valid_r3, eai_clk, eai_rst_n);

   wire conv_init_valid_r4;
   wire conv_init_valid_nxt4 = conv_init_valid_r3;
   sirv_gnrl_dffr #(1) conv_init_valid4_dffr (conv_init_valid_nxt4, conv_init_valid_r4, eai_clk, eai_rst_n);

   wire conv_init_valid_r5;
   wire conv_init_valid_nxt5 = conv_init_valid_r4;
   sirv_gnrl_dffr #(1) conv_init_valid5_dffr (conv_init_valid_nxt5, conv_init_valid_r5, eai_clk, eai_rst_n);

   wire conv_init_valid_r6;
   wire conv_init_valid_nxt6 = conv_init_valid_r5;
   sirv_gnrl_dffr #(1) conv_init_valid6_dffr (conv_init_valid_nxt6, conv_init_valid_r6, eai_clk, eai_rst_n);


   wire [`E203_ADDR_SIZE-1:0] im_in_value_r;
   wire in_im_value_ena = in_im_value_en | conv_init_valid_r6;
   wire [`E203_ADDR_SIZE-1:0] im_in_value_nxt = (conv_init_valid_r6) ? im_in_value_r1 : eai_icb_rsp_rdata;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) im_in_value_dfflr (in_im_value_ena, im_in_value_nxt, im_in_value_r, eai_clk, eai_rst_n);


   wire conv_init_valid_first_r1;
   sirv_gnrl_dffr #(1) conv_init_valid_first_r1_dffr (custom0_jj_loop_ena, conv_init_valid_first_r1, eai_clk, eai_rst_n);
   
   wire conv_init_valid_first_r2;
   sirv_gnrl_dffr #(1) conv_init_valid_first_r2_dffr (conv_init_valid_first_r1, conv_init_valid_first_r2, eai_clk, eai_rst_n);

   wire conv_init_valid_first_r3;
   sirv_gnrl_dffr #(1) conv_init_valid_first_r3_dffr (conv_init_valid_first_r2, conv_init_valid_first_r3, eai_clk, eai_rst_n);


   wire conv_init_valid_first_r4;
   sirv_gnrl_dffr #(1) conv_init_valid_first_r4_dffr (conv_init_valid_first_r3, conv_init_valid_first_r4, eai_clk, eai_rst_n);
 
   wire conv_init_valid_first_r5;
   sirv_gnrl_dffr #(1) conv_init_valid_first_r5_dffr (conv_init_valid_first_r4, conv_init_valid_first_r5, eai_clk, eai_rst_n);
   

   assign re_conv_out = conv_init_valid_r5 | conv_init_valid_first_r1;
   assign store_im_out = conv_init_valid_r4;


   wire jj_loop_byte0 = (im_out_real_addr[1:0] == 2'h0);
   wire jj_loop_byte1 = (im_out_real_addr[1:0] == 2'h1);
   wire jj_loop_byte2 = (im_out_real_addr[1:0] == 2'h2);
   wire jj_loop_byte3 = (im_out_real_addr[1:0] == 2'h3);

   wire jj_im_in_byte0 = (im_in_real_addr_r[1:0] == 2'h0);
   wire jj_im_in_byte1 = (im_in_real_addr_r[1:0] == 2'h1);
   wire jj_im_in_byte2 = (im_in_real_addr_r[1:0] == 2'h2);
   wire jj_im_in_byte3 = (im_in_real_addr_r[1:0] == 2'h3);

   wire jj_wt_byte0 = (wt_real_addr_r[1:0] == 2'h0);
   wire jj_wt_byte1 = (wt_real_addr_r[1:0] == 2'h1);
   wire jj_wt_byte2 = (wt_real_addr_r[1:0] == 2'h2);
   wire jj_wt_byte3 = (wt_real_addr_r[1:0] == 2'h3);

   wire [3:0] byte_im_pk = {jj_im_in_byte3 , jj_im_in_byte2 , jj_im_in_byte1, jj_im_in_byte0};
   wire [3:0] byte_wt_pk = {jj_wt_byte3 , jj_wt_byte2 , jj_wt_byte1, jj_wt_byte0};

   wire [3:0] byte_im_pk_r;
   wire [3:0] byte_im_pk_nxt = byte_im_pk;
   wire byte_im_pk_ena = in_im_value_ena & (~store_im_out) | conv_init_valid_r6;
   sirv_gnrl_dfflr #(4) byte_im_pk_dfflr (byte_im_pk_ena, byte_im_pk_nxt, byte_im_pk_r, eai_clk, eai_rst_n);

   wire [3:0] byte_wt_pk_r;
   wire [3:0] byte_wt_pk_nxt = byte_wt_pk;
   wire byte_wt_pk_ena = wt_value_ena & (~store_im_out);
   sirv_gnrl_dfflr #(4) byte_wt_pk_dfflr (byte_wt_pk_ena, byte_wt_pk_nxt, byte_wt_pk_r, eai_clk, eai_rst_n);


   wire type_bais0 = (bias_real_addr[1:0] == 0); 
   wire type_bais1 = (bias_real_addr[1:0] == 1); 
   wire type_bais2 = (bias_real_addr[1:0] == 2); 
   wire type_bais3 = (bias_real_addr[1:0] == 3);

   wire [31:0] bias_real_32 =   {32{type_bais0}} & {{24{eai_icb_rsp_rdata[7]}}  , eai_icb_rsp_rdata[7:0]} 
                             |  {32{type_bais1}} & {{24{eai_icb_rsp_rdata[15]}} , eai_icb_rsp_rdata[15:8]} 
                             |  {32{type_bais2}} & {{24{eai_icb_rsp_rdata[23]}} , eai_icb_rsp_rdata[23:16]}
                             |  {32{type_bais3}} & {{24{eai_icb_rsp_rdata[31]}} , eai_icb_rsp_rdata[31:24]}
                             ;

   wire [`E203_ADDR_SIZE-1:0] conv_out_r;

   wire [`E203_ADDR_SIZE-1:0] conv_out_init_r;
   wire [`E203_ADDR_SIZE-1:0] conv_out_init_nxt = (bias_real_32 << bias_shift) + ( ($signed(1) << out_shift) >> 1 );

   wire cnt_i_ena_r;
   sirv_gnrl_dffr #(1) cnt_i_ena_r_dffr (cnt_i_ena, cnt_i_ena_r, eai_clk, eai_rst_n);

   wire cnt_i_ena_r1;
   sirv_gnrl_dffr #(1) cnt_i_ena_r1_dffr (cnt_i_ena_r, cnt_i_ena_r1, eai_clk, eai_rst_n);
   
   wire conv_out_init_ena = conv_init_valid_r6 | conv_init_valid_first_r2 | cnt_i_ena_r1;
   
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) conv_out_init_dfflr (conv_out_init_ena, conv_out_init_nxt, conv_out_init_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] conv_out_init = (conv_init_valid_r6 | conv_init_valid_first_r5) ? conv_out_init_r : conv_out_r;
   wire [`E203_ADDR_SIZE-1:0] conv_out_nxt = ({8{byte_im_pk_r[0]}} & (im_in_value_r[07:00]) |    
                                              {8{byte_im_pk_r[1]}} & (im_in_value_r[15:08]) |   
                                              {8{byte_im_pk_r[2]}} & (im_in_value_r[23:16]) |   
                                              {8{byte_im_pk_r[3]}} & (im_in_value_r[31:24])
                                             ) 
                                             *
                                             ( 
                                              {8{byte_wt_pk_r[0]}} & (wt_value_r[07:00]) | 
                                              {8{byte_wt_pk_r[1]}} & (wt_value_r[15:08]) |
                                              {8{byte_wt_pk_r[2]}} & (wt_value_r[23:16]) |
                                              {8{byte_wt_pk_r[3]}} & (wt_value_r[31:24]) 
                                             ) 
                                             +
                                             conv_out_init;
   wire conv_out_ena = (conv_out_valid_r & ~conv_init_valid_r4) | conv_init_valid_r6;

   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) conv_out_dfflr (conv_out_ena, conv_out_nxt, conv_out_r, eai_clk, eai_rst_n);

   wire [31:0] conv_out_shift = (conv_out_r >> out_shift);

   wire conv_out_max = | conv_out_shift[30:7];
   wire conv_out_min = | conv_out_shift[30:8];

   wire [31:0] ssat_max = (~conv_out_shift[31]) & conv_out_max ;
   wire [31:0] ssat_min = (conv_out_shift[31]) & conv_out_min;

   wire [7:0] im_out = (ssat_max) ? 8'd127 : (ssat_min) ? -8'd128 : conv_out_shift[7:0]
                                       ;
   wire jj_loop_ret_r;
   wire jj_loop_ret_set = cnt_ijkmnl_end;
   wire jj_loop_ret_clr = conv_init_valid_r4;
   wire jj_loop_ret_ena = jj_loop_ret_set | jj_loop_ret_clr;
   wire jj_loop_ret_nxt = cnt_ijkmnl_end;

   sirv_gnrl_dfflr #(1) jj_loop_ret_dfflr (jj_loop_ret_ena, jj_loop_ret_nxt, jj_loop_ret_r, eai_clk, eai_rst_n);

   wire jj_loop_ret = jj_loop_ret_r & conv_init_valid_r4;

   //==================custom0_rowsum start===========================//

   wire custom0_rowsum_num_ena = custom0_rowsum_ena;
   wire [`E203_XLEN-1:0] custom0_rowsum_num_nxt = eai_req_rs1;
   wire [`E203_XLEN-1:0] custom0_rowsum_num_r;

   sirv_gnrl_dfflr #(32) custom0_rowsum_num_dfflr (custom0_rowsum_num_ena, custom0_rowsum_num_nxt, custom0_rowsum_num_r, eai_clk, eai_rst_n);

   wire rowsum_start_r;
   wire rowsum_start_set = custom0_rowsum_ena;
   wire rowsum_start_clr = rowsum_start_r;
   wire rowsum_start_ena = rowsum_start_set | rowsum_start_clr;
   wire rowsum_start_nxt = rowsum_start_set ;
   sirv_gnrl_dfflr #(1) rowsum_start_dfflr (rowsum_start_ena, rowsum_start_nxt, rowsum_start_r, eai_clk, eai_rst_n);


   wire [`E203_ADDR_SIZE-1:0] rowsum_real_addr =  matrix_entry_addr_r + custom0_rowsum_num_r * matrix_size_r*4;

   wire [3:0] cnt_rowsum_r;
   wire rowsum_end = (cnt_rowsum_r == 3);
   wire  cnt_rowsum_ena = state_is_rowsum | rowsum_end;
   wire [3:0] cnt_rowsum_nxt = (custom0_rowsum_ena | state_is_rowsum & eai_icb_rsp_hsked) ? cnt_rowsum_r + 4'b1 :
                               (state_is_idle) ? 4'b0 : cnt_rowsum_r;

   sirv_gnrl_dfflr #(4) cnt_rowsum_dfflr (cnt_rowsum_ena, cnt_rowsum_nxt, cnt_rowsum_r, eai_clk, eai_rst_n);

   wire eai_icb_cmd_valid_real = (state_is_rowsum & (rowsum_start_r | (cnt_rowsum_r < 2) & eai_icb_rsp_hsked)) ? 1'b1 : 1'b0;
   wire eai_icb_cmd_valid_r;
   wire eai_icb_cmd_valid_set = eai_icb_cmd_valid_real;
   wire eai_icb_cmd_valid_clr = eai_icb_cmd_valid_r;
   wire eai_icb_cmd_valid_ena = eai_icb_cmd_valid_set | eai_icb_cmd_valid_clr;
   wire eai_icb_cmd_valid_nxt = eai_icb_cmd_valid_set;
  
   sirv_gnrl_dfflr #(1) eai_icb_cmd_valid_dfflr (eai_icb_cmd_valid_ena, eai_icb_cmd_valid_nxt, eai_icb_cmd_valid_r, eai_clk, eai_rst_n);

   

   wire [`E203_ADDR_SIZE-1:0] eai_icb_cmd_addr_r;
   wire [`E203_ADDR_SIZE-1:0] eai_icb_cmd_addr_nxt = (rowsum_start_r) ? rowsum_real_addr : eai_icb_cmd_addr_r + 32'h4;
   

   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) eai_icb_cmd_addr_dfflr (eai_icb_cmd_valid_nxt, eai_icb_cmd_addr_nxt, eai_icb_cmd_addr_r, eai_clk, eai_rst_n);


   
   wire [`E203_XLEN*3 -1:0] buf_row_r;
   wire [`E203_XLEN*3 -1:0] buf_row_nxt = (custom0_rowsum_num_r==0) ? {buf_row_r[`E203_XLEN*2-1:0],eai_icb_rsp_rdata} : {buf_row_r[`E203_XLEN*2-1:0],eai_icb_rsp_rdata + buf_row_r[`E203_XLEN*3-1:`E203_XLEN*2]};
   wire buf_row_ena = eai_icb_rsp_valid & state_is_rowsum;

   sirv_gnrl_dfflr #(`E203_XLEN*3) buf_row_dfflr (buf_row_ena, buf_row_nxt, buf_row_r, eai_clk, eai_rst_n);
   
   wire state_ena =  custom0_setup_ena   & state_is_idle 
                   | custom0_rowsum_ena  & state_is_idle 
                   | custom0_colsum_ena  & state_is_idle
                   | custom0_jj_relu_size_ena  & state_is_idle
                   | custom0_jj_init_ch_ena  & state_is_idle
                   | custom0_jj_init_im_ena  & state_is_idle
                   | custom0_jj_init_fs_ena  & state_is_idle
                   | custom0_jj_init_pw_ena  & state_is_idle
                   | custom0_jj_init_imaddr_ena  & state_is_idle
                   | custom0_jj_init_bias_ena  & state_is_idle
                   | custom0_jj_loop_ena  & state_is_idle
                   | rowsum_end & state_is_rowsum
                   | state_is_setup
                   | state_is_colsum
                   | state_is_jj_init_ch
                   | state_is_jj_init_im
                   | state_is_jj_init_fs
                   | state_is_jj_init_pw
                   | state_is_jj_init_imaddr
                   | state_is_jj_init_bias
                   | state_is_jj_loop & jj_loop_ret
                   ;

   sirv_gnrl_dfflr #(EAI_FSM) state_dfflr (state_ena, next_state, state_r, eai_clk, eai_rst_n);

   //=========================custom0_colsum start==============================//
   wire custom0_colsum_ret_next = custom0_colsum_ena;
   wire custom0_colsum_ret_r;
   wire custom0_colsum_ret = custom0_colsum_ret_r & state_is_colsum;

   sirv_gnrl_dffrs #(1) custom0_colsum_ret_dffrs (custom0_colsum_ret_next,custom0_colsum_ret_r, eai_clk, eai_rst_n);

   wire custom0_colsum_num_ena = custom0_colsum_ena;
   wire [`E203_XLEN-1:0] custom0_colsum_num_nxt = eai_req_rs1;
   wire [`E203_XLEN-1:0] custom0_colsum_num_r;

   sirv_gnrl_dfflr #(32) custom0_colsum_num_dfflr (custom0_colsum_num_ena, custom0_colsum_num_nxt, custom0_colsum_num_r, eai_clk, eai_rst_n);


   wire [`E203_XLEN -1:0] eai_rsp_rdat_r;
   wire [`E203_XLEN -1:0] eai_rsp_rdat_nxt = (state_is_idle) ? 32'h0 : eai_icb_rsp_rdata + eai_rsp_rdat_r;
   wire eai_rsp_rdat_ena = buf_row_ena | state_is_idle;
   sirv_gnrl_dfflr #(`E203_XLEN) eai_rsp_rdat_dfflr (eai_rsp_rdat_ena, eai_rsp_rdat_nxt, eai_rsp_rdat_r, eai_clk, eai_rst_n);

   wire [`E203_XLEN -1:0] eai_rsp_rdat_colsum = (custom0_colsum_num_r == 0) ? buf_row_r[`E203_XLEN*3-1:`E203_XLEN*2] :
                                                (custom0_colsum_num_r == 1) ? buf_row_r[`E203_XLEN*2-1:`E203_XLEN*1] :
                                                (custom0_colsum_num_r == 2) ? buf_row_r[`E203_XLEN-1 : 0] : 32'b0;

   
   //========================interface==========================================//
   //
   assign eai_rsp_rdat = (state_is_rowsum) ? eai_rsp_rdat_r : (state_is_colsum) ? eai_rsp_rdat_colsum : 32'b0; 
   assign eai_rsp_err = 1'b0;   	  
   assign eai_active = 1'b1;
   assign eai_req_ready = (state_is_idle) ? 1'b1 : 1'b0;
   assign eai_icb_cmd_valid = eai_icb_cmd_valid_r | load_data_valid | conv_init_valid_r4 | conv_init_valid_first_r1 | conv_init_valid_r5;
   assign eai_icb_cmd_addr =   {32{state_is_rowsum}} & eai_icb_cmd_addr_r 
                             | {32{state_is_jj_loop & load_im_valid}} & im_in_real_addr 
                             | {32{state_is_jj_loop & load_wt_valid}} & wt_real_addr
                             | {32{conv_init_valid_r4}} & im_out_real_addr
                             | {32{conv_init_valid_r5 | conv_init_valid_first_r1}} & bias_real_addr
                             ;
   assign eai_icb_cmd_wdata = (conv_init_valid_r4) ? {{8{jj_loop_byte3}}&im_out , 
                                                      {8{jj_loop_byte2}}&im_out , 
                                                      {8{jj_loop_byte1}}&im_out , 
                                                      {8{jj_loop_byte0}}&im_out} : 8'b0;
   assign eai_icb_cmd_size = (state_is_jj_loop) ? 2'b00 : 2'b10;
   assign eai_icb_rsp_ready = 1'b1;
   assign eai_icb_cmd_read = (conv_init_valid_r4) ? 1'b0 : 1'b1;
   assign eai_mem_holdup =  (state_is_rowsum | state_is_jj_loop | state_is_jj_relu_q7) ? 1'b1 : 1'b0;
 
   assign eai_rsp_valid = ( state_is_setup  
                          | state_is_colsum 
                          | rowsum_end
                          | state_is_jj_init_ch 
                          | state_is_jj_init_im 
                          | state_is_jj_init_fs 
                          | state_is_jj_init_pw 
                          | state_is_jj_init_imaddr
                          | state_is_jj_init_bias
                          | jj_loop_ret
                          ) ? 1'b1 : 1'b0;



endmodule
