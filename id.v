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

    input wire inDelaySlot_i,         //是否为延迟槽指令

    output reg re1,
    output reg[`RegAddrBus] readAddr1,
    output reg re2,
    output reg[`RegAddrBus] readAddr2,

    output reg[`AluOpLength] aluOp,                 //ALU操作数
    output reg[`RegBus] opNum1,                     //操作数1
    output reg[`RegBus] opNum2,                     //操作数2

    output reg writeReg,                    //是否写入寄存器
    output reg[`RegAddrBus] writeAddr,      //要写入的寄存器地址，会一直传递下去
    output wire id_stall,

    output reg branch_flag,
    output reg[`RegBus] branchTargetAddr,
    output reg inDelaySlot_o,
    output reg[`RegBus] linkAddr,
    output reg nextInstInDelaySlot
    );

    assign id_stall = 1'b0;

    wire[5:0] op = id_inst[31:26];      //操作码
    wire[4:0] rs = id_inst[25:21];      //操作数1寄存器
    wire[4:0] rd = id_inst[15:11];      //目标寄存器
    wire[4:0] shamt = id_inst[10:6];    //移位操作偏移量
    wire[5:0] funct = id_inst[5:0];     //功能码

    reg[`RegBus] imm;                   //立即数
    reg instValid;                      //指令是否有效

    wire[`RegBus] imm_sll2_signedext;
    wire[`RegBus] pc_4;
    wire[`RegBus] pc_8;

    assign pc_4 = id_pc + 4;            //delay slot
    assign pc_8 = id_pc + 8;            //return
    //imm左移两位并符号扩展
    assign imm_sll2_signedext = {{14{id_inst[15]}},id_inst[15:0],2'b0};

//****************指令译码*****************
//  对于逻辑运算、移位操作以及空指令：
//      根据op，非零则可以得到的对应的逻辑操作，包括
//          ori | andi  | xori  | lui
//      若为零，进一步根据shamt判断，若为零，根据funct可以得到对应操作，包括：
//          or  | and   | xor   | nor   | sllv  | srlv  | srav
//      另有三个指令格式不同，判断op、rs为全零时，可以根据funct确定：
//          sll | srl   | sra
//  对于移动指令：
//  对于算数运算指令：
//      根据op，非零且但为011100，可根据funct对应以下：
//          clz | clo   | mul
//      若op非零，且不为011100，可对应以下：
//          slti| sltiu | addi  | addiu
//      若op为零，shamt为零，根据funct对应以下：
//          slt | sltu  | add   | addu  | sub   | subu  | mult  | multu
//  对于转移指令：

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

            branch_flag <= `NotBranch;
            nextInstInDelaySlot <= `NotInDelaySlot;
            branchTargetAddr <= `ZeroWord;
            linkAddr <= `ZeroWord;
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
            linkAddr <= `ZeroWord;
            branch_flag <= `NotBranch;
            branchTargetAddr <= `ZeroWord;
            nextInstInDelaySlot <= `NotInDelaySlot;
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
                    imm <= {16'h0, id_inst[15:0]};      //立即数无符号扩展
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
                `EXE_ADDI:
                begin
                    aluOp <= `EXE_ADD_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <= `WriteEnable;
                    writeAddr <= id_inst[20:16];
                    imm <= {{16{id_inst[15]}}, id_inst[15:0]};
                    instValid <= `InstValid;
                end
                `EXE_ADDIU:
                begin
                    aluOp <= `EXE_ADD_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <= `WriteEnable;
                    writeAddr <= id_inst[20:16];
                    imm <= {{16{id_inst[15]}}, id_inst[15:0]};
                    instValid <= `InstValid;
                end
                `EXE_SLTI:
                begin
                    aluOp <= `EXE_SLT_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <= `WriteEnable;
                    writeAddr <= id_inst[20:16];
                    imm <= {{16{id_inst[15]}}, id_inst[15:0]};
                    instValid <= `InstValid;
                end
                `EXE_SLTIU:
                begin
                    aluOp <= `EXE_SLTU_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <= `WriteEnable;
                    writeAddr <= id_inst[20:16];
                    imm <= {{16{id_inst[15]}}, id_inst[15:0]};
                    instValid <= `InstValid;
                end
                `EXE_J:
                begin
                    aluOp <= `EXE_J_OP;
                    re1 <= `ReadDisable;
                    re2 <= `ReadDisable;
                    writeReg <=`WriteDisable;
                    branch_flag <= `Branch;
                    nextInstInDelaySlot <= `InDelaySlot;
                    //32位地址，可以表示4096MB区域，划分为16个256MB区域
                    //j指令在当前PC所在的256MB中跳转。
                    //因为按字节变址，所以左移2位
                    branchTargetAddr <= {pc_4[31:28], id_inst[25:0], 2'b00};
                    instValid <= `InstValid;
                end
                `EXE_JAL:
                begin
                    aluOp <= `EXE_JAL_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <=`WriteEnable;
                    writeAddr <= 5'b11111;
                    branch_flag <= `Branch;
                    nextInstInDelaySlot <= `InDelaySlot;
                    branchTargetAddr <= {pc_4[31:28], id_inst[25:0], 2'b00};
                    linkAddr <= pc_8;
                    instValid <= `InstValid;
                end
                `EXE_BEQ:
                begin
                    aluOp <= `EXE_BEQ_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadEnable;
                    writeReg <=`WriteDisable;
                    if (regData1 == regData2) begin
                        branch_flag <= `Branch;
                        nextInstInDelaySlot <= `InDelaySlot;
                        branchTargetAddr <= pc_4 + imm_sll2_signedext;
                    end
                    instValid <= `InstValid;
                end
                `EXE_BNE:
                begin
                    aluOp <= `EXE_BNE_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadEnable;
                    writeReg <=`WriteDisable;
                    if (regData1 != regData2) begin
                        branch_flag <= `Branch;
                        nextInstInDelaySlot <= `InDelaySlot;
                        branchTargetAddr <= pc_4 + imm_sll2_signedext;
                    end
                    instValid <= `InstValid;
                end
                `EXE_BGTZ:
                begin
                    aluOp <= `EXE_BGTZ_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <=`WriteDisable;
                    if (regData1[31] == 1'b0 && regData1 != `ZeroWord) begin
                        branch_flag <= `Branch;
                        nextInstInDelaySlot <= `InDelaySlot;
                        branchTargetAddr <= pc_4 + imm_sll2_signedext;
                    end
                    instValid <= `InstValid;
                end
                `EXE_BLEZ:
                begin
                    aluOp <= `EXE_BLEZ_OP;
                    re1 <= `ReadEnable;
                    re2 <= `ReadDisable;
                    writeReg <=`WriteDisable;
                    if (regData1[31] == 1'b1 || regData1 == `ZeroWord) begin
                        branch_flag <= `Branch;
                        nextInstInDelaySlot <= `InDelaySlot;
                        branchTargetAddr <= pc_4 + imm_sll2_signedext;
                    end
                    instValid <= `InstValid;
                end
                6'b000001:
                begin
                    case(id_inst[20:16])
                        `EXE_BGEZ:
                        begin
                            aluOp <= `EXE_BGEZ_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadDisable;
                            writeReg <=`WriteDisable;
                            if (regData1[31] == 1'b0) begin
                                branch_flag <= `Branch;
                                nextInstInDelaySlot <= `InDelaySlot;
                                branchTargetAddr <= pc_4 + imm_sll2_signedext;
                            end
                            instValid <= `InstValid;
                        end
                        `EXE_BGEZAL:
                        begin
                            aluOp <= `EXE_BGEZAL_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadDisable;
                            writeReg <=`WriteEnable;
                            writeAddr <= 5'b11111;
                            linkAddr <= pc_8;
                            if (regData1[31] == 1'b0) begin
                                branch_flag <= `Branch;
                                nextInstInDelaySlot <= `InDelaySlot;
                                branchTargetAddr <= pc_4 + imm_sll2_signedext;
                            end
                            instValid <= `InstValid;
                        end
                        `EXE_BLTZ:
                        begin
                            aluOp <= `EXE_BLTZ_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadDisable;
                            writeReg <=`WriteDisable;
                            if (regData1[31] == 1'b1) begin
                                branch_flag <= `Branch;
                                nextInstInDelaySlot <= `InDelaySlot;
                                branchTargetAddr <= pc_4 + imm_sll2_signedext;
                            end
                            instValid <= `InstValid;
                        end
                        `EXE_BLTZAL:
                        begin
                            aluOp <= `EXE_BLTZAL_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadDisable;
                            writeReg <=`WriteEnable;
                            writeAddr <= 5'b11111;
                            linkAddr <= pc_8;
                            if (regData1[31] == 1'b1) begin
                                branch_flag <= `Branch;
                                nextInstInDelaySlot <= `InDelaySlot;
                                branchTargetAddr <= pc_4 + imm_sll2_signedext;
                            end
                            instValid <= `InstValid;
                        end
                    endcase
                end
                6'b011100:
                begin
                    case (funct)
                        `EXE_CLZ:
                        begin
                            aluOp <= `EXE_CLZ_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadDisable;
                            writeReg <= `WriteEnable;
                            instValid <= `InstValid;
                        end
                        `EXE_CLO:
                        begin
                            aluOp <= `EXE_CLO_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadDisable;
                            writeReg <= `WriteEnable;
                            instValid <= `InstValid;
                        end
                        `EXE_MUL:
                        begin
                            aluOp <= `EXE_MUL_OP;
                            re1 <= `ReadEnable;
                            re2 <= `ReadEnable;
                            writeReg <= `WriteEnable;
                            instValid <= `InstValid;
                        end
                        `EXE_MADD:
                        begin
                            aluOp <= `EXE_MADD_OP;
                            re1 <= `ReadEnable;
                            re2 <=  `ReadEnable;
                            writeReg <= `WriteDisable;
                            instValid <= `InstValid;
                        end
                        `EXE_MADDU:
                        begin
                            aluOp <= `EXE_MADDU_OP;
                            re1 <= `ReadEnable;
                            re2 <=  `ReadEnable;
                            writeReg <= `WriteDisable;
                            instValid <= `InstValid;
                        end
                        `EXE_MSUB:
                        begin
                            aluOp <= `EXE_MSUB_OP;
                            re1 <= `ReadEnable;
                            re2 <=  `ReadEnable;
                            writeReg <= `WriteDisable;
                            instValid <= `InstValid;
                        end
                        `EXE_MSUBU:
                        begin
                            aluOp <= `EXE_MSUBU_OP;
                            re1 <= `ReadEnable;
                            re2 <=  `ReadEnable;
                            writeReg <= `WriteDisable;
                            instValid <= `InstValid;
                        end
                        default: begin
                        end
                    endcase
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
                                `EXE_SLT:
                                begin
                                    aluOp <= `EXE_SLT_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_SLTU:
                                begin
                                    aluOp <= `EXE_SLTU_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_ADD:
                                begin
                                    aluOp <= `EXE_ADD_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_ADDU:
                                begin
                                    aluOp <= `EXE_ADDU_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_SUB:
                                begin
                                    aluOp <= `EXE_SUB_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_SUBU:
                                begin
                                    aluOp <= `EXE_SUBU_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteEnable;
                                    instValid <= `InstValid;
                                end
                                `EXE_MULT:
                                begin
                                    aluOp <= `EXE_MULT_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteDisable;
                                    instValid <= `InstValid;
                                end
                                `EXE_MULTU:
                                begin
                                    aluOp <= `EXE_MULTU_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadEnable;
                                    writeReg <= `WriteDisable;
                                    instValid <= `InstValid;
                                end
                                `EXE_JR:
                                begin
                                    aluOp <= `EXE_JR_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadDisable;
                                    writeReg <= `WriteDisable;
                                    branch_flag <= `Branch;
                                    branchTargetAddr <= regData1;
                                    nextInstInDelaySlot <= `InDelaySlot;
                                    instValid <= `InstValid;
                                end
                                `EXE_JALR:
                                begin
                                    aluOp <= `EXE_JR_OP;
                                    re1 <= `ReadEnable;
                                    re2 <= `ReadDisable;
                                    writeReg <= `WriteEnable;
                                    linkAddr <= pc_8;
                                    branch_flag <= `Branch;
                                    branchTargetAddr <= regData1;
                                    nextInstInDelaySlot <= `InDelaySlot;
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

//根据上一时钟周期的结果判断当前指令是否在延迟槽中
    always @(*) begin
        if (rst == `RstEnable) begin
            inDelaySlot_o <= `NotInDelaySlot;
        end
        else begin
            inDelaySlot_o <= inDelaySlot_i;
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
