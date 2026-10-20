`timescale 1ns/1ps

module tb_counter4;

    logic       clk;
    logic       rst_n;
    logic       en;
    logic [3:0] count;

    counter4 dut (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .count(count)
    );

    int errors = 0;
    int checks = 0;

    // 10ns clock period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_count(input logic [3:0] expected, input string msg);
        checks++;
        if (count !== expected) begin
            errors++;
            $display("[FAIL] %0t ns | %s | Expected: %0d, Got: %0d", 
                     $time, msg, expected, count);
        end else begin
            $display("[PASS] %0t ns | %s | Count: %0d", $time, msg, count);
        end
    endtask

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb_counter4);

        $display("---------------------------------------------------------");
        $display("Starting Testbench: 4-Bit Synchronous Counter");
        $display("---------------------------------------------------------");

        // 1. Initial Reset Check
        rst_n = 1'b0;
        en    = 1'b0;
        #12;
        check_count(4'd0, "Initial Asynchronous Reset");

        // 2. Count 0 -> 15
        @(negedge clk);
        rst_n = 1'b1;
        en    = 1'b1;

        for (int i = 1; i <= 15; i++) begin
            @(negedge clk);
            check_count(i[3:0], "Counting Up");
        end

        // 3. Roll-over (15 -> 0)
        @(negedge clk);
        check_count(4'd0, "Roll-over 15 to 0");

        // 4. Hold when en = 0
        @(negedge clk);
        en = 1'b0;
        repeat (3) @(negedge clk);
        check_count(4'd1, "Hold count when en=0");

        // 5. Asynchronous reset during active count
        @(negedge clk);
        en = 1'b1;
        @(negedge clk);
        #2;
        rst_n = 1'b0; // Assert reset between clock edges
        #1;
        check_count(4'd0, "Async Reset Mid-Cycle");

        #20;
        $display("---------------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: All %0d checks passed! 🏆", checks);
        end else begin
            $display("FAILED: %0d error(s) out of %0d checks. ❌", errors, checks);
        end
        $display("---------------------------------------------------------");

        $finish;
    end

endmodule
