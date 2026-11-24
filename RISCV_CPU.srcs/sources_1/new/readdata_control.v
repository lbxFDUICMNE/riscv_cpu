`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/04 09:51:44
// Design Name: 
// Module Name: readdata_control
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


module readdata_control(
input [2:0]rdsrc,input [31:0]data_in,input [1:0]shift,output reg[31:0]data_out
    );
    wire [31:0]data;
    assign data=data_in>>{shift,3'b000};
    always@(*)
        case(rdsrc)
            3'b000:data_out=data;//lw
            3'b001:data_out={{16{data[15]}},data[15:0]};//lh
            3'b010:data_out={{24{data[7]}},data[7:0]};//lb
            3'b011:data_out={16'b0,data[15:0]};//lhu
            3'b100:data_out={24'b0,data[7:0]};//lbu
            default:data_out=32'b0;
        endcase
endmodule
