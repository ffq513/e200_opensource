                                                                       
`include "e203_defines.v"


module e203_exu_dsp_adder (

  input  dsp_req_addsub_i,
  input  dsp_req_sub_en_i,

  input  [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_op1_i   ,
  input  [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_op2_i   , 
  input  [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_op1_i,
  input  [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_op2_i,

  output [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_res_o   ,
  output [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_res_o 


  );

  `ifdef E203_XLEN_IS_32
      
  `else
      !!! ERROR: There must be something wrong, our core must be 32bits wide !!!
  `endif


  
  
  
  

  localparam BIGLIT_ADDER_MUX_WIDTH = ((`E203_DSP_BIGADDER_WIDTH*2)+(`E203_DSP_LITADDER_WIDTH*2)+1); 

  wire mux_sub_en;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] mux_op1  ;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] mux_op2  ; 
  wire [`E203_DSP_LITADDER_WIDTH-1:0] mux_op1_1;
  wire [`E203_DSP_LITADDER_WIDTH-1:0] mux_op2_1;



  assign  {
    mux_op1
   ,mux_op2
   ,mux_op1_1
   ,mux_op2_1
   ,mux_sub_en
    }
    = 
        ({BIGLIT_ADDER_MUX_WIDTH{dsp_req_addsub_i}} & {
             adder_big_op1_i   
            ,adder_big_op2_i   
            ,adder_little_op1_i
            ,adder_little_op2_i
            ,dsp_req_sub_en_i
          })
        ;

     
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_in1 = mux_op1;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_in2 = mux_op2;
  wire                             adder_big_cin = mux_sub_en;
  wire [`E203_DSP_BIGADDER_WIDTH-1:0] adder_big_res = adder_big_in1 + adder_big_in2 + adder_big_cin;

  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_in1 = mux_op1_1;
  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_in2 = mux_op2_1;
  wire                             adder_little_cin = adder_big_res[`E203_DSP_BIGADDER_WIDTH-1] ;
  wire [`E203_DSP_LITADDER_WIDTH-1:0] adder_little_res = adder_little_in1 + adder_little_in2 + adder_little_cin;

  assign adder_big_res_o    = adder_big_res    ;
  assign adder_little_res_o = adder_little_res ;

endmodule                                  
