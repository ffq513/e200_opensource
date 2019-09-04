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

#################################################################################
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
##########pbsad##########
//4*ABS((ff) - (ff)) = 0
li a2, 0xffffffff
li a3, 0xffffffff
pbsad a4,a2,a3
li a6, 0x0
bne a4,a6,fail
// 4*ABS((ff) - 1) = 0x3f8
li a2, 0xffffffff
li a3, 0x01010101
pbsad a4,a2,a3
li a6, 0x3f8
bne a4,a6,fail
// 4*ABS((1) - (ff)) = 0x3f8
li a2, 0x01010101
li a3, 0xffffffff
pbsad a4,a2,a3
li a6, 0x3f8
bne a4,a6,fail
// 4*ABS((3) - (4)) = 4
li a2, 0x3030303
li a3, 0x4040404
pbsad a4,a2,a3
li a6, 0x4
bne a4,a6,fail
##########pbsada##########
//4*ABS((ff) - (ff)) = 0
li a4, 0x1
li a2, 0xffffffff
li a3, 0xffffffff
pbsada a4,a2,a3
li a6, 0x1
bne a4,a6,fail
// 4*ABS((ff) - ff) = 0x3f8
li a2, 0xffffffff
li a3, 0x01010101
pbsada a4,a2,a3
li a6, 0x3f9
bne a4,a6,fail
// 4*ABS((1) - (ff)) = 0x3f8
li a2, 0x01010101
li a3, 0xffffffff
pbsada a4,a2,a3
li a6, 0x7f1
bne a4,a6,fail
// 4*ABS((3) - (4)) = 4
li a2, 0x3030303
li a3, 0x4040404
pbsada a4,a2,a3
li a6, 0x7f5 
bne a4,a6,fail
//##########kmda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmxda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmxda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmxda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmxda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmxda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smds##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smds a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smds a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smds a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smds a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smdrs##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smdrs a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smdrs a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smdrs a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smdrs a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smxds##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smxds a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smxds a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smxds a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smxds a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
##########smal##########
//{rd_1,rd_0} = {rs1_1,rs1_0} + se64(rs2[31:16]*rs2[15:0])
li a0, 0xffffffff
li a1, 0xffffffff
li a3, 0xffffffff
smal a4,a0,a3
li a6, 0x0
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail

li a0, 0xffffffff
li a1, 0xffffffff
li a3, 0x30004
smal a4,a0,a3
li a6, 0xb
li a7, 0x0
bne a4,a6,fail
bne a5,a7,fail

li a0, 0xffffffff
li a1, 0xffffffff
li a3, 0x0
smal a4,a0,a3
li a6, 0xffffffff
li a7, 0xffffffff
bne a4,a6,fail
bne a5,a7,fail

li a0, 0x4030201
li a1, 0x1010202
li a3, 0x15678
smal a4,a0,a3
li a6, 0x4035879
li a7, 0x1010202
bne a4,a6,fail
bne a5,a7,fail
##########smmul.u##########
//-1*-1 = 1
li a2, 0xffffffff
li a3, 0xffffffff
smmul.u a4,a2,a3
li a6, 0x0
bne a4,a6,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x1
smmul.u a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
smmul.u a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//3*4 = 12
li a2, 0x30000
li a3, 0x40000
smmul.u a4,a2,a3
li a6, 0xc
bne a4,a6,fail

li a2, 0x2
li a3, 0x40000000
smmul.u a4,a2,a3
li a6, 0x1
bne a4,a6,fail
//##########kwmmul.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kwmmul.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kwmmul.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kwmmul.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kwmmul.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmwt2.u##########
//-1*-1 = 1
li a2, 0xffffffff
li a3, 0xffff1323
kmmwt2.u a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//overflow
li a2, 0x80000000
li a3, 0x80001323
kmmwt2.u a4,a2,a3
li a6, 0x7fffffff
bne a4,a6,fail
csrr a7,ucode
li a6,0x1
bne a6,a7,fail
// -1*1=-1
li a2, 0xffffffff
li a3, 0x12345
kmmwt2.u a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//-1*0 = 0
li a2, 0xffffffff
li a3, 0x0
kmmwt2.u a4,a2,a3
li a6, 0x0
bne a4,a6,fail
//3*4 = 12
li a2, 0x7000
li a3, 0x10000
kmmwt2.u a4,a2,a3
li a6, 0x1
bne a4,a6,fail

li a2, 0x23300
li a3, 0x30000
kmmwt2.u a4,a2,a3
li a6, 0xd
bne a4,a6,fail
//##########kmmwb2.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmwb2.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmwb2.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmwb2.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmwb2.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smmwt.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smmwt.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smmwt.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smmwt.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smmwt.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smmwb.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smmwb.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smmwb.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smmwb.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smmwb.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########maddr32##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//maddr32 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//maddr32 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//maddr32 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//maddr32 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########msubr32##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//msubr32 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//msubr32 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//msubr32 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//msubr32 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawb.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawb.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawb.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawb.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawb.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawt.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawt.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawt.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawt.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawt.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawb2##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawb2 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawb2 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawb2 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawb2 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawb2.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawb2.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawb2.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawb2.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawb2.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawt2##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawt2 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawt2 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawt2 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawt2 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawt2.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawt2.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawt2.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawt2.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawt2.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmawb##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmawb a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmawb a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmawb a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmawb a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmac##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmac a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmac a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmac a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmac a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmac.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmac.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmac.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmac.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmac.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmsb##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmsb a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmsb a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmsb a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmsb a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmmsb.u##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmmsb.u a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmmsb.u a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmmsb.u a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmmsb.u a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smar64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smar64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smar64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smar64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smar64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smsr64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smsr64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smsr64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smsr64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smsr64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmsr64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmsr64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmsr64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmsr64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmsr64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmar64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmar64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmar64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmar64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmar64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########ukmsr64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//ukmsr64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//ukmsr64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//ukmsr64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//ukmsr64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########ukmar64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//ukmar64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//ukmar64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//ukmar64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//ukmar64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########umar64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//umar64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//umar64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//umar64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//umar64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########umsr64##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//umsr64 a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//umsr64 a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//umsr64 a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//umsr64 a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smalbb##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smalbb a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smalbb a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smalbb a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smalbb a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smalbt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smalbt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smalbt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smalbt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smalbt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smaltt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smaltt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smaltt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smaltt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smaltt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmabb##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmabb a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmabb a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmabb a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmabb a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmabt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmabt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmabt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmabt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmabt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmatt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmatt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmatt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmatt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmatt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kdmabb##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kdmabb a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kdmabb a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kdmabb a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kdmabb a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kdmabt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kdmabt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kdmabt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kdmabt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kdmabt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kdmatt##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kdmatt a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kdmatt a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kdmatt a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kdmatt a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmada##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmada a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmada a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmada a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmada a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmaxda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmaxda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmaxda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmaxda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmaxda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmads##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmads a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmads a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmads a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmads a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmadrs##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmadrs a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmadrs a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmadrs a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmadrs a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmaxds##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmaxds a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmaxds a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmaxds a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmaxds a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmsda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmsda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmsda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmsda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmsda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########kmsxda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//kmsxda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//kmsxda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//kmsxda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//kmsxda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smaqa##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smaqa a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smaqa a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smaqa a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smaqa a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########umaqa##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//umaqa a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//umaqa a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//umaqa a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//umaqa a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smaqa.su##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smaqa.su a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smaqa.su a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smaqa.su a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smaqa.su a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smslda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smslda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smslda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smslda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smslda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smslxda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smslxda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smslxda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smslxda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smslxda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smalda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smalda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smalda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smalda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smalda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smalxda##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smalxda a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smalxda a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smalxda a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smalxda a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smalds##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smalds a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smalds a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smalds a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smalds a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smaldrs##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smaldrs a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smaldrs a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smaldrs a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smaldrs a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
//##########smalxds##########
////-1*-1 = 1
//li a2, 0xffffffff
//li a3, 0xffffffff
//smalxds a4,a2,a3
//li a6, 0x10001
//li a7, 0x10001
//##bne a4,a6,fail
//##bne a5,a7,fail
//// -1*1=-1
//li a2, 0xffffffff
//li a3, 0x01010101
//smalxds a4,a2,a3
//li a6, 0xffffffff
//li a7, 0xffffffff
//##bne a4,a6,fail
//##bne a5,a7,fail
////-1*0 = 0
//li a2, 0xffffffff
//li a3, 0x0
//smalxds a4,a2,a3
//li a6, 0x0
//li a7, 0x0
//##bne a4,a6,fail
//##bne a5,a7,fail
////3*4 = 12
//li a2, 0x3030303
//li a3, 0x4040404
//smalxds a4,a2,a3
//li a6, 0xc000c
//li a7, 0xc000c
//##bne a4,a6,fail
//##bne a5,a7,fail
#`endif N200_CFG_HAS_DSP



  j pass
  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

fsw_data: .word 1

RVTEST_DATA_END
