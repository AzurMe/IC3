/*
 * 模块：time_setter
 * 功能：处理时间设置的 FSM (有限状态机)
 */
module time_setter (
    input  logic clk,
    input  logic rst_n,
    input  logic set_p,     // 设置键脉冲
    input  logic sel_p,     // 选择键脉冲
    input  logic inc_p,     // 递增键脉冲
    
    input  logic [7:0] cur_hh,  // 当前时间 (用于加载)
    input  logic [7:0] cur_mm,
    input  logic [7:0] cur_ss,
    
    output logic       set_en,     // 设为 1 时，counter 停止
    output logic       set_load,   // 脉冲，加载新时间到 counter
    output logic [7:0] set_hh,     // 要设置的时间
    output logic [7:0] set_mm,
    output logic [7:0] set_ss,
    output logic [1:0] blink_sel   // 闪烁选择
);

    typedef enum logic [1:0] {
        STATE_RUN,
        STATE_SET_HH,
        STATE_SET_MM,
        STATE_SET_SS
    } state_t;
    
    state_t state, next_state;
    logic [7:0] r_set_hh, r_set_mm, r_set_ss;

    // BCD 递增函数 (0-59 循环)
    function automatic [7:0] bcd_inc_59(input [7:0] val);
        if (val == 8'h59) return 8'h00;
        else if (val[3:0] == 9) return {val[7:4] + 1, 4'h0};
        else return val + 1;
    endfunction
    
    // BCD 递增函数 (0-23 循环)
    function automatic [7:0] bcd_inc_23(input [7:0] val);
        if (val == 8'h23) return 8'h00;
        else if (val[3:0] == 9) return {val[7:4] + 1, 4'h0};
        else return val + 1;
    endfunction

    // 状态机时序逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_RUN;
        end else begin
            state <= next_state;
        end
    end

    // 状态机组合逻辑 (状态转移)
    always_comb begin
        next_state = state;
        set_load   = 1'b0;
        
        case (state)
            STATE_RUN:
                if (set_p) next_state = STATE_SET_HH;
                
            STATE_SET_HH:
                if (set_p)begin
                    next_state = STATE_RUN; 
                    set_load = 1'b1; 
                end 
                else if (sel_p) next_state = STATE_SET_MM;
                
            STATE_SET_MM:
                if (set_p) begin
                    next_state = STATE_RUN; 
                    set_load = 1'b1; 
                end
                else if (sel_p) next_state = STATE_SET_SS;
                
            STATE_SET_SS:
                if (set_p) begin
                    next_state = STATE_RUN; 
                    set_load = 1'b1; 
                end
                else if (sel_p) next_state = STATE_SET_HH;
                
            default:
                next_state = STATE_RUN;
        endcase
    end
    
    // 设置寄存器 (用于存储正在设置的时间)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_set_hh <= 8'h00;
            r_set_mm <= 8'h00;
            r_set_ss <= 8'h00;
        end else begin
            if (state == STATE_RUN && next_state == STATE_SET_HH) begin
                // 刚进入设置模式，加载当前时间
                r_set_hh <= cur_hh;
                r_set_mm <= cur_mm;
                r_set_ss <= cur_ss;
            end 
            else if (state == STATE_SET_HH && inc_p) begin
                r_set_hh <= bcd_inc_23(r_set_hh);
            end
            else if (state == STATE_SET_MM && inc_p) begin
                r_set_mm <= bcd_inc_59(r_set_mm);
            end
            else if (state == STATE_SET_SS && inc_p) begin
                r_set_ss <= bcd_inc_59(r_set_ss);
            end
        end
    end

    // 输出
    assign set_hh = r_set_hh;
    assign set_mm = r_set_mm;
    assign set_ss = r_set_ss;
    assign set_en = (state != STATE_RUN);
    
    always_comb begin
        case(state)
            STATE_SET_HH: blink_sel = 2'b00; // 闪烁 HH
            STATE_SET_MM: blink_sel = 2'b01; // 闪烁 MM
            STATE_SET_SS: blink_sel = 2'b10; // 闪烁 SS
            default:      blink_sel = 2'b11; // 不闪烁
        endcase
    end
    
endmodule