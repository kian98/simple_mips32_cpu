`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:42:34 12/27/2018 
// Design Name: 
// Module Name:    rom 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//     ָ��洢��������PC��ֵ����ȡָ��
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module inst_rom(
    input wire[`InstAddrBus] addr,
    input wire ce,
    output reg [`InstBus] inst
    );

    reg[`InstBus] inst_rom[0:`InstMemSize-1];

    initial $readmemh("inst_rom.data", inst_rom);

    always @(*) begin
    	if (ce == `ChipDisable) begin
    		inst <= `ZeroWord;
    	end
    	else begin
            //ÿ��ָ��32λ��4���ֽڣ�������λ��������4
            //ָ����Ŀ������17λ��ʾ
    		inst <= inst_rom[addr[`InstMemSizeLength+1:2]];
    	end
    end

endmodule
