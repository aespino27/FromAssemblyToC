; Compute 19 + 23 and expose the result as the process exit status.
; The shell can observe only the low eight bits of the status.

global _start

section .text
_start:
    mov     eax, 19
    add     eax, 23         ; eax = 42

    mov     edi, eax        ; first argument to sys_exit = status
    mov     eax, 60
    syscall
