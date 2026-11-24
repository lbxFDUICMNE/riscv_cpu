`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: datapath
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

module datapath(
input clk,reset,output [31:0]PCF,input [31:0]instr,output [31:0]readdata_addr,writedata,output write_en,input [31:0]readdata,output [1:0]sdsrcM
    );
    wire regwriteD,regwriteE,regwriteM,regwriteW,memwriteD,memwriteE,memwriteM,jumpD,jumpE,branchD,branchE,ALUsrcD,ALUsrcE,PCsrcE,branch_en,stallF,stallD,flushD,flushE,jalrD,jalrE,luiD,luiE;
    wire [1:0]resultsrcD,resultsrcE,resultsrcM,resultsrcW,forwardAE,forwardBE,sdsrcD,sdsrcE;
    wire [2:0]immsrcD,rdsrcD,rdsrcE,rdsrcM,branchcontrolD,branchcontrolE;
    wire [4:0]ALUcontrolD,ALUcontrolE,Rs1D,Rs2D,RdD,Rs1E,Rs2E,RdE,RdM,RdW;
    wire [31:0]ALUresultE_set0,instrD,PC_next,PCD,PCE,immD,immE,RD1,RD2,RD1E,RD2E,srcAE,srcBE,writedataE,writedataM,ALUresultE,ALUresultM,ALUresultW;
    wire[31:0] readdataM,readdataW,PCplus4F,PCplus4D,PCplus4E,PCplus4M,PCplus4W,resultW,PCtargetE,PCtargetM,PCtargetW,PC_next_j,forward_resultM;
    assign Rs1D=instrD[19:15];
    assign Rs2D=instrD[24:20];
    assign RdD=instrD[11:7];
    assign writedata=writedataM;
    assign write_en=memwriteM;
    assign readdata_addr=ALUresultM;
    assign PCsrcE=jumpE||(branchE&&branch_en);
    assign PCtargetE=luiE?immE:(PCE+immE);
    assign ALUresultE_set0={ALUresultE[31:1],1'b0};
    assign forward_resultM=(resultsrcM == 2'b11)?PCtargetM:(resultsrcM==2'b10)?PCplus4M:ALUresultM;
    //F部分取指
    reg32_stall PC(clk,reset,stallF,0,PC_next,PCF);
    mux_2 PC_mux(PCplus4F,PC_next_j,PCsrcE,PC_next);
    mux_2 jal_mux(PCtargetE,ALUresultE_set0,jalrE,PC_next_j);
    assign PCplus4F=PCF+4;
    //F与D
    reg32_stall instrFD(clk,reset,stallD,flushD,instr,instrD);
    reg32_stall PCFD(clk,reset,stallD,flushD,PCF,PCD);
    reg32_stall PCplus4FD(clk,reset,stallD,flushD,PCplus4F,PCplus4D);
    //D部分译码
    reg_file regf(clk,regwriteW,instrD[19:15],instrD[24:20],RdW,resultW,RD1,RD2);
    extend imm_extend(immsrcD,instrD[31:7],immD);
    control_unit control(instrD[6:0],instrD[14:12],instrD[31:25],regwriteD,resultsrcD,memwriteD,jumpD,branchD,ALUcontrolD,branchcontrolD,ALUsrcD,immsrcD,rdsrcD,sdsrcD,jalrD,luiD);
    //D与E
    reg1 regwriteDE(clk,reset,flushE,regwriteD,regwriteE);
    reg2 resultsrcDE(clk,reset,flushE,resultsrcD,resultsrcE);
    reg1 memwriteDE(clk,reset,flushE,memwriteD,memwriteE);
    reg3 rdsrcDE(clk,reset,flushE,rdsrcD,rdsrcE);
    reg2 sdsrcDE(clk,reset,flushE,sdsrcD,sdsrcE);
    reg1 jumpDE(clk,reset,flushE,jumpD,jumpE);
    reg1 jalrDE(clk,reset,flushE,jalrD,jalrE);
    reg1 branchDE(clk,reset,flushE,branchD,branchE);
    reg5 ALUcontrolDE(clk,reset,flushE,ALUcontrolD,ALUcontrolE);
    reg3 branchcontrolDE(clk,reset,flushE,branchcontrolD,branchcontrolE);
    reg1 ALUsrcDE(clk,reset,flushE,ALUsrcD,ALUsrcE);
    reg32 RD1DE(clk,reset,flushE,RD1,RD1E);
    reg32 RD2DE(clk,reset,flushE,RD2,RD2E);
    reg32 PCDE(clk,reset,flushE,PCD,PCE);
    reg5 Rs1DE(clk,reset,flushE,Rs1D,Rs1E);
    reg5 Rs2DE(clk,reset,flushE,Rs2D,Rs2E);
    reg5 RdDE(clk,reset,flushE,RdD,RdE);
    reg32 immDE(clk,reset,flushE,immD,immE);
    reg32 PCplus4DE(clk,reset,flushE,PCplus4D,PCplus4E);
    reg1 luiDE(clk,reset,flushE,luiD,luiE);
    //E部分执行
    mux_3 srcAE_mux(RD1E,resultW,forward_resultM,forwardAE,srcAE);
    mux_3 srcBE_mux(RD2E,resultW,forward_resultM,forwardBE,writedataE);
    assign srcBE=ALUsrcE?immE:writedataE;
    ALU alu(ALUcontrolE,srcAE,srcBE,branchcontrolE,ALUresultE,branch_en);
    //E与M
    reg1 regwriteEM(clk,reset,0,regwriteE,regwriteM);
    reg2 resultsrcEM(clk,reset,0,resultsrcE,resultsrcM);
    reg1 memwriteEM(clk,reset,0,memwriteE,memwriteM);
    reg3 rdsrcEM(clk,reset,0,rdsrcE,rdsrcM);
    reg2 sdsrcEM(clk,reset,0,sdsrcE,sdsrcM);
    reg32 ALUresultEM(clk,reset,0,ALUresultE,ALUresultM);
    reg32 writedataEM(clk,reset,0,writedataE,writedataM);
    reg5 RdEM(clk,reset,0,RdE,RdM);
    reg32 PCplus4EM(clk,reset,0,PCplus4E,PCplus4M);
    reg32 PCtargetEM(clk,reset,0,PCtargetE,PCtargetM);
    //M
    readdata_control rdcon(rdsrcM,readdata,ALUresultM[1:0],readdataM);
    //M与W
    reg1 regwriteMW(clk,reset,0,regwriteM,regwriteW);
    reg2 resultsrcMW(clk,reset,0,resultsrcM,resultsrcW);
    reg32 ALUresultMW(clk,reset,0,ALUresultM,ALUresultW);
    reg32 readdataMW(clk,reset,0,readdataM,readdataW);
    reg5 RdMW(clk,reset,0,RdM,RdW);
    reg32 PCplus4MW(clk,reset,0,PCplus4M,PCplus4W);
    reg32 PCtargetMW(clk,reset,0,PCtargetM,PCtargetW);
    //W
    mux4 resultmux(ALUresultW,readdataW,PCplus4W,PCtargetW,resultsrcW,resultW);
    //冲突处理单元
    hazard h(Rs1D,Rs2D,Rs1E,Rs2E,RdE,PCsrcE,resultsrcE,RdM,RdW,regwriteM,regwriteW,stallF,stallD,flushD,flushE,forwardAE,forwardBE);
endmodule
