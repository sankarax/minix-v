module uart_tx #(
    parameter integer CLK_FREQ  = 100_000_000,
    parameter integer BAUD_RATE = 115200,
    parameter integer DW        = 8
)
(
    input  logic          clk_i,
    input  logic          rst_n_i,
    input  logic          tx_start,
    input  logic [DW-1:0] tx_data,

    output logic           tx_busy,
    output logic           tx
);

    timeunit 1ns;
    timeprecision 1ps;

    typedef enum logic [3:0] {
        IDLE  = 4'b0001,
        START = 4'b0010,
        DATA  = 4'b0100,
        STOP  = 4'b1000
    } state_t;

    state_t current_state;
    state_t next_state;

    localparam integer BAUD_COUNT = CLK_FREQ / BAUD_RATE;

    logic [$clog2(BAUD_COUNT)-1:0] baud_counter;
    logic                          baud_tick;

    logic [$clog2(DW)-1:0] bit_count;

    logic [DW-1:0] tx_shift_reg;

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin
            baud_counter <= '0;
        end
        else begin

            if (current_state == IDLE) begin
                baud_counter <= '0;
            end
            else if (baud_counter == BAUD_COUNT - 1) begin
                baud_counter <= '0;
            end
            else begin
                baud_counter <= baud_counter + 1'b1;
            end

        end

    end

    assign baud_tick = (baud_counter == BAUD_COUNT - 1);

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin
            bit_count <= '0;
        end
        else begin

            if (current_state == IDLE) begin
                bit_count <= '0;
            end
            else if ((current_state == DATA) && baud_tick) begin

                if (bit_count == DW - 1)
                    bit_count <= '0;
                else
                    bit_count <= bit_count + 1'b1;

            end

        end

    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin

        if (!rst_n_i) begin
            tx_shift_reg <= '1;
        end
        else begin

            if ((current_state == IDLE) && tx_start) begin
                tx_shift_reg <= tx_data;
            end
            else if ((current_state == DATA) && baud_tick) begin
                tx_shift_reg <= {1'b1, tx_shift_reg[DW-1:1]};
            end

        end

    end

    always_comb begin

        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (tx_start)
                    next_state = START;
            end

            START: begin
                if (baud_tick)
                    next_state = DATA;
            end

            DATA: begin
                if (baud_tick && (bit_count == DW - 1))
                    next_state = STOP;
            end

            STOP: begin
                if (baud_tick)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

        endcase

    end

    always_comb begin

        tx = 1'b1;

        case (current_state)

            IDLE: begin
                tx = 1'b1;
            end

            START: begin
                tx = 1'b0;
            end

            DATA: begin
                tx = tx_shift_reg[0];
            end

            STOP: begin
                tx = 1'b1;
            end

            default: begin
                tx = 1'b1;
            end

        endcase

    end

    always_comb begin

        if (current_state == IDLE)
            tx_busy = 1'b0;
        else
            tx_busy = 1'b1;

    end

endmodule : uart_tx
