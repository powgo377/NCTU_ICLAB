
`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"
`include "success.sv"
program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

integer i,j;
integer id,act,cat,amnt;
initial begin
    ////initial
    inf.rst_n       = 'd1;
    inf.act_valid   = 'd0;
    inf.id_valid    = 'd0;
    inf.cat_valid   = 'd0;
    inf.amnt_valid  = 'd0;
    inf.D           = 'dx;

    reset_task;

    //// 1
    //// Sead > Reap > Check > Water > Steal *10
    ////   0      1      2       3       4
    for(i = 0;i < 40;i = i + 1)begin
        id = i % 4;
        if(i % 4 == 0)begin
            input_id;
            ////Seed
            act  = 1;
            input_act;
            cat  = 8;
            input_cat;
            amnt = 1;
            input_amnt;
            check_ans;
        end else if(i % 4 == 1)begin
            input_id;
            ////Reap
            act  = 2;
            input_act;
            check_ans;
            ////CheckDepo
            act  = 8;
            input_act;
            check_ans;
        end else if(i % 4 == 2)begin
            input_id;
            ////Water
            act  = 3;
            input_act;
            amnt = 1;
            input_amnt;
            check_ans;
        end else if(i % 4 == 3)begin
            input_id;
            ////Steal
            act  = 4;
            input_act;
            check_ans;
        end
    end

    //// 2
    //// Sead > Check > Steal > Reap > Water *10
    ////   0      1      2       3       4
    for(i = 40;i < 80;i = i + 1)begin
        id = 4 + (i % 4);
        if(i % 4 == 0)begin
            input_id;
            ////Seed
            act  = 1;
            input_act;
            cat  = 8;
            input_cat;
            amnt = 1;
            input_amnt;
            check_ans;
            ////CheckDepo
            act  = 8;
            input_act;
            check_ans;
        end else if(i % 4 == 1)begin
            input_id;
            ////Steal
            act  = 4;
            input_act;
            check_ans;
        end else if(i % 4 == 2)begin
            input_id;
            ////Reap
            act  = 2;
            input_act;
            check_ans;
        end else if(i % 4 == 3)begin
            input_id;
            ////Water
            act  = 3;
            input_act;
            amnt = 1;
            input_amnt;
            check_ans;
        end
    end
    
    //// 3
    //// Sead > Steal > Water > Check > Reap *10
    ////   0      1      2       3       4
    for(i = 80;i < 120;i = i + 1)begin
        id = 8 + (i % 4);
        if(i % 4 == 0)begin
            input_id;
            ////Seed
            act  = 1;
            input_act;
            cat  = 8;
            input_cat;
            amnt = 1;
            input_amnt;
            check_ans;
        end else if(i % 4 == 1)begin
            input_id;
            ////Steal
            act  = 4;
            input_act;
            check_ans;
        end else if(i % 4 == 2)begin
            input_id;
            ////Water
            act  = 3;
            input_act;
            amnt = 1;
            input_amnt;
            check_ans;
            ////CheckDepo
            act  = 8;
            input_act;
            check_ans;
        end else if(i % 4 == 3)begin
            input_id;
            ////Reap
            act  = 2;
            input_act;
            check_ans;
        end
    end

    //// 4
    //// Sead > Water > Reap > Steal > Check *10
    ////   0      1      2       3       4
    for(i = 120;i < 160;i = i + 1)begin
        id = 12 + (i % 4);
        if(i % 4 == 0)begin
            input_id;
            ////Seed
            act  = 1;
            input_act;
            cat  = 8;
            input_cat;
            amnt = 1;
            input_amnt;
            check_ans;
        end else if(i % 4 == 1)begin
            input_id;
            ////Water
            act  = 3;
            input_act;
            amnt = 1;
            input_amnt;
            check_ans;
        end else if(i % 4 == 2)begin
            input_id;
            ////Reap
            act  = 2;
            input_act;
            check_ans;
        end else if(i % 4 == 3)begin
            input_id;
            ////Steal
            act  = 4;
            input_act;
            check_ans;
            ////CheckDepo
            act  = 8;
            input_act;
            check_ans;
        end
    end

    ////CheckDepo * 10 (C>C*10)
    for(i = 0;i < 10; i = i + 1)begin
        act  = 8;
        input_act;
        check_ans;
    end

    ////Seed * 60 (C>S*1 ERR2*60 Amnt 1*20 12001*40)
    for(i = 160;i < 220; i = i + 1)begin
        id = 16 + (i % 6);
        input_id;
        act  = 1;
        input_act;
        cat  = 8;
        input_cat;
        amnt = (i > 179)? 12001 : 1;
        input_amnt;
        check_ans;
    end

    ////Water * 360 (ERR3 Amnt done)
    for(i = 220;i < 580; i = i + 1)begin
        id = 22 + (i % 36);
        input_id;
        act  = 3;
        input_act;
        amnt = (i < 280)? 12001 : (i < 380)? 24001 : (i < 480)? 36001 : 48001;
        input_amnt;
        check_ans;
    end

    ////Reap * 970 (ERR14 R>R done)
    for(i = 580;i < 1550; i = i + 1)begin
        id = 58 + (i % 97);
        input_id;
        act  = 2;
        input_act;
        check_ans;
    end

    ////Steal * 1000 (ID done S>S done)
    for(i = 1550;i < 2549; i = i + 1)begin
        id = 155 + (i % 100);
        input_id;
        act  = 4;
        input_act;
        check_ans;
    end

    ////last check ans
    id = 204;
    input_id;
    act  = 4;
    input_act;
    while(inf.out_valid !== 1)begin
        @(negedge clk);
        ////if(inf.out__)
    end
    @(posedge clk);
end

task input_id ; begin
//    $display("---------Debug - ID : _%d_",id);
    @(negedge clk);
    inf.id_valid    = 'd1;    
    inf.D           = {8'b0,id};
    @(negedge clk);
    inf.id_valid    = 'd0;    
    inf.D           = 'dx;
end endtask

task input_act ; begin
//    $display("---------Debug - ACT : _%d_",act);
    @(negedge clk);
    inf.act_valid   = 'd1;    
    inf.D           = {12'b0,act};
    @(negedge clk);
    inf.act_valid   = 'd0;    
    inf.D           = 'dx;
end endtask

task input_cat ; begin
    inf.cat_valid   = 'd1;    
    inf.D           = {12'b0,cat};
    @(negedge clk);
    inf.cat_valid   = 'd0;    
    inf.D           = 'dx;
    @(negedge clk);
end endtask

task input_amnt ; begin
//    $display("---------Debug - WATER : _%d_",amnt);
    inf.amnt_valid  = 'd1;    
    inf.D           = amnt;
    @(negedge clk);
    inf.amnt_valid  = 'd0;    
    inf.D           = 'dx;
end endtask

task check_ans ; begin
    while(inf.out_valid !== 1)begin
        @(negedge clk);
        ////if(inf.out__)
    end
    @(negedge clk);
end endtask

task reset_task ; begin
    #(1); inf.rst_n = 0;

    #(7.5);
    
    #(7.5); inf.rst_n = 1 ;
    //#(3.0); release clk;
end endtask

endprogram
