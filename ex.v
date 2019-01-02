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
    
    input wire[`RegBus] hiData_i,   //从hilo_reg传入
    input wire[`RegBus] loData_i,   //从hilo_reg传入

    input wire mem_wHiLo_i,
    input wire[`RegBus] mem_hiData_i,
    input wire[`RegBus] mem_loData_i,

    input wire wb_wHiLo_i,
    input wire[`RegBus] wb_hiData_i,
    input wire[`RegBus] wb_loData_i,

    input wire[1:0] count_i,
    input wire[`DoubleRegBus] hilo_i,

    input wire inDelaySlot,
    input wire[`RegBus] linkAddr,

    input wire[`RegBus] inst_i,

    output reg writeReg_o,
    output reg[`RegAddrBus] writeAddr_o,
    output reg[`RegBus] writeData_o,

    output reg wHiLo,
    output reg[`RegBus] hiData_o,   //写到hilo_reg
    output reg[`RegBus] loData_o,   //写到hilo_reg
    output reg ex_stall,
    output reg[1:0] count_o,
    output reg[`DoubleRegBus] hilo_o,
    output wire[`AluOpLength] aluOp_o,
    output wire[`DataAddrBus] mem_addr,
    output wire[`RegBus] opNum2_o
    );

    reg[`RegBus] hiData;            //从hilo_reg读出
    reg[`RegBus] loData;            //从hilo_reg读出
    wire[`RegBus] opNum2_comp;      //opNum2补码
    wire[`RegBus] opNum1_not;       //opNum1反码
    wire overflow;                  //溢出标志
    wire[`RegBus] sum;              //相加结果
    wire opNum1_lt_opNum2;          //opNum1 less than opNum2

    wire[`DoubleRegBus] mul_ans_temp;
    reg[`DoubleRegBus] mul_ans;
    reg[`DoubleRegBus] mul_add_sub_ans;

    assign aluOp_o = aluOp;
    assign mem_addr = opNum1 + {{16{inst_i[15]}},inst_i[15:0]};
    assign opNum2_o = opNum2;

    //若为减法或者有符号的比较指令，需要求出补码，转化为加法运算
    assign opNum2_comp =
        ((aluOp == `EXE_SUB_OP) ||
            (aluOp == `EXE_SUBU_OP) ||
                (aluOp == `EXE_SLT_OP))
        ? (~opNum2)+1 : opNum2;

    //加法运算
    //减法，或有符号比较（相当于减法），转换得到补码后加法
    assign sum = opNum1 + opNum2_comp;

    //溢出标志，溢出会引发异常（与进位不同）
    //情况1：正数+正数 = 负数
    //情况2：负数+负数 = 正数
    //根据标志位即可判断
    assign overflow =
        ((!opNum1[31] && !opNum2_comp[31]) && sum[31]) ||
            ((opNum1[31] && opNum2_comp[31]) && (!sum[31]));
    
    //若为slt指令有符号比较，小于等于情况如下：
    //  1：负数 < 正数
    //  2：正数1-正数2 < 0
    //  3：负数1-负数2 < 0
    //否则可以直接判断
    assign opNum1_lt_opNum2 =
        (aluOp == `EXE_SLT_OP) ?
            ((opNum1[31] && !opNum2[31]) ||
                (!opNum1[31] && !opNum2[31] && sum[31]) ||
                    (opNum1[31] && opNum2[31] && sum[31]))
            : (opNum1 < opNum2);

    //opNum1反码
    assign opNum1_not = ~opNum1;

    //根据操作码进行相应运算，并给出最终结果writeData_o，最终写回寄存器堆
    always @(*) begin
        if (rst == `RstEnable) begin
            writeReg_o <= `WriteDisable;
            hilo_o <= {`ZeroWord, `ZeroWord};
            count_o <= 2'b00;
            ex_stall <= `NotStop;
        end
        else begin
            //若为有符号数的运算，需要根据是否溢出来判断写回
            if((aluOp == `EXE_ADD_OP ||
                aluOp == `EXE_ADDI_OP ||
                aluOp == `EXE_SUB_OP)
                && (overflow == 1'b1))
            begin
                writeReg_o <= `WriteDisable;
            end
            else begin
                writeReg_o <= writeReg_i;
            end

            writeAddr_o <= writeAddr_i;

            //判断指令
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
                `EXE_SLT_OP, `EXE_SLTU_OP:
                begin
                    writeData_o <= opNum1_lt_opNum2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP,
                    `EXE_ADDIU_OP,`EXE_SUB_OP, `EXE_SUBU_OP:
                begin
                    writeData_o <= sum;
                end
                `EXE_CLZ_OP:
                begin
                    writeData_o <=
                    opNum1[31] ? 0  : opNum1[30] ? 1  : opNum1[29] ? 2  :
                    opNum1[28] ? 3  : opNum1[27] ? 4  : opNum1[26] ? 5  :
                    opNum1[25] ? 6  : opNum1[24] ? 7  : opNum1[23] ? 8  :
                    opNum1[22] ? 9  : opNum1[21] ? 10 : opNum1[20] ? 11 :
                    opNum1[19] ? 12 : opNum1[18] ? 13 : opNum1[17] ? 14 :
                    opNum1[16] ? 15 : opNum1[15] ? 16 : opNum1[14] ? 17 :
                    opNum1[13] ? 18 : opNum1[12] ? 19 : opNum1[11] ? 20 :
                    opNum1[10] ? 21 : opNum1[9]  ? 22 : opNum1[8]  ? 23 :
                    opNum1[7]  ? 24 : opNum1[6]  ? 25 : opNum1[5]  ? 26 :
                    opNum1[4]  ? 27 : opNum1[3]  ? 28 : opNum1[2]  ? 29 :
                    opNum1[1]  ? 30 : opNum1[0]  ? 31 : 32 ;
                end
                `EXE_CLO_OP:
                begin
                    writeData_o <=
                    opNum1_not[31] ? 0  : opNum1_not[30] ? 1  : opNum1_not[29] ? 2  :
                    opNum1_not[28] ? 3  : opNum1_not[27] ? 4  : opNum1_not[26] ? 5  :
                    opNum1_not[25] ? 6  : opNum1_not[24] ? 7  : opNum1_not[23] ? 8  : 
                    opNum1_not[22] ? 9  : opNum1_not[21] ? 10 : opNum1_not[20] ? 11 :
                    opNum1_not[19] ? 12 : opNum1_not[18] ? 13 : opNum1_not[17] ? 14 : 
                    opNum1_not[16] ? 15 : opNum1_not[15] ? 16 : opNum1_not[14] ? 17 : 
                    opNum1_not[13] ? 18 : opNum1_not[12] ? 19 : opNum1_not[11] ? 20 :
                    opNum1_not[10] ? 21 : opNum1_not[9]  ? 22 : opNum1_not[8]  ? 23 : 
                    opNum1_not[7]  ? 24 : opNum1_not[6]  ? 25 : opNum1_not[5]  ? 26 : 
                    opNum1_not[4]  ? 27 : opNum1_not[3]  ? 28 : opNum1_not[2]  ? 29 : 
                    opNum1_not[1]  ? 30 : opNum1_not[0]  ? 31 : 32;
                end
                `EXE_MADD_OP, `EXE_MADDU_OP:
                begin
                    if(count_i == 2'b00)
                    begin
                        hilo_o <= mul_ans;
                        count_o <= 2'b01;
                        ex_stall <= `Stop;
                    end
                    else if(count_i == 2'b01) begin
                        hilo_o <= {`ZeroWord, `ZeroWord};
                        count_o <= 2'b10;
                        mul_add_sub_ans <= hilo_i + {hiData, loData};
                        ex_stall <= `NotStop;
                    end
                end
                `EXE_MSUB_OP, `EXE_MSUBU_OP:
                begin
                    if(count_i == 2'b00)
                    begin
                        hilo_o <= ~mul_ans + 1;
                        count_o <= 2'b01;
                        ex_stall <= `Stop;
                    end
                    else if(count_i == 2'b01) begin
                        hilo_o <= {`ZeroWord, `ZeroWord};
                        count_o <= 2'b10;
                        mul_add_sub_ans <= hilo_i + {hiData, loData};
                        ex_stall <= `NotStop;
                    end
                end
                `EXE_J_OP, `EXE_JAL_OP, `EXE_JALR_OP,
                `EXE_JR_OP, `EXE_BEQ_OP, `EXE_BGEZ_OP,
                `EXE_BGEZAL_OP, `EXE_BGTZ_OP, `EXE_BLEZ_OP,
                `EXE_BLTZ_OP, `EXE_BLTZAL_OP, `EXE_BNE_OP:
                begin
                    writeData_o <= linkAddr;
                end
                default: begin
                    writeData_o <= `ZeroWord;
                    hilo_o <= {`ZeroWord, `ZeroWord};
                    count_o <= 2'b00;
                    ex_stall <= `NotStop;
                end
            endcase
        end
    end

    wire[`RegBus] opNum1_mul;
    wire[`RegBus] opNum2_mul;

    //若为有符号乘，需要对负数取补码
    assign opNum1_mul = ((aluOp == `EXE_MUL_OP || aluOp == `EXE_MULT_OP
        || aluOp == `EXE_MADD_OP || aluOp == `EXE_MSUB_OP)
        && opNum1[31] == 1'b1) ? (~opNum1 + 1) : opNum1;
    assign opNum2_mul = ((aluOp == `EXE_MUL_OP || aluOp == `EXE_MULT_OP
        || aluOp == `EXE_MADD_OP || aluOp == `EXE_MSUB_OP)
        && opNum2[31] == 1'b1) ? (~opNum2 + 1) : opNum2;

    //未修正的乘法结果
    assign mul_ans_temp = opNum1_mul * opNum2_mul;

    //无符号乘法，直接赋值
    //有符号乘法，若两个数同号，直接赋值；
    //若不同号，需要将已经求得的结果取补码
    always @(*) begin
        if (rst == `RstEnable) begin
            mul_ans <= {`ZeroWord,`ZeroWord};
        end
        else if (aluOp == `EXE_MUL_OP || aluOp == `EXE_MULT_OP
            || aluOp == `EXE_MADD_OP || aluOp == `EXE_MSUB_OP) 
        begin
            if (opNum1[31] ^ opNum2 == 1'b1) begin
                mul_ans <= ~mul_ans_temp + 1;
            end
            else begin
                mul_ans <= mul_ans_temp;
            end
        end
        else begin
            mul_ans <= mul_ans_temp;
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
                `EXE_MULT_OP, `EXE_MULTU_OP:
                begin
                    wHiLo <= `WriteEnable;
                    hiData_o <= mul_ans[63:32];
                    loData_o <= mul_ans[31:0];
                end
                `EXE_MADD_OP, `EXE_MSUB_OP, `EXE_MADDU_OP,`EXE_MSUBU_OP:
                begin
                    wHiLo <= `WriteEnable;
                    hiData_o <= mul_add_sub_ans[63:32];
                    loData_o <= mul_add_sub_ans[31:0];
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
