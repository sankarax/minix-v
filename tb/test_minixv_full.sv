module test_minixv_full;

    timeunit 1ns;
    timeprecision 100ps;

    import typedefs::*;

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

    task automatic check_reg(
        input integer      reg_num,
        input logic [31:0] expected,
        input string       test_name
    );
        begin

            if (dut.minixv_mc_inst.dp.rf.regs[reg_num] === expected) begin

                $display(
                    "PASS: %-20s x%0d = %0d",
                    test_name,
                    reg_num,
                    $signed(dut.minixv_mc_inst.dp.rf.regs[reg_num])
                );

            end
            else begin

                $display(
                    "FAIL: %-20s x%0d = %0d, expected %0d",
                    test_name,
                    reg_num,
                    $signed(dut.minixv_mc_inst.dp.rf.regs[reg_num]),
                    $signed(expected)
                );

                errors = errors + 1;

            end

        end
    endtask

    task automatic check_mem(
        input integer      index,
        input logic [31:0] expected,
        input string       test_name
    );
        begin

            if (dut.dmem.mem[index] === expected) begin

                $display(
                    "PASS: %-20s DMEM[%0d] = %0d",
                    test_name,
                    index,
                    $signed(dut.dmem.mem[index])
                );

            end
            else begin

                $display(
                    "FAIL: %-20s DMEM[%0d] = %0d, expected %0d",
                    test_name,
                    index,
                    $signed(dut.dmem.mem[index]),
                    $signed(expected)
                );

                errors = errors + 1;

            end

        end
    endtask

    initial begin

        errors = 0;
        rst_n  = 1'b0;

        dut.imem.mem[0] = 32'h00A00093;

        dut.imem.mem[1] = 32'h00300113;

        dut.imem.mem[2] = 32'h002081B3;

        dut.imem.mem[3] = 32'h40208233;

        dut.imem.mem[4] = 32'h0020F2B3;

        dut.imem.mem[5] = 32'h0020E333;

        dut.imem.mem[6] = 32'h0020C3B3;

        dut.imem.mem[7] = 32'h00209433;

        dut.imem.mem[8] = 32'h001124B3;

        dut.imem.mem[9] = 32'h0020D533;

        dut.imem.mem[10] = 32'h0060F593;

        dut.imem.mem[11] = 32'h0010E613;

        dut.imem.mem[12] = 32'h0030C693;

        dut.imem.mem[13] = 32'h00512713;

        dut.imem.mem[14] = 32'h00211793;

        dut.imem.mem[15] = 32'h0010D813;

        dut.imem.mem[16] = 32'hFF000893;

        dut.imem.mem[17] = 32'h4028D913;

        dut.imem.mem[18] = 32'h00302023;

        dut.imem.mem[19] = 32'h00002983;

        dut.imem.mem[20] = 32'h01202223;

        dut.imem.mem[21] = 32'h00402A03;

        dut.imem.mem[22] = 32'h00108463;

        dut.imem.mem[23] = 32'h06300A93;

        dut.imem.mem[24] = 32'h00100B13;

        dut.imem.mem[25] = 32'h00209463;

        dut.imem.mem[26] = 32'h06300B93;

        dut.imem.mem[27] = 32'h00200C13;

        dut.imem.mem[28] = 32'h00114463;

        dut.imem.mem[29] = 32'h06300C93;

        dut.imem.mem[30] = 32'h00300D13;

        dut.imem.mem[31] = 32'h0020D463;

        dut.imem.mem[32] = 32'h06300D93;

        dut.imem.mem[33] = 32'h00400E13;

        dut.imem.mem[34] = 32'h00800EEF;

        dut.imem.mem[35] = 32'h06300F13;

        dut.imem.mem[36] = 32'h01D02423;

        dut.imem.mem[37] = 32'h0A400293;

        dut.imem.mem[38] = 32'h00028367;

        dut.imem.mem[39] = 32'h05800F13;

        dut.imem.mem[40] = 32'h04D00F13;

        dut.imem.mem[41] = 32'h00602623;

        dut.imem.mem[42] = 32'h07B00F93;

        dut.imem.mem[43] = 32'h01F02823;

        dut.imem.mem[44] = 32'h0000006F;

        repeat (3)
            @(posedge clk);

        rst_n = 1'b1;

        repeat (600)
            @(posedge clk);

        $display("");
        $display("==================================================");
        $display("       MINI-XV COMPREHENSIVE INSTRUCTION TEST");
        $display("==================================================");

        $display("");
        $display("--- R-TYPE ALU ---");

        check_reg(3,  32'd13, "ADD");
        check_reg(4,  32'd7,  "SUB");

        check_reg(7,  32'd9,  "XOR");
        check_reg(8,  32'd80, "SLL");
        check_reg(9,  32'd1,  "SLT");
        check_reg(10, 32'd1,  "SRL");

        $display("");
        $display("--- I-TYPE ALU ---");

        check_reg(11, 32'd2,  "ANDI");
        check_reg(12, 32'd11, "ORI");
        check_reg(13, 32'd9,  "XORI");
        check_reg(14, 32'd1,  "SLTI");
        check_reg(15, 32'd12, "SLLI");
        check_reg(16, 32'd5,  "SRLI");

        $display("");
        $display("--- ARITHMETIC SHIFT ---");

        check_reg(
            17,
            32'hFFFFFFF0,
            "ADDI -16"
        );

        check_reg(
            18,
            32'hFFFFFFFC,
            "SRAI"
        );

        $display("");
        $display("--- LOAD / STORE ---");

        check_mem(0, 32'd13, "SW");
        check_reg(19, 32'd13, "LW");

        check_mem(
            1,
            32'hFFFFFFFC,
            "SW negative"
        );

        check_reg(
            20,
            32'hFFFFFFFC,
            "LW negative"
        );

        $display("");
        $display("--- BRANCHES ---");

        check_reg(
            21,
            32'd0,
            "BEQ skip"
        );

        check_reg(
            22,
            32'd1,
            "BEQ target"
        );

        check_reg(
            23,
            32'd0,
            "BNE skip"
        );

        check_reg(
            24,
            32'd2,
            "BNE target"
        );

        check_reg(
            25,
            32'd0,
            "BLT skip"
        );

        check_reg(
            26,
            32'd3,
            "BLT target"
        );

        check_reg(
            27,
            32'd0,
            "BGE skip"
        );

        check_reg(
            28,
            32'd4,
            "BGE target"
        );

        $display("");
        $display("--- JAL ---");

        check_reg(
            29,
            32'd140,
            "JAL link"
        );

        check_mem(
            2,
            32'd140,
            "JAL stored link"
        );

        $display("");
        $display("--- JALR ---");

        check_reg(
            5,
            32'd164,
            "JALR target addr"
        );

        check_reg(
            6,
            32'd156,
            "JALR link"
        );

        check_mem(
            3,
            32'd156,
            "JALR stored link"
        );

        check_reg(
            30,
            32'd0,
            "JALR skipped code"
        );

        $display("");
        $display("--- FINAL MARKER ---");

        check_reg(
            31,
            32'd123,
            "Final register"
        );

        check_mem(
            4,
            32'd123,
            "Final memory"
        );

        $display("");
        $display("--- x0 ---");

        check_reg(
            0,
            32'd0,
            "Hardwired zero"
        );

        $display("");
        $display("--------------------------------------------------");

        if (errors == 0) begin

            $display("");
            $display("ALL MINI-XV INSTRUCTION TESTS PASSED!");
            $display("");

        end
        else begin

            $display("");
            $display(
                "MINI-XV TEST FAILED: %0d ERROR(S)",
                errors
            );
            $display("");

        end

        $display("==================================================");

        $finish;

    end

endmodule : test_minixv_full
