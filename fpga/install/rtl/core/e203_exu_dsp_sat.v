                                                                        

`include "e203_defines.v"


module e203_exu_dsp_sat(

  

  input[`E203_DSP_BIGADDER_WIDTH-1:0]  dsp_sat_idata_i ,
  input[`E203_DSP_LITADDER_WIDTH-1:0]  dsp_sat_idata_1_i ,
  input[2:0]   dsp_sat_dform_i  , 
  input[3:0]   dsp_sat_type_i   , 
  input        dsp_sat_usflag_i , 
  input        dsp_sat_enable_i ,
  output[`E203_DSP_BIGADDER_WIDTH-1:0] dsp_sat_odata_o   ,
  output[`E203_DSP_LITADDER_WIDTH-1:0] dsp_sat_odata_1_o  ,
  output       dsp_sat_ov_o      


  );

  wire [`E203_DSP_BIGADDER_WIDTH-1:0] op_idata;
  wire [`E203_DSP_LITADDER_WIDTH-1:0] op_idata_1;
  wire [2:0]  sat_dfmt;
  wire [3:0]  sat_type;
  wire        sign_sel;
  
  
  
  

  localparam DPATH_MUX_WIDTH = `E203_DSP_BIGADDER_WIDTH+`E203_DSP_LITADDER_WIDTH+3+4+1;

  assign  {
    op_idata
   ,op_idata_1
   ,sat_dfmt      
   ,sat_type      
   ,sign_sel     
    }
    = 
        ({DPATH_MUX_WIDTH{dsp_sat_enable_i}} & {
             dsp_sat_idata_i 
            ,dsp_sat_idata_1_i 
            ,dsp_sat_dform_i 
            ,dsp_sat_type_i 
            ,dsp_sat_usflag_i      
           })
        ;


  
  
  
  
  wire sat_q7_dfmt8 = (sat_type == 4'b0000) & (sat_dfmt == 3'b000) & sign_sel;
  wire sat_ov_8_byt1_g7f = ~op_idata[38] & op_idata[37];
  wire sat_ov_8_byt2_g7f = ~op_idata[28] & op_idata[27];
  wire sat_ov_8_byt3_g7f = ~op_idata[18] & op_idata[17];
  wire sat_ov_8_byt4_g7f = ~op_idata[8 ] & op_idata[7 ];
  
  wire sat_ov_8_byt1_l80 = op_idata[38] & ~op_idata[37];
  wire sat_ov_8_byt2_l80 = op_idata[28] & ~op_idata[27];
  wire sat_ov_8_byt3_l80 = op_idata[18] & ~op_idata[17];
  wire sat_ov_8_byt4_l80 = op_idata[8 ] & ~op_idata[7 ];

  wire[31:0] sat_q7d8_res = {32{sat_q7_dfmt8}} &  
       {({1'b0,{7{sat_ov_8_byt1_g7f}}}) | ({8{sat_ov_8_byt1_l80}} & 8'h80) | ({8{~sat_ov_8_byt1_g7f & ~sat_ov_8_byt1_l80}} & op_idata[37:30]),
        ({1'b0,{7{sat_ov_8_byt2_g7f}}}) | ({8{sat_ov_8_byt2_l80}} & 8'h80) | ({8{~sat_ov_8_byt2_g7f & ~sat_ov_8_byt2_l80}} & op_idata[27:20]),
        ({1'b0,{7{sat_ov_8_byt3_g7f}}}) | ({8{sat_ov_8_byt3_l80}} & 8'h80) | ({8{~sat_ov_8_byt3_g7f & ~sat_ov_8_byt3_l80}} & op_idata[17:10]),
        ({1'b0,{7{sat_ov_8_byt4_g7f}}}) | ({8{sat_ov_8_byt4_l80}} & 8'h80) | ({8{~sat_ov_8_byt4_g7f & ~sat_ov_8_byt4_l80}} & op_idata[7 : 0])
                            };
  wire sat_q7d8_ov = sat_q7_dfmt8 & (sat_ov_8_byt1_g7f | sat_ov_8_byt2_g7f | sat_ov_8_byt3_g7f | sat_ov_8_byt4_g7f | 
                      sat_ov_8_byt1_l80 | sat_ov_8_byt2_l80 | sat_ov_8_byt3_l80 | sat_ov_8_byt4_l80);

  
  wire sat_u8_dfmt8 = (sat_type == 4'b0001) & (sat_dfmt == 3'b000) & sign_sel;
  wire[31:0] sat_u8d8_res = {32{sat_u8_dfmt8}} &
                            {({8{~(op_idata[38])}} & op_idata[37:30]),
                             ({8{~(op_idata[28])}} & op_idata[27:20]),
                             ({8{~(op_idata[18])}} & op_idata[17:10]),
                             ({8{~(op_idata[08])}} & op_idata[07:00])};

  wire sat_u8d8_ov = sat_u8_dfmt8 & (op_idata[38] | op_idata[28] |op_idata[18] |op_idata[8]);

  
  wire usat_u8_dfmt8 = (sat_type == 4'b0001) & (sat_dfmt == 3'b000) & ~sign_sel;
  wire[31:0] usat_u8d8_res = {32{usat_u8_dfmt8}} &
                             {({8{op_idata[38]}} | op_idata[37:30]),
                              ({8{op_idata[28]}} | op_idata[27:20]),
                              ({8{op_idata[18]}} | op_idata[17:10]),
                              ({8{op_idata[8 ]}} | op_idata[7 :0] )};
  wire usat_u8d8_ov = usat_u8_dfmt8 & (op_idata[38] | op_idata[28] |op_idata[18] |op_idata[8]);

  
  wire sat_q15_dfmt16 = (sat_type == 4'b0010) & (sat_dfmt == 3'b001) & sign_sel;
  
  wire sat_ov_hw0_g7fff = ~op_idata[36] & op_idata[35]; 
  wire sat_ov_hw1_g7fff = ~op_idata[16] & op_idata[15];
  
  wire sat_ov_hw0_l8000 = op_idata[36] & ~op_idata[35]; 
  wire sat_ov_hw1_l8000 = op_idata[16] & ~op_idata[15];
  wire[31:0] sat_q15d16_res = {32{sat_q15_dfmt16}} &
          {({1'b0,{15{sat_ov_hw0_g7fff}}}) | ({16{sat_ov_hw0_l8000}} & 16'h8000) | ({16{~sat_ov_hw0_g7fff & ~sat_ov_hw0_l8000}} & op_idata[35:20]),
           ({1'b0,{15{sat_ov_hw1_g7fff}}}) | ({16{sat_ov_hw1_l8000}} & 16'h8000) | ({16{~sat_ov_hw1_g7fff & ~sat_ov_hw1_l8000}} & op_idata[15:0 ])};
  wire sat_q15d16_ov = sat_q15_dfmt16 & (sat_ov_hw0_g7fff | sat_ov_hw1_g7fff | sat_ov_hw0_l8000 | sat_ov_hw1_l8000);


  
  wire usat_u16_dfmt16 = (sat_type == 4'b0011) & (sat_dfmt == 3'b001) & ~sign_sel;
  wire[31:0] usat_u16d16_res = {32{usat_u16_dfmt16}} &
                               {({16{op_idata[36]}} | op_idata[35:20]),({16{op_idata[16]}} | op_idata[15:0 ])};
  wire usat_u16d16_ov = usat_u16_dfmt16 & (op_idata[36] | op_idata[16]);
  
  
  wire sat_u16_dfmt16 = (sat_type == 4'b0011) & (sat_dfmt == 3'b001) & sign_sel;
  wire[31:0] sat_u16d16_res =  {32{sat_u16_dfmt16}} &
                               {({16{~(op_idata[36])}} & op_idata[35:20]),({16{~(op_idata[16])}} & op_idata[15:0 ])};
  wire sat_u16d16_ov = sat_u16_dfmt16 & (op_idata[36] | op_idata[16]);


  
  wire sat_kabs8_dfmt8 = (sat_type == 4'b0110) & (sat_dfmt == 3'b000);
  wire sat_kabs8_ov_byt3 = op_idata[38] & (~op_idata[37]);
  wire sat_kabs8_ov_byt2 = op_idata[28] & (~op_idata[27]);
  wire sat_kabs8_ov_byt1 = op_idata[18] & (~op_idata[17]);
  wire sat_kabs8_ov_byt0 = op_idata[ 8] & (~op_idata[ 7]);

  wire[31:0] sat_kabs8_res = {32{sat_kabs8_dfmt8}} & 
    {{1'b0,{7{sat_kabs8_ov_byt3}}} | ({8{op_idata[38] & op_idata[37]}} & (~op_idata[37:30])) | ({8{(~op_idata[38]) & (~op_idata[37])}} & op_idata[37:30]) ,
     {1'b0,{7{sat_kabs8_ov_byt2}}} | ({8{op_idata[28] & op_idata[27]}} & (~op_idata[27:20])) | ({8{(~op_idata[28]) & (~op_idata[27])}} & op_idata[27:20]) ,
     {1'b0,{7{sat_kabs8_ov_byt1}}} | ({8{op_idata[18] & op_idata[17]}} & (~op_idata[17:10])) | ({8{(~op_idata[18]) & (~op_idata[17])}} & op_idata[17:10]) ,
     {1'b0,{7{sat_kabs8_ov_byt0}}} | ({8{op_idata[ 8] & op_idata[ 7]}} & (~op_idata[7 :0 ])) | ({8{(~op_idata[ 8]) & (~op_idata[ 7])}} & op_idata[7 :0 ]) };
  wire sat_kabs8_ov = sat_kabs8_dfmt8 & (sat_kabs8_ov_byt3 | sat_kabs8_ov_byt2 |sat_kabs8_ov_byt1 |sat_kabs8_ov_byt0);

  
  wire sat_kabs16_dfmt16 = (sat_type == 4'b0110) & (sat_dfmt == 3'b001);
  wire sat_kabs16_ov_hw1 = op_idata[36] & (~op_idata[35]);
  wire sat_kabs16_ov_hw0 = op_idata[16] & (~op_idata[15]);
  wire[31:0] sat_kabs16_res =  {32{sat_kabs16_dfmt16}} &
    {{1'b0,{15{sat_kabs16_ov_hw1}}} | ({16{op_idata[36] & op_idata[35]}} & (~op_idata[35:20])) | ({16{(~op_idata[36]) & (~op_idata[35])}} & op_idata[35:20]),
     {1'b0,{15{sat_kabs16_ov_hw0}}} | ({16{op_idata[16] & op_idata[15]}} & (~op_idata[15:0 ])) | ({16{(~op_idata[16]) & (~op_idata[15])}} & op_idata[15:0 ])};
  wire sat_kabs16_ov = sat_kabs16_dfmt16 & (sat_kabs16_ov_hw1 | sat_kabs16_ov_hw0);

  
  
  wire sat_uxas_dfmt16 = (sat_type == 4'b0111) & (sat_dfmt == 3'b001);
  wire[31:0] sat_uxas_res = {32{sat_uxas_dfmt16}} &
                            {({16{op_idata[36]}} | op_idata[35:20]), ({16{~(op_idata[16])}} & op_idata[15:0 ])};
  wire sat_uxas_ov = sat_uxas_dfmt16 & (op_idata[36] | op_idata[16]);

  
  
  wire sat_uxsa_dfmt16 = (sat_type == 4'b1000) & (sat_dfmt == 3'b001);
  wire[31:0] sat_uxsa_res = {32{sat_uxsa_dfmt16}} &
                            {({16{~(op_idata[36])}} & op_idata[35:20]), ({16{op_idata[16]}} | op_idata[15:0 ])};  
  wire sat_uxsa_ov = sat_uxsa_dfmt16 & (op_idata[36] | op_idata[16]);


  
  wire sat_q15_dfmt32 = (sat_type == 4'b0010) & (sat_dfmt == 3'b010) & sign_sel;
  wire sat_ov_w0_g7fff = ~op_idata[32] &  (|op_idata[31:15]); 
  wire sat_ov_w0_l8000 =  op_idata[32] & ~(&op_idata[31:15]); 
  wire[31:0] sat_q15d32_res = {32{sat_q15_dfmt32}} &
          {({17'b0,{15{sat_ov_w0_g7fff}}}) 
         |({32{sat_ov_w0_l8000}} & 32'hffff8000) 
         |({32{~sat_ov_w0_g7fff & ~sat_ov_w0_l8000}} & {{16{op_idata[32]}},op_idata[15:0]})};
  wire sat_q15d32_ov = sat_q15_dfmt32 & (sat_ov_w0_g7fff | sat_ov_w0_l8000);

  
  wire sat_u16_dfmt32 = (sat_type == 4'b0011) & (sat_dfmt == 3'b010) & sign_sel;
  wire sat_ov_w0_gffff = ~op_idata[32] & (|op_idata[31:16]); 
  wire sat_ov_w0_l0000 =  op_idata[32]; 
  wire[31:0] sat_u16d32_res = {32{sat_u16_dfmt32}} &
          {({16'b0,{16{sat_ov_w0_gffff}}}) 
         | ({32{~sat_ov_w0_gffff & ~sat_ov_w0_l0000}} & {{16{op_idata[32]}}, op_idata[15:0]})};
  wire sat_u16d32_ov = sat_u16_dfmt32 & (sat_ov_w0_gffff | sat_ov_w0_l0000);

  
  wire usat_u16_dfmt32 = (sat_type == 4'b0011) & (sat_dfmt == 3'b010) & ~sign_sel;
  wire usat_ov_w0_gffff = (|op_idata[32:16]); 
  wire[31:0] usat_u16d32_res = {32{usat_u16_dfmt32}} &
          {({16'b0,{16{usat_ov_w0_gffff}}}) | ({32{~usat_ov_w0_gffff}} & {16'h0, op_idata[15:0]})};
  wire usat_u16d32_ov = usat_u16_dfmt32 & (usat_ov_w0_gffff);

  
  wire sat_q31_dfmt32 = (sat_type == 4'b0100) & (sat_dfmt == 3'b010) & sign_sel;
  wire sat_ov_w0_g7fffffff = ~op_idata[32] &  op_idata[31]; 
  wire sat_ov_w0_l80000000 =  op_idata[32] & ~op_idata[31]; 
  wire[31:0] sat_q31d32_res = {32{sat_q31_dfmt32}} &
           {({1'b0,{31{sat_ov_w0_g7fffffff}}}) 
          | ({32{sat_ov_w0_l80000000}} & 32'h80000000) 
          | ({32{~sat_ov_w0_g7fffffff & ~sat_ov_w0_l80000000}} & op_idata[31:0])};
  wire sat_q31d32_ov = sat_q31_dfmt32 & (sat_ov_w0_g7fffffff | sat_ov_w0_l80000000);

  
  wire sat_u32_dfmt32 = (sat_type == 4'b0101) & (sat_dfmt == 3'b010) & sign_sel;
  wire[31:0] sat_u32d32_res = {32{sat_u32_dfmt32}} & {({32{ ~op_idata[32]}} & op_idata[31:0])};
  wire sat_u32d32_ov = sat_u32_dfmt32 & (op_idata[32]);

  
  wire usat_u32_dfmt32 = (sat_type == 4'b0101) & (sat_dfmt == 3'b010) & ~sign_sel;
  wire[31:0] usat_u32d32_res = {32{usat_u32_dfmt32}} & 
          {({32{op_idata[32]}}) | ({32{~op_idata[32]}} & op_idata[31:0])};
  wire usat_u32d32_ov = usat_u32_dfmt32 & op_idata[32];

  
  wire sat_kabsw_dfmt32 = (sat_type == 4'b0110) & (sat_dfmt == 3'b010);
  wire sat_kabsw_ov_w0 = op_idata[32] & (~op_idata[31]);
  wire[31:0] sat_kabsw_res = {32{sat_kabsw_dfmt32}} &
       {{1'b0,{31{sat_kabsw_ov_w0}}} | ({32{op_idata[32] & op_idata[31]}} & (~op_idata[31:0 ])) | ({32{(~op_idata[32]) & (~op_idata[31])}} & op_idata[31:0 ])};
  wire sat_kabsw_ov = sat_kabsw_dfmt32 & (sat_kabsw_ov_w0);

  
  wire sat_q63_dfmt64 = (sat_type == 4'b1001) & (sat_dfmt == 3'b011) & sign_sel;
  wire sat_ov_dw0_gtmax = ~op_idata_1[25] &  op_idata_1[24]; 
  wire sat_ov_dw0_ltmin =  op_idata_1[25] & ~op_idata_1[24]; 
  wire[`E203_DSP_BIGADDER_WIDTH-1:0] sat_q63d64_res = {`E203_DSP_BIGADDER_WIDTH{sat_q63_dfmt64}} &
           {({`E203_DSP_BIGADDER_WIDTH{sat_ov_dw0_gtmax}}) 
          | ({`E203_DSP_BIGADDER_WIDTH{sat_ov_dw0_ltmin}} & {`E203_DSP_BIGADDER_WIDTH{1'b0}}) 
          | ({`E203_DSP_BIGADDER_WIDTH{(~sat_ov_dw0_gtmax & ~sat_ov_dw0_ltmin)}} & op_idata)};
  wire[`E203_DSP_LITADDER_WIDTH-1:0] sat_q63d64_res_1 = {`E203_DSP_LITADDER_WIDTH{sat_q63_dfmt64}} &
           {({`E203_DSP_LITADDER_WIDTH{sat_ov_dw0_gtmax}} & {2'b00,{`E203_DSP_LITADDER_WIDTH-2{1'b1}}}) 
          | ({`E203_DSP_LITADDER_WIDTH{sat_ov_dw0_ltmin}} & {2'b11,{`E203_DSP_LITADDER_WIDTH-2{1'b0}}}) 
          | ({`E203_DSP_LITADDER_WIDTH{(~sat_ov_dw0_gtmax & ~sat_ov_dw0_ltmin)}} & op_idata_1)};
  wire sat_q63d64_ov = sat_q63_dfmt64 & (sat_ov_dw0_gtmax | sat_ov_dw0_ltmin);

  
  wire sat_u64_dfmt64 = (sat_type == 4'b1010) & (sat_dfmt == 3'b011) & sign_sel;
  wire[`E203_DSP_BIGADDER_WIDTH-1:0] sat_u64d64_res = {`E203_DSP_BIGADDER_WIDTH{sat_u64_dfmt64}} &
           {({`E203_DSP_BIGADDER_WIDTH{op_idata_1[25]}} & {`E203_DSP_BIGADDER_WIDTH{1'b0}}) 
          | ({`E203_DSP_BIGADDER_WIDTH{~op_idata_1[25]}} & op_idata)};
  wire[`E203_DSP_LITADDER_WIDTH-1:0] sat_u64d64_res_1 = {`E203_DSP_LITADDER_WIDTH{sat_u64_dfmt64}} &
           {({`E203_DSP_LITADDER_WIDTH{op_idata_1[25]}} & {`E203_DSP_LITADDER_WIDTH{1'b0}}) 
          | ({`E203_DSP_LITADDER_WIDTH{(~op_idata_1[25])}} & op_idata_1)};
  wire sat_u64d64_ov = sat_u64_dfmt64 & (op_idata_1[25]);

  
  wire usat_u64_dfmt64 = (sat_type == 4'b1010) & (sat_dfmt == 3'b011) & ~sign_sel;
  wire[`E203_DSP_BIGADDER_WIDTH-1:0] usat_u64d64_res = {`E203_DSP_BIGADDER_WIDTH{usat_u64_dfmt64}} &
           {({`E203_DSP_BIGADDER_WIDTH{op_idata_1[25]}} & {`E203_DSP_BIGADDER_WIDTH{1'b1}}) 
          | ({`E203_DSP_BIGADDER_WIDTH{~op_idata_1[25]}} & op_idata)};
  wire[`E203_DSP_LITADDER_WIDTH-1:0] usat_u64d64_res_1 = {`E203_DSP_LITADDER_WIDTH{usat_u64_dfmt64}} &
           {({`E203_DSP_LITADDER_WIDTH{op_idata_1[25]}} & {`E203_DSP_LITADDER_WIDTH{1'b1}}) 
          | ({`E203_DSP_LITADDER_WIDTH{(~op_idata_1[25])}} & op_idata_1)};
  wire usat_u64d64_ov = usat_u64_dfmt64 & (op_idata_1[25]);






  wire[`E203_DSP_BIGADDER_WIDTH-1:0] sat_res = 
          ({`E203_DSP_BIGADDER_WIDTH{usat_u8_dfmt8   }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},usat_u8d8_res})  
         |({`E203_DSP_BIGADDER_WIDTH{sat_q7_dfmt8    }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_q7d8_res})  
         |({`E203_DSP_BIGADDER_WIDTH{sat_u8_dfmt8    }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_u8d8_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_kabs8_dfmt8 }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_kabs8_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_q15_dfmt16  }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_q15d16_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{usat_u16_dfmt16 }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},usat_u16d16_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_u16_dfmt16  }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_u16d16_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_kabs16_dfmt16}}&  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_kabs16_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_uxas_dfmt16 }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_uxas_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_uxsa_dfmt16 }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_uxsa_res}) 
         |({`E203_DSP_BIGADDER_WIDTH{sat_q15_dfmt32 }}  &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_q15d32_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{sat_u16_dfmt32 }}  &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_u16d32_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{usat_u16_dfmt32 }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},usat_u16d32_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{sat_q31_dfmt32 }}  &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_q31d32_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{sat_u32_dfmt32 }}  &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_u32d32_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{usat_u32_dfmt32 }} &  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},usat_u32d32_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{sat_kabsw_dfmt32 }}&  {{(`E203_DSP_BIGADDER_WIDTH-32){1'b0}},sat_kabsw_res})                         
         |({`E203_DSP_BIGADDER_WIDTH{sat_q63_dfmt64 }}  &  sat_q63d64_res)                         
         |({`E203_DSP_BIGADDER_WIDTH{sat_u64_dfmt64 }}  &  sat_u64d64_res)                         
         |({`E203_DSP_BIGADDER_WIDTH{usat_u64_dfmt64}}  &  usat_u64d64_res)                         
         ;

  wire [`E203_DSP_LITADDER_WIDTH-1:0] sat_res_1 = 
          ({`E203_DSP_LITADDER_WIDTH{sat_q63_dfmt64 }}      &  sat_q63d64_res_1)                         
         |({`E203_DSP_LITADDER_WIDTH{sat_u64_dfmt64 }}      &  sat_u64d64_res_1)                         
         |({`E203_DSP_LITADDER_WIDTH{usat_u64_dfmt64}}      &  usat_u64d64_res_1) ;                       

  wire sat_ov = usat_u8d8_ov   
              | sat_q7d8_ov  
              | sat_u8d8_ov  
              | sat_kabs8_ov 
              | sat_q15d16_ov
              | usat_u16d16_ov 
              | sat_u16d16_ov
              | sat_kabs16_ov
              | sat_uxas_ov  
              | sat_uxsa_ov  
              | sat_q15d32_ov
              | sat_u16d32_ov
              | usat_u16d32_ov 
              | sat_q31d32_ov
              | sat_u32d32_ov
              | usat_u32d32_ov 
              | sat_kabsw_ov 
              | sat_q63d64_ov 
              | sat_u64d64_ov 
              | usat_u64d64_ov
                ;


            
            
            
assign dsp_sat_odata_o = sat_res;
assign dsp_sat_odata_1_o = sat_res_1;
assign dsp_sat_ov_o    = sat_ov ;

endmodule              
