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
    input wire[`RegBus] id_opNum1,
    input wire[`RegBus] id_opNum2,
    input wire[`RegAddrBus] id_writeAddr,
    input wire id_writeReg,
    input wire[`StallSignal] stall,
    input wire id_inDelaySlot,
    input wire[`RegBus] id_linkAddr,
    input wire nextInstInDelaySlot,
    input wire[`RegBus] id_inst,
    output reg ex_inDelaySlot,
    output reg[`RegBus] ex_linkAddr,
    output reg inDelaySlot,
    output reg[`AluOpLength] ex_aluOp,
    output reg[`RegBus] ex_opNum1,
    output reg[`RegBus] ex_opNum2,
    output reg[`RegAddrBus] ex_writeAddr,
    output reg ex_writeReg,
    output reg[`RegBus] ex_inst
    );

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluOp <= `EXE_NOP_OP;          //复位，NOP

            ex_writeReg <= `WriteDisable;       //禁用写
            ex_writeAddr <= `NOPRegAddr;       //写地址全零

            ex_opNum1 <= `ZeroWord;
            ex_opNum2 <= `ZeroWord;

            ex_linkAddr <= `ZeroWord;
            ex_inDelaySlot <= `NotInDelaySlot;
            inDelaySlot <= `NotInDelaySlot;
        end
        else if(stall[2] != `Stop) begin
            ex_aluOp <= id_aluOp;

            ex_writeReg <= id_writeReg;
            ex_writeAddr <= id_writeAddr;

            ex_opNum1 <= id_opNum1;
            ex_opNum2 <= id_opNum2;

            ex_linkAddr <= id_linkAddr;
            ex_inDelaySlot <= id_inDelaySlot;
            //传回id段，指示id段此时读入指令是否为延迟槽指令
            inDelaySlot <= nextInstInDelaySlot;

            ex_inst <= id_inst;
        end
        else if(stall[3] != `Stop) begin
            ex_aluOp <= `EXE_NOP_OP;          //复位，NOP

            ex_writeReg <= `WriteDisable;       //禁用写
            ex_writeAddr <= `NOPRegAddr;       //写地址全零

            ex_opNum1 <= `ZeroWord;
            ex_opNum2 <= `ZeroWord;

            ex_linkAddr <= `ZeroWord;
            ex_inDelaySlot <= `NotInDelaySlot;
        end
    end

endmodule
