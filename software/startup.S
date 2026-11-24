    .section .text.start,"ax",@progbits
    .globl _start
_start:
    li sp, 4096       // 4 KiB data RAM, stack grows down
    call main
1:
    j 1b
