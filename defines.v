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
`define InstValid			1'b1 			//指令有效
`define InstInvalid			1'b0 			//指令无效
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


//32位指令中的前六位操作码字段Operation code
//必要时结合funct确定aluOp
//逻辑运算
`define EXE_AND 			6'b100100
`define EXE_OR 				6'b100101
`define EXE_XOR 			6'b100110
`define EXE_NOR 			6'b100111

//立即数运算
`define EXE_ANDI 			6'b001100
`define EXE_ORI 			6'b001101
`define EXE_XORI 			6'b001110
`define EXE_LUI 			6'b001111

//移位
`define EXE_SLL 			6'b000000
`define EXE_SLLV 			6'b000100
`define EXE_SRL 			6'b000010
`define EXE_SRLV 			6'b000110
`define EXE_SRA 			6'b000011
`define EXE_SRAV 			6'b000111

//移动传输
`define EXE_MOVN 			6'b001011
`define EXE_MOVZ 			6'b001010
`define EXE_MFHI 			6'b010000
`define EXE_MTHI 			6'b010001
`define EXE_MFLO 			6'b010010
`define EXE_MTLO 			6'b010011

//算数运算
`define EXE_SLT 			6'b101010
`define EXE_SLTU 			6'b101011
`define EXE_SLTI 			6'b001010
`define EXE_SLTIU 			6'b001011
`define EXE_ADD 			6'b100000
`define EXE_ADDU 			6'b100001
`define EXE_SUB 			6'b100010
`define EXE_SUBU 			6'b100011
`define EXE_ADDI 			6'b001000
`define EXE_ADDIU 			6'b001001
`define EXE_CLZ 			6'b100000
`define EXE_CLO 			6'b100001
`define EXE_MULT 			6'b011000
`define EXE_MULTU 			6'b011001
`define EXE_MUL 			6'b000010

//空指令
`define EXE_NOP 			6'b000000

//aluOp，确定具体操作
`define EXE_AND_OP			8'b00100100 	//与
`define EXE_ANDI_OP			8'b01011001 	//与立即数
`define EXE_OR_OP			8'b00100101 	//或
`define EXE_ORI_OP			8'b01011010 	//或立即数
`define EXE_XOR_OP			8'b00100110 	//异或
`define EXE_XORI_OP			8'b01011011 	//异或立即数
`define EXE_NOR_OP			8'b00100111 	//或非
`define EXE_LUI_OP			8'b01011100 	//立即数加载到高位
`define EXE_SLL_OP			8'b01111100 	//逻辑左移
`define EXE_SLLV_OP			8'b00000100 	//逻辑可变左移
`define EXE_SRL_OP			8'b00000010 	//逻辑右移
`define EXE_SRLV_OP			8'b00000110 	//逻辑可变右移
`define EXE_SRA_OP			8'b00000011 	//算数右移
`define EXE_SRAV_OP			8'b00000111 	//算数可变右移
`define EXE_MOVZ_OP			8'b00001010 	//mov if zero
`define EXE_MOVN_OP			8'b00001011 	//mov if not zero
`define EXE_MFHI_OP			8'b00010000 	//mov from hi
`define EXE_MTHI_OP			8'b00010001 	//mov to hi
`define EXE_MFLO_OP			8'b00010010 	//mov from lo
`define EXE_MTLO_OP			8'b00010011 	//mov to lo
`define EXE_SLT_OP 			8'b00101010 	//set if less than
`define EXE_SLTU_OP 		8'b00101011 	//set if less than unsign
`define EXE_SLTI_OP 		8'b01010111 	//slt imm
`define EXE_SLTIU_OP 		8'b01011000 	//slt imm unsign
`define EXE_ADD_OP 			8'b00100000 	//add
`define EXE_ADDU_OP 		8'b00100001 	//add unsign
`define EXE_SUB_OP 			8'b00100010 	//sub
`define EXE_SUBU_OP 		8'b00100011 	//sub unsign
`define EXE_ADDI_OP 		8'b01010101 	//add imm
`define EXE_ADDIU_OP 		8'b01010110 	//add imm unsign
`define EXE_CLZ_OP 			8'b10110000 	//count leading zeros
`define EXE_CLO_OP 			8'b10110001 	//count leading ones
`define EXE_MULT_OP 		8'b00011000 	//mult save to hi&lo
`define EXE_MULTU_OP 		8'b00011001 	//mult unsign 
`define EXE_MUL_OP 			8'b10101001 	//mul save to reg 

`define EXE_NOP_OP			8'b00000000 	//空操作