`timescale 1ns/1ps

module tb_async_fifo;

    parameter int unsigned WIDTH = 8;
    parameter int unsigned DEPTH = 8;

    logic wclk;
    logic rclk;
    logic rst_n;

    logic wr_en;
    logic [WIDTH-1:0] din;
    logic full;

    logic rd_en;
    logic [WIDTH-1:0] dout;
    logic empty;

    // Reference queue: accepted writes are pushed; accepted reads are popped.
    logic [WIDTH-1:0] expected_q[$];

    int unsigned accepted_writes = 0;
    int unsigned accepted_reads  = 0;
    int unsigned errors          = 0;

    async_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wclk  (wclk),
        .rclk  (rclk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .din   (din),
        .full  (full),
        .rd_en (rd_en),
        .dout  (dout),
        .empty (empty)
    );

    // Independent clocks. The phase offset avoids coincident active edges.
    initial begin
        wclk = 1'b0;
        forever #5 wclk = ~wclk;       // 10 ns period
    end

    initial begin
        rclk = 1'b0;
        #1;
        forever #7 rclk = ~rclk;       // 14 ns period, offset by 1 ns
    end

    // Scoreboard write monitor: only count writes accepted by the DUT.
    always @(posedge wclk) begin
        if (rst_n && wr_en && !full) begin
            expected_q.push_back(din);
            accepted_writes++;
        end
    end

    // Scoreboard read monitor: check FIFO ordering and output data.
    always @(posedge rclk) begin : read_scoreboard
        logic [WIDTH-1:0] expected_data;

        if (rst_n && rd_en && !empty) begin
            if (expected_q.size() == 0) begin
                $error("%0t: DUT accepted a read when reference queue is empty", $time);
                errors++;
            end else begin
                expected_data = expected_q.pop_front();
                accepted_reads++;

                // Allow the DUT's nonblocking assignment to update dout.
                #1;
                if (dout !== expected_data) begin
                    $error("%0t: DATA MISMATCH: expected 0x%0h, got 0x%0h",
                           $time, expected_data, dout);
                    errors++;
                end
            end
        end
    end

    // Write one word, waiting for full to deassert if necessary.
    task automatic write_word(input logic [WIDTH-1:0] value);
        @(negedge wclk);
        while (full) begin
            @(negedge wclk);
        end
        din   = value;
        wr_en = 1'b1;
        @(posedge wclk);
        #1;
        wr_en = 1'b0;
    endtask

    // Read one word, waiting until the synchronized empty flag deasserts.
    task automatic read_word;
        @(negedge rclk);
        while (empty) begin
            @(negedge rclk);
        end
        rd_en = 1'b1;
        @(posedge rclk);
        #1;
        rd_en = 1'b0;
    endtask

    initial begin : test_sequence
        int i;

        rst_n = 1'b0;
        wr_en = 1'b0;
        din   = '0;
        rd_en = 1'b0;

        // Hold reset for several write-clock edges, then allow settling.
        repeat (3) @(negedge wclk);
        rst_n = 1'b1;
        repeat (3) @(posedge rclk);

        $display("[TEST 1] Fill FIFO to full...");
        for (i = 0; i < DEPTH; i++) begin
            write_word(8'h30 + i);
        end
        #1;
        if (!full)
            $fatal(1, "FIFO did not assert full after %0d accepted writes", DEPTH);
        if (expected_q.size() != DEPTH)
            $fatal(1, "Scoreboard expected %0d entries after fill, found %0d",
                   DEPTH, expected_q.size());

        $display("[TEST 2] Attempt an extra write while full...");
        @(negedge wclk);
        din   = 'hE7;
        wr_en = 1'b1;
        @(posedge wclk);
        #1;
        wr_en = 1'b0;
        if (expected_q.size() != DEPTH)
            $fatal(1, "Overflow protection failed: reference queue size changed");

        $display("[TEST 3] Drain FIFO and check read order...");
        for (i = 0; i < DEPTH; i++) begin
            read_word();
        end
        #1;
        if (!empty)
            $fatal(1, "FIFO did not assert empty after draining");
        if (expected_q.size() != 0)
            $fatal(1, "Scoreboard is not empty after draining");

        $display("[TEST 4] Attempt a read while empty...");
        @(negedge rclk);
        rd_en = 1'b1;
        @(posedge rclk);
        #1;
        rd_en = 1'b0;
        if (expected_q.size() != 0)
            $fatal(1, "Underflow protection failed: reference queue changed");

        $display("[TEST 5] Randomized independent read/write traffic...");
        fork
            begin : random_writer
                repeat (1000) begin
                    @(negedge wclk);
                    din   = $urandom;
                    wr_en = ($urandom_range(0, 99) < 60);
                end
                @(negedge wclk);
                wr_en = 1'b0;
            end
            begin : random_reader
                repeat (1000) begin
                    @(negedge rclk);
                    rd_en = ($urandom_range(0, 99) < 60);
                end
                @(negedge rclk);
                rd_en = 1'b0;
            end
        join

        // Drain any remaining accepted writes.
        $display("[TEST 6] Drain remaining entries...");
        while (expected_q.size() != 0) begin
            read_word();
        end

        // Allow the synchronized pointers and flags to settle.
        repeat (5) @(posedge rclk);
        repeat (5) @(posedge wclk);
        #1;

        if (!empty)
            $fatal(1, "FIFO empty flag did not return high after final drain");
        if (full)
            $fatal(1, "FIFO full flag did not return low after final drain");
        if (expected_q.size() != 0)
            $fatal(1, "Reference queue not empty at end of test");
        if (errors != 0)
            $fatal(1, "TEST FAILED with %0d scoreboard error(s)", errors);

        $display("PASS: Async FIFO test completed successfully.");
        $display("Accepted writes: %0d | Accepted reads: %0d",
                 accepted_writes, accepted_reads);
        $finish;
    end

    // Watchdog prevents a hung test from running indefinitely.
    initial begin
        #100000;
        $fatal(1, "Testbench timeout: check empty/full logic and synchronizers");
    end

endmodule
