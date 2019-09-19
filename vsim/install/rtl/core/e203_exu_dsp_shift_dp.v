
                                                                        
`include "e203_defines.v"

module e203_exu_dsp_shift_dp(
  input                   dp_shift_right_req_i    ,      
  input                   dp_shift_left_req_i     ,      
  input  [`E203_XLEN-1:0] dp_shift_op1_i          ,      
  input  [4:0]            dp_shift_op2_i          ,      
  output [`E203_XLEN-1:0] dp_shift_right_res_o    ,      
  output [`E203_XLEN-1:0] dp_shift_left_res_o            

  );

wire op_shift = dp_shift_right_req_i | dp_shift_right_req_i;

wire [`E203_XLEN-1:0] shifter_op1 = dp_shift_op1_i;
wire [4:0]            shifter_op2 = dp_shift_op2_i;

wire [`E203_XLEN-1:0] shifter_in1;
wire [4:0]            shifter_in2;

wire [`E203_XLEN-1:0] shifter_op1_br =  
                 {
    shifter_op1[00],shifter_op1[01],shifter_op1[02],shifter_op1[03],
    shifter_op1[04],shifter_op1[05],shifter_op1[06],shifter_op1[07],
    shifter_op1[08],shifter_op1[09],shifter_op1[10],shifter_op1[11],
    shifter_op1[12],shifter_op1[13],shifter_op1[14],shifter_op1[15],
    shifter_op1[16],shifter_op1[17],shifter_op1[18],shifter_op1[19],
    shifter_op1[20],shifter_op1[21],shifter_op1[22],shifter_op1[23],
    shifter_op1[24],shifter_op1[25],shifter_op1[26],shifter_op1[27],
    shifter_op1[28],shifter_op1[29],shifter_op1[30],shifter_op1[31]
                 };

assign shifter_in1 =   ({`E203_XLEN{dp_shift_right_req_i}} & shifter_op1_br)
                     | ({`E203_XLEN{dp_shift_left_req_i }} & shifter_op1   )
                     ;

assign shifter_in2 = shifter_op2;

wire [`E203_XLEN-1:0] shifter_res;
assign shifter_res = (shifter_in1 << shifter_in2);

assign dp_shift_left_res_o = shifter_res;

assign dp_shift_right_res_o =        
                 {
    shifter_res[00],shifter_res[01],shifter_res[02],shifter_res[03],
    shifter_res[04],shifter_res[05],shifter_res[06],shifter_res[07],
    shifter_res[08],shifter_res[09],shifter_res[10],shifter_res[11],
    shifter_res[12],shifter_res[13],shifter_res[14],shifter_res[15],
    shifter_res[16],shifter_res[17],shifter_res[18],shifter_res[19],
    shifter_res[20],shifter_res[21],shifter_res[22],shifter_res[23],
    shifter_res[24],shifter_res[25],shifter_res[26],shifter_res[27],
    shifter_res[28],shifter_res[29],shifter_res[30],shifter_res[31]
                 };

endmodule
