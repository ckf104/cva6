.section .text
.globl _start
_start:
    li sp, 0x10000000 + 0x7000     # Load address of stack_top into sp
    jal ra, main        # Jump to main function