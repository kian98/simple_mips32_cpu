`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:33:46 01/01/2019 
// Design Name: 
// Module Name:    control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//   控制流水线stall
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module control(
    input rst,
    input id_stall,
    input ex_stall,
    output reg[`StallSignal] stall
    );

	always @(*) begin
		if (rst == `RstEnable) begin
			stall <= 6'b0;
		end
		else if (ex_stall == `Stop) begin
			stall <= 6'b001111;
		end
		else if (id_stall == `Stop) begin
			stall <= 6'b000111;
		end
		else begin
			stall <= 6'b0;
		end
	end


endmodule
