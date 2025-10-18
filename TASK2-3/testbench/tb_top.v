module tb_top;

    reg clk, rst_n, button_in;

    initial
    begin
    	clk = 1'b0;
    	rst_n = 1'b0;
    	button_in = 1'b1;
    	#100000 rst_n = 1'b1;
    	#1900000 button_in = 1'b0;
    	#1000000 button_in = ~button_in;
    	#5000000 button_in = ~button_in;
    	#8000000 button_in = ~button_in;
    	#17000000 button_in = ~button_in;
    	#100000000 button_in = ~button_in;
    	#16000000 button_in = ~button_in;
    	#8000000 button_in = ~button_in;
    	#200000000 button_in = 1'b1;

        #2000000 button_in = 1'b0;
    	#1000000 button_in = ~button_in;
    	#5000000 button_in = ~button_in;
    	#8000000 button_in = ~button_in;
    	#17000000 button_in = ~button_in;
    	#100000000 button_in = ~button_in;
    	#16000000 button_in = ~button_in;
    	#8000000 button_in = ~button_in;
        #200000000 button_in = 1'b1;

        #2000000 button_in = 1'b0;
    	#1000000 button_in = ~button_in;
    	#5000000 button_in = ~button_in;
    	#8000000 button_in = ~button_in;
    	#17000000 button_in = ~button_in;
    	#100000000 button_in = ~button_in;
    	#16000000 button_in = ~button_in;
    	#8000000 button_in = ~button_in;

    	#200000000 $finish;
    end
    always #10 clk = ~clk;   //50Mhz

    // output declaration of module top
    wire [7:0] segment;
    wire [7:0] select;

    top u_top(
        .clk       	(clk        ),
        .rst_n     	(rst_n      ),
        .button_in 	(button_in  ),
        .segment   	(segment    ),
        .select    	(select     )
    );

    // 波形输出（ModelSim 可视化）
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

endmodule