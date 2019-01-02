`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:35:20 01/02/2019 
// Design Name: 
// Module Name:    data_ram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//    数据存储器
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module data_ram(
    input wire ce,
    input wire clk,
    input wire[`DataBus] wData,
    input wire[`DataAddrBus] addr,
    input wire we,
    input wire[3:0] sel,
    output reg[`DataBus] rData
    );

	reg[`ByteWidth] mem0[0:`DataMemNum-1];
	reg[`ByteWidth] mem1[0:`DataMemNum-1];
	reg[`ByteWidth] mem2[0:`DataMemNum-1];
	reg[`ByteWidth] mem3[0:`DataMemNum-1];

	always @(posedge clk) begin
		if (ce == `ChipEnable && we == `WriteEnable) begin
			if(sel[3] == 1'b1)
			begin
				mem3[addr[`DataMemSizeLength+1:2]] <= wData[31:24];
			end
			if(sel[2] == 1'b1)
			begin
				mem2[addr[`DataMemSizeLength+1:2]] <= wData[23:16];
			end
			if(sel[1] == 1'b1)
			begin
				mem1[addr[`DataMemSizeLength+1:2]] <= wData[15:8];
			end
			if(sel[0] == 1'b1)
			begin
				mem0[addr[`DataMemSizeLength+1:2]] <= wData[7:0];
			end
		end
	end

	always @(*) begin
		if (ce == `ChipDisable) begin
			rData <= `ZeroWord;
		end
		else if (we <= `WriteDisable) begin
			rData <= {
				mem3[addr[`DataMemSizeLength+1:2]],
				mem2[addr[`DataMemSizeLength+1:2]],
				mem1[addr[`DataMemSizeLength+1:2]],
				mem0[addr[`DataMemSizeLength+1:2]]
			};
		end
		else begin
			rData <= `ZeroWord;
		end
	end



endmodule
