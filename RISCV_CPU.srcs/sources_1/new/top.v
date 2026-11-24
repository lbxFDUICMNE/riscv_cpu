`timescale 1ns/1ps
// FPGA top: shortest paths from a reset-latched source to a live-selected target.
module top #(parameter BOARD_INPUT = 1)(
    input clk_raw,
    input reset,
    input [8:0] sw,
    output reg [6:0] seg,
    output reg [3:0] an,
    
    output led
);
    //reg [4:0] count = 4'd0;
reg clk_div = 1'b0;
wire clk;

always @(posedge clk_raw) //begin
   // if (count == 4'd1) begin
     //   count   <= 4'd0;
        clk_div <= ~clk_div;
    //end else begin
      //  count <= count + 1'b1;
   // end
//end

BUFG cpu_clock_buffer (
    .I(clk_div),
    .O(clk)
);
    wire [31:0] pc, instr, data_addr, writedata, readdata, ram_readdata;
    wire write_en;
    wire [1:0] sdsrc;
    wire ram_write_en = write_en && !reset;

    // Capture the source while reset is held; the same switches can select a
    // destination after reset without changing the running CPU's input.
    reg [4:0] sampled_n = 0;
    always @(posedge clk)
        if (reset) sampled_n <= sw[4:0];

    // The C program reads the starting node from word address zero.
    // BOARD_INPUT=0 lets older testbenches access the physical RAM[0].
    assign readdata = (BOARD_INPUT && data_addr == 32'd0)
                    ? {25'b0, sampled_n} : ram_readdata;

    mem_inst imem(.addr(pc), .inst(instr));
    datapath dp(.clk(clk), .reset(reset), .PCF(pc), .instr(instr),
                .readdata_addr(data_addr), .writedata(writedata),
                .write_en(write_en), .readdata(readdata), .sdsrcM(sdsrc));
    mem_data dmem(.clk(clk), .write_en(ram_write_en), .addr(data_addr),
                  .writedata(writedata), .sdsrc(sdsrc), .readdata(ram_readdata));
    reg [13:0] sum_value = 0;
    reg [31:0] path_distance [0:23];
    reg done = 0;
    // A CPU-cycle timer and a 1-us timer (50 CPU clocks at 50 MHz).
    reg [31:0] elapsed_cycles = 0;
    reg [5:0] microsecond_phase = 0;
    reg [15:0] elapsed_us = 0;
    integer result_index;
    always @(posedge clk) begin
        if (reset) begin
            sum_value <= 0;
            done <= 0;
            elapsed_cycles <= 0;
            microsecond_phase <= 0;
            elapsed_us <= 0;
            for (result_index = 0; result_index < 24; result_index = result_index + 1)
                path_distance[result_index] <= 0;
        end else begin
            if (!done) begin
                elapsed_cycles <= elapsed_cycles + 1'b1;
                if (microsecond_phase == 6'd49) begin
                    microsecond_phase <= 0;
                    elapsed_us <= elapsed_us + 1'b1;
                end else
                    microsecond_phase <= microsecond_phase + 1'b1;
            end
            if (ram_write_en) begin
                if (data_addr[31:2] >= 30'd16 && data_addr[31:2] < 30'd40 &&
                    data_addr[1:0] == 2'b00 && sdsrc == 2'b10)
                    path_distance[data_addr[6:2] - 5'd16] <= writedata;
                case (data_addr)
                    32'd8:  sum_value <= writedata[13:0];
                    32'd20: if (writedata == 32'h0000600d) done <= 1;
                    default: ;
                endcase
            end
        end
    end

    assign led = done;

    // 00 source, 01 distance to SW4:0, 10 microseconds, 11 sum.
    wire invalid_target = (sw[8:7] == 2'b01) && (sw[4:0] >= 5'd24);
    reg [13:0] shown;
    always @* begin
        case (sw[8:7])
            2'b00: shown = {7'b0, sampled_n};
            2'b01: shown = (sw[4:0] < 5'd24) ? path_distance[sw[4:0]][13:0] : 0;
            2'b10: shown = (elapsed_us > 16'd9999) ? 14'd9999 : elapsed_us[13:0];
            2'b11: shown = sum_value;
            default: shown = 0;
        endcase
    end

    // 14-bit binary to four decimal digits, shift-and-add-3.
    reg [15:0] bcd, bcd_work;
    integer bit_index;
    always @* begin
        bcd_work = 0;
        for (bit_index = 13; bit_index >= 0; bit_index = bit_index - 1) begin
            if (bcd_work[3:0]   >= 5) bcd_work[3:0]   = bcd_work[3:0]   + 4'd3;
            if (bcd_work[7:4]   >= 5) bcd_work[7:4]   = bcd_work[7:4]   + 4'd3;
            if (bcd_work[11:8]  >= 5) bcd_work[11:8]  = bcd_work[11:8]  + 4'd3;
            if (bcd_work[15:12] >= 5) bcd_work[15:12] = bcd_work[15:12] + 4'd3;
            bcd_work = {bcd_work[14:0], shown[bit_index]};
        end
        bcd = bcd_work;
    end

    reg [22:0] scan = 0;
    
    
   
        always@(posedge clk)
            if(reset)begin scan<=0;an=4'b0111;end
            else if(scan==22'd4999)begin an<={an[2:0],an[3]}; scan<=0;end
                else scan<=scan+1;
    reg [3:0]number;
    
    
    
    always @* begin
        case (an)
            4'b1110:number= bcd[3:0];
            4'b1101:number= bcd[7:4];
            4'b1011:number = bcd[11:8];
            4'b0111:number = bcd[15:12];
                default:number=4'b0000;
        endcase
        if (!done || invalid_target) seg = 7'b1111111;
        else case (number)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
    // Active-low decimal point on the rightmost digit signals completion.
    
endmodule
