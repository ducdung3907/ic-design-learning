module seq_detector_1011 (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detected
);

    typedef enum logic [2:0] {
        S_RESET,
        S_1,
        S_10,
        S_101,
        S_1011
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S_RESET;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        // Defaults to avoid latches
        next_state = current_state;
        detected   = 1'b0;

        case (current_state)
            S_RESET: begin
                if (din) begin
                    next_state = S_1;
                end else begin
                    next_state = S_RESET;
                end
                detected = 1'b0; 
            end

            S_1: begin
                if (!din) begin
                    next_state = S_10;
                end else begin
                    next_state = S_1;
                end
                detected = 1'b0; 
            end

            S_10: begin
                if (din) begin
                    next_state = S_101;
                end else begin
                    next_state = S_RESET;
                end
                detected = 1'b0; 
            end

            S_101: begin
                if (din) begin
                    next_state = S_1011;
                end else begin
                    next_state = S_10;
                end
                detected = 1'b0; 
            end

            S_1011: begin
                if (din) begin
                    next_state = S_1;
                end else begin
                    next_state = S_10;
                end
                detected = 1'b1;
            end

            default: next_state = S_RESET;
        endcase
    end

endmodule
