`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:24:37 12/27/2018 
// Design Name: 
// Module Name:    if_id 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     用于寄存if阶段中pc指向指令的地址，以及从该地址取出的指令，
//     在下一个时钟周期再传入id阶段
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module if_id(
    input wire rst,
    input wire clk,
    input wire[`InstAddrBus] if_pc,
    input wire[`InstBus] if_inst,
    input wire[`StallSignal] stall,
    output reg[`InstAddrBus] id_pc,
    output reg[`InstBus] id_inst
    );

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end
		else if(stall[1] != `Stop) begin
			//当前阶段不用暂停，则正常
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
		else if(stall[2] != `Stop) begin
			//当前段需要暂停且下一段继续运行，插入nop
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end
	end

endmodule
