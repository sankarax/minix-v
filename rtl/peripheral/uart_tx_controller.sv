module uart_tx_controller (
    input  logic clk_i,
    input  logic rst_n_i,

    input  logic fifo_empty_i,
    input  logic tx_busy_i,

    output logic fifo_rd_en_o,
    output logic tx_start_o
);

    timeunit 1ns;
    timeprecision 100ps;

    typedef enum logic [1:0] {
        IDLE,
        FIFO_RD,
        TX_START,
        WAIT
    } state_t;

    state_t current_state;
    state_t next_state;

    always_comb begin

        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (!fifo_empty_i && !tx_busy_i)
                    next_state = FIFO_RD;
            end

            FIFO_RD: begin
                next_state = TX_START;
            end

            TX_START: begin
                next_state = WAIT;
            end

            WAIT: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase

    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i)
            current_state <= IDLE;
        else
            current_state <= next_state;

    end

    always_comb begin

        fifo_rd_en_o = 1'b0;
        tx_start_o   = 1'b0;

        case (current_state)

            FIFO_RD: begin
                fifo_rd_en_o = 1'b1;
            end

            TX_START: begin
                tx_start_o = 1'b1;
            end

            default: begin
                fifo_rd_en_o = 1'b0;
                tx_start_o   = 1'b0;
            end

        endcase

    end

endmodule : uart_tx_controller
