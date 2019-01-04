# simple_mips32_cpu
Based on OpenMIPS@Lei Silei

使用Verilog实现的具有哈佛结构的32位标量处理器，兼容MIPS32 Release 1指令集架构，可使用现有MIPS编译环境。  
具体实现参考《自己动手写CPU》，完成了中前九章的大部分内容，模块的划分和代码思路与书中相同，但具体代码存在差异。

## 主要实现功能：  
> * 五段流水线，取值、译码、执行、访存、写回
> * 指令存储器
> * 数据存储器
> * 高位、低位寄存器
> * 流水线暂停机制
> * 解决数据冲突
> * 支持延迟槽指令
> * 逻辑运算指令
> * 算术运算指令
> * 移位指令
> * 加载存储指令
> * 跳转分支指令  

## 模块连接图 
![pic](https://github.com/kian98/simple_mips32_cpu/raw/master/%E6%A8%A1%E5%9D%97%E8%BF%9E%E6%8E%A5%E5%85%B3%E7%B3%BB%E5%9B%BE.png)

## 使用说明：  
使用 ISE 进行仿真。  
> * 将 `.v` 文件添加到ISE工程中  
> * 在同目录下加入编译完成的16进制指令文件 `inst_rom.data`  
> * 对 TestBench 文件进行仿真
