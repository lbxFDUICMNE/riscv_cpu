`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: extend
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


module extend(input [2:0]immtype,
input [31:7]data,output reg[31:0]imm
    );
    always@(*)
        case(immtype)
            3'b000:imm<={{21{data[31]}},data[30:20]};//I-Type
            3'b001:imm<={{21{data[31]}},data[30:25],data[11:7]};//S-Type
            3'b010:imm<={{20{data[31]}},data[7],data[30:25],data[11:8],1'b0};//B-Type
            3'b011:imm<={data[31:12],12'b0};//U-Type
            3'b100:imm<={{12{data[31]}},data[19:12],data[20],data[30:21],1'b0};//J-Type
            default:imm<=31'b0;
        endcase
endmodule
