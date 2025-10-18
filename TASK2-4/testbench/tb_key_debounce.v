// Reference: https://github.com/alinxalinx/AX7020_2023.1/blob/master/course_s1_fpga/07_key_debounce/auto_create_project/src/testbench/key_debounce_tb.v
// Modified by: Zhuolin Li

`timescale 1ns/1ns
module tb_key_debounce;
reg clk;
reg rst_n;
reg button_in;
wire button_out;
wire button_posedge;
wire button_negedge;

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
	
	#200000000 $finish;
end
always #10 clk = ~clk;   //50Mhz

key_debounce uut
(
	.clk     (clk),
	.rst_n       (rst_n),
	.button_in         (button_in),
	.button_out         (button_out),
    .button_posedge    (button_posedge),
    .button_negedge    (button_negedge)
);

// 波形输出（ModelSim 可视化）
    initial begin
        $dumpfile("tb_key_debounce.vcd");
        $dumpvars(0, tb_key_debounce);
    end

endmodule