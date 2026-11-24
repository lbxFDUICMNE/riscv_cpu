`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/04 22:21:57
// Design Name: 
// Module Name: mux4
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


module mux4(
input [31:0]A,B,C,D,input [1:0]s,output reg [31:0]d
    );
    always@(*)
        case(s)
            2'b00:d=A;
            2'b01:d=B;
            2'b10:d=C;
            2'b11:d=D;
        endcase
endmodule
