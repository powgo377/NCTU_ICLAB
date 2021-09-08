//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 spring
//   Midterm Proejct            : AMBA (Cache & AXI-4)
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : AMBA.v
//   Module Name : AMBA
//   Release version : V1.0 (Release Date: 2021-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module AMBA(
				clk,	
			  rst_n,	
	
			  PADDR,
			 PRDATA,
			  PSELx, 
			PENABLE, 
			 PWRITE, 
			 PREADY,  
	

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 32, DRAM_NUMBER=2, WRIT_NUMBER=1;
input			  clk,rst_n;



// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
	   therefore I declared output of AXI as wire in Poly_Ring
*/
   
// -----------------------------
// APB channel 
input   wire [ADDR_WIDTH-1:0] 	   PADDR;
output  reg [DATA_WIDTH-1:0]  	  PRDATA;
input   wire			    	   PSELx;
input   wire		             PENABLE;
input   wire 		              PWRITE;
output  reg 			          PREADY;
// -----------------------------


// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 4 -1:0]             awlen_m_inf;
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
assign bready_m_inf = 1'b1;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 4 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//////////////////
//  reg & wire  //
//////////////////
wire is_insn_fetched;
//in
reg [31:0] ff_PADDR;
//reg ff_PSELx;
reg ff_PENABLE;
//reg ff_PWRITE;

//INSNC
wire[31:0] QI;
reg [31:0] ff_QI;
reg [63:0] ff_insn_tag;

//RA1SH
reg [6:0] dram_A;
reg [6:0] dramr_A;

//mult
reg [4:0] ff_mult_cnt;
reg [4:0] ff_mult_cnt2;

//conv
reg [4:0] ff_conv_cnt;
reg [4:0] ff_conv_cnt2;

//ff's
reg [31:0] arr1 [15:0];
reg [31:0] arr2 [15:0];
reg [31:0] arr3 [15:0];
reg [31:0] arr9 [8:0];
reg [31:0] arrwb[15:0];

parameter   ST_IDLE         =   'd0,
            ST_INSN_ADDR    =   'd1,
            ST_INSN_FETCH   =   'd2,
            ST_DATA_PRE     =   'd3,
            ST_DATA_PRE2    =   'd4,
            ST_DATA_FETCH   =   'd5,
            ST_MULT         =   'd6,
            ST_CONV         =   'd7,
            ST_OUT          =   'd8;

reg [3:0]   cs;
wire CS_IDLE         = cs == ST_IDLE;
wire CS_DATA_FETCH   = cs == ST_DATA_FETCH;
wire CS_MULT         = cs == ST_MULT;
wire CS_CONV         = cs == ST_CONV;
wire CS_OUT          = cs == ST_OUT;
///////////
//  FSM  //
///////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cs <= 'd0;
    end else begin
        case(cs)
            ST_IDLE:            if(PENABLE)           cs <= ST_INSN_ADDR;
            ST_INSN_ADDR:begin
                if(arready_m_inf[1])                cs <= ST_INSN_FETCH;
                else if(ff_insn_tag[ff_PADDR[11:6]])   cs <= ST_DATA_PRE;
            end
            ST_INSN_FETCH:      if(rlast_m_inf)     cs <= ST_DATA_PRE;
            ST_DATA_PRE:                            cs <= ST_DATA_PRE2;
            ST_DATA_PRE2:                           cs <= ST_DATA_FETCH;
            ST_DATA_FETCH:if(dram_A[6]&&dramr_A[6])begin
                if(ff_QI[0])
                    cs <= ST_CONV;
                else
                    cs <= ST_MULT;
            end
            ST_MULT: if(ff_mult_cnt[4]    && wlast_m_inf)  cs <= ST_OUT;
            ST_CONV: if(ff_conv_cnt == 17 && wlast_m_inf)  cs <= ST_OUT;
            ST_OUT:                                     cs <= ST_IDLE;
        endcase
    end
end
//////////
//  IN  //
//////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_PADDR <= 'd0;
    else 
        ff_PADDR <= PADDR;
end
/*always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_PSELx <= 'd0;
    else 
        ff_PSELx <= PSELx;
end*/
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
       ff_PENABLE <= 'd0; 
    else 
       ff_PENABLE <= PENABLE; 
end
/*always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_PWRITE <= 'd0;
    else 
        ff_PWRITE <= PWRITE;
end*/
/////////////
//  INSNC  //
/////////////
reg [3:0] ff_insn_cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_insn_cnt <= 'd0;
    else if(cs == ST_INSN_FETCH && rvalid_m_inf[1])
        ff_insn_cnt <= ff_insn_cnt + 1;
    else if(cs == ST_IDLE)
        ff_insn_cnt <= 'd0;
end

wire is_insn_write = rvalid_m_inf[1] && cs == ST_INSN_FETCH;
wire CEN = 'd0;
wire OEN = 'd0;
wire WENI = ~is_insn_write;
wire [9:0]  AI  = (is_insn_write)? {ff_PADDR[11:6],ff_insn_cnt} : ff_PADDR[11:2];
wire [31:0] DI  = rdata_m_inf[63:32];

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_insn_tag <= 'd0;
    else if(cs == ST_INSN_FETCH)
        ff_insn_tag[ff_PADDR[11:6]] <= 'b1;
end

assign is_insn_fetched  = ff_insn_tag[ff_PADDR[11:6]];

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_QI <= 'd0;
    else
        ff_QI <= QI;
end

INSNC insnc(   .Q(QI),   .CLK(clk),   .CEN(CEN),   .WEN(WENI),   .A(AI),   .D(DI),   .OEN(OEN));

/////////////
//  DRAM1  //
/////////////
wire [31:0] dram_D = rdata_m_inf[31:0];
reg [63:0] ff_dram_tag;
wire [5:0] dram_A_start = ff_QI[27:22];
wire [3:0] dram_A_tail  = ff_QI[21:18];
/*reg [3:0] dram_A_tail;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        dram_A_tail <= 'd0;
    else
        dram_A_tail <= ff_QI[21:18];
end*/

wire is_dram_A_mid = dram_A_tail != 'd0;
always@(*)begin
    if(ff_dram_tag[dram_A_start] == 1'b0)
        dram_A = dram_A_start;
    else if(ff_dram_tag[dram_A_start + 'd1] == 1'b0)
        dram_A = dram_A_start + 'd1;
    else if(ff_dram_tag[dram_A_start + 'd2] == 1'b0)
        dram_A = dram_A_start + 'd2;
    else if(ff_dram_tag[dram_A_start + 'd3] == 1'b0)
        dram_A = dram_A_start + 'd3;
    else if(ff_dram_tag[dram_A_start + 'd4] == 1'b0)
        dram_A = dram_A_start + 'd4;
    else if(ff_dram_tag[dram_A_start + 'd5] == 1'b0)
        dram_A = dram_A_start + 'd5;
    else if(ff_dram_tag[dram_A_start + 'd6] == 1'b0)
        dram_A = dram_A_start + 'd6;
    else if(ff_dram_tag[dram_A_start + 'd7] == 1'b0)
        dram_A = dram_A_start + 'd7;
    else if(ff_dram_tag[dram_A_start + 'd8] == 1'b0)
        dram_A = dram_A_start + 'd8;
    else if(ff_dram_tag[dram_A_start + 'd9] == 1'b0)
        dram_A = dram_A_start + 'd9;
    else if(ff_dram_tag[dram_A_start + 'd10] == 1'b0)
        dram_A = dram_A_start + 'd10;
    else if(ff_dram_tag[dram_A_start + 'd11] == 1'b0)
        dram_A = dram_A_start + 'd11;
    else if(ff_dram_tag[dram_A_start + 'd12] == 1'b0)
        dram_A = dram_A_start + 'd12;
    else if(ff_dram_tag[dram_A_start + 'd13] == 1'b0)
        dram_A = dram_A_start + 'd13;
    else if(ff_dram_tag[dram_A_start + 'd14] == 1'b0)
        dram_A = dram_A_start + 'd14;
    else if(ff_dram_tag[dram_A_start + 'd15] == 1'b0)
        dram_A = dram_A_start + 'd15;
    else if( is_dram_A_mid )begin
        if(ff_dram_tag[dram_A_start + 'd16] == 1'b0)
            dram_A = dram_A_start + 'd16;
        else
            dram_A = 'd64;
    end
    else
        dram_A = 'd64;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_dram_tag <= 'd0;
    else if(cs == ST_DATA_FETCH && rlast_m_inf[0])
        ff_dram_tag[dram_A] <= 'b1;
end

reg [3:0] ff_dram_cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_dram_cnt <= 'd0;
    else if(cs == ST_DATA_FETCH && rvalid_m_inf[0])
        ff_dram_cnt <= ff_dram_cnt + 1;
    else if(cs == ST_IDLE)
        ff_dram_cnt <= 'd0;
end

wire mult_data_save = (CS_MULT) && (ff_mult_cnt2 >= 'd19) && ff_mult_cnt <16;
wire conv_data_save = (CS_CONV) && (ff_conv_cnt2 >= 'd19) && ff_conv_cnt <17 && ff_conv_cnt > 0;
wire save_result = mult_data_save || conv_data_save;
wire [5:0] mult_idx = (CS_MULT)? (ff_QI[27:22] + ff_mult_cnt) : (ff_QI[27:22] + ff_conv_cnt - conv_data_save);
wire [5:0] AD_0 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 0  < dram_A_tail);
wire [5:0] AD_1 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 1  < dram_A_tail);
wire [5:0] AD_2 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 2  < dram_A_tail);
wire [5:0] AD_3 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 3  < dram_A_tail);
wire [5:0] AD_4 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 4  < dram_A_tail);
wire [5:0] AD_5 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 5  < dram_A_tail);
wire [5:0] AD_6 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 6  < dram_A_tail);
wire [5:0] AD_7 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 7  < dram_A_tail);
wire [5:0] AD_8 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 8  < dram_A_tail);
wire [5:0] AD_9 = (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 9  < dram_A_tail);
wire [5:0] AD_10= (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 10 < dram_A_tail);
wire [5:0] AD_11= (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 11 < dram_A_tail);
wire [5:0] AD_12= (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 12 < dram_A_tail);
wire [5:0] AD_13= (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 13 < dram_A_tail);
wire [5:0] AD_14= (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 14 < dram_A_tail);
wire [5:0] AD_15= (CS_DATA_FETCH)? dram_A[5:0] : mult_idx + ( 15 < dram_A_tail);

wire WEND_0 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd0 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_1 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd1 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_2 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd2 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_3 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd3 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_4 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd4 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_5 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd5 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_6 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd6 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_7 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd7 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_8 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd8 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_9 = (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd9 == ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_10= (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd10== ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_11= (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd11== ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_12= (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd12== ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_13= (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd13== ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_14= (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd14== ff_dram_cnt)) : ((save_result)?'d0: 'd1);
wire WEND_15= (CS_DATA_FETCH)? ~(rvalid_m_inf[0] &&(4'd15== ff_dram_cnt)) : ((save_result)?'d0: 'd1);

wire [31:0] QD [15:0];

wire [3:0] arr_0m_t  = 0  - dram_A_tail;
wire [3:0] arr_1m_t  = 1  - dram_A_tail;
wire [3:0] arr_2m_t  = 2  - dram_A_tail;
wire [3:0] arr_3m_t  = 3  - dram_A_tail;
wire [3:0] arr_4m_t  = 4  - dram_A_tail;
wire [3:0] arr_5m_t  = 5  - dram_A_tail;
wire [3:0] arr_6m_t  = 6  - dram_A_tail;
wire [3:0] arr_7m_t  = 7  - dram_A_tail;
wire [3:0] arr_8m_t  = 8  - dram_A_tail;
wire [3:0] arr_9m_t  = 9  - dram_A_tail;
wire [3:0] arr_10m_t = 10 - dram_A_tail;
wire [3:0] arr_11m_t = 11 - dram_A_tail;
wire [3:0] arr_12m_t = 12 - dram_A_tail;
wire [3:0] arr_13m_t = 13 - dram_A_tail;
wire [3:0] arr_14m_t = 14 - dram_A_tail;
wire [3:0] arr_15m_t = 15 - dram_A_tail;

wire [31:0] DD_0 =(mult_data_save)? (arr2[arr_0m_t ]) : ((conv_data_save)? (arr3[arr_0m_t ]) : dram_D);
wire [31:0] DD_1 =(mult_data_save)? (arr2[arr_1m_t ]) : ((conv_data_save)? (arr3[arr_1m_t ]) : dram_D);
wire [31:0] DD_2 =(mult_data_save)? (arr2[arr_2m_t ]) : ((conv_data_save)? (arr3[arr_2m_t ]) : dram_D);
wire [31:0] DD_3 =(mult_data_save)? (arr2[arr_3m_t ]) : ((conv_data_save)? (arr3[arr_3m_t ]) : dram_D);
wire [31:0] DD_4 =(mult_data_save)? (arr2[arr_4m_t ]) : ((conv_data_save)? (arr3[arr_4m_t ]) : dram_D);
wire [31:0] DD_5 =(mult_data_save)? (arr2[arr_5m_t ]) : ((conv_data_save)? (arr3[arr_5m_t ]) : dram_D);
wire [31:0] DD_6 =(mult_data_save)? (arr2[arr_6m_t ]) : ((conv_data_save)? (arr3[arr_6m_t ]) : dram_D);
wire [31:0] DD_7 =(mult_data_save)? (arr2[arr_7m_t ]) : ((conv_data_save)? (arr3[arr_7m_t ]) : dram_D);
wire [31:0] DD_8 =(mult_data_save)? (arr2[arr_8m_t ]) : ((conv_data_save)? (arr3[arr_8m_t ]) : dram_D);
wire [31:0] DD_9 =(mult_data_save)? (arr2[arr_9m_t ]) : ((conv_data_save)? (arr3[arr_9m_t ]) : dram_D);
wire [31:0] DD_10=(mult_data_save)? (arr2[arr_10m_t]) : ((conv_data_save)? (arr3[arr_10m_t]) : dram_D);
wire [31:0] DD_11=(mult_data_save)? (arr2[arr_11m_t]) : ((conv_data_save)? (arr3[arr_11m_t]) : dram_D);
wire [31:0] DD_12=(mult_data_save)? (arr2[arr_12m_t]) : ((conv_data_save)? (arr3[arr_12m_t]) : dram_D);
wire [31:0] DD_13=(mult_data_save)? (arr2[arr_13m_t]) : ((conv_data_save)? (arr3[arr_13m_t]) : dram_D);
wire [31:0] DD_14=(mult_data_save)? (arr2[arr_14m_t]) : ((conv_data_save)? (arr3[arr_14m_t]) : dram_D);
wire [31:0] DD_15=(mult_data_save)? (arr2[arr_15m_t]) : ((conv_data_save)? (arr3[arr_15m_t]) : dram_D);

RA1SH dram_0  (   .Q(QD[0 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_0 ),   .A(AD_0 ),   .D(DD_0 ),   .OEN(OEN));
RA1SH dram_1  (   .Q(QD[1 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_1 ),   .A(AD_1 ),   .D(DD_1 ),   .OEN(OEN));
RA1SH dram_2  (   .Q(QD[2 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_2 ),   .A(AD_2 ),   .D(DD_2 ),   .OEN(OEN));
RA1SH dram_3  (   .Q(QD[3 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_3 ),   .A(AD_3 ),   .D(DD_3 ),   .OEN(OEN));
RA1SH dram_4  (   .Q(QD[4 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_4 ),   .A(AD_4 ),   .D(DD_4 ),   .OEN(OEN));
RA1SH dram_5  (   .Q(QD[5 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_5 ),   .A(AD_5 ),   .D(DD_5 ),   .OEN(OEN));
RA1SH dram_6  (   .Q(QD[6 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_6 ),   .A(AD_6 ),   .D(DD_6 ),   .OEN(OEN));
RA1SH dram_7  (   .Q(QD[7 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_7 ),   .A(AD_7 ),   .D(DD_7 ),   .OEN(OEN));
RA1SH dram_8  (   .Q(QD[8 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_8 ),   .A(AD_8 ),   .D(DD_8 ),   .OEN(OEN));
RA1SH dram_9  (   .Q(QD[9 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_9 ),   .A(AD_9 ),   .D(DD_9 ),   .OEN(OEN));
RA1SH dram_10 (   .Q(QD[10]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_10),   .A(AD_10),   .D(DD_10),   .OEN(OEN));
RA1SH dram_11 (   .Q(QD[11]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_11),   .A(AD_11),   .D(DD_11),   .OEN(OEN));
RA1SH dram_12 (   .Q(QD[12]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_12),   .A(AD_12),   .D(DD_12),   .OEN(OEN));
RA1SH dram_13 (   .Q(QD[13]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_13),   .A(AD_13),   .D(DD_13),   .OEN(OEN));
RA1SH dram_14 (   .Q(QD[14]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_14),   .A(AD_14),   .D(DD_14),   .OEN(OEN));
RA1SH dram_15 (   .Q(QD[15]),   .CLK(clk),   .CEN(CEN),   .WEN(WEND_15),   .A(AD_15),   .D(DD_15),   .OEN(OEN));

/////////////
//  DRAMR  //
/////////////
wire [31:0] dramr_D = rdata_m_inf[63:32];
reg [63:0] ff_dramr_tag;
wire [5:0] dramr_A_start = ff_QI[11: 6];
wire [3:0] dramr_A_tail  = ff_QI[ 5: 2];
/*reg [3:0] dramr_A_tail;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        dramr_A_tail <= 'd0;
    else
        dramr_A_tail <= ff_QI[ 5: 2];
end*/

wire is_dramr_A_mid = dramr_A_tail != 'd0;
wire [6:0] dramr_A_start_p_1  = dramr_A_start + 'd1 ;
wire [6:0] dramr_A_start_p_2  = dramr_A_start + 'd2 ;
wire [6:0] dramr_A_start_p_3  = dramr_A_start + 'd3 ;
wire [6:0] dramr_A_start_p_4  = dramr_A_start + 'd4 ;
wire [6:0] dramr_A_start_p_5  = dramr_A_start + 'd5 ;
wire [6:0] dramr_A_start_p_6  = dramr_A_start + 'd6 ;
wire [6:0] dramr_A_start_p_7  = dramr_A_start + 'd7 ;
wire [6:0] dramr_A_start_p_8  = dramr_A_start + 'd8 ;
wire [6:0] dramr_A_start_p_9  = dramr_A_start + 'd9 ;
wire [6:0] dramr_A_start_p_10 = dramr_A_start + 'd10;
wire [6:0] dramr_A_start_p_11 = dramr_A_start + 'd11;
wire [6:0] dramr_A_start_p_12 = dramr_A_start + 'd12;
wire [6:0] dramr_A_start_p_13 = dramr_A_start + 'd13;
wire [6:0] dramr_A_start_p_14 = dramr_A_start + 'd14;
wire [6:0] dramr_A_start_p_15 = dramr_A_start + 'd15;
wire [6:0] dramr_A_start_p_16 = dramr_A_start + 'd16;
always@(*)begin
    if(ff_dramr_tag[dramr_A_start] == 1'b0)
        dramr_A = dramr_A_start;
    else if( !dramr_A_start_p_1[6]  && ff_dramr_tag[dramr_A_start_p_1] == 1'b0)
        dramr_A = dramr_A_start_p_1;
    else if( !dramr_A_start_p_2[6]  && ff_dramr_tag[dramr_A_start_p_2] == 1'b0)
        dramr_A = dramr_A_start_p_2;
    else if( !dramr_A_start_p_3[6]  && ff_dramr_tag[dramr_A_start_p_3] == 1'b0)
        dramr_A = dramr_A_start_p_3;
    else if( !dramr_A_start_p_4[6]  && ff_dramr_tag[dramr_A_start_p_4] == 1'b0)
        dramr_A = dramr_A_start_p_4;
    else if( !dramr_A_start_p_5[6]  && ff_dramr_tag[dramr_A_start_p_5] == 1'b0)
        dramr_A = dramr_A_start_p_5;
    else if( !dramr_A_start_p_6[6]  && ff_dramr_tag[dramr_A_start_p_6] == 1'b0)
        dramr_A = dramr_A_start_p_6;
    else if( !dramr_A_start_p_7[6]  && ff_dramr_tag[dramr_A_start_p_7] == 1'b0)
        dramr_A = dramr_A_start_p_7;
    else if( !dramr_A_start_p_8[6]  && ff_dramr_tag[dramr_A_start_p_8] == 1'b0)
        dramr_A = dramr_A_start_p_8;
    else if( !dramr_A_start_p_9[6]  && ff_dramr_tag[dramr_A_start_p_9] == 1'b0)
        dramr_A = dramr_A_start_p_9;
    else if( !dramr_A_start_p_10[6] && ff_dramr_tag[dramr_A_start_p_10] == 1'b0)
        dramr_A = dramr_A_start_p_10;
    else if( !dramr_A_start_p_11[6] && ff_dramr_tag[dramr_A_start_p_11] == 1'b0)
        dramr_A = dramr_A_start_p_11;
    else if( !dramr_A_start_p_12[6] && ff_dramr_tag[dramr_A_start_p_12] == 1'b0)
        dramr_A = dramr_A_start_p_12;
    else if( !dramr_A_start_p_13[6] && ff_dramr_tag[dramr_A_start_p_13] == 1'b0)
        dramr_A = dramr_A_start_p_13;
    else if( !dramr_A_start_p_14[6] && ff_dramr_tag[dramr_A_start_p_14] == 1'b0)
        dramr_A = dramr_A_start_p_14;
    else if( !dramr_A_start_p_15[6] && ff_dramr_tag[dramr_A_start_p_15] == 1'b0)
        dramr_A = dramr_A_start_p_15;
    else if( !dramr_A_start_p_16[6] &&  (ff_dramr_tag[dramr_A_start_p_16] == 1'b0) && is_dramr_A_mid)
        dramr_A = dramr_A_start_p_16;
    else
        dramr_A = 'd64;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_dramr_tag <= 'd0;
    else if(cs == ST_DATA_FETCH && rlast_m_inf[1])
        ff_dramr_tag[dramr_A] <= 'b1;
end

reg [3:0] ff_dramr_cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_dramr_cnt <= 'd0;
    else if(cs == ST_DATA_FETCH && rvalid_m_inf[1])
        ff_dramr_cnt <= ff_dramr_cnt + 1;
    else if(cs == ST_IDLE)
        ff_dramr_cnt <= 'd0;
end

wire [5:0] mult_idxr = (CS_MULT)? (ff_QI[11:6] + ff_mult_cnt2) : (ff_QI[11:6]);
wire [5:0] ADR_0 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 0  < dramr_A_tail);
wire [5:0] ADR_1 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 1  < dramr_A_tail);
wire [5:0] ADR_2 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 2  < dramr_A_tail);
wire [5:0] ADR_3 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 3  < dramr_A_tail);
wire [5:0] ADR_4 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 4  < dramr_A_tail);
wire [5:0] ADR_5 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 5  < dramr_A_tail);
wire [5:0] ADR_6 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 6  < dramr_A_tail);
wire [5:0] ADR_7 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 7  < dramr_A_tail);
wire [5:0] ADR_8 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 8  < dramr_A_tail);
wire [5:0] ADR_9 = (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 9  < dramr_A_tail);
wire [5:0] ADR_10= (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 10 < dramr_A_tail);
wire [5:0] ADR_11= (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 11 < dramr_A_tail);
wire [5:0] ADR_12= (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 12 < dramr_A_tail);
wire [5:0] ADR_13= (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 13 < dramr_A_tail);
wire [5:0] ADR_14= (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 14 < dramr_A_tail);
wire [5:0] ADR_15= (CS_DATA_FETCH)? dramr_A[5:0] : mult_idxr + ( 15 < dramr_A_tail);

wire WENDR_0 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd0 == ff_dramr_cnt)) : 'd1;
wire WENDR_1 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd1 == ff_dramr_cnt)) : 'd1;
wire WENDR_2 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd2 == ff_dramr_cnt)) : 'd1;
wire WENDR_3 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd3 == ff_dramr_cnt)) : 'd1;
wire WENDR_4 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd4 == ff_dramr_cnt)) : 'd1;
wire WENDR_5 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd5 == ff_dramr_cnt)) : 'd1;
wire WENDR_6 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd6 == ff_dramr_cnt)) : 'd1;
wire WENDR_7 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd7 == ff_dramr_cnt)) : 'd1;
wire WENDR_8 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd8 == ff_dramr_cnt)) : 'd1;
wire WENDR_9 = (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd9 == ff_dramr_cnt)) : 'd1;
wire WENDR_10= (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd10== ff_dramr_cnt)) : 'd1;
wire WENDR_11= (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd11== ff_dramr_cnt)) : 'd1;
wire WENDR_12= (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd12== ff_dramr_cnt)) : 'd1;
wire WENDR_13= (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd13== ff_dramr_cnt)) : 'd1;
wire WENDR_14= (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd14== ff_dramr_cnt)) : 'd1;
wire WENDR_15= (CS_DATA_FETCH)? ~(rvalid_m_inf[1] &&(4'd15== ff_dramr_cnt)) : 'd1;

wire [31:0] QDR [15:0];
/*wire [31:0] QDR_0 ;
wire [31:0] QDR_1 ;
wire [31:0] QDR_2 ;
wire [31:0] QDR_3 ;
wire [31:0] QDR_4 ;
wire [31:0] QDR_5 ;
wire [31:0] QDR_6 ;
wire [31:0] QDR_7 ;
wire [31:0] QDR_8 ;
wire [31:0] QDR_9 ;
wire [31:0] QDR_10;
wire [31:0] QDR_11;
wire [31:0] QDR_12;
wire [31:0] QDR_13;
wire [31:0] QDR_14;
wire [31:0] QDR_15;
*/
RA1SH dramr_0  (   .Q(QDR[0 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_0 ),   .A(ADR_0 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_1  (   .Q(QDR[1 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_1 ),   .A(ADR_1 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_2  (   .Q(QDR[2 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_2 ),   .A(ADR_2 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_3  (   .Q(QDR[3 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_3 ),   .A(ADR_3 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_4  (   .Q(QDR[4 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_4 ),   .A(ADR_4 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_5  (   .Q(QDR[5 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_5 ),   .A(ADR_5 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_6  (   .Q(QDR[6 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_6 ),   .A(ADR_6 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_7  (   .Q(QDR[7 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_7 ),   .A(ADR_7 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_8  (   .Q(QDR[8 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_8 ),   .A(ADR_8 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_9  (   .Q(QDR[9 ]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_9 ),   .A(ADR_9 ),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_10 (   .Q(QDR[10]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_10),   .A(ADR_10),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_11 (   .Q(QDR[11]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_11),   .A(ADR_11),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_12 (   .Q(QDR[12]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_12),   .A(ADR_12),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_13 (   .Q(QDR[13]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_13),   .A(ADR_13),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_14 (   .Q(QDR[14]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_14),   .A(ADR_14),   .D(dramr_D),   .OEN(OEN));
RA1SH dramr_15 (   .Q(QDR[15]),   .CLK(clk),   .CEN(CEN),   .WEN(WENDR_15),   .A(ADR_15),   .D(dramr_D),   .OEN(OEN));

////////////////////////////////
//  axi read address channel  //
////////////////////////////////
assign arid_m_inf   = {4'd1 ,4'd1 };
assign arlen_m_inf  = {4'd15,4'd15};
assign arsize_m_inf = {3'd2 ,3'd2 };
assign arburst_m_inf= {2'b01,2'b01};
reg [31:0] addr_dr,addr_d1;
reg valid_dr,valid_d1;
assign araddr_m_inf = {addr_dr,addr_d1};
assign arvalid_m_inf= {valid_dr,valid_d1};
assign rready_m_inf= 2'b11;

reg ff_dr_ready,ff_d1_ready;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_dr_ready <= 'd0;
    else if (cs == ST_DATA_FETCH)begin
        if(arready_m_inf[1])
            ff_dr_ready <= 'd1;
        else if(rlast_m_inf[1])
            ff_dr_ready <= 'd0;
    end else if (cs == ST_IDLE)
        ff_dr_ready <= 'd0;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_d1_ready <= 'd0;
    else if (cs == ST_DATA_FETCH)begin
        if(arready_m_inf[0])
            ff_d1_ready <= 'd1;
        else if(rlast_m_inf[0])
            ff_d1_ready <= 'd0;
    end else if (cs == ST_IDLE)
        ff_d1_ready <= 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_dr <= 'd0;
        valid_dr<= 'd0;
    end else if(cs == ST_INSN_ADDR && ff_PENABLE && !is_insn_fetched && !arready_m_inf[1])begin
        addr_dr <= {ff_PADDR[31:6],6'd0};
        valid_dr<= 1'b1;
    end else if(cs == ST_DATA_FETCH && !ff_dr_ready && !arready_m_inf[1] && !dramr_A[6]) begin
        addr_dr <= {16'b0,4'b0010,dramr_A[5:0],6'b0};
        valid_dr<= 1'b1;
    end else begin
        addr_dr <= 'd0;
        valid_dr<= 'd0;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        addr_d1 <= 'd0;
        valid_d1<= 'd0;
    end else if(cs == ST_DATA_FETCH && !ff_d1_ready && !dram_A[6] && !arready_m_inf[0]) begin
        addr_d1 <= {16'b0,4'b0001,dram_A[5:0],6'b0};
        valid_d1<= 1'b1;
    end else begin
        addr_d1 <= 'd0;
        valid_d1<= 'd0;
    end
end

////////////
//  MULT  //
////////////
wire is_one_row_done = mult_data_save && wlast_m_inf;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_mult_cnt <= 'd0;
    else if(is_one_row_done)
        ff_mult_cnt <= ff_mult_cnt + 1;
    else if(CS_IDLE)
        ff_mult_cnt <= 'd0;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_mult_cnt2 <= 'd0;
    else if(is_one_row_done)
        ff_mult_cnt2 <= 'd0;
    else if(cs == ST_MULT)
        ff_mult_cnt2 <= ff_mult_cnt2 + 1;
    else if(CS_IDLE)
        ff_mult_cnt2 <= 'd0;
end

////////////
//  CONV  //
////////////
wire is_one_row_done_conv = ff_conv_cnt2 >= 19 && wlast_m_inf;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_conv_cnt <= 'd0;
    else if(is_one_row_done_conv)
        ff_conv_cnt <= ff_conv_cnt + 1;
    else if(CS_IDLE)
        ff_conv_cnt <= 'd0;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_conv_cnt2 <= 'd0;
    else if(is_one_row_done_conv)
        ff_conv_cnt2 <= 'd0;
    else if(CS_CONV)
        ff_conv_cnt2 <= ff_conv_cnt2 + 1;
    else if(CS_IDLE)
        ff_conv_cnt2 <= 'd0;
end

////////////
//  FF'S  //
////////////
wire [3:0] qd_tmp = dram_A_tail + CS_CONV*ff_conv_cnt2 + CS_MULT*ff_mult_cnt2 - 'd1;

wire [3:0] qdr_0  = dramr_A_tail+0 ;
wire [3:0] qdr_1  = dramr_A_tail+1 ;
wire [3:0] qdr_2  = dramr_A_tail+2 ;
wire [3:0] qdr_3  = dramr_A_tail+3 ;
wire [3:0] qdr_4  = dramr_A_tail+4 ;
wire [3:0] qdr_5  = dramr_A_tail+5 ;
wire [3:0] qdr_6  = dramr_A_tail+6 ;
wire [3:0] qdr_7  = dramr_A_tail+7 ;
wire [3:0] qdr_8  = dramr_A_tail+8 ;
wire [3:0] qdr_9  = dramr_A_tail+9 ;
wire [3:0] qdr_10 = dramr_A_tail+10;
wire [3:0] qdr_11 = dramr_A_tail+11;
wire [3:0] qdr_12 = dramr_A_tail+12;
wire [3:0] qdr_13 = dramr_A_tail+13;
wire [3:0] qdr_14 = dramr_A_tail+14;
wire [3:0] qdr_15 = dramr_A_tail+15;

reg [31:0] ff_QD;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_QD <= 'd0;
    else
        ff_QD <= QD[qd_tmp];
end

reg [31:0] ff_QDR0,ff_QDR1,ff_QDR2,ff_QDR3,ff_QDR4,ff_QDR5,ff_QDR6,ff_QDR7,ff_QDR8,ff_QDR9,ff_QDR10,ff_QDR11,ff_QDR12,ff_QDR13,ff_QDR14,ff_QDR15;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ff_QDR0  <= 'd0;
        ff_QDR1  <= 'd0;
        ff_QDR2  <= 'd0;
        ff_QDR3  <= 'd0;
        ff_QDR4  <= 'd0;
        ff_QDR5  <= 'd0;
        ff_QDR6  <= 'd0;
        ff_QDR7  <= 'd0;
        ff_QDR8  <= 'd0;
        ff_QDR9  <= 'd0;
        ff_QDR10 <= 'd0;
        ff_QDR11 <= 'd0;
        ff_QDR12 <= 'd0;
        ff_QDR13 <= 'd0;
        ff_QDR14 <= 'd0;
        ff_QDR15 <= 'd0;
    end else begin
        ff_QDR0  <= QDR[qdr_0 ];
        ff_QDR1  <= QDR[qdr_1 ];
        ff_QDR2  <= QDR[qdr_2 ];
        ff_QDR3  <= QDR[qdr_3 ];
        ff_QDR4  <= QDR[qdr_4 ];
        ff_QDR5  <= QDR[qdr_5 ];
        ff_QDR6  <= QDR[qdr_6 ];
        ff_QDR7  <= QDR[qdr_7 ];
        ff_QDR8  <= QDR[qdr_8 ];
        ff_QDR9  <= QDR[qdr_9 ];
        ff_QDR10 <= QDR[qdr_10];
        ff_QDR11 <= QDR[qdr_11];
        ff_QDR12 <= QDR[qdr_12];
        ff_QDR13 <= QDR[qdr_13];
        ff_QDR14 <= QDR[qdr_14];
        ff_QDR15 <= QDR[qdr_15];
    end
end
 
wire [31:0] mult_result0  = ff_QD*ff_QDR0 ;
wire [31:0] mult_result1  = ff_QD*ff_QDR1 ;
wire [31:0] mult_result2  = ff_QD*ff_QDR2 ;
wire [31:0] mult_result3  = ff_QD*ff_QDR3 ;
wire [31:0] mult_result4  = ff_QD*ff_QDR4 ;
wire [31:0] mult_result5  = ff_QD*ff_QDR5 ;
wire [31:0] mult_result6  = ff_QD*ff_QDR6 ;
wire [31:0] mult_result7  = ff_QD*ff_QDR7 ;
wire [31:0] mult_result8  = ff_QD*ff_QDR8 ;
wire [31:0] mult_result9  = ff_QD*ff_QDR9 ;
wire [31:0] mult_result10 = ff_QD*ff_QDR10;
wire [31:0] mult_result11 = ff_QD*ff_QDR11;
wire [31:0] mult_result12 = ff_QD*ff_QDR12;
wire [31:0] mult_result13 = ff_QD*ff_QDR13;
wire [31:0] mult_result14 = ff_QD*ff_QDR14;
wire [31:0] mult_result15 = ff_QD*ff_QDR15;

wire [31:0] add_result0  = (CS_MULT)? (arr2[0 ]+arr1[0 ]) : arr1[ff_conv_cnt2-4]+arr9[2] ;
wire [31:0] add_result1  = (CS_MULT)? (arr2[1 ]+arr1[1 ]) : arr1[ff_conv_cnt2-3]+arr9[1] ;
wire [31:0] add_result2  = (CS_MULT)? (arr2[2 ]+arr1[2 ]) : arr1[ff_conv_cnt2-2]+arr9[0] ;
wire [31:0] add_result3  = (CS_MULT)? (arr2[3 ]+arr1[3 ]) : arr2[ff_conv_cnt2-4]+arr9[5] ;
wire [31:0] add_result4  = (CS_MULT)? (arr2[4 ]+arr1[4 ]) : arr2[ff_conv_cnt2-3]+arr9[4] ;
wire [31:0] add_result5  = (CS_MULT)? (arr2[5 ]+arr1[5 ]) : arr2[ff_conv_cnt2-2]+arr9[3] ;
wire [31:0] add_result6  = (CS_MULT)? (arr2[6 ]+arr1[6 ]) : arr3[ff_conv_cnt2-4]+arr9[8] ;
wire [31:0] add_result7  = (CS_MULT)? (arr2[7 ]+arr1[7 ]) : arr3[ff_conv_cnt2-3]+arr9[7] ;
wire [31:0] add_result8  = (CS_MULT)? (arr2[8 ]+arr1[8 ]) : arr3[ff_conv_cnt2-2]+arr9[6] ;
wire [31:0] add_result9  = arr2[9 ]+arr1[9 ];
wire [31:0] add_result10 = arr2[10]+arr1[10];
wire [31:0] add_result11 = arr2[11]+arr1[11];
wire [31:0] add_result12 = arr2[12]+arr1[12];
wire [31:0] add_result13 = arr2[13]+arr1[13];
wire [31:0] add_result14 = arr2[14]+arr1[14];
wire [31:0] add_result15 = arr2[15]+arr1[15];

integer i;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 9;i = i +1)begin
            arr9[i] = 'd0;
        end
    end else if (CS_CONV && ff_conv_cnt2 > 1) begin
        arr9[0 ] = mult_result0 ;
        arr9[1 ] = mult_result1 ;
        arr9[2 ] = mult_result2 ;
        arr9[3 ] = mult_result3 ;
        arr9[4 ] = mult_result4 ;
        arr9[5 ] = mult_result5 ;
        arr9[6 ] = mult_result6 ;
        arr9[7 ] = mult_result7 ;
        arr9[8 ] = mult_result8 ;
    end else if (CS_IDLE) begin
        for(i = 0;i < 9;i = i +1)begin
            arr9[i] = 'd0;
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 16;i = i +1)begin
            arr1[i] = 'd0;
        end
    end else if (cs == ST_MULT && ff_mult_cnt2 > 1) begin
        arr1[0 ] = mult_result0 ;
        arr1[1 ] = mult_result1 ;
        arr1[2 ] = mult_result2 ;
        arr1[3 ] = mult_result3 ;
        arr1[4 ] = mult_result4 ;
        arr1[5 ] = mult_result5 ;
        arr1[6 ] = mult_result6 ;
        arr1[7 ] = mult_result7 ;
        arr1[8 ] = mult_result8 ;
        arr1[9 ] = mult_result9 ;
        arr1[10] = mult_result10;
        arr1[11] = mult_result11;
        arr1[12] = mult_result12;
        arr1[13] = mult_result13;
        arr1[14] = mult_result14;
        arr1[15] = mult_result15;
    end else if (CS_CONV) begin
        if(ff_conv_cnt < 16)begin
            if (ff_conv_cnt2 == 'd0) begin
                for(i = 0;i < 16;i = i +1)begin
                    arr1[i] = 'd0;
                end
            end else if (ff_conv_cnt2 >= 'd3 && ff_conv_cnt2 <= 'd18) begin
                if (ff_conv_cnt2 != 'd3)
                    arr1[ff_conv_cnt2-4] = add_result0;
                    arr1[ff_conv_cnt2-3] = add_result1;
                if (ff_conv_cnt2 != 'd18)
                    arr1[ff_conv_cnt2-2] = add_result2;
            end
        end
    end else if (CS_IDLE) begin
        for(i = 0;i < 16;i = i +1)begin
            arr1[i] = 'd0;
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 16;i = i +1)begin
            arr2[i] = 'd0;
        end
    end else if (CS_IDLE) begin
        for(i = 0;i < 16;i = i +1)begin
            arr2[i] = 'd0;
        end
    end else if (is_one_row_done) begin
        for(i = 0;i < 16;i = i +1)begin
            arr2[i] = 'd0;
        end
    end else if (CS_MULT && (ff_mult_cnt2 > 'd2) && (ff_mult_cnt2 < 'h13)) begin
        arr2[0 ] = add_result0 ;
        arr2[1 ] = add_result1 ;
        arr2[2 ] = add_result2 ;
        arr2[3 ] = add_result3 ;
        arr2[4 ] = add_result4 ;
        arr2[5 ] = add_result5 ;
        arr2[6 ] = add_result6 ;
        arr2[7 ] = add_result7 ;
        arr2[8 ] = add_result8 ;
        arr2[9 ] = add_result9 ;
        arr2[10] = add_result10;
        arr2[11] = add_result11;
        arr2[12] = add_result12;
        arr2[13] = add_result13;
        arr2[14] = add_result14;
        arr2[15] = add_result15;
    end else if (CS_CONV) begin
        if(ff_conv_cnt < 16)begin
            if (ff_conv_cnt2 == 'd0) begin
                for(i = 0;i < 16;i = i +1)begin
                    arr2[i] = arr1[i];
                end
            end else if (ff_conv_cnt2 >= 'd3 && ff_conv_cnt2 <= 'd18) begin
                if (ff_conv_cnt2 != 'd3)
                    arr2[ff_conv_cnt2-4] = add_result3;
                    arr2[ff_conv_cnt2-3] = add_result4;
                if (ff_conv_cnt2 != 'd18)
                    arr2[ff_conv_cnt2-2] = add_result5;
            end
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 16;i = i +1)begin
            arr3[i] = 'd0;
        end
    end else if (CS_IDLE) begin
        for(i = 0;i < 16;i = i +1)begin
            arr3[i] = 'd0;
        end
    end else if (CS_CONV) begin
        if(ff_conv_cnt < 16)begin
            if (ff_conv_cnt2 == 'd0) begin
                for(i = 0;i < 16;i = i +1)begin
                    arr3[i] = arr2[i];
                end
            end else if (ff_conv_cnt2 >= 'd3 && ff_conv_cnt2 <= 'd18) begin
                if (ff_conv_cnt2 != 'd3)
                    arr3[ff_conv_cnt2-4] = add_result6;
                    arr3[ff_conv_cnt2-3] = add_result7;
                if (ff_conv_cnt2 != 'd18)
                    arr3[ff_conv_cnt2-2] = add_result8;
            end
        end else if ((ff_conv_cnt == 16 && ff_conv_cnt2 == 'd0) ||is_one_row_done_conv) begin
            for(i = 0;i < 16;i = i +1)begin
                arr3[i] = arr2[i];
            end
        end
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 16;i = i +1)begin
            arrwb[i] = 'd0;
        end
    end else if (is_one_row_done) begin
        for(i = 0;i < 16;i = i +1)begin
            arrwb[i] = arr2[i];
        end
    end else if (CS_CONV) begin
        if ((ff_conv_cnt == 16 && ff_conv_cnt2 == 'd0) ||is_one_row_done_conv) begin
            for(i = 0;i < 16;i = i +1)begin
                arrwb[i] = arr3[i];
            end
        end
    end
end


/////////////////
//  AXI WRITE  //
/////////////////
// axi write address channel 
assign       awid_m_inf = 4'd1;
assign     awsize_m_inf = 3'd2;
assign    awburst_m_inf = 2'b01;
assign      awlen_m_inf = 4'd15;
////// axi write data channel 
////// axi write response channel
////input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
////input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
////input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
////output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
////// -----------------------------
//assign rready_m_inf= 2'b11;

wire can_start_wb = (CS_MULT && ff_mult_cnt > 0 && ff_mult_cnt < 17);
wire can_start_wb_conv = (CS_CONV && ff_conv_cnt > 1 && ff_conv_cnt < 18);
reg ff_d1_w_ready;
////channel
wire [5:0] tmp  = ff_QI[27:22]+ff_mult_cnt-1;
wire [5:0] tmp2 = ff_QI[27:22]+ff_conv_cnt-2;
always@(*)begin
    if(can_start_wb && !ff_d1_w_ready) begin
        awaddr_m_inf = {16'b0,4'b0001,tmp ,ff_QI[21:18],2'b0};
        awvalid_m_inf= 1'b1;
    end else if(can_start_wb_conv && !ff_d1_w_ready) begin
        awaddr_m_inf = {16'b0,4'b0001,tmp2,ff_QI[21:18],2'b0};
        awvalid_m_inf= 1'b1;
    end else begin
        awaddr_m_inf = 'd0;
        awvalid_m_inf= 'd0;
    end
end

////data
reg [3:0] ff_wb_cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_wb_cnt <= 'd15;
    else if((can_start_wb||can_start_wb_conv) && wready_m_inf)
        ff_wb_cnt <= ff_wb_cnt + 1;
    else if(is_one_row_done||is_one_row_done_conv)
        ff_wb_cnt <= 'd0;
    else if(CS_IDLE)
        ff_wb_cnt <= 'd15;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_d1_w_ready <= 'd0;
    else if (CS_MULT || CS_CONV)begin
        if(awready_m_inf)
            ff_d1_w_ready <= 'd1;
        else if(ff_wb_cnt == 'd15)
            ff_d1_w_ready <= 'd0;
    end else if (cs == ST_IDLE)
        ff_d1_w_ready <= 'd0;
end

assign wdata_m_inf = arrwb[ff_wb_cnt];
assign wvalid_m_inf = (can_start_wb || can_start_wb_conv) && ff_d1_w_ready;
assign wlast_m_inf = (CS_MULT && ff_wb_cnt == 'd15) || (CS_CONV && (ff_wb_cnt == 'd15 || ff_conv_cnt < 2));


/////////////
//  OUTUT  //
/////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        PRDATA <= 'd0;
        PREADY <= 'd0;
    end else if (CS_OUT)begin
        PRDATA <=  ff_QI;
        PREADY <= 'd1;
    end else begin
        PRDATA <= 'd0;
        PREADY <= 'd0;
    end
end

endmodule








