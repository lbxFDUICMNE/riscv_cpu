`timescale 1ns/1ps
// Independent Floyd-Warshall reference checks all 24 Dijkstra distances.
module tb_shortest_path;
    reg clk_raw = 0, reset = 1;
    reg [8:0] sw = 0;
    wire [6:0] seg;
    wire [3:0] an;
    wire led;
    top dut(.clk_raw(clk_raw), .reset(reset), .sw(sw),
            .seg(seg), .an(an), .led(led));
    always #5 clk_raw = ~clk_raw;

    reg [31:0] reference [0:23][0:23];
    integer i, j, k, failures = 0, cycles;
    integer pattern, weight, neighbor;
    reg [31:0] total, maximum, digest, d, candidate;
    localparam [31:0] INF = 32'h3fffffff;

    initial begin
        // This oracle uses all-pairs Floyd-Warshall, not the CPU's Dijkstra.
        for (i = 0; i < 24; i = i + 1)
            for (j = 0; j < 24; j = j + 1) begin
                pattern = (i * 13 + j * 7 + (i ^ j) * 3) & 7;
                neighbor = (i + 1 == j || j + 1 == i ||
                            (i == 0 && j == 23) || (j == 0 && i == 23));
                weight = 1 + (((i + 1) * (j + 3) + (i ^ j) * 11) & 63);
                reference[i][j] = (i == j) ? 0 :
                    ((neighbor || pattern < 3) ? weight : INF);
            end
        for (k = 0; k < 24; k = k + 1)
            for (i = 0; i < 24; i = i + 1)
                for (j = 0; j < 24; j = j + 1) begin
                    candidate = reference[i][k] + reference[k][j];
                    if (candidate < reference[i][j])
                        reference[i][j] = candidate;
                end

        #1;
        $readmemh("shortest_path_riscvtest.txt", dut.imem.RAM);
        run_case(0,   508, 51, 32'hbd57165f);
        run_case(9,   490, 43, 32'h7fcd2954);
        run_case(23,  495, 53, 32'ha818294d);
        run_case(31,  390, 47, 32'he0aad13d);
        if (failures) $fatal(1, "FAIL %0d shortest-path checks", failures);
        $display("PASS ALL SHORTEST PATH CASES");
        $finish;
    end

    task run_case;
        input [4:0] input_source;
        input [31:0] expected_sum, expected_max, expected_digest;
        integer source, v;
        begin
            @(negedge clk_raw);
            reset = 1;
            sw = {4'b0000, input_source};
            for (v = 0; v < 1024; v = v + 1) dut.dmem.RAM[v] = 0;
            repeat (3) @(posedge dut.clk);
            @(negedge dut.clk);
            reset = 0;
            sw[6:0] = ~input_source; // Test input capture during reset.
            source = input_source;
            while (source >= 24) source = source - 24;
            cycles = 0;
            while (dut.done !== 1'b1 && cycles < 200000) begin
                @(posedge dut.clk);
                cycles = cycles + 1;
                #1;
            end
            total = 0;
            maximum = 0;
            digest = 32'h12345678;
            for (v = 0; v < 24; v = v + 1) begin
                d = reference[source][v];
                if (dut.dmem.RAM[16 + v] !== d) begin
                    failures = failures + 1;
                    $display("FAIL input=%0d destination=%0d expected=%0d actual=%0d",
                             input_source, v, d, dut.dmem.RAM[16 + v]);
                end
                sw[8:7] = 2'b01;
                sw[4:0] = v;
                #1;
                if (dut.shown !== d || dut.path_distance[v] !== d) begin
                    failures = failures + 1;
                    $display("FAIL display input=%0d target=%0d expected=%0d shown=%0d",
                             input_source, v, d, dut.shown);
                end
                total = total + d;
                if (d > maximum) maximum = d;
                digest = (digest << 5) ^ (digest >> 2) ^ d ^ v;
            end
            if (dut.done !== 1'b1 || dut.sampled_n !== input_source ||
                led !== 1'b1 || dut.elapsed_cycles !== cycles ||
                dut.elapsed_us !== (cycles / 50) ||
                total !== expected_sum || maximum !== expected_max ||
                digest !== expected_digest || dut.dmem.RAM[1] !== 24 ||
                dut.dmem.RAM[2] !== total || dut.dmem.RAM[3] !== maximum ||
                dut.dmem.RAM[4] !== digest || dut.dmem.RAM[5] !== 32'h600d) begin
                failures = failures + 1;
                $display("FAIL input=%0d cycles=%0d done=%b count=%0d sum=%0d max=%0d digest=%h",
                         input_source, cycles, dut.done, dut.dmem.RAM[1],
                         dut.dmem.RAM[2], dut.dmem.RAM[3], dut.dmem.RAM[4]);
            end else
                $display("PASS input=%0d source=%0d sum=%0d max=%0d cycles=%0d time_ms=%0.5f",
                         input_source, source, total, maximum, cycles,
                         $itor(cycles) / 50000.0);
            sw[8:7] = 2'b10;
            #1;
            if (dut.shown !== (cycles / 50)) begin
                failures = failures + 1;
                $display("FAIL time display input=%0d expected=%0d shown=%0d",
                         input_source, cycles / 50, dut.shown);
            end
            sw[8:7] = 2'b11;
            #1;
            if (dut.shown !== total) begin
                failures = failures + 1;
                $display("FAIL sum display input=%0d expected=%0d shown=%0d",
                         input_source, total, dut.shown);
            end
            sw[8:7] = 2'b01;
            sw[4:0] = 5'd24;
            #1;
            if (!dut.invalid_target || seg !== 7'b1111111) begin
                failures = failures + 1;
                $display("FAIL invalid target blanking input=%0d", input_source);
            end
        end
    endtask
endmodule
