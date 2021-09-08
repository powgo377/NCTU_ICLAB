module farm(input clk, INF.farm_inf inf);
import usertype::*;
wire [31:0] bridge_data_out = {inf.C_data_r[7:0],inf.C_data_r[15:8],inf.C_data_r[23:16],inf.C_data_r[31:24]};

////FSM1
typedef enum {IDLE,SEED,SEED_O,WATER,WATER_O,REAP,REAP_O,STEAL,STEAL_O,CHECK,CHECK_O
,OUT_E1,OUT_E2,OUT_E3,OUT_E4} state;
state cs;
wire CS_SEED    = cs == SEED;
wire CS_SEED_O  = cs == SEED_O;
wire CS_WATER   = cs == WATER;
wire CS_WATER_O = cs == WATER_O;
wire CS_REAP    = cs == REAP;
wire CS_REAP_O  = cs == REAP_O;
wire CS_STEAL   = cs == STEAL;
wire CS_STEAL_O = cs == STEAL_O;
wire CS_CHECK   = cs == CHECK;
wire CS_CHECK_O = cs == CHECK_O;
wire CS_OUT_E1  = cs == OUT_E1;
wire CS_OUT_E2  = cs == OUT_E2;
wire CS_OUT_E3  = cs == OUT_E3;
wire CS_OUT_E4  = cs == OUT_E4;
////FSM2
//logic second_time;
typedef enum {IDLE_B,DEPO,DEPO2,PRE,SAVE,SAVE2,LOAD,LOAD2,READY} state_b;
state_b cs_b;
wire CSB_DEPO   = cs_b == DEPO;
wire CSB_DEPO2  = cs_b == DEPO2;
wire CSB_DEPO3  = cs_b >  DEPO2;
wire CSB_LOAD   = cs_b == LOAD;
wire CSB_LOAD2  = cs_b == LOAD2;
wire CSB_SAVE   = cs_b == SAVE;
wire CSB_SAVE2  = cs_b == SAVE2;
wire CSB_READY  = cs_b == READY;
//logic need_sl,is_first_depo;

////INPUT
logic [7:0] ff_id;
Action      ff_act;
Crop_cat    ff_cat;
logic [15:0]ff_amnt;
logic [31:0]ff_deposit;
logic [31:0]ff_land;

////E R R logic
wire land_empty = ff_land[20];
wire land_n_empty = !ff_land[20];
wire crop_n_grown = ff_land[21];
wire crop_full_water = ff_land[23];

wire stat_12 = ff_land[22] || ff_land[23];
wire can_seed = CSB_READY && CS_SEED && land_empty;
wire can_water = CSB_READY && CS_WATER && (ff_land[21]||ff_land[22]);
wire can_reap = CS_REAP_O && stat_12;
wire can_steal = CS_STEAL_O && stat_12;

///////////
//  FSM  //
///////////
////FSM1
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        cs <= IDLE;
    else begin
        case(cs)
            IDLE:   if(inf.act_valid)begin
                             if(inf.D.d_act[0] == Reap     )    cs <= REAP;
                        else if(inf.D.d_act[0] == Steal    )    cs <= STEAL;
                        else if(inf.D.d_act[0] == Check_dep)    cs <= CHECK;
                    end else if(inf.amnt_valid)begin
                             if(        ff_act == Seed )        cs <= SEED;
                        else if(        ff_act == Water)        cs <= WATER;
                    end
            SEED:   if(CSB_READY) begin
                        if(land_n_empty)                        cs <= OUT_E2;
                        else                                    cs <= SEED_O;
                    end

            WATER:  if(CSB_READY) begin
                        if(land_empty)                          cs <= OUT_E1;
                        else if(crop_full_water)                cs <= OUT_E3;
                        else                                    cs <= WATER_O;
                    end

            REAP:   if(CSB_READY) begin
                        if(land_empty)                          cs <= OUT_E1;
                        else if(crop_n_grown)                   cs <= OUT_E4;
                        else                                    cs <= REAP_O;
                    end

            STEAL:  if(CSB_READY) begin
                        if(land_empty)                          cs <= OUT_E1;
                        else if(crop_n_grown)                   cs <= OUT_E4;
                        else                                    cs <= STEAL_O;
                    end

            CHECK:  if(CSB_DEPO3)                               cs <= CHECK_O;

            SEED_O,WATER_O,REAP_O,STEAL_O,CHECK_O,OUT_E1,OUT_E2,OUT_E3,OUT_E4: cs <= IDLE;
        endcase
    end
end
////FSM2
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        cs_b <= IDLE_B;
    else begin
        case(cs_b)
            IDLE_B:                     cs_b <= DEPO; 
            DEPO:                       cs_b <= DEPO2; 
            DEPO2:  if(inf.C_out_valid) cs_b <= PRE;
            PRE:    if(ff_id != 8'hff)  cs_b <= LOAD;//first time && id comes in
            LOAD:                       cs_b <= LOAD2;
            LOAD2:  if(inf.C_out_valid) cs_b <= READY;
            READY:  if(inf.id_valid)    cs_b <= SAVE;
            SAVE:                       cs_b <= SAVE2;
            SAVE2:  if(inf.C_out_valid) cs_b <= LOAD;
        endcase
    end
end

/*always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        can_go <= 1'b1;
    else if(CSB_LOAD)
        can_go <= 1'b0;
end*/

/*always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        second_time <= 1'b0;
    else if(CSB_LOAD)
        second_time <= 1'b1;
end*/

/////////////
//  INPUT  //
/////////////
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        ff_id <= 8'hff;
    else if(inf.id_valid)
        ff_id <= inf.D.d_id[0];
end

always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        ff_act <= No_action;
    else if(inf.act_valid)
        ff_act <= inf.D.d_act[0];
end

always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        ff_cat <= No_cat;
    else if(inf.cat_valid)
        ff_cat <= inf.D.d_cat[0];
end

always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        ff_amnt <= 'd0;
    else if(inf.amnt_valid)
        ff_amnt <= inf.D.d_amnt;
end

logic signed [5:0] seed_cost;
always_comb begin
    if(ff_cat[0])
        seed_cost = -5;
    else if(ff_cat[1])
        seed_cost = -10;
    else if(ff_cat[2])
        seed_cost = -15;
    else
        seed_cost = -20;
end
logic signed [7:0] reap_earned;
always_comb begin
    if(ff_land[16]) begin
        if(ff_land[22])
            reap_earned = 10;
        else
            reap_earned = 25;
    end else if(ff_land[17]) begin
        if(ff_land[22])
            reap_earned = 20;
        else
            reap_earned = 50;
    end else if(ff_land[18]) begin
        if(ff_land[22])
            reap_earned = 30;
        else
            reap_earned = 75;
    end else begin
        if(ff_land[22])
            reap_earned = 40;
        else
            reap_earned = 100;
    end
end
wire signed [7:0] deposit_change = (CS_SEED)? seed_cost : reap_earned;
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        ff_deposit <= 'd0;
    else if(CSB_DEPO2 && inf.C_out_valid)
        ff_deposit <= bridge_data_out;
    else if(can_seed || can_reap)
        ff_deposit <= $signed(ff_deposit) + $signed(deposit_change);
end

wire [15:0] new_water = ff_amnt+ff_land[15:0];
logic [3:0] new_status;
wire [3:0] cat_in = (CS_SEED)?ff_cat : ff_land[19:16];
always_comb begin
    if(new_water[15:13] > 'd0) //// h2000 
        new_status = 'd8;
    else if(new_water[12:11] > 'd0)begin //// h800
        if(cat_in[3])
            new_status = 'd4;
        else
            new_status = 'd8;
    end else if(new_water[10])begin //// h400
        if(cat_in[3:2] > 0)
            new_status = 'd4;
        else
            new_status = 'd8;
    end else if(new_water[9])begin //// h200
        if(cat_in[2])
            new_status = 'd4;
        else if(cat_in[1:0] > 0)
            new_status = 'd8;
        else
            new_status = 'd2;
    end else if(new_water[8])begin //// h100
        if(cat_in[2:1] > 0)
            new_status = 'd4;
        else if(cat_in[0])
            new_status = 'd8;
        else
            new_status = 'd2;
    end else if(new_water[7])begin //// h80
        if(cat_in[1])
            new_status = 'd4;
        else if(cat_in[0])
            new_status = 'd8;
        else
            new_status = 'd2;
    end else if(new_water[6])begin //// h40
        if(cat_in[1:0] > 0)
            new_status = 'd4;
        else
            new_status = 'd2;
    end else if(new_water[5:4] > 0)begin //// h10
        if(cat_in[0])
            new_status = 'd4;
        else
            new_status = 'd2;
    end else
        new_status = 'd2;
end
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        ff_land <= 'd0;
    else if(CSB_LOAD2 && inf.C_out_valid)
        ff_land <= bridge_data_out;
    else if(can_seed || can_water)
        ff_land[23:0] <= {new_status,cat_in,new_water};
    else if(can_reap || can_steal)
        ff_land[23:0] <= {4'd1,20'd0};
end

//////////////
//  OUTPUT  //
//////////////
always_ff@(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        inf.out_valid   <= 'd0;
    else if( (CSB_READY && (CS_SEED || CS_WATER || CS_REAP || CS_STEAL)) || (CSB_DEPO3 && CS_CHECK) )
        inf.out_valid   <= 'd1;
    else 
        inf.out_valid   <= 'd0;
end

always_comb begin
    if(CS_SEED_O || CS_WATER_O) begin
        inf.err_msg      = No_Err;
        inf.complete     = 'd1;
        inf.out_info     = ff_land;
        inf.out_deposit  = 'd0;
    end else if(CS_REAP_O || CS_STEAL_O) begin
        inf.err_msg      = No_Err;
        inf.complete     = 'd1;
        inf.out_info     = ff_land;
        inf.out_deposit  = 'd0;
    end else if(CS_CHECK_O)begin
        inf.err_msg      = No_Err;
        inf.complete     = 'd1;
        inf.out_info     = 'd0;
        inf.out_deposit  = ff_deposit;
    end else if(CS_OUT_E1) begin
        inf.err_msg      = Is_Empty;
        inf.complete     = 'd0;
        inf.out_info     = 'd0;
        inf.out_deposit  = 'd0;
    end else if(CS_OUT_E2) begin
        inf.err_msg      = Not_Empty;
        inf.complete     = 'd0;
        inf.out_info     = 'd0;
        inf.out_deposit  = 'd0;
    end else if(CS_OUT_E3) begin
        inf.err_msg      = Has_Grown;
        inf.complete     = 'd0;
        inf.out_info     = 'd0;
        inf.out_deposit  = 'd0;
    end else if(CS_OUT_E4) begin
        inf.err_msg      = Not_Grown;
        inf.complete     = 'd0;
        inf.out_info     = 'd0;
        inf.out_deposit  = 'd0;
    end else begin
        inf.err_msg      = No_Err;
        inf.complete     = 'd0;
        inf.out_info     = 'd0;
        inf.out_deposit  = 'd0;
    end
end
////BRIDGE
always_comb begin
    if (CSB_DEPO) begin
        inf.C_addr       = 'hff;
        inf.C_data_w     = 'd0;
        inf.C_in_valid   = 'd1;
        inf.C_r_wb       = 'd1;
    end else if (CSB_LOAD) begin
        inf.C_addr       = ff_id;
        inf.C_data_w     = 'd0;
        inf.C_in_valid   = 'd1;
        inf.C_r_wb       = 'd1;
    end else if (CSB_LOAD2) begin
        inf.C_addr       = ff_id;
        inf.C_data_w     = 'd0;
        inf.C_in_valid   = 'd0;
        inf.C_r_wb       = 'd0;
    end else if (CSB_SAVE) begin
        inf.C_addr       = ff_land[31:24];
        inf.C_data_w     = {ff_land[7:0],ff_land[15:8],ff_land[23:16],ff_land[31:24]};
        inf.C_in_valid   = 'd1;
        inf.C_r_wb       = 'd0;
    end else if (CSB_SAVE2) begin
        inf.C_addr       = ff_land[31:24];
        inf.C_data_w     = {ff_land[7:0],ff_land[15:8],ff_land[23:16],ff_land[31:24]};
        inf.C_in_valid   = 'd0;
        inf.C_r_wb       = 'd0;
    end else begin
        inf.C_addr       = 'd0;
        inf.C_data_w     = 'd0;
        inf.C_in_valid   = 'd0;
        inf.C_r_wb       = 'd0;
    end
end

endmodule
