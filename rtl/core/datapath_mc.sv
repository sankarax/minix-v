module datapath_mc
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

    input  logic              pc_ctrl_i,
    input  logic              pc_en_ctrl_i,
    input  logic              pc_jump_ctrl_i,

    input  logic [2:0]        imm_ctrl_i,
    input  logic              data2_alu_ctrl_i,
    input  alu_op_t           alu_ctrl_i,

    input  logic [1:0]        data_mux_ctrl_i,
    input  logic              rf_wen_ctrl_i,
    input  logic              fetch_en_ctrl_i,

    output logic [AWIDTH-1:0] imem_addr_o,
    output logic [AWIDTH-1:0] dmem_addr_o,
    output logic [DWIDTH-1:0] dmem_wdata_o,

    output logic              alu_zero_ctrl_o,
    output logic              alu_less_ctrl_o,

    output logic [DWIDTH-1:0] instr_fetch_o
);

    timeunit 1ns;
    timeprecision 100ps;

    // program counter and fetch registers
    logic [DWIDTH-1:0] pc;
    logic [DWIDTH-1:0] pc_next;
    logic [DWIDTH-1:0] pc4;

    logic [DWIDTH-1:0] pc_jump;
    logic [DWIDTH-1:0] pc_jalr;

    logic [DWIDTH-1:0] pc_fetch;
    logic [DWIDTH-1:0] pc4_fetch;
    logic [DWIDTH-1:0] pc_jump_execute;

    logic [DWIDTH-1:0] imm_ext;

    logic [DWIDTH-1:0] alu_result;
    logic [DWIDTH-1:0] alu_result_execute;

    logic [DWIDTH-1:0] data1;
    logic [DWIDTH-1:0] data2;

    logic [DWIDTH-1:0] rf_rd_data2;
    logic [DWIDTH-1:0] rf_wdata;

    logic [DWIDTH-1:0] data1_decode;
    logic [DWIDTH-1:0] rf_rd_data2_decode;

    logic [DWIDTH-1:0] instr;
    logic [DWIDTH-1:0] instr_fetch;

    logic [DWIDTH-1:0] dmem_rdata_memory;

    logic [1:0][DWIDTH-1:0] pc_next_mux_data;

    assign pc_next_mux_data[0] = pc4;
    assign pc_next_mux_data[1] = pc_jump;

    muxN #(
        .N     (2),
        .WIDTH (DWIDTH)
    ) pc_next_mux (
        .d_i   (pc_next_mux_data),
        .sel_i (pc_ctrl_i),
        .y_o   (pc_next)
    );

    fflopLD #(
        .WIDTH(DWIDTH)
    ) pc_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (pc_next),
        .en_i    (pc_en_ctrl_i),
        .q_o     (pc)
    );

    assign imem_addr_o = pc[AWIDTH-1:0];

    assign instr = imem_rdata_i;

    adder #(
        .WIDTH(DWIDTH)
    ) pc_adder4 (
        .a_i      (pc),
        .b_i      (DWIDTH'(4)),
        .result_o (pc4)
    );

    fflopLD #(
        .WIDTH(DWIDTH)
    ) fetch_instr_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (instr),
        .en_i    (fetch_en_ctrl_i),
        .q_o     (instr_fetch)
    );

    fflopLD #(
        .WIDTH(DWIDTH)
    ) fetch_pc_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (pc),
        .en_i    (fetch_en_ctrl_i),
        .q_o     (pc_fetch)
    );

    fflopLD #(
        .WIDTH(DWIDTH)
    ) fetch_pc4_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (pc4),
        .en_i    (fetch_en_ctrl_i),
        .q_o     (pc4_fetch)
    );

    assign instr_fetch_o = instr_fetch;

    regfile rf (
        .clk_i    (clk_i),
        .rst_n_i  (rst_n_i),

        .raddr1_i (instr_fetch[19:15]),
        .raddr2_i (instr_fetch[24:20]),

        .waddr_i  (instr_fetch[11:7]),
        .wdata_i  (rf_wdata),
        .wen_i    (rf_wen_ctrl_i),

        .rdata1_o (data1),
        .rdata2_o (rf_rd_data2)
    );

    extend imm_extender (
        .imm_ctrl_i (imm_ctrl_i),
        .instr_i    (instr_fetch),
        .imm_o      (imm_ext)
    );

    fflop #(
        .WIDTH(DWIDTH)
    ) decode_data1_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (data1),
        .q_o     (data1_decode)
    );

    fflop #(
        .WIDTH(DWIDTH)
    ) decode_data2_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (rf_rd_data2),
        .q_o     (rf_rd_data2_decode)
    );

    logic [1:0][DWIDTH-1:0] alu_mux_data;

    assign alu_mux_data[0] = rf_rd_data2_decode;
    assign alu_mux_data[1] = imm_ext;

    muxN #(
        .N     (2),
        .WIDTH (DWIDTH)
    ) alu_mux (
        .d_i   (alu_mux_data),
        .sel_i (data2_alu_ctrl_i),
        .y_o   (data2)
    );

    alu #(
        .WIDTH(DWIDTH)
    ) alu_inst (
        .a_i      (data1_decode),
        .b_i      (data2),
        .alu_op_i (alu_ctrl_i),

        .result_o (alu_result),
        .zero_o   (alu_zero_ctrl_o),
        .less_o   (alu_less_ctrl_o)
    );

    fflop #(
        .WIDTH(DWIDTH)
    ) execute_alu_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (alu_result),
        .q_o     (alu_result_execute)
    );

    adder #(
        .WIDTH(DWIDTH)
    ) pc_adder_jump (
        .a_i      (pc_fetch),
        .b_i      (imm_ext),
        .result_o (pc_jump_execute)
    );

    adder #(
        .WIDTH(DWIDTH)
    ) pc_adder_jalr (
        .a_i      (data1_decode),
        .b_i      (imm_ext),
        .result_o (pc_jalr)
    );

    assign dmem_addr_o = alu_result_execute[AWIDTH-1:0];

    assign dmem_wdata_o = rf_rd_data2_decode;

    fflop #(
        .WIDTH(DWIDTH)
    ) memory_data_ff (
        .clk_i   (clk_i),
        .rst_n_i (rst_n_i),
        .d_i     (dmem_rdata_i),
        .q_o     (dmem_rdata_memory)
    );

    logic [1:0][DWIDTH-1:0] pc_jump_mux_data;

    assign pc_jump_mux_data[0] = pc_jalr;
    assign pc_jump_mux_data[1] = pc_jump_execute;

    muxN #(
        .N     (2),
        .WIDTH (DWIDTH)
    ) pc_jump_mux (
        .d_i   (pc_jump_mux_data),
        .sel_i (pc_jump_ctrl_i),
        .y_o   (pc_jump)
    );

    logic [3:0][DWIDTH-1:0] rf_wdata_mux_data;

    assign rf_wdata_mux_data[0] = pc4_fetch;
    assign rf_wdata_mux_data[1] = dmem_rdata_memory;
    assign rf_wdata_mux_data[2] = alu_result_execute;
    assign rf_wdata_mux_data[3] = '0;

    muxN #(
        .N     (4),
        .WIDTH (DWIDTH)
    ) rf_wdata_mux (
        .d_i   (rf_wdata_mux_data),
        .sel_i (data_mux_ctrl_i),
        .y_o   (rf_wdata)
    );
endmodule : datapath_mc
