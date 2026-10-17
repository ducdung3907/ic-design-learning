`timescale 1ns/1ps

module tb_shift_reg8;

    logic       clk;
    logic       rst_n;
    logic       load;
    logic       en;
    logic       serial_in;
    logic [7:0] data_in;
    logic [7:0] q;

    shift_reg8 dut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .en(en),
        .serial_in(serial_in),
        .data_in(data_in),
        .q(q)
    );

    int checks = 0;
    int errors = 0;

    // 10ns clock period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_state(input logic [7:0] expected, input string msg);
        checks++;
        if (q !== expected) begin
            errors++;
            $display("[FAIL] %0t ns | %s | Expected: 8'b%b (0x%h), Got: 8'b%b (0x%h)", 
                     $time, msg, expected, expected, q, q);
        end else begin
            $display("[PASS] %0t ns | %s | q = 8'b%b (0x%h)", $time, msg, q, q);
        end
    endtask

    initial begin
        $dumpfile("shift_reg.vcd");
        $dumpvars(0, tb_shift_reg8);

        $display("---------------------------------------------------------");
        $display("Starting Testbench: 8-Bit Shift Register");
        $display("---------------------------------------------------------");

        // 1. Asynchronous Reset Check
        rst_n     = 1'b0;
        load      = 1'b0;
        en        = 1'b0;
        serial_in = 1'b0;
        data_in   = 8'hAA;
        #12;
        check_state(8'h00, "Asynchronous Reset Initial Check");

        // 2. Parallel Load Test
        @(negedge clk);
        rst_n   = 1'b1;
        load    = 1'b1;
        data_in = 8'b1010_0101; // 0xA5
        @(negedge clk);
        load    = 1'b0;
        check_state(8'b1010_0101, "Parallel Load (0xA5)");

        // 3. Hold Test (en=0, load=0)
        repeat (2) @(negedge clk);
        check_state(8'b1010_0101, "Hold State across clock cycles");

        // 4. Shift In 1s (Shift Left: bits move left, serial_in enters at LSB)
        en        = 1'b1;
        serial_in = 1'b1;

        @(negedge clk);
        check_state(8'b0100_1011, "Shift 1: in=1");

        @(negedge clk);
        check_state(8'b1001_0111, "Shift 2: in=1");

        // 5. Shift In 0s
        serial_in = 1'b0;

        @(negedge clk);
        check_state(8'b0010_1110, "Shift 3: in=0");

        @(negedge clk);
        check_state(8'b0101_1100, "Shift 4: in=0");

        // 6. Priority Check: load over en
        load    = 1'b1;
        en      = 1'b1; // Both asserted at once
        data_in = 8'hFF;
        serial_in = 1'b0;
        @(negedge clk);
        load    = 1'b0;
        en      = 1'b0;
        check_state(8'hFF, "Priority Test (load outranks en)");

        // 7. Async Reset Check Mid-Operation
        #3;
        rst_n = 1'b0;
        #1;
        check_state(8'h00, "Async Reset Asserted Mid-Cycle");

        #20;
        $display("---------------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: All %0d shift register checks passed! 🏆", checks);
        end else begin
            $display("FAILED: %0d error(s) out of %0d checks. ❌", errors, checks);
        end
        $display("---------------------------------------------------------");

        $finish;
    end

endmodule
