
                                                                      
`include "e203_defines.v"

module e203_dynamic_sat(
  input  [`E203_XLEN-1:0]   dsat_op_i      ,     
  input  [`E203_XLEN-1:0]   dsat32_cmp_t   ,     
  input  [`E203_XLEN-1:0]   dsat32_cmp_b   ,     
  output                    dsat32_t_ov    ,     
  output                    dsat32_b_ov    ,     
  output [1:0]              dsat16_t_ov    ,     
  output [1:0]              dsat16_b_ov    ,     
  output [3:0]              dsat8_t_ov     ,     
  output [3:0]              dsat8_b_ov           

);

wire [`E203_XLEN-1:0] dsat_op1 = dsat_op_i;
wire [15:0] dsat16_cmp_t = dsat32_cmp_t[15:0];
wire [15:0] dsat16_cmp_b = dsat32_cmp_b[15:0];
wire [7:0]  dsat8_cmp_t = dsat32_cmp_t[7:0];     
wire [7:0]  dsat8_cmp_b = dsat32_cmp_b[7:0];     

wire [`E203_XLEN-1:0] dsat32_cmp_t_inv = dsat32_cmp_b;
wire [`E203_XLEN-1:0] dsat32_op2_b_inv = dsat32_cmp_t;

wire [`E203_XLEN-1:0] dsat32_word_cmp_t = dsat32_cmp_t_inv & dsat_op1[31:0];
wire dsat32_byte0_or = (|dsat32_word_cmp_t[7:0]);
wire dsat32_byte1_or = (|dsat32_word_cmp_t[15:8]);
wire dsat32_byte2_or = (|dsat32_word_cmp_t[23:16]);
wire dsat32_byte3_or = (|dsat32_word_cmp_t[31:24]);

assign dsat32_t_ov = (dsat32_byte0_or | dsat32_byte1_or | dsat32_byte2_or | dsat32_byte3_or) & ~dsat_op1[31];

wire [`E203_XLEN-1:0] dsat32_word_cmp_b = (dsat32_cmp_b & dsat_op1[31:0]) | dsat32_op2_b_inv;
wire dsat32_byte0_and = (&dsat32_word_cmp_b[7:0]);
wire dsat32_byte1_and = (&dsat32_word_cmp_b[15:8]);
wire dsat32_byte2_and = (&dsat32_word_cmp_b[23:16]);
wire dsat32_byte3_and = (&dsat32_word_cmp_b[31:24]);

assign dsat32_b_ov = ~(dsat32_byte0_and & dsat32_byte1_and & dsat32_byte2_and & dsat32_byte3_and) & dsat_op1[31];

wire [15:0] dsat16_cmp_t_inv = dsat16_cmp_b;
wire [15:0] dsat16_cmp_b_inv = dsat16_cmp_t;

assign dsat16_t_ov[0] = (dsat32_byte0_or | dsat32_byte1_or) & ~dsat_op1[15];     
assign dsat16_b_ov[0] = ~(dsat32_byte0_and & dsat32_byte1_and) & dsat_op1[15];   

wire [15:0] dsat16_half1_cmp_t = dsat16_cmp_t_inv & dsat_op1[31:16];
assign dsat16_t_ov[1] = (|dsat16_half1_cmp_t) & ~dsat_op1[31];                   
wire [15:0] dsat16_half1_cmp_b = (dsat16_cmp_b & dsat_op1[31:16]) | dsat16_cmp_b_inv;
assign dsat16_b_ov[1] = ~(&dsat16_half1_cmp_b) & dsat_op1[31];                   

wire [7:0] dsat8_cmp_t_inv = dsat8_cmp_b;       
wire [7:0] dsat8_cmp_b_inv = dsat8_cmp_t;       

assign dsat8_t_ov[0] = (dsat32_byte0_or) & ~dsat_op1[7];                          
assign dsat8_b_ov[0] = ~(dsat32_byte0_and) & dsat_op1[7];                         

wire [7:0] dsat8_byte1_cmp_t =  dsat8_cmp_t_inv & dsat_op1[15:8];
assign dsat8_t_ov[1] = (|dsat8_byte1_cmp_t) & ~dsat_op1[15];                      
wire [7:0] dsat8_byte1_cmp_b = (dsat8_cmp_b & dsat_op1[15:8]) | dsat8_cmp_b_inv;
assign dsat8_b_ov[1] = ~(&dsat8_byte1_cmp_b) & dsat_op1[15];                      

wire [7:0] dsat8_byte2_cmp_t =  dsat8_cmp_t_inv & dsat_op1[23:16];
assign dsat8_t_ov[2] = (|dsat8_byte2_cmp_t) & ~dsat_op1[23];                      
wire [7:0] dsat8_byte2_cmp_b = (dsat8_cmp_b & dsat_op1[23:16]) | dsat8_cmp_b_inv;
assign dsat8_b_ov[2] = ~(&dsat8_byte2_cmp_b) & dsat_op1[23];                      

wire [7:0] dsat8_byte3_cmp_t =  dsat8_cmp_t_inv & dsat_op1[31:24];
assign dsat8_t_ov[3] = (|dsat8_byte3_cmp_t) & ~dsat_op1[31];                      
wire [7:0] dsat8_byte3_cmp_b = (dsat8_cmp_b & dsat_op1[31:24]) | dsat8_cmp_b_inv;
assign dsat8_b_ov[3] = ~(&dsat8_byte3_cmp_b) & dsat_op1[31];                      

endmodule
