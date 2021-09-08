//synopsys translate_off
`include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_dp4.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sum4.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_sum3.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_addsub.v"
`include "/usr/synthesis/dw/sim_ver/DW_ifp_addsub.v"
`include "/usr/synthesis/dw/sim_ver/DW_fp_ifp_conv.v"
`include "/usr/synthesis/dw/sim_ver/DW_ifp_fp_conv.v"
`include "/usr/synthesis/dw/sim_ver/DW_ifp_mult.v"
//synopsys translate_on
module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_d,
	in_valid_t,
	in_valid_w1,
	in_valid_w2,
	data_point,
	target,
	weight1,
	weight2,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_d, in_valid_t, in_valid_w1, in_valid_w2;
input [inst_sig_width+inst_exp_width:0] data_point, target;
input [inst_sig_width+inst_exp_width:0] weight1, weight2;
output reg	out_valid;
output wire [inst_sig_width+inst_exp_width:0] out;


//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
parameter [2:0] ST_IDLE     =   'd0,
                ST_INPUT    =   'd1,
                ST_F1       =   'd2;
reg [2:0]   cs;

reg [31:0] weight1_arr  [11:0];
reg [31:0] weight2_arr  [2:0];
reg [31:0] input_arr    [3:0];
reg [31:0] target_in         ;

integer i;
reg [3:0] weight1_cnt;
reg [1:0] weight2_cnt;
reg [1:0] input_cnt;
reg [1:0] f1_cnt;

wire [31:0] out11;
wire [7:0] status;

///////////////////////////
//  Cycle 0 : input & mult
////////////////////////////
wire [31:0] output_m_11 ,output_m_12 ,output_m_13 ,output_m_14;
wire [31:0] output_m_21 ,output_m_22 ,output_m_23 ,output_m_24;
wire [31:0] output_m_31 ,output_m_32 ,output_m_33 ,output_m_34;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M11( .a(input_arr[0]), .b(weight1_arr[0 ]), .rnd(3'b000), .z(output_m_11), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M12( .a(input_arr[1]), .b(weight1_arr[1 ]), .rnd(3'b000), .z(output_m_12), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M13( .a(input_arr[2]), .b(weight1_arr[2 ]), .rnd(3'b000), .z(output_m_13), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M14( .a(data_point  ), .b(weight1_arr[3 ]), .rnd(3'b000), .z(output_m_14), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M21( .a(input_arr[0]), .b(weight1_arr[4 ]), .rnd(3'b000), .z(output_m_21), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M22( .a(input_arr[1]), .b(weight1_arr[5 ]), .rnd(3'b000), .z(output_m_22), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M23( .a(input_arr[2]), .b(weight1_arr[6 ]), .rnd(3'b000), .z(output_m_23), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M24( .a(data_point  ), .b(weight1_arr[7 ]), .rnd(3'b000), .z(output_m_24), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M31( .a(input_arr[0]), .b(weight1_arr[8 ]), .rnd(3'b000), .z(output_m_31), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M32( .a(input_arr[1]), .b(weight1_arr[9 ]), .rnd(3'b000), .z(output_m_32), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M33( .a(input_arr[2]), .b(weight1_arr[10]), .rnd(3'b000), .z(output_m_33), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M34( .a(data_point  ), .b(weight1_arr[11]), .rnd(3'b000), .z(output_m_34), .status(status) );
reg [31:0] output_m_11_r ,output_m_12_r ,output_m_13_r ,output_m_14_r;
reg [31:0] output_m_21_r ,output_m_22_r ,output_m_23_r ,output_m_24_r;
reg [31:0] output_m_31_r ,output_m_32_r ,output_m_33_r ,output_m_34_r;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        output_m_11_r <= 'd0; 
        output_m_12_r <= 'd0; 
        output_m_13_r <= 'd0; 
        output_m_14_r <= 'd0; 
        output_m_21_r <= 'd0; 
        output_m_22_r <= 'd0; 
        output_m_23_r <= 'd0; 
        output_m_24_r <= 'd0; 
        output_m_31_r <= 'd0; 
        output_m_32_r <= 'd0; 
        output_m_33_r <= 'd0; 
        output_m_34_r <= 'd0; 
    end else if(input_cnt == 'd3) begin
        output_m_11_r <= output_m_11; 
        output_m_12_r <= output_m_12; 
        output_m_13_r <= output_m_13; 
        output_m_14_r <= output_m_14; 
        output_m_21_r <= output_m_21; 
        output_m_22_r <= output_m_22; 
        output_m_23_r <= output_m_23; 
        output_m_24_r <= output_m_24; 
        output_m_31_r <= output_m_31; 
        output_m_32_r <= output_m_32; 
        output_m_33_r <= output_m_33; 
        output_m_34_r <= output_m_34; 
    end
end

//////////////////////
//  Cycle 1 : 4-1 * 3
///////////////////////
wire [31:0] output_a_1 ,output_a_2 ,output_a_3;
DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
    A11 (.a(output_m_11_r),.b(output_m_12_r),.c(output_m_13_r),.d(output_m_14_r),.rnd(3'b000),.z(output_a_1),.status(status) );
DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
    A12 (.a(output_m_21_r),.b(output_m_22_r),.c(output_m_23_r),.d(output_m_24_r),.rnd(3'b000),.z(output_a_2),.status(status) );
DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
    A13 (.a(output_m_31_r),.b(output_m_32_r),.c(output_m_33_r),.d(output_m_34_r),.rnd(3'b000),.z(output_a_3),.status(status) );
//wire [31:0] output_a_1 ,output_a_2 ,output_a_3;
//DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
//    A11 (.a(output_m_11),.b(output_m_12),.c(output_m_13),.d(output_m_14),.rnd(3'b000),.z(output_a_1),.status(status) );
//DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
//    A12 (.a(output_m_21),.b(output_m_22),.c(output_m_23),.d(output_m_24),.rnd(3'b000),.z(output_a_2),.status(status) );
//DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
//    A13 (.a(output_m_31),.b(output_m_32),.c(output_m_33),.d(output_m_34),.rnd(3'b000),.z(output_a_3),.status(status) );
//reg [31:0] output_a_1_r ,output_a_2_r ,output_a_3_r;
//always@(posedge clk or negedge rst_n)begin
//    if(!rst_n)begin
//        output_a_1_r <= 'd0; 
//        output_a_2_r <= 'd0; 
//        output_a_3_r <= 'd0; 
//    end else if(input_cnt == 'd3) begin
//        output_a_1_r <= output_a_1; 
//        output_a_2_r <= output_a_2; 
//        output_a_3_r <= output_a_3; 
//    end
//end

//Relu
////////////////////////
wire [31:0] output_r_1 = (output_a_1[31])? 0 : output_a_1;
wire [31:0] output_r_2 = (output_a_2[31])? 0 : output_a_2;
wire [31:0] output_r_3 = (output_a_3[31])? 0 : output_a_3;

//Mult
////////////////////////
wire [31:0] output_m2_1 ,output_m2_2 ,output_m2_3;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M211( .a(output_r_1), .b(weight2_arr[0]), .rnd(3'b000), .z(output_m2_1), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M212( .a(output_r_2), .b(weight2_arr[1]), .rnd(3'b000), .z(output_m2_2), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M213( .a(output_r_3), .b(weight2_arr[2]), .rnd(3'b000), .z(output_m2_3), .status(status) );
reg [31:0] output_m2_1_r ,output_m2_2_r ,output_m2_3_r;
reg drelu_h1 ,drelu_h2 ,drelu_h3;
reg [31:0] output_r_1_r ,output_r_2_r ,output_r_3_r;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        output_m2_1_r <= 'd0; 
        output_m2_2_r <= 'd0; 
        output_m2_3_r <= 'd0; 
        drelu_h1 <= 'd0;
        drelu_h2 <= 'd0;
        drelu_h3 <= 'd0;
        output_r_1_r <= 'd0; 
        output_r_2_r <= 'd0; 
        output_r_3_r <= 'd0; 
    end else if(f1_cnt == 'd0) begin
        output_m2_1_r <= output_m2_1; 
        output_m2_2_r <= output_m2_2; 
        output_m2_3_r <= output_m2_3; 
        drelu_h1 <= output_a_1[31];
        drelu_h2 <= output_a_2[31];
        drelu_h3 <= output_a_3[31];
        output_r_1_r <= output_r_1; 
        output_r_2_r <= output_r_2; 
        output_r_3_r <= output_r_3; 
    end
end

//////////////////////////////////
//  Cycle 2 : 3-1 && minus target
///////////////////////////////////

//for output
wire [31:0] output_a2_0;
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
    A20 (.a(output_m2_1_r),.b(output_m2_2_r),.c(output_m2_3_r),.rnd(3'b000),.z(output_a2_0),.status(status) );

wire [31:0] output_a2_1;
DW_fp_sum4 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 'b0)
    A21 (.a(output_m2_1_r),.b(output_m2_2_r),.c(output_m2_3_r),.d({~target_in[31],target_in[30:0]}),.rnd(3'b000),.z(output_a2_1),.status(status) );
//    A21 (.a(output_m2_1),.b(output_m2_2),.c(output_m2_3),.rnd(3'b000),.z(output_a2_1),.status(status) );
//reg  [31:0] output_a2_1_r;
//always@(posedge clk or negedge rst_n)begin
//    if(!rst_n)
//        output_a2_1_r <= 'd0;
//    else
//        output_a2_1_r <= output_a2_1;
//end

//Mult
////////////////////////
wire [31:0] output_m3_1 ,output_m3_2 ,output_m3_3;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M311( .a(output_a2_1), .b(weight2_arr[0]), .rnd(3'b000), .z(output_m3_1), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M312( .a(output_a2_1), .b(weight2_arr[1]), .rnd(3'b000), .z(output_m3_2), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M313( .a(output_a2_1), .b(weight2_arr[2]), .rnd(3'b000), .z(output_m3_3), .status(status) );
reg [31:0] output_m3_1_r ,output_m3_2_r ,output_m3_3_r;
reg [31:0] output_a2_1_r;
reg [31:0] output_r_1_r2 ,output_r_2_r2 ,output_r_3_r2;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        output_m3_1_r <= 'd0; 
        output_m3_2_r <= 'd0; 
        output_m3_3_r <= 'd0; 
        output_a2_1_r <= 'd0; 
        output_r_1_r2 <= 'd0; 
        output_r_2_r2 <= 'd0; 
        output_r_3_r2 <= 'd0; 
    end else if(f1_cnt == 'd1) begin
        output_m3_1_r <= (drelu_h1)? 0 : output_m3_1; 
        output_m3_2_r <= (drelu_h2)? 0 : output_m3_2; 
        output_m3_3_r <= (drelu_h3)? 0 : output_m3_3;
        output_a2_1_r <= output_a2_1; 
        output_r_1_r2 <= output_r_1_r; 
        output_r_2_r2 <= output_r_2_r; 
        output_r_3_r2 <= output_r_3_r; 
    end
end

wire [31:0] learning_rate = 32'h3A83126F;

///////////////////////////////////
///  Cycle 3 : Mult x Mult x minux
////////////////////////////////////
wire [31:0] output_m4_1;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M411( .a(learning_rate), .b(output_a2_1_r), .rnd(3'b000), .z(output_m4_1), .status(status) );
wire [31:0] output_m5_1 ,output_m5_2 ,output_m5_3;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M51( .a(output_m4_1), .b(output_r_1_r2), .rnd(3'b000), .z(output_m5_1), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M52( .a(output_m4_1), .b(output_r_2_r2), .rnd(3'b000), .z(output_m5_2), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M53( .a(output_m4_1), .b(output_r_3_r2), .rnd(3'b000), .z(output_m5_3), .status(status) );

wire [31:0] output_m4_21,output_m4_22,output_m4_23;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M421( .a(learning_rate), .b(output_m3_1_r), .rnd(3'b000), .z(output_m4_21), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M422( .a(learning_rate), .b(output_m3_2_r), .rnd(3'b000), .z(output_m4_22), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M423( .a(learning_rate), .b(output_m3_3_r), .rnd(3'b000), .z(output_m4_23), .status(status) );

wire [31:0] output_m5_11 ,output_m5_12 ,output_m5_13,output_m5_14;
wire [31:0] output_m5_21 ,output_m5_22 ,output_m5_23,output_m5_24;
wire [31:0] output_m5_31 ,output_m5_32 ,output_m5_33,output_m5_34;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M511( .a(output_m4_21), .b(input_arr[0]), .rnd(3'b000), .z(output_m5_11), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M512( .a(output_m4_21), .b(input_arr[1]), .rnd(3'b000), .z(output_m5_12), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M513( .a(output_m4_21), .b(input_arr[2]), .rnd(3'b000), .z(output_m5_13), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M514( .a(output_m4_21), .b(input_arr[3]), .rnd(3'b000), .z(output_m5_14), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M521( .a(output_m4_22), .b(input_arr[0]), .rnd(3'b000), .z(output_m5_21), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M522( .a(output_m4_22), .b(input_arr[1]), .rnd(3'b000), .z(output_m5_22), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M523( .a(output_m4_22), .b(input_arr[2]), .rnd(3'b000), .z(output_m5_23), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M524( .a(output_m4_22), .b(input_arr[3]), .rnd(3'b000), .z(output_m5_24), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M531( .a(output_m4_23), .b(input_arr[0]), .rnd(3'b000), .z(output_m5_31), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M532( .a(output_m4_23), .b(input_arr[1]), .rnd(3'b000), .z(output_m5_32), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M533( .a(output_m4_23), .b(input_arr[2]), .rnd(3'b000), .z(output_m5_33), .status(status) );
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
    M534( .a(output_m4_23), .b(input_arr[3]), .rnd(3'b000), .z(output_m5_34), .status(status) );

wire [31:0] output_a3_1,output_a3_2,output_a3_3;
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    A31 (.a({~output_m5_1[31],output_m5_1[30:0]}),.b(weight2_arr[0]),.rnd(3'b000),.z(output_a3_1),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    A32 (.a({~output_m5_2[31],output_m5_2[30:0]}),.b(weight2_arr[1]),.rnd(3'b000),.z(output_a3_2),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    A33 (.a({~output_m5_3[31],output_m5_3[30:0]}),.b(weight2_arr[2]),.rnd(3'b000),.z(output_a3_3),.status(status) );
wire [31:0] output_a3_11,output_a3_12,output_a3_13,output_a3_14;
wire [31:0] output_a3_21,output_a3_22,output_a3_23,output_a3_24;
wire [31:0] output_a3_31,output_a3_32,output_a3_33,output_a3_34;
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    A311 (.a({~output_m5_11[31],output_m5_11[30:0]}),.b(weight1_arr[0 ]),.rnd(3'b000),.z(output_a3_11),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A312 (.a({~output_m5_12[31],output_m5_12[30:0]}),.b(weight1_arr[1 ]),.rnd(3'b000),.z(output_a3_12),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A313 (.a({~output_m5_13[31],output_m5_13[30:0]}),.b(weight1_arr[2 ]),.rnd(3'b000),.z(output_a3_13),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A314 (.a({~output_m5_14[31],output_m5_14[30:0]}),.b(weight1_arr[3 ]),.rnd(3'b000),.z(output_a3_14),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A321 (.a({~output_m5_21[31],output_m5_21[30:0]}),.b(weight1_arr[4 ]),.rnd(3'b000),.z(output_a3_21),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                                                                                   
    A322 (.a({~output_m5_22[31],output_m5_22[30:0]}),.b(weight1_arr[5 ]),.rnd(3'b000),.z(output_a3_22),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A323 (.a({~output_m5_23[31],output_m5_23[30:0]}),.b(weight1_arr[6 ]),.rnd(3'b000),.z(output_a3_23),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A324 (.a({~output_m5_24[31],output_m5_24[30:0]}),.b(weight1_arr[7 ]),.rnd(3'b000),.z(output_a3_24),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A331 (.a({~output_m5_31[31],output_m5_31[30:0]}),.b(weight1_arr[8 ]),.rnd(3'b000),.z(output_a3_31),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A332 (.a({~output_m5_32[31],output_m5_32[30:0]}),.b(weight1_arr[9 ]),.rnd(3'b000),.z(output_a3_32),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A333 (.a({~output_m5_33[31],output_m5_33[30:0]}),.b(weight1_arr[10]),.rnd(3'b000),.z(output_a3_33),.status(status) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)                                           
    A334 (.a({~output_m5_34[31],output_m5_34[30:0]}),.b(weight1_arr[11]),.rnd(3'b000),.z(output_a3_34),.status(status) );


///////////
//  FSM  //
///////////
integer run_cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        cs <= ST_IDLE;
        run_cnt <= 0;
    end else begin
        case(cs)
            ST_IDLE     :if(in_valid_d)     cs <= ST_INPUT;
            ST_INPUT    :if(input_cnt == 3) begin cs <= ST_F1;     run_cnt <= run_cnt + 1;end
            ST_F1       :if(f1_cnt == 'd2)  cs <= ST_IDLE;
        endcase
    end
end
        
/////////////
//  INPUT  //
/////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 12;i = i + 1)begin
            weight1_arr[i] <= 'd0;
        end
        weight1_cnt <= 'd0;
    end else if(in_valid_w1) begin
        weight1_arr[weight1_cnt] <= weight1;
        weight1_cnt <= weight1_cnt + 1;
    end else if(f1_cnt == 'd2) begin
        weight1_arr[0] <= output_a3_11;
        weight1_arr[1] <= output_a3_12;
        weight1_arr[2] <= output_a3_13;
        weight1_arr[3] <= output_a3_14;
        weight1_arr[4] <= output_a3_21;
        weight1_arr[5] <= output_a3_22;
        weight1_arr[6] <= output_a3_23;
        weight1_arr[7] <= output_a3_24;
        weight1_arr[8] <= output_a3_31;
        weight1_arr[9] <= output_a3_32;
        weight1_arr[10] <= output_a3_33;
        weight1_arr[11] <= output_a3_34;
    end else begin
        weight1_cnt <= 'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 3;i = i + 1)begin
            weight2_arr[i] <= 'd0;
        end
        weight2_cnt <= 'd0;
    end else if(in_valid_w2) begin
        weight2_arr[weight2_cnt] <= weight2;
        weight2_cnt <= weight2_cnt + 1;
    end else if(f1_cnt == 'd2) begin
        weight2_arr[0] <= output_a3_1;
        weight2_arr[1] <= output_a3_2;
        weight2_arr[2] <= output_a3_3;
    end else begin
        weight2_cnt <= 'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 4;i = i + 1)begin
            input_arr[i] <= 'd0;
        end
        input_cnt <= 'd0;
    end else if(in_valid_d) begin
        input_arr[input_cnt] <= data_point;
        input_cnt <= input_cnt + 1;
    end else begin
        input_cnt <= 'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        target_in <= 'd0;
    end else if(in_valid_t) begin
        target_in <= target;
    end
end

//////////
//  F1  //
//////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        f1_cnt <= 'd0;
    end else if(cs == ST_F1) begin
        f1_cnt <= f1_cnt + 1;
    end else begin
        f1_cnt <= 'd0;
    end
end

//---------------------------------------------------------------------
//   Output
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid <= 'd0;
    end else if(f1_cnt == 1) begin
        out_valid <= 'd1;
    end else
        out_valid <= 'd0;
end

assign out = (f1_cnt == 2)? output_a2_0 : 0 ;
//always@(posedge clk or negedge rst_n)begin
//    if(!rst_n)begin
//        out <= 'd0;
//    end else if(cs == ST_OUT) begin
//        out <= output_a3_34;
//    end else
//        out <= 'd0;
//end


endmodule

//---------------------------------------------------------------------
//   DesignWare
//---------------------------------------------------------------------

