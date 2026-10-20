module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    assign sum  = a^b^cin;
    assign cout = (a&b)|(a&cin)|(b&cin);
endmodule

module adder4_slow (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);

    logic c1,c2,c3;

    full_adder f0 (a[0],b[0],cin,sum[0],c1);
    full_adder f1 (a[1],b[1],c1,sum[1],c2);
    full_adder f2 (a[2],b[2],c2,sum[2],c3);
    full_adder f3 (a[3],b[3],c3,sum[3],cout);
endmodule

module adder4 #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout
);
    logic[WIDTH:0] carry;
    assign carry[0] =cin;
    assign cout = carry[WIDTH];
    generate
        genvar i;
        for (i=0; i <WIDTH; i =i+1) begin : gen_adders
            full_adder f (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
endmodule