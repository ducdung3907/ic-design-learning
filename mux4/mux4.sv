module mux4 #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic [WIDTH-1:0] d2,
    input  logic [WIDTH-1:0] d3,
    input  logic [1:0] sel,
    output logic [WIDTH-1:0] y
);

//    assign y = sel[1] ? (sel[0] ? d3 : d2) : (sel[0] ? d1 : d0);

always_comb begin
    case (sel)
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10: y = d2;
        2'b11: y = d3;
        default: y = '0; // Default case to avoid latches
    endcase
endmodule
