/*
 * 模块：clk_divider
 * 功能：产生 1Hz 滴答信号和 2Hz 闪烁信号
 */
module clk_divider #(
    parameter CLK_FREQ = 50_000_000 // 默认 50MHz
) (
    input  logic clk,
    input  logic rst_n,
    output logic clk_1hz_tick, // 1Hz 时钟滴答 (单周期脉冲)
    output logic blink_toggle  // 2Hz 闪烁控制信号 (50% 占空比)
);

    localparam CNT_1HZ_MAX = CLK_FREQ - 1;
    localparam CNT_2HZ_MAX = (CLK_FREQ / 2) - 1;

    logic [$clog2(CLK_FREQ):0] cnt_1hz;
    logic [$clog2(CLK_FREQ):0] cnt_2hz;
    logic r_blink_toggle;

    assign clk_1hz_tick = (cnt_1hz == CNT_1HZ_MAX);
    assign blink_toggle = r_blink_toggle;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1hz <= 0;
            cnt_2hz <= 0;
            r_blink_toggle <= 1'b0;
        end else begin
            // 1Hz 计数器
            if (cnt_1hz == CNT_1HZ_MAX) begin
                cnt_1hz <= 0;
            end else begin
                cnt_1hz <= cnt_1hz + 1;
            end
            
            // 2Hz 计数器 (用于闪烁)
            if (cnt_2hz == CNT_2HZ_MAX) begin
                cnt_2hz <= 0;
                r_blink_toggle <= ~r_blink_toggle;
            end else begin
                cnt_2hz <= cnt_2hz + 1;
            end
        end
    end

endmodule