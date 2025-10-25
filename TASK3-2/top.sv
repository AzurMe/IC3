/*
 * 模块：top_digital_clock (顶层模块)
 * 功能：连接所有子模块，实现数字时钟
 * 输入：
 * clk_50mhz: 50MHz 系统时钟
 * rst_n:     异步复位 (低电平有效)
 * btn_set_n: 设置键 (低电平有效)
 * btn_sel_n: 选择键 (低电平有效)
 * btn_inc_n: 递增键 (低电平有效)
 * 输出：
 * seg_out: 8位7段数码管段选 (a-g, dp - 低电平有效)
 * an_out:  8位8段数码管位选 (低电平有效)
 */
module top_digital_clock (
    input  logic clk_50mhz,
    input  logic rst_n,
    input  logic btn_set_n,
    input  logic btn_sel_n,
    input  logic btn_inc_n,
    
    output logic [7:0] seg_out, // 7:dp, 6:g, 5:f, 4:e, 3:d, 2:c, 1:b, 0:a
    output logic [7:0] an_out   // 7:第7个 ... 0:第0个 (最右边)
);

    // 假设 50MHz 时钟
    localparam CLK_FREQ = 50_000_000;

    // 内部信号
    logic clk_1hz_tick;
    logic blink_toggle;
    
    logic set_p, sel_p, inc_p; // 按键消抖后的单周期脉冲

    logic [7:0] cur_hh, cur_mm, cur_ss; // BCD 格式的当前时间
    logic [7:0] set_hh, set_mm, set_ss; // BCD 格式的设置时间
    logic       set_en;     // 时间设置使能 (高电平表示在设置模式)
    logic       set_load;   // 加载设置时间脉冲
    logic [1:0] blink_sel;  // 00: 闪烁HH, 01: 闪烁MM, 10: 闪烁SS, 11: 不闪烁

    // 模块实例化

    // 1. 时钟分频器
    clk_divider #(
        .CLK_FREQ(CLK_FREQ)
    ) u_clk_div (
        .clk          (clk_50mhz),
        .rst_n        (rst_n),
        .clk_1hz_tick (clk_1hz_tick),
        .blink_toggle (blink_toggle)
    );

    // 2. 按键消抖
    debouncer u_db_set (
        .clk      (clk_50mhz),
        .rst_n    (rst_n),
        .btn_in   (~btn_set_n), // 按钮低电平有效，取反后输入
        .btn_out  (),
        .btn_pulse(set_p)
    );

    debouncer u_db_sel (
        .clk      (clk_50mhz),
        .rst_n    (rst_n),
        .btn_in   (~btn_sel_n),
        .btn_out  (),
        .btn_pulse(sel_p)
    );

    debouncer u_db_inc (
        .clk      (clk_50mhz),
        .rst_n    (rst_n),
        .btn_in   (~btn_inc_n),
        .btn_out  (),
        .btn_pulse(inc_p)
    );

    // 3. BCD 计时器
    clock_counter u_counter (
        .clk          (clk_50mhz),
        .rst_n        (rst_n),
        .clk_1hz_tick (clk_1hz_tick),
        .set_en       (set_en),
        .set_load     (set_load),
        .set_hh       (set_hh),
        .set_mm       (set_mm),
        .set_ss       (set_ss),
        .hh           (cur_hh),
        .mm           (cur_mm),
        .ss           (cur_ss)
    );

    // 4. 时间设置逻辑 (状态机)
    time_setter u_setter (
        .clk      (clk_50mhz),
        .rst_n    (rst_n),
        .set_p    (set_p),
        .sel_p    (sel_p),
        .inc_p    (inc_p),
        .cur_hh   (cur_hh),
        .cur_mm   (cur_mm),
        .cur_ss   (cur_ss),
        .set_en   (set_en),
        .set_load (set_load),
        .set_hh   (set_hh),
        .set_mm   (set_mm),
        .set_ss   (set_ss),
        .blink_sel(blink_sel)
    );

    // 5. 显示复用驱动
    // 当在设置模式时，显示设置的时间；否则显示当前时间
    display_mux u_disp (
        .clk       (clk_50mhz),
        .rst_n     (rst_n),
        .hh        (set_en ? set_hh : cur_hh),
        .mm        (set_en ? set_mm : cur_mm),
        .ss        (set_en ? set_ss : cur_ss),
        .blink_en  (blink_toggle),
        .blink_sel (blink_sel),
        .seg_out   (seg_out),
        .an_out    (an_out)
    );

endmodule