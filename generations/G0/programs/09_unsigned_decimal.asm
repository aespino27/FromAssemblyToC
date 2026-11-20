; G0.04 — convert an unsigned 64-bit integer to decimal text.
; RAX starts as all one bits (unsigned value 18446744073709551615).
; u64_to_ascii writes digits backward and returns RSI=start, RDX=length.
; write_all sends the complete result, including the newline, to stdout.

default rel

section .bss
buffer: resb 32

section .text
global _start

_start:
    mov byte [buffer + 31], 10       ; trailing newline
    lea rdi, [buffer + 30]           ; last digit position
    mov rax, -1                      ; UINT64_MAX
    call u64_to_ascii

    inc rdx                          ; include newline in output length
    mov edi, 1
    call write_all
    test rax, rax
    js .exit_error

    xor edi, edi
    mov eax, 60
    syscall

.exit_error:
    mov edi, 1
    mov eax, 60
    syscall

; Convert unsigned RAX to decimal ASCII.
; Input:  RAX = unsigned value, RDI = address of final digit slot.
; Output: RSI = first digit, RDX = digit count.
; Clobbers RAX, RCX, RDX, RDI, R9.
u64_to_ascii:
    xor r9d, r9d

.convert_digit:
    xor edx, edx
    mov ecx, 10
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    inc r9
    test rax, rax
    jnz .convert_digit

    lea rsi, [rdi + 1]
    mov rdx, r9
    ret

; Input: RDI=file descriptor, RSI=buffer, RDX=length.
; Output: RAX=0 on success, -1 on error.
write_all:
    mov r8, rdx
    mov r9, rsi

.write_again:
    test r8, r8
    jz .write_done

    mov eax, 1
    mov rsi, r9
    mov rdx, r8
    syscall

    cmp rax, -4
    je .write_again
    test rax, rax
    jle .write_error

    add r9, rax
    sub r8, rax
    jmp .write_again

.write_done:
    xor eax, eax
    ret

.write_error:
    mov rax, -1
    ret
