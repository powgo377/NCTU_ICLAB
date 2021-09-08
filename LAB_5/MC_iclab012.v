module MC(
	//io
	clk,
	rst_n,
	in_valid,
	in_data,
	size,
	action,
	out_valid,
	out_data
);
//io
input	clk;
input	rst_n;
input	in_valid;
input	[30:0]in_data;
input	[1:0]size;
input	[2:0]action;
output	reg out_valid;
output	reg [30:0]out_data;


//FSM
parameter   ST_IDLE     =   'd0,
            ST_INPUT    =   'd1,
            ST_MULT1    =   'd2,
            ST_MULT2    =   'd3,
            ST_TRAN     =   'd4,
            ST_MIRR     =   'd5,
            ST_ROTA     =   'd6,
            ST_OUT1     =   'd7,
            ST_OUT2     =   'd8,
//out for actoin 3,4,5
            ST_OUT3     =   'd9
;
reg [3:0] cs;
//IN
reg [8:0] input_cnt;
reg [1:0] ff_size0;
reg [4:0] ff_size;
wire[4:0] ff_sizem1  = ff_size  - 1;
reg [8:0] ff_size2;
wire[8:0] ff_size2m1 = ff_size2 - 1;
reg [2:0] ff_action;
reg [30:0]ff_data;

//MULT1
reg [8:0] mult_cnt;
wire [8:0] tmp_row_cnt = (mult_cnt - 3) >> (ff_size0+1);
reg [30:0] ff_tmp_QM,ff_tmp_QC;
reg [61:0] ff_tmp_mult;
reg [30:0] ff_tmp_row [15:0];
wire [32:0] pa1 = ff_tmp_mult[61:31] + ff_tmp_mult[30:0] + ff_tmp_row[tmp_row_cnt];
wire [30:0] pa2 = pa1[32:31] + pa1[30:0];
//wire [30:0] pa3 = pa2[31] + pa2[30:0];

//MULT2
reg [3:0] mult2_cnt;

//MEM
wire CEN = 'd0;
wire OEN = 'd0;

wire [30:0] QM;
wire        WENM;
reg  [3:0]  ym,xm;
wire [7:0]  AM  = {ym,xm};
reg  [30:0] DM;

wire [30:0] QC;
reg         WENC;
reg  [3:0]  yc,xc;
wire [7:0]  AC  = {yc,xc};
reg  [30:0] DC;

//OUT
reg[8:0] output_cnt;

///////////
//  FSM  //
///////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cs <= ST_IDLE;
    else begin
        case(cs)
            ST_IDLE :begin
                if(in_valid)begin
                    if(action == 'd3)
                        cs <= ST_TRAN;
                    else if(action == 'd4)
                        cs <= ST_MIRR;
                    else if(action == 'd5)
                        cs <= ST_ROTA;
                    else
                        cs <= ST_INPUT;
                end
            end
            ST_INPUT:begin
                if(input_cnt == (ff_size2m1+(ff_action == 'd1)) )begin
                    if(ff_action == 'd2)
                        cs <= ST_MULT1;
                    else
                        cs <= ST_OUT1;
                end
            end
            ST_MULT1:if(mult_cnt == ff_size2m1+'d5) cs <= ST_MULT2;
            ST_MULT2:begin
                if(mult2_cnt == ff_sizem1)begin
                    if(ym == ff_sizem1)
                        cs <= ST_OUT1;
                    else
                        cs <= ST_MULT1;
                end
            end
            ST_TRAN:begin
                if(xm == ff_sizem1 &&  ym == ff_sizem1)begin
                        cs <= ST_OUT1;
                end
            end
            ST_MIRR:begin
                if(xm == 'd0 &&  ym == ff_sizem1)begin
                        cs <= ST_OUT1;
                end
            end
            ST_ROTA:begin
                if(xm == ff_sizem1 &&  ym == 'd0)begin
                        cs <= ST_OUT1;
                end
            end
            ST_OUT1:                               cs <= ST_OUT2;
            ST_OUT2:begin
                if(output_cnt == ff_size2m1)begin
                    if(ff_action > 'd2)
                        cs <= ST_OUT3;
                    else
                        cs <= ST_IDLE;
                end
            end
            ST_OUT3: cs <= ST_IDLE;
        endcase
    end
end

//////////
//  IN  //
//////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        input_cnt <= 'd0;
    else if(cs == ST_OUT2)
        input_cnt <= 'd0;
    else if(in_valid || cs == ST_INPUT)
        input_cnt <= input_cnt + 1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_data <= 'd0;
    else
        ff_data <= in_data;
end

always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        ff_size   <= 'd0;
        ff_size2  <= 'd0;
        ff_action <= 'd0;
        ff_size0  <= 'd0;
    end else if (cs == ST_IDLE && in_valid) begin
        if(action == 'd0)begin
            ff_size0 <= size;
            if(size == 'd0)begin
                ff_size  <= 5'b00010;
                ff_size2 <= 9'b000000100;
            end else if(size == 'd1) begin
                ff_size  <= 5'b00100;
                ff_size2 <= 9'b000010000;
            end else if(size == 'd2) begin
                ff_size  <= 5'b01000;
                ff_size2 <= 9'b001000000;
            end else if(size == 'd3) begin
                ff_size  <= 5'b10000;
                ff_size2 <= 9'b100000000;
            end
        end
        ff_action <= action;
    end
end

/////////////
//  MULT1  //
/////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        mult_cnt <= 'd0;
    else if(cs == ST_IDLE)
        mult_cnt <= 'd0;
    else if(cs == ST_MULT2)
        mult_cnt <= 'd0;
    else if(cs == ST_MULT1)begin
        mult_cnt <= mult_cnt + 1;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_tmp_QM <= 'd0;
    else
        ff_tmp_QM <= QM;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_tmp_QC <= 'd0;
    else
        ff_tmp_QC <= QC;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        ff_tmp_mult <= 'd0;
    else
        ff_tmp_mult <= ff_tmp_QC*ff_tmp_QM;
end

integer i;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 16;i = i + 1)begin
            ff_tmp_row[i] <= 'd0;
        end
    end else if (cs == ST_MULT2 && mult2_cnt == ff_sizem1) begin
        for(i = 0;i < 16;i = i + 1)begin
            ff_tmp_row[i] <= 'd0;
        end
    end else if(cs == ST_MULT1) begin
        ff_tmp_row[tmp_row_cnt] <= pa2;
    end
end

/////////////
//  MULT2  //
/////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        mult2_cnt <= 'd0;
    else if(cs == ST_IDLE)
        mult2_cnt <= 'd0;
    else if(cs == ST_MULT1)
        mult2_cnt <= 'd0;
    else if (mult_cnt == ff_sizem1+'d5)
        mult2_cnt <= mult2_cnt + 1;
    else if (cs == ST_MULT2 && mult2_cnt < ff_sizem1)
        mult2_cnt <= mult2_cnt + 1;
end

///////////
//  OUT  //
///////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        output_cnt <= 'd0;
    else if(cs == ST_IDLE)
        output_cnt <= 'd0;
    else if(cs == ST_OUT2)
        output_cnt <= output_cnt + 1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        out_valid <= 'd0;
        out_data <= 'd0;
    end else if (cs == ST_OUT2 && ff_action < 'd3) begin
        out_valid <= 'd1;
        out_data <= QM;
    end else if (cs == ST_OUT3) begin
        out_valid <= 'd1;
        out_data <= 'd0;
    end else begin
        out_valid <= 'd0;
        out_data <= 'd0;
    end
end

///////////
//  MEM  //
///////////
RA1SH mem_I(   .Q(QM),   .CLK(clk),   .CEN(CEN),   .WEN(WENM),   .A(AM),   .D(DM),   .OEN(OEN));
RA1SH mem_O(   .Q(QC),   .CLK(clk),   .CEN(CEN),   .WEN(WENC),   .A(AC),   .D(DC),   .OEN(OEN));

wire is_action345 = cs == ST_TRAN || cs == ST_MIRR || cs == ST_ROTA;
assign WENM = !((in_valid && !(cs == ST_IDLE && action > 'd2)) || cs == ST_MULT2 || is_action345 || (ff_action == 'd1 && cs == ST_INPUT) );
//always@(posedge clk or negedge rst_n)begin
//    if(!rst_n)
//        WENM <= 'd1;
//    else if (in_valid)
//        WENM <= 'd0;
//    else if (mult_cnt == ff_sizem1+'d5)
//        WENM <= 'd0;
//    else if (cs == ST_MULT2 && mult2_cnt < ff_sizem1)
//        WENM <= 'd0;
//    else
//        WENM <= 'd1;
//end
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        ym <= 'd0;
        xm <= 'd0;
    end else if (in_valid || cs >= ST_OUT1) begin
        if(xm == ff_sizem1)begin
            if (ym == ff_sizem1) begin
                ym <= 'd0;
                xm <= 'd0;
            end else begin
                ym <= ym + 1;
                xm <= 'd0;
            end
        end else if((action == 'd1 || action == 'd3) && cs == ST_IDLE) begin
            xm <= xm;
        end else if(action == 'd4 && cs == ST_IDLE) begin
            xm <= ff_sizem1;
        end else if(action == 'd5 && cs == ST_IDLE) begin
            xm <= xm;
            ym <= ff_sizem1;
        end else begin
            xm <= xm + 1;
        end
    end else if (cs == ST_MULT2) begin
        if(mult2_cnt == ff_sizem1)begin
            if(ym == ff_sizem1)
                ym <= 'd0;
            else
                ym <= ym + 1;
            xm <= 'd0;
        end else
            xm <= xm + 1;
    end else if (cs == ST_MULT1) begin
        if(mult_cnt == ff_size2m1+'d5)begin
            xm <= 'd0;
        end else if(xm == ff_sizem1)begin
            xm <= 'd0;
        end else begin
            xm <= xm + 1;
        end
    end else if (cs == ST_TRAN) begin
        if(ym == ff_sizem1)begin
            if (xm == ff_sizem1) begin
                xm <= 'd0;
                ym <= 'd0;
            end else begin
                xm <= xm + 1;
                ym <= 'd0;
            end
        end else begin
            ym <= ym + 1;
        end
    end else if (cs == ST_MIRR) begin
        if(xm == 'd0)begin
            if (ym == ff_sizem1) begin
                ym <= 'd0;
                xm <= 'd0;
            end else begin
                ym <= ym + 1;
                xm <= ff_sizem1;
            end
        end else begin
            xm <= xm - 1;
        end
    end else if (cs == ST_ROTA) begin
        if(ym == 'd0)begin
            if (xm == ff_sizem1) begin
                ym <= 'd0;
                xm <= 'd0;
            end else begin
                ym <= ff_sizem1;
                xm <= xm + 1;
            end
        end else begin
            ym <= ym - 1;
        end
    end else if ((cs == ST_IDLE) ||(cs == ST_INPUT && input_cnt == ff_size2) )begin
        ym <= 'd0;
        xm <= 'd0;
    end
end
wire [31:0] tmp_add = ff_data+QC;
wire [30:0] pa_add = tmp_add[31]+tmp_add[30:0];
//assign DM = (cs == ST_MULT2)? ff_tmp_row[mult2_cnt] : (ff_action == 'd1)? pa_add :(in_valid) ? in_data : 'd0;
always@(*)begin
    if (cs == ST_MULT2)
        DM = ff_tmp_row[mult2_cnt];
    else if (ff_action == 'd1 && cs == ST_INPUT)
        DM = pa_add;
    else if (in_valid)
        DM = in_data;
    else if (cs == ST_TRAN || cs == ST_MIRR || cs == ST_ROTA)
        DM = QC;
    else
        DM = 'd0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        WENC <= 'd1;
    else if (cs == ST_OUT2)
        WENC <= 'd0;
    else if (cs == ST_IDLE)
        WENC <= 'd1;
end
always@(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        yc <= 'd0;
        xc <= 'hffff;
    end else if (cs == ST_OUT1) begin
        yc <= 'd0;
        xc <= 'hffff;
    end else if (cs == ST_OUT2 || cs == ST_TRAN || cs == ST_MIRR || cs == ST_ROTA) begin
        if(xc == ff_sizem1)begin
            if (yc == ff_sizem1 || ( WENM && WENC)) begin
                yc <= 'd0;
                xc <= 'd0;
            end else begin
                yc <= yc + 1;
                xc <= 'd0;
            end
        end else begin
            xc <= xc + 1;
        end
    end else if (cs == ST_MULT2) begin
        if(mult2_cnt == ff_sizem1)begin
            yc <= 'd0;
            xc <= 'd0;
        end else
            xc <= xc + 1;
    end else if (cs == ST_MULT1) begin
        if(yc == ff_sizem1)begin
            if (xc == ff_sizem1) begin
                xc <= 'd0;
                yc <= 'd0;
            end else begin
                xc <= xc + 1;
                yc <= 'd0;
            end
        end else begin
            yc <= yc + 1;
        end
    end else if (in_valid) begin
        if((cs == ST_IDLE && (action == 'd1 || action == 'd3 || action == 'd4 || action == 'd5) ) || ff_action == 'd1) begin
            if(xc == ff_sizem1)begin
                if (yc == ff_sizem1) begin
                    yc <= 'd0;
                    xc <= 'd0;
                end else begin
                    yc <= yc + 1;
                    xc <= 'd0;
                end
            end else begin
                xc <= xc + 1;
            end
        end else if(ff_action == 'd2)begin
            yc <= 'd0;
            xc <= 'd0;
        end else begin
            yc <= 'd0;
            xc <= 'hffff;
        end
    end else if (cs == ST_IDLE) begin
        yc <= 'd0;
        xc <= 'd0;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        DC <= 'd0;
    else if (cs == ST_OUT2)
        DC <= QM;
end

//wire [61:0 ]tmp_mux = in_data_arr[0]*in_data_arr[1];
//assign out_data = (input_cnt == 'd2)? tmp_mux[61:31] : 0 ;

//wire [30:0] out1,B_out;
//wire [31:0] A_out;
//MULT_BY_SHIFT mbs(.in1(in_data_arr[0]),.in2(in_data_arr[1]),.A_in({1'b0,in_data_arr[0]}),.B_in(in_data_arr[0]),.out1(out1),.A_out(A_out),.B_out(B_out));

endmodule

//////////////////////////
////////  MODULE  ////////
//////////////////////////

module MULT_BY_SHIFT(in1,in2,A_in,B_in,out1,A_out,B_out);
input [30:0] in1,in2,B_in;
input [31:0] A_in;
output [30:0] out1,B_out;
output [31:0] A_out;

assign out1 = {1'b0,in1[30:1]};
assign A_out = A_in[31:1] + in2;
assign B_out = {A_in[0],B_in[30:1]};
endmodule 
