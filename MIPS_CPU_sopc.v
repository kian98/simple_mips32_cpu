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
    (* KEEP="TRUE" *)wire ram_we;
    (* KEEP="TRUE" *)wire[`DataAddrBus] ram_addr;
    (* KEEP="TRUE" *)wire[3:0] ram_sel;
    (* KEEP="TRUE" *)wire[`RegBus] ram_data_o;
    (* KEEP="TRUE" *)wire ram_ce;
    (* KEEP="TRUE" *)wire[`DataBus] ram_data_i;
	CPU cpu0(
		.clk(clk),
		.rst(rst),
		.rom_inst(inst_i),
		.rom_addr(inst_addr),
		.rom_ce(rom_ce),
		.ram_data_i(ram_data_i),
		.ram_addr(ram_addr),
		.ram_data_o(ram_data_o),
		.ram_we(ram_we),
		.ram_sel(ram_sel),
		.ram_ce(ram_ce)
	);

	inst_rom inst_rom0(
		.addr(inst_addr),
		.ce(rom_ce),
		.inst(inst_i)
	);

	data_ram data_ram0(
		.ce(mem_ce),
		.clk(clk),
		.wData(ram_data_o),
		.addr(ram_addr),
		.we(ram_we),
		.sel(ram_sel),
		.rData(ram_data_i)
	);

endmodule
