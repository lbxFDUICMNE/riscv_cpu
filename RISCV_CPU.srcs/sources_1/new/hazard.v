`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: hazard
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


module hazard(
input [4:0]Rs1D,Rs2D,Rs1E,Rs2E,RdE,input PCsrcE,input[1:0]resultsrcE,input [4:0]RdM,RdW,input regwriteM,regwriteW,
output stallF,stallD,flushD,flushE,output reg[1:0]forwardAE,forwardBE
    );
    always@(*)begin
            if(((Rs1E==RdM)&regwriteM)&(Rs1E!=0)) forwardAE=2'b10;
            else if(((Rs1E==RdW)&regwriteW)&(Rs1E!=0)) forwardAE=2'b01;
            else forwardAE=2'b00;
                if(((Rs2E==RdM)&regwriteM)&(Rs2E!=0)) forwardBE=2'b10;
            else if(((Rs2E==RdW)&regwriteW)&(Rs2E!=0)) forwardBE=2'b01;
            else forwardBE=2'b00;end
    assign stallF=(resultsrcE==2'b01)&((Rs1D==RdE)|(Rs2D==RdE))&(RdE!=0);
    assign stallD=stallF;
    assign flushD=PCsrcE;
    assign flushE=stallF|PCsrcE;
endmodule
