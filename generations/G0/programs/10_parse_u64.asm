; G0.05 — parse one line of unsigned decimal input.
; Accepts 1–20 decimal digits, followed by newline or EOF.
; Rejects non-digits and values above UINT64_MAX.
; Success: process exit status is the low 8 bits of the parsed value.
; Invalid input/overflow: exit status 1. Read error: exit status 2.

default rel

section .bss
buffer: resb 20
input_char: resb 1

section .text
global _start

_start:
    xor r8d, r8d                    ; number of digits collected

.read_next:
    ; read(0, &input_char, 1)
    xor eax, eax
    xor edi, edi
    lea rsi, [input_char]
    mov edx, 1
    syscall

    cmp rax, -4                     ; EINTR: retry
    je .read_next
    test rax, rax
    js .read_error
    jz .parse                       ; EOF terminates the input line

    mov al, [input_char]
    cmp al, 10                      ; newline terminates the input line
    je .parse

    cmp r8, 20
    jae .invalid                    ; more than 20 digits
    mov [buffer + r8], al
    inc r8
    jmp .read_next

.parse:
    test r8, r8
    jz .invalid                     ; empty line is not a number

    xor ecx, ecx                    ; current character index
    xor eax, eax                    ; accumulated unsigned value
    mov r10, 10

.parse_digit:
    cmp rcx, r8
    je .success

    movzx edx, byte [buffer + rcx]
    cmp dl, '0'
    jb .invalid
    cmp dl, '9'
    ja .invalid
    sub edx, '0'
    mov r11, rdx                    ; preserve digit across MUL

    ; accumulator = accumulator * 10 + digit
    mul r10                         ; RDX:RAX = RAX * 10
    test rdx, rdx
    jnz .invalid                    ; high half means multiplication overflow
    add rax, r11
    jc .invalid                     ; addition overflow

    inc rcx
    jmp .parse_digit

.success:
    mov edi, eax                    ; shell observes the low 8 bits
    mov eax, 60
    syscall

.invalid:
    mov edi, 1
    mov eax, 60
    syscall

.read_error:
    mov edi, 2
    mov eax, 60
    syscall
