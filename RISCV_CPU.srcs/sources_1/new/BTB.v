`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/25 09:33:07
// Design Name: 
// Module Name: BTB
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


module BTB(
input clk,reset,branch,jump,//branch表示是跳转指令，jump表示实际是否跳转
input [31:0]PC,PCtarget_in,PCplus4F,PCF,
//PC,PCtarget_in是EX阶段传回来写表的，PCF及其plus4是IF阶段进来查表的
output [31:0]PCtarget
    );
    reg [31:0]RAM[0:63];
    reg [23:0]tag[0:63];
    reg [63:0]valid;
    reg [1:0]counter[0:63];
always@(posedge clk)
begin
    if(reset)
    begin
        valid<=0;
    end
    else if(branch)begin
    RAM[PC[7:2]]<=PCtarget_in;
    tag[PC[7:2]]<=PC[31:8];
    valid[PC[7:2]]<=1;
    if(!valid[PC[7:2]]||tag[PC[7:2]]!=PC[31:8])counter[PC[7:2]]<=jump?2'b10:2'b01;
    else if(jump&&(counter[PC[7:2]]!=2'b11))counter[PC[7:2]]<=counter[PC[7:2]]+2'b01;
    else if((!jump)&&(counter[PC[7:2]]!=2'b00))counter[PC[7:2]]<=counter[PC[7:2]]-2'b01;
    end
end
assign PCtarget=valid[PCF[7:2]]&&(tag[PCF[7:2]]==PCF[31:8])&&counter[PCF[7:2]][1]?RAM[PCF[7:2]]:PCplus4F;//跳/不跳判断后的最终目标地址
endmodule
