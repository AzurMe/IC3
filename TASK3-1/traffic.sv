/******************************************************************************
 * Module: traffic_light_controller
 * 
 * Description:
 *   一个交通信号灯控制器。
 *   - 控制红、黄、绿三个LED灯，模拟交通灯循环。
 *   - 在两位八段数码管上动态显示当前状态的剩余时间。
 *   - 包含黄灯闪烁功能。
 * 
 * Parameters:
 *   - CLK_FREQ: 板载时钟频率 (Hz)。请根据你的开发板进行修改。
 *   - RED_TIME: 红灯持续时间 (秒)。
 *   - YELLOW_TIME: 黄灯持续时间 (秒)。
 *   - GREEN_TIME: 绿灯持续时间 (秒)。
 * 
 * Ports:
 *   - clk: 系统时钟输入。
 *   - rst_n: 异步复位输入，低电平有效。
 *   - led_r, led_y, led_g: 红、黄、绿灯的LED输出。高电平点亮。
 *   - seg_out: 8段数码管段选输出 {dp,g,f,e,d,c,b,a}。共阳极，低电平点亮。
 *   - seg_sel: 2位数码管位选输出。低电平有效。
 * 
 ******************************************************************************/
module traffic_light_controller #(
    parameter CLK_FREQ      = 50_000_000, // 假设系统时钟为50MHz
    parameter RED_TIME      = 25,
    parameter YELLOW_TIME   = 5,
    parameter GREEN_TIME    = 30
) (
    input  logic clk,
    input  logic rst_n,
    output logic led_r,
    output logic led_y,
    output logic led_g,
    output logic [7:0] seg_out, // {dp, g, f, e, d, c, b, a} <-- 修改点1：扩展到8位
    output logic [1:0] seg_sel  // {十位, 个位}
);

    //==========================================================================
    // 1. 状态机定义
    //==========================================================================
    typedef enum logic [1:0] {
        S_GREEN,
        S_YELLOW,
        S_RED
    } state_t;

    state_t current_state, next_state;

    //==========================================================================
    // 2. 时钟和计时器
    //==========================================================================
    // 1秒定时器
    logic [$clog2(CLK_FREQ)-1:0] sec_cnt;
    logic sec_tick;

    // 倒计时计数器 (最大值为GREEN_TIME=30, 6位足够)
    logic [5:0] time_cnt;

    // 黄灯闪烁定时器 (实现0.5秒切换一次状态，即1Hz闪烁)
    localparam BLINK_DIV = CLK_FREQ / 2;
    logic [$clog2(BLINK_DIV)-1:0] blink_cnt;
    logic blink_on;

    // 生成1秒脉冲 sec_tick
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec_cnt <= '0;
        end else if (sec_cnt == CLK_FREQ - 1) begin
            sec_cnt <= '0;
        end else begin
            sec_cnt <= sec_cnt + 1;
        end
    end
    assign sec_tick = (sec_cnt == CLK_FREQ - 1);

    // 生成闪烁信号 blink_on
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            blink_cnt <= '0;
            blink_on  <= 1'b1;
        end else if (blink_cnt == BLINK_DIV - 1) begin
            blink_cnt <= '0;
            blink_on  <= ~blink_on;
        end else begin
            blink_cnt <= blink_cnt + 1;
        end
    end

    //==========================================================================
    // 3. 状态机核心逻辑 (状态转移和倒计时控制)
    //==========================================================================

    // 状态寄存器 (时序逻辑)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_GREEN;
        end else begin
            current_state <= next_state;
        end
    end

    // 下一状态判断 (组合逻辑)
    always_comb begin
        next_state = current_state; // 默认保持当前状态
        // 当倒计时为0且1秒tick到来时，切换状态
        if (time_cnt == 0 && sec_tick) begin
            case (current_state)
                S_GREEN:  next_state = S_YELLOW;
                S_YELLOW: next_state = S_RED;
                S_RED:    next_state = S_GREEN;
                default:  next_state = S_GREEN;
            endcase
        end
    end

    // 倒计时器更新 (时序逻辑)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            time_cnt <= GREEN_TIME; // 复位后从绿灯开始
        end else if (next_state != current_state) begin // 状态发生切换时，加载新时间
            case (next_state)
                S_GREEN:  time_cnt <= GREEN_TIME;
                S_YELLOW: time_cnt <= YELLOW_TIME;
                S_RED:    time_cnt <= RED_TIME;
                default:  time_cnt <= GREEN_TIME;
            endcase
        end else if (sec_tick) begin // 每秒钟
            if (time_cnt > 0) begin
                time_cnt <= time_cnt - 1;
            end
        end
    end

    //==========================================================================
    // 4. LED 输出逻辑
    //==========================================================================
    always_comb begin
        // 默认所有灯都关闭
        led_r = 1'b0;
        led_y = 1'b0;
        led_g = 1'b0;

        case (current_state)
            S_GREEN:  led_g = 1'b1;
            S_YELLOW: led_y = blink_on; // 黄灯由闪烁信号控制
            S_RED:    led_r = 1'b1;
        endcase
    end

    //==========================================================================
    // 5. 数码管驱动逻辑 (八段版本)
    //==========================================================================
    // BCD 转换
    logic [3:0] digit_tens;
    logic [3:0] digit_ones;

    assign digit_tens = time_cnt / 10;
    assign digit_ones = time_cnt % 10;

    // 动态扫描控制器
    logic [17:0] scan_cnt; // 使用18位计数器，扫描频率约为 50MHz/2^18 ≈ 190Hz
    logic [3:0] digit_to_decode;
    logic [7:0] seg_data; // <-- 修改点2：内部信号也扩展到8位

    // 扫描计数器
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scan_cnt <= '0;
        end else begin
            scan_cnt <= scan_cnt + 1;
        end
    end

    // 位选和数据选择 (多路复用)
    always_comb begin
        // 根据扫描计数器的高位来选择数码管
        case (scan_cnt[17]) // 用1位做选择，实现两路切换
            1'b0: begin // 显示个位
                seg_sel = 2'b10; // 选中个位管 (假设位选0为个位)
                digit_to_decode = digit_ones;
            end
            1'b1: begin // 显示十位
                seg_sel = 2'b01; // 选中十位管 (假设位选1为十位)
                digit_to_decode = digit_tens;
            end
        endcase
    end

    // 8段译码器 (共阳极, 低电平有效)
    // <-- 修改点3：更新译码逻辑为8位输出
    always_comb begin
        case (digit_to_decode)
            // dp,g,f,e,d,c,b,a, 0=on, 1=off
            // dp位(最高位)始终为1，使其保持熄灭
            4'd0: seg_data = 8'b11000000; // "0"
            4'd1: seg_data = 8'b11111001; // "1"
            4'd2: seg_data = 8'b10100100; // "2"
            4'd3: seg_data = 8'b10110000; // "3"
            4'd4: seg_data = 8'b10011001; // "4"
            4'd5: seg_data = 8'b10010010; // "5"
            4'd6: seg_data = 8'b10000010; // "6"
            4'd7: seg_data = 8'b11111000; // "7"
            4'd8: seg_data = 8'b10000000; // "8"
            4'd9: seg_data = 8'b10010000; // "9"
            default: seg_data = 8'b11111111; // 全灭
        endcase
    end
    
    assign seg_out = seg_data;

endmodule