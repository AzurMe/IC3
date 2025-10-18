// Divide input clock by 5000
module clk_div(
    input clk,
    input rst_n,
    output reg clk_out
);

    reg [12:0] count;
    // counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 13'b0000;
        end
        else begin
            if (count == 13'd4999) begin
                count <= 13'd0;
            end
            else begin
                count <= count + 1;
            end
        end
    end

    // combinational logic
    always @(*) begin
        if (count < 13'd2500) begin
            clk_out = 1'b1;
        end
        else begin
            clk_out = 1'b0;
        end
    end

endmodule