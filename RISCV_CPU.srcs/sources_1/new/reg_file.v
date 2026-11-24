`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 11:35:11
// Design Name: 
// Module Name: reg_file
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


module reg_file(
input clk,write_en3,input[4:0]A1,A2,A3,input [31:0]writedata3,output[31:0]readdata1,readdata2 
    );
    //32个寄存器，每个32位
    //A1A2是两个读地址端口，A3是写地址端口
    reg [31:0]RAM[31:0];
    assign readdata1=(A1==5'b0)?31'b0:RAM[A1];
    assign readdata2=(A2==5'b0)?31'b0:RAM[A2];
    always@(negedge clk)//前半周期（结束时）写，后半周期结束时下一级流水线寄存器读，避免同时读写导致读出旧值
    if(write_en3)RAM[A3]<=writedata3;
endmodule
