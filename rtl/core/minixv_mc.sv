module minixv_mc
    import typedefs::*;
#(
    parameter integer DWIDTH = 32,
    parameter integer AWIDTH = 10
)
(
    input  logic              clk_i,
    input  logic              rst_n_i,

    input  logic [DWIDTH-1:0] imem_rdata_i,
    input  logic [DWIDTH-1:0] dmem_rdata_i,

    output logic [AWIDTH-1:0] imem_addr_o,
    output logic              imem_wen_o,

    output logic [AWIDTH-1:0] dmem_addr_o,
    output logic [DWIDTH-1:0] dmem_wdata_o,
    output logic              dmem_wen_o
);

    timeunit 1ns;
    timeprecision 100ps;

    logic              pc_ctrl;
    logic              pc_en_ctrl;
    logic              pc_jump_ctrl;

    logic [2:0]        imm_ctrl;
    logic              data2_alu_ctrl;
    alu_op_t           alu_ctrl;

    logic [1:0]        data_mux_ctrl;
    logic              rf_wen_ctrl;
    logic              fetch_en_ctrl;

    logic              alu_zero;
    logic              alu_less;

    logic              dmem_we_ctrl;

    logic [DWIDTH-1:0] instr_fetch;

    datapath_mc #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) dp (
        .clk_i             (clk_i),
        .rst_n_i           (rst_n_i),

        .imem_rdata_i      (imem_rdata_i),
        .dmem_rdata_i      (dmem_rdata_i),

        .pc_ctrl_i         (pc_ctrl),
        .pc_en_ctrl_i      (pc_en_ctrl),
        .pc_jump_ctrl_i    (pc_jump_ctrl),

        .imm_ctrl_i        (imm_ctrl),
        .data2_alu_ctrl_i  (data2_alu_ctrl),
        .alu_ctrl_i        (alu_ctrl),

        .data_mux_ctrl_i   (data_mux_ctrl),
        .rf_wen_ctrl_i     (rf_wen_ctrl),
        .fetch_en_ctrl_i   (fetch_en_ctrl),

        .imem_addr_o       (imem_addr_o),
        .dmem_addr_o       (dmem_addr_o),
        .dmem_wdata_o      (dmem_wdata_o),

        .alu_zero_ctrl_o   (alu_zero),
        .alu_less_ctrl_o   (alu_less),

        .instr_fetch_o     (instr_fetch)
    );

    controller_mc ctrl (
        .clk_i              (clk_i),
        .rst_n_i            (rst_n_i),

        .opcode_i           (instr_fetch[6:0]),
        .funct3_i           (instr_fetch[14:12]),
        .funct7_i           (instr_fetch[31:25]),

        .alu_zero_i         (alu_zero),
        .alu_less_i         (alu_less),

        .pc_ctrl_o          (pc_ctrl),
        .pc_jump_ctrl_o     (pc_jump_ctrl),
        .pc_en_ctrl_o       (pc_en_ctrl),

        .imm_ctrl_o         (imm_ctrl),
        .data2_alu_ctrl_o   (data2_alu_ctrl),
        .alu_ctrl_o         (alu_ctrl),

        .data_mux_ctrl_o    (data_mux_ctrl),
        .rf_wen_ctrl_o      (rf_wen_ctrl),

        .dmem_we_ctrl_o     (dmem_we_ctrl),
        .fetch_en_ctrl_o    (fetch_en_ctrl)
    );

    assign imem_wen_o = 1'b0;

    assign dmem_wen_o = dmem_we_ctrl;

endmodule : minixv_mc
