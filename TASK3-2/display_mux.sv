/*
 * 模块：display_mux
 * 功能：8 位数码管动态扫描
 * 映射: an[5]=HH_hi, an[4]=HH_lo, an[3]=MM_hi, an[2]=MM_lo, an[1]=SS_hi, an[0]=SS_lo
 * an[4] 和 an[2] 上的小数点 (DP) 点亮作为 ":"
 */
module display_mux (
    input  logic clk,
    input  logic rst_n,
    input  logic [7:0] hh,        // BCD
    input  logic [7:0] mm,        // BCD
    input  logic [7:0] ss,        // BCD
    input  logic       blink_en,  // 闪烁信号 (来自 2Hz 时钟)
    input  logic [1:0] blink_sel, // 闪烁选择
    
    output logic [7:0] seg_out,   // {dp, g, f, e, d, c, b, a} - 低电平有效
    output logic [7:0] an_out     // 位选 - 低电平有效
);

    // 动态扫描计数器 (e.g., 50MHz / 2^16 = ~763Hz 刷新率)
    logic [18:0] mux_cnt;
    logic [2:0]  sel; // 3'b000 ~ 3'b111 (选择 8 位中的一位)
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) mux_cnt <= '0;
        else        mux_cnt <= mux_cnt + 1;
    end
    
    assign sel = mux_cnt[18:16]; // 使用高位作为选择信号

    logic [3:0] digit_data;
    logic       dp;
    logic [6:0] seg_data;
    logic       digit_off;
    
    // 1. 数据选择器
    always_comb begin
        dp = 1'b1; // 默认 DP 熄灭 (高电平)
        case (sel)
            3'h0:    begin 
                digit_data = ss[3:0];  // SS_lo
                an_out = 8'b00000001;
            end
            3'h1:    begin
                digit_data = ss[7:4];  // SS_hi
                an_out = 8'b00000010;
            end
            3'h2:    begin
                {dp, digit_data} = {1'b0, mm[3:0]}; // MM_lo + ":"
                an_out = 8'b00000100;
            end
            3'h3:    begin
                digit_data = mm[7:4];  // MM_hi
                an_out = 8'b00001000;
            end
            3'h4:    begin
                {dp, digit_data} = {1'b0, hh[3:0]}; // HH_lo + ":"
                an_out = 8'b00010000;
            end
            3'h5:    begin
                digit_data = hh[7:4];  // HH_hi
                an_out = 8'b00100000;
            end
            default: begin
                digit_data = 4'h0;     // 默认显示 0
                an_out = 8'b00000000;      // 熄灭所有位
            end
        endcase
    end

    // 2. BCD 译码
    bcd_to_7seg u_decoder (
        .bcd_in (digit_data),
        .seg_out(seg_data)
    );

    // 3. 闪烁逻辑
    always_comb begin
        digit_off = 1'b0;
        if (blink_en) begin // 只有在闪烁信号为高时才判断
            case (blink_sel)
                2'b00: if (sel == 3'h4 || sel == 3'h5) digit_off = 1'b1; // 闪烁 HH
                2'b01: if (sel == 3'h2 || sel == 3'h3) digit_off = 1'b1; // 闪烁 MM
                2'b10: if (sel == 3'h0 || sel == 3'h1) digit_off = 1'b1; // 闪烁 SS
                default: digit_off = 1'b0;
            endcase
        end
    end

    // 4. 输出
    // {dp, g, f, e, d, c, b, a}
    // 假设你的板子 dp 是 seg[7]
    assign seg_out =  digit_off ? 8'b11111111 : {dp, seg_data};
    
    // 位选，低电平有效

endmodule