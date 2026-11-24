`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: mem_inst
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_inst(
input [31:0]addr,output [31:0]inst
    );
    reg [31:0]RAM[1023:0];//指令内存4KB，一个字是4个字节（B），一个字节8个bit
    initial begin
        $readmemh("riscvtest.txt",RAM);
        
    end
    assign inst=RAM[addr[31:2]];
endmodule
