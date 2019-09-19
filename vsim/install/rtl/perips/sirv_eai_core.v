
//=====================================================================
//
//--  #     # #     #  #####  #       #######   ###
//--  ##    # #     # #     # #       #          #
//--  # #   # #     # #       #       #          #
//--  #  #  # #     # #       #       #####      #
//--  #   # # #     # #       #       #          #
//--  #    ## #     # #     # #       #          #
//--  #     #  #####   #####  ####### #######   ###
//
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


   wire custom0_setup_ena  = custom0_setup  & eai_req_hsked;
   wire custom0_rowsum_ena = custom0_rowsum & eai_req_hsked;
   wire custom0_colsum_ena = custom0_colsum & eai_req_hsked;
   wire custom0_jj_init_ch_ena = custom0_jj_init_ch & eai_req_hsked;
   wire custom0_jj_init_im_ena = custom0_jj_init_im & eai_req_hsked;
   wire custom0_jj_init_fs_ena = custom0_jj_init_fs & eai_req_hsked;
   wire custom0_jj_init_pw_ena = custom0_jj_init_pw & eai_req_hsked;
   wire custom0_jj_init_imaddr_ena = custom0_jj_init_imaddr & eai_req_hsked;
   wire custom0_jj_loop_ena = custom0_jj_loop & eai_req_hsked;

   wire [EAI_FSM-1:0] next_state_idle  = custom0_setup_ena  ? SETUP  : 
                                         custom0_rowsum_ena ? ROWSUM :
                                         custom0_colsum_ena ? COLSUM : 
                                         custom0_jj_init_ch_ena ? JJ_INIT_CH : 
                                         custom0_jj_init_im_ena ? JJ_INIT_IM : 
                                         custom0_jj_init_fs_ena ? JJ_INIT_FS : 
                                         custom0_jj_init_pw_ena ? JJ_INIT_PW : 
                                         custom0_jj_init_imaddr_ena ? JJ_INIT_IMADDR : 
                                         custom0_jj_loop_ena ? JJ_LOOP : 
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
                                   ;


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
   wire [`E203_ADDR_SIZE-1:0] in_row ;
   wire [`E203_ADDR_SIZE-1:0] in_col ;
   wire in_row_is_not_negative = (in_row >= 0);
   wire in_col_is_not_negative = (in_col >= 0);

   wire in_row_loop = (in_row < dim_im_in_r);
   wire in_col_loop = (in_col < dim_im_in_r);
   wire cnt_l_start = in_row_is_not_negative 
                    & in_col_is_not_negative 
                    & in_row_loop 
                    & in_col_loop;

   wire [`E203_ADDR_SIZE-1:0] cnt_l_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_l_max = ch_im_in_r - 32'b1;
   wire cnt_l_loop = (cnt_l_r < cnt_l_max);
   wire cnt_l_end = (cnt_l_r == cnt_l_max);  
   wire [`E203_ADDR_SIZE-1:0] cnt_l_nxt = (cnt_l_loop) ? cnt_l_r + 1'b1 : 32'b0;
   wire cnt_l_ena = state_is_jj_loop & ( cnt_l_end | cnt_l_start & cnt_l_loop );
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_l_dfflr (cnt_l_ena, cnt_l_nxt, cnt_l_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_n_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_n_max = filter_size_r - 32'b1;
   wire cnt_n_loop = (cnt_n_r <  cnt_n_max);
   wire cnt_n_end =  (cnt_n_r == cnt_n_max);
   wire [`E203_ADDR_SIZE-1:0] cnt_n_nxt = (cnt_n_loop) ? cnt_n_r + 1'b1 : 32'b0;
   wire cnt_n_ena = state_is_jj_loop & (cnt_l_end | ~(cnt_l_start));
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_n_dfflr (cnt_n_ena, cnt_n_nxt, cnt_n_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_m_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_m_max = cnt_n_max;
   wire cnt_m_loop = (cnt_m_r < cnt_m_max);
   wire cnt_m_end = (cnt_m_r == cnt_m_max);
   wire [`E203_ADDR_SIZE-1:0] cnt_m_nxt = (cnt_m_loop) ? cnt_m_r + 1'b1 : 32'b0;
   wire cnt_m_ena = state_is_jj_loop & cnt_n_end  ;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_m_dfflr (cnt_m_ena, cnt_m_nxt, cnt_m_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_k_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_k_max = dim_im_out_r - 32'b1;
   wire cnt_k_loop = (cnt_k_r < cnt_k_max);
   wire cnt_k_end = (cnt_k_r == cnt_k_max);
   wire [`E203_ADDR_SIZE-1:0] cnt_k_nxt = (cnt_k_loop) ? cnt_k_r + 1'b1 : 32'b0;
   wire cnt_k_ena = state_is_jj_loop & cnt_m_end ;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_k_dfflr (cnt_k_ena, cnt_k_nxt, cnt_k_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_j_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_j_max = cnt_k_max;
   wire cnt_j_loop = (cnt_j_r < cnt_j_max);
   wire cnt_j_end = (cnt_j_r == cnt_j_max);    
   wire [`E203_ADDR_SIZE-1:0] cnt_j_nxt = (cnt_j_loop) ? cnt_j_r + 1'b1 : 32'b0;
   wire cnt_j_ena = state_is_jj_loop & cnt_k_end;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_j_dfflr (cnt_j_ena, cnt_j_nxt, cnt_j_r, eai_clk, eai_rst_n);

   wire [`E203_ADDR_SIZE-1:0] cnt_i_r;
   wire [`E203_ADDR_SIZE-1:0] cnt_i_max = ch_im_out_r - 32'b1;
   wire cnt_i_loop = (cnt_i_r < cnt_i_max);
   wire cnt_i_end = (cnt_i_r == cnt_i_max); 
   wire [`E203_ADDR_SIZE-1:0] cnt_i_nxt = (cnt_i_loop) ? cnt_i_r + 1'b1 : 32'b0;
   wire cnt_i_ena = state_is_jj_loop & cnt_j_end ;
   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) cnt_i_dfflr (cnt_i_ena, cnt_i_nxt, cnt_i_r, eai_clk, eai_rst_n);

   assign in_row = stride_r * cnt_j_r + cnt_m_r - padding_r;
   assign in_col = stride_r * cnt_k_r + cnt_n_r - padding_r;
   wire [`E203_ADDR_SIZE-1:0] im_in_real_addr = im_in_addr_r + (in_row * dim_im_in_r + in_col) * ch_im_in_r + cnt_l_r;


   //==================custom0_rowsum start===========================//

   wire custom0_rowsum_num_ena = custom0_rowsum_ena;
   wire [`E203_XLEN-1:0] custom0_rowsum_num_nxt = eai_req_rs1;
   wire [`E203_XLEN-1:0] custom0_rowsum_num_r;

   sirv_gnrl_dfflr #(32) custom0_rowsum_num_dfflr (custom0_rowsum_num_ena, custom0_rowsum_num_nxt, custom0_rowsum_num_r, eai_clk, eai_rst_n);

   reg rowsum_start;
   always @(posedge eai_clk or negedge eai_rst_n)
   begin
     if (!eai_rst_n)
       rowsum_start <= 1'b0;
     else if (custom0_rowsum_ena)
       rowsum_start <= #1 custom0_rowsum_ena;
     else
       rowsum_start <= 1'b0;
   end

   wire [`E203_ADDR_SIZE-1:0] rowsum_real_addr =  matrix_entry_addr_r + custom0_rowsum_num_r * matrix_size_r*4;

   wire [3:0] cnt_rowsum_r;
   wire  cnt_rowsum_ena = state_is_rowsum | (cnt_rowsum_r == 3);
   wire [3:0] cnt_rowsum_nxt = (custom0_rowsum_ena | state_is_rowsum & eai_icb_rsp_hsked) ? cnt_rowsum_r + 4'b1 :
                               (state_is_idle) ? 4'b0 : cnt_rowsum_r;

   sirv_gnrl_dfflr #(4) cnt_rowsum_dfflr (cnt_rowsum_ena, cnt_rowsum_nxt, cnt_rowsum_r, eai_clk, eai_rst_n);

   wire eai_icb_cmd_valid_nxt = (rowsum_start | (cnt_rowsum_r < 2) & eai_icb_rsp_hsked) ? 1'b1 : 1'b0;
   reg eai_icb_cmd_valid_r;
   
   always @(posedge eai_clk or negedge eai_rst_n)
   begin
     if (!eai_rst_n)
       eai_icb_cmd_valid_r <= 1'b0;
     else if (eai_icb_cmd_valid_nxt)
       eai_icb_cmd_valid_r <= #1 eai_icb_cmd_valid_nxt;
     else
       eai_icb_cmd_valid_r <= 1'b0;
   end

   assign eai_icb_cmd_valid = eai_icb_cmd_valid_r;

   wire [`E203_ADDR_SIZE-1:0] eai_icb_cmd_addr_r;
   wire [`E203_ADDR_SIZE-1:0] eai_icb_cmd_addr_nxt = (rowsum_start) ? rowsum_real_addr : eai_icb_cmd_addr_r + 32'h4;
   

   sirv_gnrl_dfflr #(`E203_ADDR_SIZE) eai_icb_cmd_addr_dfflr (eai_icb_cmd_valid_nxt, eai_icb_cmd_addr_nxt, eai_icb_cmd_addr_r, eai_clk, eai_rst_n);

   assign eai_icb_cmd_addr = eai_icb_cmd_addr_r;
   assign eai_icb_cmd_wdata = 32'b0;
   assign eai_icb_cmd_size = 2'b10;
   assign eai_icb_rsp_ready = 1'b1;
   assign eai_icb_cmd_read = 1'b1;
   assign eai_mem_holdup =  (state_is_rowsum | state_is_jj_loop) ? 1'b1 : 1'b0;

   
   wire [`E203_XLEN*3 -1:0] buf_row_r;
   wire [`E203_XLEN*3 -1:0] buf_row_nxt = (custom0_rowsum_num_r==0) ? {buf_row_r[`E203_XLEN*2-1:0],eai_icb_rsp_rdata} : {buf_row_r[`E203_XLEN*2-1:0],eai_icb_rsp_rdata + buf_row_r[`E203_XLEN*3-1:`E203_XLEN*2]};
   wire buf_row_ena = eai_icb_rsp_valid & state_is_rowsum;

   sirv_gnrl_dfflr #(`E203_XLEN*3) buf_row_dfflr (buf_row_ena, buf_row_nxt, buf_row_r, eai_clk, eai_rst_n);
   
   wire state_ena =  custom0_setup_ena   & state_is_idle 
                   | custom0_rowsum_ena  & state_is_idle 
                   | custom0_colsum_ena  & state_is_idle
                   | custom0_jj_init_ch_ena  & state_is_idle
                   | custom0_jj_init_im_ena  & state_is_idle
                   | custom0_jj_init_fs_ena  & state_is_idle
                   | custom0_jj_init_pw_ena  & state_is_idle
                   | custom0_jj_init_imaddr_ena  & state_is_idle
                   | custom0_jj_loop_ena  & state_is_idle
                   | (cnt_rowsum_r == 3) & state_is_rowsum
                   | state_is_setup
                   | state_is_colsum
                   | state_is_jj_init_ch
                   | state_is_jj_init_im
                   | state_is_jj_init_fs
                   | state_is_jj_init_pw
                   | state_is_jj_init_imaddr
                   | state_is_jj_loop & (cnt_i_r == (ch_im_out_r - 32'b1))
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

   assign eai_rsp_valid = (state_is_setup  
                          | state_is_colsum 
                          | (cnt_rowsum_r == 3) 
                          | state_is_jj_init_ch 
                          | state_is_jj_init_im 
                          | state_is_jj_init_fs 
                          | state_is_jj_init_pw 
                          | state_is_jj_init_imaddr
                          | (cnt_i_r == (ch_im_out_r - 32'b1))
                          ) ? 1'b1 : 1'b0;

   wire [`E203_XLEN -1:0] eai_rsp_rdat_r;
   wire [`E203_XLEN -1:0] eai_rsp_rdat_nxt = (state_is_idle) ? 32'h0 : eai_icb_rsp_rdata + eai_rsp_rdat_r;
   wire eai_rsp_rdat_ena = buf_row_ena | state_is_idle;
   sirv_gnrl_dfflr #(`E203_XLEN) eai_rsp_rdat_dfflr (eai_rsp_rdat_ena, eai_rsp_rdat_nxt, eai_rsp_rdat_r, eai_clk, eai_rst_n);

   wire [`E203_XLEN -1:0] eai_rsp_rdat_colsum = (custom0_colsum_num_r == 0) ? buf_row_r[`E203_XLEN*3-1:`E203_XLEN*2] :
                                                (custom0_colsum_num_r == 1) ? buf_row_r[`E203_XLEN*2-1:`E203_XLEN*1] :
                                                (custom0_colsum_num_r == 2) ? buf_row_r[`E203_XLEN-1 : 0] : 32'b0;
   assign eai_rsp_rdat = (state_is_rowsum) ? eai_rsp_rdat_r : (state_is_colsum) ? eai_rsp_rdat_colsum : 32'b0; 
   assign eai_rsp_err = 1'b0;   	  
   assign eai_active = 1'b1;
   assign eai_req_ready = (state_is_idle) ? 1'b1 : 1'b0;

endmodule
