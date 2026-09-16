module memory #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 10
)
(
    input  logic              clk_i,
    input  logic [AWIDTH-1:0] addr_i,
    input  logic [DWIDTH-1:0] data_i,
    input  logic              wr_en_i,
    input  logic              sel_i,

    output logic [DWIDTH-1:0] data_o
);

    timeunit 1ns;
    timeprecision 100ps;

    localparam SIZE = 2**(AWIDTH-2);

    logic [DWIDTH-1:0] mem [0:SIZE-1];

    always_ff @(posedge clk_i) begin

        if (wr_en_i && sel_i)
            mem[addr_i[AWIDTH-1:2]] <= data_i;

    end

    assign data_o = mem[addr_i[AWIDTH-1:2]];

endmodule : memory
