`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 12:25:57
// Design Name: 
// Module Name: reg32_stall
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


module reg32_stall(
input clk,reset,stall,flush,input[31:0]in,output reg [31:0]out
    );
    always@(posedge clk)
        
        begin 
            if(reset|flush)out<=0;
            else if(!stall)out<=in;
        end
endmodule
