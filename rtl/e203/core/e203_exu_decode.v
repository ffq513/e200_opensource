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
//  The decode module to decode the instruction details
//
// ====================================================================
`include "e203_defines.v"

module e203_exu_decode(

  //////////////////////////////////////////////////////////////
  // The IR stage to Decoder
  input  [`E203_INSTR_SIZE-1:0] i_instr,
  input  [`E203_PC_SIZE-1:0] i_pc,
  input  i_prdt_taken, 
  input  i_misalgn,              // The fetch misalign
  input  i_buserr,               // The fetch bus error
  input  i_muldiv_b2b,           // The back2back case for mul/div

  input  dbg_mode,
  //////////////////////////////////////////////////////////////
  // The Decoded Info-Bus

  output dec_rs1x0,
  output dec_rs2x0,

  output dec_rs1x0_1,
  output dec_rs2x0_1,
  
  output dec_rs1en,
  output dec_rs2en,

  output dec_rs1en_1,
  output dec_rs2en_1,
  output dec_rdren,
  output dec_rdren_1,
  output dec_rdwen_1,

  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx_1,  
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx_1, 
  output [`E203_RFIDX_WIDTH-1:0] dec_rdidx_1,  

  output dec_rdwen,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,
  output [`E203_RFIDX_WIDTH-1:0] dec_rdidx,
  output [`E203_DECINFO_WIDTH-1:0] dec_info,  
  output [`E203_XLEN-1:0] dec_imm,
  output [`E203_PC_SIZE-1:0] dec_pc,
  output dec_misalgn,
  output dec_buserr,
  output dec_ilegl,

  //////////////////////////////////////
  //nice decode
  input  nice_xs_off,  
  output dec_nice,
  output nice_cmt_off_ilgl_o,      

  /////////////////////////////////////
  //dsp dec
  output dec_dsp,
  output [`E203_DECINFO_DSP_WIDTH-1:0] dec_dsp_info,

  output dec_mulhsu,
  output dec_mul   ,
  output dec_div   ,
  output dec_rem   ,
  output dec_divu  ,
  output dec_remu  ,

  output dec_rv32,
  output dec_bjp,
  output dec_jal,
  output dec_jalr,
  output dec_bxx,

  output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
  output [`E203_XLEN-1:0] dec_bjp_imm 
  );



  wire [32-1:0] rv32_instr = i_instr;
  wire [16-1:0] rv16_instr = i_instr[15:0];

  wire [6:0]  opcode = rv32_instr[6:0];

  wire opcode_1_0_00  = (opcode[1:0] == 2'b00);
  wire opcode_1_0_01  = (opcode[1:0] == 2'b01);
  wire opcode_1_0_10  = (opcode[1:0] == 2'b10);
  wire opcode_1_0_11  = (opcode[1:0] == 2'b11);

  wire rv32 = opcode_1_0_11;

  wire [4:0]  rv32_rd     = rv32_instr[11:7];
  wire [2:0]  rv32_func3  = rv32_instr[14:12];
  wire [4:0]  rv32_rs1    = rv32_instr[19:15];
  wire [4:0]  rv32_rs2    = rv32_instr[24:20];
  wire [6:0]  rv32_func7  = rv32_instr[31:25];

  wire [4:0]  rv16_rd     = rv32_rd;
  wire [4:0]  rv16_rs1    = rv16_rd; 
  wire [4:0]  rv16_rs2    = rv32_instr[6:2];

  wire [4:0]  rv16_rdd    = {2'b01,rv32_instr[4:2]};
  wire [4:0]  rv16_rss1   = {2'b01,rv32_instr[9:7]};
  wire [4:0]  rv16_rss2   = rv16_rdd;

  wire [2:0]  rv16_func3  = rv32_instr[15:13];

  
  // We generate the signals and reused them as much as possible to save gatecounts
  wire opcode_4_2_000 = (opcode[4:2] == 3'b000);
  wire opcode_4_2_001 = (opcode[4:2] == 3'b001);
  wire opcode_4_2_010 = (opcode[4:2] == 3'b010);
  wire opcode_4_2_011 = (opcode[4:2] == 3'b011);
  wire opcode_4_2_100 = (opcode[4:2] == 3'b100);
  wire opcode_4_2_101 = (opcode[4:2] == 3'b101);
  wire opcode_4_2_110 = (opcode[4:2] == 3'b110);
  wire opcode_4_2_111 = (opcode[4:2] == 3'b111);
  wire opcode_6_5_00  = (opcode[6:5] == 2'b00);
  wire opcode_6_5_01  = (opcode[6:5] == 2'b01);
  wire opcode_6_5_10  = (opcode[6:5] == 2'b10);
  wire opcode_6_5_11  = (opcode[6:5] == 2'b11);

  wire rv32_func3_000 = (rv32_func3 == 3'b000);
  wire rv32_func3_001 = (rv32_func3 == 3'b001);
  wire rv32_func3_010 = (rv32_func3 == 3'b010);
  wire rv32_func3_011 = (rv32_func3 == 3'b011);
  wire rv32_func3_100 = (rv32_func3 == 3'b100);
  wire rv32_func3_101 = (rv32_func3 == 3'b101);
  wire rv32_func3_110 = (rv32_func3 == 3'b110);
  wire rv32_func3_111 = (rv32_func3 == 3'b111);

  wire rv16_func3_000 = (rv16_func3 == 3'b000);
  wire rv16_func3_001 = (rv16_func3 == 3'b001);
  wire rv16_func3_010 = (rv16_func3 == 3'b010);
  wire rv16_func3_011 = (rv16_func3 == 3'b011);
  wire rv16_func3_100 = (rv16_func3 == 3'b100);
  wire rv16_func3_101 = (rv16_func3 == 3'b101);
  wire rv16_func3_110 = (rv16_func3 == 3'b110);
  wire rv16_func3_111 = (rv16_func3 == 3'b111);

  wire rv32_func7_0000000 = (rv32_func7 == 7'b0000000);
  wire rv32_func7_0100000 = (rv32_func7 == 7'b0100000);
  wire rv32_func7_0000001 = (rv32_func7 == 7'b0000001);
  wire rv32_func7_0000101 = (rv32_func7 == 7'b0000101);
  wire rv32_func7_0000110 = (rv32_func7 == 7'b0000110);
  wire rv32_func7_0001110 = (rv32_func7 == 7'b0001110);
  wire rv32_func7_0010110 = (rv32_func7 == 7'b0010110);
  wire rv32_func7_0000111 = (rv32_func7 == 7'b0000111);
  wire rv32_func7_0001001 = (rv32_func7 == 7'b0001001);
  wire rv32_func7_0001101 = (rv32_func7 == 7'b0001101);
  wire rv32_func7_0010101 = (rv32_func7 == 7'b0010101);
  wire rv32_func7_0100001 = (rv32_func7 == 7'b0100001);
  wire rv32_func7_0010001 = (rv32_func7 == 7'b0010001);
  wire rv32_func7_0010010 = (rv32_func7 == 7'b0010010);
  wire rv32_func7_0010011 = (rv32_func7 == 7'b0010011);
  wire rv32_func7_0101101 = (rv32_func7 == 7'b0101101);
  wire rv32_func7_1111110 = (rv32_func7 == 7'b1111110);
  wire rv32_func7_1111111 = (rv32_func7 == 7'b1111111);
  wire rv32_func7_0000100 = (rv32_func7 == 7'b0000100); 
  wire rv32_func7_0001000 = (rv32_func7 == 7'b0001000); 
  wire rv32_func7_0001100 = (rv32_func7 == 7'b0001100); 
  wire rv32_func7_0101100 = (rv32_func7 == 7'b0101100); 
  wire rv32_func7_0010000 = (rv32_func7 == 7'b0010000); 
  wire rv32_func7_0010100 = (rv32_func7 == 7'b0010100); 
  wire rv32_func7_0011100 = (rv32_func7 == 7'b0011100);
  wire rv32_func7_0011101 = (rv32_func7 == 7'b0011101);
  wire rv32_func7_1100000 = (rv32_func7 == 7'b1100000); 
  wire rv32_func7_1110000 = (rv32_func7 == 7'b1110000); 
  wire rv32_func7_1111100 = (rv32_func7 == 7'b1111100);
  wire rv32_func7_1010000 = (rv32_func7 == 7'b1010000); 
  wire rv32_func7_1101000 = (rv32_func7 == 7'b1101000); 
  wire rv32_func7_1111000 = (rv32_func7 == 7'b1111000); 
  wire rv32_func7_1100011 = (rv32_func7 == 7'b1100011);
  wire rv32_func7_1010001 = (rv32_func7 == 7'b1010001);  
  wire rv32_func7_1011000 = (rv32_func7 == 7'b1011000);
  wire rv32_func7_1011001 = (rv32_func7 == 7'b1011001);
  wire rv32_func7_1110001 = (rv32_func7 == 7'b1110001);  
  wire rv32_func7_1111001 = (rv32_func7 == 7'b1111001);
  wire rv32_func7_1100010 = (rv32_func7 == 7'b1100010);
  wire rv32_func7_1111101 = (rv32_func7 == 7'b1111101);
  wire rv32_func7_1100001 = (rv32_func7 == 7'b1100001);  
  wire rv32_func7_1101001 = (rv32_func7 == 7'b1101001);  
  wire rv32_func7_1000011 = (rv32_func7 == 7'b1000011);
  wire rv32_func7_1011011 = (rv32_func7 == 7'b1011011);
  wire rv32_func7_1011010 = (rv32_func7 == 7'b1011010);
  wire rv32_func7_1010010 = (rv32_func7 == 7'b1010010);
  wire rv32_func7_1010011 = (rv32_func7 == 7'b1010011);
  wire rv32_func7_1001011 = (rv32_func7 == 7'b1001011);
  wire rv32_func7_1001010 = (rv32_func7 == 7'b1001010);
  wire rv32_func7_1010100 = (rv32_func7 == 7'b1010100);
  wire rv32_func7_1010101 = (rv32_func7 == 7'b1010101);
  wire rv32_func7_1011100 = (rv32_func7 == 7'b1011100);
  wire rv32_func7_1011101 = (rv32_func7 == 7'b1011101);
  wire rv32_func7_1000111 = (rv32_func7 == 7'b1000111);
  wire rv32_func7_1001111 = (rv32_func7 == 7'b1001111);
  wire rv32_func7_0110000 = (rv32_func7 == 7'b0110000);
  wire rv32_func7_0111000 = (rv32_func7 == 7'b0111000);


  wire rv32_rs1_x0 = (rv32_rs1 == 5'b00000);
  wire rv32_rs2_x0 = (rv32_rs2 == 5'b00000);
  wire rv32_rs2_x1 = (rv32_rs2 == 5'b00001);
  wire rv32_rd_x0  = (rv32_rd  == 5'b00000);
  wire rv32_rd_x2  = (rv32_rd  == 5'b00010);

  wire rv16_rs1_x0 = (rv16_rs1 == 5'b00000);
  wire rv16_rs2_x0 = (rv16_rs2 == 5'b00000);
  wire rv16_rd_x0  = (rv16_rd  == 5'b00000);
  wire rv16_rd_x2  = (rv16_rd  == 5'b00010);

  wire rv32_rs1_x31 = (rv32_rs1 == 5'b11111);
  wire rv32_rs2_x31 = (rv32_rs2 == 5'b11111);
  wire rv32_rd_x31  = (rv32_rd  == 5'b11111);

  wire rv32_load     = opcode_6_5_00 & opcode_4_2_000 & opcode_1_0_11; 
  wire rv32_store    = opcode_6_5_01 & opcode_4_2_000 & opcode_1_0_11; 
  wire rv32_madd     = opcode_6_5_10 & opcode_4_2_000 & opcode_1_0_11; 
  wire rv32_branch   = opcode_6_5_11 & opcode_4_2_000 & opcode_1_0_11; 

  wire rv32_load_fp  = opcode_6_5_00 & opcode_4_2_001 & opcode_1_0_11; 
  wire rv32_store_fp = opcode_6_5_01 & opcode_4_2_001 & opcode_1_0_11; 
  wire rv32_msub     = opcode_6_5_10 & opcode_4_2_001 & opcode_1_0_11; 
  wire rv32_jalr     = opcode_6_5_11 & opcode_4_2_001 & opcode_1_0_11; 

  wire rv32_custom0  = opcode_6_5_00 & opcode_4_2_010 & opcode_1_0_11; 
  wire rv32_custom1  = opcode_6_5_01 & opcode_4_2_010 & opcode_1_0_11; 
  wire rv32_nmsub    = opcode_6_5_10 & opcode_4_2_010 & opcode_1_0_11; 
  wire rv32_resved0  = opcode_6_5_11 & opcode_4_2_010 & opcode_1_0_11; 

  wire rv32_miscmem  = opcode_6_5_00 & opcode_4_2_011 & opcode_1_0_11; 
  `ifdef E203_SUPPORT_AMO//{
  wire rv32_amo      = opcode_6_5_01 & opcode_4_2_011 & opcode_1_0_11; 
  `endif//E203_SUPPORT_AMO}
  `ifndef E203_SUPPORT_AMO//{
  wire rv32_amo      = 1'b0;
  `endif//}
  wire rv32_nmadd    = opcode_6_5_10 & opcode_4_2_011 & opcode_1_0_11; 
  wire rv32_jal      = opcode_6_5_11 & opcode_4_2_011 & opcode_1_0_11; 

  wire rv32_op_imm   = opcode_6_5_00 & opcode_4_2_100 & opcode_1_0_11; 
  wire rv32_op       = opcode_6_5_01 & opcode_4_2_100 & opcode_1_0_11; 
  wire rv32_op_fp    = opcode_6_5_10 & opcode_4_2_100 & opcode_1_0_11; 
  wire rv32_system   = opcode_6_5_11 & opcode_4_2_100 & opcode_1_0_11; 

  wire rv32_auipc    = opcode_6_5_00 & opcode_4_2_101 & opcode_1_0_11; 
  wire rv32_lui      = opcode_6_5_01 & opcode_4_2_101 & opcode_1_0_11; 
  wire rv32_resved1  = opcode_6_5_10 & opcode_4_2_101 & opcode_1_0_11; 
  wire rv32_resved2  = opcode_6_5_11 & opcode_4_2_101 & opcode_1_0_11; 

  wire rv32_op_imm_32= opcode_6_5_00 & opcode_4_2_110 & opcode_1_0_11; 
  wire rv32_op_32    = opcode_6_5_01 & opcode_4_2_110 & opcode_1_0_11; 
  wire rv32_custom2  = opcode_6_5_10 & opcode_4_2_110 & opcode_1_0_11; 
  wire rv32_custom3  = opcode_6_5_11 & opcode_4_2_110 & opcode_1_0_11; 

  wire rv16_addi4spn     = opcode_1_0_00 & rv16_func3_000;//
  wire rv16_lw           = opcode_1_0_00 & rv16_func3_010;//
  wire rv16_sw           = opcode_1_0_00 & rv16_func3_110;//


  wire rv16_addi         = opcode_1_0_01 & rv16_func3_000;//
  wire rv16_jal          = opcode_1_0_01 & rv16_func3_001;//
  wire rv16_li           = opcode_1_0_01 & rv16_func3_010;//
  wire rv16_lui_addi16sp = opcode_1_0_01 & rv16_func3_011;//--
  wire rv16_miscalu      = opcode_1_0_01 & rv16_func3_100;//--
  wire rv16_j            = opcode_1_0_01 & rv16_func3_101;//
  wire rv16_beqz         = opcode_1_0_01 & rv16_func3_110;//
  wire rv16_bnez         = opcode_1_0_01 & rv16_func3_111;//


  wire rv16_slli         = opcode_1_0_10 & rv16_func3_000;//
  wire rv16_lwsp         = opcode_1_0_10 & rv16_func3_010;//
  wire rv16_jalr_mv_add  = opcode_1_0_10 & rv16_func3_100;//--
  wire rv16_swsp         = opcode_1_0_10 & rv16_func3_110;//

  `ifndef E203_HAS_FPU//{
  wire rv16_flw          = 1'b0;
  wire rv16_fld          = 1'b0;
  wire rv16_fsw          = 1'b0;
  wire rv16_fsd          = 1'b0;
  wire rv16_fldsp        = 1'b0;
  wire rv16_flwsp        = 1'b0;
  wire rv16_fsdsp        = 1'b0;
  wire rv16_fswsp        = 1'b0;
  `endif//}

  wire rv16_lwsp_ilgl    = rv16_lwsp & rv16_rd_x0;//(RES, rd=0)

  wire rv16_nop          = rv16_addi  
                         & (~rv16_instr[12]) & (rv16_rd_x0) & (rv16_rs2_x0);

  wire rv16_srli         = rv16_miscalu  & (rv16_instr[11:10] == 2'b00);
  wire rv16_srai         = rv16_miscalu  & (rv16_instr[11:10] == 2'b01);
  wire rv16_andi         = rv16_miscalu  & (rv16_instr[11:10] == 2'b10);

  wire rv16_instr_12_is0   = (rv16_instr[12] == 1'b0);
  wire rv16_instr_6_2_is0s = (rv16_instr[6:2] == 5'b0);

  wire rv16_sxxi_shamt_legl = 
                 rv16_instr_12_is0 //shamt[5] must be zero for RV32C
               & (~(rv16_instr_6_2_is0s)) //shamt[4:0] must be non-zero for RV32C
                 ;
  wire rv16_sxxi_shamt_ilgl =  (rv16_slli | rv16_srli | rv16_srai) & (~rv16_sxxi_shamt_legl);

  wire rv16_addi16sp     = rv16_lui_addi16sp & rv32_rd_x2;//
  wire rv16_lui          = rv16_lui_addi16sp & (~rv32_rd_x0) & (~rv32_rd_x2);//
  
  //C.LI is only valid when rd!=x0.
  wire rv16_li_ilgl = rv16_li & (rv16_rd_x0);
  //C.LUI is only valid when rd!=x0 or x2, and when the immediate is not equal to zero.
  wire rv16_lui_ilgl = rv16_lui & (rv16_rd_x0 | rv16_rd_x2 | (rv16_instr_6_2_is0s & rv16_instr_12_is0));

  wire rv16_li_lui_ilgl = rv16_li_ilgl | rv16_lui_ilgl;

  wire rv16_addi4spn_ilgl = rv16_addi4spn & (rv16_instr_12_is0 & rv16_rd_x0 & opcode_6_5_00);//(RES, nzimm=0, bits[12:5])
  wire rv16_addi16sp_ilgl = rv16_addi16sp & rv16_instr_12_is0 & rv16_instr_6_2_is0s; //(RES, nzimm=0, bits 12,6:2)

  wire rv16_subxororand  = rv16_miscalu  & (rv16_instr[12:10] == 3'b011);//
  wire rv16_sub          = rv16_subxororand & (rv16_instr[6:5] == 2'b00);//
  wire rv16_xor          = rv16_subxororand & (rv16_instr[6:5] == 2'b01);//
  wire rv16_or           = rv16_subxororand & (rv16_instr[6:5] == 2'b10);//
  wire rv16_and          = rv16_subxororand & (rv16_instr[6:5] == 2'b11);//

  wire rv16_jr           = rv16_jalr_mv_add //
                         & (~rv16_instr[12]) & (~rv16_rs1_x0) & (rv16_rs2_x0);// The RES rs1=0 illegal is already covered here
  wire rv16_mv           = rv16_jalr_mv_add //
                         & (~rv16_instr[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);
  wire rv16_ebreak       = rv16_jalr_mv_add //
                         & (rv16_instr[12]) & (rv16_rd_x0) & (rv16_rs2_x0);
  wire rv16_jalr         = rv16_jalr_mv_add //
                         & (rv16_instr[12]) & (~rv16_rs1_x0) & (rv16_rs2_x0);
  wire rv16_add          = rv16_jalr_mv_add // 
                         & (rv16_instr[12]) & (~rv16_rd_x0) & (~rv16_rs2_x0);

  
  // ==========================================================================
  // add nice logic 

  wire nice_need_rs1 = rv32_instr[13];
  wire nice_need_rs2 = rv32_instr[12];
  wire nice_need_rd  = rv32_instr[14];
  wire [31:5] nice_instr  = rv32_instr[31:5];

  wire nice_op = rv32_custom0 | rv32_custom1 | rv32_custom2 | rv32_custom3;
  assign dec_nice = nice_op;
  
  assign nice_cmt_off_ilgl_o = nice_xs_off & nice_op;

  wire [`E203_DECINFO_EAI_WIDTH-1:0] nice_info_bus;
  assign nice_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_EAI;
  assign nice_info_bus[`E203_DECINFO_RV32   ]    = rv32;
  assign nice_info_bus[`E203_DECINFO_EAI_INSTR]  = nice_instr;

  // ===========================================================================
  // Branch Instructions
  wire rv32_beq      = rv32_branch & rv32_func3_000;
  wire rv32_bne      = rv32_branch & rv32_func3_001;
  wire rv32_blt      = rv32_branch & rv32_func3_100;
  wire rv32_bgt      = rv32_branch & rv32_func3_101;
  wire rv32_bltu     = rv32_branch & rv32_func3_110;
  wire rv32_bgtu     = rv32_branch & rv32_func3_111;

  // ===========================================================================
  // System Instructions
  wire rv32_ecall    = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0000_0000_0000);
  wire rv32_ebreak   = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0000_0000_0001);
  wire rv32_mret     = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0011_0000_0010);
  wire rv32_dret     = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0111_1011_0010);
  wire rv32_wfi      = rv32_system & rv32_func3_000 & (rv32_instr[31:20] == 12'b0001_0000_0101);
  // We dont implement the WFI and MRET illegal exception when the rs and rd is not zeros

  wire rv32_csrrw    = rv32_system & rv32_func3_001; 
  wire rv32_csrrs    = rv32_system & rv32_func3_010; 
  wire rv32_csrrc    = rv32_system & rv32_func3_011; 
  wire rv32_csrrwi   = rv32_system & rv32_func3_101; 
  wire rv32_csrrsi   = rv32_system & rv32_func3_110; 
  wire rv32_csrrci   = rv32_system & rv32_func3_111; 

  wire rv32_dret_ilgl = rv32_dret & (~dbg_mode);

  wire rv32_ecall_ebreak_ret_wfi = rv32_system & rv32_func3_000;
  wire rv32_csr          = rv32_system & (~rv32_func3_000);


  // ===========================================================================
  // The DSP Logic




  wire [`E203_RFIDX_WIDTH-1:0] rv32_rc = rv32_instr[29:25];

  wire rv32_dsp_op = (rv32_instr[6:0] == 7'b1111111);
  wire rs2_is_imm_h     = rv32_instr[24];
  wire rs2_is_imm_h_0   = (rs2_is_imm_h == 1'b0);
  wire rs2_is_imm_h_1   = (rs2_is_imm_h == 1'b1);
  wire [1:0] rs2_is_imm_b     = rv32_instr[24:23];
  wire rs2_is_imm_b_00  = (rs2_is_imm_b == 2'b00);
  wire rs2_is_imm_b_01  = (rs2_is_imm_b == 2'b01);
  wire rs2_is_imm_b_10  = (rs2_is_imm_b == 2'b10);
  wire [4:0] rs2_is_fixed = rv32_instr[24:20];

  wire rs2_is_fixed_01000 = (rs2_is_fixed == 5'b01000);           // unpack_sunpkd810/clrs16
  wire rs2_is_fixed_01001 = (rs2_is_fixed == 5'b01001);           // unpack_sunpkd820/clz16
  wire rs2_is_fixed_01010 = (rs2_is_fixed == 5'b01010);           // unpack_sunpkd830
  wire rs2_is_fixed_01011 = (rs2_is_fixed == 5'b01011);           // unpack_sunpkd831/clo16
  wire rs2_is_fixed_10011 = (rs2_is_fixed == 5'b10011);           // unpack_sunpkd832
  wire rs2_is_fixed_01100 = (rs2_is_fixed == 5'b01100);           // unpack_zunpkd810
  wire rs2_is_fixed_01101 = (rs2_is_fixed == 5'b01101);           // unpack_zunpkd820
  wire rs2_is_fixed_01110 = (rs2_is_fixed == 5'b01110);           // unpack_zunpkd830
  wire rs2_is_fixed_01111 = (rs2_is_fixed == 5'b01111);           // unpack_zunpkd831
  wire rs2_is_fixed_10111 = (rs2_is_fixed == 5'b10111);           // unpack_zunpkd832
  wire rs2_is_fixed_00000 = (rs2_is_fixed == 5'b00000);           // cl8
  wire rs2_is_fixed_00001 = (rs2_is_fixed == 5'b00001);
  wire rs2_is_fixed_00011 = (rs2_is_fixed == 5'b00011);
  wire rs2_is_fixed_11000 = (rs2_is_fixed == 5'b11000);           // clrs32/swap8
  wire rs2_is_fixed_11001 = (rs2_is_fixed == 5'b11001);           // clz32/swap16
  wire rs2_is_fixed_11011 = (rs2_is_fixed == 5'b11011);           // clo32

  wire rs2_is_fixed_10001 = (rs2_is_fixed == 5'b10001);           // KABS16
  wire rs2_is_fixed_10000 = (rs2_is_fixed == 5'b10000);           // KABS8
  wire rs2_is_fixed_10100 = (rs2_is_fixed == 5'b10100);           // KABSW/SWAP8

  wire rv32_func7_0111100 = (rv32_func7 == 7'b0111100);
  wire rv32_func7_0110100 = (rv32_func7 == 7'b0110100);
  wire rv32_func7_0111101 = (rv32_func7 == 7'b0111101);
  wire rv32_func7_0110101 = (rv32_func7 == 7'b0110101);
  wire rv32_func7_0100100 = (rv32_func7 == 7'b0100100);
  wire rv32_func7_0100101 = (rv32_func7 == 7'b0100101);
  wire rv32_func7_0101110 = (rv32_func7 == 7'b0101110);
  wire rv32_func7_0111110 = (rv32_func7 == 7'b0111110);
  wire rv32_func7_0100110 = (rv32_func7 == 7'b0100110);
  wire rv32_func7_0100111 = (rv32_func7 == 7'b0100111);
  wire rv32_func7_1100100 = (rv32_func7 == 7'b1100100);
  wire rv32_func7_1100110 = (rv32_func7 == 7'b1100110);
  wire rv32_func7_1100101 = (rv32_func7 == 7'b1100101);
  wire rv32_func7_0110110 = (rv32_func7 == 7'b0110110);
  wire rv32_func7_0101111 = (rv32_func7 == 7'b0101111);
  wire rv32_func7_1000100 = (rv32_func7 == 7'b1000100);
  wire rv32_func7_1001100 = (rv32_func7 == 7'b1001100);
  wire rv32_func7_0110111 = (rv32_func7 == 7'b0110111);
  wire rv32_func7_0101000 = (rv32_func7 == 7'b0101000);           // shift16
  wire rv32_func7_0101001 = (rv32_func7 == 7'b0101001);
  wire rv32_func7_0111001 = (rv32_func7 == 7'b0111001);
  wire rv32_func7_0110001 = (rv32_func7 == 7'b0110001);
  wire rv32_func7_0101010 = (rv32_func7 == 7'b0101010);
  wire rv32_func7_0100010 = (rv32_func7 == 7'b0100010);
  wire rv32_func7_0111010 = (rv32_func7 == 7'b0111010);
  wire rv32_func7_0110010 = (rv32_func7 == 7'b0110010);
  wire rv32_func7_0100011 = (rv32_func7 == 7'b0100011);
  wire rv32_func7_0101011 = (rv32_func7 == 7'b0101011);
  wire rv32_func7_0110011 = (rv32_func7 == 7'b0110011);
  wire rv32_func7_0111011 = (rv32_func7 == 7'b0111011);
  wire rv32_func7_110101x = (rv32_func7[6:1] == 6'b110101);       // SRAIU
  wire rv32_func7_0111111 = (rv32_func7 == 7'b0111111);
  wire rv32_func7_0011011 = (rv32_func7 == 7'b0011011);
  wire rv32_func7_1000110 = (rv32_func7 == 7'b1000110);           // clip8
  wire rv32_func7_1001110 = (rv32_func7 == 7'b1001110);
  wire rv32_func7_1000101 = (rv32_func7 == 7'b1000101);
  wire rv32_func7_1001101 = (rv32_func7 == 7'b1001101);
  wire rv32_func7_1000010 = (rv32_func7 == 7'b1000010);           // clip16
  wire rv32_func7_1110010 = (rv32_func7 == 7'b1110010);           // clip32
  wire rv32_func7_1111010 = (rv32_func7 == 7'b1111010);
  wire rv32_func7_1010110 = (rv32_func7 == 7'b1010110);           // unpack/insb/swap
  wire rv32_func7_0001111 = (rv32_func7 == 7'b0001111);
  wire rv32_func7_0010111 = (rv32_func7 == 7'b0010111);
  wire rv32_func7_0011111 = (rv32_func7 == 7'b0011111);
  wire rv32_func7_1010111 = (rv32_func7 == 7'b1010111);           // cl8/16/32
  wire rv32_func7_1011111 = (rv32_func7 == 7'b1011111);
  wire rv32_func7_1110011 = (rv32_func7 == 7'b1110011);           // bitrev
  wire rv32_func7_111010x = (rv32_func7[6:1] == 6'b111010);       // bitrevi
  wire rv32_func7_1100111 = (rv32_func7 == 7'b1100111);           // wext
  wire rv32_func7_1101111 = (rv32_func7 == 7'b1101111);
  wire rv32_func7_1110111 = (rv32_func7 == 7'b1110111);
  wire rv32_func7_1011110 = (rv32_func7 == 7'b1011110);
  wire rv32_func7_11xxxxx = (rv32_func7[6:5] == 2'b11);           // bpick
 
  wire rv32_func7_0011001 = rv32_func7 == 7'b0011001;
  wire rv32_func7_0011010 = rv32_func7 == 7'b0011010;    
  wire rv32_func7_0011110 = rv32_func7 == 7'b0011110;    
  wire rv32_func7_1000001 = rv32_func7 == 7'b1000001;   
  wire rv32_func7_1000000 = rv32_func7 == 7'b1000000;   
  wire rv32_func7_1001001 = rv32_func7 == 7'b1001001;   
  wire rv32_func7_1001000 = rv32_func7 == 7'b1001000;   
  wire rv32_func7_0000010 = rv32_func7 == 7'b0000010;   
  wire rv32_func7_0001010 = rv32_func7 == 7'b0001010;   
  wire rv32_func7_0000011 = rv32_func7 == 7'b0000011;   
  wire rv32_func7_0001011 = rv32_func7 == 7'b0001011;   
  wire rv32_func7_0011000 = rv32_func7 == 7'b0011000;


  wire dsp_op_sra8      = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101100;
  wire dsp_op_srai8     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111100 & rs2_is_imm_b_00;    // need rs2field
  wire dsp_op_sra8u     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110100;
  wire dsp_op_srai8u    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111100 & rs2_is_imm_b_01;    // need rs2field
  wire dsp_op_srl8      = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101101;
  wire dsp_op_srli8     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111101 & rs2_is_imm_b_00;    // need rs2field
  wire dsp_op_srl8u     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110101;
  wire dsp_op_srli8u    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111101 & rs2_is_imm_b_01;    // need rs2field
  wire dsp_op_sll8      = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101110;
  wire dsp_op_slli8     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111110 & rs2_is_imm_b_00;    // need rs2field
  wire dsp_op_ksll8     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110110;
  wire dsp_op_kslli8    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111110 & rs2_is_imm_b_01;    // need rs2field
  wire dsp_op_kslra8    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101111;
  wire dsp_op_kslra8u   = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110111;
  wire dsp_op_sra16     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101000;
  wire dsp_op_srai16    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111000 & rs2_is_imm_h_0;     // need rs2field
  wire dsp_op_sra16u    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110000;
  wire dsp_op_srai16u   = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111000 & rs2_is_imm_h_1;     // need rs2field
  wire dsp_op_srl16     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101001;
  wire dsp_op_srli16    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111001 & rs2_is_imm_h_0;     // need rs2field
  wire dsp_op_srl16u    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110001;
  wire dsp_op_srli16u   = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111001 & rs2_is_imm_h_1;     // need rs2field
  wire dsp_op_sll16     = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101010;
  wire dsp_op_slli16    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111010 & rs2_is_imm_h_0;     // need rs2field
  wire dsp_op_ksll16    = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110010;
  wire dsp_op_kslli16   = rv32_dsp_op & rv32_func3_000 & rv32_func7_0111010 & rs2_is_imm_h_1;     // need rs2field
  wire dsp_op_kslra16   = rv32_dsp_op & rv32_func3_000 & rv32_func7_0101011;
  wire dsp_op_kslra16u  = rv32_dsp_op & rv32_func3_000 & rv32_func7_0110011;
  wire dsp_op_srau      = rv32_dsp_op & rv32_func3_001 & rv32_func7_0010010;
  wire dsp_op_sraiu     = rv32_dsp_op & rv32_func3_001 & rv32_func7_110101x;                      // func7 is 6 bit
  wire dsp_op_kslraw    = rv32_dsp_op & rv32_func3_001 & rv32_func7_0110111;
  wire dsp_op_kslrawu   = rv32_dsp_op & rv32_func3_001 & rv32_func7_0111111;
  wire dsp_op_ksllw     = rv32_dsp_op & rv32_func3_001 & rv32_func7_0010011;
  wire dsp_op_kslliw    = rv32_dsp_op & rv32_func3_001 & rv32_func7_0011011;


  wire dsp_op_sclip8    = rv32_dsp_op & rv32_func3_000 & rv32_func7_1000110 & rs2_is_imm_b_00;    // need rs2field
  wire dsp_op_uclip8    = rv32_dsp_op & rv32_func3_000 & rv32_func7_1000110 & rs2_is_imm_b_10;    // need rs2field 
  wire dsp_op_sclip16   = rv32_dsp_op & rv32_func3_000 & rv32_func7_1000010 & rs2_is_imm_h_0;     // need rs2field
  wire dsp_op_uclip16   = rv32_dsp_op & rv32_func3_000 & rv32_func7_1000010 & rs2_is_imm_h_1;     // need rs2field
  wire dsp_op_sclip32   = rv32_dsp_op & rv32_func3_000 & rv32_func7_1110010;						
  wire dsp_op_uclip32   = rv32_dsp_op & rv32_func3_000 & rv32_func7_1111010;
  wire dsp_op_sunpkd810 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01000; // rs2 is fixed
  wire dsp_op_sunpkd820 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01001; // rs2 is fixed
  wire dsp_op_sunpkd830 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01010; // rs2 is fixed
  wire dsp_op_sunpkd831 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01011; // rs2 is fixed
  wire dsp_op_sunpkd832 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_10011; // rs2 is fixed
  wire dsp_op_zunpkd810 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01100; // rs2 is fixed
  wire dsp_op_zunpkd820 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01101; // rs2 is fixed
  wire dsp_op_zunpkd830 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01110; // rs2 is fixed
  wire dsp_op_zunpkd831 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_01111; // rs2 is fixed
  wire dsp_op_zunpkd832 = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_10111; // rs2 is fixed
  wire dsp_op_packbb16  = rv32_dsp_op & rv32_func3_001 & rv32_func7_0000111;
  wire dsp_op_packbt16  = rv32_dsp_op & rv32_func3_001 & rv32_func7_0001111;
  wire dsp_op_packtb16  = rv32_dsp_op & rv32_func3_001 & rv32_func7_0011111;
  wire dsp_op_packtt16  = rv32_dsp_op & rv32_func3_001 & rv32_func7_0010111;
  wire dsp_op_clrs8     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_00000; // rs2 is fixed
  wire dsp_op_clz8      = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_00001; // rs2 is fixed 
  wire dsp_op_clo8      = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_00011; // rs2 is fixed
  wire dsp_op_clrs16    = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_01000; // rs2 is fixed
  wire dsp_op_clz16     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_01001; // rs2 is fixed
  wire dsp_op_clo16     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_01011; // rs2 is fixed
  wire dsp_op_clrs32    = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_11000; // rs2 is fixed
  wire dsp_op_clz32     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_11001; // rs2 is fixed
  wire dsp_op_clo32     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010111 & rs2_is_fixed_11011; // rs2 is fixed
  wire dsp_op_bitrev    = rv32_dsp_op & rv32_func3_000 & rv32_func7_1110011;
  wire dsp_op_bitrevi   = rv32_dsp_op & rv32_func3_000 & rv32_func7_111010x;                      // func7 is 6 bit
  wire dsp_op_wext      = rv32_dsp_op & rv32_func3_000 & rv32_func7_1100111;
  wire dsp_op_wexti     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1101111;
  wire dsp_op_bpick     = rv32_dsp_op & rv32_func3_010 & rv32_func7_11xxxxx;
  wire dsp_op_insb      = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_imm_b_00;    // need rs2field 
  wire dsp_op_swap8     = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_11000; // rs2 is fixed 
  wire dsp_op_swap16    = rv32_dsp_op & rv32_func3_000 & rv32_func7_1010110 & rs2_is_fixed_11001; // rs2 is fixed 

  wire dsp_misc_op;

  wire dsp_op_add8     = rv32_func7_0100100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_radd8    = rv32_func7_0000100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_uradd8   = rv32_func7_0010100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_kadd8    = rv32_func7_0001100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ukadd8   = rv32_func7_0011100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_sub8     = rv32_func7_0100101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_rsub8    = rv32_func7_0000101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ursub8   = rv32_func7_0010101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ksub8    = rv32_func7_0001101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_uksub8   = rv32_func7_0011101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_cmpeq8   = rv32_func7_0100111 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_scmplt8  = rv32_func7_0000111 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_scmple8  = rv32_func7_0001111 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ucmplt8  = rv32_func7_0010111 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ucmple8  = rv32_func7_0011111 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_smax8    = rv32_func7_1000101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_smin8    = rv32_func7_1000100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_umax8    = rv32_func7_1001101 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_umin8    = rv32_func7_1001100 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_kabs8    = rv32_func7_1010110 & rs2_is_fixed_10000 & rv32_func3_000 & rv32_dsp_op;
  wire dsp_op_add16    = rv32_func7_0100000 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_radd16   = rv32_func7_0000000 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_uradd16  = rv32_func7_0010000 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_kadd16   = rv32_func7_0001000 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ukadd16  = rv32_func7_0011000 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_sub16    = rv32_func7_0100001 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_rsub16   = rv32_func7_0000001 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ursub16  = rv32_func7_0010001 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_ksub16   = rv32_func7_0001001 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_uksub16  = rv32_func7_0011001 & rv32_func3_000 & rv32_dsp_op ;
  wire dsp_op_cras16   = rv32_func7_0100010 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_rcras16  = rv32_func7_0000010 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_urcras16 = rv32_func7_0010010 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_kcras16  = rv32_func7_0001010 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_ukcras16 = rv32_func7_0011010 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_crsa16   = rv32_func7_0100011 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_rcrsa16  = rv32_func7_0000011 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_urcrsa16 = rv32_func7_0010011 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_kcrsa16  = rv32_func7_0001011 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_ukcrsa16 = rv32_func7_0011011 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_stas16   = rv32_func7_0100010 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_rstas16  = rv32_func7_0000010 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_urstas16 = rv32_func7_0010010 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_kstas16  = rv32_func7_0001010 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_ukstas16 = rv32_func7_0011010 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_stsa16   = rv32_func7_0100011 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_rstsa16  = rv32_func7_0000011 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_urstsa16 = rv32_func7_0010011 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_kstsa16  = rv32_func7_0001011 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_ukstsa16 = rv32_func7_0011011 & rv32_func3_011 & rv32_dsp_op ;    
  wire dsp_op_cmpeq16  = rv32_func7_0100110 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_scmplt16 = rv32_func7_0000110 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_scmple16 = rv32_func7_0001110 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_ucmplt16 = rv32_func7_0010110 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_ucmple16 = rv32_func7_0011110 & rv32_func3_000 & rv32_dsp_op ;    
  wire dsp_op_smax16   = rv32_func7_1000001 & rv32_func3_000 & rv32_dsp_op ;   
  wire dsp_op_smin16   = rv32_func7_1000000 & rv32_func3_000 & rv32_dsp_op ;   
  wire dsp_op_umax16   = rv32_func7_1001001 & rv32_func3_000 & rv32_dsp_op ;   
  wire dsp_op_umin16   = rv32_func7_1001000 & rv32_func3_000 & rv32_dsp_op ;   
  wire dsp_op_kabs16   = rv32_func7_1010110 & rs2_is_fixed_10001 & rv32_func3_000 & rv32_dsp_op;
  wire dsp_op_kaddh    = rv32_func7_0000010 & rv32_func3_001 & rv32_dsp_op ;   
  wire dsp_op_ukaddh   = rv32_func7_0001010 & rv32_func3_001 & rv32_dsp_op ;   
  wire dsp_op_ksubh    = rv32_func7_0000011 & rv32_func3_001 & rv32_dsp_op ;   
  wire dsp_op_uksubh   = rv32_func7_0001011 & rv32_func3_001 & rv32_dsp_op ;   
  wire dsp_op_kaddw    = rv32_func7_0000000 & rv32_func3_001 & rv32_dsp_op ; 
  wire dsp_op_ukaddw   = rv32_func7_0001000 & rv32_func3_001 & rv32_dsp_op ; 
  wire dsp_op_raddw    = rv32_func7_0010000 & rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_uraddw   = rv32_func7_0011000 & rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_ksubw    = rv32_func7_0000001 & rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_uksubw   = rv32_func7_0001001 & rv32_func3_001 & rv32_dsp_op ;   
  wire dsp_op_rsubw    = rv32_func7_0010001 & rv32_func3_001 & rv32_dsp_op ;  
  wire dsp_op_ursubw   = rv32_func7_0011001 & rv32_func3_001 & rv32_dsp_op ;  
  wire dsp_op_maxw     = rv32_func7_1111001 & rv32_func3_000 & rv32_dsp_op ; 
  wire dsp_op_minw     = rv32_func7_1111000 & rv32_func3_000 & rv32_dsp_op ; 
  wire dsp_op_kabsw    = rv32_func7_1010110 & rs2_is_fixed_10100 & rv32_func3_000 & rv32_dsp_op;
  wire dsp_op_add64    = rv32_func7_1100000	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_radd64   = rv32_func7_1000000	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_uradd64  = rv32_func7_1010000	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_kadd64   = rv32_func7_1001000	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_ukadd64  = rv32_func7_1011000	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_sub64    = rv32_func7_1100001	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_rsub64   = rv32_func7_1000001	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_ursub64  = rv32_func7_1010001	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_ksub64   = rv32_func7_1001001	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_uksub64  = rv32_func7_1011001	& rv32_func3_001 & rv32_dsp_op ;
  wire dsp_op_ave      = rv32_func7_1110000 & rv32_func3_000 & rv32_dsp_op ;
  
  wire dsp_shift_op;


// add dsp_shift_op into dsp_info_bus
  assign dsp_shift_op = 
                      | dsp_op_sra8    
                      | dsp_op_srai8   
                      | dsp_op_sra8u   
                      | dsp_op_srai8u  
                      | dsp_op_srl8    
                      | dsp_op_srli8   
                      | dsp_op_srl8u   
                      | dsp_op_srli8u  
                      | dsp_op_sll8    
                      | dsp_op_slli8   
                      | dsp_op_ksll8   
                      | dsp_op_kslli8  
                      | dsp_op_kslra8  
                      | dsp_op_kslra8u 
                      | dsp_op_sra16   
                      | dsp_op_srai16  
                      | dsp_op_sra16u  
                      | dsp_op_srai16u 
                      | dsp_op_srl16   
                      | dsp_op_srli16  
                      | dsp_op_srl16u  
                      | dsp_op_srli16u 
                      | dsp_op_sll16   
                      | dsp_op_slli16  
                      | dsp_op_ksll16  
                      | dsp_op_kslli16 
                      | dsp_op_kslra16 
                      | dsp_op_kslra16u
                      | dsp_op_srau    
                      | dsp_op_sraiu   
                      | dsp_op_kslraw  
                      | dsp_op_kslrawu 
                      | dsp_op_ksllw   
                      | dsp_op_kslliw  
                      ;
    
  //  add dsp_misc_op into dsp_info_bus
  assign dsp_misc_op = 1'b0 
                       | dsp_op_sclip8
                       | dsp_op_uclip8   
                       | dsp_op_sclip16  
                       | dsp_op_uclip16  
                       | dsp_op_sclip32  
                       | dsp_op_uclip32  
                       | dsp_op_sunpkd810
                       | dsp_op_sunpkd820
                       | dsp_op_sunpkd830
                       | dsp_op_sunpkd831
                       | dsp_op_sunpkd832
                       | dsp_op_zunpkd810
                       | dsp_op_zunpkd820
                       | dsp_op_zunpkd830
                       | dsp_op_zunpkd831
                       | dsp_op_zunpkd832
                       | dsp_op_packbb16 
                       | dsp_op_packbt16 
                       | dsp_op_packtb16 
                       | dsp_op_packtt16 
                       | dsp_op_clrs8    
                       | dsp_op_clz8     
                       | dsp_op_clo8     
                       | dsp_op_clrs16   
                       | dsp_op_clz16    
                       | dsp_op_clo16    
                       | dsp_op_clrs32   
                       | dsp_op_clz32    
                       | dsp_op_clo32    
                       | dsp_op_bitrev   
                       | dsp_op_bitrevi  
                       | dsp_op_wext     
                       | dsp_op_wexti    
                       | dsp_op_bpick    
                       | dsp_op_insb     
                       | dsp_op_swap8    
                       | dsp_op_swap16   
                       ;


  wire [`E203_DECINFO_DSP_WIDTH-1:0] dsp_info_bus;
  assign  dsp_info_bus[`E203_DECINFO_GRP]           = `E203_DECINFO_GRP_DSP;
  assign  dsp_info_bus[`E203_DECINFO_RV32]          = rv32;



  assign dec_dsp_info = dsp_info_bus;


  wire rv32_dsp_smul16     = rv32_dsp_op & rv32_func7_1010000 & rv32_func3_000;						
  wire rv32_dsp_smulx16    = rv32_dsp_op & rv32_func7_1010001 & rv32_func3_000;
  wire rv32_dsp_umul16     = rv32_dsp_op & rv32_func7_1011000 & rv32_func3_000;						
  wire rv32_dsp_umulx16    = rv32_dsp_op & rv32_func7_1011001 & rv32_func3_000;
  wire rv32_dsp_khm16      = rv32_dsp_op & rv32_func7_1000011 & rv32_func3_000;
  wire rv32_dsp_khmx16     = rv32_dsp_op & rv32_func7_1001011 & rv32_func3_000;
  wire rv32_dsp_smul8      = rv32_dsp_op & rv32_func7_1010100 & rv32_func3_000;
  wire rv32_dsp_smulx8     = rv32_dsp_op & rv32_func7_1010101 & rv32_func3_000;
  wire rv32_dsp_umul8      = rv32_dsp_op & rv32_func7_1011100 & rv32_func3_000;
  wire rv32_dsp_umulx8     = rv32_dsp_op & rv32_func7_1011101 & rv32_func3_000;
  wire rv32_dsp_khm8       = rv32_dsp_op & rv32_func7_1000111 & rv32_func3_000;
  wire rv32_dsp_khmx8      = rv32_dsp_op & rv32_func7_1001111 & rv32_func3_000;
  wire rv32_dsp_smmul      = rv32_dsp_op & rv32_func7_0100000 & rv32_func3_001;
  wire rv32_dsp_smmulu     = rv32_dsp_op & rv32_func7_0101000 & rv32_func3_001;
  wire rv32_dsp_kmmac      = rv32_dsp_op & rv32_func7_0110000 & rv32_func3_001;
  wire rv32_dsp_kmmacu     = rv32_dsp_op & rv32_func7_0111000 & rv32_func3_001;
  wire rv32_dsp_kmmsb      = rv32_dsp_op & rv32_func7_0100001 & rv32_func3_001;
  wire rv32_dsp_kmmsbu     = rv32_dsp_op & rv32_func7_0101001 & rv32_func3_001;
  wire rv32_dsp_kwmmul     = rv32_dsp_op & rv32_func7_0110001 & rv32_func3_001;
  wire rv32_dsp_kwmmulu    = rv32_dsp_op & rv32_func7_0111001 & rv32_func3_001;
  wire rv32_dsp_smmwb      = rv32_dsp_op & rv32_func7_0100010 & rv32_func3_001;
  wire rv32_dsp_smmwbu     = rv32_dsp_op & rv32_func7_0101010 & rv32_func3_001;
  wire rv32_dsp_smmwt      = rv32_dsp_op & rv32_func7_0110010 & rv32_func3_001;
  wire rv32_dsp_smmwtu     = rv32_dsp_op & rv32_func7_0111010 & rv32_func3_001;
  wire rv32_dsp_kmmawb     = rv32_dsp_op & rv32_func7_0100011 & rv32_func3_001;
  wire rv32_dsp_kmmawbu    = rv32_dsp_op & rv32_func7_0101011 & rv32_func3_001;
  wire rv32_dsp_kmmawt     = rv32_dsp_op & rv32_func7_0110011 & rv32_func3_001;
  wire rv32_dsp_kmmawtu    = rv32_dsp_op & rv32_func7_0111011 & rv32_func3_001;
  wire rv32_dsp_kmmwb2     = rv32_dsp_op & rv32_func7_1000111 & rv32_func3_001;
  wire rv32_dsp_kmmwb2u    = rv32_dsp_op & rv32_func7_1001111 & rv32_func3_001;
  wire rv32_dsp_kmmwt2     = rv32_dsp_op & rv32_func7_1010111 & rv32_func3_001;
  wire rv32_dsp_kmmwt2u    = rv32_dsp_op & rv32_func7_1011111 & rv32_func3_001;
  wire rv32_dsp_kmmawb2    = rv32_dsp_op & rv32_func7_1100111 & rv32_func3_001;
  wire rv32_dsp_kmmawb2u   = rv32_dsp_op & rv32_func7_1101111 & rv32_func3_001;
  wire rv32_dsp_kmmawt2    = rv32_dsp_op & rv32_func7_1110111 & rv32_func3_001;
  wire rv32_dsp_kmmawt2u   = rv32_dsp_op & rv32_func7_1111111 & rv32_func3_001;
  wire rv32_dsp_smslda     = rv32_dsp_op & rv32_func7_1010110 & rv32_func3_001;
  wire rv32_dsp_smslxda    = rv32_dsp_op & rv32_func7_1011110 & rv32_func3_001;
  wire rv32_dsp_smbb16     = rv32_dsp_op & rv32_func7_0000100 & rv32_func3_001;
  wire rv32_dsp_smbt16     = rv32_dsp_op & rv32_func7_0001100 & rv32_func3_001;
  wire rv32_dsp_smtt16     = rv32_dsp_op & rv32_func7_0010100 & rv32_func3_001;
  wire rv32_dsp_kmda       = rv32_dsp_op & rv32_func7_0011100 & rv32_func3_001;
  wire rv32_dsp_kmxda      = rv32_dsp_op & rv32_func7_0011101 & rv32_func3_001;
  wire rv32_dsp_smds       = rv32_dsp_op & rv32_func7_0101100 & rv32_func3_001;
  wire rv32_dsp_smdrs      = rv32_dsp_op & rv32_func7_0110100 & rv32_func3_001;
  wire rv32_dsp_smxds      = rv32_dsp_op & rv32_func7_0111100 & rv32_func3_001;
  wire rv32_dsp_kmabb      = rv32_dsp_op & rv32_func7_0101101 & rv32_func3_001;
  wire rv32_dsp_kmabt      = rv32_dsp_op & rv32_func7_0110101 & rv32_func3_001;
  wire rv32_dsp_kmatt      = rv32_dsp_op & rv32_func7_0111101 & rv32_func3_001;
  wire rv32_dsp_kmada      = rv32_dsp_op & rv32_func7_0100100 & rv32_func3_001;
  wire rv32_dsp_kmaxda     = rv32_dsp_op & rv32_func7_0100101 & rv32_func3_001;
  wire rv32_dsp_kmads      = rv32_dsp_op & rv32_func7_0101110 & rv32_func3_001;
  wire rv32_dsp_kmadrs     = rv32_dsp_op & rv32_func7_0110110 & rv32_func3_001;
  wire rv32_dsp_kmaxds     = rv32_dsp_op & rv32_func7_0111110 & rv32_func3_001;
  wire rv32_dsp_kmsda      = rv32_dsp_op & rv32_func7_0100110 & rv32_func3_001;
  wire rv32_dsp_kmsxda     = rv32_dsp_op & rv32_func7_0100111 & rv32_func3_001;
  wire rv32_dsp_smaqa      = rv32_dsp_op & rv32_func7_1100100 & rv32_func3_000;
  wire rv32_dsp_umaqa      = rv32_dsp_op & rv32_func7_1100110 & rv32_func3_000;
  wire rv32_dsp_smaqasu    = rv32_dsp_op & rv32_func7_1100101 & rv32_func3_000;
  wire rv32_dsp_khmbb      = rv32_dsp_op & rv32_func7_0000110 & rv32_func3_001;
  wire rv32_dsp_khmbt      = rv32_dsp_op & rv32_func7_0001110 & rv32_func3_001;
  wire rv32_dsp_khmtt      = rv32_dsp_op & rv32_func7_0010110 & rv32_func3_001;
  wire rv32_dsp_kdmbb      = rv32_dsp_op & rv32_func7_0000101 & rv32_func3_001;
  wire rv32_dsp_kdmbt      = rv32_dsp_op & rv32_func7_0001101 & rv32_func3_001;
  wire rv32_dsp_kdmtt      = rv32_dsp_op & rv32_func7_0010101 & rv32_func3_001;
  wire rv32_dsp_kdmabb     = rv32_dsp_op & rv32_func7_1101001 & rv32_func3_001;
  wire rv32_dsp_kdmabt     = rv32_dsp_op & rv32_func7_1110001 & rv32_func3_001;
  wire rv32_dsp_kdmatt     = rv32_dsp_op & rv32_func7_1111001 & rv32_func3_001;
  wire rv32_dsp_maddr32    = rv32_dsp_op & rv32_func7_1100010 & rv32_func3_001;
  wire rv32_dsp_mtlei      = rv32_dsp_op & rv32_func7_1111101 & rv32_func3_000;
  wire rv32_dsp_maxw       = rv32_dsp_op & rv32_func7_1111001 & rv32_func3_000;
  wire rv32_dsp_minw       = rv32_dsp_op & rv32_func7_1111000 & rv32_func3_000;
  wire rv32_dsp_msubr32    = rv32_dsp_op & rv32_func7_1100011 & rv32_func3_001;
  wire rv32_dsp_mulr64     = rv32_dsp_op & rv32_func7_1111000 & rv32_func3_001;
  wire rv32_dsp_mulsr64    = rv32_dsp_op & rv32_func7_1110000 & rv32_func3_001;
  wire rv32_dsp_mtlbi      = rv32_dsp_op & rv32_func7_1111100 & rv32_func3_000;
  wire rv32_dsp_smal       = rv32_dsp_op & rv32_func7_0101111 & rv32_func3_001;
  wire rv32_dsp_smalbb     = rv32_dsp_op & rv32_func7_1000100 & rv32_func3_001;
  wire rv32_dsp_smalbt     = rv32_dsp_op & rv32_func7_1001100 & rv32_func3_001;
  wire rv32_dsp_smaltt     = rv32_dsp_op & rv32_func7_1010100 & rv32_func3_001;
  wire rv32_dsp_smalda     = rv32_dsp_op & rv32_func7_1000110 & rv32_func3_001;
  wire rv32_dsp_smalxda    = rv32_dsp_op & rv32_func7_1001110 & rv32_func3_001;
  wire rv32_dsp_smalds     = rv32_dsp_op & rv32_func7_1000101 & rv32_func3_001;
  wire rv32_dsp_smaldrs    = rv32_dsp_op & rv32_func7_1001101 & rv32_func3_001;
  wire rv32_dsp_smalxds    = rv32_dsp_op & rv32_func7_1010101 & rv32_func3_001;
  wire rv32_dsp_smar64     = rv32_dsp_op & rv32_func7_1000010 & rv32_func3_001;
  wire rv32_dsp_smsr64     = rv32_dsp_op & rv32_func7_1000011 & rv32_func3_001;
  wire rv32_dsp_ukmsr64    = rv32_dsp_op & rv32_func7_1011011 & rv32_func3_001;
  wire rv32_dsp_ukmar64    = rv32_dsp_op & rv32_func7_1011010 & rv32_func3_001;
  wire rv32_dsp_kmsr64     = rv32_dsp_op & rv32_func7_1001011 & rv32_func3_001;
  wire rv32_dsp_kmar64     = rv32_dsp_op & rv32_func7_1001010 & rv32_func3_001;
  wire rv32_dsp_umar64     = rv32_dsp_op & rv32_func7_1010010 & rv32_func3_001;
  wire rv32_dsp_umsr64     = rv32_dsp_op & rv32_func7_1010011 & rv32_func3_001;
  wire rv32_dsp_pbsad      = rv32_dsp_op & rv32_func7_1111110 & rv32_func3_000;
  wire rv32_dsp_pbsada     = rv32_dsp_op & rv32_func7_1111111 & rv32_func3_000;
 

 wire dsp_mul_plex_longp_op = 
                             rv32_dsp_smal
                           | rv32_dsp_smmulu
                           | rv32_dsp_kwmmulu
                           | rv32_dsp_kmmwt2u
                           | rv32_dsp_kmmwb2u
                           | rv32_dsp_smmwtu
                           | rv32_dsp_smmwbu
                           | rv32_dsp_kmda
                           | rv32_dsp_kmxda
                           | rv32_dsp_smds
                           | rv32_dsp_smdrs
                           | rv32_dsp_smxds
                           ;


  wire dsp_mac_32_op =
                      rv32_dsp_kmabb
                    | rv32_dsp_kmabt
                    | rv32_dsp_kmatt
                    | rv32_dsp_kdmabb
                    | rv32_dsp_kdmabt
                    | rv32_dsp_kdmatt
                    | rv32_dsp_maddr32
                    | rv32_dsp_msubr32
                    | rv32_dsp_kmmawbu
                    | rv32_dsp_kmmawt
                    | rv32_dsp_kmmawtu
                    | rv32_dsp_kmmawb2
                    | rv32_dsp_kmmawb2u
                    | rv32_dsp_kmmawt2
                    | rv32_dsp_kmmawt2u
                    | rv32_dsp_kmmawb
                    | rv32_dsp_kmmac
                    | rv32_dsp_kmmacu
                    | rv32_dsp_kmmsb
                    | rv32_dsp_kmmsbu
                    | rv32_dsp_smaqa
                    | rv32_dsp_umaqa
                    | rv32_dsp_smaqasu
                    | rv32_dsp_kmada
                    | rv32_dsp_kmaxda
                    | rv32_dsp_kmads
                    | rv32_dsp_kmadrs
                    | rv32_dsp_kmaxds
                    | rv32_dsp_kmsda
                    | rv32_dsp_kmsxda
                    | rv32_dsp_pbsada
                    ;
    
 wire dsp_mac_64_op = 
                     | rv32_dsp_smalbb
                     | rv32_dsp_smalbt
                     | rv32_dsp_smaltt
                     | rv32_dsp_smar64
                     | rv32_dsp_smsr64
                     | rv32_dsp_kmsr64
                     | rv32_dsp_kmar64
                     | rv32_dsp_ukmsr64
                     | rv32_dsp_ukmar64
                     | rv32_dsp_umar64
                     | rv32_dsp_umsr64
                     | rv32_dsp_smslda
                     | rv32_dsp_smslxda
                     | rv32_dsp_smalda
                     | rv32_dsp_smalxda
                     | rv32_dsp_smalds
                     | rv32_dsp_smaldrs
                     | rv32_dsp_smalxds
                     ;

  wire dsp_mac_op =  dsp_mac_64_op | dsp_mac_32_op;    
  wire dsp_longp_op = dsp_mac_op | dsp_mul_plex_longp_op | rv32_dsp_pbsad;
  
  wire dsp_1cyc_mul_plex_alumul  = rv32_dsp_smmwb
                              | rv32_dsp_smmwt
                              | rv32_dsp_kmmwb2
                              | rv32_dsp_kmmwt2
                              | rv32_dsp_kwmmul
                              | rv32_dsp_smmul
                              | rv32_dsp_mulr64
                              | rv32_dsp_mulsr64
                              | rv32_dsp_smbb16
                              | rv32_dsp_smbt16
                              | rv32_dsp_smtt16
                              | rv32_dsp_khmbb
                              | rv32_dsp_khmbt
                              | rv32_dsp_khmtt
                              | rv32_dsp_kdmbb
                              | rv32_dsp_kdmbt
                              | rv32_dsp_kdmtt
                              ;
    
  wire dsp_1cycle_simd_mul_op = 
                                 rv32_dsp_khm8
                               | rv32_dsp_khmx8
                               | rv32_dsp_smul8
                               | rv32_dsp_smulx8
                               | rv32_dsp_umul8
                               | rv32_dsp_umulx8
                               | rv32_dsp_khm16
                               | rv32_dsp_khmx16
                               | rv32_dsp_smul16
                               | rv32_dsp_smulx16
                               | rv32_dsp_umul16
                               | rv32_dsp_umulx16
                               ;
  
  wire  dsp_mul_op = dsp_1cycle_simd_mul_op | dsp_1cyc_mul_plex_alumul;
  wire  dsp_addsub_op   = dsp_op_add8     
                         | dsp_op_radd8    
                         | dsp_op_uradd8   
                         | dsp_op_kadd8    
                         | dsp_op_ukadd8   
                         | dsp_op_sub8     
                         | dsp_op_rsub8    
                         | dsp_op_ursub8   
                         | dsp_op_ksub8    
                         | dsp_op_uksub8   
                         | dsp_op_cmpeq8   
                         | dsp_op_scmplt8  
                         | dsp_op_scmple8  
                         | dsp_op_ucmplt8  
                         | dsp_op_ucmple8  
                         | dsp_op_smax8    
                         | dsp_op_smin8    
                         | dsp_op_umax8    
                         | dsp_op_umin8    
                         | dsp_op_kabs8    
                         | dsp_op_add16    
                         | dsp_op_radd16   
                         | dsp_op_uradd16  
                         | dsp_op_kadd16   
                         | dsp_op_ukadd16  
                         | dsp_op_sub16    
                         | dsp_op_rsub16   
                         | dsp_op_ursub16  
                         | dsp_op_ksub16   
                         | dsp_op_uksub16  
                         | dsp_op_cras16    
                         | dsp_op_rcras16   
                         | dsp_op_urcras16  
                         | dsp_op_kcras16   
                         | dsp_op_ukcras16 
                         | dsp_op_crsa16   
                         | dsp_op_rcrsa16  
                         | dsp_op_urcrsa16 
                         | dsp_op_kcrsa16  
                         | dsp_op_ukcrsa16 
                         | dsp_op_stas16   
                         | dsp_op_rstas16  
                         | dsp_op_urstas16 
                         | dsp_op_kstas16  
                         | dsp_op_ukstas16 
                         | dsp_op_stsa16   
                         | dsp_op_rstsa16  
                         | dsp_op_urstsa16 
                         | dsp_op_kstsa16  
                         | dsp_op_ukstsa16 
                         | dsp_op_cmpeq16  
                         | dsp_op_scmplt16 
                         | dsp_op_scmple16 
                         | dsp_op_ucmplt16 
                         | dsp_op_ucmple16 
                         | dsp_op_smax16   
                         | dsp_op_smin16   
                         | dsp_op_umax16   
                         | dsp_op_umin16   
                         | dsp_op_kabs16   
                         | dsp_op_kaddh    
                         | dsp_op_ukaddh   
                         | dsp_op_ksubh    
                         | dsp_op_uksubh   
                         | dsp_op_kaddw    
                         | dsp_op_ukaddw   
                         | dsp_op_raddw    
                         | dsp_op_uraddw   
                         | dsp_op_ksubw    
                         | dsp_op_uksubw   
                         | dsp_op_rsubw    
                         | dsp_op_ursubw   
                         | dsp_op_maxw     
                         | dsp_op_minw     
                         | dsp_op_kabsw    
                         | dsp_op_add64    
                         | dsp_op_radd64   
                         | dsp_op_uradd64  
                         | dsp_op_kadd64   
                         | dsp_op_ukadd64  
                         | dsp_op_sub64    
                         | dsp_op_rsub64   
                         | dsp_op_ursub64  
                         | dsp_op_ksub64   
                         | dsp_op_uksub64  
                         | dsp_op_ave  
                         ;
 
  wire rs1_is_64 = rv32_dsp_smal
                 // 64bit opcode in addsub.
                 | dsp_op_add64   
                 | dsp_op_radd64  
                 | dsp_op_uradd64 
                 | dsp_op_kadd64  
                 | dsp_op_ukadd64 
                 | dsp_op_sub64   
                 | dsp_op_rsub64  
                 | dsp_op_ursub64 
                 | dsp_op_ksub64  
                 | dsp_op_uksub64    
                 | dsp_op_wext    
                 | dsp_op_wexti 
                 ;
  wire rs2_is_64 = dsp_op_add64   
                 | dsp_op_radd64  
                 | dsp_op_uradd64 
                 | dsp_op_kadd64  
                 | dsp_op_ukadd64 
                 | dsp_op_sub64   
                 | dsp_op_rsub64  
                 | dsp_op_ursub64 
                 | dsp_op_ksub64  
                 | dsp_op_uksub64
                    ;   

  wire dsp_64_mac_op = 
                          rv32_dsp_smalbb
                        | rv32_dsp_smalbt
                        | rv32_dsp_smaltt
                        | rv32_dsp_smslda
                        | rv32_dsp_smslxda
                        | rv32_dsp_smalda
                        | rv32_dsp_smalxda
                        | rv32_dsp_smalds
                        | rv32_dsp_smaldrs
                        | rv32_dsp_smalxds
                        | rv32_dsp_smar64
                        | rv32_dsp_smsr64
                        | rv32_dsp_ukmsr64
                        | rv32_dsp_ukmar64
                        | rv32_dsp_kmsr64
                        | rv32_dsp_kmar64
                        | rv32_dsp_umar64
                        | rv32_dsp_umsr64
                        ;

  wire dsp_longp_mul_plex_alumul = rv32_dsp_smalbb
                               | rv32_dsp_smalbt
                               | rv32_dsp_smaltt
                               | rv32_dsp_kmabb
                               | rv32_dsp_kmabt
                               | rv32_dsp_kmatt
                               | rv32_dsp_kdmabb
                               | rv32_dsp_kdmabt
                               | rv32_dsp_kdmatt
                               | rv32_dsp_smal
                               | rv32_dsp_smmulu
                               | rv32_dsp_kwmmulu
                               | rv32_dsp_kmmwt2u
                               | rv32_dsp_kmmwb2u
                               | rv32_dsp_smmwtu
                               | rv32_dsp_smmwbu
                               | rv32_dsp_maddr32
                               | rv32_dsp_msubr32
                               | rv32_dsp_kmmawbu
                               | rv32_dsp_kmmawt
                               | rv32_dsp_kmmawtu
                               | rv32_dsp_kmmawb2
                               | rv32_dsp_kmmawb2u
                               | rv32_dsp_kmmawt2
                               | rv32_dsp_kmmawt2u
                               | rv32_dsp_kmmawb
                               | rv32_dsp_kmmac
                               | rv32_dsp_kmmacu
                               | rv32_dsp_kmmsb
                               | rv32_dsp_kmmsbu
                               | rv32_dsp_smar64
                               | rv32_dsp_smsr64
                               | rv32_dsp_kmsr64
                               | rv32_dsp_kmar64
                               | rv32_dsp_ukmsr64
                               | rv32_dsp_ukmar64
                               | rv32_dsp_umar64
                               | rv32_dsp_umsr64
                               ;

  wire rd_w_is_64 = dsp_64_mac_op 
                  | rv32_dsp_smul8 | rv32_dsp_smulx8 | rv32_dsp_smul16 | rv32_dsp_smulx16 |rv32_dsp_umul16 |rv32_dsp_umulx16  
                  | rv32_dsp_mulr64 | rv32_dsp_mulsr64 | rv32_dsp_smal | rv32_dsp_umul8 | rv32_dsp_umulx8 
                  // 64bit opcode in addsub.
                  | dsp_op_add64   | dsp_op_radd64   | dsp_op_uradd64  | dsp_op_kadd64  | dsp_op_ukadd64 | dsp_op_sub64   
                  | dsp_op_rsub64  | dsp_op_ursub64  | dsp_op_ksub64   | dsp_op_uksub64
      ;   

  wire rd_r_is_64 = dsp_64_mac_op;
  wire rv32_need_read_rd = dsp_mac_op | dsp_op_insb;

  

  wire dsp_op = rv32_dsp_op & (dsp_addsub_op | dsp_mul_op | dsp_longp_op | dsp_misc_op | dsp_shift_op);
  assign dec_dsp = dsp_op;


  wire dsp_addsub_plex_longp_op =                           
                         | rv32_dsp_pbsad    
                         | rv32_dsp_pbsada   
                         ;
  wire dsp_mul_plex_alumul_op =  dsp_1cyc_mul_plex_alumul | dsp_longp_mul_plex_alumul;

  assign  dsp_info_bus[`E203_DECINFO_DSP_SMUL16]    = rv32_dsp_smul16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMULX16]   = rv32_dsp_smulx16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMUL16]    = rv32_dsp_umul16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMULX16]   = rv32_dsp_umulx16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHM16]     = rv32_dsp_khm16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHMX16]    = rv32_dsp_khmx16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMUL8]     = rv32_dsp_smul8;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMULX8]    = rv32_dsp_smulx8;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMUL8]     = rv32_dsp_umul8;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMULX8]    = rv32_dsp_umulx8;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHM8]      = rv32_dsp_khm8;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHMX8]     = rv32_dsp_khmx8;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMMUL]     = rv32_dsp_smmul;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMMULU]    = rv32_dsp_smmulu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAC]     = rv32_dsp_kmmac;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMACU]    = rv32_dsp_kmmacu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMSB]     = rv32_dsp_kmmsb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMSBU]    = rv32_dsp_kmmsbu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KWMMUL]    = rv32_dsp_kwmmul;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KWMMULU]   = rv32_dsp_kwmmulu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMMWB]     = rv32_dsp_smmwb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMMWBU]    = rv32_dsp_smmwbu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMMWT]     = rv32_dsp_smmwt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMMWTU]    = rv32_dsp_smmwtu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWB]    = rv32_dsp_kmmawb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWBU]   = rv32_dsp_kmmawbu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWT]    = rv32_dsp_kmmawt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWTU]   = rv32_dsp_kmmawtu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMWB2]    = rv32_dsp_kmmwb2;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMWB2U]   = rv32_dsp_kmmwb2u;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMWT2]    = rv32_dsp_kmmwt2;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMWT2U]   = rv32_dsp_kmmwt2u;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWB2]   = rv32_dsp_kmmawb2;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWB2U]  = rv32_dsp_kmmawb2u;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWT2]   = rv32_dsp_kmmawt2;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMMAWT2U]  = rv32_dsp_kmmawt2u;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMSLDA]    = rv32_dsp_smslda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMSLXDA]   = rv32_dsp_smslxda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMBB16]    = rv32_dsp_smbb16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMBT16]    = rv32_dsp_smbt16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMTT16]    = rv32_dsp_smtt16;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMDA]      = rv32_dsp_kmda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMXDA]     = rv32_dsp_kmxda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMDS]      = rv32_dsp_smds;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMDRS]     = rv32_dsp_smdrs;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMXDS]     = rv32_dsp_smxds;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMABB]     = rv32_dsp_kmabb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMABT]     = rv32_dsp_kmabt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMATT]     = rv32_dsp_kmatt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMADA]     = rv32_dsp_kmada;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMAXDA]    = rv32_dsp_kmaxda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMADS]     = rv32_dsp_kmads;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMADRS]    = rv32_dsp_kmadrs;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMAXDS]    = rv32_dsp_kmaxds;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMSDA]     = rv32_dsp_kmsda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMSXDA]    = rv32_dsp_kmsxda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMAQA]     = rv32_dsp_smaqa;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMAQA]     = rv32_dsp_umaqa;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMAQASU]   = rv32_dsp_smaqasu;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHMBB]     = rv32_dsp_khmbb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHMBT]     = rv32_dsp_khmbt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KHMTT]     = rv32_dsp_khmtt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KDMBB]     = rv32_dsp_kdmbb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KDMBT]     = rv32_dsp_kdmbt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KDMTT]     = rv32_dsp_kdmtt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KDMABB]    = rv32_dsp_kdmabb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KDMABT]    = rv32_dsp_kdmabt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KDMATT]    = rv32_dsp_kdmatt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MADDR32]   = rv32_dsp_maddr32;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MSUBR32]   = rv32_dsp_msubr32;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MULR64]    = rv32_dsp_mulr64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MULSR64]   = rv32_dsp_mulsr64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMAL]      = rv32_dsp_smal;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALBB]    = rv32_dsp_smalbb;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALBT]    = rv32_dsp_smalbt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALTT]    = rv32_dsp_smaltt;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALDA]    = rv32_dsp_smalda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALXDA]   = rv32_dsp_smalxda;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALDS]    = rv32_dsp_smalds;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALDRS]   = rv32_dsp_smaldrs;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMALXDS]   = rv32_dsp_smalxds;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMAR64]    = rv32_dsp_smar64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_SMSR64]    = rv32_dsp_smsr64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMSR64]    = rv32_dsp_kmsr64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_KMAR64]    = rv32_dsp_kmar64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UKMSR64]   = rv32_dsp_ukmsr64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UKMAR64]   = rv32_dsp_ukmar64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMAR64]    = rv32_dsp_umar64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_UMSR64]    = rv32_dsp_umsr64;
  assign  dsp_info_bus[`E203_DECINFO_DSP_PBSAD]     = rv32_dsp_pbsad    ;
  assign  dsp_info_bus[`E203_DECINFO_DSP_PBSADA]    = rv32_dsp_pbsada   ;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MULOP]             = dsp_mul_op;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MUL_PLEX_LONGPOP]    = dsp_mul_plex_longp_op;
  assign  dsp_info_bus[`E203_DECINFO_DSP_ADDSUB_PLEX_LONGPOP] = dsp_addsub_plex_longp_op;
  assign  dsp_info_bus[`E203_DECINFO_DSP_MACOP]             = dsp_mac_op;
  assign  dsp_info_bus[`E203_DECINFO_DSP_LONGPOP]           = dsp_longp_op;
  assign  dsp_info_bus[`E203_DECINFO_DSP_PAIR_RD_MACOP]     = dsp_mac_64_op; 
  assign  dsp_info_bus[`E203_DECINFO_DSP_MUL_PLEX_ALUMULOP] = dsp_mul_plex_alumul_op;

  assign dsp_info_bus[`E203_DECINFO_DSP_ADD8     ] = dsp_op_add8     ;
  assign dsp_info_bus[`E203_DECINFO_DSP_RADD8    ] = dsp_op_radd8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_URADD8   ] = dsp_op_uradd8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KADD8    ] = dsp_op_kadd8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UKADD8   ] = dsp_op_ukadd8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUB8     ] = dsp_op_sub8     ;
  assign dsp_info_bus[`E203_DECINFO_DSP_RSUB8    ] = dsp_op_rsub8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_URSUB8   ] = dsp_op_ursub8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSUB8    ] = dsp_op_ksub8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSUB8   ] = dsp_op_uksub8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_CMPEQ8   ] = dsp_op_cmpeq8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SCMPLT8  ] = dsp_op_scmplt8  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SCMPLE8  ] = dsp_op_scmple8  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UCMPLT8  ] = dsp_op_ucmplt8  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UCMPLE8  ] = dsp_op_ucmple8  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SMAX8    ] = dsp_op_smax8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SMIN8    ] = dsp_op_smin8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UMAX8    ] = dsp_op_umax8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UMIN8    ] = dsp_op_umin8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KABS8    ] = dsp_op_kabs8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_ADD16    ] = dsp_op_add16    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_RADD16   ] = dsp_op_radd16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_URADD16  ] = dsp_op_uradd16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KADD16   ] = dsp_op_kadd16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UKADD16  ] = dsp_op_ukadd16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUB16    ] = dsp_op_sub16    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_RSUB16   ] = dsp_op_rsub16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_URSUB16  ] = dsp_op_ursub16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSUB16   ] = dsp_op_ksub16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSUB16  ] = dsp_op_uksub16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_CRAS16   ] = dsp_op_cras16   ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_RCRAS16  ] = dsp_op_rcras16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_URCRAS16 ] = dsp_op_urcras16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_KCRAS16  ] = dsp_op_kcras16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_UKCRAS16 ] = dsp_op_ukcras16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_CRSA16   ] = dsp_op_crsa16   ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_RCRSA16  ] = dsp_op_rcrsa16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_URCRSA16 ] = dsp_op_urcrsa16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_KCRSA16  ] = dsp_op_kcrsa16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_UKCRSA16 ] = dsp_op_ukcrsa16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_STAS16   ] = dsp_op_stas16   ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_RSTAS16  ] = dsp_op_rstas16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_URSTAS16 ] = dsp_op_urstas16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_KSTAS16  ] = dsp_op_kstas16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSTAS16 ] = dsp_op_ukstas16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_STSA16   ] = dsp_op_stsa16   ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_RSTSA16  ] = dsp_op_rstsa16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_URSTSA16 ] = dsp_op_urstsa16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_KSTSA16  ] = dsp_op_kstsa16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSTSA16 ] = dsp_op_ukstsa16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_CMPEQ16  ] = dsp_op_cmpeq16  ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_SCMPLT16 ] = dsp_op_scmplt16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_SCMPLE16 ] = dsp_op_scmple16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_UCMPLT16 ] = dsp_op_ucmplt16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_UCMPLE16 ] = dsp_op_ucmple16 ;    
  assign dsp_info_bus[`E203_DECINFO_DSP_SMAX16   ] = dsp_op_smax16   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_SMIN16   ] = dsp_op_smin16   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_UMAX16   ] = dsp_op_umax16   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_UMIN16   ] = dsp_op_umin16   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_KABS16   ] = dsp_op_kabs16   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_KADDH    ] = dsp_op_kaddh    ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_UKADDH   ] = dsp_op_ukaddh   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_KSUBH    ] = dsp_op_ksubh    ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSUBH   ] = dsp_op_uksubh   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_KADDW    ] = dsp_op_kaddw    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_UKADDW   ] = dsp_op_ukaddw   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_RADDW    ] = dsp_op_raddw    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_URADDW   ] = dsp_op_uraddw   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSUBW    ] = dsp_op_ksubw    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSUBW   ] = dsp_op_uksubw   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_RSUBW    ] = dsp_op_rsubw    ;  
  assign dsp_info_bus[`E203_DECINFO_DSP_URSUBW   ] = dsp_op_ursubw   ;  
  assign dsp_info_bus[`E203_DECINFO_DSP_MAXW     ] = dsp_op_maxw     ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_MINW     ] = dsp_op_minw     ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_KABSW    ] = dsp_op_kabsw    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_ADD64    ] = dsp_op_add64    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_RADD64   ] = dsp_op_radd64   ;   
  assign dsp_info_bus[`E203_DECINFO_DSP_URADD64  ] = dsp_op_uradd64  ;  
  assign dsp_info_bus[`E203_DECINFO_DSP_KADD64   ] = dsp_op_kadd64   ;  
  assign dsp_info_bus[`E203_DECINFO_DSP_UKADD64  ] = dsp_op_ukadd64  ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_SUB64    ] = dsp_op_sub64    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_RSUB64   ] = dsp_op_rsub64   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_URSUB64  ] = dsp_op_ursub64  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSUB64   ] = dsp_op_ksub64   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UKSUB64  ] = dsp_op_uksub64  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_AVE      ] = dsp_op_ave      ;

  assign dsp_info_bus[`E203_DECINFO_DSP_GPR_ADDSUB      ] = dsp_addsub_op ;

  assign dsp_info_bus[`E203_DECINFO_DSP_IMM      ] = rv32_instr[24:20];

  
  assign dsp_info_bus[`E203_DECINFO_DSP_SRA8     ] = dsp_op_sra8    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_SRAI8    ] = dsp_op_srai8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRA8U    ] = dsp_op_sra8u   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRA8IU   ] = dsp_op_srai8u  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRL8     ] = dsp_op_srl8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRLI8    ] = dsp_op_srli8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRL8U    ] = dsp_op_srl8u   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRLI8U   ] = dsp_op_srli8u  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SLL8     ] = dsp_op_sll8    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SLLI8    ] = dsp_op_slli8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLL8    ] = dsp_op_ksll8   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLLI8   ] = dsp_op_kslli8  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLRA8   ] = dsp_op_kslra8  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLRA8U  ] = dsp_op_kslra8u ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRA16    ] = dsp_op_sra16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRAI16   ] = dsp_op_srai16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRA16U   ] = dsp_op_sra16u  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRA16IU  ] = dsp_op_srai16u ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRL16    ] = dsp_op_srl16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRLI16   ] = dsp_op_srli16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRL16U   ] = dsp_op_srl16u  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRLI16U  ] = dsp_op_srli16u ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRLL16   ] = dsp_op_sll16   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRLLI16  ] = dsp_op_slli16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLL16   ] = dsp_op_ksll16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLLI16  ] = dsp_op_kslli16 ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLRA16  ] = dsp_op_kslra16 ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLRA16U ] = dsp_op_kslra16u;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRAU     ] = dsp_op_srau    ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SRAIU    ] = dsp_op_sraiu   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLRAW   ] = dsp_op_kslraw  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLRAWU  ] = dsp_op_kslrawu ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLLW    ] = dsp_op_ksllw   ;
  assign dsp_info_bus[`E203_DECINFO_DSP_KSLLIW   ] = dsp_op_kslliw  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SHIFT_OP ] = dsp_shift_op   ;

  assign dsp_info_bus[`E203_DECINFO_DSP_SCLIP8   ] = dsp_op_sclip8   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_UCLIP8   ] = dsp_op_uclip8   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_SCLIP16  ] = dsp_op_sclip16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UCLIP16  ] = dsp_op_uclip16  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SCLIP32  ] = dsp_op_sclip32  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_UCLIP32  ] = dsp_op_uclip32  ;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUNPKD810] = dsp_op_sunpkd810;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUNPKD820] = dsp_op_sunpkd820;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUNPKD830] = dsp_op_sunpkd830;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUNPKD831] = dsp_op_sunpkd831;
  assign dsp_info_bus[`E203_DECINFO_DSP_SUNPKD832] = dsp_op_sunpkd832;
  assign dsp_info_bus[`E203_DECINFO_DSP_ZUNPKD810] = dsp_op_zunpkd810;
  assign dsp_info_bus[`E203_DECINFO_DSP_ZUNPKD820] = dsp_op_zunpkd820;
  assign dsp_info_bus[`E203_DECINFO_DSP_ZUNPKD830] = dsp_op_zunpkd830;
  assign dsp_info_bus[`E203_DECINFO_DSP_ZUNPKD831] = dsp_op_zunpkd831;
  assign dsp_info_bus[`E203_DECINFO_DSP_ZUNPKD832] = dsp_op_zunpkd832;
  assign dsp_info_bus[`E203_DECINFO_DSP_PKBB16   ] = dsp_op_packbb16 ;
  assign dsp_info_bus[`E203_DECINFO_DSP_PKBT16   ] = dsp_op_packbt16 ;
  assign dsp_info_bus[`E203_DECINFO_DSP_PKTB16   ] = dsp_op_packtb16 ;
  assign dsp_info_bus[`E203_DECINFO_DSP_PKTT16   ] = dsp_op_packtt16 ;
  assign dsp_info_bus[`E203_DECINFO_DSP_CLRS8    ] = dsp_op_clrs8    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CRZ8     ] = dsp_op_clz8     ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLO8     ] = dsp_op_clo8     ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLRS16   ] = dsp_op_clrs16   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLZ16    ] = dsp_op_clz16    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLO16    ] = dsp_op_clo16    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLRS32   ] = dsp_op_clrs32   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLZ32    ] = dsp_op_clz32    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_CLO32    ] = dsp_op_clo32    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_BITREV   ] = dsp_op_bitrev   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_BITREVI  ] = dsp_op_bitrevi  ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_WEXT     ] = dsp_op_wext     ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_WEXTI    ] = dsp_op_wexti    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_BPICK    ] = dsp_op_bpick    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_INSB     ] = dsp_op_insb     ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_SWAP8    ] = dsp_op_swap8    ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_SWAP16   ] = dsp_op_swap16   ; 
  assign dsp_info_bus[`E203_DECINFO_DSP_MISC_OP  ] = dsp_misc_op     ; 

  // ===========================================================================
    // The Branch and system group of instructions will be handled by BJP

  assign dec_jal     = rv32_jal    | rv16_jal  | rv16_j;
  assign dec_jalr    = rv32_jalr   | rv16_jalr | rv16_jr;
  assign dec_bxx     = rv32_branch | rv16_beqz | rv16_bnez;
  assign dec_bjp     = dec_jal | dec_jalr | dec_bxx;


  wire rv32_fence  ;
  wire rv32_fence_i;
  wire rv32_fence_fencei;
  wire bjp_op = dec_bjp | rv32_mret | (rv32_dret & (~rv32_dret_ilgl)) | rv32_fence_fencei;

  wire [`E203_DECINFO_BJP_WIDTH-1:0] bjp_info_bus;
  assign bjp_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_BJP;
  assign bjp_info_bus[`E203_DECINFO_RV32   ]    = rv32;
  assign bjp_info_bus[`E203_DECINFO_BJP_JUMP ]  = dec_jal | dec_jalr;
  assign bjp_info_bus[`E203_DECINFO_BJP_BPRDT]  = i_prdt_taken;
  assign bjp_info_bus[`E203_DECINFO_BJP_BEQ  ]  = rv32_beq | rv16_beqz;
  assign bjp_info_bus[`E203_DECINFO_BJP_BNE  ]  = rv32_bne | rv16_bnez;
  assign bjp_info_bus[`E203_DECINFO_BJP_BLT  ]  = rv32_blt; 
  assign bjp_info_bus[`E203_DECINFO_BJP_BGT  ]  = rv32_bgt ;
  assign bjp_info_bus[`E203_DECINFO_BJP_BLTU ]  = rv32_bltu;
  assign bjp_info_bus[`E203_DECINFO_BJP_BGTU ]  = rv32_bgtu;
  assign bjp_info_bus[`E203_DECINFO_BJP_BXX  ]  = dec_bxx;
  assign bjp_info_bus[`E203_DECINFO_BJP_MRET ]  = rv32_mret;
  assign bjp_info_bus[`E203_DECINFO_BJP_DRET ]  = rv32_dret;
  assign bjp_info_bus[`E203_DECINFO_BJP_FENCE ]  = rv32_fence;
  assign bjp_info_bus[`E203_DECINFO_BJP_FENCEI]  = rv32_fence_i;


  // ===========================================================================
  // ALU Instructions
  wire rv32_addi     = rv32_op_imm & rv32_func3_000;
  wire rv32_slti     = rv32_op_imm & rv32_func3_010;
  wire rv32_sltiu    = rv32_op_imm & rv32_func3_011;
  wire rv32_xori     = rv32_op_imm & rv32_func3_100;
  wire rv32_ori      = rv32_op_imm & rv32_func3_110;
  wire rv32_andi     = rv32_op_imm & rv32_func3_111;

  wire rv32_slli     = rv32_op_imm & rv32_func3_001 & (rv32_instr[31:26] == 6'b000000);
  wire rv32_srli     = rv32_op_imm & rv32_func3_101 & (rv32_instr[31:26] == 6'b000000);
  wire rv32_srai     = rv32_op_imm & rv32_func3_101 & (rv32_instr[31:26] == 6'b010000);

  wire rv32_sxxi_shamt_legl = (rv32_instr[25] == 1'b0); //shamt[5] must be zero for RV32I
  wire rv32_sxxi_shamt_ilgl =  (rv32_slli | rv32_srli | rv32_srai) & (~rv32_sxxi_shamt_legl);

  wire rv32_add      = rv32_op     & rv32_func3_000 & rv32_func7_0000000;
  wire rv32_sub      = rv32_op     & rv32_func3_000 & rv32_func7_0100000;
  wire rv32_sll      = rv32_op     & rv32_func3_001 & rv32_func7_0000000;
  wire rv32_slt      = rv32_op     & rv32_func3_010 & rv32_func7_0000000;
  wire rv32_sltu     = rv32_op     & rv32_func3_011 & rv32_func7_0000000;
  wire rv32_xor      = rv32_op     & rv32_func3_100 & rv32_func7_0000000;
  wire rv32_srl      = rv32_op     & rv32_func3_101 & rv32_func7_0000000;
  wire rv32_sra      = rv32_op     & rv32_func3_101 & rv32_func7_0100000;
  wire rv32_or       = rv32_op     & rv32_func3_110 & rv32_func7_0000000;
  wire rv32_and      = rv32_op     & rv32_func3_111 & rv32_func7_0000000;

  wire rv32_nop      = rv32_addi & rv32_rs1_x0 & rv32_rd_x0 & (~(|rv32_instr[31:20]));
  // The ALU group of instructions will be handled by 1cycle ALU-datapath
  wire ecall_ebreak = rv32_ecall | rv32_ebreak | rv16_ebreak;

  wire alu_op = (~rv32_sxxi_shamt_ilgl) & (~rv16_sxxi_shamt_ilgl) 
              & (~rv16_li_lui_ilgl) & (~rv16_addi4spn_ilgl) & (~rv16_addi16sp_ilgl) & 
              ( rv32_op_imm 
              | rv32_op & (~rv32_func7_0000001) // Exclude the MULDIV
              | rv32_auipc
              | rv32_lui
              | rv16_addi4spn
              | rv16_addi         
              | rv16_lui_addi16sp 
              | rv16_li | rv16_mv
              | rv16_slli         
              | rv16_miscalu  
              | rv16_add
              | rv16_nop | rv32_nop
              | rv32_wfi // We just put WFI into ALU and do nothing in ALU
              | ecall_ebreak)
              ;
  wire need_imm;
  wire [`E203_DECINFO_ALU_WIDTH-1:0] alu_info_bus;
  assign alu_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_ALU;
  assign alu_info_bus[`E203_DECINFO_RV32   ]    = rv32;
  assign alu_info_bus[`E203_DECINFO_ALU_ADD]    = rv32_add  | rv32_addi | rv32_auipc |
                                                  rv16_addi4spn | rv16_addi | rv16_addi16sp | rv16_add |
                            // We also decode LI and MV as the add instruction, becuase
                            //   they all add x0 with a RS2 or Immeidate, and then write into RD
                                                  rv16_li | rv16_mv;
  assign alu_info_bus[`E203_DECINFO_ALU_SUB]    = rv32_sub  | rv16_sub;      
  assign alu_info_bus[`E203_DECINFO_ALU_SLT]    = rv32_slt  | rv32_slti;     
  assign alu_info_bus[`E203_DECINFO_ALU_SLTU]   = rv32_sltu | rv32_sltiu;  
  assign alu_info_bus[`E203_DECINFO_ALU_XOR]    = rv32_xor  | rv32_xori | rv16_xor;    
  assign alu_info_bus[`E203_DECINFO_ALU_SLL]    = rv32_sll  | rv32_slli | rv16_slli;   
  assign alu_info_bus[`E203_DECINFO_ALU_SRL]    = rv32_srl  | rv32_srli | rv16_srli;
  assign alu_info_bus[`E203_DECINFO_ALU_SRA]    = rv32_sra  | rv32_srai | rv16_srai;   
  assign alu_info_bus[`E203_DECINFO_ALU_OR ]    = rv32_or   | rv32_ori  | rv16_or;     
  assign alu_info_bus[`E203_DECINFO_ALU_AND]    = rv32_and  | rv32_andi | rv16_andi | rv16_and;
  assign alu_info_bus[`E203_DECINFO_ALU_LUI]    = rv32_lui  | rv16_lui; 
  assign alu_info_bus[`E203_DECINFO_ALU_OP2IMM] = need_imm; 
  assign alu_info_bus[`E203_DECINFO_ALU_OP1PC ] = rv32_auipc;
  assign alu_info_bus[`E203_DECINFO_ALU_NOP ]   = rv16_nop | rv32_nop;
  assign alu_info_bus[`E203_DECINFO_ALU_ECAL ]  = rv32_ecall; 
  assign alu_info_bus[`E203_DECINFO_ALU_EBRK ]  = rv32_ebreak | rv16_ebreak;
  assign alu_info_bus[`E203_DECINFO_ALU_WFI  ]  = rv32_wfi;


  
  wire csr_op = rv32_csr;
  wire [`E203_DECINFO_CSR_WIDTH-1:0] csr_info_bus;
  assign csr_info_bus[`E203_DECINFO_GRP    ]    = `E203_DECINFO_GRP_CSR;
  assign csr_info_bus[`E203_DECINFO_RV32   ]    = rv32;
  assign csr_info_bus[`E203_DECINFO_CSR_CSRRW ] = rv32_csrrw | rv32_csrrwi; 
  assign csr_info_bus[`E203_DECINFO_CSR_CSRRS ] = rv32_csrrs | rv32_csrrsi;
  assign csr_info_bus[`E203_DECINFO_CSR_CSRRC ] = rv32_csrrc | rv32_csrrci;
  assign csr_info_bus[`E203_DECINFO_CSR_RS1IMM] = rv32_csrrwi | rv32_csrrsi | rv32_csrrci;
  assign csr_info_bus[`E203_DECINFO_CSR_ZIMMM ] = rv32_rs1;
  assign csr_info_bus[`E203_DECINFO_CSR_RS1IS0] = rv32_rs1_x0;
  assign csr_info_bus[`E203_DECINFO_CSR_CSRIDX] = rv32_instr[31:20];

  
  // ===========================================================================
  // Memory Order Instructions
  assign rv32_fence    = rv32_miscmem & rv32_func3_000;
  assign rv32_fence_i  = rv32_miscmem & rv32_func3_001;

  assign rv32_fence_fencei  = rv32_miscmem;


  // ===========================================================================
  // MUL/DIV Instructions
  wire rv32_mul      = rv32_op     & rv32_func3_000 & rv32_func7_0000001;
  wire rv32_mulh     = rv32_op     & rv32_func3_001 & rv32_func7_0000001;
  wire rv32_mulhsu   = rv32_op     & rv32_func3_010 & rv32_func7_0000001;
  wire rv32_mulhu    = rv32_op     & rv32_func3_011 & rv32_func7_0000001;
  wire rv32_div      = rv32_op     & rv32_func3_100 & rv32_func7_0000001;
  wire rv32_divu     = rv32_op     & rv32_func3_101 & rv32_func7_0000001;
  wire rv32_rem      = rv32_op     & rv32_func3_110 & rv32_func7_0000001;
  wire rv32_remu     = rv32_op     & rv32_func3_111 & rv32_func7_0000001;
  
  // The MULDIV group of instructions will be handled by MUL-DIV-datapath
  `ifdef E203_SUPPORT_MULDIV//{
  wire muldiv_op = rv32_op & rv32_func7_0000001;
  `endif//}
  `ifndef E203_SUPPORT_MULDIV//{
  wire muldiv_op = 1'b0;
  `endif//}

  wire [`E203_DECINFO_MULDIV_WIDTH-1:0] muldiv_info_bus;
  assign muldiv_info_bus[`E203_DECINFO_GRP          ] = `E203_DECINFO_GRP_MULDIV;
  assign muldiv_info_bus[`E203_DECINFO_RV32         ] = rv32        ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MUL   ] = rv32_mul    ;   
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MULH  ] = rv32_mulh   ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MULHSU] = rv32_mulhsu ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_MULHU ] = rv32_mulhu  ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_DIV   ] = rv32_div    ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_DIVU  ] = rv32_divu   ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_REM   ] = rv32_rem    ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_REMU  ] = rv32_remu   ;
  assign muldiv_info_bus[`E203_DECINFO_MULDIV_B2B   ] = i_muldiv_b2b;

  assign dec_mulhsu = rv32_mulh | rv32_mulhsu | rv32_mulhu;
  assign dec_mul    = rv32_mul;
  assign dec_div    = rv32_div ;
  assign dec_divu   = rv32_divu;
  assign dec_rem    = rv32_rem;
  assign dec_remu   = rv32_remu;
 
  // ===========================================================================
  // Load/Store Instructions
  wire rv32_lb       = rv32_load   & rv32_func3_000;
  wire rv32_lh       = rv32_load   & rv32_func3_001;
  wire rv32_lw       = rv32_load   & rv32_func3_010;
  wire rv32_lbu      = rv32_load   & rv32_func3_100;
  wire rv32_lhu      = rv32_load   & rv32_func3_101;

  wire rv32_sb       = rv32_store  & rv32_func3_000;
  wire rv32_sh       = rv32_store  & rv32_func3_001;
  wire rv32_sw       = rv32_store  & rv32_func3_010;


  // ===========================================================================
  // Atomic Instructions
  `ifdef E203_SUPPORT_AMO//{
  wire rv32_lr_w      = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00010);
  wire rv32_sc_w      = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00011);
  wire rv32_amoswap_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00001);
  wire rv32_amoadd_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00000);
  wire rv32_amoxor_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b00100);
  wire rv32_amoand_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b01100);
  wire rv32_amoor_w   = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b01000);
  wire rv32_amomin_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b10000);
  wire rv32_amomax_w  = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b10100);
  wire rv32_amominu_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b11000);
  wire rv32_amomaxu_w = rv32_amo & rv32_func3_010 & (rv32_func7[6:2] == 5'b11100);

  `endif//E203_SUPPORT_AMO}
  `ifndef E203_SUPPORT_AMO//{
  wire rv32_lr_w      = 1'b0;
  wire rv32_sc_w      = 1'b0;
  wire rv32_amoswap_w = 1'b0;
  wire rv32_amoadd_w  = 1'b0;
  wire rv32_amoxor_w  = 1'b0;
  wire rv32_amoand_w  = 1'b0;
  wire rv32_amoor_w   = 1'b0;
  wire rv32_amomin_w  = 1'b0;
  wire rv32_amomax_w  = 1'b0;
  wire rv32_amominu_w = 1'b0;
  wire rv32_amomaxu_w = 1'b0;

  `endif//}

  wire   amoldst_op = rv32_amo | rv32_load | rv32_store | rv16_lw | rv16_sw | (rv16_lwsp & (~rv16_lwsp_ilgl)) | rv16_swsp;
    // The RV16 always is word
  wire [1:0] lsu_info_size  = rv32 ? rv32_func3[1:0] : 2'b10;
    // The RV16 always is signed
  wire       lsu_info_usign = rv32? rv32_func3[2] : 1'b0;

  wire [`E203_DECINFO_AGU_WIDTH-1:0] agu_info_bus;
  assign agu_info_bus[`E203_DECINFO_GRP    ] = `E203_DECINFO_GRP_AGU;
  assign agu_info_bus[`E203_DECINFO_RV32   ] = rv32;
  assign agu_info_bus[`E203_DECINFO_AGU_LOAD   ] = rv32_load  | rv32_lr_w | rv16_lw | rv16_lwsp;
  assign agu_info_bus[`E203_DECINFO_AGU_STORE  ] = rv32_store | rv32_sc_w | rv16_sw | rv16_swsp;
  assign agu_info_bus[`E203_DECINFO_AGU_SIZE   ] = lsu_info_size;
  assign agu_info_bus[`E203_DECINFO_AGU_USIGN  ] = lsu_info_usign;
  assign agu_info_bus[`E203_DECINFO_AGU_EXCL   ] = rv32_lr_w | rv32_sc_w;
  assign agu_info_bus[`E203_DECINFO_AGU_AMO    ] = rv32_amo & (~(rv32_lr_w | rv32_sc_w));// We seperated the EXCL out of AMO in LSU handling
  assign agu_info_bus[`E203_DECINFO_AGU_AMOSWAP] = rv32_amoswap_w;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOADD ] = rv32_amoadd_w ;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOAND ] = rv32_amoand_w ;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOOR  ] = rv32_amoor_w ;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOXOR ] = rv32_amoxor_w  ;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMAX ] = rv32_amomax_w ;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMIN ] = rv32_amomin_w ;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMAXU] = rv32_amomaxu_w;
  assign agu_info_bus[`E203_DECINFO_AGU_AMOMINU] = rv32_amominu_w;
  assign agu_info_bus[`E203_DECINFO_AGU_OP2IMM ] = need_imm; 


   wire dsp_has_no_rs2 = 
      
                        (dsp_op_srai8 | dsp_op_srai8u)        |    
                        (dsp_op_srli8 | dsp_op_srli8u)        |    
                        dsp_op_slli8       |                       
                        dsp_op_kslli8      |                       
                        dsp_op_srai16      |                       
                        dsp_op_srai16u     |                       
                        (dsp_op_srli16 | dsp_op_srli16u)      |    
                        (dsp_op_kslli16 | dsp_op_slli16)      |    
                        dsp_op_sraiu       |                       
                        dsp_op_kslliw      |                       
                        (dsp_op_sclip8 | dsp_op_uclip8)       |    
                        (dsp_op_sclip16 | dsp_op_uclip16)     |    
                        dsp_op_sclip32     |                       
                        dsp_op_uclip32     |                       
                        (rv32_func7_1010110 & rv32_func3_000) |    
                        (rv32_func7_1010111 & rv32_func3_000) |    
                        dsp_op_bitrevi     |                       
                        dsp_op_kabs8 |  dsp_op_kabs16 |dsp_op_kabsw |    
                        dsp_op_wexti       ;


  // Reuse the common signals as much as possible to save gatecounts
  wire rv32_all0s_ilgl  = rv32_func7_0000000 
                        & rv32_rs2_x0 
                        & rv32_rs1_x0 
                        & rv32_func3_000 
                        & rv32_rd_x0 
                        & opcode_6_5_00 
                        & opcode_4_2_000 
                        & (opcode[1:0] == 2'b00); 

  wire rv32_all1s_ilgl  = rv32_func7_1111111 
                        & rv32_rs2_x31 
                        & rv32_rs1_x31 
                        & rv32_func3_111 
                        & rv32_rd_x31 
                        & opcode_6_5_11 
                        & opcode_4_2_111 
                        & (opcode[1:0] == 2'b11); 

  wire rv16_all0s_ilgl  = rv16_func3_000 //rv16_func3  = rv32_instr[15:13];
                        & rv32_func3_000 //rv32_func3  = rv32_instr[14:12];
                        & rv32_rd_x0     //rv32_rd     = rv32_instr[11:7];
                        & opcode_6_5_00 
                        & opcode_4_2_000 
                        & (opcode[1:0] == 2'b00); 

  wire rv16_all1s_ilgl  = rv16_func3_111
                        & rv32_func3_111 
                        & rv32_rd_x31 
                        & opcode_6_5_11 
                        & opcode_4_2_111 
                        & (opcode[1:0] == 2'b11);
  
  wire rv_all0s1s_ilgl = rv32 ?  (rv32_all0s_ilgl | rv32_all1s_ilgl)
                              :  (rv16_all0s_ilgl | rv16_all1s_ilgl);

  //
  // All the RV32IMA need RD register except the
  //   * Branch, Store,
  //   * fence, fence_i 
  //   * ecall, ebreak  
  wire rv32_need_rd = 
                      (~rv32_rd_x0) & (
                      nice_op ? nice_need_rd :
                    (
                      (~rv32_branch) & (~rv32_store)
                    & (~rv32_fence_fencei)
                    & (~rv32_ecall_ebreak_ret_wfi) 
                    )
                   );

  // All the RV32IMA need RS1 register except the
  //   * lui
  //   * auipc
  //   * jal
  //   * fence, fence_i 
  //   * ecall, ebreak  
  //   * csrrwi
  //   * csrrsi
  //   * csrrci
  wire rv32_need_rs1 =
                      (~rv32_rs1_x0) & (
                      nice_op ? nice_need_rs1 :
                    (
                     
                      (~rv32_lui)
                    & (~rv32_auipc)
                    & (~rv32_jal)
                    & (~rv32_fence_fencei)
                    & (~rv32_ecall_ebreak_ret_wfi)
                    & (~rv32_csrrwi)
                    & (~rv32_csrrsi)
                    & (~rv32_csrrci)
                    )
                  );
                    
  // Following RV32IMA instructions need RS2 register
  //   * branch
  //   * store
  //   * rv32_op
  //   * rv32_amo except the rv32_lr_w
  wire rv32_need_rs2 = (~rv32_rs2_x0) & (
                 nice_op ? nice_need_rs2 :
                (
                
                 (rv32_branch)
               | (rv32_store)
               | (rv32_op)
               | (rv32_amo & (~rv32_lr_w))
               | (rv32_dsp_op & ~dsp_has_no_rs2)
                 )
                 );

  wire [31:0]  rv32_i_imm = { 
                               {20{rv32_instr[31]}} 
                              , rv32_instr[31:20]
                             };

  wire [31:0]  rv32_s_imm = {
                               {20{rv32_instr[31]}} 
                              , rv32_instr[31:25] 
                              , rv32_instr[11:7]
                             };


  wire [31:0]  rv32_b_imm = {
                               {19{rv32_instr[31]}} 
                              , rv32_instr[31] 
                              , rv32_instr[7] 
                              , rv32_instr[30:25] 
                              , rv32_instr[11:8]
                              , 1'b0
                              };

  wire [31:0]  rv32_u_imm = {rv32_instr[31:12],12'b0};

  wire [31:0]  rv32_j_imm = {
                               {11{rv32_instr[31]}} 
                              , rv32_instr[31] 
                              , rv32_instr[19:12] 
                              , rv32_instr[20] 
                              , rv32_instr[30:21]
                              , 1'b0
                              };

                   // It will select i-type immediate when
                   //    * rv32_op_imm
                   //    * rv32_jalr
                   //    * rv32_load
  wire rv32_imm_sel_i = rv32_op_imm | rv32_jalr | rv32_load;
  wire rv32_imm_sel_jalr = rv32_jalr;
  wire [31:0]  rv32_jalr_imm = rv32_i_imm;

                   // It will select u-type immediate when
                   //    * rv32_lui, rv32_auipc 
  wire rv32_imm_sel_u = rv32_lui | rv32_auipc;

                   // It will select j-type immediate when
                   //    * rv32_jal
  wire rv32_imm_sel_j = rv32_jal;
  wire rv32_imm_sel_jal = rv32_jal;
  wire [31:0]  rv32_jal_imm = rv32_j_imm;

                   // It will select b-type immediate when
                   //    * rv32_branch
  wire rv32_imm_sel_b = rv32_branch;
  wire rv32_imm_sel_bxx = rv32_branch;
  wire [31:0]  rv32_bxx_imm = rv32_b_imm;
                   
                   // It will select s-type immediate when
                   //    * rv32_store
  wire rv32_imm_sel_s = rv32_store;



  //   * Note: this CIS/CILI/CILUI/CI16SP-type is named by myself, because in 
  //           ISA doc, the CI format for LWSP is different
  //           with other CI formats in terms of immediate
  
                   // It will select CIS-type immediate when
                   //    * rv16_lwsp
  wire rv16_imm_sel_cis = rv16_lwsp;
  wire [31:0]  rv16_cis_imm ={
                          24'b0
                        , rv16_instr[3:2]
                        , rv16_instr[12]
                        , rv16_instr[6:4]
                        , 2'b0
                         };
                   
  wire [31:0]  rv16_cis_d_imm ={
                          23'b0
                        , rv16_instr[4:2]
                        , rv16_instr[12]
                        , rv16_instr[6:5]
                        , 3'b0
                         };
                   // It will select CILI-type immediate when
                   //    * rv16_li
                   //    * rv16_addi
                   //    * rv16_slli
                   //    * rv16_srai
                   //    * rv16_srli
                   //    * rv16_andi
  wire rv16_imm_sel_cili = rv16_li | rv16_addi | rv16_slli
                   | rv16_srai | rv16_srli | rv16_andi;
  wire [31:0]  rv16_cili_imm ={
                          {26{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[6:2]
                         };
                   
                   // It will select CILUI-type immediate when
                   //    * rv16_lui
  wire rv16_imm_sel_cilui = rv16_lui;
  wire [31:0]  rv16_cilui_imm ={
                          {14{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[6:2]
                        , 12'b0
                         };
                   
                   // It will select CI16SP-type immediate when
                   //    * rv16_addi16sp
  wire rv16_imm_sel_ci16sp = rv16_addi16sp;
  wire [31:0]  rv16_ci16sp_imm ={
                          {22{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[4]
                        , rv16_instr[3]
                        , rv16_instr[5]
                        , rv16_instr[2]
                        , rv16_instr[6]
                        , 4'b0
                         };
                   
                   // It will select CSS-type immediate when
                   //    * rv16_swsp
  wire rv16_imm_sel_css = rv16_swsp;
  wire [31:0]  rv16_css_imm ={
                          24'b0
                        , rv16_instr[8:7]
                        , rv16_instr[12:9]
                        , 2'b0
                         };
  wire [31:0]  rv16_css_d_imm ={
                          23'b0
                        , rv16_instr[9:7]
                        , rv16_instr[12:10]
                        , 3'b0
                         };
                   // It will select CIW-type immediate when
                   //    * rv16_addi4spn
  wire rv16_imm_sel_ciw = rv16_addi4spn;
  wire [31:0]  rv16_ciw_imm ={
                          22'b0
                        , rv16_instr[10:7]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[5]
                        , rv16_instr[6]
                        , 2'b0
                         };

                   // It will select CL-type immediate when
                   //    * rv16_lw
  wire rv16_imm_sel_cl = rv16_lw;
  wire [31:0]  rv16_cl_imm ={
                          25'b0
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , rv16_instr[6]
                        , 2'b0
                         };
                   
  wire [31:0]  rv16_cl_d_imm ={
                          24'b0
                        , rv16_instr[6]
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , 3'b0
                         };
                   // It will select CS-type immediate when
                   //    * rv16_sw
  wire rv16_imm_sel_cs = rv16_sw;
  wire [31:0]  rv16_cs_imm ={
                          25'b0
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , rv16_instr[6]
                        , 2'b0
                         };
   wire [31:0]  rv16_cs_d_imm ={
                          24'b0
                        , rv16_instr[6]
                        , rv16_instr[5]
                        , rv16_instr[12]
                        , rv16_instr[11]
                        , rv16_instr[10]
                        , 3'b0
                         };

                   // It will select CB-type immediate when
                   //    * rv16_beqz
                   //    * rv16_bnez
  wire rv16_imm_sel_cb = rv16_beqz | rv16_bnez;
  wire [31:0]  rv16_cb_imm ={
                          {23{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[6:5]
                        , rv16_instr[2]
                        , rv16_instr[11:10]
                        , rv16_instr[4:3]
                        , 1'b0
                         };
  wire [31:0]  rv16_bxx_imm = rv16_cb_imm;

                   // It will select CJ-type immediate when
                   //    * rv16_j
                   //    * rv16_jal
  wire rv16_imm_sel_cj = rv16_j | rv16_jal;
  wire [31:0]  rv16_cj_imm ={
                          {20{rv16_instr[12]}}
                        , rv16_instr[12]
                        , rv16_instr[8]
                        , rv16_instr[10:9]
                        , rv16_instr[6]
                        , rv16_instr[7]
                        , rv16_instr[2]
                        , rv16_instr[11]
                        , rv16_instr[5:3]
                        , 1'b0
                         };
  wire [31:0]  rv16_jjal_imm = rv16_cj_imm;

                   // It will select CR-type register (no-imm) when
                   //    * rv16_jalr_mv_add
  wire [31:0]  rv16_jrjalr_imm = 32'b0;
                   
                   // It will select CSR-type register (no-imm) when
                   //    * rv16_subxororand

                   
  wire [31:0]  rv32_load_fp_imm  = rv32_i_imm;
  wire [31:0]  rv32_store_fp_imm = rv32_s_imm;
  wire [31:0]  rv32_imm = 
                     ({32{rv32_imm_sel_i}} & rv32_i_imm)
                   | ({32{rv32_imm_sel_s}} & rv32_s_imm)
                   | ({32{rv32_imm_sel_b}} & rv32_b_imm)
                   | ({32{rv32_imm_sel_u}} & rv32_u_imm)
                   | ({32{rv32_imm_sel_j}} & rv32_j_imm)
                   ;
                   
  wire  rv32_need_imm = 
                     rv32_imm_sel_i
                   | rv32_imm_sel_s
                   | rv32_imm_sel_b
                   | rv32_imm_sel_u
                   | rv32_imm_sel_j
                   ;

  wire [31:0]  rv16_imm = 
                     ({32{rv16_imm_sel_cis   }} & rv16_cis_imm)
                   | ({32{rv16_imm_sel_cili  }} & rv16_cili_imm)
                   | ({32{rv16_imm_sel_cilui }} & rv16_cilui_imm)
                   | ({32{rv16_imm_sel_ci16sp}} & rv16_ci16sp_imm)
                   | ({32{rv16_imm_sel_css   }} & rv16_css_imm)
                   | ({32{rv16_imm_sel_ciw   }} & rv16_ciw_imm)
                   | ({32{rv16_imm_sel_cl    }} & rv16_cl_imm)
                   | ({32{rv16_imm_sel_cs    }} & rv16_cs_imm)
                   | ({32{rv16_imm_sel_cb    }} & rv16_cb_imm)
                   | ({32{rv16_imm_sel_cj    }} & rv16_cj_imm)
                   ;

  wire rv16_need_imm = 
                     rv16_imm_sel_cis   
                   | rv16_imm_sel_cili  
                   | rv16_imm_sel_cilui 
                   | rv16_imm_sel_ci16sp
                   | rv16_imm_sel_css   
                   | rv16_imm_sel_ciw   
                   | rv16_imm_sel_cl    
                   | rv16_imm_sel_cs    
                   | rv16_imm_sel_cb    
                   | rv16_imm_sel_cj    
                   ;


  assign need_imm = rv32 ? rv32_need_imm : rv16_need_imm; 

  assign dec_imm = rv32 ? rv32_imm : rv16_imm;
  assign dec_pc  = i_pc;

  

  assign dec_info = 
              ({`E203_DECINFO_WIDTH{alu_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_ALU_WIDTH{1'b0}},alu_info_bus})
            | ({`E203_DECINFO_WIDTH{amoldst_op}} & {{`E203_DECINFO_WIDTH-`E203_DECINFO_AGU_WIDTH{1'b0}},agu_info_bus})
            | ({`E203_DECINFO_WIDTH{bjp_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_BJP_WIDTH{1'b0}},bjp_info_bus})
            | ({`E203_DECINFO_WIDTH{csr_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}},csr_info_bus})
            | ({`E203_DECINFO_WIDTH{muldiv_op}}  & {{`E203_DECINFO_WIDTH-`E203_DECINFO_CSR_WIDTH{1'b0}},muldiv_info_bus})
            | ({`E203_DECINFO_WIDTH{nice_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_EAI_WIDTH{1'b0}},nice_info_bus})
            | ({`E203_DECINFO_WIDTH{dsp_op}}     & {{`E203_DECINFO_WIDTH-`E203_DECINFO_DSP_WIDTH{1'b0}},dsp_info_bus})
              ;


  wire legl_ops = 
              alu_op
            | amoldst_op
            | bjp_op
            | csr_op
            | muldiv_op
            | nice_op
            | dsp_op
            ;

  // To decode the registers for Rv16, divided into 8 groups
  wire rv16_format_cr  = rv16_jalr_mv_add;
  wire rv16_format_ci  = rv16_lwsp | rv16_flwsp | rv16_fldsp | rv16_li | rv16_lui_addi16sp | rv16_addi | rv16_slli; 
  wire rv16_format_css = rv16_swsp | rv16_fswsp | rv16_fsdsp; 
  wire rv16_format_ciw = rv16_addi4spn; 
  wire rv16_format_cl  = rv16_lw | rv16_flw | rv16_fld; 
  wire rv16_format_cs  = rv16_sw | rv16_fsw | rv16_fsd | rv16_subxororand; 
  wire rv16_format_cb  = rv16_beqz | rv16_bnez | rv16_srli | rv16_srai | rv16_andi; 
  wire rv16_format_cj  = rv16_j | rv16_jal; 


  // In CR Cases:
  //   * JR:     rs1= rs1(coded),     rs2= x0 (coded),   rd = x0 (implicit)
  //   * JALR:   rs1= rs1(coded),     rs2= x0 (coded),   rd = x1 (implicit)
  //   * MV:     rs1= x0 (implicit),  rs2= rs2(coded),   rd = rd (coded)
  //   * ADD:    rs1= rs1(coded),     rs2= rs2(coded),   rd = rd (coded)
  //   * eBreak: rs1= rs1(coded),     rs2= x0 (coded),   rd = x0 (coded)
  wire rv16_need_cr_rs1   = rv16_format_cr & 1'b1;
  wire rv16_need_cr_rs2   = rv16_format_cr & 1'b1;
  wire rv16_need_cr_rd    = rv16_format_cr & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rs1 = rv16_mv ? `E203_RFIDX_WIDTH'd0 : rv16_rs1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rs2 = rv16_rs2[`E203_RFIDX_WIDTH-1:0];
     // The JALR and JR difference in encoding is just the rv16_instr[12]
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cr_rd  = (rv16_jalr | rv16_jr)? 
                 {{`E203_RFIDX_WIDTH-1{1'b0}},rv16_instr[12]} : rv16_rd[`E203_RFIDX_WIDTH-1:0];
                         
  // In CI Cases:
  //   * LWSP:     rs1= x2 (implicit),  rd = rd 
  //   * LI/LUI:   rs1= x0 (implicit),  rd = rd
  //   * ADDI:     rs1= rs1(implicit),  rd = rd
  //   * ADDI16SP: rs1= rs1(implicit),  rd = rd
  //   * SLLI:     rs1= rs1(implicit),  rd = rd
  wire rv16_need_ci_rs1   = rv16_format_ci & 1'b1;
  wire rv16_need_ci_rs2   = rv16_format_ci & 1'b0;
  wire rv16_need_ci_rd    = rv16_format_ci & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rs1 = (rv16_lwsp | rv16_flwsp | rv16_fldsp) ? `E203_RFIDX_WIDTH'd2 :
                                  (rv16_li | rv16_lui) ? `E203_RFIDX_WIDTH'd0 : rv16_rs1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rs2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ci_rd  = rv16_rd[`E203_RFIDX_WIDTH-1:0];
                        
  // In CSS Cases:
  //   * SWSP:     rs1 = x2 (implicit), rs2= rs2 
  wire rv16_need_css_rs1  = rv16_format_css & 1'b1;
  wire rv16_need_css_rs2  = rv16_format_css & 1'b1;
  wire rv16_need_css_rd   = rv16_format_css & 1'b0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rs1 = `E203_RFIDX_WIDTH'd2;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rs2 = rv16_rs2[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_css_rd  = `E203_RFIDX_WIDTH'd0;
                       
  // In CIW cases:
  //   * ADDI4SPN:   rdd = rdd, rss1= x2 (implicit)
  wire rv16_need_ciw_rss1 = rv16_format_ciw & 1'b1;
  wire rv16_need_ciw_rss2 = rv16_format_ciw & 1'b0;
  wire rv16_need_ciw_rdd  = rv16_format_ciw & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rss1  = `E203_RFIDX_WIDTH'd2;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rss2  = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_ciw_rdd  = rv16_rdd[`E203_RFIDX_WIDTH-1:0];
                      
  // In CL cases:
  //   * LW:   rss1 = rss1, rdd= rdd
  wire rv16_need_cl_rss1  = rv16_format_cl & 1'b1;
  wire rv16_need_cl_rss2  = rv16_format_cl & 1'b0;
  wire rv16_need_cl_rdd   = rv16_format_cl & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rss2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cl_rdd  = rv16_rdd[`E203_RFIDX_WIDTH-1:0];
                     
  // In CS cases:
  //   * SW:            rdd = none(implicit), rss1= rss1       , rss2=rss2
  //   * SUBXORORAND:   rdd = rss1,           rss1= rss1(coded), rss2=rss2
  wire rv16_need_cs_rss1  = rv16_format_cs & 1'b1;
  wire rv16_need_cs_rss2  = rv16_format_cs & 1'b1;
  wire rv16_need_cs_rdd   = rv16_format_cs & rv16_subxororand;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rss2 = rv16_rss2[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cs_rdd  = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
                    
  // In CB cases:
  //   * BEQ/BNE:            rdd = none(implicit), rss1= rss1, rss2=x0(implicit)
  //   * SRLI/SRAI/ANDI:     rdd = rss1          , rss1= rss1, rss2=none(implicit)
  wire rv16_need_cb_rss1  = rv16_format_cb & 1'b1;
  wire rv16_need_cb_rss2  = rv16_format_cb & (rv16_beqz | rv16_bnez);
  wire rv16_need_cb_rdd   = rv16_format_cb & (~(rv16_beqz | rv16_bnez));
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rss1 = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rss2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cb_rdd  = rv16_rss1[`E203_RFIDX_WIDTH-1:0];
  
  // In CJ cases:
  //   * J:            rdd = x0(implicit)
  //   * JAL:          rdd = x1(implicit)
  wire rv16_need_cj_rss1  = rv16_format_cj & 1'b0;
  wire rv16_need_cj_rss2  = rv16_format_cj & 1'b0;
  wire rv16_need_cj_rdd   = rv16_format_cj & 1'b1;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rss1 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rss2 = `E203_RFIDX_WIDTH'd0;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_cj_rdd  = rv16_j ? `E203_RFIDX_WIDTH'd0 : `E203_RFIDX_WIDTH'd1;

  // rv16_format_cr  
  // rv16_format_ci  
  // rv16_format_css 
  // rv16_format_ciw 
  // rv16_format_cl  
  // rv16_format_cs  
  // rv16_format_cb  
  // rv16_format_cj  
  wire rv16_need_rs1 = rv16_need_cr_rs1 | rv16_need_ci_rs1 | rv16_need_css_rs1;
  wire rv16_need_rs2 = rv16_need_cr_rs2 | rv16_need_ci_rs2 | rv16_need_css_rs2;
  wire rv16_need_rd  = rv16_need_cr_rd  | rv16_need_ci_rd  | rv16_need_css_rd;

  wire rv16_need_rss1 = rv16_need_ciw_rss1|rv16_need_cl_rss1|rv16_need_cs_rss1|rv16_need_cb_rss1|rv16_need_cj_rss1;
  wire rv16_need_rss2 = rv16_need_ciw_rss2|rv16_need_cl_rss2|rv16_need_cs_rss2|rv16_need_cb_rss2|rv16_need_cj_rss2;
  wire rv16_need_rdd  = rv16_need_ciw_rdd |rv16_need_cl_rdd |rv16_need_cs_rdd |rv16_need_cb_rdd |rv16_need_cj_rdd ;

  wire rv16_rs1en = (rv16_need_rs1 | rv16_need_rss1);
  wire rv16_rs2en = (rv16_need_rs2 | rv16_need_rss2);
  wire rv16_rden  = (rv16_need_rd  | rv16_need_rdd );

  wire [`E203_RFIDX_WIDTH-1:0] rv16_rs1idx;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_rs2idx;
  wire [`E203_RFIDX_WIDTH-1:0] rv16_rdidx ;

  assign rv16_rs1idx = 
         ({`E203_RFIDX_WIDTH{rv16_need_cr_rs1 }} & rv16_cr_rs1)
       | ({`E203_RFIDX_WIDTH{rv16_need_ci_rs1 }} & rv16_ci_rs1)
       | ({`E203_RFIDX_WIDTH{rv16_need_css_rs1}} & rv16_css_rs1)
       | ({`E203_RFIDX_WIDTH{rv16_need_ciw_rss1}} & rv16_ciw_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cl_rss1}}  & rv16_cl_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cs_rss1}}  & rv16_cs_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cb_rss1}}  & rv16_cb_rss1)
       | ({`E203_RFIDX_WIDTH{rv16_need_cj_rss1}}  & rv16_cj_rss1)
       ;

  assign rv16_rs2idx = 
         ({`E203_RFIDX_WIDTH{rv16_need_cr_rs2 }} & rv16_cr_rs2)
       | ({`E203_RFIDX_WIDTH{rv16_need_ci_rs2 }} & rv16_ci_rs2)
       | ({`E203_RFIDX_WIDTH{rv16_need_css_rs2}} & rv16_css_rs2)
       | ({`E203_RFIDX_WIDTH{rv16_need_ciw_rss2}} & rv16_ciw_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cl_rss2}}  & rv16_cl_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cs_rss2}}  & rv16_cs_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cb_rss2}}  & rv16_cb_rss2)
       | ({`E203_RFIDX_WIDTH{rv16_need_cj_rss2}}  & rv16_cj_rss2)
       ;

  assign rv16_rdidx = 
         ({`E203_RFIDX_WIDTH{rv16_need_cr_rd }} & rv16_cr_rd)
       | ({`E203_RFIDX_WIDTH{rv16_need_ci_rd }} & rv16_ci_rd)
       | ({`E203_RFIDX_WIDTH{rv16_need_css_rd}} & rv16_css_rd)
       | ({`E203_RFIDX_WIDTH{rv16_need_ciw_rdd}} & rv16_ciw_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cl_rdd}}  & rv16_cl_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cs_rdd}}  & rv16_cs_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cb_rdd}}  & rv16_cb_rdd)
       | ({`E203_RFIDX_WIDTH{rv16_need_cj_rdd}}  & rv16_cj_rdd)
       ;

  assign dec_rs1idx = rv32 ? rv32_rs1[`E203_RFIDX_WIDTH-1:0] : rv16_rs1idx;
  assign dec_rs2idx = rv32 ? rv32_rs2[`E203_RFIDX_WIDTH-1:0] : rv16_rs2idx;
  assign dec_rdidx  = rv32 ? rv32_rd [`E203_RFIDX_WIDTH-1:0] : rv16_rdidx ;

  assign dec_rs1idx_1 = 
                        rs1_is_64 ? {rv32_rs1[`E203_RFIDX_WIDTH-1:1], 1'b1} :
                        rd_r_is_64 ? {rv32_rd[`E203_RFIDX_WIDTH-1:1], 1'b0} :
                        rv32_rd[`E203_RFIDX_WIDTH-1:0];  // rv32_need_read_rd

  assign dec_rs2idx_1 = rs2_is_64 ? {rv32_rs2[`E203_RFIDX_WIDTH-1:1], 1'b1} :
                        rd_r_is_64 ? {rv32_rd[`E203_RFIDX_WIDTH-1:1], 1'b1} : 
                        rv32_rc[`E203_RFIDX_WIDTH-1:0];  // rc of bpick


  assign dec_rs1en = rv32 ? rv32_need_rs1 : (rv16_rs1en & (~(rv16_rs1idx == `E203_RFIDX_WIDTH'b0))); 
  assign dec_rs2en = rv32 ? rv32_need_rs2 : (rv16_rs2en & (~(rv16_rs2idx == `E203_RFIDX_WIDTH'b0)));
  assign dec_rdwen = rv32 ? rv32_need_rd  : (rv16_rden  & (~(rv16_rdidx  == `E203_RFIDX_WIDTH'b0)));


  assign dec_rs1en_1 = rs1_is_64 | rd_r_is_64 | rv32_need_read_rd ;  
  assign dec_rs2en_1 = rs2_is_64 | rd_r_is_64 | dsp_op_bpick;  
  assign dec_rdwen_1 = rd_w_is_64;  
  assign dec_rdren   = rd_r_is_64 | rv32_need_read_rd ;
  assign dec_rdren_1 = rd_r_is_64;   

  assign dec_rdidx_1 = {rv32_rd [`E203_RFIDX_WIDTH-1:1],1'b1};


  assign dec_rs1x0 = (dec_rs1idx == `E203_RFIDX_WIDTH'b0);
  assign dec_rs2x0 = (dec_rs2idx == `E203_RFIDX_WIDTH'b0);
 
  assign dec_rs1x0_1 = (dec_rs1idx_1  == `E203_RFIDX_WIDTH'b0);
  assign dec_rs2x0_1 = (dec_rs2idx_1  == `E203_RFIDX_WIDTH'b0);
                     
  wire rv_index_ilgl;
  `ifdef E203_RFREG_NUM_IS_4 //{ 
  assign rv_index_ilgl =
                 (| dec_rs1idx[`E203_RFIDX_WIDTH-1:2])
                |(| dec_rs2idx[`E203_RFIDX_WIDTH-1:2])
                |(| dec_rdidx [`E203_RFIDX_WIDTH-1:2])
                ;
  `endif//}
  `ifdef E203_RFREG_NUM_IS_8 //{ 
  assign rv_index_ilgl =
                 (| dec_rs1idx[`E203_RFIDX_WIDTH-1:3])
                |(| dec_rs2idx[`E203_RFIDX_WIDTH-1:3])
                |(| dec_rdidx [`E203_RFIDX_WIDTH-1:3])
                ;
  `endif//}
  `ifdef E203_RFREG_NUM_IS_16 //{ 
  assign rv_index_ilgl =
                 (| dec_rs1idx[`E203_RFIDX_WIDTH-1:4])
                |(| dec_rs2idx[`E203_RFIDX_WIDTH-1:4])
                |(| dec_rdidx [`E203_RFIDX_WIDTH-1:4])
                ;
  `endif//}
  `ifdef E203_RFREG_NUM_IS_32 //{ 
      //Never happen this illegal exception
  assign rv_index_ilgl = 1'b0;
  `endif//}

  assign dec_rv32 = rv32;

  assign dec_bjp_imm = 
                     ({32{rv16_jal | rv16_j     }} & rv16_jjal_imm)
                   | ({32{rv16_jalr_mv_add      }} & rv16_jrjalr_imm)
                   | ({32{rv16_beqz | rv16_bnez }} & rv16_bxx_imm)
                   | ({32{rv32_jal              }} & rv32_jal_imm)
                   | ({32{rv32_jalr             }} & rv32_jalr_imm)
                   | ({32{rv32_branch           }} & rv32_bxx_imm)
                   ;

  assign dec_jalr_rs1idx = rv32 ? rv32_rs1[`E203_RFIDX_WIDTH-1:0] : rv16_rs1[`E203_RFIDX_WIDTH-1:0]; 

  assign dec_misalgn = i_misalgn;
  assign dec_buserr  = i_buserr ;


  assign dec_ilegl = 
            (rv_all0s1s_ilgl) 
          | (rv_index_ilgl) 
          | (rv16_addi16sp_ilgl)
          | (rv16_addi4spn_ilgl)
          | (rv16_li_lui_ilgl)
          | (rv16_sxxi_shamt_ilgl)
          | (rv32_sxxi_shamt_ilgl)
          | (rv32_dret_ilgl)
          | (rv16_lwsp_ilgl)
          | (~legl_ops);


endmodule                                      
                                               
                                               
                                               
