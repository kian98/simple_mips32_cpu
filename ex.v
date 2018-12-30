`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:58:04 12/28/2018 
// Design Name: 
// Module Name:    ex 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     执行阶段，进行ALU运算 
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module ex(
    input wire rst,
    input wire[`AluOpLength] aluOp,
    input wire[`RegBus] opNum1,
    input wire[`RegBus] opNum2,
    input wire writeReg_i,
    input wire[`RegAddrBus] writeAddr_i,
    
    input wire[`RegBus] hiData_i,
    input wire[`RegBus] loData_i,

    input wire mem_wHiLo_i,
    input wire[`RegBus] mem_hiData_i,
    input wire[`RegBus] mem_loData_i,

    input wire wb_wHiLo_i,
    input wire[`RegBus] wb_hiData_i,
    input wire[`RegBus] wb_loData_i,

    output reg writeReg_o,
    output reg[`RegAddrBus] writeAddr_o,
    output reg[`RegBus] writeData_o,

    output reg wHiLo,
    output reg[`RegBus] hiData_o,
    output reg[`RegBus] loData_o
    );

    reg[`RegBus] hiData;
    reg[`RegBus] loData;

    //根据操作码进行相应运算，并给出最终结果writeData_o，最终写回寄存器堆
    always @(*) begin
        if (rst == `RstEnable) begin
            writeReg_o <= `WriteDisable;
        end
        else begin
            case (aluOp)
                `EXE_OR_OP:
                begin
                    writeData_o <= opNum1 | opNum2;
                end
                `EXE_AND_OP:
                begin
                    writeData_o <= opNum1 & opNum2;
                end
                `EXE_XOR_OP:
                begin
                    writeData_o <= opNum1 ^ opNum2;
                end
                `EXE_NOR_OP:
                begin
                    writeData_o <= ~(opNum1 | opNum2);
                end
                `EXE_SLL_OP:
                begin
                    writeData_o <= opNum2 << opNum1[4:0];
                end
                `EXE_SRL_OP:
                begin
                    writeData_o <= opNum2 >> opNum1[4:0];
                end
                `EXE_SRA_OP:
                begin
                    //算数右移，需要考虑符号位，先将符号位扩充为32位左移运算
                    //操作数逻辑右移后，进行或运算，将保留高位符号
                    writeData_o <= ({32{opNum2[31]}} << (
                        6'b100000 - opNum1[4:0]
                        )) | (opNum2 >> opNum1[4:0]);
                end
                `EXE_MOVN_OP:
                begin
                    writeData_o <= opNum1;
                end
                `EXE_MOVZ_OP:
                begin
                    writeData_o <= opNum1;
                end
                `EXE_MFHI_OP:
                begin
                    writeData_o <= hiData;
                end
                `EXE_MFLO_OP:
                begin
                    writeData_o <= loData;
                end
                default: begin
                    writeData_o <= `ZeroWord;
                end
            endcase
            writeReg_o <= writeReg_i;
            writeAddr_o <= writeAddr_i;
        end
    end

    //读取hilo_reg
    always @(*) begin
        if (rst == `RstEnable) begin
            hiData <= `ZeroWord;
            loData <= `ZeroWord;
        end
        else if (mem_wHiLo_i == `WriteEnable) begin
            hiData <= mem_hiData_i;
            loData <= mem_loData_i;
        end
        else if (wb_wHiLo_i == `WriteEnable) begin
            hiData <= wb_hiData_i;
            loData <= wb_loData_i;
        end
        else begin
            hiData <= hiData_i;
            loData <= loData_i;
        end
    end

    //写回hilo_reg
    always @(*) begin
        if (rst == `RstEnable) begin
            wHiLo <= `WriteDisable;
            hiData_o <= `ZeroWord;
            loData_o <= `ZeroWord;
        end
        else begin
            case(aluOp)
                `EXE_MTHI_OP:
                begin
                    wHiLo <= `WriteEnable;
                    hiData_o <= opNum1;
                    loData_o <= loData;
                end
                `EXE_MTLO_OP:
                begin
                    wHiLo <= `WriteEnable;
                    hiData_o <= hiData;
                    loData_o <= opNum1;
                end
                default:begin
                    wHiLo <= `WriteDisable;
                    hiData_o <= `ZeroWord;
                    loData_o <= `ZeroWord;
                end
            endcase
        end
    end
endmodule
