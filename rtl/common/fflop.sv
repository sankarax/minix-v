module fflop #(
    parameter WIDTH = 32
)
(
    input  logic             clk_i,
    input  logic             rst_n_i,
    input  logic [WIDTH-1:0] d_i,
    output logic [WIDTH-1:0] q_o
);

    timeunit 1ns;
    timeprecision 100ps;

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i)
            q_o <= {WIDTH{1'b0}};
        else
            q_o <= d_i;

    end

endmodule : fflop
