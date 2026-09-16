module fifo #(
    parameter integer WIDTH = 32,
    parameter integer DEPTH = 16
)
(
    input  logic             clk_i,
    input  logic             rst_n_i,

    input  logic [WIDTH-1:0] wdata_i,
    input  logic             wr_en_i,
    input  logic             rd_en_i,

    output logic [WIDTH-1:0] rdata_o,
    output logic             full_o,
    output logic             empty_o
);

    timeunit 1ns;
    timeprecision 100ps;

    initial begin
        assert ((DEPTH > 0) && ((DEPTH & (DEPTH - 1)) == 0))
        else
            $error("FIFO DEPTH must be a power of 2");
    end

    localparam integer ADDR_WIDTH = $clog2(DEPTH);

    logic [ADDR_WIDTH-1:0] wptr;
    logic [ADDR_WIDTH-1:0] rptr;

    logic last_was_read;

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin
            wptr <= '0;
        end
        else begin

            if (wr_en_i && !full_o) begin
                mem[wptr] <= wdata_i;
                wptr <= wptr + 1'b1;
            end

        end

    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin
            rptr    <= '0;
            rdata_o <= '0;
        end
        else begin

            if (rd_en_i && !empty_o) begin
                rdata_o <= mem[rptr];
                rptr <= rptr + 1'b1;
            end

        end

    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin
            last_was_read <= 1'b1;
        end
        else begin

            if (rd_en_i && !empty_o)
                last_was_read <= 1'b1;
            else if (wr_en_i && !full_o)
                last_was_read <= 1'b0;

        end

    end

    always_comb begin

        full_o  = 1'b0;
        empty_o = 1'b0;

        if (wptr == rptr) begin

            if (last_was_read)
                empty_o = 1'b1;
            else
                full_o = 1'b1;

        end

    end

endmodule : fifo
