`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/25 12:51:41
// Design Name: 
// Module Name: reg2_stall
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


module reg2_stall(input clk,reset,stall,flush,input [1:0]in,output reg[1:0]out
    );
    always@(posedge clk)
        if(reset|flush)out<=0;
            else if(!stall)out<=in;
endmodule