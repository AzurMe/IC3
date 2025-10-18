`timescale 1ns / 1ps

/*
 * 模块：tb_digital_clock
 * 功能：top_digital_clock 的测试平台
 */
module tb_digital_clock;

    // --- 参数定义 ---
    localparam CLK_FREQ   = 50_000_000;
    localparam CLK_PERIOD = (1_000_000_000 / CLK_FREQ); // 20ns
    
    // --- 信号定义 ---
    // 输入 (Testbench 驱动)
    logic clk_50mhz;
    logic rst_n;
    logic btn_set_n;
    logic btn_sel_n;
    logic btn_inc_n;
    
    // 输出 (DUT 驱动)
    logic [7:0] seg_out;
    logic [7:0] an_out;

    // --- 实例化 DUT (Design Under Test) ---
    top_digital_clock u_dut (
        .clk_50mhz(clk_50mhz),
        .rst_n    (rst_n),
        .btn_set_n(btn_set_n),
        .btn_sel_n(btn_sel_n),
        .btn_inc_n(btn_inc_n),
        .seg_out  (seg_out),
        .an_out   (an_out)
    );

    // --- 时钟生成 ---
    initial begin
        clk_50mhz = 1'b0;
        forever #(CLK_PERIOD / 2) clk_50mhz = ~clk_50mhz;
    end

    // --- 按钮模拟任务 ---
    // 模拟一次按键，持续 25ms，以确保长于 20ms 的消抖时间 [cite: 32]
    task press_button (ref logic button);
        $display("T=%0t: 模拟按键...", $time);
        button = 1'b0; // 按键按下 (低电平有效)
        #(25ms);       // 保持 25ms
        button = 1'b1; // 按键释放
        #(1ms);        // 释放后等待 1ms，防止FSM误判
    endtask

    // --- 激励 (Stimulus) ---
    initial begin
        $display("T=%0t: --- 仿真开始 ---", $time);
        
        // 1. 初始化和复位
        btn_set_n = 1'b1;
        btn_sel_n = 1'b1;
        btn_inc_n = 1'b1;
        rst_n     = 1'b0; // 施加复位
        #(CLK_PERIOD * 10);
        rst_n     = 1'b1; // 释放复位
        $display("T=%0t: 复位释放，时钟开始运行...", $time);
        
        // 2. 等待时钟运行 3 秒
        // 复位时，时钟被设为 16:25:00 
        // 3 秒后，时间应为 16:25:03
        #(3s);
        $display("T=%0t: 时钟运行 3 秒", $time);
        
        // 3. 进入设置模式 (HH)
        $display("T=%0t: --- 测试：进入设置模式 ---", $time);
        press_button(btn_set_n);
        // 此时 u_dut.u_setter.state应进入 STATE_SET_HH [cite: 3]
        // u_dut.set_en 应为 1 [cite: 86]
        // u_dut.blink_sel 应为 2'b00 [cite: 26]
        #(1s); // 观察 HH 闪烁
        
        // 4. 设置小时 (HH)
        $display("T=%0t: --- 测试：设置 HH ---", $time);
        press_button(btn_inc_n); // 16 -> 17
        press_button(btn_inc_n); // 17 -> 18
        // 此时 u_dut.u_setter.set_hh 应为 8'h18
        #(1s); 
        
        // 5. 切换到设置分钟 (MM)
        $display("T=%0t: --- 测试：切换到 MM ---", $time);
        press_button(btn_sel_n);
        // 此时 u_dut.u_setter.state应进入 STATE_SET_MM [cite: 3]
        // u_dut.blink_sel 应为 2'b01 [cite: 27]
        #(1s); // 观察 MM 闪烁
        
        // 6. 设置分钟 (MM)
        $display("T=%0t: --- 测试：设置 MM ---", $time);
        press_button(btn_inc_n); // 25 -> 26
        press_button(btn_inc_n); // 26 -> 27
        press_button(btn_inc_n); // 27 -> 28
        // 此时 u_dut.u_setter.set_mm 应为 8'h28
        #(1s);
        
        // 7. 切换到设置秒钟 (SS)
        $display("T=%0t: --- 测试：切换到 SS ---", $time);
        press_button(btn_sel_n);
        // 此时 u_dut.u_setter.state应进入 STATE_SET_SS [cite: 3]
        // u_dut.blink_sel 应为 2'b10 [cite: 28]
        #(1s); // 观察 SS 闪烁
        
        // 8. 设置秒钟 (SS)
        $display("T=%0t: --- 测试：设置 SS ---", $time);
        press_button(btn_inc_n); // 03 -> 04 (注意：设置时秒钟会从当前秒钟加载 [cite: 21])
        press_button(btn_inc_n); // 04 -> 05
        press_button(btn_inc_n); // 05 -> 06
        press_button(btn_inc_n); // 06 -> 07
        press_button(btn_inc_n); // 07 -> 08
        // 此时 u_dut.u_setter.set_ss 应为 8'h08
        #(1s);
        
        // 9. 退出设置模式
        $display("T=%0t: --- 测试：退出设置模式 ---", $time);
        press_button(btn_set_n);
        // 此时 u_dut.u_setter.state应返回 STATE_RUN [cite: 3]
        // u_dut.set_load 应产生一个脉冲 [cite: 13, 15, 17]
        // clock_counter 将加载 18:28:08
        
        // 10. 让时钟从新时间 18:28:08 开始运行
        $display("T=%0t: 时钟从 18:28:08 开始运行...", $time);
        #(10s);
        // 10 秒后，时间应为 18:28:18
        
        $display("T=%0t: --- 仿真结束 ---", $time);
        $stop;
    end

endmodule