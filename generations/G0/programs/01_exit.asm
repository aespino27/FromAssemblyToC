; Demonstrate process termination and exit status without a C runtime.
; Build: nasm -f elf64 -g -F dwarf 01_exit.asm -o 01_exit.o
; Link:  ld 01_exit.o -o 01_exit

global _start

section .text
_start:
    mov     eax, 60         ; Linux x86-64: sys_exit
    mov     edi, 37         ; status observed by the parent process
    syscall
