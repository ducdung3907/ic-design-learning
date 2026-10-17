// tb_sync_fifo.sv
// Self-checking testbench for sync_fifo.sv.
// Includes directed boundary cases plus constrained random traffic.

`timescale 1ns/1ps

module tb_sync_fifo;
    // Deliberately choose a non-power-of-two depth to exercise pointer wrap.
    localparam int unsigned WIDTH = 8;
    localparam int unsigned DEPTH = 5;
    localparam int unsigned RANDOM_CYCLES = 5000;

    logic                     clk = 1'b0;
    logic                     rst_n = 1'b0;
    logic                     wr_en = 1'b0;
    logic                     rd_en = 1'b0;
    logic [WIDTH-1:0]         din = '0;
    logic [WIDTH-1:0]         dout;
    logic                     full;
    logic                     empty;
    logic [$clog2(DEPTH+1)-1:0] count;

    logic [WIDTH-1:0] model_q [0:DEPTH-1];
    int unsigned model_count = 0;
    logic [WIDTH-1:0] expected_dout = '0;

    int unsigned cycles = 0;
    int unsigned writes_accepted = 0;
    int unsigned reads_accepted = 0;
    int unsigned rejected_writes = 0;
    int unsigned rejected_reads = 0;
    int unsigned simultaneous_attempts = 0;
    int unsigned max_occupancy = 0;

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .din   (din),
        .dout  (dout),
        .full  (full),
        .empty (empty),
        .count (count)
    );

    always #5 clk = ~clk;

    task automatic check_state(input string phase);
        begin
            if (count != model_count) begin
                $error("%s: count mismatch: DUT=%0d model=%0d at cycle %0d",
                       phase, count, model_count, cycles);
                $fatal(1);
            end
            if (full !== (model_count == DEPTH)) begin
                $error("%s: full mismatch: DUT=%b model_count=%0d",
                       phase, full, model_count);
                $fatal(1);
            end
            if (empty !== (model_count == 0)) begin
                $error("%s: empty mismatch: DUT=%b model_count=%0d",
                       phase, empty, model_count);
                $fatal(1);
            end
            if (dout !== expected_dout) begin
                $error("%s: dout mismatch: DUT=0x%0h expected=0x%0h at cycle %0d",
                       phase, dout, expected_dout, cycles);
                $fatal(1);
            end
        end
    endtask

    // Drive on falling edge, let the DUT sample on rising edge, then check
    // after nonblocking assignments have settled. Scoreboard acceptance is
    // based on the occupancy before that rising edge, matching the DUT spec.
    task automatic step(
        input bit                 request_write,
        input bit                 request_read,
        input logic [WIDTH-1:0]   write_data
    );
        bit wr_accept;
        bit rd_accept;
        logic [WIDTH-1:0] read_value;
        int unsigned old_count;
        int i;
        begin
            @(negedge clk);
            wr_en = request_write;
            rd_en = request_read;
            din   = write_data;

            old_count = model_count;
            wr_accept = request_write && (old_count < DEPTH);
            rd_accept = request_read  && (old_count > 0);
            read_value = expected_dout;
            if (rd_accept)
                read_value = model_q[0];

            if (request_write && request_read)
                simultaneous_attempts++;
            if (request_write && !wr_accept)
                rejected_writes++;
            if (request_read && !rd_accept)
                rejected_reads++;
            if (wr_accept)
                writes_accepted++;
            if (rd_accept)
                reads_accepted++;

            @(posedge clk);
            // Update the reference model in the same logical order as a FIFO:
            // remove the accepted oldest item, then append an accepted write.
            if (rd_accept) begin
                for (i = 0; i < DEPTH-1; i++) begin
                    if (i < model_count-1)
                        model_q[i] = model_q[i+1];
                end
                model_count--;
                expected_dout = read_value;
            end

            if (wr_accept) begin
                model_q[model_count] = write_data;
                model_count++;
            end

            if (model_count > max_occupancy)
                max_occupancy = model_count;
            cycles++;

            #1;
            check_state("after step");
        end
    endtask

    int unsigned seed;
    int unsigned r;
    int k;

    initial begin
        // Optional deterministic seed: vvp sim.vvp +SEED=1234
        if ($value$plusargs("SEED=%d", seed)) begin
            r = $urandom(seed);
            $display("Random seed supplied: %0d", seed);
        end else begin
            seed = 32'h1bad_f00d;
            r = $urandom(seed);
            $display("Using default random seed: 0x%08h", seed);
        end

        // Assert reset across clock edges, then release away from active edge.
        rst_n = 1'b0;
        wr_en = 1'b0;
        rd_en = 1'b0;
        din   = '0;
        repeat (2) @(posedge clk);
        #1;
        model_count = 0;
        expected_dout = '0;
        check_state("reset");
        @(negedge clk);
        rst_n = 1'b1;

        // Directed case 1: fill to capacity, then prove extra writes are dropped.
        for (k = 0; k < DEPTH + 2; k++)
            step(1'b1, 1'b0, WIDTH'(8'h20 + k));

        // Directed case 2: when full, simultaneous request reads only;
        // the write is rejected because full was true before this edge.
        step(1'b1, 1'b1, 8'hEE);

        // Drain past empty to prove empty reads are ignored and dout holds.
        for (k = 0; k < DEPTH + 2; k++)
            step(1'b0, 1'b1, '0);

        // Directed case 3: when empty, simultaneous request writes only;
        // the read is rejected because empty was true before this edge.
        step(1'b1, 1'b1, 8'hA5);
        step(1'b0, 1'b1, '0);

        // Directed case 4: interleaved operations force pointer wrap-around.
        for (k = 0; k < (DEPTH * 4); k++) begin
            step(1'b1, 1'b0, WIDTH'($urandom));
            if ((k % 2) == 0)
                step(1'b1, 1'b1, WIDTH'($urandom));
            step(1'b0, 1'b1, '0);
        end

        // Randomized phase. Independent weighted requests exercise normal,
        // full, empty and simultaneous read/write conditions.
        for (k = 0; k < RANDOM_CYCLES; k++) begin
            bit random_wr;
            bit random_rd;
            logic [WIDTH-1:0] random_data;
            random_wr  = ($urandom_range(0, 99) < 58);
            random_rd  = ($urandom_range(0, 99) < 58);
            random_data = WIDTH'($urandom);
            step(random_wr, random_rd, random_data);
        end

        // A final idle step checks that dout is held when no read is accepted.
        step(1'b0, 1'b0, '0);

        $display("PASS: sync_fifo self-check completed.");
        $display("  cycles                 : %0d", cycles);
        $display("  accepted writes        : %0d", writes_accepted);
        $display("  accepted reads         : %0d", reads_accepted);
        $display("  rejected writes        : %0d", rejected_writes);
        $display("  rejected reads         : %0d", rejected_reads);
        $display("  simultaneous attempts  : %0d", simultaneous_attempts);
        $display("  maximum occupancy      : %0d / %0d", max_occupancy, DEPTH);
        if (max_occupancy != DEPTH || rejected_writes == 0 || rejected_reads == 0)
            $fatal(1, "Coverage check failed: expected full and empty boundary cases.");
        $finish;
    end
endmodule
