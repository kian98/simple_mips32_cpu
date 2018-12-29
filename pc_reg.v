`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:31:10 12/27/2018 
// Design Name: 
// Module Name:    pc_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     ָ��Ĵ���������ָʾָ����λ�ã����ø�λ�ź�
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module pc_reg(
    input wire rst,				//reset,��λ�ź�
    input wire clk,				//clock,ʱ���ź�
    output reg[`InstAddrBus] pc,//program counter,ָ��Ĵ���,Ҫ��ȡ��ָ��ĵ�ַ
    output reg ce				//ָ��洢��ʹ���ź�
    );

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable; //��λ��ָ��洢��������
        end
        else begin
            ce <= `ChipEnable;
        end
    end

    always @(posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= `InstAddrLength'b0;        //32'b0;ָ��洢�������ã�PCΪ0
        end
        else begin
            pc <= pc + `InstAddrLength'h4;
        end
    end
endmodule
