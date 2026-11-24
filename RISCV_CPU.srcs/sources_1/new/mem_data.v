`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/28 10:04:57
// Design Name: 
// Module Name: mem_data
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


module mem_data(
input clk,write_en,input [31:0]addr,writedata,input [1:0]sdsrc,output [31:0]readdata
    );
    reg [31:0]RAM[1023:0];//Êý¾ÝÄÚ´æ4KB
    initial RAM[0] = 32'd100;
    wire [31:0]ram_data;
    reg [3:0]byte_en;
    assign ram_data=writedata<<{addr[1:0],3'b000};
    assign readdata=RAM[addr[31:2]];
    always@(*)
        case(sdsrc)
            2'b00:
                case(addr[1:0])
                    2'b00:byte_en=4'b0001;
                    2'b01:byte_en=4'b0010;
                    2'b10:byte_en=4'b0100;
                    2'b11:byte_en=4'b1000;
                    default:byte_en=4'b0000;
                endcase
            2'b01:
                case(addr[1:0])
                    2'b00:byte_en=4'b0011;
                    2'b10:byte_en=4'b1100;
                    default:byte_en=4'b0000;
                endcase
            2'b10:
                byte_en=(addr[1:0]==2'b00)?4'b1111:4'b0000;
            default:byte_en=4'b0000;
        endcase
    always@(posedge clk)
        if(write_en)
            begin
                if(byte_en[0])RAM[addr[31:2]][7:0]<=ram_data[7:0];
                if(byte_en[1])RAM[addr[31:2]][15:8]<=ram_data[15:8];
                if(byte_en[2])RAM[addr[31:2]][23:16]<=ram_data[23:16];
                if(byte_en[3])RAM[addr[31:2]][31:24]<=ram_data[31:24];
            end

endmodule
