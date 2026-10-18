module bin2gray #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);
genvar i;
generate
    assign gray[WIDTH-1] = bin[WIDTH-1];
    for (i = WIDTH -2; i>=0; i=i-1) begin
        assign gray[i] = (bin[i+1])^(bin[i]);
    end
endgenerate    
endmodule

module gray2bin #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] gray,
    output logic [WIDTH-1:0] bin
);
genvar i;
generate
    assign bin[WIDTH-1] = gray[WIDTH-1];
    for (i = WIDTH -2; i>=0; i=i-1) begin
        assign bin[i] = (bin[i+1])^(gray[i]);
    end
endgenerate    
endmodule