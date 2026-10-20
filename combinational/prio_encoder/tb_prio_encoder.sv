`timescale 1ns/1ps

module tb_priority_encoder;

    logic [3:0] req;
    logic [1:0] enc_out;
    logic       valid;

    priority_encoder dut (
        .req(req),
        .enc_out(enc_out),
        .valid(valid)
    );

    int checks = 0;
    int errors = 0;

    logic [1:0] expected_enc;
    logic       expected_valid;

    task automatic get_expected(input logic [3:0] r, output logic [1:0] e_enc, output logic e_val);
        if (r[3]) begin
            e_enc = 2'd3;
            e_val = 1'b1;
        end else if (r[2]) begin
            e_enc = 2'd2;
            e_val = 1'b1;
        end else if (r[1]) begin
            e_enc = 2'd1;
            e_val = 1'b1;
        end else if (r[0]) begin
            e_enc = 2'd0;
            e_val = 1'b1;
        end else begin
            e_enc = 2'd0;
            e_val = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("priority.vcd");
        $dumpvars(0, tb_priority_encoder);

        $display("---------------------------------------------------------");
        $display("Starting Testbench: 4-Bit Priority Encoder");
        $display("---------------------------------------------------------");
        $display(" req  | got: valid enc_out | exp: valid enc_out | status");
        $display("------|--------------------+--------------------+--------");

        for (int i = 0; i < 16; i++) begin
            req = i[3:0];
            #1;

            get_expected(req, expected_enc, expected_valid);
            checks++;

            if ((valid !== expected_valid) || (expected_valid && (enc_out !== expected_enc))) begin
                errors++;
                $display(" %4b |  %b     %b      |  %b     %b      | FAIL ❌", 
                         req, valid, enc_out, expected_valid, expected_enc);
            end else begin
                $display(" %4b |  %b     %b      |  %b     %b      | PASS ", 
                         req, valid, enc_out, expected_valid, expected_enc);
            end
            #4;
        end

        $display("---------------------------------------------------------");
        if (errors == 0) begin
            $display("SUCCESS: All %0d priority tests passed successfully! 🏆", checks);
        end else begin
            $display("FAILED: %0d error(s) out of %0d checks. ❌", errors, checks);
        end
        $display("---------------------------------------------------------");

        $finish;
    end

endmodule
