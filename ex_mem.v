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
    input wire ex_wHiLo,
    input wire[`RegBus] ex_hiData,
    input wire[`RegBus] ex_loData,
    input wire[`StallSignal] stall,
    input wire[`DoubleRegBus] hilo_i,
    input wire[1:0] count_i,
    input wire[`AluOpLength] ex_aluOp,
    input wire[`RegBus] ex_mem_addr,
    input wire[`RegBus] ex_opNum2,
    output reg mem_wReg,
    output reg[`RegAddrBus] mem_wAddr,
    output reg[`RegBus] mem_wData,
    output reg mem_wHiLo,
    output reg[`RegBus] mem_hiData,
    output reg[`RegBus] mem_loData,
    output reg[`DoubleRegBus] hilo_o,
    output reg[1:0] count_o,
    output reg[`AluOpLength] mem_aluOp,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_opNum2
    );

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			mem_wReg <= `WriteDisable;
			mem_wAddr <= `NOPRegAddr;
			mem_wData <= `ZeroWord;
			mem_wHiLo <= `WriteDisable;
			mem_hiData <= `ZeroWord;
			mem_loData <= `ZeroWord;
			hilo_o <= {`ZeroWord, `ZeroWord};
			count_o <= 2'b00;
			mem_aluOp <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_opNum2 <= `ZeroWord;
		end
		else if(stall[3] != `Stop) begin
			mem_wReg <= ex_wReg;
			mem_wAddr <= ex_wAddr;
			mem_wData <= ex_wData;
			mem_wHiLo <= ex_wHiLo;
			mem_hiData <= ex_hiData;
			mem_loData <= ex_loData;
			hilo_o <= {`ZeroWord, `ZeroWord};
			count_o <= 2'b00;
			mem_aluOp <= ex_aluOp;
			mem_mem_addr <= ex_mem_addr;
			mem_opNum2 <= ex_opNum2;
		end
		else if(stall[4] != `Stop) begin
			mem_wReg <= `WriteDisable;
			mem_wAddr <= `NOPRegAddr;
			mem_wData <= `ZeroWord;
			mem_wHiLo <= `WriteDisable;
			mem_hiData <= `ZeroWord;
			mem_loData <= `ZeroWord;
			hilo_o <= hilo_i;
			count_o <= count_i;
			mem_aluOp <= `EXE_NOP_OP;
			mem_mem_addr <= `ZeroWord;
			mem_opNum2 <= `ZeroWord;
		end
		else begin
			hilo_o <= hilo_i;
			count_o <= count_i;
		end
	end

endmodule
