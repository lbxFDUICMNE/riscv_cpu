`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 14:06:26
// Design Name: 
// Module Name: reg5
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


module reg5(input clk,reset,flush,input [4:0]in,output reg[4:0]out
    );
    always@(posedge clk)
        if(reset|flush)out<=0;
        else out<=in;
endmodule
