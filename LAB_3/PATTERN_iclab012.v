`ifdef RTL
    `define CYCLE_TIME 7.0
`endif

`ifdef GATE
    `define CYCLE_TIME 7.0
`endif


module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid,
	in,
    // Input signals
    out_valid,
    out
);

//================================================================ 
//   INPUT AND OUTPUT DECLARATION
//================================================================
output reg clk, rst_n, in_valid;
output reg [3:0] in;
input out_valid;
input [3:0] out;

//================================================================
// parameters & integer
//================================================================

//================================================================
// wire & registers 
//================================================================

//================================================================
// clock
//================================================================
always  #(`CYCLE_TIME/2.0) clk = ~clk;
initial clk = 0;
//================================================================
// initial
//================================================================
integer i,y;
integer input_file,ans_file,has_sol_file;
integer scan_in,ans,has_sol;
integer patcount;
integer PATNUM = 104;
integer total_latency;
initial begin
	input_file = $fopen("../00_TESTBED/iclab012_input.txt", "r");
	ans_file = $fopen("../00_TESTBED/iclab012_15seq.txt", "r");
	has_sol_file = $fopen("../00_TESTBED/iclab012_has_sol.txt", "r");
    rst_n = 1;
    in_valid = 0;
    force clk = 0;
    reset_task;

	for (patcount=0;patcount<PATNUM;patcount=patcount+1)begin
        $display("Patcount : %d",patcount);
		input_task;
		wait_OUT_VALID;
		check_ans;
	end
	pass_task;
	$finish;
end

//================================================================
// task
//================================================================
task reset_task ; begin
	#(0.5); rst_n = 0;

	#(2.0);
	if((out !== 0) || (out_valid !== 0)) begin
		$display ("-----------------------------");
		$display ("        SPEC 3 FAIL!         ");
		$display ("-----------------------------");
		
	    $finish ;
	end
	
	#(1.0); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task input_task; begin
    for(i = 0;i < 81;i = i+1)begin
        @(negedge clk);
        in_valid = 1;
        scan_in = $fscanf(input_file,"%d\n",in);    
    end
    @(negedge clk);
    in_valid = 0;
    in = 'dx;
end endtask

always@(negedge clk)begin
    if(out_valid !== 'd1)begin
        if (out !==0)begin
		    $display ("-----------------------------");
		    $display ("        SPEC 4 FAIL!         ");
		    $display ("-----------------------------");
	        $finish ;
        end
    end
end

always@(negedge clk)begin
    if(in_valid === 1)begin
        if (out_valid === 1)begin
		    $display ("-----------------------------");
		    $display ("        SPEC 5 FAIL!         ");
		    $display ("-----------------------------");
	        $finish ;
        end
    end
end

integer latency;
task wait_OUT_VALID; begin
  latency = -1;
  while(!out_valid) begin
	latency = latency + 1;
	if(latency == 300) begin
		$display ("-----------------------------");
		$display ("        SPEC 6 FAIL!         ");
		$display ("-----------------------------");

		repeat(2)@(negedge clk);
		$finish;
	end
	@(negedge clk);
  end
  total_latency = total_latency + latency;
end endtask

task check_ans; begin
    scan_in = $fscanf(has_sol_file,"%d\n",has_sol);
	y=0;
	while(out_valid)
	begin
        if(has_sol)
            begin
		    if(y>=15)
		    	begin
		            $display ("-----------------------------");
		            $display ("        SPEC 8 FAIL!         ");
		            $display ("-----------------------------");
		    		$finish;
		    	end		
		    scan_in=$fscanf(ans_file,"%d",ans);
		    if(out!==ans)
		    		begin
		                $display ("-----------------------------");
		                $display ("        SPEC 8 FAIL!         ");
		                $display ("-----------------------------");
		    			$finish;
		    		end
		    @(negedge clk);	
		    y=y+1;
            end
        else begin
		    if(y>=1)
		    	begin
		            $display ("-----------------------------");
		            $display ("        SPEC 7 FAIL!         ");
		            $display ("-----------------------------");
		    		$finish;
		    	end		
		    if(out!=='d10)
		    		begin
		                $display ("-----------------------------");
		                $display ("        SPEC 7 FAIL!         ");
		                $display ("-----------------------------");
		    			$finish;
		    		end
		    @(negedge clk);	
		    y=y+1;
        end
	end
	
	if(has_sol && y<14)
		begin
		    $display ("-----------------------------");
		    $display ("        SPEC 8 FAIL!         ");
		    $display ("-----------------------------");
			$finish;
		end		
end endtask

task pass_task;begin
    $display ("----------------------------------------------------------------------------------------------------------------------");
    $display ("                                                  Congratulations!                                                   ");
    $display ("                                           You have passed all patterns!                                             ");
    $display ("----------------------------------------------------------------------------------------------------------------------");
    $finish;
end endtask

endmodule

