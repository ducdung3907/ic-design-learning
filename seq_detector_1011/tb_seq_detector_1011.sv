`timescale 1ns/1ps

module tb_seq_detector_1011;

    logic clk;
    logic rst_n;
    logic din;
    logic detected;

    seq_detector_1011 dut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .detected(detected)
    );

    int checks = 0;
    int errors = 0;

    // 10ns clock period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to send 1 bit and verify expected detection output
    task automatic send_bit(input logic bit_in, input logic exp_detected, input string desc);
        @(negedge clk);
        din = bit_in;
        @(posedge clk);
        #1; // Sample output shortly after rising edge

        checks++;
        if (detected !== exp_detected) begin
            errors++;
            $display("[FAIL] %0t ns | In: %b | Expected Det: %b, Got: %b | %s", 
                     $time, bit_in, exp_detected, detected, desc);
        end else begin
            $display("[PASS] %0t ns | In: %b | Det: %b | %s", 
                     $time, bit_in, detected, desc);
        end
    endtask

    initial begin
        $dumpfile("fsm.vcd");
        $dumpvars(0, tb_seq_detector_1011);

        $display("---------------------------------------------------------");
        $display("Starting Testbench: 1011 Sequence Detector (Moore)");
        $display("---------------------------------------------------------");

        // 1. Reset
        rst_n = 1'b0;
        din   = 1'b0;
        #12;
        rst_n = 1'b1;

        // 2. Stream sequence 1: Clean '1011'
        $display("\n--- Test 1: Standard '1011' sequence ---");
        send_bit(1'b1, 1'b0, "Received '1'");
        send_bit(1'b0, 1'b0, "Received '10'");
        send_bit(1'b1, 1'b0, "Received '101'");
        send_bit(1'b1, 1'b1, "Received '1011' -> DETECTED! 🎯");

        // 3. Stream sequence 2: Overlapping '1011011'
        $display("\n--- Test 2: Overlapping sequence '...011' ---");
        send_bit(1'b0, 1'b0, "Received '0' (from 10110)");
        send_bit(1'b1, 1'b0, "Received '1' (from 101101)");
        send_bit(1'b1, 1'b1, "Received '1' (from 1011011) -> OVERLAP DETECTED! 🎯");

        // 4. Stream sequence 3: False path '1010' recovery
        $display("\n--- Test 3: False alarm path '101011' ---");
        send_bit(1'b0, 1'b0, "Received '0'");
        send_bit(1'b1, 1'b0, "Received '101'");
        send_bit(1'b0, 1'b0, "Received '0' (False alarm, back to 10)");
        send_bit(1'b1, 1'b0, "Received '1' (now 101)");
        send_bit(1'b1, 1'b1, "Received '1' (now 1011) -> DETECTED! 🎯");

        #20;
        $display("---------------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: All %0d FSM sequence checks passed! 🏆", checks);
        end else begin
            $display("FAILED: %0d error(s) out of %0d checks. ❌", errors, checks);
        end
        $display("---------------------------------------------------------");

        $finish;
    end

endmodule
