`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 11:56:10
// Design Name: 
// Module Name: reg1
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


module reg1(
input clk,reset,flush,in,output reg out 
    );
    always@(posedge clk)
        if(reset|flush)out<=0;
        else out<=in;
endmodule
