module shift_reg8 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       load,
    input  logic       en,
    input  logic       serial_in,
    input  logic [7:0] data_in,
    output logic [7:0] q
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 8'h00;
        end else if (load) begin
            q <= data_in;
        end else if (en) begin
            q <= {q[6:0], serial_in};
        end
    end
    // =========================================================

endmodule
