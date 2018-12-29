`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:10:11 12/28/2018 
// Design Name: 
// Module Name:    ex_mem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     ex与mem阶段中间过程，传递数据
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module ex_mem(
    input wire rst,
    input wire clk,
    input wire ex_wReg,
    input wire[`RegAddrBus] ex_wAddr,
    input wire[`RegBus] ex_wData,
    output reg mem_wReg,
    output reg[`RegAddrBus] mem_wAddr,
    output reg[`RegBus] mem_wData
    );

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			mem_wReg <= `WriteDisable;
			mem_wAddr <= `NOPRegAddr;
			mem_wData <= `ZeroWord;
		end
		else begin
			mem_wReg <= ex_wReg;
			mem_wAddr <= ex_wAddr;
			mem_wData <= ex_wData;
		end
	end

endmodule
