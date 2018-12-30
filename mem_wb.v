`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:36:39 12/28/2018 
// Design Name: 
// Module Name:    mem_wb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//    写回阶段
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module mem_wb(
    input wire rst,
    input wire clk,
    input wire mem_wReg,
    input wire[`RegAddrBus] mem_wAddr,
    input wire[`RegBus] mem_wData,
    input wire mem_wHiLo,
    input wire[`RegBus] mem_hiData,
    input wire[`RegBus] mem_loData,
    output reg wb_wReg,
    output reg[`RegAddrBus] wb_wAddr,
    output reg[`RegBus] wb_wData,
    output reg wb_wHiLo,
    output reg[`RegBus] wb_hiData,
    output reg[`RegBus] wb_loData
    );

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			wb_wReg <= `WriteDisable;
			wb_wAddr <= `NOPRegAddr;
			wb_wData <= `ZeroWord;
			wb_wHiLo <= `WriteDisable;
			wb_hiData <= `ZeroWord;
			wb_loData <= `ZeroWord;
		end
		else begin
			wb_wReg <= mem_wReg;
			wb_wAddr <= mem_wAddr;
			wb_wData <= mem_wData;
			wb_wHiLo <= mem_wHiLo;
			wb_hiData <= mem_hiData;
			wb_loData <= mem_loData;
		end
	end


endmodule
