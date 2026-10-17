module clk_divider #(
    parameter int N = 4 
)(
    input logic clk,
    input logic rst_n,
    output logic tick,
    output logic clk_out
);
    localparam int WIDTH = (N > 1) ? $clog2(N) : 1;
    logic [WIDTH-1:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
            clk_out <= 1'b0;
        end else begin
            if (count == N-1) begin
                count <= '0;
                clk_out <= ~clk_out;
            end else begin
                count <= count +1'b1;
            end
        end
    end

    always_comb begin
        tick = (count == N - 1);
    end
endmodule