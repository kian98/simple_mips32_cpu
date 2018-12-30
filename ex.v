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
    output reg writeReg_o,
    output reg [`RegAddrBus] writeAddr_o,
    output reg [`RegBus] writeData_o
    );

    //根据操作码进行相应运算，并给出最终结果
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
                default: begin
                    writeData_o <= `ZeroWord;
                end
            endcase
            writeReg_o <= writeReg_i;
            writeAddr_o <= writeAddr_i;
        end
    end

endmodule
