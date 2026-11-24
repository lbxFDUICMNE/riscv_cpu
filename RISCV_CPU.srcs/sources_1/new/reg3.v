`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/04 10:23:30
// Design Name: 
// Module Name: reg3
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

module reg3(
input clk,reset,flush,input [2:0]in,output reg[2:0]out
    );
    always@(posedge clk)
        if(reset|flush)out<=0;
        else out<=in;
endmodule
