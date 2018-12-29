`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:35:00 12/28/2018 
// Design Name: 
// Module Name:    id_ex 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     id与ex阶段中间的寄存器
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module id_ex(
    input wire rst,
    input wire clk,
    input wire[`AluOpLength] id_aluOp,
    //input wire[`AluTypeLength] id_aluType,
    input wire[`RegBus] id_opNum1,
    input wire[`RegBus] id_opNum2,
    input wire[`RegAddrBus] id_writeAddr,
    input wire id_writeReg,
    output reg[`AluOpLength] ex_aluOp,
    //output reg[`AluTypeLength] ex_aluType,
    output reg[`RegBus] ex_opNum1,
    output reg[`RegBus] ex_opNum2,
    output reg[`RegAddrBus] ex_writeAddr,
    output reg ex_writeReg
    );

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            //ex_aluType <= `EXE_NOP_T;         //复位，NOP
            ex_aluOp <= `EXE_NOP_OP;          //复位，NOP

            ex_writeReg <= `WriteDisable;       //禁用写
            ex_writeAddr <= `NOPRegAddr;       //写地址全零

            ex_opNum1 <= `ZeroWord;
            ex_opNum2 <= `ZeroWord;
        end
        else begin
            //ex_aluType <= id_aluType;
            ex_aluOp <= id_aluOp;

            ex_writeReg <= id_writeReg;
            ex_writeAddr <= id_writeAddr;

            ex_opNum1 <= id_opNum1;
            ex_opNum2 <= id_opNum2;
        end
    end

endmodule
