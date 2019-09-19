
module e203_dsp_42comp #(
    parameter DW = 106 
)(
  input [DW-1:0] i0,
  input [DW-1:0] i1,
  input [DW-1:0] i2,
  input [DW-1:0] i3,
  output [DW-1:0] c,
  output [DW-1:0] s 
);

   wire [DW-1:0] tmp1 = (i0 & i1) | (i1 & i2) | (i0 & i2);
   wire [DW-1:0] tmp2 = {tmp1[DW-2:0], 1'b0};

   wire [DW-1:0] n0 = tmp2 ^ i3;
   wire [DW-1:0] n1 = (i0 ^ i1) ^ i2;

   assign s = n0 ^ n1;

   wire [DW-1:0] tmp3 = (n1 & i3) |  (i3 & tmp2) | (tmp2 & n1);

   assign c = {tmp3[DW-2:0], 1'b0};

endmodule
