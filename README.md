# RISC-V 五级流水线 CPU（Basys3）

当前版本是运行在 Basys3 FPGA 上的单发射、五级流水线 RISC-V 课程项目。使用 Vivado 2019.1，器件为 `xc7a35tcpg236-1`。包含流水线相关处理、乘法运算、板上开关输入、数码管显示，以及用 C 编译的 24 节点最短路径演示。支持RISCV整数指令和乘法指令

## 文件

- `RISCV_CPU.xpr`：Vivado 工程；顶层为 `top`。
- `RISCV_CPU.srcs/sources_1/new/`：RTL 和板上烧录的 `riscvtest.txt` 指令镜像。
- `RISCV_CPU.srcs/constrs_1/new/basys3_display.xdc`：Basys3 引脚和时钟约束。
- `RISCV_CPU.srcs/sim_1/new/tb_cpu.v`：最短路径功能与周期数仿真；`tb_all.v` 用于指令测试。
- `software/shortest_path.c`、`startup.S`、`build_shortest_path.ps1`：C 程序、启动入口和编译脚本。
- `software/shortest_path_riscvtest.txt`：供 Vivado 仿真读取的机器码，与当前板上指令镜像一致。

## 编译并更新指令镜像

需要 Windows PowerShell 和 `riscv-none-elf-gcc` 工具链。于工程根目录执行：

```powershell
.\software\build_shortest_path.ps1 -ToolBin 'D:\path\to\riscv-toolchain\bin'
```

脚本生成 `software/shortest_path_riscvtest.txt`、ELF、BIN 和反汇编，检查程序不含当前方案未使用的除法/取余指令。重新生成 bitstream 前，将生成的文本镜像复制到 `RISCV_CPU.srcs/sources_1/new/riscvtest.txt`。Vivado 综合从后一个文件初始化指令存储器；仅更新 C 文件或运行仿真不会更新已经生成的 bitstream。

## 仿真和上板

在 Vivado 中打开 `RISCV_CPU.xpr`，设 `tb_cpu` 为仿真顶层，运行 `Run All`。测试比较 Floyd–Warshall 参考结果与 CPU 运行 Dijkstra 的输出，并打印各起点周期数。若 Vivado 未找到 `shortest_path_riscvtest.txt`，将 `software/shortest_path_riscvtest.txt` 加入仿真源并标记为 Memory Initialization File。

板上先用 `SW6:0` 选择起点并按住复位，再松开复位等待 LED0 亮。随后 `SW4:0` 选择终点（0–23）；`SW8:7` 选择数码管显示：`00` 起点、`01` 起点到终点距离、`10` 运行时间（微秒）、`11` 全部 24 个节点的最短距离总和。详细验证数据和内存映射见 [software/SHORTEST_PATH.md](software/SHORTEST_PATH.md)。

当前指令镜像下，起点 0、终点 16 的板上演示结果为距离 4、总和 508、约 736 微秒。当前板上时钟为 50 MHz；在变更设计或编译选项后应重新测量周期数和时序。
