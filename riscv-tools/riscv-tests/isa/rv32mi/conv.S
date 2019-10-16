# See LICENSE for license details.

#*****************************************************************************
# csr.S
#-----------------------------------------------------------------------------
#
# Test CSRRx and CSRRxI instructions.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64S
RVTEST_CODE_BEGIN

test1:


#  li x4 , 1
#  li x5 , 0x90000000
#  li x6 , 200
#init_mem1:
#  sw x4 , 0(x5) 
#  addi x4 , x4 , 1
#  addi x5 , x5 , 4
#  bne x4 ,x6 , init_mem1
#
#
#  li x4 , 1
#  li x5 , 0x90001000
#  li x6 , 200
#init_mem2:
#  sw x4 , 0(x5) 
#  addi x4 , x4 , 1
#  addi x5 , x5 , 4
#  bne x4 ,x6 , init_mem2

  li x4 , 0x00020001 //bias_shift
  li x5 , 0x90000800 //out_shift
  .insn r 0xb , 3 ,0xb , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[3] , xd , xs1 ,xs2 // [jj_init_ch]


  li x4 , 3 //ch_im_in
  li x5 , 3 //ch_im_out
  .insn r 0xb , 3 ,3 , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[3] , xd , xs1 ,xs2 // [jj_init_ch]

  li x4 , 6 //dim_im_in
  li x5 , 6 //dim_im_out
  .insn r 0xb , 3 ,4 , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[4] , xd , xs1 ,xs2 // [jj_init_im]

  li x4 , 3 //dim_kernel
  li x5 , 1 //stride
  .insn r 0xb , 3 ,5 , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[5] , xd , xs1 ,xs2 // [jj_init_fs]

  li x4 , 0 //padding
  li x5 , 0x90000100 //wt_addr
  .insn r 0xb , 3 ,6 , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[6] , xd , xs1 ,xs2 // [jj_init_pw]

  li x4 , 0x90000000 //im_in_addr
  li x5 , 0x90000200 //im_out_addr
  .insn r 0xb , 3 ,7 , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[7] , xd , xs1 ,xs2 // [jj_init_imaddr]

 
 .insn r 0xb , 4 ,8 , x0 ,x4 ,x5  //custom0[0xb] , func3[xd,xs1,xs2(011)] ,func7[8] , xd , xs1 ,xs2 // [jj_init_ch]


  j pass
  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

fsw_data: .word 1

RVTEST_DATA_END
