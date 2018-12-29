//全局
`define RstEnable			1'b1 			//复位信号有效
`define RstDisable			1'b0 			//复位信号无效
`define ZeroWord			32'h00000000 	//全零
`define WriteEnable			1'b1 			//写使能信号有效，可写
`define WriteDisable		1'b0 			//写使能信号无效，不可写
`define ReadEnable			1'b1 			//读使能信号有效，可读
`define ReadDisable			1'b0 			//读使能信号无效，不可读
`define AluOpLength			7:0 			//ALU操作数宽度
`define AluTypeLength		2:0 			//ALU操作选择码宽度
`define InstValid			1'b0 			//指令有效
`define InstInvalid			1'b1 			//指令无效
`define Stop				1'b1
`define NoStop				1'b0
`define InDelaySlot			1'b1
`define NotInDelaySlot		1'b0
`define Branch				1'b1
`define NotBranch			1'b0
`define InterruptAssert		1'b1
`define InterruptNotAssert	1'b0
`define TrapAssert			1'b1
`define TrapNotAssert		1'b0
`define True_v				1'b1 			//假
`define False_v				1'b0 			//真
`define ChipEnable			1'b1 			//芯片使能信号有效
`define ChipDisable			1'b0 			//芯片使能信号无效

//指令存储器inst_rom
`define InstAddrBus			31:0 			//指令寄存器地址总线宽度
`define InstAddrLength		32				//每条指令长度为32位每条指令长度为32位
`define InstBus				31:0 			//指令寄存器数据总线宽度，4个字节
`define InstMemSize			131072			//指令存储器存储128K条指令
`define InstMemSizeLength	17				//表示指令寄存器中一个地址所需的宽度，2^17=131072
											//当扩大指令寄存器大小时，需要修改

//通用寄存器regfile
`define RegAddrBus			4:0
`define RegBus				31:0			//寄存器宽度，即总线宽度
`define RegNum				32				//寄存器个数
`define DoubleRegWidth		64
`define DoubleRegBus		63:0
`define RegNumLength		5				//寄存器个数，用地址表示需要的最大宽度
`define NOPRegAddr			5'b00000


//指令，32位指令中的前六位操作码
//必要时结合funct确定aluOp
`define EXE_ORI				6'b001101 		//ori指令码
`define EXE_NOP				6'b000000


//aluOp，确定具体操作
`define EXE_OR_OP			8'b00100101
`define EXE_ORI_OP			8'b01011010
`define EXE_NOP_OP			8'b00000000

//aluType，操作总共分为
`define EXE_LOGIC_T			3'b001 			//逻辑操作
`define EXE_NOP_T			3'b000 			//无操作，NOP
