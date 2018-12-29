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
//
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
    output reg wb_wReg,
    output reg[`RegAddrBus] wb_wAddr,
    output reg[`RegBus] wb_wData
    );

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			wb_wReg <= `WriteDisable;
			wb_wAddr <= `NOPRegAddr;
			wb_wData <= `ZeroWord;
		end
		else begin
			wb_wReg <= mem_wReg;
			wb_wAddr <= mem_wAddr;
			wb_wData <= mem_wData;
		end
	end


endmodule
