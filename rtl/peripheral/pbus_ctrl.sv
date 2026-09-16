module pbus_ctrl #(
    parameter integer DWIDTH = 32,
    parameter integer AWIDTH = 12
)
(
    input logic [AWIDTH-1:0] dmem_addr_i,
    input logic [DWIDTH-1:0] dmem_wdata_i,
    input logic              dmem_we_i,
    input logic              sel_uart_i,

    obi_if.master            pbus
);

    timeunit 1ns;
    timeprecision 100ps;

    assign pbus.req = sel_uart_i;

    assign pbus.addr = dmem_addr_i;

    assign pbus.we = dmem_we_i;

    assign pbus.wdata = dmem_wdata_i;

    assign pbus.be = 4'b1111;

endmodule : pbus_ctrl
