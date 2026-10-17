module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 5
)(
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic rd_en,
    input logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout,
    output logic full,
    output logic empty,
    output logic [$clog2(DEPTH+1)-1:0] count
);

logic [WIDTH-1:0] mem [0:DEPTH-1];

localparam int PTR_W = (DEPTH > 1) ? $clog2(DEPTH) : 1;
logic [PTR_W-1:0] rd_ptr;
logic [PTR_W-1:0] wr_ptr;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <='0;
        rd_ptr <='0;
        wr_ptr <='0;
        dout <='0;
    end else begin
        if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            if (wr_ptr == (DEPTH -1)) begin
                wr_ptr <= '0;
            end else begin
                wr_ptr <= wr_ptr +1;
            end
        end if (rd_en && !empty) begin
            dout <= mem[rd_ptr];
            if (rd_ptr == (DEPTH-1)) begin
                rd_ptr <= '0;
            end else begin
                rd_ptr <= rd_ptr +1;
            end
        end
        case ({wr_en && !full, rd_en && !empty})
            2'b10: count <= count + 1'b1; 
            2'b01: count <= count - 1'b1; 
            default: count <= count;      
        endcase
    end
end

always_comb begin
    empty = (count == 0);
    full = (count == DEPTH);
end

endmodule