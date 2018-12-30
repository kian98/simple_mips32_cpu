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

    output reg re1,
    output reg[`RegAddrBus] readAddr1,
    output reg re2,
    output reg[`RegAddrBus] readAddr2,

    output reg[`AluOpLength] aluOp,                 //ALU操作数
    output reg[`RegBus] opNum1,                     //操作数1
    output reg[`RegBus] opNum2,                     //操作数2

    output reg writeReg,                    //是否写入寄存器
    output reg[`RegAddrBus] writeAddr       //要写入的寄存器地址，会一直传递下去
    );

    wire[5:0] op = id_inst[31:26];      //操作码
    wire[4:0] rs = id_inst[25:21];      //操作数1寄存器
    wire[4:0] rd = id_inst[15:11];      //目标寄存器
    wire[4:0] shamt = id_inst[10:6];    //移位操作偏移量
    wire[5:0] funct = id_inst[5:0];     //功能码

    reg[`RegBus] imm;                   //立即数
    reg instValid;                      //指令是否有效

//****************指令译码*****************
//  对于逻辑运算、移位操作以及空指令：
//      根据op，非零则可以得到的对应的逻辑操作，包括
//          ori | andi  | xori  | lui
//      若为零，进一步根据shamt判断，若为零，根据funct可以得到对应操作，包括：
//          or  | and   | xor   | nor   | sllv  | srlv  | srav
//      另有三个指令格式不同，判断op、rs为全零时，可以根据funct确定：
//          sll | srl   | sra

    always @(*) begin
        if (rst == `RstEnable) begin
            aluOp <= `EXE_NOP_OP;           //复位，NOP

            instValid <= `InstInvalid;      //指令无效
            writeReg <= `WriteDisable;      //禁用写
            re1 <= `ReadDisable;            //禁用读
            re2 <= `ReadDisable;

            writeAddr <= `NOPRegAddr;       //写地址全零
            readAddr1 <= `NOPRegAddr;       //读地址全零
            readAddr2 <= `NOPRegAddr;

            imm <= `ZeroWord;               //立即数全零
        end
        else begin
            //当没有对应操作时，默认为NOP
            //之前这部分代码放在default中，但随着指令数增加，每个default都会需要添加
            //为了减少代码冗余，将这部分提前。若不是NOP则需要覆盖
            aluOp <= `EXE_NOP_OP;               //默认NOP操作
            re1 <= `ReadDisable;                //不可读
            re2 <= `ReadDisable;
            readAddr1 <= id_inst[25:21];        //读寄存器地址
            readAddr2 <= id_inst[20:16];
            writeReg <= `WriteDisable;          //不可写
            writeAddr <= id_inst[15:11];        //写寄存器地址
            imm <= `ZeroWord;                   //立即数全零
            instValid <= `InstInvalid;          //指令无效

            case(op)
                `EXE_ORI:
                begin
                    aluOp <= `EXE_OR_OP;
                    re1 <= `ReadEnable;                 //读操作数1
                    re2 <= `ReadDisable;                //不读操作数2
                    writeReg <= `WriteEnable;           //运算结果需要写回
                    writeAddr <= id_inst[20:16];        //目标寄存器地址
                    imm <= {16'b0, id_inst[15:0]};      //立即数无符号扩展
                    instValid <= `InstValid;
                end
                `EXE_ANDI:
                begin
                    aluOp <= `EXE_AND_OP;
                    re1 <= `ReadEnable;                 //读操作数1
                    re2 <= `ReadDisable;                //不读操作数2
                    writeReg <= `WriteEnable;           //运算结果需要写回
                    writeAddr <= id_inst[20:16];        //目标寄存器地址
                    imm <= {16'b0, id_inst[15:0]};      //立即数无符号扩展
                    instValid <= `InstValid;
                end
                `EXE_XORI:
                begin
                    aluOp <= `EXE_XOR_OP;
                    re1 <= `ReadEnable;                 //读操作数1
                    re2 <= `ReadDisable;                //不读操作数2
                    writeReg <= `WriteEnable;           //运算结果需要写回
                    writeAddr <= id_inst[20:16];        //目标寄存器地址
                    imm <= {16'b0, id_inst[15:0]};      //立即数无符号扩展
                    instValid <= `InstValid;
                end
                `EXE_LUI:
                begin
                    aluOp <= `EXE_OR_OP;
                    re1 <= `ReadEnable;                 //读操作数1
                    re2 <= `ReadDisable;                //不读操作数2
                    writeReg <= `WriteEnable;           //运算结果需要写回
                    writeAddr <= id_inst[20:16];        //目标寄存器地址
                    imm <= {id_inst[15:0], 16'b0};     //立即数装到高位
                    instValid <= `InstValid;
                end
                6'b000000:
                begin
                    case (shamt)
                        5'b00000:
                        begin
                            case(funct)
                                `EXE_OR:
                                begin
                                    aluOp <= `EXE_OR_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_AND:
                                begin
                                    aluOp <= `EXE_AND_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_XOR:
                                begin
                                    aluOp <= `EXE_XOR_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_NOR:
                                begin
                                    aluOp <= `EXE_NOR_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_SLLV:
                                begin
                                    aluOp <= `EXE_SLL_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_SRLV:
                                begin
                                    aluOp <= `EXE_SRL_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_SRAV:
                                begin
                                    aluOp <= `EXE_SRA_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_MOVN:
                                begin
                                    aluOp <= `EXE_MOVN_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    if(regData2 == `ZeroWord)
                                    begin
                                        writeReg <= `WriteDisable;
                                    end
                                    else begin
                                        writeReg <= `WriteEnable;
                                    end
                                    instValid <= `InstValid;
                                end
                                `EXE_MOVZ:
                                begin
                                    aluOp <= `EXE_MOVZ_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    if(regData2 != `ZeroWord)
                                    begin
                                        writeReg <= `WriteDisable;
                                    end
                                    else begin
                                        writeReg <= `WriteEnable;
                                    end
                                    instValid <= `InstValid;
                                end
                                `EXE_MFHI:
                                begin
                                    aluOp <= `EXE_MFHI_OP;
                                    re1 <= `ReadDisable;
                                    re2 <= `ReadDisable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_MTHI:
                                begin
                                    aluOp <= `EXE_MTHI_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadDisable;
                                    writeReg <= `WriteDisable;
                                    instValid <= `InstValid;
                                end
                                `EXE_MFLO:
                                begin
                                    aluOp <= `EXE_MFLO_OP;
                                    re1 <= `ReadDisable;
                                    re2 <= `ReadDisable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_MTLO:
                                begin
                                    aluOp <= `EXE_MTLO_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadDisable;
                                    writeReg <= `WriteDisable;
                                    instValid <= `InstValid;
                                end
                                default: begin
                                end
                            endcase
                        end
                        default:begin
                        end
                    endcase
                end
                default:begin
                end
            endcase
            if ({op, rs} == 11'b0) begin
                case(funct)
                    `EXE_SLL:
                    begin
                        aluOp <= `EXE_SLL_OP;
                        re1 <= `ReadDisable;
                        re2 <= `ReadEnable;
                        writeReg <= `WriteEnable;
                        imm[4:0] <= id_inst[10:6];
                        instValid <= `InstValid;
                    end
                    `EXE_SRL:
                    begin
                        aluOp <= `EXE_SRL_OP;
                        re1 <= `ReadDisable;
                        re2 <= `ReadEnable;
                        writeReg <= `WriteEnable;
                        imm[4:0] <= id_inst[10:6];
                        instValid <= `InstValid;
                    end
                    `EXE_SRA:
                    begin
                        aluOp <= `EXE_SRA_OP;
                        re1 <= `ReadDisable;
                        re2 <= `ReadEnable;
                        writeReg <= `WriteEnable;
                        imm[4:0] <= id_inst[10:6];
                        instValid <= `InstValid;
                    end
                endcase
            end
        end
    end


//*****************取操作数1***************
    always @(*) begin
        if (rst == `RstEnable) begin
            opNum1 <= `ZeroWord;
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


//******************取操作数2***************
    always @(*) begin
        if (rst == `RstEnable) begin
            opNum2 <= `ZeroWord;
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
