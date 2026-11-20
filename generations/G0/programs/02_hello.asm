; Write a byte sequence to standard output, then terminate.
; This program uses Linux system calls directly; no libc is linked.

global _start

section .rodata
message:     db "Hello from NASM!", 10
message_len: equ $ - message

section .text
_start:
    mov     eax, 1          ; sys_write
    mov     edi, 1          ; file descriptor 1 = stdout
    lea     rsi, [rel message]
    mov     edx, message_len
    syscall

    ; For this first example, assume the write succeeds and writes all bytes.
    ; Partial writes and error handling will be introduced with I/O.
    mov     eax, 60         ; sys_exit
    xor     edi, edi        ; status 0
    syscall
