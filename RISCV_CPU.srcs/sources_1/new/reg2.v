`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 11:56:10
// Design Name: 
// Module Name: reg2
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


module reg2(
input clk,reset,flush,input [1:0]in,output reg[1:0]out
    );
    always@(posedge clk)
        if(reset|flush)out<=0;
        else out<=in;
endmodule
