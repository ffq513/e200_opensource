
module e203_dsp_32comp #(
  parameter DW = 106 
)(
  input [DW-1:0] i0,
  input [DW-1:0] i1,
  input [DW-1:0] i2,
  output [DW-1:0] c,
  output [DW-1:0] s 
);

assign s = (i0 ^ i1) ^ i2;

wire [DW-1:0] tmp = (i0 & i1) | (i0 & i2) | (i1 & i2);

assign c = {tmp[DW-2:0], 1'b0};

endmodule
