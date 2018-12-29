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
    output wire[`InstAddrBus] rom_addr,
    output wire rom_ce			//pc传到inst_rom，可直接在pc输出值处赋值
    );

	//pc传到if/id
	wire[`InstAddrBus] pc;

	//inst_rom传到if/id
	wire[`InstBus] if_inst;

	//if/id传到id
	wire[`InstAddrBus] id_pc;
	wire[`InstBus] id_inst;

    //id传到regfile
    wire id_re1;
    wire[`RegAddrBus] id_readAddr1;
    wire id_re2;
    wire[`RegAddrBus] id_readAddr2;

    //regfile传到id
    wire[`RegBus] id_regData1;
    wire[`RegBus] id_regData2;

    //id传到id/ex
    //wire[`AluTypeLength] id_aluType;
    wire[`AluOpLength] id_aluOp;
    wire[`RegBus] id_opNum1;
    wire[`RegBus] id_opNum2;
    wire id_writeReg;
    wire[`RegAddrBus] id_writeAddr;

    //id/ex传到ex
    wire[`AluOpLength] ex_aluOp;
    //wire[`AluTypeLength] ex_aluType;
    wire[`RegBus] ex_opNum1;
    wire[`RegBus] ex_opNum2;
    wire[`RegAddrBus] ex_writeAddr;
    wire ex_writeReg;

    //ex传到ex/mem
    wire ex_wReg;
    wire[`RegAddrBus] ex_wAddr;
    wire[`RegBus] ex_wData;

    //ex/mem传到mem
    wire mem_wReg_i;
    wire[`RegAddrBus] mem_wAddr_i;
    wire[`RegBus] mem_wData_i;

    //mem传到mem/wb
    wire mem_wReg_o;
    wire[`RegAddrBus] mem_wAddr_o;
    wire[`RegBus] mem_wData_o;

    //mem/wb传到regfile
    wire we;
    wire[`RegAddrBus] writeAddr;
    wire[`RegBus] writeData;

    pc_reg pc_reg0(
    	.clk(clk),
    	.rst(rst),
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
    	.id_pc(id_pc),
    	.id_inst(id_inst)
    );

    id id0(
    	.rst(rst),
    	.id_pc(id_pc),
    	.id_inst(id_inst),
    	.regData1(id_regData1),
    	.regData2(id_regData2),
        .ex_wReg_i(ex_wReg),
        .ex_wAddr_i(ex_wAddr),
        .ex_wData_i(ex_wData),
        .mem_wReg_i(mem_wReg_o),
        .mem_wAddr_i(mem_wAddr_o),
        .mem_wData_i(mem_wData_o),

    	.re1(id_re1),
    	.re2(id_re2),
    	.readAddr1(id_readAddr1),
    	.readAddr2(id_readAddr2),
    	//.aluType(id_aluType),
    	.aluOp(id_aluOp),
    	.opNum1(id_opNum1),
    	.opNum2(id_opNum2),
    	.writeReg(id_writeReg),
    	.writeAddr(id_writeAddr)
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
    	.readData1(id_regData1),
    	.readData2(id_regData2)
    );

    id_ex id_ex0(
    	.rst(rst),
    	.clk(clk),
    	.id_aluOp(id_aluOp),
    	//.id_aluType(id_aluType),
    	.id_opNum1(id_opNum1),
    	.id_opNum2(id_opNum2),
    	.id_writeAddr(id_writeAddr),
    	.id_writeReg(id_writeReg),
    	.ex_aluOp(ex_aluOp),
    	//.ex_aluType(ex_aluType),
    	.ex_opNum1(ex_opNum1),
    	.ex_opNum2(ex_opNum2),
    	.ex_writeAddr(ex_writeAddr),
    	.ex_writeReg(ex_writeReg)
    );

    ex ex0(
    	.rst(rst),
    	//.aluType(ex_aluType),
    	.aluOp(ex_aluOp),
    	.opNum1(ex_opNum1),
    	.opNum2(ex_opNum2),
    	.writeReg_i(ex_writeReg),
    	.writeAddr_i(ex_writeAddr),
    	.writeReg_o(ex_wReg),
    	.writeAddr_o(ex_wAddr),
    	.writeData_o(ex_wData)
    );

    ex_mem ex_mem0(
    	.rst(rst),
    	.clk(clk),
    	.ex_wReg(ex_wReg),
    	.ex_wAddr(ex_wAddr),
    	.ex_wData(ex_wData),
    	.mem_wReg(mem_wReg_i),
    	.mem_wAddr(mem_wAddr_i),
    	.mem_wData(mem_wData_i)
    );

    mem mem0(
    	.rst(rst),
    	.wReg_i(mem_wReg_i),
    	.wAddr_i(mem_wAddr_i),
    	.wData_i(mem_wData_i),
    	.wReg_o(mem_wReg_o),
    	.wAddr_o(mem_wAddr_o),
    	.wData_o(mem_wData_o)
    );

    mem_wb mem_wb0(
    	.rst(rst),
    	.clk(clk),
    	.mem_wReg(mem_wReg_o),
    	.mem_wAddr(mem_wAddr_o),
    	.mem_wData(mem_wData_o),
    	.wb_wReg(we),
    	.wb_wAddr(writeAddr),
    	.wb_wData(writeData)
    );

endmodule
