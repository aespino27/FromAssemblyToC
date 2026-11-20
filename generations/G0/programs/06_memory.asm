; G0.02 — initialized data, uninitialized storage, and byte order.
; The qword 0x0102030405060708 is copied into .bss and its eight bytes
; are written to stdout. On x86-64 (little-endian), the byte order is:
; 08 07 06 05 04 03 02 01

default rel

section .data
align 8
initial_value: dq 0x0102030405060708

section .bss
align 8
scratch: resq 1

section .text
global _start

_start:
    ; Load the 64-bit value stored at initial_value into RAX.
    mov rax, [initial_value]

    ; Store those eight bytes into reserved writable memory.
    mov [scratch], rax

    ; write(1, &scratch, 8)
    mov eax, 1
    mov edi, 1
    lea rsi, [scratch]
    mov edx, 8
    syscall

    ; exit(0)
    mov eax, 60
    xor edi, edi
    syscall
