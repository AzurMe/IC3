module top(
    input clk,
    input rst_n,
    input [2:0] button_in,
    output [7:0] seg,
    output [7:0] select_out
);

    wire [2:0] button_out;
    wire [2:0] button_posedge;
    wire [2:0] button_negedge;
    wire clk_out;
    wire level;
    wire select;
    wire [31:0] data;

    assign data = {4'd0, 4'd5, 4'd2, 4'd0, 4'd1, 4'd3, 4'd1, 4'd4};
    assign select_out = select;

    // reset
    key_debounce key_debounce_inst0 (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(button_in[0]),
        .button_out(button_out[0]),
        .button_posedge(button_posedge[0]),
        .button_negedge(button_negedge[0])
    );

    // assign rst_n = button_out[0];

    // en
    key_debounce key_debounce_inst1 (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(button_in[1]),
        .button_out(button_out[1]),
        .button_posedge(button_posedge[1]),
        .button_negedge(button_negedge[1])
    );

    // clear
    key_debounce key_debounce_inst2 (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(button_in[2]),
        .button_out(button_out[2]),
        .button_posedge(button_posedge[2]),
        .button_negedge(button_negedge[2])
    );

    clk_div clk_div_inst(
        .clk     	(clk      ),
        .rst_n   	(rst_n    ),
        .clk_out 	(clk_out  )
    );

    setup setup_inst(
        .clk   	(clk    ),
        .rst_n 	(rst_n  ),
        .pulse 	(button_negedge[1]),
        .clear 	(button_negedge[2]),
        .level 	(level  )
    );

    counter counter_inst (
        .clk_div(clk_out),
        .rst_n(rst_n),
        .en(level),
        .select(select)
    );

    segment_dinamic segment_dinamic_inst(
        .clk    (clk    ),
        .rst_n  (rst_n  ),
        .data   (data   ),
        .select (select ),
        .seg    (seg    )
    );

endmodule