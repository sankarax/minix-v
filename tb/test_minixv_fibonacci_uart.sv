module test_minixv_fibonacci_uart;

    timeunit 1ns;
    timeprecision 100ps;

    localparam integer DWIDTH = 32;
    localparam integer MEM_AW = 10;
    localparam integer AWIDTH = 12;

    localparam integer CLK_FREQ  = 100_000_000;
    localparam integer BAUD_RATE = 115200;

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    logic clk;
    logic rst_n;
    logic tx;

    integer errors;
    integer uart_count;

    logic [7:0] received_byte;
    logic [7:0] expected_fib [0:39];

    top_minixv_mc #(
        .DWIDTH(DWIDTH),
        .MEM_AW(MEM_AW),
        .AWIDTH(AWIDTH)
    ) dut (
        .clk_i   (clk),
        .rst_n_i (rst_n),
        .tx_o    (tx)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // sample one uart frame in the middle of each bit
    task automatic uart_receive_byte(
        output logic [7:0] data
    );

        integer bit_index;

        begin

            data = 8'h00;

            @(negedge tx);

            repeat (CLKS_PER_BIT / 2)
                @(posedge clk);

            if (tx !== 1'b0) begin
                $display("FAIL: Invalid UART start bit");
                errors = errors + 1;
            end

            repeat (CLKS_PER_BIT)
                @(posedge clk);

            for (bit_index = 0;
                 bit_index < 8;
                 bit_index = bit_index + 1) begin

                data[bit_index] = tx;

                repeat (CLKS_PER_BIT)
                    @(posedge clk);

            end

            if (tx !== 1'b1) begin
                $display("FAIL: Invalid UART stop bit");
                errors = errors + 1;
            end

        end

    endtask

    initial begin

        errors     = 0;
        uart_count = 0;
        rst_n      = 1'b0;

        expected_fib[0]  = 8'd1;
        expected_fib[1]  = 8'd1;
        expected_fib[2]  = 8'd2;
        expected_fib[3]  = 8'd3;
        expected_fib[4]  = 8'd5;
        expected_fib[5]  = 8'd8;
        expected_fib[6]  = 8'd13;
        expected_fib[7]  = 8'd21;
        expected_fib[8]  = 8'd34;
        expected_fib[9]  = 8'd55;
        expected_fib[10] = 8'd89;
        expected_fib[11] = 8'd144;
        expected_fib[12] = 8'd233;
        expected_fib[13] = 8'd121;
        expected_fib[14] = 8'd98;
        expected_fib[15] = 8'd219;
        expected_fib[16] = 8'd61;
        expected_fib[17] = 8'd24;
        expected_fib[18] = 8'd85;
        expected_fib[19] = 8'd109;
        expected_fib[20] = 8'd194;
        expected_fib[21] = 8'd47;
        expected_fib[22] = 8'd241;
        expected_fib[23] = 8'd32;
        expected_fib[24] = 8'd17;
        expected_fib[25] = 8'd49;
        expected_fib[26] = 8'd66;
        expected_fib[27] = 8'd115;
        expected_fib[28] = 8'd181;
        expected_fib[29] = 8'd40;
        expected_fib[30] = 8'd221;
        expected_fib[31] = 8'd5;
        expected_fib[32] = 8'd226;
        expected_fib[33] = 8'd231;
        expected_fib[34] = 8'd201;
        expected_fib[35] = 8'd176;
        expected_fib[36] = 8'd121;
        expected_fib[37] = 8'd41;
        expected_fib[38] = 8'd162;
        expected_fib[39] = 8'd203;

        dut.imem.mem[0]  = 32'h3fc00113;
        dut.imem.mem[1]  = 32'hfd010113;
        dut.imem.mem[2]  = 32'h02812623;
        dut.imem.mem[3]  = 32'h03010413;
        dut.imem.mem[4]  = 32'h40000793;
        dut.imem.mem[5]  = 32'hfef42023;
        dut.imem.mem[6]  = 32'h02800793;
        dut.imem.mem[7]  = 32'hfcf42e23;
        dut.imem.mem[8]  = 32'hfe042623;
        dut.imem.mem[9]  = 32'h00100793;
        dut.imem.mem[10] = 32'hfef42423;
        dut.imem.mem[11] = 32'hfe042223;
        dut.imem.mem[12] = 32'h03c0006f;
        dut.imem.mem[13] = 32'hfec42703;
        dut.imem.mem[14] = 32'hfe842783;
        dut.imem.mem[15] = 32'h00f707b3;
        dut.imem.mem[16] = 32'hfcf42c23;
        dut.imem.mem[17] = 32'hfe842783;
        dut.imem.mem[18] = 32'hfef42623;
        dut.imem.mem[19] = 32'hfd842783;
        dut.imem.mem[20] = 32'hfef42423;
        dut.imem.mem[21] = 32'hfec42703;
        dut.imem.mem[22] = 32'hfe042783;
        dut.imem.mem[23] = 32'h00e7a023;
        dut.imem.mem[24] = 32'hfe442783;
        dut.imem.mem[25] = 32'h00178793;
        dut.imem.mem[26] = 32'hfef42223;
        dut.imem.mem[27] = 32'hfe442703;
        dut.imem.mem[28] = 32'hfdc42783;
        dut.imem.mem[29] = 32'hfcf740e3;
        dut.imem.mem[30] = 32'h0000006f;

        repeat (5)
            @(posedge clk);

        rst_n = 1'b1;

        $display("");
        $display("==============================================");
        $display("      MINI-XV FIBONACCI UART TEST");
        $display("==============================================");
        $display("");
        $display("Running compiled C program...");
        $display("Waiting for UART transmissions...");
        $display("");

        for (uart_count = 0;
             uart_count < 40;
             uart_count = uart_count + 1) begin

            uart_receive_byte(received_byte);

            if (received_byte === expected_fib[uart_count]) begin

                $display(
                    "PASS UART[%0d]: received %0d (0x%02h)",
                    uart_count,
                    received_byte,
                    received_byte
                );

            end
            else begin

                $display(
                    "FAIL UART[%0d]: received %0d (0x%02h), expected %0d (0x%02h)",
                    uart_count,
                    received_byte,
                    received_byte,
                    expected_fib[uart_count],
                    expected_fib[uart_count]
                );

                errors = errors + 1;

            end

        end

        $display("");
        $display("--- FINAL CPU CHECKS ---");

        if (dut.dmem.mem[250] === 32'd102334155) begin

            $display(
                "PASS: dmem[250] = %0d",
                dut.dmem.mem[250]
            );

        end
        else begin

            $display(
                "FAIL: dmem[250] = %0d, expected 102334155",
                dut.dmem.mem[250]
            );

            errors = errors + 1;

        end

        if (dut.dmem.mem[248] === 32'd40) begin

            $display(
                "PASS: Loop counter = %0d",
                dut.dmem.mem[248]
            );

        end
        else begin

            $display(
                "FAIL: Loop counter = %0d, expected 40",
                dut.dmem.mem[248]
            );

            errors = errors + 1;

        end

        if (dut.minixv_mc_inst.dp.rf.regs[2] === 32'd972) begin

            $display(
                "PASS: Stack pointer x2 = %0d",
                dut.minixv_mc_inst.dp.rf.regs[2]
            );

        end
        else begin

            $display(
                "FAIL: Stack pointer x2 = %0d, expected 972",
                dut.minixv_mc_inst.dp.rf.regs[2]
            );

            errors = errors + 1;

        end

        $display("");
        $display("----------------------------------------------");

        if (errors == 0) begin

            $display("");
            $display("ALL MINI-XV UART TESTS PASSED!");
            $display("");
            $display("40 Fibonacci values transmitted over UART.");
            $display("Compiled C -> MINI-XV -> OBI -> FIFO -> UART");
            $display("");

        end
        else begin

            $display("");
            $display(
                "MINI-XV UART TEST FAILED: %0d ERROR(S)",
                errors
            );
            $display("");

        end

        $display("==============================================");

        $finish;

    end

endmodule : test_minixv_fibonacci_uart
