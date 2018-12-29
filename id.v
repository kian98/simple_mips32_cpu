`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:01:08 12/28/2018 
// Design Name: 
// Module Name:    id 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     译码阶段，读取指令以及相应操作数内容
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module id(
    input wire rst,
    input wire[`InstAddrBus] id_pc,
    input wire[`InstBus] id_inst,

    //寄存器堆中读取到的两个操作数
    input wire[`RegBus] regData1,
    input wire[`RegBus] regData2,

    //为解决数据相关问题，将MEM和EX的数据直接传入到ID段
    input wire ex_wReg_i,
    input wire[`RegAddrBus] ex_wAddr_i,
    input wire[`RegBus] ex_wData_i,
    input wire mem_wReg_i,
    input wire[`RegAddrBus] mem_wAddr_i,
    input wire[`RegBus] mem_wData_i,

    output reg re1,
    output reg[`RegAddrBus] readAddr1,
    output reg re2,
    output reg[`RegAddrBus] readAddr2,

    //output reg[`AluTypeLength] aluType,             //ALU操作数选择码
    output reg[`AluOpLength] aluOp,                 //ALU操作数
    output reg[`RegBus] opNum1,                     //操作数1
    output reg[`RegBus] opNum2,                     //操作数2

    output reg writeReg,                    //是否写入寄存器
    output reg[`RegAddrBus] writeAddr       //要写入的寄存器地址，会一直传递下去
    );

    wire[5:0] op = id_inst[31:26];      //操作码
    wire[4:0] op1 = id_inst[10:6];
    wire[5:0] op2 = id_inst[5:0];       //功能码
    wire[4:0] op4 = id_inst[20:16];

    reg[`RegBus] imm;                   //立即数
    reg instValid;                      //指令是否有效

//**********指令译码***********
    always @(*) begin
        if (rst == `RstEnable) begin
            //aluType <= `EXE_NOP_T;         //复位，NOP
            aluOp <= `EXE_NOP_OP;          //复位，NOP

            instValid <= `InstInvalid;      //指令无效
            writeReg <= `WriteDisable;       //禁用写
            re1 <= `ReadDisable;            //禁用读
            re2 <= `ReadDisable;

            writeAddr <= `NOPRegAddr;       //写地址全零
            readAddr1 <= `NOPRegAddr;            //读地址全零
            readAddr2 <= `NOPRegAddr;

            imm <= `ZeroWord;               //立即数全零
        end
        else begin
            case(op)
                `EXE_ORI:       //ori
                begin
                    //aluType <= `EXE_LOGIC_T;
                    aluOp <= `EXE_ORI_OP;

                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    readAddr1 <= id_inst[25:21];         //读地址

                    writeReg <= `WriteEnable;       //ori将结果写入寄存器
                    writeAddr <= id_inst[20:16];    //写地址

                    imm <= {16'b0, id_inst[15:0]};  //立即数无符号扩展
                    instValid <= `InstValid;
                end
                default:        //nop
                begin
                    //aluType <= `EXE_NOP_T;          //默认NOP操作
                    aluOp <= `EXE_NOP_OP;           //默认NOP操作

                    re1 <= `ReadEnable;             //可读
                    re2 <= `ReadEnable;
                    readAddr1 <= id_inst[25:21];         //读地址
                    readAddr2 <= id_inst[20:16];

                    writeReg <= `WriteDisable;       //不可写
                    writeAddr <= id_inst[15:11];    //写地址

                    imm <= `ZeroWord;               //立即数全零
                    instValid <= `InstInvalid;      //指令无效
                end
            endcase

        end
    end

//**********取操作数1***********
    always @(*) begin
        if (rst == `RstEnable) begin
            opNum1 <= `ZeroWord;
        end
        else if (re1 == `ReadEnable && ex_wReg_i == `WriteEnable
            && readAddr1 == ex_wAddr_i) begin
            opNum1 <= ex_wData_i;
        end
        else if (re1 == `ReadEnable && mem_wReg_i == `WriteEnable
            && readAddr1 == mem_wAddr_i) begin
            opNum1 <= mem_wData_i;
        end
        else if (re1 == `ReadDisable) begin
            opNum1 <= imm;
        end
        else if (re1 == `ReadEnable) begin
            opNum1 <= regData1;
        end
        else begin
            opNum1 <= `ZeroWord;
        end
    end

//**********取操作数2***********
    always @(*) begin
        if (rst == `RstEnable) begin
            opNum2 <= `ZeroWord;
        end
        else if (re2 == `ReadEnable && ex_wReg_i == `WriteEnable
            && readAddr2 == ex_wAddr_i) begin
            opNum2 <= ex_wData_i;
        end
        else if (re2 == `ReadEnable && mem_wReg_i == `WriteEnable
            && readAddr2 == mem_wAddr_i) begin
            opNum2 <= mem_wData_i;
        end
        else if (re2 == `ReadDisable) begin
            opNum2 <= imm;
        end
        else if (re2 == `ReadEnable) begin
            opNum2 <= regData2;
        end
        else begin
            opNum2 <= `ZeroWord;
        end
    end

endmodule
