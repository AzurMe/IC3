/*
 * 模块：bcd_to_7seg
 * 功能：BCD 码转 7 段共阳极数码管 (低电平有效)
 */
module bcd_to_7seg (
    input  logic [3:0] bcd_in,
    output logic [6:0] seg_out // {g, f, e, d, c, b, a}
);

    always_comb begin
        case (bcd_in)
            4'h0:    seg_out = ~7'b1000000; // 0 (0111111)
            4'h1:    seg_out = ~7'b1111001; // 1 (0000110)
            4'h2:    seg_out = ~7'b0100100; // 2 (1011011)
            4'h3:    seg_out = ~7'b0110000; // 3 (1001111)
            4'h4:    seg_out = ~7'b0011001; // 4 (1100110)
            4'h5:    seg_out = ~7'b0010010; // 5 (1101101)
            4'h6:    seg_out = ~7'b0000010; // 6 (1111101)
            4'h7:    seg_out = ~7'b1111000; // 7 (0000111)
            4'h8:    seg_out = ~7'b0000000; // 8 (1111111)
            4'h9:    seg_out = ~7'b0010000; // 9 (1101111)
            default: seg_out =  7'b0000000; // Off
        endcase
    end

endmodule