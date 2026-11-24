`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: control_unit
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


module control_unit(
input [6:0]op,input [2:0]func3,input [6:0]func7,output reg regwrite,
output reg [1:0]resultsrc,
output reg memwrite,
jump,
branch,
output reg[4:0] ALUcontrol,
output reg[2:0]branch_src,
output reg ALUsrc,
output reg [2:0]immsrc,
output reg [2:0]rdsrc,
output reg [1:0]sdsrc,
output reg jalr,lui
    );
    always@(*)
    begin
        regwrite=0;//是否写寄存器
        resultsrc=2'b00;//选择写回寄存器/forwarding送到ALU的数据
        memwrite=0;//是否写数据内存（S-type专属）
        jump=0;//是否跳转（J-type专属）
        branch=0;//是否分支（B-type专属）
        ALUcontrol=5'b00000;//ALU选择哪种计算
        branch_src=3'b000;//分支指令类型
        ALUsrc=0;//选择操作数B
        immsrc=3'b000;//立即数扩展方式
        rdsrc=3'b000;//数据内存读取方式
        sdsrc=2'b00;//数据内存存储方式
        jalr=0;//jalr指令为1
        lui=0;//lui指令为1
        case(op)
            7'b0110011://R-type
            begin
                regwrite=1;
                if(func7[0]==0)
                case(func3)
                    3'b000:if(func7[5]==0)//add 
                                ALUcontrol=5'b00000;      
                            else if(func7[5]==1)//sub
                                    ALUcontrol=5'b00001;
                    3'b001://sll
                        ALUcontrol=5'b00101;
                    3'b010://slt
                        ALUcontrol=5'b01000;
                    3'b011://sltu
                        ALUcontrol=5'b01001;
                    3'b100://xor
                        ALUcontrol=5'b00100;
                    3'b101:if(func7[5]==0)//srl
                        ALUcontrol=5'b00110;
                                else ALUcontrol=5'b00111;//sra
                    3'b110://or
                        ALUcontrol=5'b00011;
                    3'b111://and
                        ALUcontrol=5'b00010;
                endcase
                else case(func3)//RVM 乘除指令
                    3'b000:ALUcontrol=5'b01010;//mul 
                    3'b001:ALUcontrol=5'b01011;//mulh   
                    3'b010:ALUcontrol=5'b01100;//mulhsu
                    3'b011:ALUcontrol=5'b01101;//mulhu
                    default:ALUcontrol=5'b00000;                      
                   /* 3'b100:ALUcontrol=5'b01110;//div                       
                    3'b101:ALUcontrol=5'b01111;//divu        
                    3'b110:ALUcontrol=5'b10000;//rem
                    3'b111:ALUcontrol=5'b10001;//remu*/
                endcase
            end
            7'b0010011://I-type
            begin
                regwrite=1;
                ALUsrc=1;//选择扩展后立即数作为操作数B
                case(func3)
                    3'b000://addi 
                        ALUcontrol=5'b00000; 
                    3'b001://slli
                        ALUcontrol=5'b00101;
                    3'b010://slti
                        ALUcontrol=5'b01000;
                    3'b011://sltiu
                        ALUcontrol=5'b01001;
                    3'b100://xori
                        ALUcontrol=5'b00100;
                    3'b101:if(func7[5]==0)//srli
                        ALUcontrol=5'b00110;
                         else ALUcontrol=5'b00111;//srai
                    3'b110://ori
                        ALUcontrol=5'b00011;
                    3'b111://andi
                        ALUcontrol=5'b00010;
                endcase
            end
            7'b0000011://I-type load
            begin
                regwrite=1;
                resultsrc=2'b01;
                ALUsrc=1;
                case(func3)
                    3'b000:rdsrc=3'b010;//lb
                    3'b001:rdsrc=3'b001;//lh
                    3'b010:rdsrc=3'b000;//lw
                    3'b100:rdsrc=3'b100;//lbu
                    3'b101:rdsrc=3'b011;//lhu
                endcase
            end
            7'b0100011://S-type
            begin
                memwrite=1;
                ALUsrc=1;
                immsrc=3'b001;
                case(func3)
                    3'b000:sdsrc=2'b00;//sb
                    3'b001:sdsrc=2'b01;//sh
                    3'b010:sdsrc=2'b10;//sw
                endcase
            end
            7'b1100011://B-type
                begin
                    branch=1;
                    immsrc=3'b010;
                    branch_src=func3;
                    case(func3)
                        3'b000:ALUcontrol=5'b00001;
                        3'b001:ALUcontrol=5'b00001;
                        3'b100:ALUcontrol=5'b01000;
                        3'b101:ALUcontrol=5'b01000;
                        3'b110:ALUcontrol=5'b01001;
                        3'b111:ALUcontrol=5'b01001;
                    endcase
                end
            7'b1100111://jalr
                begin
                    regwrite=1;
                    resultsrc=2'b10;
                    ALUsrc=1;
                    immsrc=3'b000;
                    jump=1;
                    jalr=1;
                end
            7'b1101111://jal
                begin
                    regwrite=1;
                    resultsrc=2'b10;
                    immsrc=3'b100;
                    jump=1;
                end
            7'b0110111://lui,rd={upimm,12'b0}
                begin
                    regwrite=1;
                    immsrc=3'b011;
                    lui=1;
                    resultsrc=2'b11;
                end
            7'b0010111://auipc,rd={upimm,12'b0}+PC
                begin
                    regwrite=1;
                    immsrc=3'b011;
                    resultsrc=2'b11;
                end
        endcase
    end
endmodule
