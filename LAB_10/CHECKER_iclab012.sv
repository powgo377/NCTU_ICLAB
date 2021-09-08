//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

///define cover groups
covergroup COV_AMNT @(posedge clk&&inf.amnt_valid);
    coverpoint inf.D.d_amnt{
        option.at_least = 100;
        bins bin1 = {[    0:12000]};
        bins bin2 = {[12001:24000]};
        bins bin3 = {[24001:36000]};
        bins bin4 = {[36001:48000]};
        bins bin5 = {[48001:60000]};
    }
endgroup

covergroup COV_N_ID @(posedge clk&&inf.id_valid);
    coverpoint inf.D.d_id[0]{
        option.at_least = 10;
        option.auto_bin_max = 255;
    }
endgroup

covergroup COV_ACT @(posedge clk&&inf.act_valid);
    coverpoint inf.D.d_act[0]{
        option.at_least = 10;
        bins t11 = (4'd1=>1);
        bins t12 = (1=>2);
        bins t13 = (1=>3);
        bins t14 = (1=>4);
        bins t18 = (1=>8);
                
        bins t21 = (2=>1);
        bins t22 = (2=>2);
        bins t23 = (2=>3);
        bins t24 = (2=>4);
        bins t28 = (2=>8);
                
        bins t31 = (3=>1);
        bins t32 = (3=>2);
        bins t33 = (3=>3);
        bins t34 = (3=>4);
        bins t38 = (3=>8);
                
        bins t41 = (4=>1);
        bins t42 = (4=>2);
        bins t43 = (4=>3);
        bins t44 = (4=>4);
        bins t48 = (4=>8);
                
        bins t81 = (8=>1);
        bins t82 = (8=>2);
        bins t83 = (8=>3);
        bins t84 = (8=>4);
        bins t88 = (8=>8);
    }
endgroup

covergroup COV_E_RR @(posedge ~clk && inf.out_valid);
    coverpoint inf.err_msg{
        option.at_least = 100;
        bins bin_Is_Empty   =   {1};
        bins bin_Not_Empty  =   {2};
        bins bin_Has_Grown  =   {3};
        bins bin_Not_Grown  =   {4};
    }
endgroup


////initial
COV_AMNT cov_amnt = new();
COV_N_ID cov_n_id = new();
COV_ACT  cov_act  = new();
COV_E_RR cov_e_rr = new();

//always@(negedge clk)begin
//    if(inf.out_valid)begin
//        $display("COV_ID_v= %d",inf.err_msg);
//        $display("COV_ID  = %0.2f %%",cov_e_rr.get_inst_coverage());
//    end
//end


//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end

//write other assertions
logic first_clk;
always@(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n)
        first_clk <= 0;
    else if(inf.rst_n)
        first_clk <= 1;
end
////a1
assert_1 : assert property ( @(posedge first_clk) (inf.out_valid == 0) &&
    inf.err_msg == 0 &&
    inf.complete == 0 &&
    inf.out_deposit == 0 &&
    inf.out_info == 0)
else
begin
	$display("Assertion 1 is violated");
	$fatal; 
end

////a2
assert_2 : assert property ( @(negedge clk)  inf.complete  |-> inf.err_msg == 0)
else
begin
	$display("Assertion 2 is violated");
	$fatal; 
end

////a3
assert_3 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] == 8  |->  inf.out_valid[->1] |-> inf.out_info == 0)
else
begin
	$display("Assertion 3 is violated");
	$fatal; 
end

////a4
assert_4 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] != 8  |->  inf.out_valid[->1] |-> inf.out_deposit == 0)
else
begin
	$display("Assertion 4 is violated");
	$fatal; 
end

////a5
assert_5 : assert property ( @(negedge clk)  inf.out_valid |=>  inf.out_valid == 0)
else
begin
	$display("Assertion 5 is violated");
	$fatal; 
end

////a6
assert_6 : assert property ( @(posedge clk)  inf.id_valid |=> inf.act_valid == 0 )
else
begin
	$display("Assertion 6 is violated");
	$fatal; 
end

////a7
assert_7 : assert property ( @(posedge clk)  inf.act_valid && inf.D.d_act[0] == 1 |->  inf.cat_valid[->1]  |=> inf.amnt_valid == 0 )
else
begin
	$display("Assertion 7 is violated");
	$fatal; 
end

////a8_1
assert_8_1 : assert property ( @(posedge clk)  inf.id_valid |-> (inf.act_valid | inf.cat_valid | inf.amnt_valid) == 0 )
else
begin
	$display("Assertion 8 is violated");
	$fatal; 
end
////a8_2
assert_8_2 : assert property ( @(posedge clk)  inf.act_valid |-> (inf.id_valid | inf.cat_valid | inf.amnt_valid) == 0 )
else
begin
	$display("Assertion 8 is violated");
	$fatal; 
end
////a8_3
assert_8_3 : assert property ( @(posedge clk)  inf.cat_valid |-> (inf.act_valid | inf.id_valid | inf.amnt_valid) == 0 )
else
begin
	$display("Assertion 8 is violated");
	$fatal; 
end
////a8_4
assert_8_4 : assert property ( @(posedge clk)  inf.amnt_valid |-> (inf.act_valid | inf.cat_valid | inf.id_valid) == 0 )
else
begin
	$display("Assertion 8 is violated");
	$fatal; 
end

////a9_1
assert_9_1 : assert property ( @(posedge clk)  inf.out_valid |-> ##[2:10] (inf.id_valid | inf.act_valid) == 1)
else
begin
	$display("Assertion 9 is violated");
	$fatal; 
end

////a9_2
assert_9_2 : assert property ( @(posedge clk)  inf.out_valid |-> ##1 (inf.id_valid | inf.act_valid) != 1)
else
begin
	$display("Assertion 9 is violated");
	$fatal; 
end

////a10_seed
assert_10_1 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] == 1  |-> inf.amnt_valid[->1] |->  ##[1:1199] inf.out_valid == 1)
else
begin
	$display("Assertion 10 is violated");
	$fatal; 
end
////a10_reap
assert_10_2 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] == 2  |->  ##[1:1199] inf.out_valid == 1)
else
begin
	$display("Assertion 10 is violated");
	$fatal; 
end
////a10_water
assert_10_3 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] == 3  |-> inf.amnt_valid[->1] |->  ##[1:1199] inf.out_valid == 1)
else
begin
	$display("Assertion 10 is violated");
	$fatal; 
end
////a10_steal
assert_10_4 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] == 4  |->  ##[1:1199] inf.out_valid == 1)
else
begin
	$display("Assertion 10 is violated");
	$fatal; 
end
////a10_check
assert_10_8 : assert property ( @(negedge clk)  inf.act_valid && inf.D.d_act[0] == 8  |->  ##[1:1199] inf.out_valid == 1)
else
begin
	$display("Assertion 10 is violated");
	$fatal; 
end

endmodule
