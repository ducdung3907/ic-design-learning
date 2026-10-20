`timescale 1ns/1ps

module tb_synchronizer();

    localparam WIDTH = 4;
    localparam CLK_PERIOD = 10;

    logic             clk;
    logic             rst_n;
    logic [WIDTH-1:0] async_in;
    logic [WIDTH-1:0] sync_out;

    // Instantiate DUT
    synchronizer #(.WIDTH(WIDTH)) dut (
        .*
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Initialize
        rst_n = 0;
        async_in = '0;
        
        #(CLK_PERIOD * 2);
        rst_n = 1;
        
        // Test 1: Change input synchronously (aligned)
        @(posedge clk);
        async_in = 4'b1010;
        $display("[%0t] async_in changed to %b", $time, async_in);
        
        // Wait 2 clocks to see it appear
        @(posedge clk); 
        @(posedge clk);
        #1; // small delay to read after the edge
        $display("[%0t] sync_out is %b (Should be 1010)", $time, sync_out);

        // Test 2: Change input ASYNCHRONOUSLY
        // Let's change it exactly in the middle of a clock cycle
        #(CLK_PERIOD * 1.5);
        async_in = 4'b1111;
        $display("[%0t] async_in changed ASYNCHRONOUSLY to %b", $time, async_in);
        
        // Wait to observe propagation
        @(posedge clk);
        $display("[%0t] Flop 1 captures input. sync_out = %b", $time, sync_out);
        @(posedge clk);
        #1;
        $display("[%0t] Flop 2 captures Flop 1. sync_out = %b (Should be 1111)", $time, sync_out);

        #(CLK_PERIOD * 2);
        $display("[%0t] Test completed.", $time);
        $finish;
    end

endmodule
