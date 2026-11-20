; G0.03 — copy stdin to stdout using direct Linux system calls.
; read() is repeated until EOF. write_all() handles partial writes and
; retries both read and write when Linux reports EINTR (-4).
; Any other read/write error terminates the process with status 1.

default rel

section .bss
buffer: resb 256

section .text
global _start

_start:
.read_again:
    ; read(0, buffer, sizeof buffer)
    xor eax, eax
    xor edi, edi
    lea rsi, [buffer]
    mov edx, 256
    syscall

    cmp rax, -4             ; -EINTR: retry the read
    je .read_again
    test rax, rax
    js .exit_error          ; any other negative result is an error
    jz .exit_ok             ; zero means end of input

    ; write_all(1, buffer, bytes_read)
    mov rdx, rax
    mov edi, 1
    lea rsi, [buffer]
    call write_all
    test rax, rax
    js .exit_error

    jmp .read_again

.exit_ok:
    xor edi, edi
    mov eax, 60
    syscall

.exit_error:
    mov edi, 1
    mov eax, 60
    syscall

; Input:
;   RDI = file descriptor
;   RSI = address of first byte
;   RDX = number of bytes
; Output:
;   RAX = 0 on success, -1 on error
; Clobbers caller-saved registers only.
write_all:
    mov r8, rdx             ; remaining byte count
    mov r9, rsi             ; current buffer address

.write_again:
    test r8, r8
    jz .write_done

    mov eax, 1              ; SYS_write
    mov rsi, r9
    mov rdx, r8
    syscall

    cmp rax, -4             ; interrupted: retry without losing progress
    je .write_again
    test rax, rax
    jle .write_error        ; error or zero progress

    add r9, rax
    sub r8, rax
    jmp .write_again

.write_done:
    xor eax, eax
    ret

.write_error:
    mov rax, -1
    ret
