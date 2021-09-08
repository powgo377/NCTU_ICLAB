module CHIP( 	clk,
	rst_n,
	IN_VALID_1,
	IN_VALID_2,
	ALPHA_I,
	A_I,
	D_I,
	THETA_JOINT_1,
	THETA_JOINT_2,
	THETA_JOINT_3,
	THETA_JOINT_4,
	// input signals
	OUT_VALID,
	OUT_X,
	OUT_Y,
	OUT_Z );

input   clk;
input   rst_n;
input   IN_VALID_1;
input   IN_VALID_2;
input [5:0] ALPHA_I;
input  [2:0] A_I;
input  [2:0] D_I;
input [5:0] THETA_JOINT_1;
input [5:0] THETA_JOINT_2;
input  [5:0] THETA_JOINT_3;
input  [5:0] THETA_JOINT_4;
output   OUT_VALID;
output   [8:0] OUT_X;
output   [8:0] OUT_Y;
output   [8:0] OUT_Z;

wire   C_clk;
wire   C_rst_n;
wire   C_IN_VALID_1;
wire   C_IN_VALID_2;
wire  [5:0] C_ALPHA_I;
wire  [2:0] C_A_I;
wire  [2:0] C_D_I;
wire  [5:0] C_THETA_JOINT_1;
wire  [5:0] C_THETA_JOINT_2;
wire  [5:0] C_THETA_JOINT_3;
wire  [5:0] C_THETA_JOINT_4;
wire  C_OUT_VALID;
wire  [8:0] C_OUT_X;
wire  [8:0] C_OUT_Y;
wire  [8:0] C_OUT_Z;

wire BUF_clk;
CLKBUFX20 buf0(.A(C_clk),.Y(BUF_clk));

DH I_DH(
	// Input signals
	.clk(BUF_clk),
	.rst_n(C_rst_n),
	.IN_VALID_1(C_IN_VALID_1),
	.IN_VALID_2(C_IN_VALID_2),
	.ALPHA_I(C_ALPHA_I),
	.A_I(C_A_I),
	.D_I(C_D_I),
	.THETA_JOINT_1(C_THETA_JOINT_1),
	.THETA_JOINT_2(C_THETA_JOINT_2),
	.THETA_JOINT_3(C_THETA_JOINT_3),
	.THETA_JOINT_4(C_THETA_JOINT_4),
	// Output signals
	.OUT_VALID(C_OUT_VALID),
	.OUT_X(C_OUT_X),
	.OUT_Y(C_OUT_Y),
	.OUT_Z(C_OUT_Z)
);


// Input Pads
P8C I_clk              (.Y(C_clk             ), .P(clk             ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_rst_n            (.Y(C_rst_n           ), .P(rst_n           ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_IN_VALID_1       (.Y(C_IN_VALID_1      ), .P(IN_VALID_1      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_IN_VALID_2       (.Y(C_IN_VALID_2      ), .P(IN_VALID_2      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_ALPHA_I_0        (.Y(C_ALPHA_I[0]      ), .P(ALPHA_I[0]      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_ALPHA_I_1        (.Y(C_ALPHA_I[1]      ), .P(ALPHA_I[1]      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_ALPHA_I_2        (.Y(C_ALPHA_I[2]      ), .P(ALPHA_I[2]      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_ALPHA_I_3        (.Y(C_ALPHA_I[3]      ), .P(ALPHA_I[3]      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_ALPHA_I_4        (.Y(C_ALPHA_I[4]      ), .P(ALPHA_I[4]      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_ALPHA_I_5        (.Y(C_ALPHA_I[5]      ), .P(ALPHA_I[5]      ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_A_I_0            (.Y(C_A_I[0]          ), .P(A_I[0]          ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_A_I_1            (.Y(C_A_I[1]          ), .P(A_I[1]          ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_A_I_2            (.Y(C_A_I[2]          ), .P(A_I[2]          ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_D_I_0            (.Y(C_D_I[0]          ), .P(D_I[0]          ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_D_I_1            (.Y(C_D_I[1]          ), .P(D_I[1]          ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_D_I_2            (.Y(C_D_I[2]          ), .P(D_I[2]          ), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_1_0  (.Y(C_THETA_JOINT_1[0]), .P(THETA_JOINT_1[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_1_1  (.Y(C_THETA_JOINT_1[1]), .P(THETA_JOINT_1[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_1_2  (.Y(C_THETA_JOINT_1[2]), .P(THETA_JOINT_1[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_1_3  (.Y(C_THETA_JOINT_1[3]), .P(THETA_JOINT_1[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_1_4  (.Y(C_THETA_JOINT_1[4]), .P(THETA_JOINT_1[4]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_1_5  (.Y(C_THETA_JOINT_1[5]), .P(THETA_JOINT_1[5]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_2_0  (.Y(C_THETA_JOINT_2[0]), .P(THETA_JOINT_2[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_2_1  (.Y(C_THETA_JOINT_2[1]), .P(THETA_JOINT_2[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_2_2  (.Y(C_THETA_JOINT_2[2]), .P(THETA_JOINT_2[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_2_3  (.Y(C_THETA_JOINT_2[3]), .P(THETA_JOINT_2[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_2_4  (.Y(C_THETA_JOINT_2[4]), .P(THETA_JOINT_2[4]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_2_5  (.Y(C_THETA_JOINT_2[5]), .P(THETA_JOINT_2[5]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_3_0  (.Y(C_THETA_JOINT_3[0]), .P(THETA_JOINT_3[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_3_1  (.Y(C_THETA_JOINT_3[1]), .P(THETA_JOINT_3[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_3_2  (.Y(C_THETA_JOINT_3[2]), .P(THETA_JOINT_3[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_3_3  (.Y(C_THETA_JOINT_3[3]), .P(THETA_JOINT_3[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_3_4  (.Y(C_THETA_JOINT_3[4]), .P(THETA_JOINT_3[4]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_3_5  (.Y(C_THETA_JOINT_3[5]), .P(THETA_JOINT_3[5]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_4_0  (.Y(C_THETA_JOINT_4[0]), .P(THETA_JOINT_4[0]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_4_1  (.Y(C_THETA_JOINT_4[1]), .P(THETA_JOINT_4[1]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_4_2  (.Y(C_THETA_JOINT_4[2]), .P(THETA_JOINT_4[2]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_4_3  (.Y(C_THETA_JOINT_4[3]), .P(THETA_JOINT_4[3]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_4_4  (.Y(C_THETA_JOINT_4[4]), .P(THETA_JOINT_4[4]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));
P8C I_THETA_JOINT_4_5  (.Y(C_THETA_JOINT_4[5]), .P(THETA_JOINT_4[5]), .A(1'b0), .ODEN(1'b0), .OCEN(1'b0), .PU(1'b1), .PD(1'b0), .CEN(1'b0), .CSEN(1'b1));

// Output Pads
P8C O_OUT_VALID (.A(C_OUT_VALID), .P(OUT_VALID), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_0   (.A(C_OUT_X[0] ), .P(OUT_X[0] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_1   (.A(C_OUT_X[1] ), .P(OUT_X[1] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_2   (.A(C_OUT_X[2] ), .P(OUT_X[2] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_3   (.A(C_OUT_X[3] ), .P(OUT_X[3] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_4   (.A(C_OUT_X[4] ), .P(OUT_X[4] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_5   (.A(C_OUT_X[5] ), .P(OUT_X[5] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_6   (.A(C_OUT_X[6] ), .P(OUT_X[6] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_7   (.A(C_OUT_X[7] ), .P(OUT_X[7] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_X_8   (.A(C_OUT_X[8] ), .P(OUT_X[8] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_0   (.A(C_OUT_Y[0] ), .P(OUT_Y[0] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_1   (.A(C_OUT_Y[1] ), .P(OUT_Y[1] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_2   (.A(C_OUT_Y[2] ), .P(OUT_Y[2] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_3   (.A(C_OUT_Y[3] ), .P(OUT_Y[3] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_4   (.A(C_OUT_Y[4] ), .P(OUT_Y[4] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_5   (.A(C_OUT_Y[5] ), .P(OUT_Y[5] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_6   (.A(C_OUT_Y[6] ), .P(OUT_Y[6] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_7   (.A(C_OUT_Y[7] ), .P(OUT_Y[7] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Y_8   (.A(C_OUT_Y[8] ), .P(OUT_Y[8] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_0   (.A(C_OUT_Z[0] ), .P(OUT_Z[0] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_1   (.A(C_OUT_Z[1] ), .P(OUT_Z[1] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_2   (.A(C_OUT_Z[2] ), .P(OUT_Z[2] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_3   (.A(C_OUT_Z[3] ), .P(OUT_Z[3] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_4   (.A(C_OUT_Z[4] ), .P(OUT_Z[4] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_5   (.A(C_OUT_Z[5] ), .P(OUT_Z[5] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_6   (.A(C_OUT_Z[6] ), .P(OUT_Z[6] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_7   (.A(C_OUT_Z[7] ), .P(OUT_Z[7] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));
P8C O_OUT_Z_8   (.A(C_OUT_Z[8] ), .P(OUT_Z[8] ), .ODEN(1'b1), .OCEN(1'b1), .PU(1'b1), .PD(1'b0), .CEN(1'b1), .CSEN(1'b0));

// IO power 
PVDDR VDDR0 ();
PVSSR GNDR0 ();
PVDDR VDDR1 ();
PVSSR GNDR1 ();
PVDDR VDDR2 ();
PVSSR GNDR2 ();
PVDDR VDDR3 ();
PVSSR GNDR3 ();
PVDDR VDDR4 ();
PVSSR GNDR4 ();
PVDDR VDDR5 ();
PVSSR GNDR5 ();
PVDDR VDDR6 ();
PVSSR GNDR6 ();
PVDDR VDDR7 ();
PVSSR GNDR7 ();
PVDDR VDDR8 ();
PVSSR GNDR8 ();
PVDDR VDDR9 ();
PVSSR GNDR9 ();
PVDDR VDDRA ();
PVSSR GNDRA ();
PVDDR VDDRB ();
PVSSR GNDRB ();

// Core power
PVDDC VDDC0 ();
PVSSC GNDC0 ();
PVDDC VDDC1 ();
PVSSC GNDC1 ();
PVDDC VDDC2 ();
PVSSC GNDC2 ();
PVDDC VDDC3 ();
PVSSC GNDC3 ();

endmodule
