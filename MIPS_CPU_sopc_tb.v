`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:28:12 12/28/2018
// Design Name:   MIPS_CPU_sopc
// Module Name:   F:/Code/Verilog/MIPS32_CPU_ISE/MIPS32_CPU/MIPS_CPU_sopc_tb.v
// Project Name:  MIPS32_CPU
// Target Device:  
// Tool versions:  
// Description: 
//     对MIPS CPU进行测试，建立Test Bench文件
// Verilog Test Fixture created by ISE for module: MIPS_CPU_sopc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module MIPS_CPU_sopc_tb;

	// Inputs
	reg rst;
	reg clk;


	//20ns 一个周期
	initial begin
		clk = 1'b0;
		forever #10 clk = ~clk;
	end

	initial begin
		rst = `RstEnable;
		#50 rst = `RstDisable;
		#1000 $stop;
	end

	// Instantiate the Unit Under Test (UUT)
	MIPS_CPU_sopc uut (
		.rst(rst), 
		.clk(clk)
	);
      
endmodule

