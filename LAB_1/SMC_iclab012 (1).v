module SMC(
  // Input signals0308
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
output [9:0] out_n;         							// use this if using continuous assignment for out_n  // Ex: assign out_n = XXX;
//output reg [9:0] out_n; 								// use this if using procedure assignment for out_n   // Ex: always@(*) begin out_n = XXX; end

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

wire [2:0] V_G1_0 = V_GS_0 - 1;
wire [2:0] V_G1_1 = V_GS_1 - 1;
wire [2:0] V_G1_2 = V_GS_2 - 1;
wire [2:0] V_G1_3 = V_GS_3 - 1;
wire [2:0] V_G1_4 = V_GS_4 - 1;
wire [2:0] V_G1_5 = V_GS_5 - 1;
wire [7:0] outig0,outig1,outig2,outig3,outig4,outig5;
wire [7:0] outsort0,outsort1,outsort2;
wire [6:0] nx3 = outsort0/3;
wire [6:0] ny3 = outsort1/3;
wire [6:0] nz3 = outsort2/3;

assign out_n = (mode[0])? (({nx3,1'b0}+nx3)+4*(ny3)+5*(nz3)) : (nx3+ny3+nz3);

//================================================================
//    DESIGN
//================================================================
// --------------------------------------------------
// write your design here
// --------------------------------------------------

GET_I_OR_G get_i_or_g0(.mode(mode[0]),.W(W_0),.G(V_G1_0),.D(V_DS_0),.out(outig0));
GET_I_OR_G get_i_or_g1(.mode(mode[0]),.W(W_1),.G(V_G1_1),.D(V_DS_1),.out(outig1));
GET_I_OR_G get_i_or_g2(.mode(mode[0]),.W(W_2),.G(V_G1_2),.D(V_DS_2),.out(outig2));
GET_I_OR_G get_i_or_g3(.mode(mode[0]),.W(W_3),.G(V_G1_3),.D(V_DS_3),.out(outig3));
GET_I_OR_G get_i_or_g4(.mode(mode[0]),.W(W_4),.G(V_G1_4),.D(V_DS_4),.out(outig4));
GET_I_OR_G get_i_or_g5(.mode(mode[0]),.W(W_5),.G(V_G1_5),.D(V_DS_5),.out(outig5));
SORT sort(.mode(mode[1]),.in0(outig0),.in1(outig1),.in2(outig2),.in3(outig3),.in4(outig4),.in5(outig5),.out0(outsort0),.out1(outsort1),.out2(outsort2));

endmodule



//================================================================
//   SUB MODULE
//================================================================

module GET_I_OR_G (mode,W,G,D,out);
input   mode;
input   [2:0]   W, G, D;
//max 252 wid8 (677)
output  [7:0]   out;

//max 36 wid6 (677)
reg     [5:0]   before_mul_w;
assign out = before_mul_w * W;

always@(*)begin
    case({mode,(G>D)})
        2'b01:before_mul_w = D*2;
        2'b00:before_mul_w = G*2;
        2'b10:before_mul_w = G*G;
        2'b11:before_mul_w = ((G*2)-D)*D;
    endcase
end
endmodule


module SORT(mode,in0,in1,in2,in3,in4,in5,out0,out1,out2); 
input mode;
input [7:0] in0,in1,in2,in3,in4,in5;
output[7:0] out0,out1,out2;

wire [7:0]  mid00,mid01,mid02,mid03,mid04,mid05,
            mid10,mid11,mid12,mid13,mid14,mid15,
            mid20,mid21,mid22,mid23,mid24,mid25,
            mid30,mid31,mid32,mid33,mid34,mid35,
            mid40,mid41,mid42,
            mid50,mid51,mid52,
            mid60,mid61,mid62,
            mid70,mid71,mid72;

wire cmp001 = in0 > in1;
wire cmp034 = in3 > in4;

wire cmp112 = mid01 > mid02;
wire cmp145 = mid04 > mid05;

wire cmp201 = mid10 > mid11;
wire cmp234 = mid13 > mid14;

wire cmp305 = mid20 > mid25;
wire cmp314 = mid21 > mid24;
wire cmp323 = mid22 > mid23;

wire cmp501 = mid40 > mid41;

wire cmp612 = mid51 > mid52;

wire cmp701 = mid60 > mid61;

assign mid00 = (cmp001)? in0:in1;
assign mid01 = (cmp001)? in1:in0;
assign mid02 = in2;
assign mid03 = (cmp034)? in3:in4;
assign mid04 = (cmp034)? in4:in3;
assign mid05 = in5;

assign mid10 = mid00;
assign mid11 = (cmp112)?mid01:mid02;
assign mid12 = (cmp112)?mid02:mid01;
assign mid13 = mid03;
assign mid14 = (cmp145)?mid04:mid05;
assign mid15 = (cmp145)?mid05:mid04;

assign mid20 = (cmp201)?mid10:mid11;
assign mid21 = (cmp201)?mid11:mid10;
assign mid22 = mid12;
assign mid23 = (cmp234)?mid13:mid14;
assign mid24 = (cmp234)?mid14:mid13;
assign mid25 = mid15;

assign mid30 = (cmp305)?mid20:mid25;
assign mid31 = (cmp314)?mid21:mid24;
assign mid32 = (cmp323)?mid22:mid23;
assign mid33 = (cmp323)?mid23:mid22;
assign mid34 = (cmp314)?mid24:mid21;
assign mid35 = (cmp305)?mid25:mid20;

assign mid40 = (mode)?mid30:mid33;
assign mid41 = (mode)?mid31:mid34;
assign mid42 = (mode)?mid32:mid35;

assign mid50 = (cmp501)?mid40:mid41;
assign mid51 = (cmp501)?mid41:mid40;
assign mid52 = mid42;

assign mid60 = mid50;
assign mid61 = (cmp612)?mid51:mid52;
assign mid62 = (cmp612)?mid52:mid51;

assign mid70 = (cmp701)?mid60:mid61;
assign mid71 = (cmp701)?mid61:mid60;
assign mid72 = mid62;

assign out0 = mid70;
assign out1 = mid71;
assign out2 = mid72;

endmodule
// module BBQ (meat,vagetable,water,cost);
// input XXX;
// output XXX;
// 
// endmodule

// --------------------------------------------------
// Example for using submodule 
// BBQ bbq0(.meat(meat_0), .vagetable(vagetable_0), .water(water_0),.cost(cost[0]));
// --------------------------------------------------
// Example for continuous assignment
// assign out_n = XXX;
// --------------------------------------------------
// Example for procedure assignment
// always@(*) begin 
// 	out_n = XXX; 
// end
// --------------------------------------------------
// Example for case statement
// always @(*) begin
// 	case(op)
// 		2'b00: output_reg = a + b;
// 		2'b10: output_reg = a - b;
// 		2'b01: output_reg = a * b;
// 		2'b11: output_reg = a / b;
// 		default: output_reg = 0;
// 	endcase
// end
// --------------------------------------------------
