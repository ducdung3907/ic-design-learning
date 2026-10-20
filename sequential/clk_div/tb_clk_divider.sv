`timescale 1ns/1ps

module tb_clk_divider;

    localparam int N = 4;

    logic clk;
    logic rst_n;
    logic tick;
    logic clk_out;

    clk_divider #(.N(N)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick),
        .clk_out(clk_out)
    );

    // 10ns clock period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("clk_div.vcd");
        $dumpvars(0, tb_clk_divider);

        $display("---------------------------------------------------------");
        $display("Testing Clock Divider (N = %0d)", N);
        $display("---------------------------------------------------------");

        // Reset sequence
        rst_n = 1'b0;
        #12;
        @(negedge clk);
        rst_n = 1'b1;

        // Monitor 16 clock cycles
        repeat (16) begin
            @(posedge clk);
            #1;
            $display("%0t ns | count: %0d | tick: %b | clk_out: %b",
                     $time, dut.count, tick, clk_out);
        end

        $display("---------------------------------------------------------");
        $display("Simulation finished. Check clk_div.vcd in waveform viewer!");
        $display("---------------------------------------------------------");
        $finish;
    end

endmodule
