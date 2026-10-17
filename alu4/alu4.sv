`timescale 1ns/1ps

module alu4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic [2:0] op,
    output logic [3:0] y,         
    output logic       zero,      
    output logic       carry,     
    output logic       overflow  
);

    localparam logic [2:0] OP_ADD = 3'b000;
    localparam logic [2:0] OP_SUB = 3'b001;
    localparam logic [2:0] OP_AND = 3'b010;
    localparam logic [2:0] OP_OR  = 3'b011;
    localparam logic [2:0] OP_XOR = 3'b100;
    localparam logic [2:0] OP_SLT = 3'b101;
    localparam logic [2:0] OP_SHL = 3'b110;
    localparam logic [2:0] OP_SHR = 3'b111;

    logic [4:0] h_carry; 
    logic fa,fb,fy;

    always_comb begin
        y = '0;
        carry = 1'b0;
        overflow = 1'b0;
        h_carry = '0;  fa = 1'b0;  fb = 1'b0;  fy = 1'b0;
        case (op)
            OP_ADD : begin
                h_carry = a + b;
                carry = h_carry[4];
                y = h_carry [3:0];
                fa = a[3];
                fb = b[3];
                fy = y[3];
                overflow = ((fa&fb&(~fy))|((~fa)&(~fb)&fy)); 
            end
            OP_SUB : begin
                h_carry = a - b;
                carry = h_carry[4];
                y = h_carry [3:0];
                fa = a[3];
                fb = b[3];
                fy = y[3];
                overflow = ((fa&(~fb)&(~fy))|((~fa)&fb&fy));
            end
            OP_AND : begin
                y = a&b;
                carry =1'b0;
                overflow = 1'b0;
            end
            OP_OR : begin
                y = a|b;
                carry =1'b0;
                overflow = 1'b0;
            end
            OP_XOR : begin
                y = a^b;
                carry =1'b0;
                overflow = 1'b0;
            end
            OP_SLT : begin
                carry =1'b0;
                overflow = 1'b0;
                if ($signed(a) < $signed(b)) begin
                    y = 4'd1;
                end else begin
                    y = '0;
                end
            end
            OP_SHL : begin
                carry = a[3];
                overflow = 1'b0;
                y = {a[2:0],1'b0};
            end
            OP_SHR : begin
                carry = a[0];
                overflow = 1'b0;
                y = {1'b0,a[3:1]};
            end
            default: begin
                y = '0;
                carry = 1'b0;
                overflow = 1'b0;
            end
        endcase
    end
    
    always_comb begin
        if(y==0) begin
            zero = 1'b1;
        end else begin
            zero = 1'b0;
        end
    end

endmodule