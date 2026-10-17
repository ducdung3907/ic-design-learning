`timescale 1ns/1ps

module traffic_light #(
    parameter int GREEN_TIME  = 5,   
    parameter int YELLOW_TIME = 2   
) (
    input  logic       clk,
    input  logic       rst_n,        
    output logic [2:0] ns,           
    output logic [2:0] ew            
);
    localparam logic [2:0] RED = 3'b100;
    localparam logic [2:0] YEL = 3'b010;
    localparam logic [2:0] GRN = 3'b001;

    typedef enum logic [1:0] {
        NS_GREEN,
        NS_YELLOW,
        EW_GREEN,
        EW_YELLOW
    } state_t;

    state_t state;

    localparam MAX_TIME = (GREEN_TIME > YELLOW_TIME) ? GREEN_TIME : YELLOW_TIME;
    logic [$clog2(MAX_TIME)-1:0] count;
   
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state = NS_GREEN;
            count <= '0;
        end else begin
            if ((state== NS_GREEN) || (state == EW_GREEN)) begin
                if (count == GREEN_TIME-1) begin
                    if (state == NS_GREEN) begin
                        state = NS_YELLOW;
                        count <= '0;
                    end else begin
                        state = EW_YELLOW;
                        count <= '0;
                    end
                end else begin
                    count <= count + 1'b1;
                end
            end else begin
                if (count == YELLOW_TIME-1) begin
                    if (state == NS_YELLOW) begin
                        state = EW_GREEN;
                        count <= '0;
                    end else begin
                        state = NS_GREEN;
                        count <= '0;
                    end
                end else begin
                    count <= count + 1'b1;
                end
            end
        end 
    end

    always_comb begin
        case (state) 
            NS_GREEN : begin ns = GRN; ew = RED; end
            NS_YELLOW: begin ns = YEL; ew = RED; end
            EW_GREEN : begin ns = RED; ew = GRN; end
            EW_YELLOW: begin ns = RED; ew = YEL; end
            default :  begin ns = GRN; ew = RED; end
        endcase
    end

endmodule