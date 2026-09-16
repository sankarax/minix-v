module uart_tx_obi #(
    parameter integer WIDTH     = 8,
    parameter integer DEPTH     = 32,
    parameter integer CLK_FREQ  = 100_000_000,
    parameter integer BAUD_RATE = 115200
)
(
    obi_if.slave bus,

    input  logic sel_i,
    output logic tx_o
);

    timeunit 1ns;
    timeprecision 1ps;

    // uart data register offset
    localparam logic [3:0] UART_TX_DATA = 4'h0;

    logic full;
    logic empty;

    logic wr_en;
    logic rd_en;

    logic [WIDTH-1:0] rdata;

    logic tx_start;
    logic tx_busy;

    assign bus.gnt = bus.req && sel_i;

    always_comb begin

        wr_en = 1'b0;

        if (bus.req &&
            sel_i   &&
            bus.we  &&
            (bus.addr[3:0] == UART_TX_DATA)) begin

            wr_en = !full;

        end

    end

    always_ff @(posedge bus.clk_i or negedge bus.rst_n_i) begin

        if (!bus.rst_n_i) begin
            bus.rvalid <= 1'b0;
            bus.rdata  <= 32'b0;
        end
        else begin

            bus.rvalid <= 1'b0;

            if (bus.req && !bus.we && sel_i) begin

                bus.rvalid <= 1'b1;

                case (bus.addr[3:0])

                    UART_TX_DATA:
                        bus.rdata <= {
                            30'b0,
                            full,
                            empty
                        };

                    default:
                        bus.rdata <= 32'b0;

                endcase

            end

        end

    end

    fifo #(
        .WIDTH (WIDTH),
        .DEPTH (DEPTH)
    ) u_tx_fifo (
        .clk_i   (bus.clk_i),
        .rst_n_i (bus.rst_n_i),

        .wdata_i (bus.wdata[WIDTH-1:0]),
        .wr_en_i (wr_en),
        .rd_en_i (rd_en),

        .rdata_o (rdata),
        .full_o  (full),
        .empty_o (empty)
    );

    uart_tx_controller u_uart_tx_controller (
        .clk_i        (bus.clk_i),
        .rst_n_i      (bus.rst_n_i),

        .fifo_empty_i (empty),
        .tx_busy_i    (tx_busy),

        .fifo_rd_en_o (rd_en),
        .tx_start_o   (tx_start)
    );

    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .DW        (WIDTH)
    ) u_uart_tx (
        .clk_i    (bus.clk_i),
        .rst_n_i  (bus.rst_n_i),

        .tx_start (tx_start),
        .tx_data  (rdata),

        .tx_busy  (tx_busy),
        .tx       (tx_o)
    );

endmodule : uart_tx_obi
