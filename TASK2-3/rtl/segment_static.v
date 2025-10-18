// segment_static.v
// 8-segment common-anode display decoder for static display
module segment_static(
    input [3:0] data,
    input rst_n_combinational, // Active low reset (used in combinational logic)
    output reg [7:0] segment,
    output reg [7:0] select // Select which digit to display
);
    always @(*) begin
        if (!rst_n_combinational) begin
            select = 8'b00000000;
        end else begin
            select = 8'b10000010;
        end
    end
        
    always @(*) begin
        case(data)
            4'b0000: segment = 8'b00000011; // 0
            4'b0001: segment = 8'b10011111; // 1
            4'b0010: segment = 8'b00100101; // 2
            4'b0011: segment = 8'b00001101; // 3
            4'b0100: segment = 8'b10011001; // 4
            4'b0101: segment = 8'b01001001; // 5
            4'b0110: segment = 8'b01000001; // 6           
            4'b0111: segment = 8'b00011111; // 7
            4'b1000: segment = 8'b00000001; // 8
            4'b1001: segment = 8'b00001001; // 9
            4'b1010: segment = 8'b00010001; // A
            4'b1011: segment = 8'b11000001; // b
            4'b1100: segment = 8'b01100011; // C
            4'b1101: segment = 8'b10000101; // d
            4'b1110: segment = 8'b01100001; // E
            4'b1111: segment = 8'b01110001; // F
            default: segment = 8'b11111110; // Off: Only the decimal point is on.
        endcase
    end

endmodule