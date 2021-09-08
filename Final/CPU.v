//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg  [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  reg  [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  reg  [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  reg  [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;

wire [ID_WIDTH-1:0]           arid_m_inf_i,   arid_m_inf_d;
reg  [ADDR_WIDTH-1:0]       araddr_m_inf_i, araddr_m_inf_d;
wire [7 -1:0]                arlen_m_inf_i,  arlen_m_inf_d;
wire [3 -1:0]               arsize_m_inf_i, arsize_m_inf_d;
wire [2 -1:0]              arburst_m_inf_i,arburst_m_inf_d;
reg                        arvalid_m_inf_i,arvalid_m_inf_d;
wire                       arready_m_inf_i,arready_m_inf_d;

assign    arid_m_inf ={   arid_m_inf_i,   arid_m_inf_d};
assign  araddr_m_inf ={ araddr_m_inf_i, araddr_m_inf_d};
assign   arlen_m_inf ={  arlen_m_inf_i,  arlen_m_inf_d};
assign  arsize_m_inf ={ arsize_m_inf_i, arsize_m_inf_d};
assign arburst_m_inf ={arburst_m_inf_i,arburst_m_inf_d};
assign arvalid_m_inf ={arvalid_m_inf_i,arvalid_m_inf_d};
assign arready_m_inf_i = arready_m_inf[1];
assign arready_m_inf_d = arready_m_inf[0];
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;

wire [ID_WIDTH-1:0]         rid_m_inf_i,   rid_m_inf_d;
wire [DATA_WIDTH-1:0]     rdata_m_inf_i, rdata_m_inf_d;
wire [2 -1:0]             rresp_m_inf_i, rresp_m_inf_d;
wire                      rlast_m_inf_i, rlast_m_inf_d;
wire                     rvalid_m_inf_i,rvalid_m_inf_d;
wire                     rready_m_inf_i,rready_m_inf_d;

assign rid_m_inf_i = rid_m_inf[7:4];
assign rid_m_inf_d = rid_m_inf[3:0];
assign rdata_m_inf_i = rdata_m_inf[31:16];
assign rdata_m_inf_d = rdata_m_inf[15:0];
assign rresp_m_inf_i = rresp_m_inf[3:2];
assign rresp_m_inf_d = rresp_m_inf[1:0];
assign rlast_m_inf_i = rlast_m_inf[1];
assign rlast_m_inf_d = rlast_m_inf[0];
assign rvalid_m_inf_i =rvalid_m_inf[1];
assign rvalid_m_inf_d =rvalid_m_inf[0];
assign rready_m_inf = {rready_m_inf_i,rready_m_inf_d};

// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

//wire signed [15:0] core_arr [15:0];
//assign core_arr[0 ] = core_r0 ;
//assign core_arr[1 ] = core_r1 ;
//assign core_arr[2 ] = core_r2 ;
//assign core_arr[3 ] = core_r3 ;
//assign core_arr[4 ] = core_r4 ;
//assign core_arr[5 ] = core_r5 ;
//assign core_arr[6 ] = core_r6 ;
//assign core_arr[7 ] = core_r7 ;
//assign core_arr[8 ] = core_r8 ;
//assign core_arr[9 ] = core_r9 ;
//assign core_arr[10] = core_r10;
//assign core_arr[11] = core_r11;
//assign core_arr[12] = core_r12;
//assign core_arr[13] = core_r13;
//assign core_arr[14] = core_r14;
//assign core_arr[15] = core_r15;

//###########################################
//
// Wrtie down your design below
//
//###########################################
//####################################################
//               reg & wire
//####################################################
integer i;
//// FSM1
parameter   ST1_IDLE        =   'd0,
            ST1_INSN_FETCH  =   'd1,
            ST1_PRE_RUN     =   'd2,
            ST1_RUN         =   'd3,
            ST1_DATA_FETCH  =   'd4,
            ST1_DATA_STORE  =   'd5;
reg [2:0]   cs1;
wire        CS1_IDLE        =   cs1 == ST1_IDLE;
wire        CS1_INSN_FETCH  =   cs1 == ST1_INSN_FETCH;
wire        CS1_RUN         =   cs1 == ST1_PRE_RUN || cs1 == ST1_RUN;
wire        CS1_RUN2        =   cs1 == ST1_RUN;
wire        CS1_DATA_FETCH  =   cs1 == ST1_DATA_FETCH;
wire        CS1_DATA_STORE  =   cs1 == ST1_DATA_STORE;

/*
////FSM2
parameter   ST2_IDLE        =   'd0;
reg         cs2;
wire        CS2_IDLE        =   cs2 == ST2_IDLE;
*/

////PC
reg [10:0]  pc,pc_delay;
wire load_stall;
wire store_stall;
wire beq_stall;
wire jump_stall;
reg load_stalled;
reg store_stalled;
reg beq_stalled;
reg jump_stalled;
wire is_not_stall = !(load_stall || beq_stall || jump_stall ||store_stall);
wire is_not_stalled = !(load_stalled || beq_stalled || jump_stalled || store_stalled);
/*
////Cal
reg [15:0]  Cals [15:0];
*/
////Insnc
wire [7:0] AI;
wire [15:0] DI;
wire [15:0] QI;
reg [2:0] ff_insn_tag [1:0];
reg [1:0] ff_insn_first;
reg [6:0] ff_cnt_insnc;
wire pc_head = pc[7];
wire insn_need_fetch = (ff_insn_first[pc_head] || ~(ff_insn_tag[pc_head]==pc[10:8])) && is_not_stall;

reg [15:0] QI_Delay;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        QI_Delay <= 'd0;
    else if(!(CS1_DATA_FETCH||CS1_DATA_STORE))
        QI_Delay <= QI;
end

////rs rt rd
reg signed [15:0] rs,rt,rd;
reg [15:0] rt_delay;
always@(*)begin
    case(QI[8:5])
        4'd0 : rt = core_r0 ;
        4'd1 : rt = core_r1 ;
        4'd2 : rt = core_r2 ;
        4'd3 : rt = core_r3 ;
        4'd4 : rt = core_r4 ;
        4'd5 : rt = core_r5 ;
        4'd6 : rt = core_r6 ;
        4'd7 : rt = core_r7 ;
        4'd8 : rt = core_r8 ;
        4'd9 : rt = core_r9 ;
        4'd10: rt = core_r10;
        4'd11: rt = core_r11;
        4'd12: rt = core_r12;
        4'd13: rt = core_r13;
        4'd14: rt = core_r14;
        4'd15: rt = core_r15;
    endcase
end
always@(*)begin
    case(QI[12:9])
        4'd0 : rs = core_r0 ;
        4'd1 : rs = core_r1 ;
        4'd2 : rs = core_r2 ;
        4'd3 : rs = core_r3 ;
        4'd4 : rs = core_r4 ;
        4'd5 : rs = core_r5 ;
        4'd6 : rs = core_r6 ;
        4'd7 : rs = core_r7 ;
        4'd8 : rs = core_r8 ;
        4'd9 : rs = core_r9 ;
        4'd10: rs = core_r10;
        4'd11: rs = core_r11;
        4'd12: rs = core_r12;
        4'd13: rs = core_r13;
        4'd14: rs = core_r14;
        4'd15: rs = core_r15;
    endcase
end

////Datac
wire [7:0] AD;
wire [15:0] DD;
wire [15:0] QD;
reg [2:0] ff_data_tag [1:0];
reg [1:0] ff_data_first;
reg [6:0] ff_cnt_datac;
wire signed [10:0] addr = $signed(rs) + $signed(QI[4:0]);
wire addr_head = addr[7];
wire data_need_fetch = CS1_RUN2 && QI[15:13] == 3'b010 && (ff_data_first[addr_head] || ~(ff_data_tag[addr_head]==addr[10:8])) && is_not_stalled;
wire data_need_write = CS1_RUN2 && QI[15:13] == 3'b011 && is_not_stalled;

reg [10:0] addr_delay;
wire addr_head_delay = addr_delay[7];
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        addr_delay <= 'd0;
    else if((data_need_fetch||data_need_write) && CS1_RUN)
        addr_delay <= addr;
end


////////////
//  FSM1  //
////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cs1 <= ST1_IDLE;
    else begin
        case(cs1)
            ST1_IDLE: if(insn_need_fetch) cs1 <= ST1_INSN_FETCH;
            ST1_INSN_FETCH: if(rlast_m_inf_i) cs1 <= ST1_PRE_RUN;
            ST1_PRE_RUN:begin
                if(insn_need_fetch) cs1 <= ST1_INSN_FETCH;
                else cs1 <= ST1_RUN;
            end
            ST1_RUN:begin 
                if(insn_need_fetch && is_not_stall) cs1 <= ST1_INSN_FETCH;
                else if(data_need_fetch) cs1 <= ST1_DATA_FETCH;
                else if(data_need_write) cs1 <= ST1_DATA_STORE;
            end
            ST1_DATA_FETCH: if(rlast_m_inf_d) cs1 <= ST1_PRE_RUN;
            ST1_DATA_STORE: if(bvalid_m_inf) cs1 <= ST1_PRE_RUN;
        endcase
    end
end

//////////
//  PC  //
//////////
assign load_stall = CS1_RUN2 && QI[15:13] == 3'b010 && is_not_stalled;
assign beq_stall = CS1_RUN2 && QI[15:13] == 3'b100 && is_not_stalled;
assign jump_stall = CS1_RUN2 && QI[15:13] == 3'b101 && is_not_stalled;
assign store_stall = CS1_RUN2 && QI[15:13] == 3'b011 && is_not_stalled;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        load_stalled <= 'd0;
    else if(load_stall && !load_stalled) 
        load_stalled <= 'd1;
    else
        load_stalled <= 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        beq_stalled <= 'd0;
    else if(beq_stall && !beq_stalled) 
        beq_stalled <= 'd1;
    else
        beq_stalled <= 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        jump_stalled <= 'd0;
    else if(jump_stall && !jump_stalled) 
        jump_stalled <= 'd1;
    else
        jump_stalled <= 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        store_stalled <= 'd0;
    else if(store_stall && !store_stalled) 
        store_stalled <= 'd1;
    else
        store_stalled <= 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        pc <= 'd0;
    else if(CS1_RUN) begin
        if (data_need_fetch) begin
            //if (is_not_stalled)
            if(load_stall || store_stall)
            pc <= pc - 1;
        end else if (!insn_need_fetch && !(load_stall || store_stall))begin
            if(CS1_RUN2 && QI[15:13] == 3'b100 && rs == rt && is_not_stalled)
                pc <= $signed(pc_delay+1) + $signed(QI[4:0]);
            else if(CS1_RUN2 && QI[15:13] == 3'b101 && is_not_stalled)
                pc <= QI[11:1];
            else if(!beq_stall)
                pc <= pc + 1;
        end
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        pc_delay <= 'd0;
    else
        pc_delay <= pc;
end
///////////
//  Cal  //
///////////
wire [15:0] result_add = rs + rt;
wire [15:0] result_sub = rs - rt;
wire        result_slt = rs < rt;
wire [15:0] result_mul = rs * rt;

////////////
//  Regs  //
////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        core_r0  <= 'd0;
        core_r1  <= 'd0;
        core_r2  <= 'd0;
        core_r3  <= 'd0;
        core_r4  <= 'd0;
        core_r5  <= 'd0;
        core_r6  <= 'd0;
        core_r7  <= 'd0;
        core_r8  <= 'd0;
        core_r9  <= 'd0;
        core_r10 <= 'd0;
        core_r11 <= 'd0;
        core_r12 <= 'd0;
        core_r13 <= 'd0;
        core_r14 <= 'd0;
        core_r15 <= 'd0;
    end else if(CS1_RUN2)begin
        if(load_stalled)begin //// LOAD
            case(QI_Delay[8:5])
                0 :core_r0  <= QD;
                1 :core_r1  <= QD;
                2 :core_r2  <= QD;
                3 :core_r3  <= QD;
                4 :core_r4  <= QD;
                5 :core_r5  <= QD;
                6 :core_r6  <= QD;
                7 :core_r7  <= QD;
                8 :core_r8  <= QD;
                9 :core_r9  <= QD;
                10:core_r10 <= QD;
                11:core_r11 <= QD;
                12:core_r12 <= QD;
                13:core_r13 <= QD;
                14:core_r14 <= QD;
                15:core_r15 <= QD;
            endcase
        end else if(is_not_stalled) begin
            if(QI[15:13] == 3'b001 && QI[0])begin //// MUL
                case(QI[4:1])
                    0 :core_r0  <= result_mul;
                    1 :core_r1  <= result_mul; 
                    2 :core_r2  <= result_mul; 
                    3 :core_r3  <= result_mul; 
                    4 :core_r4  <= result_mul; 
                    5 :core_r5  <= result_mul; 
                    6 :core_r6  <= result_mul; 
                    7 :core_r7  <= result_mul; 
                    8 :core_r8  <= result_mul; 
                    9 :core_r9  <= result_mul; 
                    10:core_r10 <= result_mul; 
                    11:core_r11 <= result_mul; 
                    12:core_r12 <= result_mul; 
                    13:core_r13 <= result_mul; 
                    14:core_r14 <= result_mul; 
                    15:core_r15 <= result_mul; 
                endcase
            end else if(QI[15:13] == 3'b000 && !QI[0]) begin//// ADD
                case(QI[4:1])
                    0 :core_r0  <= result_add;
                    1 :core_r1  <= result_add; 
                    2 :core_r2  <= result_add; 
                    3 :core_r3  <= result_add; 
                    4 :core_r4  <= result_add; 
                    5 :core_r5  <= result_add; 
                    6 :core_r6  <= result_add; 
                    7 :core_r7  <= result_add; 
                    8 :core_r8  <= result_add; 
                    9 :core_r9  <= result_add; 
                    10:core_r10 <= result_add; 
                    11:core_r11 <= result_add; 
                    12:core_r12 <= result_add; 
                    13:core_r13 <= result_add; 
                    14:core_r14 <= result_add; 
                    15:core_r15 <= result_add; 
                endcase
            end else if(QI[15:13] == 3'b000 && QI[0]) begin//// SUB
                case(QI[4:1])
                    0 :core_r0  <= result_sub;
                    1 :core_r1  <= result_sub; 
                    2 :core_r2  <= result_sub; 
                    3 :core_r3  <= result_sub; 
                    4 :core_r4  <= result_sub; 
                    5 :core_r5  <= result_sub; 
                    6 :core_r6  <= result_sub; 
                    7 :core_r7  <= result_sub; 
                    8 :core_r8  <= result_sub; 
                    9 :core_r9  <= result_sub; 
                    10:core_r10 <= result_sub; 
                    11:core_r11 <= result_sub; 
                    12:core_r12 <= result_sub; 
                    13:core_r13 <= result_sub; 
                    14:core_r14 <= result_sub; 
                    15:core_r15 <= result_sub; 
                endcase
            end else if(QI[15:13] == 3'b001 && !QI[0]) begin//// SLT
                case(QI[4:1])
                    0 :core_r0  <= result_slt;
                    1 :core_r1  <= result_slt; 
                    2 :core_r2  <= result_slt; 
                    3 :core_r3  <= result_slt; 
                    4 :core_r4  <= result_slt; 
                    5 :core_r5  <= result_slt; 
                    6 :core_r6  <= result_slt; 
                    7 :core_r7  <= result_slt; 
                    8 :core_r8  <= result_slt; 
                    9 :core_r9  <= result_slt; 
                    10:core_r10 <= result_slt; 
                    11:core_r11 <= result_slt; 
                    12:core_r12 <= result_slt; 
                    13:core_r13 <= result_slt; 
                    14:core_r14 <= result_slt; 
                    15:core_r15 <= result_slt; 
                endcase
            end
        end
    end 
end

/////////////
//  INSNC  //
/////////////
assign AI = (CS1_INSN_FETCH)? {pc_head,ff_cnt_insnc} : pc[7:0];
assign DI = rdata_m_inf_i;
wire WENI = ~rvalid_m_inf_i;
RA1SHI insnc(   .Q(QI),   .CLK(clk),   .CEN(1'd0),   .WEN(WENI),   .A(AI),   .D(DI),   .OEN(1'd0));

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_cnt_insnc <= 'd0;
    else if (rvalid_m_inf_i)
        ff_cnt_insnc <= ff_cnt_insnc + 1;
end 

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ff_insn_first <= 2'b11;
    end else if(CS1_INSN_FETCH)
        ff_insn_first[pc_head] <= 1'b0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ff_insn_tag[0] <= 'd0;
        ff_insn_tag[1] <= 'd0;
    end else if(CS1_INSN_FETCH)
        ff_insn_tag[pc_head] <= pc[10:8];
end

/////////////
//  DATAC  //
/////////////
assign AD = (CS1_DATA_FETCH)? {addr_head_delay,ff_cnt_datac} : (CS1_DATA_STORE)? addr_delay[7:0] : addr[7:0];
assign DD = (CS1_DATA_FETCH)? rdata_m_inf_d : rt_delay;
wire WEND = ~(rvalid_m_inf_d || (CS1_DATA_STORE && ff_data_tag[addr_head_delay]==addr_delay[10:8] ) );
RA1SHD datac(   .Q(QD),   .CLK(clk),   .CEN(1'b0),   .WEN(WEND),   .A(AD),   .D(DD),   .OEN(1'd0));
//RA1SHD datac(   .Q(QD),   .CLK(clk),   .CEN(!ff_data_tag[AD[10:7]]),   .WEN(WEND),   .A(AD),   .D(DD),   .OEN(1'd0));

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_cnt_datac <= 'd0;
    else if (rvalid_m_inf_d)
        ff_cnt_datac <= ff_cnt_datac + 1;
end 

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ff_data_first <= 2'b11;
    end else if(CS1_DATA_FETCH)
        ff_data_first[addr_head_delay] <= 1'b0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ff_data_tag[0] <= 'd0;
        ff_data_tag[1] <= 'd0;
    end else if(CS1_DATA_FETCH)
        ff_data_tag[addr_head_delay] <= addr_delay[10:8];
end

///////////
//  AXI  //
///////////
// axi write address channel 
assign    awid_m_inf = 4'd1;
assign  awsize_m_inf = 3'b001;
assign awburst_m_inf = 2'b01;
assign   awlen_m_inf = 7'd0;
always@(*)begin
    if(CS1_DATA_STORE)
        awaddr_m_inf = {16'b0,4'b0001,addr_delay,1'b0}; 
    else
        awaddr_m_inf = 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        awvalid_m_inf <= 'd0;
    else if(awready_m_inf)
        awvalid_m_inf <= 'd0;
    else if(data_need_write && CS1_RUN2 && !insn_need_fetch)
        awvalid_m_inf <= 'd1;
end

// axi write data channel 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        rt_delay <= 'd0;
    else if(data_need_write && CS1_RUN)
        rt_delay <= rt;
end

assign wdata_m_inf = rt_delay;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        wvalid_m_inf <= 'd0;
        wlast_m_inf <= 'd0;
    end else if(wready_m_inf) begin
        wvalid_m_inf <= 'd0;
        wlast_m_inf <= 'd0;
    end else if(CS1_DATA_STORE && awready_m_inf) begin
        wvalid_m_inf <= 'd1;
        wlast_m_inf <= 'd1;
    end
end

// axi write response channel
assign bready_m_inf = 1'b1;

// -----------------------------
// axi read address channel 
assign arid_m_inf_i = 4'd1;
assign arid_m_inf_d = 4'd1;
assign arlen_m_inf_i = 7'd127;
assign arlen_m_inf_d = 7'd127;
assign arsize_m_inf_i = 3'b001;
assign arsize_m_inf_d = 3'b001;
assign arburst_m_inf_i = 2'b01;
assign arburst_m_inf_d = 2'b01;
//wire [ADDR_WIDTH-1:0]       araddr_m_inf_i, araddr_m_inf_d;
//wire                       arvalid_m_inf_i,arvalid_m_inf_d;
//wire                       arready_m_inf_i,arready_m_inf_d;
always@(*)begin
    if(CS1_INSN_FETCH)
        araddr_m_inf_i = {16'b0,4'b0001,pc[10:7],8'b0}; 
    else
        araddr_m_inf_i = 'd0;
end
always@(*)begin
    if(CS1_DATA_FETCH)
        araddr_m_inf_d = {16'b0,4'b0001,addr_delay[10:7],8'b0}; 
    else
        araddr_m_inf_d = 'd0;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        arvalid_m_inf_i <= 'd0;
    else if(arready_m_inf_i)
        arvalid_m_inf_i <= 'd0;
    else if(insn_need_fetch && (CS1_IDLE || (CS1_RUN && is_not_stall) ))
        arvalid_m_inf_i <= 'd1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        arvalid_m_inf_d <= 'd0;
    else if(arready_m_inf_d)
        arvalid_m_inf_d <= 'd0;
    else if(data_need_fetch && CS1_RUN2 && !insn_need_fetch)
        arvalid_m_inf_d <= 'd1;
end
// -----------------------------
// axi read data channel 
/*
wire [ID_WIDTH-1:0]         rid_m_inf_i,   rid_m_inf_d;
wire [DATA_WIDTH-1:0]     rdata_m_inf_i, rdata_m_inf_d;
wire [2 -1:0]             rresp_m_inf_i, rresp_m_inf_d;
wire                      rlast_m_inf_i, rlast_m_inf_d;
wire                     rvalid_m_inf_i,rvalid_m_inf_d;
wire                     rready_m_inf_i,rready_m_inf_d;
*/
assign rready_m_inf_i = 1'd1;
assign rready_m_inf_d = 1'd1;

//////////////
//  OUTPUT  //
//////////////
reg [31:0] out_cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        IO_stall <= 'd1;
        out_cnt <= 'd0;
    end else if ((CS1_RUN2 && is_not_stall) || (CS1_DATA_STORE && bvalid_m_inf)) begin
        IO_stall <= 'd0;
        out_cnt <= out_cnt +1;
    end else begin
        IO_stall <= 'd1;
        out_cnt <= out_cnt;
    end
end

endmodule



















