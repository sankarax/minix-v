module controller_mc
    import typedefs::*;
(
    input  logic       clk_i,
    input  logic       rst_n_i,

    input  logic [6:0] opcode_i,
    input  logic [2:0] funct3_i,
    input  logic [6:0] funct7_i,

    output logic        pc_ctrl_o,
    output logic        pc_jump_ctrl_o,
    output logic        pc_en_ctrl_o,

    output logic [2:0]  imm_ctrl_o,

    output logic        data2_alu_ctrl_o,
    output alu_op_t     alu_ctrl_o,

    output logic [1:0]  data_mux_ctrl_o,
    output logic        rf_wen_ctrl_o,

    input  logic        alu_zero_i,
    input  logic        alu_less_i,

    output logic        dmem_we_ctrl_o,
    output logic        fetch_en_ctrl_o
);

    timeunit 1ns;
    timeprecision 100ps;

    // branch condition from the alu flags
    logic cond;

    always_comb begin

        case (funct3_i)

            3'b000:
                cond = alu_zero_i;  // beq

            3'b001:
                cond = ~alu_zero_i;  // bne

            3'b100:
                cond = alu_less_i;  // blt

            3'b101:
                cond = ~alu_less_i;  // bge

            default:
                cond = 1'b0;

        endcase

    end

    alu_op_t alu_op;

    always_comb begin

        case (funct3_i)

            3'b000: begin

                if (opcode_i[5] == 1'b0)
                    alu_op = ALU_ADD;

                else if (funct7_i[5] == 1'b1)
                    alu_op = ALU_SUB;

                else
                    alu_op = ALU_ADD;

            end

            3'b001:
                alu_op = ALU_SLL;

            3'b010:
                alu_op = ALU_SLT;

            3'b100:
                alu_op = ALU_XOR;

            3'b101: begin

                if (funct7_i[5])
                    alu_op = ALU_SRA;
                else
                    alu_op = ALU_SRL;

            end

            3'b110:
                alu_op = ALU_OR;

            3'b111:
                alu_op = ALU_AND;

            default:
                alu_op = ALU_ADD;

        endcase

    end

    always_comb begin

        case (opcode_i)

            OPCODE_LOAD:
                imm_ctrl_o = 3'b000;

            OPCODE_STORE:
                imm_ctrl_o = 3'b001;

            OPCODE_R_TYPE:
                imm_ctrl_o = 3'b000;

            OPCODE_I_TYPE_ALU:
                imm_ctrl_o = 3'b000;

            OPCODE_JALR:
                imm_ctrl_o = 3'b000;

            OPCODE_JAL:
                imm_ctrl_o = 3'b100;

            OPCODE_BRANCH:
                imm_ctrl_o = 3'b010;

            default:
                imm_ctrl_o = 3'b000;

        endcase

    end

    // multicycle control states
    typedef enum logic [3:0] {

        FETCH    = 4'd0,
        DECODE   = 4'd1,

        MEMADDR  = 4'd2,
        MEMREAD  = 4'd3,
        MEMWRITE = 4'd4,
        REGWRITE = 4'd5,

        EXECUTER = 4'd6,
        EXECUTEI = 4'd7,

        JALR     = 4'd8,
        JWRITE   = 4'd9,
        JAL      = 4'd10,

        BEQ      = 4'd11,

        ALUWRITE = 4'd12

    } state_t;

    state_t current_state;
    state_t next_state;

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i)
            current_state <= FETCH;
        else
            current_state <= next_state;

    end

    always_comb begin

        next_state = FETCH;

        case (current_state)

            FETCH: begin

                next_state = DECODE;

            end

            DECODE: begin

                case (opcode_i)

                    OPCODE_LOAD:
                        next_state = MEMADDR;

                    OPCODE_STORE:
                        next_state = MEMADDR;

                    OPCODE_R_TYPE:
                        next_state = EXECUTER;

                    OPCODE_I_TYPE_ALU:
                        next_state = EXECUTEI;

                    OPCODE_JALR:
                        next_state = JALR;

                    OPCODE_JAL:
                        next_state = JAL;

                    OPCODE_BRANCH:
                        next_state = BEQ;

                    default:
                        next_state = FETCH;

                endcase

            end

            MEMADDR: begin

                if (opcode_i == OPCODE_LOAD)
                    next_state = MEMREAD;
                else
                    next_state = MEMWRITE;

            end

            MEMREAD: begin

                next_state = REGWRITE;

            end

            MEMWRITE: begin

                next_state = FETCH;

            end

            REGWRITE: begin

                next_state = FETCH;

            end

            EXECUTER: begin

                next_state = ALUWRITE;

            end

            EXECUTEI: begin

                next_state = ALUWRITE;

            end

            JALR: begin

                next_state = JWRITE;

            end

            JWRITE: begin

                next_state = FETCH;

            end

            JAL: begin

                next_state = JWRITE;

            end

            BEQ: begin

                next_state = FETCH;

            end

            ALUWRITE: begin

                next_state = FETCH;

            end

            default: begin

                next_state = FETCH;

            end

        endcase

    end

    always_comb begin

        pc_ctrl_o        = 1'b0;
        pc_jump_ctrl_o   = 1'b0;
        pc_en_ctrl_o     = 1'b0;

        data2_alu_ctrl_o = 1'b0;
        alu_ctrl_o       = ALU_ADD;

        data_mux_ctrl_o  = 2'b00;
        rf_wen_ctrl_o    = 1'b0;

        dmem_we_ctrl_o   = 1'b0;
        fetch_en_ctrl_o  = 1'b0;

        case (current_state)

            FETCH: begin

                fetch_en_ctrl_o = 1'b1;

            end

            DECODE: begin

                pc_en_ctrl_o = 1'b1;

            end

            MEMADDR: begin

                data2_alu_ctrl_o = 1'b1;
                alu_ctrl_o       = ALU_ADD;

            end

            MEMREAD: begin

                dmem_we_ctrl_o = 1'b0;

            end

            MEMWRITE: begin

                dmem_we_ctrl_o = 1'b1;

            end

            REGWRITE: begin

                data_mux_ctrl_o = 2'b01;

                rf_wen_ctrl_o = 1'b1;

            end

            EXECUTER: begin

                data2_alu_ctrl_o = 1'b0;

                alu_ctrl_o = alu_op;

            end

            EXECUTEI: begin

                data2_alu_ctrl_o = 1'b1;

                alu_ctrl_o = alu_op;

            end

            JALR: begin

                pc_ctrl_o = 1'b1;

                pc_jump_ctrl_o = 1'b0;

                pc_en_ctrl_o = 1'b1;

            end

            JWRITE: begin

                data_mux_ctrl_o = 2'b00;

                rf_wen_ctrl_o = 1'b1;

            end

            JAL: begin

                pc_ctrl_o = 1'b1;

                pc_jump_ctrl_o = 1'b1;

                pc_en_ctrl_o = 1'b1;

            end

            BEQ: begin

                data2_alu_ctrl_o = 1'b0;
                alu_ctrl_o       = ALU_SUB;

                pc_ctrl_o    = cond;
                pc_en_ctrl_o = cond;

                pc_jump_ctrl_o = 1'b1;

            end

            ALUWRITE: begin

                data_mux_ctrl_o = 2'b10;

                rf_wen_ctrl_o = 1'b1;

            end

            default: begin

            end

        endcase

    end

endmodule : controller_mc
