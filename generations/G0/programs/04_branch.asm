; Compare two values and select one of two output paths.

global _start

section .rodata
equal_message:      db "equal", 10
equal_length:       equ $ - equal_message
different_message:  db "different", 10
different_length:   equ $ - different_message

section .text
_start:
    mov     eax, 7
    mov     ebx, 7
    cmp     eax, ebx
    je      .equal

.different:
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel different_message]
    mov     edx, different_length
    syscall
    jmp     .exit

.equal:
    mov     eax, 1
    mov     edi, 1
    lea     rsi, [rel equal_message]
    mov     edx, equal_length
    syscall

.exit:
    mov     eax, 60
    xor     edi, edi
    syscall
