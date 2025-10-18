// tb_segment_static.v
// testbench for segment_static.v
// not matched with segment_static.v of TASK2-1
`timescale 1ns / 1ps

module tb_segment_static;

    reg [3:0] data;
    wire [7:0] segment;

    segment_static uut (
        .data(data),
        .segment(segment)
    );

    initial begin
        // Test all possible inputs
        //for (data = 0; data < 16; data = data + 1) begin
        //    $display("Input: %d, Output: %b", data, segment);
        //    #10; // Wait for 10 time units
        //end
        data = 4'b0000; #10;
        data = 4'b0001; #10;   
        data = 4'b0010; #10;
        data = 4'b0011; #10;
        $finish;
    end
  // 波形输出（ModelSim 可视化）
    initial begin
        $dumpfile("tb_segment_static.vcd");
        $dumpvars(0, tb_segment_static);
    end

endmodule