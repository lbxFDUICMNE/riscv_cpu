`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: ALU
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


module ALU(
input [4:0]ALUcontrol,input [31:0]A,B,input [2:0]branch_src,output reg[31:0]result,output reg branch_en
    );
    wire signed [63:0]signed_A,signed_B,unsigned_A,unsigned_B;
    wire [63:0]mul_ss,mul_uu,mul_su;
    assign signed_A={{32{A[31]}},A};
    assign signed_B={{32{B[31]}},B};
    assign unsigned_A={32'b0,A};
    assign unsigned_B={32'b0,B};
    assign mul_ss=signed_A*signed_B;
    assign mul_uu=unsigned_A*unsigned_B;
    assign mul_su=signed_A*unsigned_B;
    always@(*)
    begin
        
        case(ALUcontrol)
            5'b00000:result=A+B;//add
            5'b00001:result=A-B;//sub
            5'b00010:result=A&B;//and
            5'b00011:result=A|B;//or
            5'b00100:result=A^B;//xor
            5'b00101:result=A<<B[4:0];//sll逻辑左移
            5'b00110:result=A>>B[4:0];//srl逻辑右移
            5'b00111:result=$signed(A)>>>B[4:0];//sra算术右移
            5'b01000:result=($signed(A)<$signed(B));//slt set less than如果小于则置1，否则0
            5'b01001:result=A<B;//sltu set less than unsigned 无符号数比较，如果小于则置1，否则0
            5'b01010:result=mul_uu[31:0];//mul乘法低位
            5'b01011:result=mul_ss[63:32];//mulh有符号数乘法高位
            5'b01100:result=mul_su[63:32];//mulhsu有符号数与无符号数乘法高位
            5'b01101:result=mul_uu[63:32];//mulhu无符号数乘法高位
            /*5'b01110:if(B==0)result=32'hffffffff;//div有符号数除法，规定如果除数为0，结果为-1
                else if(A==32'h80000000&&B==32'hffffffff)result=32'h80000000;//规定溢出（32位有符号数范围-2^31~2^31-1，如果(-2^31)/(-1)=2^31则溢出，规定此时结果为-2^31）
                else result=$signed(A)/$signed(B);
            5'b01111:result=B?A/B:32'hffff_ffff;//无符号数除法
            5'b10000:if(B==0)result=A;//rem有符号数取余，如果B=0则结果为A
                 else if ((A == 32'h80000000) && (B == 32'hffffffff)) result=32'b0;
                 else result=$signed(A)%$signed(B);
            5'b10001:result=B?A%B:A;//remu无符号数取余*/
            default:result=32'b0;
        endcase
    end
    always @* begin
    case (branch_src)
        3'b000: branch_en=(A == B);                  // BEQ
        3'b001: branch_en=(A != B);                  // BNE
        3'b100: branch_en=($signed(A) < $signed(B)); // BLT
        3'b101: branch_en=($signed(A) >= $signed(B));// BGE
        3'b110: branch_en=(A < B);                   // BLTU
        3'b111: branch_en=(A >= B);                  // BGEU
        default: branch_en= 1'b0;
    endcase
end
endmodule
