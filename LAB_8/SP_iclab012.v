// synopsys translate_off 
`ifdef RTL
`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on
module SP(
	// Input signals
	clk,
	rst_n,
    cg_en,
	in_valid,
	in_data,
	in_mode,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, cg_en, in_valid;
input [2:0] in_mode;
input [8:0] in_data;
output wire out_valid;
output wire [8:0] out_data;

reg [3:0] all_cnt;

////FSM
/*parameter   ST_IDLE     =   3'b100,//4
            ST_INPUT    =   3'b000,//0
            ST_INV      =   3'b001,//1
            ST_MUL      =   3'b011,//3
            ST_SORT     =   3'b010,//2
            ST_OUT      =   3'b110;//6*/
parameter   ST_IDLE     =   3'd0,//4
            ST_INPUT    =   3'd1,//0
            ST_INV      =   3'd2,//1
            ST_MUL      =   3'd3,//3
            ST_SORT     =   3'd4,//2
            ST_ADD      =   3'd5,//6
            ST_OUT      =   3'd6;//6
reg [2:0]   cs;
wire    CS_IDLE = cs == ST_IDLE ;
wire    CS_INPUT= cs == ST_INPUT;
wire    CS_INV  = cs == ST_INV  ;
wire    CS_MUL  = cs == ST_MUL  ;
wire    CS_SORT = cs == ST_SORT ;
wire    CS_ADD  = cs == ST_ADD  ;
wire    CS_OUT  = cs == ST_OUT  ;

////INPUT
reg [8:0] input_arr [5:0];
reg [2:0] mode;

integer i;
////INV
reg [8:0] inv_arr [5:0];
reg [8:0] inv_sel [5:0];
always@(*)begin
    if(mode[0])begin
        for(i = 0;i < 6;i = i + 1)begin
            inv_sel[i] = inv_arr[i];
        end
    end else begin
        for(i = 0;i < 6;i = i + 1)begin
            inv_sel[i] = input_arr[i];
        end
    end
end
reg [3:0] inv_cnt;

////MULT
reg [1:0] mul_cnt;
reg [8:0] mult_arr [5:0];
reg [8:0] mult_sel [5:0];
always@(*)begin
    if(mode[1])begin
        for(i = 0;i < 6;i = i + 1)begin
            mult_sel[i] = mult_arr[i];
        end
    end else begin
        for(i = 0;i < 6;i = i + 1)begin
            mult_sel[i] = inv_sel[i];
        end
    end
end

////SORT
reg [8:0] sort_arr [5:0];
reg [8:0] sort_sel [5:0];
always@(*)begin
    if(mode[2])begin
        for(i = 0;i < 6;i = i + 1)begin
            sort_sel[i] = sort_arr[i];
        end
    end else begin
        for(i = 0;i < 6;i = i + 1)begin
            sort_sel[i] = mult_sel[i];
        end
    end
end

////ADD
reg [10:0] add_in1;
reg [8:0] add_in2;
wire[10:0] add_out;

////MUL
reg [8:0] mul_in1;
reg [8:0] mul_in2;
wire[17:0]mul_out;
//wire [10:0] mul_pa1;
//wire [9:0]  mul_pa2;
//wire [8:0]  mul_pa3;
//wire [8:0]  mul_pa4;

reg [17:0]tmp_result;
reg [8:0] result;
////OUTPUT
//reg [2:0] add_cnt;
//reg [10:0] output_arr [5:0];

///////////
//  FSM  //
///////////
wire inv_last = all_cnt == 'd5 && inv_cnt == 15 && mul_cnt == 3;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cs <= ST_IDLE;
    else begin
        case(cs)
            ST_IDLE:    if(in_valid)   cs <= ST_INPUT;
            ST_INPUT:   if(all_cnt == 5) begin
                            if(mode[0])
                                cs <= ST_INV;
                            else if(mode[1])
                                cs <= ST_MUL;
                            else if(mode[2])
                                cs <= ST_SORT;
                            else
                                cs <= ST_ADD;
                        end
            ST_INV:     if(inv_last) begin
                            if(mode[1])
                                cs <= ST_MUL;
                            else if(mode[2])
                                cs <= ST_SORT;
                            else
                                cs <= ST_ADD;
                        end

            ST_MUL:     if(all_cnt == 'd12) begin
                            if(mode[2])
                                cs <= ST_SORT;
                            else
                                cs <= ST_ADD;
                        end

            ST_SORT:     if(all_cnt == 'd2) cs <= ST_ADD;

            ST_ADD:     if(all_cnt == 'd6) cs <= ST_OUT;
            ST_OUT:     if(all_cnt == 'd5) cs <= ST_IDLE; 
            
        endcase
    end 
end

/////////////
//  INPUT  //
/////////////
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        all_cnt <= 'd0;
    else if(in_valid||CS_OUT) begin
        if(all_cnt == 'd5)
            all_cnt <= 'd0;
        else
            all_cnt <= all_cnt + 1;
    end else if(CS_ADD) begin
        if(all_cnt == 'd6)
            all_cnt <= 'd0;
        else if(inv_cnt == 'd4)
            all_cnt <= all_cnt + 1;
    end else if(CS_SORT) begin
        if(all_cnt == 'd2)
            all_cnt <= 'd0;
        else
            all_cnt <= all_cnt + 1;
    end else if(CS_MUL) begin
        if(all_cnt == 'd12)
            all_cnt <= 'd0;
        else if(mul_cnt == 'd3)
            all_cnt <= all_cnt + 1;
    end else if(CS_INV) begin
        if(inv_last)
            all_cnt <= 'd0;
        else if(inv_cnt == 'd15 && mul_cnt == 3)
            all_cnt <= all_cnt + 1;
    end else if(CS_IDLE)
        all_cnt <= 'd0;
end

wire clk_in;
wire sleep_in = !(CS_IDLE || CS_INPUT || inv_cnt == 4 );
GATED_OR GATED_IN(.CLOCK(clk),.SLEEP_CTRL(cg_en & sleep_in),.RST_N(rst_n),.CLOCK_GATED(clk_in));
always@(posedge clk_in or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0;i < 6;i = i + 1)begin
            input_arr[i] <= 'd0;
        end
    end else if(CS_IDLE || CS_INPUT) begin
        input_arr[all_cnt] <= in_data;
    end else if(CS_ADD && inv_cnt == 4) begin
        input_arr[all_cnt] <= result;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mode <= 'd0;
    end else if(in_valid && all_cnt == 'd0) begin
        mode <= in_mode;
    end
end
///////////
//  inv  //
///////////
wire sleep_inv = !(mul_cnt == 3 && inv_cnt == 'd15);
GATED_OR GATED_INV(.CLOCK(clk),.SLEEP_CTRL(cg_en & sleep_inv),.RST_N(rst_n),.CLOCK_GATED(clk_inv));
always@(posedge clk_inv or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0;i < 6;i = i + 1)begin
            inv_arr[i] <= 'd0;
        end
    end else if(CS_INV) begin
        if(inv_cnt == 'd15 && mul_cnt == 3)
            inv_arr[all_cnt] <= result;
    end
end

////////////
//  MULT  //
////////////
wire clk_mult;
wire sleep_mult = !(mul_cnt == 3);
GATED_OR GATED_MULT(.CLOCK(clk),.SLEEP_CTRL(cg_en & sleep_mult),.RST_N(rst_n),.CLOCK_GATED(clk_mult));
always@(posedge clk_mult or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0;i < 6;i = i + 1)begin
            mult_arr[i] <= 'd0;
        end
    end else if(CS_MUL && mul_cnt == 'd3) begin
        if(all_cnt == 'd4)
            mult_arr[0] <= result;
        else if(all_cnt == 'd5)
            mult_arr[1] <= result;
        else if(all_cnt == 'd6)
            mult_arr[2] <= result;
        else if(all_cnt == 'd8)
            mult_arr[3] <= result;
        else if(all_cnt == 'd10)
            mult_arr[4] <= result;
        else if(all_cnt == 'd11)
            mult_arr[5] <= result;
    end
end

////////////
//  SORT  //
////////////

reg [8:0] sort_out00,sort_out01,sort_out02,sort_out03,sort_out04,sort_out05;
reg [8:0] sort_out10,sort_out11,sort_out12,sort_out13,sort_out14,sort_out15;
reg [8:0] sort_out20,sort_out21,sort_out22,sort_out23,sort_out24,sort_out25;
reg [8:0] sort_out30,sort_out31,sort_out32,sort_out33,sort_out34,sort_out35;
reg [8:0] sort_out40,sort_out41,sort_out42,sort_out43,sort_out44,sort_out45;
reg [8:0] sort_out50,sort_out51,sort_out52,sort_out53,sort_out54,sort_out55;

wire clk_sort;
wire sleep_sort = !(CS_SORT || ((CS_MUL||CS_INV) && (mul_cnt == 'd3 || mul_cnt == 'd0) ));
//wire sleep_sort = !(CS_SORT || CS_MUL||CS_INV );
GATED_OR GATED_SORT(.CLOCK(clk),.SLEEP_CTRL(cg_en & sleep_sort),.RST_N(rst_n),.CLOCK_GATED(clk_sort));
always@(posedge clk_sort or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0;i < 6;i = i + 1)begin
            sort_arr[i] <= 'd0;
        end
    end else if(CS_MUL && mul_cnt == 'd3) begin
        if (all_cnt == 'd0)begin
            sort_arr[0] <= result;
        end else if (all_cnt == 'd1)begin
            sort_arr[1] <= result;
        end else if (all_cnt == 'd2)begin
            sort_arr[2] <= result;
        end else if (all_cnt == 'd3)begin
            sort_arr[3] <= result;
        end else if (all_cnt == 'd7)begin
            sort_arr[2] <= result;
        end else if (all_cnt == 'd9)begin
            sort_arr[1] <= result;
        end
    end else if(CS_INV) begin
        if(inv_cnt == 'd0)begin
//            tmp_arr[1] <= input_arr[all_cnt];
            sort_arr[0] <= result;
        end else if(inv_cnt == 'd3)begin
            sort_arr[1] <= sort_arr[1];
        end else if(inv_cnt[0])begin
            sort_arr[1] <= result;
        end else begin
            sort_arr[0] <= result;
        end
    end else if(CS_SORT) begin
        if(all_cnt == 'd0)begin
            sort_arr[0] <= sort_out20;
            sort_arr[1] <= sort_out21;
            sort_arr[2] <= sort_out22;
            sort_arr[3] <= sort_out23;
            sort_arr[4] <= sort_out24;
            sort_arr[5] <= sort_out25;
        end else begin
//            sort_arr[0] <= sort_out50;
            sort_arr[1] <= sort_out51;
            sort_arr[2] <= sort_out52;
            sort_arr[3] <= sort_out53;
            sort_arr[4] <= sort_out54;
//            sort_arr[5] <= sort_out55;
        end
    end
end

always@(*)begin
    if(mult_sel[1] < mult_sel[0])begin//AB
        sort_out00 = mult_sel[1];
        sort_out01 = mult_sel[0];
    end else begin
        sort_out00 = mult_sel[0];
        sort_out01 = mult_sel[1];
    end 
    if(mult_sel[3] < mult_sel[2])begin//CD
        sort_out02 = mult_sel[3];
        sort_out03 = mult_sel[2];
    end else begin
        sort_out02 = mult_sel[2];
        sort_out03 = mult_sel[3];
    end 
    if(mult_sel[5] < mult_sel[4])begin//EF
        sort_out04 = mult_sel[5];
        sort_out05 = mult_sel[4];
    end else begin
        sort_out04 = mult_sel[4];
        sort_out05 = mult_sel[5];
    end
    
    sort_out13 = sort_out03;
    sort_out14 = sort_out04;
    if(sort_out02 < sort_out00)begin//AC
        sort_out10 = sort_out02;
        sort_out12 = sort_out00;
    end else begin
        sort_out10 = sort_out00;
        sort_out12 = sort_out02;
    end 
    if(sort_out05 < sort_out01)begin//BF
        sort_out11 = sort_out05;
        sort_out15 = sort_out01;
    end else begin
        sort_out11 = sort_out01;
        sort_out15 = sort_out05;
    end

    sort_out21 = sort_out11;
    sort_out22 = sort_out12;
    if(sort_out14 < sort_out10)begin//AE
        sort_out20 = sort_out14;
        sort_out24 = sort_out10;
    end else begin
        sort_out20 = sort_out10;
        sort_out24 = sort_out14;
    end 
    if(sort_out15 < sort_out13)begin//DF
        sort_out23 = sort_out15;
        sort_out25 = sort_out13;
    end else begin
        sort_out23 = sort_out13;
        sort_out25 = sort_out15;
    end

//    sort_out30 = sort_arr[0];
//    sort_out35 = sort_arr[5];
    if(sort_arr[2] < sort_arr[1])begin//BC
        sort_out31 = sort_arr[2];
        sort_out32 = sort_arr[1];
    end else begin
        sort_out31 = sort_arr[1];
        sort_out32 = sort_arr[2];
    end 
    if(sort_arr[4]<sort_arr[3])begin//DE
        sort_out33 = sort_arr[4];
        sort_out34 = sort_arr[3];
    end else begin
        sort_out33 = sort_arr[3];
        sort_out34 = sort_arr[4];
    end

//    sort_out40 = sort_arr[0];
//    sort_out45 = sort_arr[5];
    if(sort_out33 < sort_out31)begin//BD
        sort_out41 = sort_out33;
        sort_out43 = sort_out31;
    end else begin
        sort_out41 = sort_out31;
        sort_out43 = sort_out33;
    end 
    if(sort_out34<sort_out32)begin//CE
        sort_out42 = sort_out34;
        sort_out44 = sort_out32;
    end else begin
        sort_out42 = sort_out32;
        sort_out44 = sort_out34;
    end

//    sort_out50 = sort_out40;
    sort_out51 = sort_out41;
    sort_out54 = sort_out44;
//    sort_out55 = sort_out45;
    if(sort_out43 < sort_out42)begin//CD
        sort_out52 = sort_out43;
        sort_out53 = sort_out42;
    end else begin
        sort_out52 = sort_out42;
        sort_out53 = sort_out43;
    end
end

///////////
//  add  //
///////////
always@(*)begin
    if((CS_MUL || CS_INV) && mul_cnt > 0) begin
        add_in1 = mul_out[10:0];
        add_in2 = tmp_result[8:0];
    end else if(CS_ADD) begin
        if(inv_cnt == 0)begin
            add_in1 = input_arr[all_cnt];
            add_in2 = inv_sel[all_cnt];
        end else if(inv_cnt == 1)begin
            add_in1 = tmp_result[10:0];
            add_in2 = mult_sel[all_cnt];
        end else if(inv_cnt == 2)begin
            add_in1 = tmp_result[10:0];
            add_in2 = sort_sel[all_cnt];
        end else if(inv_cnt == 3)begin
            add_in1 = mul_out;
            add_in2 = tmp_result[8:0];
        end else if(inv_cnt == 4)begin
            add_in1 = mul_out;
            add_in2 = tmp_result[8:0];
        end else begin
            add_in1 = 'bx;
            add_in2 = 'bx;
        end
    end else begin
        add_in1 = 'bx;
        add_in2 = 'bx;
    end
end
assign add_out = add_in1 + add_in2;


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tmp_result <= 'd0;
    else if(CS_MUL || CS_INV) begin
        if(mul_cnt == 0) tmp_result <= mul_out;
        else tmp_result <= add_out;
    end else if(CS_ADD) begin
        //if(mul_cnt == 0) tmp_result <= mul_out;
        tmp_result <= add_out;
    end
end
//assign result = (mul_cnt == 3)?(add_out > 508)? add_out - 'd509 : add_out :'dx; 
always@(*)begin
    if(CS_MUL||CS_INV)
        result = (mul_cnt == 3)?(add_out > 508)? add_out - 'd509 : add_out :'dx;
    else if(CS_ADD)
        result = (inv_cnt == 4)?(add_out > 508)? add_out - 'd509 : add_out :'dx;
    else 
        result = 'dx;
end
///////////
//  mul  //
///////////
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mul_cnt <= 'd0;
    else if (CS_IDLE)
        mul_cnt <= 'd0;
    else if (CS_MUL||CS_INV)
        mul_cnt <= mul_cnt + 1;
end

always@(*)begin
    if(CS_MUL) begin
        if(mul_cnt == 0) begin
            if(all_cnt == 'd0)begin
                mul_in1 = inv_sel[5];
                mul_in2 = inv_sel[4];
            end else if (all_cnt == 'd1)begin
                mul_in1 = sort_arr[0];
                mul_in2 = inv_sel[3];
            end else if (all_cnt == 'd2)begin
                mul_in1 = sort_arr[1];
                mul_in2 = inv_sel[2];
            end else if (all_cnt == 'd3)begin
                mul_in1 = inv_sel[0];
                mul_in2 = inv_sel[1];
            end else if (all_cnt == 'd4)begin
                mul_in1 = sort_arr[2];
                mul_in2 = inv_sel[1];
            end else if (all_cnt == 'd5)begin
                mul_in1 = sort_arr[2];
                mul_in2 = inv_sel[0];
            end else if (all_cnt == 'd6)begin
                mul_in1 = sort_arr[3];
                mul_in2 = sort_arr[1];
            end else if (all_cnt == 'd7)begin
                mul_in1 = sort_arr[3];
                mul_in2 = inv_sel[2];
            end else if (all_cnt == 'd8)begin
                mul_in1 = sort_arr[2];
                mul_in2 = sort_arr[0];
            end else if (all_cnt == 'd9)begin
                mul_in1 = sort_arr[2];
                mul_in2 = inv_sel[3];
            end else if (all_cnt == 'd10)begin
                mul_in1 = sort_arr[1];
                mul_in2 = inv_sel[5];
            end else if (all_cnt == 'd11)begin
                mul_in1 = sort_arr[1];
                mul_in2 = inv_sel[4];
            end else begin
                mul_in1 = 'bx;
                mul_in2 = 'bx;
            end
        end else begin
            mul_in1 = tmp_result[17:9];
            mul_in2 = 'd3;
        end
    end else if(CS_ADD) begin
        if(inv_cnt > 2)begin
            mul_in1 = tmp_result[10:9];
            mul_in2 = 'd3;
        end else begin
            mul_in1 = 'bx;
            mul_in2 = 'bx;
        end
    end else if(CS_INV) begin
        if(mul_cnt == 0)begin
            if(inv_cnt == 'd0)begin
                mul_in1 = input_arr[all_cnt];
                mul_in2 = input_arr[all_cnt];
            end else if(inv_cnt == 'd1)begin
                mul_in1 = input_arr[all_cnt];
                mul_in2 = sort_arr[0];
    /*        end else if(inv_cnt == 'd3)begin
                mul_in1 = tmp_arr[1];
                mul_in2 = tmp_arr[1];*/
            end else if(inv_cnt[0])begin
                mul_in1 = sort_arr[1];
                mul_in2 = sort_arr[0];
            end else begin
                mul_in1 = sort_arr[0];
                mul_in2 = sort_arr[0];
            end
        end else begin
            mul_in1 = tmp_result[17:9];
            mul_in2 = 'd3;
        end
    end else begin
        mul_in1 = 'bx;
        mul_in2 = 'bx;
    end
end
//always@(posedge clk_mul or negedge rst_n)begin
//    if(!rst_n)begin
//        for(i = 0;i < 4;i = i + 1)begin
//            tmp_arr[i] <= 'd0;
//        end
//    end else if(CS_INV) begin
//        if(inv_cnt == 'd0)begin
////            tmp_arr[1] <= input_arr[all_cnt];
//            tmp_arr[0] <= mul_pa4;
//        end else if(inv_cnt == 'd3)begin
//            tmp_arr[1] <= tmp_arr[1];
//        end else if(inv_cnt[0])begin
//            tmp_arr[1] <= mul_pa4;
//        end else begin
//            tmp_arr[0] <= mul_pa4;
//        end
//    end else begin
//        for(i = 0;i < 4;i = i + 1)begin
//            tmp_arr[i] <= 'bx;
//        end
//    end
//end
//
assign mul_out = mul_in1 * mul_in2;

///////////
//  INV  //
///////////
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        inv_cnt <= 'd0;
    else if (CS_INPUT)
        inv_cnt <= 'd0;
    else if (CS_INV && mul_cnt == 3)
        inv_cnt <= inv_cnt + 1;
    else if (CS_ADD)begin
        if(inv_cnt == 'd4) 
            inv_cnt <= 'd0;
        else
            inv_cnt <= inv_cnt + 1;
    end
end

//////////////
//  OUTPUT  //
//////////////
/*always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        add_cnt <= 'd0;
    else if (CS_INPUT)
        add_cnt <= 'd0;
    else if (CS_ADD)begin
        if(add_cnt == 'd4) 
            add_cnt <= 'd0;
        else
            add_cnt <= add_cnt + 1;
    end
end
*/
assign out_valid =(CS_OUT) ? 'd1 : 'd0;
assign out_data = (CS_OUT) ? input_arr[all_cnt] : 'd0;

//wire clk_out;
//GATED_OR GATED_OUT(.CLOCK(clk),.SLEEP_CTRL(cg_en & !(CS_OUT || CS_OUT2)),.RST_N(rst_n),.CLOCK_GATED(clk_out));
//always@(posedge clk_out or negedge rst_n) begin
//    if(!rst_n) begin
//        out_valid <= 'd0;
//        out_data <= 'd0;
//    end else if(CS_OUT) begin
//        out_valid <= 'd1;
//        out_data <= out_pa3;
//    end else begin
//        out_valid <= 'd0;
//        out_data <= 'd0;
//    end 
//end

endmodule


