module setup(
    input clk,
    input rst_n,
    input pulse,
    input clear,
    output reg level
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            level <= 1'b0;
        end else if (clear) begin
            level <= 1'b0;
        end else if (pulse) begin
            level <= 1'b1;
        end
    end

endmodule