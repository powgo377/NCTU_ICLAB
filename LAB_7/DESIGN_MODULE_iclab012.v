module CLK_1_MODULE(// Input signals
			clk_1,
			clk_2,
			rst_n,
			in_valid,
			in,
			mode,
			operator,
			// Output signals,
			clk1_in_0, clk1_in_1, clk1_in_2, clk1_in_3, clk1_in_4, clk1_in_5, clk1_in_6, clk1_in_7, clk1_in_8, clk1_in_9, 
			clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19,
			clk1_op_0, clk1_op_1, clk1_op_2, clk1_op_3, clk1_op_4, clk1_op_5, clk1_op_6, clk1_op_7, clk1_op_8, clk1_op_9, 
			clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19,
			clk1_expression_0, clk1_expression_1, clk1_expression_2,
			clk1_operators_0, clk1_operators_1, clk1_operators_2,
			clk1_mode,
			clk1_control_signal,
			clk1_flag_0, clk1_flag_1, clk1_flag_2, clk1_flag_3, clk1_flag_4, clk1_flag_5, clk1_flag_6, clk1_flag_7, 
			clk1_flag_8, clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13, clk1_flag_14, 
			clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_1, clk_2, rst_n, in_valid, operator, mode;
input [2:0] in;

output reg [2:0] clk1_in_0, clk1_in_1, clk1_in_2, clk1_in_3, clk1_in_4, clk1_in_5, clk1_in_6, clk1_in_7, clk1_in_8, clk1_in_9, 
				 clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19;
output reg clk1_op_0, clk1_op_1, clk1_op_2, clk1_op_3, clk1_op_4, clk1_op_5, clk1_op_6, clk1_op_7, clk1_op_8, clk1_op_9, 
		   clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19;
output reg [59:0] clk1_expression_0, clk1_expression_1, clk1_expression_2;
output reg [19:0] clk1_operators_0, clk1_operators_1, clk1_operators_2;
output reg clk1_mode;
output reg [19 :0] clk1_control_signal;
output clk1_flag_0,  clk1_flag_2, clk1_flag_3, clk1_flag_4, clk1_flag_5, clk1_flag_6, clk1_flag_7, 
	   clk1_flag_8, clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13, clk1_flag_14, 
	   clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19;
output wire clk1_flag_1;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
syn_XOR     syn_1(.IN(in_valid),.OUT(clk1_flag_0),.TX_CLK(clk_1),.RX_CLK(clk_2),.RST_N(rst_n));
synchronizer syn2(.D(in_valid), .Q(clk1_flag_1), .clk(clk_2), .rst_n(rst_n));
assign clk1_flag_3 = in_valid;
always@(posedge clk_1 or negedge rst_n)begin
    if(!rst_n) begin
        clk1_in_0 <= 'd0;
        clk1_mode <= 'd0;
        clk1_op_0 <= 'd0;
        //clk1_flag_1 <= 'd0;
    end else begin
        clk1_in_0 <= in;
        clk1_mode <= mode;
        clk1_op_0 <= operator;
        //clk1_flag_1 <= in_valid;
    end
end
//---------------------------------------------------------------------
//   TA hint:
//	  Please write a synchroniser using syn_XOR or doubole flop synchronizer design in CLK_1_MODULE to generate a flag signal to inform CLK_2_MODULE that it can read input signal from CLK_1_MODULE.
//	  You don't need to include syn_XOR.v file or synchronizer.v file by yourself, we have already done that in top module CDC.v
//	  example:
//   syn_XOR syn_1(.IN(inflag_clk1),.OUT(clk1_flag_0),.TX_CLK(clk_1),.RX_CLK(clk_2),.RST_N(rst_n));             
//---------------------------------------------------------------------	
endmodule







module CLK_2_MODULE(// Input signals
			clk_2,
			clk_3,
			rst_n,
			clk1_in_0, clk1_in_1, clk1_in_2, clk1_in_3, clk1_in_4, clk1_in_5, clk1_in_6, clk1_in_7, clk1_in_8, clk1_in_9, 
			clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19,
			clk1_op_0, clk1_op_1, clk1_op_2, clk1_op_3, clk1_op_4, clk1_op_5, clk1_op_6, clk1_op_7, clk1_op_8, clk1_op_9, 
			clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19,
			clk1_expression_0, clk1_expression_1, clk1_expression_2,
			clk1_operators_0, clk1_operators_1, clk1_operators_2,
			clk1_mode,
			clk1_control_signal,
			clk1_flag_0, clk1_flag_1, clk1_flag_2, clk1_flag_3, clk1_flag_4, clk1_flag_5, clk1_flag_6, clk1_flag_7, 
			clk1_flag_8, clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13, clk1_flag_14, 
			clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19,
			
			// output signals
			clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3,
			clk2_mode,
			clk2_control_signal,
			clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_2, clk_3, rst_n;

input [2:0] clk1_in_0, clk1_in_1, clk1_in_2, clk1_in_3, clk1_in_4, clk1_in_5, clk1_in_6, clk1_in_7, clk1_in_8, clk1_in_9, 
	 	    clk1_in_10, clk1_in_11, clk1_in_12, clk1_in_13, clk1_in_14, clk1_in_15, clk1_in_16, clk1_in_17, clk1_in_18, clk1_in_19;
input clk1_op_0, clk1_op_1, clk1_op_2, clk1_op_3, clk1_op_4, clk1_op_5, clk1_op_6, clk1_op_7, clk1_op_8, clk1_op_9, 
  	  clk1_op_10, clk1_op_11, clk1_op_12, clk1_op_13, clk1_op_14, clk1_op_15, clk1_op_16, clk1_op_17, clk1_op_18, clk1_op_19;
input [59:0] clk1_expression_0, clk1_expression_1, clk1_expression_2;
input [19:0] clk1_operators_0, clk1_operators_1, clk1_operators_2;
input clk1_mode;
input [19 :0] clk1_control_signal;
input clk1_flag_0, clk1_flag_1, clk1_flag_2, clk1_flag_3, clk1_flag_4, clk1_flag_5, clk1_flag_6, clk1_flag_7, 
	  clk1_flag_8, clk1_flag_9, clk1_flag_10, clk1_flag_11, clk1_flag_12, clk1_flag_13, clk1_flag_14, 
	  clk1_flag_15, clk1_flag_16, clk1_flag_17, clk1_flag_18, clk1_flag_19;


output [63:0] clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3;
output reg clk2_mode;
output reg [8:0] clk2_control_signal;
output clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7;


//---------------------------------------------------------------------
// DESIGN
//---------------------------------------------------------------------

//input
reg         mode;
reg [2:0]  arr_in      [18:0];
reg [18:0]  op;
reg [4:0]   ff_in_cnt;

//count
wire [26:0] op_00_in1,op_00_in2;
wire [26:0] op_01_in1,op_01_in2;
wire [26:0] op_02_in1,op_02_in2;

//exec
reg [4:0] ff_exec_cnt,ff_stack_cnt;
reg [29:0] arr_stack [9:0];

//count
//wire can_do_first  = (mode)? (!op[ff_in_cnt-2] && !op[ff_in_cnt-1] && clk1_op_0      ) : (op[ff_in_cnt-2] && !op[ff_in_cnt-1] && !clk1_op_0);
wire can_do_first  = mode &&  clk1_op_0  ;
//wire can_do_second = (ff_in_cnt>2)? ((mode)? (!op[ff_in_cnt-3] && !op[ff_in_cnt-2] && op[ff_in_cnt-1]) : (op[ff_in_cnt-3] && !op[ff_in_cnt-2] && !op[ff_in_cnt-1])) : 'd0;

//FSM
parameter   ST_IDLE     =   'd0,
            ST_INPUT    =   'd1,
            ST_EXEC     =   'd2,
//            ST_EXEC2    =   'd3,
            ST_OUT      =   'd4;
reg     [2:0]   cs;
wire    CS_IDLE     = cs == ST_IDLE;
wire    CS_INPUT    = cs == ST_INPUT;
wire    CS_EXEC     = cs == ST_EXEC;
//wire    CS_EXEC2    = cs == ST_EXEC2;
wire    CS_OUT      = cs == ST_OUT;

///////////
//  FSM  //
///////////
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)
        cs <= ST_IDLE;
    else begin
        case(cs)
            ST_IDLE: if(clk1_flag_1)    cs  <=  ST_INPUT;
            ST_INPUT:if(clk1_flag_0 && !clk1_flag_3)begin
                if(mode)cs  <=  ST_OUT;
                //else if(!can_do_second)cs <= ST_EXEC;
                else cs <= ST_EXEC;
            end
            ST_EXEC:if(ff_in_cnt == 1) cs  <=  ST_OUT;
            //ST_EXEC2:   cs  <=  ST_OUT;
            ST_OUT: cs <= ST_IDLE;
        endcase
    end
end

/////////////
//  COUNT  //
/////////////

assign op_00_in1 = (mode)? arr_stack[ff_in_cnt-2] :arr_stack[ff_exec_cnt-1] ;
assign op_00_in2 = (mode)? arr_stack[ff_in_cnt-1] :arr_stack[ff_exec_cnt-2] ;
assign op_01_in1 = (mode)? arr_stack[ff_in_cnt-2] :arr_stack[ff_exec_cnt-1] ;
assign op_01_in2 = (mode)? arr_stack[ff_in_cnt-1] :arr_stack[ff_exec_cnt-2] ;
assign op_02_in1 = (mode)? arr_stack[ff_in_cnt-2] :arr_stack[ff_exec_cnt-1] ;
assign op_02_in2 = (mode)? arr_stack[ff_in_cnt-1] :arr_stack[ff_exec_cnt-2] ;

/*always@(*)begin
    if(CS_EXEC)begin
        op_00_in1 = arr_stack[ff_exec_cnt-1];
        op_00_in2 = arr_stack[ff_exec_cnt-2];
        op_01_in1 = arr_stack[ff_exec_cnt-1];
        op_01_in2 = arr_stack[ff_exec_cnt-2];
        op_02_in1 = arr_stack[ff_exec_cnt-1];
        op_02_in2 = arr_stack[ff_exec_cnt-2];
    end else begin
    case({mode,clk1_flag_0})
        2'b11:begin
            op_00_in1 = arr_in[ff_in_cnt-2];
            op_00_in2 = arr_in[ff_in_cnt-1];
            op_01_in1 = arr_in[ff_in_cnt-2];
            op_01_in2 = arr_in[ff_in_cnt-1];
            op_02_in1 = arr_in[ff_in_cnt-2];
            op_02_in2 = arr_in[ff_in_cnt-1];
        end
        2'b01:begin
            op_00_in1 = arr_in[ff_in_cnt-1];
            op_00_in2 = clk1_in_0          ;
            op_01_in1 = arr_in[ff_in_cnt-1];
            op_01_in2 = clk1_in_0          ;
            op_02_in1 = arr_in[ff_in_cnt-1];
            op_02_in2 = clk1_in_0          ;
        end
*//*
        2'b10:begin
            op_00_in1 = arr_in[ff_in_cnt-3];
            op_00_in2 = arr_in[ff_in_cnt-2];
            op_01_in1 = arr_in[ff_in_cnt-3];
            op_01_in2 = arr_in[ff_in_cnt-2];
            op_02_in1 = arr_in[ff_in_cnt-3];
            op_02_in2 = arr_in[ff_in_cnt-2];
        end
        2'b00:begin
            op_00_in1 = arr_in[ff_in_cnt-2];
            op_00_in2 = arr_in[ff_in_cnt-1];
            op_01_in1 = arr_in[ff_in_cnt-2];
            op_01_in2 = arr_in[ff_in_cnt-1];
            op_02_in1 = arr_in[ff_in_cnt-2];
            op_02_in2 = arr_in[ff_in_cnt-1];
        end
        default:begin
            op_00_in1 = 'd0;
            op_00_in2 = 'd0;
            op_01_in1 = 'd0;
            op_01_in2 = 'd0;
            op_02_in1 = 'd0;
            op_02_in2 = 'd0;
        end
    endcase
    end
end
*/
wire [29:0] op_00_result = $signed(op_00_in1) + $signed(op_00_in2);
wire [29:0] op_01_result = $signed(op_01_in1) - $signed(op_01_in2);
wire [29:0] op_02_result = $signed(op_02_in1) * $signed(op_02_in2);
wire [29:0] op_03_result = (op_00_result[29])? ~op_00_result + 1 : op_00_result;
wire [29:0] op_04_result = op_01_result << 'd1;

reg  [29:0] op_result;
wire [2:0] op_which = (mode)?clk1_in_0:arr_in[ff_in_cnt-1];
/*reg [2:0] op_which;
always@(*)begin
    if(CS_EXEC)begin
        op_which = arr_in[ff_in_cnt-1];
    end else begin
    case({clk1_flag_0,mode})
        2'b00:op_which = arr_in[ff_in_cnt-3];
        2'b10:op_which = arr_in[ff_in_cnt-2];
        2'b01:op_which = arr_in[ff_in_cnt-1];
        2'b11:op_which = clk1_in_0;
    endcase
    end
end
*/

always@(*)begin
    case(op_which)
        0:op_result = op_00_result;
        1:op_result = op_01_result;
        2:op_result = op_02_result;
        3:op_result = op_03_result;
        4:op_result = op_04_result;
        default:op_result = 'd0 ;
    endcase
end

/////////////
//  INPUT  //
/////////////
integer i;
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)begin
        ff_in_cnt <= 'd0;
    end else if(CS_INPUT)begin
        if (clk1_flag_0)begin
            if(can_do_first)
                ff_in_cnt <= ff_in_cnt - 1 ;
            else
                ff_in_cnt <= ff_in_cnt + 1;
        //end else if(can_do_second)
        //    ff_in_cnt <= ff_in_cnt - 2 ;
        end
    end else if (CS_EXEC)begin
        ff_in_cnt   <= ff_in_cnt -1;
    end else if(CS_IDLE)
        ff_in_cnt <= 'd0;
end
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)begin
        mode <= 'd0;
        for(i = 0;i < 19;i = i + 1)begin
            arr_in[i] <= 'd0;
        end
        op <= 'd0;
    end else if (CS_INPUT)begin
        if (clk1_flag_0)begin
            if(ff_in_cnt == 0)
                mode <= clk1_mode;
            if(can_do_first)begin
                op[ff_in_cnt-2] <= 0;
                arr_in[ff_in_cnt-2] <= op_result;
            end else begin
                op[ff_in_cnt] <= clk1_op_0;
                arr_in[ff_in_cnt] <= clk1_in_0;
            end
        //end else begin
        //    if(can_do_second) begin
        //        op[ff_in_cnt-3] <= 0;
        //        arr_in[ff_in_cnt-3] <= op_result;
        //    end
        end
//    end else if (CS_EXEC2)begin
//        arr_in[0] <= arr_stack[0];
    end else if (CS_IDLE)begin
        mode <= 'd0;
        for(i = 1;i < 19;i = i + 1)begin
            arr_in[i] <= 'd0;
        end
    end
end
/////////////
//  EXECP  //
/////////////
wire is_pop = op[ff_in_cnt-1];
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)begin
        ff_exec_cnt <= 'd0;
    end else if(CS_EXEC)begin
        if(is_pop)
            ff_exec_cnt <= ff_exec_cnt - 1;
        else
            ff_exec_cnt <= ff_exec_cnt + 1;
    end else if(CS_IDLE)
        ff_exec_cnt <= 'd0;
end
always@(posedge clk_2 or negedge rst_n)begin
    if(!rst_n)begin
        ff_stack_cnt <= 'd0;
        for(i = 0;i < 10;i = i + 1)begin
            arr_stack[i] <= 'd0;
        end
    end else if(CS_INPUT && clk1_flag_0)begin
        if(can_do_first)
            arr_stack[ff_in_cnt-2] <= op_result;
        else
            arr_stack[ff_in_cnt] <= clk1_in_0;
    end else if(CS_EXEC)begin
        if(is_pop)
            arr_stack[ff_exec_cnt-2] <= op_result;
        else
            arr_stack[ff_exec_cnt] <= arr_in[ff_in_cnt-1];
    end else if(CS_IDLE)begin
        ff_stack_cnt <= 'd0;
        for(i = 1;i < 10;i = i + 1)begin
            arr_stack[i] <= 'd0;
        end
    end
end

//////////////
//  OUTPUT  //
//////////////
//syn_XOR     syn_test(.IN(ff_in_cnt[0]),.OUT(clk2_flag_1),.TX_CLK(clk_2),.RX_CLK(clk_3),.RST_N(rst_n));
wire out_cond = (CS_EXEC &&ff_in_cnt==2) || (mode&&clk1_flag_0 && !clk1_flag_3);
syn_XOR     syn_1(.IN(out_cond),.OUT(clk2_flag_0),.TX_CLK(clk_2),.RX_CLK(clk_3),.RST_N(rst_n));
assign clk2_out_0 = (arr_stack[0][29])? {34'h3ffffffff,arr_stack[0]} : arr_stack[0];
//---------------------------------------------------------------------
//   TA hint:
//	  Please write a synchroniser using syn_XOR or doubole flop synchronizer design in CLK_2_MODULE to generate a flag signal to inform CLK_3_MODULE that it can read input signal from CLK_2_MODULE.
//	  You don't need to include syn_XOR.v file or synchronizer.v file by yourself, we have already done that in top module CDC.v
//	  example:
//   syn_XOR syn_2(.IN(inflag_clk2),.OUT(clk2_flag_0),.TX_CLK(clk_2),.RX_CLK(clk_3),.RST_N(rst_n));             
//---------------------------------------------------------------------	
endmodule



module CLK_3_MODULE(// Input signals
			clk_3,
			rst_n,
			clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3,
			clk2_mode,
			clk2_control_signal,
			clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7,
			
			// Output signals
			out_valid,
			out
		  
			);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------			
input clk_3, rst_n;


input [63:0] clk2_out_0, clk2_out_1, clk2_out_2, clk2_out_3;
input clk2_mode;
input [8:0] clk2_control_signal;
input clk2_flag_0, clk2_flag_1, clk2_flag_2, clk2_flag_3, clk2_flag_4, clk2_flag_5, clk2_flag_6, clk2_flag_7;

output reg out_valid;
output reg [63:0]out; 		

//---------------------------------------------------------------------
//  DESIGN
//---------------------------------------------------------------------

always@(posedge clk_3 or negedge rst_n)begin
    if(!rst_n)begin
        out_valid <= 'd0;
        out <= 'd0;
    end else if (clk2_flag_0) begin
        out_valid <= 'd1;
        out <= clk2_out_0;
    end else begin
        out_valid <= 'd0;
        out <= 'd0;
    end
end

endmodule


