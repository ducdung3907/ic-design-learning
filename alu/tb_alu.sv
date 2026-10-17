`timescale 1ns/1ps

// Exhaustive self-checking testbench for alu4: every op (8) x every a (16) x every b (16) = 2048 cases.
module tb_alu4;

    logic [3:0] a, b;
    logic [2:0] op;
    logic [3:0] y;
    logic       zero, carry, overflow;

    alu4 dut (.a(a), .b(b), .op(op), .y(y), .zero(zero), .carry(carry), .overflow(overflow));

    // Reference model. Returns {zero, carry, overflow, y}.
    function automatic logic [6:0] model(input logic [3:0] a, input logic [3:0] b, input logic [2:0] op);
        logic [3:0] ry;
        logic       rc, ro;
        logic [4:0] t;
        begin
            ry = 4'd0; rc = 1'b0; ro = 1'b0; t = 5'd0;
            case (op)
                3'b000: begin // ADD
                    t  = {1'b0, a} + {1'b0, b};
                    ry = t[3:0];
                    rc = t[4];
                    ro = (a[3] == b[3]) && (ry[3] != a[3]);
                end
                3'b001: begin // SUB
                    t  = {1'b0, a} - {1'b0, b};
                    ry = t[3:0];
                    rc = t[4];                        // 1 means borrow (a < b unsigned)
                    ro = (a[3] != b[3]) && (ry[3] != a[3]);
                end
                3'b010: ry = a & b;
                3'b011: ry = a | b;
                3'b100: ry = a ^ b;
                3'b101: ry = ($signed(a) < $signed(b)) ? 4'd1 : 4'd0;   // SLT
                3'b110: begin ry = {a[2:0], 1'b0}; rc = a[3]; end        // SHL
                3'b111: begin ry = {1'b0, a[3:1]}; rc = a[0]; end        // SHR
            endcase
            model = {(ry == 4'd0), rc, ro, ry};
        end
    endfunction

    function automatic string opname(input logic [2:0] op);
        case (op)
            3'b000: opname = "ADD";
            3'b001: opname = "SUB";
            3'b010: opname = "AND";
            3'b011: opname = "OR ";
            3'b100: opname = "XOR";
            3'b101: opname = "SLT";
            3'b110: opname = "SHL";
            3'b111: opname = "SHR";
        endcase
    endfunction

    int errors = 0;
    int checks = 0;
    logic [6:0] exp;

    task automatic apply_and_check(input logic [2:0] o, input logic [3:0] i, input logic [3:0] j);
        begin
            op = o;
            a  = i;
            b  = j;
            #1;
            exp = model(a, b, op);
            checks++;
            if ({zero, carry, overflow, y} !== exp) begin
                errors++;
                if (errors <= 10)
                    $display("FAIL %s a=%0d b=%0d: got y=%0d z=%b c=%b v=%b | expected y=%0d z=%b c=%b v=%b",
                             opname(op), a, b, y, zero, carry, overflow,
                             exp[3:0], exp[6], exp[5], exp[4]);
            end
        end
    endtask

    initial begin
        $dumpfile("alu4.vcd");
        $dumpvars(0, tb_alu4);

        // Pass 1: every op x a x b, one op at a time
        for (int o = 0; o < 8; o++)
            for (int i = 0; i < 16; i++)
                for (int j = 0; j < 16; j++)
                    apply_and_check(o[2:0], i[3:0], j[3:0]);

        // Pass 2: same cases, but the op changes on every step.
        // This catches outputs that "remember" an old value (a latch) because
        // some branch of your always_comb forgot to assign them.
        for (int i = 0; i < 16; i++)
            for (int j = 0; j < 16; j++)
                for (int o = 0; o < 8; o++)
                    apply_and_check(o[2:0], i[3:0], j[3:0]);

        // Pass 3: random order
        for (int n = 0; n < 4000; n++)
            apply_and_check($urandom_range(7, 0), $urandom_range(15, 0), $urandom_range(15, 0));

        $display("----------------------------------------");
        if (errors == 0)
            $display("PASS: all %0d cases passed", checks);
        else
            $display("FAILED: %0d error(s) out of %0d cases", errors, checks);
        $finish;
    end

endmodule