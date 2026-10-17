module synchronizer #(
    parameter WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);
    logic [WIDTH-1:0] cache; 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_out <='0;
            cache <='0;
        end else begin
            cache <= async_in;
            sync_out <= cache;
        end
    end
endmodule
