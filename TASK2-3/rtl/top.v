module top(
    input clk,
    input rst_n,
    input button_in,
    output [7:0] segment,
    output [7:0] select
);

wire button_out;
wire button_posedge;
wire button_negedge;
wire [3:0] data;

key_debounce key_debounce_inst (
    .clk(clk),
    .rst_n(rst_n),
    .button_in(button_in),
    .button_out(button_out),
    .button_posedge(button_posedge),
    .button_negedge(button_negedge)
);

counter counter_inst (
    .clk(clk),
    .rst_n(rst_n),
    .en(button_negedge),
    .count(data)
);

segment_static segment_static_inst (
    .data(data),
    .rst_n_combinational(rst_n),
    .segment(segment),
    .select(select)
);

endmodule