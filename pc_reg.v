`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:31:10 12/27/2018 
// Design Name: 
// Module Name:    pc_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     指令寄存器，用于指示指令存放位置，设置复位信号
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module pc_reg(
    input wire rst,				//reset,复位信号
    input wire clk,				//clock,时钟信号
    input wire[`StallSignal] stall,
    input wire branch_flag,     //是否在转移
    input wire[`RegBus] branchTargetAddr,     //转移地址
    output reg[`InstAddrBus] pc,//program counter,指令寄存器,要读取的指令的地址
    output reg ce				//指令存储器使能信号
    );
//按字节变址，一个操作8位
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable; //复位，指令存储器不可用
        end
        else begin
            ce <= `ChipEnable;
        end
    end

    always @(posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= `InstAddrLength'b0;        //32'b0;指令存储器不可用，PC为0
        end
        else if(branch_flag == `Branch) begin
            pc <= branchTargetAddr;
        end
        else if(stall[0] != `Stop) begin
            pc <= pc + `InstAddrLength'h4;
        end
    end
endmodule
