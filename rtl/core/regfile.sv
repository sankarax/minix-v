module regfile (
    input  logic        clk_i,
    input  logic        rst_n_i,

    input  logic [4:0]  raddr1_i,
    input  logic [4:0]  raddr2_i,

    input  logic [4:0]  waddr_i,
    input  logic [31:0] wdata_i,
    input  logic        wen_i,

    output logic [31:0] rdata1_o,
    output logic [31:0] rdata2_o
);

    timeunit 1ns;
    timeprecision 100ps;

    // integer register file
    logic [31:0] regs [0:31];

    integer i;

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin

            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;

        end
        else begin

            // x0 stays hardwired to zero
            if (wen_i && (waddr_i != 5'd0))
                regs[waddr_i] <= wdata_i;

        end

    end

    assign rdata1_o =
        (raddr1_i == 5'd0) ? 32'b0 : regs[raddr1_i];

    assign rdata2_o =
        (raddr2_i == 5'd0) ? 32'b0 : regs[raddr2_i];

endmodule : regfile
