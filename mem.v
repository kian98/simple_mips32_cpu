`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:20:41 12/28/2018 
// Design Name: 
// Module Name:    mem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     访存阶段，读取数据存储器
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module mem(
    input wire rst,
    input wire wReg_i,
    input wire[`RegAddrBus] wAddr_i,
    input wire[`RegBus] wData_i,
    input wire wHiLo_i,
    input wire[`RegBus] hiData_i,
    input wire[`RegBus] loData_i,
    output reg wReg_o,
    output reg[`RegAddrBus] wAddr_o,
    output reg[`RegBus] wData_o,
    output reg wHiLo_o,
    output reg[`RegBus] hiData_o,
    output reg[`RegBus] loData_o
    );

	always @(*) begin
		if (rst == `RstEnable) begin
			wReg_o <= `WriteDisable;
			wAddr_o <= `NOPRegAddr;
			wData_o <= `ZeroWord;
			wHiLo_o <= `WriteDisable;
			hiData_o <= `ZeroWord;
			loData_o <= `ZeroWord;
		end
		else begin
			wReg_o <= wReg_i;
			wAddr_o <= wAddr_i;
			wData_o <= wData_i;
			wHiLo_o <= wHiLo_i;
			hiData_o <= hiData_i;
			loData_o <= loData_i;
		end
	end

endmodule
