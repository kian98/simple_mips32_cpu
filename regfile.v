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
//     对寄存器堆（Register file）的读写操作，可能读取一个或两个寄存器，
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
        else if (re1 == `ReadEnable && we == `WriteEnable && readAddr1 == writeAddr) begin
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
        else if (re2 == `ReadEnable && we == `WriteEnable
            && readAddr2 == writeAddr) begin
        //当写回阶段的写地址与译码阶段的读操作数地址相同时，
        //读操作中直接赋值，解决了相隔两条指令存在的数据相关
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
