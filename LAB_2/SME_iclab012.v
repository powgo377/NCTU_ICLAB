module SME(
    clk,
    rst_n,
    chardata,
    isstring,
    ispattern,
    out_valid,
    match,
    match_index
);

input clk;
input rst_n;
input [7:0] chardata;
input isstring;
input ispattern;
output reg match;
output reg [4:0] match_index;
output reg out_valid;

parameter   ST_IDLE         =   3'd0,
            ST_INPUT        =   3'd1,
            ST_IDLE_P       =   3'd2,
            ST_INPUT_P      =   3'd3,
            ST_JUDG         =   3'd4,
            ST_JUDG2        =   3'd5,
            ST_OUT          =   3'd6;
reg [2:0] cs;

//reg is_input_str;
reg [5:0] input_cnt;
reg [3:0] input_cnt_p;
reg [7:0] input_arr [33:0];
reg [7:0] input_arr_p [7:0];
wire star_skip = (chardata == 8'h2a);
reg [1:0] star_mode;
reg [2:0] star_index;

reg is_head_start;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        is_head_start <= 0;
    else if (ispattern && input_cnt_p == 0 && chardata == 8'h5E)
        is_head_start <= 1;
    else if (cs == ST_OUT)
        is_head_start <= 0;
    else 
        is_head_start <= is_head_start;
end
////unsign better?!
wire head_shift = 1-is_head_start;
wire is_tail = (input_arr_p[input_cnt_p-1] == 8'h24);

reg [4:0] judg_i;
reg is_equal;

reg match_arr[7:0];
wire [3:0] cmp_cnt = (star_mode == 2'b01)? (input_cnt_p-star_index) : ((star_mode == 2'b10)? star_index:input_cnt_p);
reg [3:0] prev_cmp_cnt;
wire [3:0] match_cnt =(('d0 >= prev_cmp_cnt) & ('d0 < cmp_cnt) &  match_arr[0]) +
            (('d1 >= prev_cmp_cnt) & ('d1 < cmp_cnt) & match_arr[1]) + 
            (('d2 >= prev_cmp_cnt) & ('d2 < cmp_cnt) & match_arr[2]) + 
            (('d3 >= prev_cmp_cnt) & ('d3 < cmp_cnt) & match_arr[3]) + 
            (('d4 >= prev_cmp_cnt) & ('d4 < cmp_cnt) & match_arr[4]) + 
            (('d5 >= prev_cmp_cnt) & ('d5 < cmp_cnt) & match_arr[5]) + 
            (('d6 >= prev_cmp_cnt) & ('d6 < cmp_cnt) & match_arr[6]) + 
            (('d7 >= prev_cmp_cnt) & ('d7 < cmp_cnt) & match_arr[7]); 
wire judg_succ = match_cnt == cmp_cnt - prev_cmp_cnt;
wire judg_last = judg_i == (input_cnt - input_cnt_p-1+is_tail+is_head_start); 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        prev_cmp_cnt <= 0;
    else if(cs == ST_INPUT_P)
        prev_cmp_cnt <= 0;
    else if(judg_succ && star_mode == 2'b10)
        prev_cmp_cnt <= cmp_cnt;
end
reg fake_head;
integer i;

///////////
//  FSM  //
///////////
always@(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs <= ST_IDLE;
    else
        case(cs)
            ST_IDLE:begin
                if(isstring)
                    cs <= ST_INPUT;
                else if(ispattern)
                    cs <= ST_INPUT_P;
            end

            ST_INPUT:begin
                if(!isstring)
                    cs <= ST_IDLE_P;
            end

            ST_IDLE_P:begin
                if(ispattern)
                    cs <= ST_INPUT_P;
            end

            ST_INPUT_P:begin
                if(!ispattern)
                    cs <= ST_JUDG;
            end

            ST_JUDG:begin
                if(judg_succ && star_mode == 2'b10)
                    cs <= ST_JUDG2;
                else if(judg_succ || judg_last)
                    cs <= ST_OUT;
            end

            ST_JUDG2:
                cs <= ST_JUDG;

            ST_OUT:
                cs <= ST_IDLE;

            default:
                cs <= cs;

        endcase
end

/////////////
//  INPUT  //
/////////////
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        input_cnt <= 'd2;
    else if (cs == ST_IDLE && isstring)
        input_cnt <= 'd2;
    else if (isstring)
        input_cnt <= input_cnt + 1;
    else
        input_cnt <= input_cnt;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        input_cnt_p <= 'd0;
    else if (ispattern) begin
        if(!star_skip)
            input_cnt_p <= input_cnt_p + 1;
    end else if (cs == ST_OUT)
        input_cnt_p <= 'd0;
    else
        input_cnt_p <= input_cnt_p;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0;i<33;i = i+1)begin
            input_arr[i] <= 'd0;
        end
    end else if (isstring) begin
        if (cs == ST_IDLE)
            input_arr[1] <= chardata;
        else begin
            input_arr[input_cnt] <= chardata;
            input_arr[input_cnt + 1] <= 8'h24;
        end
    end else if (cs == ST_IDLE) 
        input_arr[0] <= 8'h5e;
    //end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i = 0;i<8;i = i+1)begin
            input_arr_p[i] <= 'd0;
        end
    end else if (ispattern) begin
        if (!star_skip)
            input_arr_p[input_cnt_p] <= chardata;
    end
end

reg last_star_flag;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
            last_star_flag <= 'd0;
            star_mode <= 2'b00;
            star_index <= 'd0;
    end else if (ispattern) begin
        if (star_skip) begin
            if (input_cnt_p == 'd0) 
                star_mode <= 2'b01;
            else
                star_mode <= 2'b10;
            star_index <= input_cnt_p;
            last_star_flag <= 'd1;
        end else
            last_star_flag <= 'd0;
    end else if (!ispattern && last_star_flag && input_cnt_p != 'd0)begin
            star_mode <= 'd0;
            star_index <= 'd0;
    end else if (cs == ST_IDLE || cs == ST_OUT) begin
            star_mode <= 'd0;
            star_index <= 'd0;
    end else if (cs == ST_JUDG2)begin
            star_mode <= 2'b11;
    end        
end
////////////
//  JUDG  //
////////////

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        judg_i <= 'd0;
    else if(cs == ST_INPUT_P) begin
        judg_i <= 'd0;
    end else if(cs == ST_JUDG && ! (judg_succ || judg_last) ) begin
        judg_i <= judg_i + 'd1;
    end
end

reg prev_fake_head;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        prev_fake_head <= 'd0;
    else
        prev_fake_head <= fake_head;
end
wire[5:0] tmp = judg_i+head_shift;
////first judg
always@(*) begin
    //// [^ ] [^]
    if( ((input_arr[tmp] == 8'h20) || (input_arr[tmp] == 8'h5e) ) && (input_arr_p[0] == 8'h5E) )begin
        fake_head = 'd1;
        match_arr[0] = 'd1;
    end else begin
        fake_head = 'd0;
        //// __ [.]
        if(input_arr_p[0] == 8'h2e)begin
            //// [^] [.]
            if((input_arr[tmp] == 8'h5E)) 
                match_arr[0] = 'd0;
            //// [a ] [.]
            else
                match_arr[0] = 'd1;
        ////// [ ] [$]
        end else begin
            if(input_arr[tmp] == input_arr_p[0]) 
                match_arr[0] = 'd1;
            else
                match_arr[0] = 'd0;
        end
    end
end

//// 1-7 judg
always@(*) begin
    for(i = 1;i < 8;i = i + 1) begin
        //// [a ] [.]
        if(input_arr_p[i] == 8'h2e)begin
                match_arr[i] = 'd1;
        //// [ ] [^$]
        end else if( (input_arr[tmp+i] == 8'h20) && ((input_arr_p[i] == 8'h5E) || (input_arr_p[i] == 8'h24)) )begin
            match_arr[i] = 'd1;
        end else  if(input_arr[tmp+i] == input_arr_p[i]) 
            match_arr[i] = 'd1;
        else
            match_arr[i] = 'd0;
    end
end


//////////////
//  OUTPUT  //
//////////////
reg [4:0] prev_match_index;
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        prev_match_index <= 'd0;
    else if(cs == ST_JUDG2)
        prev_match_index <= judg_i - 1 + prev_fake_head+head_shift;
    else if(cs == ST_INPUT_P)
        prev_match_index <= 'd0;
end

always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid   <= 'd0;
        match       <= 'd0;
        match_index <= 'd0;
    end else if(cs == ST_OUT) begin
        out_valid   <= 'd0;
        match       <= 'd0;
        match_index <= 'd0;
    end else if(cs == ST_JUDG && judg_succ && !(star_mode == 2'b10))begin
        out_valid   <= 'd1;
        match       <= 'd1;
        if(star_mode == 2'b01)
            match_index <= 'd0;
        else if (star_mode == 2'b11)
            match_index <= prev_match_index;
        else
            match_index <= judg_i - 'd1 + fake_head+head_shift;
    end else if(cs == ST_JUDG && judg_last && !judg_succ)begin
        out_valid   <= 'd1;
        match       <= 'd0;
        match_index <= 'd0;
    end
end

endmodule
