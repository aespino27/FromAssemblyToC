; Demonstrate an ordinary internal function using the System V AMD64
; integer argument/return registers: rdi, rsi -> rax.
; This is NOT a system call. The call/ret instructions use the user stack.

global _start

section .text
_start:
    mov     edi, 19
    mov     esi, 23
    call    add_numbers

    ; Function result is returned in rax.
    mov     edi, eax
    mov     eax, 60
    syscall

; uint64_t add_numbers(uint64_t a, uint64_t b)
add_numbers:
    lea     rax, [rdi + rsi]
    ret
