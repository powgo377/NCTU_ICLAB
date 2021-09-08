module bridge(input clk, INF.bridge_inf inf);

////FSM
typedef enum {IDLE,INPUT_R,WAIT_R,OUT_R,INPUT_W,WRITE,WAIT_W,OUT_W} state;
state cs;
wire CS_IDLE    = (cs == IDLE);
wire CS_N_IDLE  = (cs != IDLE);
wire CS_INPUT_W = (cs == INPUT_W);
wire CS_INPUT_R = (cs == INPUT_R);
wire CS_WRITE   = (cs == WRITE);
wire CS_WAIT_W  = (cs == WAIT_W);
wire CS_OUT_R   = (cs == OUT_R);
wire CS_OUT_W   = (cs == OUT_W);

////input
logic [7:0] ff_addr;
logic [31:0]ff_data;

///////////
//  FSM  //
///////////
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        cs <= IDLE;
    else begin
        case(cs)
            IDLE:   if(inf.C_in_valid)  cs <= (inf.C_r_wb)? INPUT_R : INPUT_W;
            INPUT_R:if(inf.AR_READY)    cs <= WAIT_R;
            WAIT_R: if(inf.R_VALID)     cs <= OUT_R;
            OUT_R:                      cs <= IDLE;

            INPUT_W:if(inf.AW_READY)    cs <= WRITE;
            WRITE:  if(inf.W_READY)     cs <= WAIT_W;
            WAIT_W: if(inf.B_VALID)     cs <= OUT_W;
            OUT_W:                      cs <= IDLE;
            
        endcase
    end
end

/////////////
//  INPUT  //
/////////////
always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)
        ff_addr <= 'd0;
    else if(inf.C_in_valid)
        ff_addr <= inf.C_addr;
end

always_ff@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)
        ff_data <= 'd0;
    else if(inf.C_in_valid)
        ff_data <= inf.C_data_w;
    else if(inf.R_VALID)
        ff_data <= inf.R_DATA;
end

///////////
//  OUT  //
///////////
//wire [7:0] tmp_addr = (CS_IDLE)? inf.C_addr : ff_addr;
wire [7:0] tmp_addr = ff_addr;
wire [16:0] addr = {7'b1000000,tmp_addr,2'b00};
assign inf.AR_VALID     = CS_INPUT_R;
assign inf.AR_ADDR      = (CS_N_IDLE)? addr : 'd0;
assign inf.R_READY      = CS_OUT_R;

assign inf.AW_VALID     = CS_INPUT_W;
assign inf.AW_ADDR      = (CS_N_IDLE)? addr : 'd0;
assign inf.W_VALID      = CS_WRITE;
assign inf.W_DATA       = ff_data;
assign inf.B_READY      = CS_WAIT_W;

assign inf.C_out_valid  = CS_OUT_R || CS_OUT_W;
assign inf.C_data_r     = ff_data;


endmodule
