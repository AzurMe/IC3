/*
 * 模块：debouncer
 * 功能：按键消抖，并产生单周期脉冲
 */
module debouncer (
    input       clk,
    input       rst_n,
    input       btn_in,
    output reg  btn_out,
    output      btn_pulse,
);

parameter N = 20 ;           // debounce timer bitwidth (Need Calculation)
parameter FREQ = 50;         //model clock :Mhz
parameter MAX_TIME = 20;     //ms
localparam TIMER_MAX_VAL =   MAX_TIME * 1000 * FREQ;

    reg Q1, Q2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Q1 <= 1'b1;
            Q2 <= 1'b1;
        end else begin
            Q1 <= btn_in;
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

    reg btn_out_temp1, btn_out_temp2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_out <= 1'b1;
            btn_out_temp1 <= 1'b1;
            btn_out_temp2 <= 1'b1;
        end else if (cnt == TIMER_MAX_VAL) begin
            btn_out <= Q2;
            btn_out_temp1 <= Q2;
            btn_out_temp2 <= btn_out_temp1;
        end
    end

    assign btn_pulse = (btn_out_temp1 == 1'b1) && (btn_out_temp2 == 1'b0);

endmodule