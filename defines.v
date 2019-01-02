//ȫ��
`define RstEnable			1'b1 			//��λ�ź���Ч
`define RstDisable			1'b0 			//��λ�ź���Ч
`define ZeroWord			32'h00000000 	//ȫ��
`define WriteEnable			1'b1 			//дʹ���ź���Ч����д
`define WriteDisable		1'b0 			//дʹ���ź���Ч������д
`define ReadEnable			1'b1 			//��ʹ���ź���Ч���ɶ�
`define ReadDisable			1'b0 			//��ʹ���ź���Ч�����ɶ�
`define AluOpLength			7:0 			//ALU���������
`define AluTypeLength		2:0 			//ALU����ѡ������
`define InstValid			1'b1 			//ָ����Ч
`define InstInvalid			1'b0 			//ָ����Ч
`define InDelaySlot 		1'b1 			//�����ӳٲ���
`define NotInDelaySlot 		1'b0 			//ָ�����ӳٲ���
`define Branch				1'b1
`define NotBranch			1'b0
`define InterruptAssert		1'b1
`define InterruptNotAssert	1'b0
`define TrapAssert			1'b1
`define TrapNotAssert		1'b0
`define True_v				1'b1 			//��
`define False_v				1'b0 			//��
`define ChipEnable			1'b1 			//оƬʹ���ź���Ч
`define ChipDisable			1'b0 			//оƬʹ���ź���Ч

`define StallSignal			5:0 			//stall�źſ��
`define Stop 				1'b1 			//stall stop
`define NotStop 			1'b0 			//stall not stop

//ָ��洢��inst_rom
`define InstAddrBus			31:0 			//ָ��Ĵ�����ַ���߿��
`define InstAddrLength		32				//ÿ��ָ���Ϊ32λÿ��ָ���Ϊ32λ
`define InstBus				31:0 			//ָ��Ĵ����������߿�ȣ�4���ֽ�
`define InstMemSize			131072			//ָ��洢���洢128K��ָ��
`define InstMemSizeLength	17				//��ʾָ��Ĵ�����һ����ַ����Ŀ�ȣ�2^17=131072
											//������ָ��Ĵ�����Сʱ����Ҫ�޸�

//ͨ�üĴ���regfile
`define RegAddrBus			4:0
`define RegBus				31:0			//�Ĵ�����ȣ������߿��
`define RegNum				32				//�Ĵ�������
`define DoubleRegWidth		64
`define DoubleRegBus		63:0
`define RegNumLength		5				//�Ĵ����������õ�ַ��ʾ��Ҫ�������
`define NOPRegAddr			5'b00000

//���ݴ洢��data_ram
`define DataAddrBus 		31:0
`define DataBus 			31:0
`define DataMemNum 			1024
`define DataMemSizeLength 	10
`define ByteWidth 			7:0

//����
`define DivFree 			2'b00
`define DivByZero 			2'b01
`define DivOn 				2'b10
`define DivEnd 				2'b11
`define Finish 				1'b1
`define NotFinish 			1'b0

//32λָ���е�ǰ��λ�������ֶ�Operation code
//���������λfunct
//�����ظ�����Ϊ����Ҫ��һ������shamt���ж�
//�߼�����
`define EXE_AND 			6'b100100
`define EXE_OR 				6'b100101
`define EXE_XOR 			6'b100110
`define EXE_NOR 			6'b100111

//����������
`define EXE_ANDI 			6'b001100
`define EXE_ORI 			6'b001101
`define EXE_XORI 			6'b001110
`define EXE_LUI 			6'b001111

//��λ
`define EXE_SLL 			6'b000000
`define EXE_SLLV 			6'b000100
`define EXE_SRL 			6'b000010
`define EXE_SRLV 			6'b000110
`define EXE_SRA 			6'b000011
`define EXE_SRAV 			6'b000111

//�ƶ�����
`define EXE_MOVN 			6'b001011
`define EXE_MOVZ 			6'b001010
`define EXE_MFHI 			6'b010000
`define EXE_MTHI 			6'b010001
`define EXE_MFLO 			6'b010010
`define EXE_MTLO 			6'b010011

//��������
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
`define EXE_MADD 			6'b000000
`define EXE_MADDU 			6'b000001
`define EXE_MSUB 			6'b000100
`define EXE_MSUBU 			6'b000101

//��תָ��
`define EXE_J 				6'b000010
`define EXE_JAL 			6'b000011
`define EXE_JALR 			6'b001001
`define EXE_JR 				6'b001000

//��ָ֧��
`define EXE_BEQ 			6'b000100
`define EXE_BGEZ 			5'b00001
`define EXE_BGEZAL 			5'b10001
`define EXE_BGTZ 			6'b000111
`define EXE_BLEZ 			6'b000110
`define EXE_BLTZ 			5'b00000
`define EXE_BLTZAL 			5'b10000
`define EXE_BNE 			6'b000101

//���ش洢ָ��
`define EXE_LB 				6'b100000
`define EXE_LBU 			6'b100100
`define EXE_LH 				6'b100001
`define EXE_LHU 			6'b100101
`define EXE_LW 				6'b100011
`define EXE_LWL 			6'b100010
`define EXE_LWR 			6'b100110
`define EXE_SB 				6'b101000
`define EXE_SH 				6'b101001
`define EXE_SW 				6'b101011
`define EXE_SWL 			6'b101010
`define EXE_SWR 			6'b101110

//����ָ��
`define EXE_DIV 			6'b011010
`define EXE_DIVU 			6'b011011

//��ָ��
`define EXE_NOP 			6'b000000

//aluOp��ȷ���������
//���ֽڱ�ָ��һ������8λ
`define EXE_AND_OP			8'b00100100 	//��
`define EXE_ANDI_OP			8'b01011001 	//��������
`define EXE_OR_OP			8'b00100101 	//��
`define EXE_ORI_OP			8'b01011010 	//��������
`define EXE_XOR_OP			8'b00100110 	//���
`define EXE_XORI_OP			8'b01011011 	//���������
`define EXE_NOR_OP			8'b00100111 	//���
`define EXE_LUI_OP			8'b01011100 	//���������ص���λ
`define EXE_SLL_OP			8'b01111100 	//�߼�����
`define EXE_SLLV_OP			8'b00000100 	//�߼��ɱ�����
`define EXE_SRL_OP			8'b00000010 	//�߼�����
`define EXE_SRLV_OP			8'b00000110 	//�߼��ɱ�����
`define EXE_SRA_OP			8'b00000011 	//��������
`define EXE_SRAV_OP			8'b00000111 	//�����ɱ�����
`define EXE_MOVZ_OP			8'b00001010 	//mov if zero
`define EXE_MOVN_OP			8'b00001011 	//mov if not zero
`define EXE_MFHI_OP			8'b00010000 	//mov from hi
`define EXE_MTHI_OP			8'b00010001 	//mov to hi
`define EXE_MFLO_OP			8'b00010010 	//mov from lo
`define EXE_MTLO_OP			8'b00010011 	//mov to lo
//��Ϊ�з��ź��޷�����Ҫ�����Ƿ��������˲����Ժ���
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
`define EXE_MADD_OP 		8'b10100110 	//add hilo after mult
`define EXE_MADDU_OP 		8'b10101000 	//add hilo after mult unsign
`define EXE_MSUB_OP 		8'b10101010 	//sub hilo after mult
`define EXE_MSUBU_OP 		8'b10101011 	//sub hilo after mult unsign
`define EXE_J_OP 			8'b01001111
`define EXE_JAL_OP 			8'b01010000
`define EXE_JALR_OP 		8'b00001001
`define EXE_JR_OP 			8'b00001000
`define EXE_BEQ_OP 			8'b01010001
`define EXE_BGEZ_OP 		8'b01000001
`define EXE_BGEZAL_OP 		8'b01001011
`define EXE_BGTZ_OP 		8'b01010100
`define EXE_BLEZ_OP 		8'b01010011
`define EXE_BLTZ_OP 		8'b01000000
`define EXE_BLTZAL_OP 		8'b01001010
`define EXE_BNE_OP 			8'b01010010
`define EXE_LB_OP 			8'b11100000
`define EXE_LBU_OP 			8'b11100100
`define EXE_LH_OP 			8'b11100001
`define EXE_LHU_OP 			8'b11100101
`define EXE_LW_OP 			8'b11100011
`define EXE_SB_OP 			8'b11101000
`define EXE_SH_OP 			8'b11101001
`define EXE_SW_OP 			8'b11101011
`define EXE_DIV_OP 			8'b00011010
`define EXE_DIVU_OP 		8'b00011011

`define EXE_NOP_OP			8'b00000000 	//�ղ���