`timescale 1ns/1ps

// Self-checking testbench for the 4-bit ripple-carry adder exercise.
// It tests full_adder exhaustively (8 cases) and adder4 exhaustively (512 cases).
module tb_adder4;

    // ---- full_adder under test ----
    logic fa_a, fa_b, fa_cin;
    logic fa_sum, fa_cout;
    full_adder u_fa (.a(fa_a), .b(fa_b), .cin(fa_cin), .sum(fa_sum), .cout(fa_cout));

    // ---- adder4 under test ----
    logic [3:0] a, b;
    logic       cin;
    logic [3:0] sum;
    logic       cout;
    adder4 u_adder (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    int errors = 0;
    int checks = 0;

    logic [1:0] exp_fa;
    logic [4:0] exp_add;

    initial begin
        $dumpfile("adder4.vcd");
        $dumpvars(0, tb_adder4);

        // Part 1: full adder, all 8 input combinations
        for (int i = 0; i < 8; i++) begin
            {fa_a, fa_b, fa_cin} = i[2:0];
            #1;
            exp_fa = fa_a + fa_b + fa_cin;
            checks++;
            if ({fa_cout, fa_sum} !== exp_fa) begin
                errors++;
                $display("FAIL full_adder: a=%b b=%b cin=%b -> cout=%b sum=%b, expected cout=%b sum=%b",
                         fa_a, fa_b, fa_cin, fa_cout, fa_sum, exp_fa[1], exp_fa[0]);
            end
        end

        // Part 2: 4-bit adder, all 512 input combinations
        for (int i = 0; i < 512; i++) begin
            {a, b, cin} = i[8:0];
            #1;
            exp_add = a + b + cin;
            checks++;
            if ({cout, sum} !== exp_add) begin
                errors++;
                if (errors <= 10)
                    $display("FAIL adder4: %0d + %0d + %0d -> got cout=%b sum=%0d, expected cout=%b sum=%0d",
                             a, b, cin, cout, sum, exp_add[4], exp_add[3:0]);
            end
            #9;  // spacing so waveforms are easy to read
        end

        $display("----------------------------------------");
        if (errors == 0)
            $display("PASS: all %0d checks passed", checks);
        else
            $display("FAILED: %0d error(s) out of %0d checks", errors, checks);
        $finish;
    end

endmodule
