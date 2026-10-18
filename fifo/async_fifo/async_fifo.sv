//dout have one cycle of read latency
module async_fifo #(
    parameter int unsigned WIDTH = 8,
    parameter int unsigned DEPTH = 8
) (
    input  logic             wclk,
    input  logic             rclk,
    input  logic             rst_n,

    input  logic             wr_en,
    input  logic [WIDTH-1:0] din,
    output logic             full,

    input  logic             rd_en,
    output logic [WIDTH-1:0] dout,
    output logic             empty
);
    localparam int PTR_W  = $clog2(DEPTH) + 1;

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    logic [PTR_W-1:0] wptr_bin,  wptr_gray;
    logic [PTR_W-1:0] rptr_bin,  rptr_gray;

    logic [PTR_W-1:0] wptr_bin_next,  wptr_gray_next;
    logic [PTR_W-1:0] rptr_bin_next,  rptr_gray_next;

    logic [PTR_W-1:0] rgray_wsync;
    logic [PTR_W-1:0] wgray_rsync;

    logic full_next;
    logic empty_next;

    initial begin
        if (DEPTH < 4 || (DEPTH & (DEPTH - 1)) != 0) begin
            $fatal(1, "DEPTH must be a power of two and >= 4");
        end
    end


    always_comb begin
        wptr_bin_next = wptr_bin;
        if (wr_en && !full) begin
            wptr_bin_next = wptr_bin + 1'b1;
        end
    end

    always_comb begin
        rptr_bin_next = rptr_bin;
        if (rd_en && !empty) begin
            rptr_bin_next = rptr_bin + 1'b1;
        end
    end

    bin2gray #(
        .WIDTH(PTR_W)
    ) b2gw (
        .bin(wptr_bin_next),
        .gray(wptr_gray_next)
    );

    bin2gray #(
        .WIDTH(PTR_W)
    ) b2gr (
        .bin(rptr_bin_next),
        .gray(rptr_gray_next)
    );

    synchronizer #(
        .WIDTH(PTR_W)
    )w2rsync(
        .clk(rclk),
        .rst_n(rst_n),
        .async_in(wptr_gray),
        .sync_out(wgray_rsync)
    );

    synchronizer #(
        .WIDTH(PTR_W)
    )r2wsync(
        .clk(wclk),
        .rst_n(rst_n),
        .async_in(rptr_gray),
        .sync_out(rgray_wsync)
    );



    always_comb begin// calc to know if next state is full yet
        full_next =(wptr_gray_next =={~rgray_wsync[PTR_W-1:PTR_W-2],rgray_wsync[PTR_W-3:0]});
    end


    always_comb begin
        empty_next = (rptr_gray_next == wgray_rsync);
    end

    always_ff @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr_bin  <= '0;
            wptr_gray <= '0;
            full      <= 1'b0;
        end else begin
            wptr_bin  <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
            full      <= full_next;

            if (wr_en && !full) begin
                mem[wptr_bin[PTR_W-2:0]] <= din;
            end
        end
    end

    always_ff @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr_bin  <= '0;
            rptr_gray <= '0;
            empty     <= 1'b1;
            dout      <= '0;
        end else begin
            rptr_bin  <= rptr_bin_next;
            rptr_gray <= rptr_gray_next;
            empty     <= empty_next;

            if (rd_en && !empty) begin
                dout <= mem[rptr_bin[PTR_W-2:0]];
            end
        end
    end
endmodule
