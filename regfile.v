`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:40:16 12/27/2018 
// Design Name: 
// Module Name:    regfile 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     寄存器堆（Register file）
//     可能读取一个或两个寄存器，
//     或写入一个寄存器；可以返回读取的地址和读取的数据
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module regfile(
    input wire rst,
    input wire clk,
    input wire re1,                      // Read enable for the 1st reg
    input wire[`RegAddrBus] readAddr1,          // The address of the 1st reg (one in 32)
    input wire re2,                      // Write Enable for the 2st reg
    input wire[`RegAddrBus] readAddr2,          // The address of the 2nd reg (one in 32)
    input wire we,                       // Write enable
    input wire[`RegAddrBus] writeAddr,          // Write address for reg
    input wire[`RegBus] writeData,         // Data to write in

    //为解决数据相关问题，将MEM和EX的数据直接传入到ID段
    input wire ex_wReg_i,
    input wire[`RegAddrBus] ex_wAddr_i,
    input wire[`RegBus] ex_wData_i,
    input wire mem_wReg_i,
    input wire[`RegAddrBus] mem_wAddr_i,
    input wire[`RegBus] mem_wData_i,

    output reg[`RegBus] readData1,        // Data read from the 1st reg
    output reg[`RegBus] readData2         // Data read from the 2nd reg
    );

    reg[`RegBus] regs[0:`RegNum-1];

    //********Write**********
    always @(posedge clk) begin
        if (rst == `RstDisable) begin
            if (we == `WriteEnable && writeAddr!=`RegNumLength'b0) begin
            regs[writeAddr] <= writeData;
            end
        end
    end

    //********Read1**********
    always @(rst, clk, re1, re2, readAddr1, readAddr2,
        readData1, readData2, we, writeAddr, writeData) begin
        if (rst == `RstEnable) begin
            readData1 <= `ZeroWord;
        end
        else if (readAddr1 == `RegNumLength'b0) begin
            readData1 <= `ZeroWord;
        end
        //直接读取ex阶段执行得到的值，解决相邻指令的数据相关
        else if (re1 == `ReadEnable && ex_wReg_i == `WriteEnable
            && readAddr1 == ex_wAddr_i) begin
            readData1 <= ex_wData_i;
        end
        //直接读取mem阶段的值，解决相隔一条指令的数据相关
        else if (re1 == `ReadEnable && mem_wReg_i == `WriteEnable
            && readAddr1 == mem_wAddr_i) begin
            readData1 <= mem_wData_i;
        end
        //读取wb阶段的值，解决了相隔两条指令存在的数据相关
        else if (re1 == `ReadEnable && we == `WriteEnable 
            && readAddr1 == writeAddr) begin
            readData1 <= writeData;
        end
        else if (re1 == `ReadEnable) begin
            readData1 <= regs[readAddr1];
        end
        else begin
            readData1 <= `ZeroWord;
        end
    end

    //********Read2**********
    always @(rst, clk, re1, re2, readAddr1, readAddr2,
        readData1, readData2, we, writeAddr, writeData) begin
        if (rst == `RstEnable)begin
            readData2 <= `ZeroWord;
        end
        else if (readAddr2 == `RegNumLength'b0) begin
            readData2 <= `ZeroWord;
        end
        else if (re2 == `ReadEnable && ex_wReg_i == `WriteEnable
            && readAddr2 == ex_wAddr_i) begin
            readData2 <= ex_wData_i;
        end
        else if (re2 == `ReadEnable && mem_wReg_i == `WriteEnable
            && readAddr2 == mem_wAddr_i) begin
            readData2 <= mem_wData_i;
        end
        else if (re2 == `ReadEnable && we == `WriteEnable
            && readAddr2 == writeAddr) begin
            readData2 <= writeData;
        end
        else if (re2 == `ReadEnable) begin
            readData2 <= regs[readAddr2];
        end
        else begin
            readData2 <= `ZeroWord;
        end
    end

endmodule
