module top_minixv_mc #(
    parameter integer DWIDTH = 32,
    parameter integer MEM_AW = 10,
    parameter integer AWIDTH = 12
)
(
    input  logic clk_i,
    input  logic rst_n_i,
    output logic tx_o
);

    timeunit 1ns;
    timeprecision 100ps;

    logic [AWIDTH-1:0] imem_addr;
    logic [DWIDTH-1:0] imem_rdata;
    logic              imem_wen;

    logic [AWIDTH-1:0] dmem_addr;
    logic [DWIDTH-1:0] dmem_wdata;
    logic [DWIDTH-1:0] dmem_rdata;
    logic              dmem_wen;

    logic sel_dmem;
    logic sel_uart;

    logic [DWIDTH-1:0] dmem_ram_rdata;

    // peripheral bus between the cpu side and uart
    obi_if #(
        .ADDR_WIDTH(AWIDTH),
        .DATA_WIDTH(DWIDTH)
    ) bus (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i)
    );

    minixv_mc #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) minixv_mc_inst (
        .clk_i        (clk_i),
        .rst_n_i      (rst_n_i),

        .imem_rdata_i (imem_rdata),
        .dmem_rdata_i (dmem_rdata),

        .imem_addr_o  (imem_addr),
        .imem_wen_o   (imem_wen),

        .dmem_addr_o  (dmem_addr),
        .dmem_wdata_o (dmem_wdata),
        .dmem_wen_o   (dmem_wen)
    );

    addr_decoder addr_decoder_inst (
        .addr     (dmem_addr),
        .sel_dmem (sel_dmem),
        .sel_uart (sel_uart)
    );

    memory #(
        .DWIDTH(DWIDTH),
        .AWIDTH(MEM_AW)
    ) imem (
        .clk_i   (clk_i),
        .addr_i  (imem_addr[MEM_AW-1:0]),
        .data_i  ('0),
        .wr_en_i (1'b0),
        .sel_i   (1'b1),
        .data_o  (imem_rdata)
    );

    memory #(
        .DWIDTH(DWIDTH),
        .AWIDTH(MEM_AW)
    ) dmem (
        .clk_i   (clk_i),
        .addr_i  (dmem_addr[MEM_AW-1:0]),
        .data_i  (dmem_wdata),
        .wr_en_i (dmem_wen),
        .sel_i   (sel_dmem),
        .data_o  (dmem_ram_rdata)
    );

    pbus_ctrl #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) pbus_ctrl_inst (
        .dmem_addr_i  (dmem_addr),
        .dmem_wdata_i (dmem_wdata),
        .dmem_we_i    (dmem_wen),
        .sel_uart_i   (sel_uart),
        .pbus         (bus)
    );

    uart_tx_obi #(
        .WIDTH     (8),
        .DEPTH     (64),
        .CLK_FREQ  (100_000_000),
        .BAUD_RATE (115200)
    ) uart_inst (
        .bus   (bus),
        .sel_i (sel_uart),
        .tx_o  (tx_o)
    );

    always_comb begin

        if (sel_dmem)
            dmem_rdata = dmem_ram_rdata;

        else if (sel_uart)
            dmem_rdata = bus.rdata;

        else
            dmem_rdata = '0;

    end

endmodule : top_minixv_mc
