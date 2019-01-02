`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:20:41 12/28/2018 
// Design Name: 
// Module Name:    mem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     访存阶段，读取数据存储器
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module mem(
    input wire rst,
    input wire wReg_i,
    input wire[`RegAddrBus] wAddr_i,
    input wire[`RegBus] wData_i,
    input wire wHiLo_i,
    input wire[`RegBus] hiData_i,
    input wire[`RegBus] loData_i,
    input wire[`AluOpLength] aluOp_i,
    input wire[`DataAddrBus] mem_addr_i,
    input wire[`RegBus] mem_opNum2_i,
    input wire[`RegBus] mem_data_i,		//来自数据存储器
    output reg wReg_o,
    output reg[`RegAddrBus] wAddr_o,
    output reg[`RegBus] wData_o,
    output reg wHiLo_o,
    output reg[`RegBus] hiData_o,
    output reg[`RegBus] loData_o,
    output wire mem_we,
    output reg[`DataAddrBus] mem_addr_o,
    output reg[`RegBus] mem_data_o,
    output reg mem_ce,
    output reg[3:0] mem_sel		//字节选择信号，每一位对应数据存储器中的一个字节（八位）
    );

	reg mem_we_temp;
	assign mem_we = mem_we_temp;

	always @(rst, wReg_i, wAddr_i, wHiLo_i, hiData_i, loData_i,
		aluOp_i, mem_addr_i, mem_opNum2_i, mem_data_i) begin
		if (rst == `RstEnable) begin
			wReg_o <= `WriteDisable;
			wAddr_o <= `NOPRegAddr;
			wData_o <= `ZeroWord;
			wHiLo_o <= `WriteDisable;
			hiData_o <= `ZeroWord;
			loData_o <= `ZeroWord;
			mem_we_temp <= `WriteDisable;
			mem_addr_o <= `ZeroWord;
			mem_data_o <= `ZeroWord;
			mem_ce <= `ChipDisable;
			mem_sel <= 4'b0;
		end
		else begin
			wReg_o <= wReg_i;
			wAddr_o <= wAddr_i;
			wData_o <= wData_i;
			wHiLo_o <= wHiLo_i;
			hiData_o <= hiData_i;
			loData_o <= loData_i;

			mem_sel <= 4'b1111;
			mem_we_temp <= `WriteEnable;
			mem_addr_o <= `ZeroWord;
			mem_ce <= `ChipEnable;
			case(aluOp_i)
				`EXE_LB_OP:
				begin
					mem_addr_o <= mem_addr_i;
					mem_we_temp <= `WriteDisable;
					case (mem_addr_i[1:0])
						2'b00:
						begin
							wData_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
							mem_sel <= 4'b1000;
						end
						2'b01:
						begin
							wData_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
							mem_sel <= 4'b0100;
						end
						2'b10:
						begin
							wData_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
							mem_sel <= 4'b0010;
						end
						2'b11:
						begin
							wData_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
							mem_sel <= 4'b0001;
						end
						default:
						begin
							wData_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LBU_OP:
				begin
					mem_addr_o <= mem_addr_i;
					mem_we_temp <= `WriteDisable;
					case (mem_addr_i[1:0])
						2'b00:
						begin
							wData_o <= {{24{1'b0}},mem_data_i[31:24]};
							mem_sel <= 4'b1000;
						end
						2'b01:
						begin
							wData_o <= {{24{1'b0}},mem_data_i[23:16]};
							mem_sel <= 4'b0100;
						end
						2'b10:
						begin
							wData_o <= {{24{1'b0}},mem_data_i[15:8]};
							mem_sel <= 4'b0010;
						end
						2'b11:
						begin
							wData_o <= {{24{1'b0}},mem_data_i[7:0]};
							mem_sel <= 4'b0001;
						end
						default:
						begin
							wData_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LH_OP:
				begin
					mem_addr_o <= mem_addr_i;
					mem_we_temp <= `WriteDisable;
					case (mem_addr_i[1:0])
						2'b00:
						begin
							wData_o <= {{24{mem_data_i[31]}},mem_data_i[31:16]};
							mem_sel <= 4'b1100;
						end
						2'b10:
						begin
							wData_o <= {{24{mem_data_i[15]}},mem_data_i[15:0]};
							mem_sel <= 4'b0011;
						end
						default:
						begin
							wData_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LHU_OP:
				begin
					mem_addr_o <= mem_addr_i;
					mem_we_temp <= `WriteDisable;
					case (mem_addr_i[1:0])
						2'b00:
						begin
							wData_o <= {{24{1'b0}},mem_data_i[31:16]};
							mem_sel <= 4'b1100;
						end
						2'b10:
						begin
							wData_o <= {{24{1'b0}},mem_data_i[15:0]};
							mem_sel <= 4'b0011;
						end
						default:
						begin
							wData_o <= `ZeroWord;
						end
					endcase
				end
				`EXE_LW_OP:
				begin
					//默认的选择范围为四个，4'b1111
					mem_addr_o <= mem_addr_i;
					mem_we_temp <= `WriteDisable;
					wData_o <= mem_data_i;
				end
				`EXE_SB_OP:
				begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we_temp <= `WriteEnable;
					mem_data_o <= {mem_opNum2_i[7:0],mem_opNum2_i[7:0],
						mem_opNum2_i[7:0],mem_opNum2_i[7:0]};
					case (mem_addr_i[1:0])
						2'b00:
						begin
							mem_sel <= 4'b1000;
						end
						2'b01:
						begin
							mem_sel <= 4'b0100;
						end
						2'b10:
						begin
							mem_sel <= 4'b0010;
						end
						2'b11:
						begin
							mem_sel <= 4'b0001;
						end
						default:
						begin
							mem_sel <= 4'b0000;
						end
					endcase
				end
				`EXE_SH_OP:
				begin
					mem_addr_o <= {mem_addr_i[31:2], 2'b00};
					mem_we_temp <= `WriteEnable;
					mem_data_o <= {mem_opNum2_i[15:0],mem_opNum2_i[15:0]};
					case (mem_addr_i[1:0])
						2'b00:
						begin
							mem_sel <= 4'b1100;
						end
						2'b10:
						begin
							mem_sel <= 4'b0011;
						end
						default: begin
							mem_sel <= 4'b0000;
						end
					endcase
				end
				`EXE_SW_OP:
				begin
					mem_addr_o <= mem_addr_i;
					mem_we_temp <= `WriteEnable;
					mem_data_o <= mem_opNum2_i;
				end
				default: begin
					mem_ce <= `ChipDisable;
				end
			endcase
		end
	end

endmodule
