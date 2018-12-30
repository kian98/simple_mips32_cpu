`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:17:00 12/30/2018 
// Design Name: 
// Module Name:    hilo 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     用于保存乘除法运算的结果
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module hilo_reg(
    input wire clk,
    input wire rst,
    input wire we,
    input wire[`RegBus] hiData_i,
    input wire[`RegBus] loData_i,
    output reg[`RegBus] hiData_o,
    output reg[`RegBus] loData_o
    );

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			hiData_o <= `ZeroWord;
			loData_o <= `ZeroWord;
		end
		else if (we == `WriteEnable) begin
			hiData_o <= hiData_i;
			loData_o <= loData_i;
		end
	end

endmodule
