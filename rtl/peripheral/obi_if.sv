interface obi_if #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32
)
(
    input logic clk_i,
    input logic rst_n_i
);

    timeunit 1ns;
    timeprecision 1ps;

    logic                  req;
    logic                  gnt;

    logic [ADDR_WIDTH-1:0] addr;

    logic                  we;

    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH/8-1:0] be;

    logic                  rvalid;
    logic [DATA_WIDTH-1:0] rdata;

    modport master (
        input  clk_i,
        input  rst_n_i,

        output req,
        output addr,
        output we,
        output wdata,
        output be,

        input  gnt,
        input  rvalid,
        input  rdata
    );

    modport slave (
        input  clk_i,
        input  rst_n_i,

        input  req,
        input  addr,
        input  we,
        input  wdata,
        input  be,

        output gnt,
        output rvalid,
        output rdata
    );

endinterface : obi_if
