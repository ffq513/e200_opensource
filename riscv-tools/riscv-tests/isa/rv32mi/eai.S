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
  li x5 , 0x90000000
  li x6 , 1
  sw x6 , 0(x5)
  li x6 , 2
  sw x6 , 4(x5)
  li x6 , 3
  sw x6 , 8(x5)
  li x6 , 4
  sw x6 , 12(x5)
  li x6 , 5
  sw x6 , 16(x5)
  li x6 , 6
  sw x6 , 20(x5)
  li x6 , 7
  sw x6 , 24(x5)
  li x6 , 8
  sw x6 , 28(x5)
  li x6 , 9
  sw x6 , 32(x5)

  li x4 , 0x90000000
  li x8 , 3
  .insn r 0xb , 3 ,0 , x7 ,x4 ,x8
  
  li x1 , 0
  .insn r 0xb , 6 ,1 , x7 ,x1 ,x8
  li x4 , 6
  bne x4 ,x7 , fail

  li x1 , 1
  .insn r 0xb , 6 ,1 , x7 ,x1 ,x8
  li x4 , 15
  bne x4 ,x7 , fail

  li x1 , 2
  .insn r 0xb , 6 ,1 , x7 ,x1 ,x8
  li x4 , 24
  bne x4 ,x7 , fail

  li x1 , 0
  .insn r 0xb , 6 ,2 , x7 ,x1 ,x8
  li x4 , 12
  bne x4 , x7 , fail

  li x1 , 1
  .insn r 0xb , 6 ,2 , x7 ,x1 ,x8
  li x4 , 15
  bne x4 , x7 , fail

  li x1 , 2
  .insn r 0xb , 6 ,2 , x7 ,x1 ,x8
  li x4 , 18
  bne x4 , x7 , fail

  j pass
  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

fsw_data: .word 1

RVTEST_DATA_END
