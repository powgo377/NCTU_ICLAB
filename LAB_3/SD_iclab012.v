module SD(
    //Input Port
    clk,
    rst_n,
	in_valid,
	in,

    //Output Port
    out_valid,
    out
    );

//-----------------------------------------------------------------------------------------------------------------
//   PORT DECLARATION                                                  
//-----------------------------------------------------------------------------------------------------------------
input            clk, rst_n, in_valid;
input [3:0]		 in;
output reg		 out_valid;
output reg [3:0] out;
    
//-----------------------------------------------------------------------------------------------------------------
//   PARAMETER DECLARATION                                             
//-----------------------------------------------------------------------------------------------------------------
parameter   ST_IDLE     =   'd0,
            ST_INPUT    =   'd1,
            ST_IN_WRONG =   'd2,
            ST_SUDO     =   'd3,
            ST_OUT      =   'd4;
reg [2:0]   cs;

reg [3:0]   x,y;
wire x8y8 = x == 'd8 && y == 'd8;

reg [3:0]   input_arr   [8:0]   [8:0];
reg         is_input_fail;

reg [8:0]   row_arr     [8:0];
reg [8:0]   column_arr  [8:0];
reg [8:0]   box_arr     [8:0];

reg [3:0]   cnt_15;
reg [3:0]   z_x [14:0];
reg [3:0]   z_y [14:0];
wire [3:0] cur_x = z_x[cnt_15];
wire [3:0] cur_y = z_y[cnt_15];
wire [3:0] diff_x = (in_valid)?x:cur_x;
wire [3:0] diff_y = (in_valid)?y:cur_y;
wire [1:0] x_3  = (diff_x / 3);
wire [1:0] y_3  = (diff_y / 3);

wire [8:0] three_cond_has = row_arr[cur_y] | column_arr[cur_x] | box_arr[y_3*3+x_3];
reg [3:0] next_min;
wire [3:0] cur_index = input_arr[cur_y][cur_x];
//wire [3:0] cmp11 = (!(three_cond_has[0]|three_cond_has[1]))? () : 'd9;
//always@(*)begin
//    if(!three_cond_has[0]&& (1 > cur_index))
//        next_min = 1;
//    else if(!three_cond_has[1]&& (2 > cur_index))
//        next_min = 2;
//    else if(!three_cond_has[2]&& (3 > cur_index))
//        next_min = 3;
//    else if(!three_cond_has[3]&& (4 > cur_index))
//        next_min = 4;
//    else if(!three_cond_has[4]&& (5 > cur_index))
//        next_min = 5;
//    else if(!three_cond_has[5]&& (6 > cur_index))
//        next_min = 6;
//    else if(!three_cond_has[6]&& (7 > cur_index))
//        next_min = 7;
//    else if(!three_cond_has[7]&& (8 > cur_index))
//        next_min = 8;
//    else if(!three_cond_has[8]&& (9 > cur_index))
//        next_min = 9;
//    else
//        next_min = 10;
//end

reg [3:0] cmp11,cmp12,cmp13,cmp14;
always@(*)begin
    if(!three_cond_has[0]&& (1 > cur_index))
        cmp11 = 1;
    else if(!three_cond_has[1]&& (2 > cur_index))
        cmp11 = 2;
    else
        cmp11 = 10;
end
always@(*)begin
    if(!three_cond_has[2]&& (3 > cur_index))
        cmp12 = 3;
    else if(!three_cond_has[3]&& (4 > cur_index))
        cmp12 = 4;
    else
        cmp12 = 10;
end


always@(*)begin
    if(!three_cond_has[4]&& (5 > cur_index))
        cmp13 = 5;
    else if(!three_cond_has[5]&& (6 > cur_index))
        cmp13 = 6;
    else
        cmp13 = 10;
end

always@(*)begin
    if(!three_cond_has[6]&& (7 > cur_index))
        cmp14 = 7;
    else if(!three_cond_has[7]&& (8 > cur_index))
        cmp14 = 8;
    else
        cmp14 = 10;
end
wire [3:0] cmp21 = (cmp11<cmp12)?cmp11:cmp12;
wire [3:0] cmp22 = (cmp13<cmp14)?cmp13:cmp14;
wire [3:0] cmp31 = (cmp21<cmp22)?cmp21:cmp22;
always@(*)begin
    if(cmp31!='d10)
        next_min = cmp31;
    else if(!three_cond_has[8]&& (9 > cur_index))
        next_min = 9;
    else
        next_min = cmp31;
end









wire [3:0] to_diff= (in_valid)?in:next_min;
wire in_0 = in_valid && in == 'd0;

wire is_row_valid   =  (((input_arr[diff_y][0] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][1] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][2] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][3] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][4] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][5] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][6] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][7] == to_diff)&&(!in_0)) +
                        ((input_arr[diff_y][8] == to_diff)&&(!in_0))) == 'd0;

wire is_cloumn_valid    = (((input_arr[0][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[1][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[2][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[3][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[4][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[5][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[6][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[7][diff_x] == to_diff)&&(!in_0)) +
                           ((input_arr[8][diff_x] == to_diff)&&(!in_0))) == 'd0;
wire [3:0] x_30 = x_3*3  ;
wire [3:0] x_31 = x_3*3+1;
wire [3:0] x_32 = x_3*3+2;
wire [3:0] y_30 = y_3*3  ;
wire [3:0] y_31 = y_3*3+1;
wire [3:0] y_32 = y_3*3+2;

wire is_box_valid   =     (((input_arr[y_30][x_30] == to_diff)&&(!in_0)) +
                           ((input_arr[y_30][x_31] == to_diff)&&(!in_0)) +
                           ((input_arr[y_30][x_32] == to_diff)&&(!in_0)) +
                           ((input_arr[y_31][x_30] == to_diff)&&(!in_0)) +
                           ((input_arr[y_31][x_31] == to_diff)&&(!in_0)) +
                           ((input_arr[y_31][x_32] == to_diff)&&(!in_0)) +
                           ((input_arr[y_32][x_30] == to_diff)&&(!in_0)) +
                           ((input_arr[y_32][x_31] == to_diff)&&(!in_0)) +
                           ((input_arr[y_32][x_32] == to_diff)&&(!in_0))) == 'd0;

wire is_valid = is_row_valid && is_cloumn_valid && is_box_valid;
wire fail_at_9 = next_min == 'd10 || (next_min == 'd9 && !is_valid);
wire succ = cnt_15 == 'd14 && is_valid && cs == ST_SUDO;
wire fail = fail_at_9 && cnt_15 == 'd0 && cs == ST_SUDO;
wire         is_input_fail_w = in_valid && !is_valid;



integer i,j;
//-----------------------------------------------------------------------------------------------------------------
//   LOGIC DECLARATION                                                 
//-----------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------------------
//   Design                                                            
//-----------------------------------------------------------------------------------------------------------------
///////////
//  FSM  //
///////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cs <= ST_IDLE;
    else begin
        case(cs)
            ST_IDLE:begin
                if(in_valid) cs <= ST_INPUT;
            end
        
            ST_INPUT:begin
                if(!in_valid)begin
                    if(is_input_fail||is_input_fail_w) cs <= ST_IN_WRONG;
                    else cs <= ST_SUDO;
                end
            end
    
            ST_IN_WRONG:begin
                cs <= ST_IDLE;
            end

            ST_SUDO:begin
                if(succ||fail) cs <= ST_OUT;
            end
            
            ST_OUT:begin
                if(cnt_15 >= 'd14) cs <= ST_IDLE;
            end
        endcase
    end
end

/////////
// XY  //
/////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        x <= 0;
        y <= 0;
    end else if(x == 'd8)begin
        x <= 0;
        if(y == 'd8)
            y <= 'd0;
        else
            y <= y + 1;
    end else if(in_valid)begin
        x <= x + 1;
    end
end

////////////
//  SUDO  //
////////////

/////////////
//  INPUT  //
/////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        is_input_fail <= 0;
    else if(is_input_fail_w)
        is_input_fail <= 1;
    else if(cs == ST_IDLE)
        is_input_fail <= 0;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cnt_15 <= 'd0;
    else if(x8y8)
        cnt_15 <= 0;
    else if(in_0)
        cnt_15 <= cnt_15 + 1;
    else if(cs == ST_IDLE)
        cnt_15 <= 'd0;
    else if(succ)
        cnt_15 <= 'd1;
    else if(cs == ST_OUT)
        cnt_15 <= cnt_15 + 1;
    else if(cs == ST_SUDO && fail_at_9)
            cnt_15 <= cnt_15 - 1;
    else if(cs == ST_SUDO && is_valid)
        cnt_15 <= cnt_15 + 1;
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 15;i = i + 1)begin
            z_x[i] <= 'd0;
            z_y[i] <= 'd0;
        end
    end else if(in_0)begin
            z_x[cnt_15] <= x;
            z_y[cnt_15] <= y;
    end
end
/////////////////////
/////////////////////
////////////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 9;i = i + 1)begin
            row_arr[i] <= 'd0;
        end
    end else if(in_valid && !in_0)begin
        row_arr[y][in-1] <= 1;
    end else if (cs == ST_IDLE)begin
        for(i = 0;i < 9;i = i + 1)begin
            row_arr[i] <= 'd0;
        end
    end else if(fail_at_9)begin
        row_arr[cur_y][cur_index-1] <= 'd0;
    end else if(cs == ST_SUDO)begin
        row_arr[cur_y][cur_index-1] <= 'd0;
        row_arr[cur_y][next_min-1] <= 'd1;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 9;i = i + 1)begin
            column_arr[i] <= 'd0;
        end
    end else if(in_valid && !in_0)begin
        column_arr[x][in-1] <= 'd1;
    end else if (cs == ST_IDLE)begin
        for(i = 0;i < 9;i = i + 1)begin
            column_arr[i] <= 'd0;
        end
    end else if(fail_at_9)begin
        column_arr[cur_x][cur_index-1] <= 'd0;
    end else if(cs == ST_SUDO)begin
        column_arr[cur_x][cur_index-1] <= 'd0;
        column_arr[cur_x][next_min-1] <= 'd1;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 9;i = i + 1)begin
            box_arr[i] <= 'd0;
        end
    end else if(in_valid && !in_0)begin
        box_arr[y_3*3+x_3][in-1] <= 'd1;
    end else if (cs == ST_IDLE)begin
        for(i = 0;i < 9;i = i + 1)begin
            box_arr[i] <= 'd0;
        end
    end else if(fail_at_9)begin
        box_arr[y_3*3+x_3][cur_index-1] <= 'd0;
    end else if(cs == ST_SUDO)begin
        box_arr[y_3*3+x_3][cur_index-1] <= 'd0;
        box_arr[y_3*3+x_3][next_min-1] <= 'd1;
    end
end
/////////////////////
/////////////////////
////////////////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0;i < 9;i = i + 1)begin
            for(j = 0;j < 9;j = j + 1)
                input_arr [i][j] <= 'd0;
        end
    end else if(in_valid)begin
        input_arr [y][x] <= in;
    end else if (cs == ST_IDLE)begin
        for(i = 0;i < 9;i = i + 1)begin
            for(j = 0;j < 9;j = j + 1)
                input_arr [i][j] <= 'd0;
        end
    end else if(fail_at_9)begin
        input_arr[cur_y][cur_x] <= 'd0;
    end else if(cs == ST_SUDO)begin
        input_arr[cur_y][cur_x] <= next_min;
    end
end



///////////
//  OUT  //
///////////
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out_valid <= 'd0;
    else if(cs == ST_IDLE)
        out_valid <= 'd0;
    else if(succ||fail)
        out_valid <= 'd1;
    else if(cs == ST_OUT && cnt_15 == 'd15)
        out_valid <= 'd0;
    else if(cs == ST_IN_WRONG)
        out_valid <= 'd1;
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        out <= 'd0;
    else if(cs == ST_IDLE)
        out <= 'd0;
    else if(cs == ST_IN_WRONG)
        out <= 'd10;
    else if(cs != ST_OUT)begin
        if(succ)
            out <= input_arr[z_y[0]][z_x[0]];
        else if(fail)
            out <= 'd10;
    end else if(cs == ST_OUT)begin
        if(cnt_15 == 'd15)
            out <= 'd0;
        else
            out <= input_arr[cur_y][cur_x];
    end
end

endmodule
