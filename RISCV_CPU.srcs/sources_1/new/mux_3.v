`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: mux_3
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


module mux_3(
input [31:0]A,B,C,input [1:0]sel,output reg[31:0]Y
    );
always@(*)
    case(sel)
        2'b00:Y=A;
        2'b01:Y=B;
        2'b10:Y=C;
        default:Y=32'b0;
    endcase
endmodule
