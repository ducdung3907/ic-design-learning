module tb_gray_converters();

    localparam WIDTH = 4;

    logic [WIDTH-1:0] bin_in;
    logic [WIDTH-1:0] gray_out;
    logic [WIDTH-1:0] bin_out;
    
    // For verifying the 1-bit change property
    logic [WIDTH-1:0] prev_gray; 
    logic [WIDTH-1:0] changed_bits;

    // Instantiate DUT 1
    bin2gray #(.WIDTH(WIDTH)) u_b2g (
        .bin(bin_in),
        .gray(gray_out)
    );

    // Instantiate DUT 2
    gray2bin #(.WIDTH(WIDTH)) u_g2b (
        .gray(gray_out),
        .bin(bin_out)
    );

    initial begin
        $display("Starting Gray Code Conversion Tests...");
        $display("---------------------------------------------------");
        $display(" BIN_IN  |  GRAY_OUT | BIN_OUT | 1-BIT CHANGE OK?");
        $display("---------------------------------------------------");

        // Loop through all possible values
        for (int i = 0; i < (1<<WIDTH); i++) begin
            bin_in = i;
            #1; // Wait 1 time unit for combinational logic to propagate

            // Verify Round Trip (Bin -> Gray -> Bin)
            assert(bin_in == bin_out) else 
                $fatal("Error: %b -> %b -> %b (Mismatch!)", bin_in, gray_out, bin_out);

            // Verify 1-bit transition property (except for the very first number)
            if (i > 0) begin
                changed_bits = gray_out ^ prev_gray;
                // $onehot checks if exactly one bit is '1' in the vector
                assert($onehot(changed_bits)) else 
                    $fatal("Error: Gray code changed by more than 1 bit!");
            end

            $display("  %b   |    %b   |   %b  |       YES", bin_in, gray_out, bin_out);
            
            prev_gray = gray_out;
        end
        
        $display("---------------------------------------------------");
        $display("All tests passed successfully!");
        $finish;
    end

endmodule
