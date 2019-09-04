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

//-1*-1 = 1
li a2, 0xffffffff
li a3, 0xffffffff
smul8 a4,a2,a3
li a6, 0x10001
li a7, 0x10001
bne a4,a6,fail
bne a5,a7,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x01010101
smul8 a4,a2,a3
li a6, 0xffffffff
li a7, 0xffffffff
bne a4,a6,fail
bne a5,a7,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
smul8 a4,a2,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail
//3*4 = 12
li a2, 0x3030303
li a3, 0x4040404
smul8 a4,a2,a3
li a6, 0xc000c
li a7, 0xc000c
bne a4,a6,fail
bne a5,a7,fail

############SMUL16#############
//-1*-1 = 1
li a2, 0xffffffff
li a3, 0xffffffff
smul16 a4,a2,a3
li a6, 0x1
li a7, 0x1
bne a4,a6,fail
bne a5,a7,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x10001
smul16 a4,a2,a3
li a6, 0xffffffff
li a7, 0xffffffff
bne a4,a6,fail
bne a5,a7,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
smul16 a4,a2,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail
//3*4 = 12
li a2, 0x30003
li a3, 0x40004
smul16 a4,a2,a3
li a6, 0xc
li a7, 0xc
bne a4,a6,fail
bne a5,a7,fail


############SMMUL#############
li a2, 0xffffffff
li a3, 0xffffffff
smmul a4,a2,a3
li a5, 0x0
bne a4,a5,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x00001
smmul a4,a2,a3
li a5, 0xffffffff
bne a4,a5,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
smmul a4,a2,a3
li a5, 0x0
bne a4,a5,fail
//3*4 = 12
li a2, 0x30000000
li a3, 0x40000000
smmul a4,a2,a3
li a5, 0x0c000000
bne a4,a5,fail

############MADDR32#############
li a2, 0xffffffff
li a3, 0xffffffff
li a4, 0x1;
maddr32 a4,a2,a3
li a5, 0x2
bne a4,a5,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x00001
maddr32 a4,a2,a3
li a5, 0x1
bne a4,a5,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
maddr32 a4,a2,a3
li a5, 0x1
bne a4,a5,fail
//3*4 = 12
li a2, 0x3
li a3, 0x4
maddr32 a4,a2,a3
li a5, 0xd
bne a4,a5,fail
li a2, 0x1
li a3, 0x1
maddr32 a4,a2,a3 ###e
maddr32 a4,a2,a3 ###f
maddr32 a4,a2,a3 ###10
maddr32 a4,a2,a3 ###11
maddr32 a4,a2,a3 ###12
maddr32 a4,a2,a3 ###13
maddr32 a4,a2,a3 ###14
li a5, 0x14
bne a4,a5,fail

//umul16
//0xffff*0xffff = 0xfffe0001
li a2, 0xffffffff
li a3, 0xffffffff
umul16 a4,a2,a3
li a6, 0xfffe0001
li a7, 0xfffe0001
bne a4,a6,fail
bne a5,a7,fail
// 0xffff*1=0x0000ffff
li a2, 0xffffffff
li a3, 0x00010001
umul16 a4,a2,a3
li a6, 0x0000ffff
li a7, 0x0000ffff
bne a4,a6,fail
bne a5,a7,fail
//0xffff*0 = 0
li a2, 0xffffffff
li a3, 0x0
umul16 a4,a2,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail
//3*4 = 12
li a2, 0x40003
li a3, 0x30004
umul16 a4,a2,a3
li a6, 0xc
li a7, 0xc
bne a4,a6,fail
bne a5,a7,fail

//umulx16
//0xffff*0xffff = 0xfffe0001
li a2, 0xffffffff
li a3, 0xffffffff
umulx16 a4,a2,a3
li a6, 0xfffe0001
li a7, 0xfffe0001
bne a4,a6,fail
bne a5,a7,fail
// 0xffff*1=0x0000ffff
li a2, 0xffffffff
li a3, 0x00010001
umulx16 a4,a2,a3
li a6, 0x0000ffff
li a7, 0x0000ffff
bne a4,a6,fail
bne a5,a7,fail
//0xffff*0 = 0
li a2, 0xffffffff
li a3, 0x0
umulx16 a4,a2,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail
//3*4 = 12
li a2, 0x40003
li a3, 0x30004
umulx16 a4,a2,a3
li a6, 0x9
li a7, 0x10
bne a4,a6,fail
bne a5,a7,fail

//umul8
//0xff*0xff = 0xfe01 
li a2, 0xffffffff
li a3, 0xffffffff
umul8 a4,a2,a3
li a6, 0xfe01fe01
li a7, 0xfe01fe01
bne a4,a6,fail
bne a5,a7,fail
// 0xff*0x1=0x00ff
li a2, 0xffffffff
li a3, 0x01010101
umul8 a4,a2,a3
li a6, 0x00ff00ff
li a7, 0x00ff00ff
bne a4,a6,fail
bne a5,a7,fail
//0xff*0 = 0x0000
li a2, 0xffffffff
li a3, 0x0
umul8 a4,a2,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail
//0x03*0x04 =0x000c 
li a2, 0x4030403
li a3, 0x4030403
umul8 a4,a2,a3
li a6, 0x100009
li a7, 0x100009
bne a4,a6,fail
bne a5,a7,fail

//umulx8
//0xff*0xff = 0xfe01 
li a2, 0xffffffff
li a3, 0xffffffff
umulx8 a4,a2,a3
li a6, 0xfe01fe01
li a7, 0xfe01fe01
bne a4,a6,fail
bne a5,a7,fail
// 0xff*0x01=0x00ff
li a2, 0xffffffff
li a3, 0x01010101
umulx8 a4,a2,a3
li a6, 0x00ff00ff
li a7, 0x00ff00ff
bne a4,a6,fail
bne a5,a7,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
umulx8 a4,a2,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail
//3*4 = 12
li a2, 0x4030403
li a3, 0x4030403
umulx8 a4,a2,a3
li a6, 0xc000c
li a7, 0xc000c
bne a4,a6,fail
bne a5,a7,fail


############smmwb#############
//rd = Mres[47:16]
//-1*-1 = 0
li a2, 0xffffffff
li a3, 0x2356ffff
smmwb a4,a2,a3
li a6, 0x0
bne a4,a6,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0xf1e10001
smmwb a4,a2,a3
li a6, 0xffffffff
bne a4,a6,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x45010000
smmwb a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//30000*4 = 12
li a2, 0x30000
li a3, 0x63250004
smmwb a4,a2,a3
li a6, 0xc
bne a4,a6,fail

//##########smmwt#########
//-1*-1 = 0
li a2, 0xffffffff
li a3, 0xffff0234
smmwt a4,a2,a3
li a6, 0x0
bne a4,a6,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x0001f1e1
smmwt a4,a2,a3
li a6, 0xffffffff
bne a4,a6,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x00004501
smmwt a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//3*4 = 12
li a2, 0x30000
li a3, 0x00046325
smmwt a4,a2,a3
li a6, 0xc
bne a4,a6,fail

##########kmmwb2##########
//rd = Mres[46:15]
//-1*-1 = 0
li a2, 0xffffffff
li a3, 0x2356ffff
kmmwb2 a4,a2,a3
li a6, 0x0
bne a4,a6,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0xf1e10001
kmmwb2 a4,a2,a3
li a6, 0xffffffff
bne a4,a6,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x45010000
kmmwb2 a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//30000*4 = 12
li a2, 0x30000
li a3, 0x63250004
kmmwb2 a4,a2,a3
li a6, 0x18
bne a4,a6,fail

//##########kmmwt2##########
//rd = Mres[46:15]
//-1*-1 = 0
li a2, 0xffffffff
li a3, 0xffff0234
kmmwt2 a4,a2,a3
li a6, 0x0
bne a4,a6,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x0001f1e1
kmmwt2 a4,a2,a3
li a6, 0xffffffff
bne a4,a6,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x00004501
kmmwt2 a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//3*4 = 12
li a2, 0x30000
li a3, 0x00046325
kmmwt2 a4,a2,a3
li a6, 0x18
bne a4,a6,fail
li a2, 0x8000
li a3, 0x8000
khmbb a4,a2,a3
li a6, 0x7fff
bne a4,a6,fail

  j pass
  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

fsw_data: .word 1

RVTEST_DATA_END
