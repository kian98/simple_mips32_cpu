`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:16:42 12/28/2018 
// Design Name: 
// Module Name:    MIPS_CPU_sopc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     CPU与inst_rom的顶层文件
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module MIPS_CPU_sopc(
    input wire rst,
    input wire clk
    );

	wire[`InstBus] inst_i;
	wire rom_ce;
	wire[`InstAddrBus] inst_addr;

	CPU cpu0(
		.clk(clk),
		.rst(rst),
		.rom_inst(inst_i),
		.rom_addr(inst_addr),
		.rom_ce(rom_ce)
	);

	inst_rom inst_rom0(
		.addr(inst_addr),
		.ce(rom_ce),
		.inst(inst_i)
	);

endmodule
