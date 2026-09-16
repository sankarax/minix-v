module muxN #(
    parameter N     = 4,
    parameter WIDTH = 32
)
(
    input  logic [N-1:0][WIDTH-1:0] d_i,
    input  logic [$clog2(N)-1:0]     sel_i,
    output logic [WIDTH-1:0]         y_o
);

    timeunit 1ns;
    timeprecision 100ps;

    always_comb begin
        if (sel_i < N)
            y_o = d_i[sel_i];
        else
            y_o = '0;
    end

endmodule : muxN
