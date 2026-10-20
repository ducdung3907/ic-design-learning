`timescale 1ns/1ps

module tb_mux4;

    // Inputs
    logic d0, d1, d2, d3;
    logic [1:0] sel;
    // Outputs
    logic y;

    // Instantiate Device Under Test (DUT)
    mux4 dut (
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .sel(sel),
        .y(y)
    );

    int checks = 0;
    int errors = 0;
    logic expected_y;

    initial begin
        $dumpfile("mux4.vcd");
        $dumpvars(0, tb_mux4);

        $display("--------------------------------------------------");
        $display("Starting Testbench: 1-Bit 4-to-1 Multiplexer");
        $display("--------------------------------------------------");

        // Loop through all 64 input combinations
        for (int i = 0; i < 64; i++) begin
            // Split index bits to drive inputs: d3, d2, d1, d0, sel[1], sel[0]
            {d3, d2, d1, d0, sel} = i[5:0];
            #1; // Delay for evaluation

            // Calculate expected outcome
            case (sel)
                2'b00: expected_y = d0;
                2'b01: expected_y = d1;
                2'b10: expected_y = d2;
                2'b11: expected_y = d3;
            endcase

            checks++;

            if (y !== expected_y) begin
                errors++;
                if (errors <= 10) begin
                    $display("FAIL: sel=%b | d0=%b, d1=%b, d2=%b, d3=%b -> got y=%b, expected y=%b",
                             sel, d0, d1, d2, d3, y, expected_y);
                end
            end
            #4;
        end

        $display("--------------------------------------------------");
        if (errors == 0) begin
            $display("PASS: All %0d checks passed successfully!", checks);
        end else begin
            $display("FAILED: %0d error(s) out of %0d checks.", errors, checks);
        end
        $display("--------------------------------------------------");

        $finish;
    end

endmodule
