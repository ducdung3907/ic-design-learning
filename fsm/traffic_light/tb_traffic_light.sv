`timescale 1ns/1ps

// Checks one traffic_light instance with the given GREEN_TIME (G) and YELLOW_TIME (Y).
// It checks, on every clock cycle:
//   1. the exact expected light pattern for that cycle
//   2. safety: both directions are never green/yellow at the same time
// It also tests reset in the middle of operation.
module tl_checker #(
    parameter int G = 5,
    parameter int Y = 2
) (
    input  logic   clk,
    output logic   done,
    output integer errors
);
    localparam int PERIOD = 2 * (G + Y);

    // {red, yellow, green}
    localparam logic [2:0] RED = 3'b100;
    localparam logic [2:0] YEL = 3'b010;
    localparam logic [2:0] GRN = 3'b001;

    logic       rst_n;
    logic [2:0] ns, ew;

    traffic_light #(.GREEN_TIME(G), .YELLOW_TIME(Y)) dut (
        .clk(clk), .rst_n(rst_n), .ns(ns), .ew(ew)
    );

    // Expected {ns, ew} for clock cycle n counted from reset release.
    function automatic logic [5:0] expected(input int n);
        int p;
        begin
            p = n % PERIOD;
            if      (p < G)         expected = {GRN, RED};
            else if (p < G + Y)     expected = {YEL, RED};
            else if (p < 2*G + Y)   expected = {RED, GRN};
            else                    expected = {RED, YEL};
        end
    endfunction

    task automatic check(input int n);
        logic [5:0] e;
        begin
            e = expected(n);
            if ((ns[0] | ns[1]) && (ew[0] | ew[1])) begin
                errors++;
                if (errors <= 5)
                    $display("[G=%0d Y=%0d] cycle %0d: SAFETY VIOLATION ns=%b ew=%b (both directions not red)",
                             G, Y, n, ns, ew);
            end else if ({ns, ew} !== e) begin
                errors++;
                if (errors <= 5)
                    $display("[G=%0d Y=%0d] cycle %0d: got ns=%b ew=%b, expected ns=%b ew=%b",
                             G, Y, n, ns, ew, e[5:3], e[2:0]);
            end
        end
    endtask

    task automatic check_reset_state(input int which);
        begin
            if ({ns, ew} !== {GRN, RED}) begin
                errors++;
                if (errors <= 5)
                    $display("[G=%0d Y=%0d] reset check %0d: got ns=%b ew=%b, expected ns=%b (green) ew=%b (red)",
                             G, Y, which, ns, ew, GRN, RED);
            end
        end
    endtask

    task automatic run_cycles(input int count);
        begin
            for (int n = 0; n < count; n++) begin
                if (n > 0) @(negedge clk);
                check(n);
            end
        end
    endtask

    initial begin
        done   = 1'b0;
        errors = 0;
        rst_n  = 1'b0;

        // Initial reset: hold for two clock edges. State must be NS green, EW red.
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_reset_state(1);

        // Release reset on a falling edge; this instant is cycle 0.
        @(negedge clk);
        rst_n = 1'b1;
        #1;
        run_cycles(3 * PERIOD);

        // Reset again in the middle of operation (during EW green) and run again.
        @(negedge clk);
        rst_n = 1'b0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        check_reset_state(2);
        @(negedge clk);
        rst_n = 1'b1;
        #1;
        run_cycles(2 * PERIOD);

        done = 1'b1;
    end
endmodule


module tb_traffic_light;

    logic clk = 1'b0;
    always #5 clk = ~clk;

    logic   d0, d1, d2;
    integer e0, e1, e2;

    // Three different timings, so hard-coded durations will be caught
    tl_checker #(.G(5), .Y(2)) c0 (.clk(clk), .done(d0), .errors(e0));
    tl_checker #(.G(3), .Y(1)) c1 (.clk(clk), .done(d1), .errors(e1));
    tl_checker #(.G(8), .Y(3)) c2 (.clk(clk), .done(d2), .errors(e2));

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        wait (d0 && d1 && d2);
        #1;
        $display("----------------------------------------");
        if (e0 + e1 + e2 == 0)
            $display("PASS: all checks passed for 3 timing configurations");
        else
            $display("FAILED: %0d error(s) (G=5,Y=2: %0d | G=3,Y=1: %0d | G=8,Y=3: %0d)",
                     e0 + e1 + e2, e0, e1, e2);
        $finish;
    end

    // Safety net in case the design hangs the simulation
    initial begin
        #2000000;
        $display("TIMEOUT");
        $finish;
    end

endmodule