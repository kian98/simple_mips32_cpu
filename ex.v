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
    //input wire[`AluTypeLength] aluType,
    input wire[`AluOpLength] aluOp,
    input wire[`RegBus] opNum1,
    input wire[`RegBus] opNum2,
    input wire writeReg_i,
    input wire[`RegAddrBus] writeAddr_i,
    output reg writeReg_o,
    output reg [`RegAddrBus] writeAddr_o,
    output reg [`RegBus] writeData_o
    );

    //reg[`RegBus] result;      //运算结果

    //根据操作码进行相应运算，并给出最终结果
    always @(*) begin
        if (rst == `RstEnable) begin
            writeReg_o <= `WriteDisable;
        end
        else begin
            case (aluOp)
                `EXE_ORI_OP:
                begin
                    writeData_o <= opNum1|opNum2;
                end
            endcase
            writeReg_o <= writeReg_i;
            writeAddr_o <= writeAddr_i;
        end
    end

    //根据运算类型进行不同输出
    //删去此部分，直接融进上一部分运算
endmodule
