`timescale 1 ns / 1 ns
module  key_debounce
(
    input       clk,
    input       rst_n,
    input       button_in,
    output reg  button_out,
    output      button_posedge,
    output      button_negedge
);
//// ---------------- internal constants --------------
parameter N = 20 ;           // debounce timer bitwidth (Need Calculation)
parameter FREQ = 50;         //model clock :Mhz
parameter MAX_TIME = 20;     //ms
localparam TIMER_MAX_VAL =   MAX_TIME * 1000 * FREQ;

    wire button_diff;
    reg Q1, Q2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Q1 <= 1'b1;
            Q2 <= 1'b1;
        end else begin
            Q1 <= button_in;
            Q2 <= Q1;
        end
    end

    assign button_diff = Q1 ^ Q2;

    reg [N-1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
        end else if (button_diff == 1) begin
            cnt <= 0;
        end else if (cnt == TIMER_MAX_VAL) begin
            cnt <= cnt;
        end else begin
            cnt <= cnt + 1;
        end
    end

    reg button_out_temp1, button_out_temp2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_out <= 1'b1;
            button_out_temp1 <= 1'b1;
            button_out_temp2 <= 1'b1;
        end else if (cnt == TIMER_MAX_VAL) begin
            button_out <= Q2;
            button_out_temp1 <= Q2;
            button_out_temp2 <= button_out_temp1;
        end
    end

    assign button_posedge = (button_out_temp1 == 1'b1) && (button_out_temp2 == 1'b0);
    assign button_negedge = (button_out_temp1 == 1'b0) && (button_out_temp2 == 1'b1);
endmodule