/*
 * 模块：clock_counter
 * 功能：BCD 码时钟计数器 (00:00:00 ~ 23:59:59)
 */
module clock_counter (
    input  logic clk,
    input  logic rst_n,
    input  logic clk_1hz_tick, // 1Hz 脉冲
    input  logic set_en,       // 设置模式使能，为高时停止计数
    input  logic set_load,     // 加载脉冲，加载 set_hh/mm/ss
    input  logic [7:0] set_hh, // [7:4] BCD 高位, [3:0] BCD 低位
    input  logic [7:0] set_mm,
    input  logic [7:0] set_ss,
    output logic [7:0] hh,
    output logic [7:0] mm,
    output logic [7:0] ss
);

    logic [7:0] r_hh, r_mm, r_ss;

    assign hh = r_hh;
    assign mm = r_mm;
    assign ss = r_ss;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_hh <= 8'h12;
            r_mm <= 8'h00;
            r_ss <= 8'h00;
        end 
        // 模式 1: 加载设置时间
        else if (set_load) begin
            r_hh <= set_hh;
            r_mm <= set_mm;
            r_ss <= set_ss;
        end 
        // 模式 2: 正常计时
        else if (clk_1hz_tick && !set_en) begin
            // 递增秒
            if (r_ss == 8'h59) begin
                r_ss <= 8'h00;
                // 递增分
                if (r_mm == 8'h59) begin
                    r_mm <= 8'h00;
                    // 递增时
                    if (r_hh == 8'h23) begin
                        r_hh <= 8'h00;
                    end else if (r_hh[3:0] == 9) begin
                        r_hh <= {r_hh[7:4] + 1, 4'h0}; // e.g., 09->10, 19->20
                    end else begin
                        r_hh <= r_hh + 1; // e.g., 00->01, 10->11
                    end
                end else if (r_mm[3:0] == 9) begin
                    r_mm <= {r_mm[7:4] + 1, 4'h0}; // e.g., 09->10
                end else begin
                    r_mm <= r_mm + 1; // e.g., 00->01
                end
            end else if (r_ss[3:0] == 9) begin
                r_ss <= {r_ss[7:4] + 1, 4'h0}; // e.g., 09->10
            end else begin
                r_ss <= r_ss + 1; // e.g., 00->01
            end
        end
    end

endmodule