`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 11:56:19
// Design Name: 
// Module Name: reg32
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


module reg32(
input clk,reset,flush,input[31:0]in,output reg [31:0]out
    );
    always@(posedge clk)
       if(reset|flush)out<=0;
        else out<=in;
endmodule
