`timescale 1ns/1ps

module tb_seven_seg;

    logic [3:0] hex_in;
    logic [6:0] segments;

    // Instantiate Device Under Test
    seven_seg dut (
        .hex_in(hex_in),
        .segments(segments)
    );

    int checks = 0;
    int errors = 0;
    logic [6:0] expected_segments;

    // Lookup table inside testbench to check against
    function automatic logic [6:0] get_expected(logic [3:0] val);
        case (val)
            4'h0: return 7'b1111110;
            4'h1: return 7'b0110000;
            4'h2: return 7'b1101101;
            4'h3: return 7'b1111001;
            4'h4: return 7'b0110011;
            4'h5: return 7'b1011011;
            4'h6: return 7'b1011111;
            4'h7: return 7'b1110000;
            4'h8: return 7'b1111111;
            4'h9: return 7'b1111011;
            4'hA: return 7'b1110111;
            4'hB: return 7'b0011111;
            4'hC: return 7'b1001110;
            4'hD: return 7'b0111101;
            4'hE: return 7'b1001111;
            4'hF: return 7'b1000111;
            default: return 7'b0000000;
        endcase
    endfunction

    initial begin
        $dumpfile("seven_seg.vcd");
        $dumpvars(0, tb_seven_seg);

        $display("--------------------------------------------------");
        $display("Starting Testbench: Hex to 7-Segment Decoder");
        $display("--------------------------------------------------");

        // Exhaustive testing of all 16 states (0 to F)
        for (int i = 0; i < 16; i++) begin
            hex_in = i[3:0];
            #1; // Delay for combinatorial logic to propagate

            expected_segments = get_expected(hex_in);
            checks++;

            if (segments !== expected_segments) begin
                errors++;
                $display("FAIL [Hex %h]: got segments=%b (%p), expected=%b", 
                         hex_in, segments, segments, expected_segments);
            end else begin
                $display("PASS [Hex %h]: Decoded perfectly -> %b", hex_in, segments);
            end
            #4;
        end

        $display("--------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: All %0d characters decoded successfully! 🎉", checks);
        end else begin
            $display("FAILED: %0d error(s) out of %0d checks. ❌", errors, checks);
        end
        $display("--------------------------------------------------");

        $finish;
    end

endmodule
