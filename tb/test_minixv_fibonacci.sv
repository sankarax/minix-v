module test_minixv_fibonacci;

    timeunit 1ns;
    timeprecision 100ps;

    localparam integer DWIDTH = 32;
    localparam integer MEM_AW = 10;
    localparam integer AWIDTH = 12;

    logic clk;
    logic rst_n;
    logic tx;

    integer errors;

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

    initial begin

        errors = 0;
        rst_n  = 1'b0;

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

        repeat (3)
            @(posedge clk);

        rst_n = 1'b1;

        $display("");
        $display("==============================================");
        $display("       MINI-XV FIBONACCI C PROGRAM TEST");
        $display("==============================================");
        $display("");
        $display("Starting compiled C program...");
        $display("");

        repeat (10000)
            @(posedge clk);

        $display("");
        $display("--- CPU STATE ---");

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

        if (dut.minixv_mc_inst.dp.rf.regs[8] === 32'd1020) begin

            $display(
                "PASS: Frame pointer x8 = %0d",
                dut.minixv_mc_inst.dp.rf.regs[8]
            );

        end
        else begin

            $display(
                "FAIL: Frame pointer x8 = %0d, expected 1020",
                dut.minixv_mc_inst.dp.rf.regs[8]
            );

            errors = errors + 1;

        end

        $display("");
        $display("--- FIBONACCI RESULT ---");

        if (dut.dmem.mem[250] === 32'd102334155) begin

            $display(
                "PASS: dmem[250] = %0d",
                dut.dmem.mem[250]
            );

            $display(
                "      Expected F(40) = 102334155"
            );

        end
        else begin

            $display(
                "FAIL: dmem[250] = %0d",
                dut.dmem.mem[250]
            );

            $display(
                "      Expected F(40) = 102334155"
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

        $display("");
        $display("----------------------------------------------");

        if (errors == 0) begin

            $display("");
            $display("ALL MINI-XV FIBONACCI TESTS PASSED!");
            $display("");
            $display("Compiled C executed successfully on MINI-XV!");
            $display("");

        end
        else begin

            $display("");
            $display(
                "MINI-XV FIBONACCI TEST FAILED: %0d ERROR(S)",
                errors
            );
            $display("");

        end

        $display("==============================================");

        $finish;

    end

endmodule : test_minixv_fibonacci
