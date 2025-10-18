// segment_dinamic.v
// 8-segment common-anode display decoder for dynamic display

// 位选择语法：
// signal[start_index +: width]  // 从start_index开始，向上选择width位
// signal[start_index -: width]  // 从start_index开始，向下选择width位
module segment_dinamic(
    input clk,
    input rst_n, // Active low reset
    input [31:0] data,
    input [7:0] select,
    output reg [7:0] seg
);
    
    reg [7:0] segment [0:7]; // 8 segments for 8 digits

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : segment_gen
            always @(*) begin
                case(data[i*4 +: 4])
                    4'b0000: segment[i] = 8'b00000011; // 0
                    4'b0001: segment[i] = 8'b10011111; // 1
                    4'b0010: segment[i] = 8'b00100101; // 2
                    4'b0011: segment[i] = 8'b00001101; // 3
                    4'b0100: segment[i] = 8'b10011001; // 4
                    4'b0101: segment[i] = 8'b01001001; // 5
                    4'b0110: segment[i] = 8'b01000001; // 6
                    4'b0111: segment[i] = 8'b00011111; // 7
                    4'b1000: segment[i] = 8'b00000001; // 8
                    4'b1001: segment[i] = 8'b00001001; // 9
                    4'b1010: segment[i] = 8'b00010001; // A
                    4'b1011: segment[i] = 8'b11000001; // b
                    4'b1100: segment[i] = 8'b01100011; // C
                    4'b1101: segment[i] = 8'b10000101; // d
                    4'b1110: segment[i] = 8'b01100001; // E
                    4'b1111: segment[i] = 8'b01110001; // F
                    default: segment[i] = 8'b11111110; // Off: Only the decimal point is on.
                endcase
            end
        end
    endgenerate

    always @(*) begin
        case (select)
            8'b00000001: seg = segment[0];
            8'b00000010: seg = segment[1];
            8'b00000100: seg = segment[2];
            8'b00001000: seg = segment[3];
            8'b00010000: seg = segment[4];
            8'b00100000: seg = segment[5];
            8'b01000000: seg = segment[6];
            8'b10000000: seg = segment[7];
            default: seg = 8'b11111111; // Off: All segments are off.
        endcase
    end

endmodule