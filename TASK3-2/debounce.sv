/*
 * 模块：debouncer
 * 功能：按键消抖，并产生单周期脉冲
 */
module debouncer (
    input  logic clk,
    input  logic rst_n,
    input  logic btn_in,    // 原始按键输入
    output logic btn_out,   // 消抖后的电平
    output logic btn_pulse  // 消抖后的上升沿脉冲
);

    // 20ms 消抖时间 @ 50MHz
    localparam DEBOUNCE_MAX =  1000; // 1_000_000
    
    logic [$clog2(DEBOUNCE_MAX):0] cnt;
    logic btn_sync1, btn_sync2;
    logic btn_stable;
    logic btn_prev;

    assign btn_out = btn_stable;
    assign btn_pulse = btn_stable & ~btn_prev;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            btn_sync1 <= 1'b0;
            btn_sync2 <= 1'b0;
            btn_stable <= 1'b0;
            btn_prev <= 1'b0;
        end else begin
            // 同步
            btn_sync1 <= btn_in;
            btn_sync2 <= btn_sync1;
            
            // 状态改变，则计数器复位
            if (btn_sync2 != btn_stable) begin
                cnt <= 0;
            end
            // 计数器未满，继续计数
            else if (cnt != DEBOUNCE_MAX) begin
                cnt <= cnt + 1;
            end
            // 计数器已满，且状态稳定，更新输出
            else begin
                btn_stable <= btn_sync2;
            end
            
            // 记录前一个周期的稳定状态
            btn_prev <= btn_stable;
        end
    end

endmodule