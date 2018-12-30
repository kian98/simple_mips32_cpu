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
`define InstValid			1'b0 			//ָ����Ч
`define InstInvalid			1'b1 			//ָ����Ч
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
`define True_v				1'b1 			//��
`define False_v				1'b0 			//��
`define ChipEnable			1'b1 			//оƬʹ���ź���Ч
`define ChipDisable			1'b0 			//оƬʹ���ź���Ч

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


//32λָ���е�ǰ��λ�������ֶ�Operation code
//��Ҫʱ���functȷ��aluOp
`define EXE_AND 			6'b100100
`define EXE_OR 				6'b100101
`define EXE_XOR 			6'b100110
`define EXE_NOR 			6'b100111
`define EXE_ANDI 			6'b001100
`define EXE_ORI 			6'b001101
`define EXE_XORI 			6'b001110
`define EXE_LUI 			6'b001111

`define EXE_SLL 			6'b000000
`define EXE_SLLV 			6'b000100
`define EXE_SRL 			6'b000010
`define EXE_SRLV 			6'b000110
`define EXE_SRA 			6'b000011
`define EXE_SRAV 			6'b000111

`define EXE_NOP 			6'b000000
`define SSNOP 				32'h00000040

`define EXE_SPECIAL_INST 	6'b000000
`define EXE_REGIMM_INST 	6'b000001
`define EXE_SPECIAL2_INST 	6'b011100

//aluOp��ȷ���������
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

`define EXE_NOP_OP			8'b00000000 	//�ղ���