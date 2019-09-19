
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

   localparam ROWBUF_DP = 4;
   localparam ROWBUF_IDX_W = 2;
   localparam ROW_IDX_W = 2;
   localparam COL_IDX_W = 4;
   localparam PIPE_NUM = 3;

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

   wire eai_req_hsked     = eai_req_valid & eai_req_ready;
   wire eai_rsp_hsked     = eai_rsp_valid & eai_rsp_ready;
   wire eai_icb_rsp_hsked = eai_icb_rsp_valid & eai_icb_rsp_ready;

   wire custom0_setup    = opcode_custom0 & rv32_func3_011 & rv32_func7_0000000;
   wire custom0_rowsum   = opcode_custom0 & rv32_func3_110 & rv32_func7_0000001;
   wire custom0_colsum   = opcode_custom0 & rv32_func3_110 & rv32_func7_0000010;

   parameter EAI_FSM = 4;
   parameter IDLE    = 4'h0;
   parameter SETUP   = 4'h1;
   parameter ROWSUM  = 4'h2;
   parameter COLSUM  = 4'h3;
   
   wire [EAI_FSM-1:0] state_r;

   wire state_is_idle   = (state_r == IDLE);
   wire state_is_setup  = (state_r == SETUP);
   wire state_is_rowsum = (state_r == ROWSUM);
   wire state_is_colsum = (state_r == COLSUM);


   wire custom0_setup_ena  = custom0_setup  & eai_req_hsked;
   wire custom0_rowsum_ena = custom0_rowsum & eai_req_hsked;
   wire custom0_colsum_ena = custom0_colsum & eai_req_hsked;

   wire [EAI_FSM-1:0] next_state_idle  = custom0_setup_ena  ? SETUP  : 
                                         custom0_rowsum_ena ? ROWSUM :
                                         custom0_colsum_ena ? COLSUM : 
                                                              IDLE   ;
   wire [EAI_FSM-1:0] next_state_setup  = IDLE;
   wire [EAI_FSM-1:0] next_state_rowsum = IDLE;
   wire [EAI_FSM-1:0] next_state_colsum = IDLE;

   wire [EAI_FSM-1:0] next_state =   {EAI_FSM{state_is_idle}}   & next_state_idle   
                                   | {EAI_FSM{state_is_setup}}  & next_state_setup  
                                   | {EAI_FSM{state_is_rowsum}} & next_state_rowsum 
                                   | {EAI_FSM{state_is_colsum}} & next_state_colsum
                                   ;


   //custom0_setup start
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

   //custom0_rowsum start

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
   assign eai_mem_holdup =  (state_is_rowsum) ? 1'b1 : 1'b0;

   
   wire [`E203_XLEN*3 -1:0] buf_row_r;
   wire [`E203_XLEN*3 -1:0] buf_row_nxt = (custom0_rowsum_num_r==0) ? {buf_row_r[`E203_XLEN*2-1:0],eai_icb_rsp_rdata} : {buf_row_r[`E203_XLEN*2-1:0],eai_icb_rsp_rdata + buf_row_r[`E203_XLEN*3-1:`E203_XLEN*2]};
   wire buf_row_ena = eai_icb_rsp_valid & state_is_rowsum;

   sirv_gnrl_dfflr #(`E203_XLEN*3) buf_row_dfflr (buf_row_ena, buf_row_nxt, buf_row_r, eai_clk, eai_rst_n);
   
   wire state_ena =  custom0_setup_ena   & state_is_idle 
                   | custom0_rowsum_ena  & state_is_idle 
                   | custom0_colsum_ena  & state_is_idle
                   | (cnt_rowsum_r == 3) & state_is_rowsum
                   | state_is_setup
                   | state_is_colsum
                   ;

   sirv_gnrl_dfflr #(EAI_FSM) state_dfflr (state_ena, next_state, state_r, eai_clk, eai_rst_n);

   //custom0_colsum start
   wire custom0_colsum_ret_next = custom0_colsum_ena;
   wire custom0_colsum_ret_r;
   wire custom0_colsum_ret = custom0_colsum_ret_r & state_is_colsum;

   sirv_gnrl_dffrs #(1) custom0_colsum_ret_dffrs (custom0_colsum_ret_next,custom0_colsum_ret_r, eai_clk, eai_rst_n);

   wire custom0_colsum_num_ena = custom0_colsum_ena;
   wire [`E203_XLEN-1:0] custom0_colsum_num_nxt = eai_req_rs1;
   wire [`E203_XLEN-1:0] custom0_colsum_num_r;

   sirv_gnrl_dfflr #(32) custom0_colsum_num_dfflr (custom0_colsum_num_ena, custom0_colsum_num_nxt, custom0_colsum_num_r, eai_clk, eai_rst_n);

   assign eai_rsp_valid = (state_is_setup) ? 1'b1 : (cnt_rowsum_r == 3) ? 1'b1 : (state_is_colsum) ? 1'b1: 1'b0;

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
