//synopsys translate_off
`include "CS_IP.v"
//synopsys translate_on

module CS
#(parameter WIDTH_DATA_1 = 384, parameter WIDTH_RESULT_1 = 8,
parameter WIDTH_DATA_2 = 128, parameter WIDTH_RESULT_2 = 8)
(
    data,
    in_valid,
    clk,
    rst_n,
    result,
    out_valid
);

input [(WIDTH_DATA_1 + WIDTH_DATA_2 - 1):0] data;
input in_valid, clk, rst_n;

output wire [(WIDTH_RESULT_1 + WIDTH_RESULT_2 -1):0] result;
output wire out_valid;

/*
wire [7:0] result11,result12,result13,result2;
wire out_valid1,out_valid2,out_valid3,out_valid4;
*/
wire [7:0] result1,result2;
wire out_valid1,out_valid2;
CS_IP #(.WIDTH_DATA(384),.WIDTH_RESULT(8)) cs_ip1 (.data(data[511:128]),.in_valid(in_valid),.clk(clk),.rst_n(rst_n),.result(result1),.out_valid(out_valid1));
CS_IP #(.WIDTH_DATA(128),.WIDTH_RESULT(8)) cs_ip2 (.data(data[127:0  ]),.in_valid(in_valid),.clk(clk),.rst_n(rst_n),.result(result2),.out_valid(out_valid2));
assign out_valid = out_valid1 & out_valid2;
assign result = out_valid?{result1,result2}:'d0;
/*
CS_IP #(.WIDTH_DATA(128),.WIDTH_RESULT(8)) cs_ip2 (.data(data[127:0  ]),.in_valid(in_valid),.clk(clk),.rst_n(rst_n),.result(result2 ),.out_valid(out_valid1));
CS_IP #(.WIDTH_DATA(128),.WIDTH_RESULT(8)) cs_ip11(.data(data[255:128]),.in_valid(in_valid),.clk(clk),.rst_n(rst_n),.result(result11),.out_valid(out_valid2));
CS_IP #(.WIDTH_DATA(128),.WIDTH_RESULT(8)) cs_ip12(.data(data[383:256]),.in_valid(in_valid),.clk(clk),.rst_n(rst_n),.result(result12),.out_valid(out_valid3));
CS_IP #(.WIDTH_DATA(128),.WIDTH_RESULT(8)) cs_ip13(.data(data[511:384]),.in_valid(in_valid),.clk(clk),.rst_n(rst_n),.result(result13),.out_valid(out_valid4));
assign out_valid = out_valid1 & out_valid2 & out_valid3 & out_valid4;
wire [7:0] tmp_result_r_11 = (~result11);
wire [7:0] tmp_result_r_12 = (~result12);
wire [7:0] tmp_result_r_13 = (~result13);
wire [9:0] tmp_result11 = tmp_result_r_11 + tmp_result_r_12 + tmp_result_r_13;
wire [8:0] tmp_result12 = tmp_result11[9:8]+tmp_result11[7:0];
assign result = out_valid?{~(tmp_result12[8]+tmp_result12[7:0]),result2}:'d0;
*/
 
endmodule
