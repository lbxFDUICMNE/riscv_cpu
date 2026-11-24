# RISC-V �弶��ˮ�� CPU��Basys3��

��ǰ�汾�������� Basys3 FPGA �ϵĵ����䡢�弶��ˮ�� RISC-V �γ���Ŀ��ʹ�� Vivado 2019.1������Ϊ `xc7a35tcpg236-1`��������ˮ����ش������˷����㡢���Ͽ������롢�������ʾ���Լ��� C ����� 24 �ڵ����·����ʾ����ǰ�汾��δʵ��˫�����̬��֧Ԥ�⣻����ʾ����Ҳû�е��ó�����ȡ��ָ�

## �ļ�

- `RISCV_CPU.xpr`��Vivado ���̣�����Ϊ `top`��
- `RISCV_CPU.srcs/sources_1/new/`��RTL �Ͱ�����¼�� `riscvtest.txt` ָ���
- `RISCV_CPU.srcs/constrs_1/new/basys3_display.xdc`��Basys3 ���ź�ʱ��Լ����
- `RISCV_CPU.srcs/sim_1/new/tb_cpu.v`�����·�����������������棻`tb_all.v` ����ָ����ԡ�
- `software/shortest_path.c`��`startup.S`��`build_shortest_path.ps1`��C ����������ںͱ���ű���
- `software/shortest_path_riscvtest.txt`���� Vivado �����ȡ�Ļ����룬�뵱ǰ����ָ���һ�¡�

## ���벢����ָ���

��Ҫ Windows PowerShell �� `riscv-none-elf-gcc` ���������ڹ��̸�Ŀ¼ִ�У�

```powershell
.\software\build_shortest_path.ps1 -ToolBin 'D:\path\to\riscv-toolchain\bin'
```

�ű����� `software/shortest_path_riscvtest.txt`��ELF��BIN �ͷ���࣬�����򲻺���ǰ����δʹ�õĳ���/ȡ��ָ��������� bitstream ǰ�������ɵ��ı������Ƶ� `RISCV_CPU.srcs/sources_1/new/riscvtest.txt`��Vivado �ۺϴӺ�һ���ļ���ʼ��ָ��洢���������� C �ļ������з��治������Ѿ����ɵ� bitstream��

## ������ϰ�

�� Vivado �д� `RISCV_CPU.xpr`���� `tb_cpu` Ϊ���涥�㣬���� `Run All`�����ԱȽ� Floyd�CWarshall �ο������ CPU ���� Dijkstra �����������ӡ��������������� Vivado δ�ҵ� `shortest_path_riscvtest.txt`���� `software/shortest_path_riscvtest.txt` �������Դ�����Ϊ Memory Initialization File��

�������� `SW6:0` ѡ����㲢��ס��λ�����ɿ���λ�ȴ� LED0 ������� `SW4:0` ѡ���յ㣨0�C23����`SW8:7` ѡ���������ʾ��`00` ��㡢`01` ��㵽�յ���롢`10` ����ʱ�䣨΢�룩��`11` ȫ�� 24 ���ڵ����̾����ܺ͡���ϸ��֤���ݺ��ڴ�ӳ��� [software/SHORTEST_PATH.md](software/SHORTEST_PATH.md)��

��ǰָ����£���� 0���յ� 16 �İ�����ʾ���Ϊ���� 4���ܺ� 508��Լ 736 ΢�롣��ǰ����ʱ��Ϊ 50 MHz���ڱ����ƻ����ѡ���Ӧ���²�����������ʱ��

