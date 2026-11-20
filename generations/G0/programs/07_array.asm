; G0.02 — byte array traversal with indexed addressing.
; Sum five byte-sized elements: 1 + 2 + 3 + 4 + 5 = 15.
; The result is returned as the process exit status.

default rel

section .rodata
values: db 1, 2, 3, 4, 5
values_count equ 5

section .text
global _start

_start:
    xor ecx, ecx            ; index = 0
    xor eax, eax            ; sum = 0

.sum_loop:
    cmp ecx, values_count
    jge .done

    movzx edx, byte [values + rcx]
    add eax, edx
    inc ecx
    jmp .sum_loop

.done:
    mov edi, eax
    mov eax, 60
    syscall
