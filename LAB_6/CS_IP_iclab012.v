module CS_IP
#(parameter WIDTH_DATA = 128, parameter WIDTH_RESULT = 8)
(
    data,
    in_valid,
    clk,
    rst_n,
    result,
    out_valid
);

input [(WIDTH_DATA-1):0] data;
input in_valid, clk, rst_n;

wire [(WIDTH_RESULT-1):0] result_my;
wire [(WIDTH_RESULT-1):0] result_my_m2;
output wire [(WIDTH_RESULT-1):0] result;
output reg out_valid;

genvar i,j,k,l;
generate
for(l = WIDTH_RESULT;l==WIDTH_RESULT;l = l + 1)begin:ll
for(k = WIDTH_DATA;k==WIDTH_DATA;k = k + 1)begin:lk
if(k == 384 && l == 8)begin:if0
    wire [ 8:0] sum001 = data[ 15:  8]+data[  7:  0];
    wire [ 8:0] sum002 = data[ 31: 24]+data[ 23: 16];
    wire [ 8:0] sum003 = data[ 47: 40]+data[ 39: 32];
    wire [ 8:0] sum004 = data[ 63: 56]+data[ 55: 48];
    wire [ 8:0] sum005 = data[ 79: 72]+data[ 71: 64];
    wire [ 8:0] sum006 = data[ 95: 88]+data[ 87: 80];
    wire [ 8:0] sum007 = data[111:104]+data[103: 96];
    wire [ 8:0] sum008 = data[127:120]+data[119:112];

    wire [ 9:0] sum011 = sum001 + sum002;
    wire [ 9:0] sum012 = sum003 + sum004;
    wire [ 9:0] sum013 = sum005 + sum006;
    wire [ 9:0] sum014 = sum007 + sum008;

    reg  [ 9:0] ff_sum011;
    reg  [ 9:0] ff_sum012;
    reg  [ 9:0] ff_sum013;
    reg  [ 9:0] ff_sum014;

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ff_sum011 <= 'd0;
            ff_sum012 <= 'd0;
            ff_sum013 <= 'd0;
            ff_sum014 <= 'd0;
        end else begin
            ff_sum011 <= sum011;
            ff_sum012 <= sum012;
            ff_sum013 <= sum013;
            ff_sum014 <= sum014;
        end 
    end

    wire [10:0] sum021 = ff_sum011 + ff_sum012;
    wire [10:0] sum022 = ff_sum013 + ff_sum014;
    
    wire [11:0] sum031 = sum021 + sum022;

    wire [ 8:0] sum101 = data[128+ 15:128+  8]+data[128+  7:128+  0];
    wire [ 8:0] sum102 = data[128+ 31:128+ 24]+data[128+ 23:128+ 16];
    wire [ 8:0] sum103 = data[128+ 47:128+ 40]+data[128+ 39:128+ 32];
    wire [ 8:0] sum104 = data[128+ 63:128+ 56]+data[128+ 55:128+ 48];
    wire [ 8:0] sum105 = data[128+ 79:128+ 72]+data[128+ 71:128+ 64];
    wire [ 8:0] sum106 = data[128+ 95:128+ 88]+data[128+ 87:128+ 80];
    wire [ 8:0] sum107 = data[128+111:128+104]+data[128+103:128+ 96];
    wire [ 8:0] sum108 = data[128+127:128+120]+data[128+119:128+112];

    wire [ 9:0] sum111 = sum101 + sum102;
    wire [ 9:0] sum112 = sum103 + sum104;
    wire [ 9:0] sum113 = sum105 + sum106;
    wire [ 9:0] sum114 = sum107 + sum108;

    reg  [ 9:0] ff_sum111;
    reg  [ 9:0] ff_sum112;
    reg  [ 9:0] ff_sum113;
    reg  [ 9:0] ff_sum114;

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ff_sum111 <= 'd0;
            ff_sum112 <= 'd0;
            ff_sum113 <= 'd0;
            ff_sum114 <= 'd0;
        end else begin
            ff_sum111 <= sum111;
            ff_sum112 <= sum112;
            ff_sum113 <= sum113;
            ff_sum114 <= sum114;
        end 
    end

    wire [10:0] sum121 = ff_sum111 + ff_sum112;
    wire [10:0] sum122 = ff_sum113 + ff_sum114;
    
    wire [11:0] sum131 = sum121 + sum122;

    wire [ 8:0] sum201 = data[256+ 15:256+  8]+data[256+  7:256+  0];
    wire [ 8:0] sum202 = data[256+ 31:256+ 24]+data[256+ 23:256+ 16];
    wire [ 8:0] sum203 = data[256+ 47:256+ 40]+data[256+ 39:256+ 32];
    wire [ 8:0] sum204 = data[256+ 63:256+ 56]+data[256+ 55:256+ 48];
    wire [ 8:0] sum205 = data[256+ 79:256+ 72]+data[256+ 71:256+ 64];
    wire [ 8:0] sum206 = data[256+ 95:256+ 88]+data[256+ 87:256+ 80];
    wire [ 8:0] sum207 = data[256+111:256+104]+data[256+103:256+ 96];
    wire [ 8:0] sum208 = data[256+127:256+120]+data[256+119:256+112];

    wire [ 9:0] sum211 = sum201 + sum202;
    wire [ 9:0] sum212 = sum203 + sum204;
    wire [ 9:0] sum213 = sum205 + sum206;
    wire [ 9:0] sum214 = sum207 + sum208;

    reg  [ 9:0] ff_sum211;
    reg  [ 9:0] ff_sum212;
    reg  [ 9:0] ff_sum213;
    reg  [ 9:0] ff_sum214;

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ff_sum211 <= 'd0;
            ff_sum212 <= 'd0;
            ff_sum213 <= 'd0;
            ff_sum214 <= 'd0;
        end else begin
            ff_sum211 <= sum211;
            ff_sum212 <= sum212;
            ff_sum213 <= sum213;
            ff_sum214 <= sum214;
        end 
    end

    wire [10:0] sum221 = ff_sum211 + ff_sum212;
    wire [10:0] sum222 = ff_sum213 + ff_sum214;
    
    wire [11:0] sum231 = sum221 + sum222;

    wire [13:0] sum_3 = sum031 + sum131 + sum231;
    ///////////
    //  OUT  //
    ///////////
    reg [13:0] ff_sum_3;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            ff_sum_3 <= 'd0;
        else
            ff_sum_3 <= sum_3;
    end
    wire [ 8:0] tmp   = ff_sum_3[13:8]+ff_sum_3[7:0];
    assign result_my  = tmp  [8]   +tmp  [7:0];
    
    reg can_out;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            can_out <= 'd0;
        else if (in_valid)
            can_out <= 'd1;
        else 
            can_out <= 'd0;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_valid <= 'd0;
        end else if(can_out) begin
            out_valid <= 'd1;
        end else begin
            out_valid <= 'd0;
        end
    end
    assign result = (out_valid)? ~result_my : 'd0;

end else if(k == 128 && l == 8)begin:if2
    wire [ 8:0] sum01 = data[ 15:  8]+data[  7:  0];
    wire [ 8:0] sum02 = data[ 31: 24]+data[ 23: 16];
    wire [ 8:0] sum03 = data[ 47: 40]+data[ 39: 32];
    wire [ 8:0] sum04 = data[ 63: 56]+data[ 55: 48];
    wire [ 8:0] sum05 = data[ 79: 72]+data[ 71: 64];
    wire [ 8:0] sum06 = data[ 95: 88]+data[ 87: 80];
    wire [ 8:0] sum07 = data[111:104]+data[103: 96];
    wire [ 8:0] sum08 = data[127:120]+data[119:112];

    wire [ 9:0] sum11 = sum01 + sum02;
    wire [ 9:0] sum12 = sum03 + sum04;
    wire [ 9:0] sum13 = sum05 + sum06;
    wire [ 9:0] sum14 = sum07 + sum08;

    reg  [ 9:0] ff_sum11;
    reg  [ 9:0] ff_sum12;
    reg  [ 9:0] ff_sum13;
    reg  [ 9:0] ff_sum14;

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            ff_sum11 <= 'd0;
            ff_sum12 <= 'd0;
            ff_sum13 <= 'd0;
            ff_sum14 <= 'd0;
        end else begin
            ff_sum11 <= sum11;
            ff_sum12 <= sum12;
            ff_sum13 <= sum13;
            ff_sum14 <= sum14;
        end 
    end

    wire [10:0] sum21 = ff_sum11 + ff_sum12;
    wire [10:0] sum22 = ff_sum13 + ff_sum14;
    
    wire [11:0] sum31 = sum21 + sum22;

    wire [ 8:0] tmp   = sum31[11:8]+sum31[7:0];
    assign result_my  = tmp  [8]   +tmp  [7:0];
    ///////////
    //  OUT  //
    ///////////
    reg [(WIDTH_RESULT-1):0] ff_result;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            ff_result <= 'd0;
        else
            ff_result <= result_my;
    end
    
    reg can_out;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            can_out <= 'd0;
        else if (in_valid)
            can_out <= 'd1;
        else 
            can_out <= 'd0;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_valid <= 'd0;
        end else if(can_out) begin
            out_valid <= 'd1;
        end else begin
            out_valid <= 'd0;
        end
    end
    assign result = (out_valid)? ~ff_result : 'd0;
    
end else begin:if1
    for(j = WIDTH_RESULT; j <= WIDTH_DATA;j = (j<<1))begin:loop_j
        for(i = 0 ; i < (WIDTH_DATA/j)/2 ; i = i+1)begin:loop_i
            wire [WIDTH_RESULT-1:0] tmp_a      ; 
            wire [WIDTH_RESULT-1:0] tmp_b      ; 
            wire [WIDTH_RESULT:0]   tmp_result ; 
            wire [WIDTH_RESULT-1:0] tmp_result2; 
            if(j == WIDTH_RESULT)begin:if21
                assign tmp_a       = data[(2*i+1)*WIDTH_RESULT-1:2*i*WIDTH_RESULT];
                assign tmp_b       = data[(2*i+2)*WIDTH_RESULT-1:(2*i+1)*WIDTH_RESULT];
                assign tmp_result  = tmp_a + tmp_b;
                assign tmp_result2 = tmp_result[WIDTH_RESULT]+tmp_result[WIDTH_RESULT-1:0];
                if (WIDTH_RESULT == WIDTH_DATA/2)begin:ifff
                    assign result_my_m2= tmp_result2;
                end
            end else if(j == WIDTH_DATA/2) begin:if22
                assign tmp_a       = ll[l].lk[k].if1.loop_j[j/2].loop_i[i*2  ].tmp_result2;
                assign tmp_b       = ll[l].lk[k].if1.loop_j[j/2].loop_i[i*2+1].tmp_result2;
                assign tmp_result  = tmp_a + tmp_b;
                assign result_my   = tmp_result[WIDTH_RESULT]+tmp_result[WIDTH_RESULT-1:0];
            end else begin:if23
                assign tmp_a       = ll[l].lk[k].if1.loop_j[j/2].loop_i[i*2  ].tmp_result2;
                assign tmp_b       = ll[l].lk[k].if1.loop_j[j/2].loop_i[i*2+1].tmp_result2;
                assign tmp_result  = tmp_a + tmp_b;
                assign tmp_result2 = tmp_result[WIDTH_RESULT]+tmp_result[WIDTH_RESULT-1:0];
            end
        end
    end
    ///////////
    //  OUT  //
    ///////////
    //assign out_valid= (in_valid)? 'd1 : 'd0;
    //assign result   = (in_valid)? ((WIDTH_RESULT == WIDTH_DATA)?data:result_my) : 'd0;  
    reg [(WIDTH_RESULT-1):0] ff_result;
    reg can_out;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            ff_result <= 'd0;
        else if (can_out)
            ff_result <= ff_result ;
        else if (WIDTH_RESULT == WIDTH_DATA)
            ff_result <= data;
        else if (WIDTH_RESULT == WIDTH_DATA/2)
            ff_result <= result_my_m2;
        else
            ff_result <= result_my;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            can_out <= 'd0;
        else if (in_valid)
            can_out <= 'd1;
        else 
            can_out <= 'd0;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_valid <= 'd0;
        end else if(can_out) begin
            out_valid <= 'd1;
        end else begin
            out_valid <= 'd0;
        end
    end
    assign result = (out_valid)? ~ff_result : 'd0;
end
end
end
endgenerate


endmodule
