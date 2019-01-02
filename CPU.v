`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:01:15 12/28/2018 
// Design Name: 
// Module Name:    CPU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     顶层文件，连接CPU内部各个部件
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module CPU(
    input wire clk,
    input wire rst,
    input wire[`InstBus] rom_inst,
    input wire[`DataBus] ram_data_i,
    output wire[`InstAddrBus] rom_addr,
    output wire rom_ce,			//pc传到inst_rom，可直接在pc输出值处赋值
    output wire[`RegBus] ram_addr,
    output wire[`RegBus] ram_data_o,
    output wire ram_we,
    output wire[3:0] ram_sel,
    output wire ram_ce
    );

	//pc传到if/id
	(* KEEP="TRUE" *)wire[`InstAddrBus] pc;

	//inst_rom传到if/id
	(* KEEP="TRUE" *)wire[`InstBus] if_inst;

	//if/id传到id
	(* KEEP="TRUE" *)wire[`InstAddrBus] id_pc;
	(* KEEP="TRUE" *)wire[`InstBus] id_inst;

    //id传到regfile
    (* KEEP="TRUE" *)wire id_re1;
    (* KEEP="TRUE" *)wire[`RegAddrBus] id_readAddr1;
    (* KEEP="TRUE" *)wire id_re2;
    (* KEEP="TRUE" *)wire[`RegAddrBus] id_readAddr2;

    //regfile传到id
    (* KEEP="TRUE" *)wire[`RegBus] id_regData1;
    (* KEEP="TRUE" *)wire[`RegBus] id_regData2;

    //id传到id/ex
    (* KEEP="TRUE" *)wire[`AluOpLength] id_aluOp;
    (* KEEP="TRUE" *)wire[`RegBus] id_opNum1;
    (* KEEP="TRUE" *)wire[`RegBus] id_opNum2;
    (* KEEP="TRUE" *)wire id_writeReg;
    (* KEEP="TRUE" *)wire[`RegAddrBus] id_writeAddr;
    (* KEEP="TRUE" *)wire id_inDelaySlot;
    (* KEEP="TRUE" *)wire[`RegBus] id_linkAddr;
    (* KEEP="TRUE" *)wire nextInstInDelaySlot;
    (* KEEP="TRUE" *)wire[`InstBus] inst_o;

    //id传到control
    (* KEEP="TRUE" *)wire id_stall;

    //id传到pc
    (* KEEP="TRUE" *)wire branch_flag;
    (* KEEP="TRUE" *)wire[`RegBus] branchTargetAddr;

    //id/ex传到ex
    (* KEEP="TRUE" *)wire[`AluOpLength] ex_aluOp;
    (* KEEP="TRUE" *)wire[`RegBus] ex_opNum1;
    (* KEEP="TRUE" *)wire[`RegBus] ex_opNum2;
    (* KEEP="TRUE" *)wire[`RegAddrBus] ex_writeAddr;
    (* KEEP="TRUE" *)wire ex_writeReg;
    (* KEEP="TRUE" *)wire ex_inDelaySlot;
    (* KEEP="TRUE" *)wire[`RegBus] ex_linkAddr;
    (* KEEP="TRUE" *)wire[`InstBus] ex_inst;

    //id/ex传到id
    (* KEEP="TRUE" *)wire inDelaySlot;

    //ex传到ex/mem
    (* KEEP="TRUE" *)wire ex_wReg;
    (* KEEP="TRUE" *)wire[`RegAddrBus] ex_wAddr;
    (* KEEP="TRUE" *)wire[`RegBus] ex_wData;
    (* KEEP="TRUE" *)wire ex_wHiLo;
    (* KEEP="TRUE" *)wire[`RegBus] ex_hiData;
    (* KEEP="TRUE" *)wire[`RegBus] ex_loData;
    (* KEEP="TRUE" *)wire[`DoubleRegBus] ex_hilo_o;
    (* KEEP="TRUE" *)wire[1:0] ex_count_o;
    (* KEEP="TRUE" *)wire[`AluOpLength] ex_aluOp_o;
    (* KEEP="TRUE" *)wire[`DataAddrBus] ex_mem_addr;
    (* KEEP="TRUE" *)wire[`RegBus] ex_opNum2_o;

    //ex传到control
    (* KEEP="TRUE" *)wire ex_stall;

    //ex传到div
    (* KEEP="TRUE" *)wire div_start;
    (* KEEP="TRUE" *)wire[`RegBus] div_opNum1;
    (* KEEP="TRUE" *)wire[`RegBus] div_opNum2;
    (* KEEP="TRUE" *)wire div_sign;

    //div传到ex
    (* KEEP="TRUE" *)wire div_finish;
    (* KEEP="TRUE" *)wire[`DoubleRegBus] result;

    //ex/mem传到mem
    (* KEEP="TRUE" *)wire mem_wReg_i;
    (* KEEP="TRUE" *)wire[`RegAddrBus] mem_wAddr_i;
    (* KEEP="TRUE" *)wire[`RegBus] mem_wData_i;
    (* KEEP="TRUE" *)wire mem_wHiLo_i;
    (* KEEP="TRUE" *)wire[`RegBus] mem_loData_i;
    (* KEEP="TRUE" *)wire[`RegBus] mem_hiData_i;
    (* KEEP="TRUE" *)wire[`AluOpLength] mem_aluOp;
    (* KEEP="TRUE" *)wire[`DataAddrBus] mem_mem_addr;
    (* KEEP="TRUE" *)wire[`RegBus] mem_opNum2_i;

    //ex/mem传给ex
    (* KEEP="TRUE" *)wire[`DoubleRegBus] ex_hilo_i;
    (* KEEP="TRUE" *)wire[1:0] ex_count_i;

    //mem传到mem/wb, ex
    (* KEEP="TRUE" *)wire mem_wReg_o;
    (* KEEP="TRUE" *)wire[`RegAddrBus] mem_wAddr_o;
    (* KEEP="TRUE" *)wire[`RegBus] mem_wData_o;
    (* KEEP="TRUE" *)wire mem_wHiLo_o;
    (* KEEP="TRUE" *)wire[`RegBus] mem_loData_o;
    (* KEEP="TRUE" *)wire[`RegBus] mem_hiData_o;

    //mem/wb传到regfile
    (* KEEP="TRUE" *)wire we;
    (* KEEP="TRUE" *)wire[`RegAddrBus] writeAddr;
    (* KEEP="TRUE" *)wire[`RegBus] writeData;

    //mem/wb传到ex, hilo_reg
    (* KEEP="TRUE" *)wire wb_wHiLo;
    (* KEEP="TRUE" *)wire[`RegBus] wb_loData;
    (* KEEP="TRUE" *)wire[`RegBus] wb_hiData;

    //hilo_reg传到id
    (* KEEP="TRUE" *)wire[`RegBus] hiData;
    (* KEEP="TRUE" *)wire[`RegBus] loData;

    //control传到pc_reg,if_id,id_ex,ex_mem,mem_wb
    (* KEEP="TRUE" *)wire[`StallSignal] stallSig;

    pc_reg pc_reg0(
    	.clk(clk),
    	.rst(rst),
        .stall(stallSig),
        .branch_flag(branch_flag),
        .branchTargetAddr(branchTargetAddr),
    	.pc(pc),
    	.ce(rom_ce)
    );

    //rom_addr是输出值，内容即pc
    //因为pc既需要传给if/id，又需要给inst_rom，所以单独赋一次值
    assign rom_addr = pc;

    if_id if_id0(
    	.rst(rst),
    	.clk(clk),
    	.if_pc(pc),
    	.if_inst(rom_inst),
        .stall(stallSig),
    	.id_pc(id_pc),
    	.id_inst(id_inst)
    );

    id id0(
    	.rst(rst),
    	.id_pc(id_pc),
    	.id_inst(id_inst),
    	.regData1(id_regData1),
    	.regData2(id_regData2),
        .inDelaySlot_i(inDelaySlot),

        .re1(id_re1),
        .re2(id_re2),
        .readAddr1(id_readAddr1),
        .readAddr2(id_readAddr2),
        .aluOp(id_aluOp),
        .opNum1(id_opNum1),
        .opNum2(id_opNum2),
        .writeReg(id_writeReg),
        .writeAddr(id_writeAddr),
        .id_stall(id_stall),
        .inDelaySlot_o(id_inDelaySlot),
        .linkAddr(id_linkAddr),
        .nextInstInDelaySlot(nextInstInDelaySlot),
        .branchTargetAddr(branchTargetAddr),
        .branch_flag(branch_flag),

        .inst_o(inst_o)
    );

    regfile regfile0(
    	.rst(rst),
    	.clk(clk),
    	.re1(id_re1),
    	.re2(id_re2),
    	.readAddr1(id_readAddr1),
    	.readAddr2(id_readAddr2),
    	.we(we),
    	.writeAddr(writeAddr),
    	.writeData(writeData),
        .ex_wReg_i(ex_wReg),
        .ex_wAddr_i(ex_wAddr),
        .ex_wData_i(ex_wData),
        .mem_wReg_i(mem_wReg_o),
        .mem_wAddr_i(mem_wAddr_o),
        .mem_wData_i(mem_wData_o),

    	.readData1(id_regData1),
    	.readData2(id_regData2)
    );

    id_ex id_ex0(
    	.rst(rst),
    	.clk(clk),
    	.id_aluOp(id_aluOp),
        .stall(stallSig),
    	.id_opNum1(id_opNum1),
    	.id_opNum2(id_opNum2),
    	.id_writeAddr(id_writeAddr),
    	.id_writeReg(id_writeReg),
    	.ex_aluOp(ex_aluOp),
    	.ex_opNum1(ex_opNum1),
    	.ex_opNum2(ex_opNum2),
    	.ex_writeAddr(ex_writeAddr),
    	.ex_writeReg(ex_writeReg),
        .id_inDelaySlot(id_inDelaySlot),
        .id_linkAddr(id_linkAddr),
        .nextInstInDelaySlot(nextInstInDelaySlot),
        .ex_inDelaySlot(ex_inDelaySlot),
        .ex_linkAddr(ex_linkAddr),
        .inDelaySlot(inDelaySlot),
        .id_inst(inst_o),
        .ex_inst(ex_inst)
    );

    ex ex0(
    	.rst(rst),
    	.aluOp(ex_aluOp),
    	.opNum1(ex_opNum1),
    	.opNum2(ex_opNum2),
    	.writeReg_i(ex_writeReg),
    	.writeAddr_i(ex_writeAddr),
        .hiData_i(hiData),
        .loData_i(loData),
        .mem_wHiLo_i(mem_wHiLo_o),
        .mem_hiData_i(mem_hiData_o),
        .mem_loData_i(mem_loData_o),
        .wb_wHiLo_i(wb_wHiLo),
        .wb_hiData_i(wb_hiData),
        .wb_loData_i(wb_loData),
        .inDelaySlot(ex_inDelaySlot),
        .linkAddr(ex_linkAddr),
    	.writeReg_o(ex_wReg),
    	.writeAddr_o(ex_wAddr),
    	.writeData_o(ex_wData),
        .wHiLo(ex_wHiLo),
        .hiData_o(ex_hiData),
        .loData_o(ex_loData),
        .ex_stall(ex_stall),
        .hilo_i(ex_hilo_i),
        .count_i(ex_count_i),
        .hilo_o(ex_hilo_o),
        .count_o(ex_count_o),
        .inst_i(ex_inst),
        .aluOp_o(ex_aluOp_o),
        .mem_addr(ex_mem_addr),
        .opNum2_o(ex_opNum2_o),
        .div_res(result),
        .div_finish(div_finish),
        .opNum1_div(div_opNum1),
        .opNum2_div(div_opNum2),
        .div_start(div_start),
        .div_sign(div_sign)
    );

    div div0(
        .rst(rst),
        .clk(clk),
        .start(div_start),
        .sign(div_sign),
        .dividend_i(div_opNum1),
        .divisor_i(div_opNum2),
        .finish(div_finish),
        .result(result)
    );

    ex_mem ex_mem0(
    	.rst(rst),
    	.clk(clk),
        .stall(stallSig),
    	.ex_wReg(ex_wReg),
    	.ex_wAddr(ex_wAddr),
    	.ex_wData(ex_wData),
        .ex_wHiLo(ex_wHiLo),
        .ex_hiData(ex_hiData),
        .ex_loData(ex_loData),
    	.mem_wReg(mem_wReg_i),
    	.mem_wAddr(mem_wAddr_i),
    	.mem_wData(mem_wData_i),
        .mem_wHiLo(mem_wHiLo_i),
        .mem_hiData(mem_hiData_i),
        .mem_loData(mem_loData_i),
        .hilo_i(ex_hilo_o),
        .count_i(ex_count_o),
        .hilo_o(ex_hilo_i),
        .count_o(ex_count_i),
        .ex_aluOp(ex_aluOp_o),
        .ex_mem_addr(ex_mem_addr),
        .ex_opNum2(ex_opNum2_o),
        .mem_aluOp(mem_aluOp),
        .mem_mem_addr(mem_mem_addr),
        .mem_opNum2(mem_opNum2_i)
    );

    mem mem0(
    	.rst(rst),
    	.wReg_i(mem_wReg_i),
    	.wAddr_i(mem_wAddr_i),
    	.wData_i(mem_wData_i),
        .wHiLo_i(mem_wHiLo_i),
        .hiData_i(mem_hiData_i),
        .loData_i(mem_loData_i),
    	.wReg_o(mem_wReg_o),
    	.wAddr_o(mem_wAddr_o),
    	.wData_o(mem_wData_o),
        .wHiLo_o(mem_wHiLo_o),
        .hiData_o(mem_hiData_o),
        .loData_o(mem_loData_o),
        .aluOp_i(mem_aluOp),
        .mem_addr_i(mem_mem_addr),
        .mem_opNum2_i(mem_opNum2_i),
        .mem_ce(ram_ce),
        .mem_we(ram_we),
        .mem_addr_o(ram_addr),
        .mem_data_o(ram_data_o),
        .mem_sel(ram_sel),
        .mem_data_i(ram_data_i)
    );

    mem_wb mem_wb0(
    	.rst(rst),
    	.clk(clk),
        .stall(stallSig),
    	.mem_wReg(mem_wReg_o),
    	.mem_wAddr(mem_wAddr_o),
    	.mem_wData(mem_wData_o),
        .mem_wHiLo(mem_wHiLo_o),
        .mem_hiData(mem_hiData_o),
        .mem_loData(mem_loData_o),
    	.wb_wReg(we),
    	.wb_wAddr(writeAddr),
    	.wb_wData(writeData),
        .wb_wHiLo(wb_wHiLo),
        .wb_hiData(wb_hiData),
        .wb_loData(wb_loData)
    );

    hilo_reg hilo_reg0(
        .rst(rst),
        .clk(clk),
        .we(wb_wHiLo),
        .hiData_i(wb_hiData),
        .loData_i(wb_loData),
        .hiData_o(hiData),
        .loData_o(loData)
    );

    control control0(
        .rst(rst),
        .id_stall(id_stall),
        .ex_stall(ex_stall),
        .stall(stallSig)
    );

endmodule
