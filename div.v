`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:37:11 01/02/2019 
// Design Name: 
// Module Name:    div 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//   试商法实现的除法器
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module div(
	input wire rst,
	input wire clk,
	input wire start,
	input wire sign,
	input wire[`RegBus] dividend_i,
	input wire[`RegBus] divisor_i,
	output reg finish,
	output reg[`DoubleRegBus] result
    );

	reg[5:0] count;		//试商法次数，if 32 then finish
	wire[32:0] res_temp;
	reg[64:0] dividend;
	reg[1:0] status;
	reg[`RegBus] divisior;
	reg[`RegBus] opNum1_temp;
	reg[`RegBus] opNum2_temp;

	assign res_temp = {1'b0, dividend[63:32]} - {1'b0, divisior};

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			status <= `DivFree;
			finish <= `Finish;
			result <= {`ZeroWord, `ZeroWord};
		end
		else begin
			case(status)
				`DivFree:
				begin
					if(start == 1'b1)				//开始除法运算
					begin
						if(divisor_i == `ZeroWord)					//除以0
						begin
							status <= `DivByZero;
						end 
						else begin
							status <= `DivOn;
							count <= 6'b0;							//开始计数
							opNum1_temp = (sign == 1'b1 && 
								dividend_i[31] == 1'b1) ? 
								(~dividend_i + 1) : dividend_i;	//有符号运算，则负数取补码
							opNum2_temp = (sign == 1'b1 && 
								divisor_i[31] == 1'b1) ? 
								(~divisor_i + 1) : divisor_i;
							dividend <= {`ZeroWord, `ZeroWord};
							dividend[32:1] <= opNum1_temp;
							divisior <= opNum2_temp;
						end
					end
					else begin
						result <= {`ZeroWord, `ZeroWord};
						finish <= `NotFinish;
					end
				end
				`DivByZero:											//除以0，结果赋0
				begin
					dividend <= {`ZeroWord, `ZeroWord};
					status <= `DivEnd;
				end
				`DivOn:
				begin
					if (count != 6'd32) 
					begin
						dividend <= (res_temp[32] == 1'b1) ?
							{dividend[63:0], 1'b0} : 
							{res_temp[31:0], dividend[31:0], 1'b1};
						count <= count + 1;
					end
					else begin 										//除法结束
						if(sign == 1'b1)							//有符号运算需要调整结果
						begin
							if((dividend_i[31]^divisor_i[31]) == 1'b1)	//一正一负需要取补码
							begin
								dividend[31:0] <= ~dividend[31:0] + 1; 
							end
							if((dividend_i[31]^dividend[64]) == 1'b1)		//
							begin
								dividend[64:33] <= ~dividend[64:33] + 1;
							end
						end
						status <= `DivEnd;
						count <= 6'b0;
					end
				end
				`DivEnd:
				begin
					result <= {dividend[64:33], dividend[31:0]};	//高32位余数，低32位商
					finish <= `Finish;
					if(start == 1'b0)
					begin
						status <= `DivFree;
						finish <= `NotFinish;
						result <= {`ZeroWord, `ZeroWord};
					end
				end
				default: begin
				end
			endcase
		end
	end

endmodule
