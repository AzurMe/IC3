// counter = 8'b10000000 -> 8'b01000000 -> 8'b00010000 -> 8'b00001000 -> 8'b00000100
//                 | ------------------------- <- 8'b00000001 <- 8'b00000010 <- |
module counter(
    input clk_div,
    input rst_n,
    input en,
    output [7:0] select
);

    reg [7:0] count_temp;
    always @(posedge clk_div or negedge rst_n) begin
        if (!rst_n) begin
            count_temp <= 8'b00000000;
        end else if (en) begin
            if (count_temp == 8'b00000001) begin
                count_temp <= {count_temp[0], count_temp[7:1]};
            end
        end
    end

    assign select = count_temp;

endmodule