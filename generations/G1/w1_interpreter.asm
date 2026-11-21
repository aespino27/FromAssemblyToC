; G1.01 — W1 v0.1 interpreter.
; Entire language implementation: lexer, recursive-descent parser, threaded-code
; generator, VM, diagnostics, and decimal output. NASM + Linux syscalls only.

default rel

%define TOK_EOF   0
%define TOK_ID    256
%define TOK_NUM   257
%define TOK_MAIN  258
%define TOK_AUTO  259
%define TOK_PRINT 260

%define MAX_SOURCE 4096
%define MAX_VARS   64
%define MAX_CODE   512
%define MAX_STACK  256

section .bss
source_buf:     resb MAX_SOURCE + 1
source_len:     resq 1
source_pos:     resq 1
token_kind:     resq 1
token_value:    resq 1
token_text:     resb 32
number_value:   resq 1
identifier_len: resq 1
symbol_count:   resq 1
symbol_table:   resb MAX_VARS * 32
temp_index:     resq 1
temp_value:     resq 1
operator_kind:  resq 1
instruction_count: resq 1
code_stream:    resb MAX_CODE * 16
variables:      resq MAX_VARS
operand_stack:  resq MAX_STACK
vm_sp:          resq 1
output_buf:     resb 32

section .rodata
msg_syntax: db "W1: syntax or semantic error", 10
len_syntax equ $ - msg_syntax
msg_literal: db "W1: integer literal exceeds UINT64_MAX", 10
len_literal equ $ - msg_literal
msg_capacity: db "W1: implementation capacity exceeded", 10
len_capacity equ $ - msg_capacity
msg_input: db "W1: source input error or source exceeds 4096 bytes", 10
len_input equ $ - msg_input
msg_divzero: db "W1: division or remainder by zero", 10
len_divzero equ $ - msg_divzero
msg_stack: db "W1: invalid operand stack state", 10
len_stack equ $ - msg_stack
msg_output: db "W1: output error", 10
len_output equ $ - msg_output

section .text
global _start

_start:
    call read_source
    call next_token

    EXPECT TOK_MAIN
    EXPECT '('
    EXPECT ')'
    EXPECT '{'

.parse_declarations:
    cmp qword [token_kind], TOK_AUTO
    jne .parse_statements
    call parse_declaration
    jmp .parse_declarations

.parse_statements:
    cmp qword [token_kind], TOK_ID
    je .parse_assignment
    cmp qword [token_kind], TOK_PRINT
    je .parse_print
    jmp .finish_block

.parse_assignment:
    call find_symbol
    cmp rax, -1
    je compile_error
    mov [temp_index], rax
    call next_token
    EXPECT '='
    call parse_expression
    EXPECT ';'
    lea rdi, [rel op_store_var]
    mov rsi, [temp_index]
    call emit_instruction
    jmp .parse_statements

.parse_print:
    call next_token
    call parse_expression
    EXPECT ';'
    lea rdi, [rel op_print]
    xor esi, esi
    call emit_instruction
    jmp .parse_statements

.finish_block:
    EXPECT '}'
    cmp qword [token_kind], TOK_EOF
    jne compile_error
    lea rdi, [rel op_halt]
    xor esi, esi
    call emit_instruction

    xor eax, eax
    mov [vm_sp], rax
    lea r12, [rel code_stream]
.vm_dispatch:
    jmp qword [r12]

; ---------------------------------------------------------------------------
; Source input: read one byte at a time so the exact 4096-byte limit is clear.
; ---------------------------------------------------------------------------
read_source:
    xor r8d, r8d
.read_byte:
    xor eax, eax                    ; read
    xor edi, edi                    ; stdin
    lea rsi, [rel source_buf]
    add rsi, r8
    mov edx, 1
    syscall
    cmp rax, -4                     ; EINTR
    je .read_byte
    test rax, rax
    js input_error
    jz .eof
    cmp r8, MAX_SOURCE
    jae input_error
    inc r8
    jmp .read_byte
.eof:
    mov [source_len], r8
    mov byte [source_buf + r8], 0
    mov qword [source_pos], 0
    ret

; ---------------------------------------------------------------------------
; Lexer. token_kind is ASCII for punctuation, or one of TOK_* above.
; token_text is zero-padded to 32 bytes; identifiers are limited to 31.
; Decimal conversion detects overflow before accepting the next digit.
; ---------------------------------------------------------------------------
next_token:
.skip_space:
    mov rax, [source_pos]
    cmp rax, [source_len]
    jae .eof
    movzx edx, byte [source_buf + rax]
    cmp dl, ' '
    je .advance_space
    cmp dl, 9
    je .advance_space
    cmp dl, 10
    je .advance_space
    cmp dl, 13
    je .advance_space
    jmp .classify
.advance_space:
    inc rax
    mov [source_pos], rax
    jmp .skip_space

.eof:
    mov qword [token_kind], TOK_EOF
    ret

.classify:
    cmp dl, '0'
    jb .identifier_or_punctuation
    cmp dl, '9'
    jbe .number

.identifier_or_punctuation:
    cmp dl, 'A'
    jb .check_lower
    cmp dl, 'Z'
    jbe .identifier
.check_lower:
    cmp dl, 'a'
    jb .check_underscore
    cmp dl, 'z'
    jbe .identifier
.check_underscore:
    cmp dl, '_'
    je .identifier

    ; The grammar only accepts the punctuation characters below.
    cmp dl, '('
    je .punctuation
    cmp dl, ')'
    je .punctuation
    cmp dl, '{'
    je .punctuation
    cmp dl, '}'
    je .punctuation
    cmp dl, ','
    je .punctuation
    cmp dl, ';'
    je .punctuation
    cmp dl, '='
    je .punctuation
    cmp dl, '+'
    je .punctuation
    cmp dl, '-'
    je .punctuation
    cmp dl, '*'
    je .punctuation
    cmp dl, '/'
    je .punctuation
    cmp dl, '%'
    je .punctuation
    jmp compile_error

.punctuation:
    mov [token_kind], rdx
    inc rax
    mov [source_pos], rax
    ret

.number:
    xor r8d, r8d                    ; accumulator
.number_loop:
    mov rax, [source_pos]
    cmp rax, [source_len]
    jae .number_done
    movzx edx, byte [source_buf + rax]
    cmp dl, '0'
    jb .number_done
    cmp dl, '9'
    ja .number_done
    sub edx, '0'
    mov r10, rdx                    ; digit

    ; UINT64_MAX = 1844674407370955161 * 10 + 5.
    mov rax, 1844674407370955161
    cmp r8, rax
    ja literal_error
    jb .accumulate
    cmp r10, 5
    ja literal_error
.accumulate:
    imul r8, r8, 10                 ; safe after the bound check
    add r8, r10
    inc qword [source_pos]
    jmp .number_loop
.number_done:
    mov [token_value], r8
    mov qword [token_kind], TOK_NUM
    ret

.identifier:
    xor r8d, r8d                    ; copied character count
.identifier_loop:
    mov rax, [source_pos]
    cmp rax, [source_len]
    jae .identifier_done
    movzx edx, byte [source_buf + rax]
    cmp dl, 'A'
    jb .id_lower
    cmp dl, 'Z'
    jbe .id_copy
.id_lower:
    cmp dl, 'a'
    jb .id_digit
    cmp dl, 'z'
    jbe .id_copy
.id_digit:
    cmp dl, '0'
    jb .id_underscore
    cmp dl, '9'
    jbe .id_copy
.id_underscore:
    cmp dl, '_'
    jne .identifier_done
.id_copy:
    cmp r8, 31
    jae compile_error
    mov [token_text + r8], dl
    inc r8
    inc qword [source_pos]
    jmp .identifier_loop
.identifier_done:
    mov byte [token_text + r8], 0
    mov [identifier_len], r8
    mov qword [token_kind], TOK_ID

    cmp r8, 4
    jne .check_auto
    cmp dword [token_text], 'main'
    je .keyword_main
.check_auto:
    cmp r8, 4
    jne .check_print
    cmp dword [token_text], 'auto'
    je .keyword_auto
.check_print:
    cmp r8, 5
    jne .identifier_return
    cmp dword [token_text], 'prin'
    jne .identifier_return
    cmp byte [token_text + 4], 't'
    je .keyword_print
.identifier_return:
    ret
.keyword_main:
    mov qword [token_kind], TOK_MAIN
    ret
.keyword_auto:
    mov qword [token_kind], TOK_AUTO
    ret
.keyword_print:
    mov qword [token_kind], TOK_PRINT
    ret

; ---------------------------------------------------------------------------
; Symbol table. One scope, fixed 32-byte zero-padded names.
; find_symbol returns index in RAX or -1.
; declare_current inserts token_text or reports duplicate/capacity.
; ---------------------------------------------------------------------------
find_symbol:
    xor r8d, r8d
.search_symbol:
    cmp r8, [symbol_count]
    jae .not_found
    lea rdi, [rel token_text]
    lea rsi, [rel symbol_table]
    mov rax, r8
    shl rax, 5
    add rsi, rax
    mov ecx, 32
    repe cmpsb
    je .found
    inc r8
    jmp .search_symbol
.found:
    mov rax, r8
    ret
.not_found:
    mov rax, -1
    ret

declare_current:
    call find_symbol
    cmp rax, -1
    jne compile_error
    mov r8, [symbol_count]
    cmp r8, MAX_VARS
    jae capacity_error
    lea rdi, [rel token_text]
    lea rsi, [rel symbol_table]
    mov rax, r8
    shl rax, 5
    add rsi, rax
    mov ecx, 32
    rep movsb
    inc qword [symbol_count]
    ret

parse_declaration:
    call next_token                 ; consume auto
    cmp qword [token_kind], TOK_ID
    jne compile_error
    call declare_current
    call next_token
.declaration_more:
    cmp qword [token_kind], ','
    jne .declaration_end
    call next_token
    cmp qword [token_kind], TOK_ID
    jne compile_error
    call declare_current
    call next_token
    jmp .declaration_more
.declaration_end:
    EXPECT ';'
    ret

; ---------------------------------------------------------------------------
; Recursive-descent expression parser.
; Emits postfix instructions as each operator is reduced.
; ---------------------------------------------------------------------------
parse_expression:
    call parse_additive
    ret

parse_additive:
    call parse_multiplicative
.add_loop:
    mov rax, [token_kind]
    cmp rax, '+'
    je .add_operator
    cmp rax, '-'
    je .sub_operator
    ret
.add_operator:
    mov qword [operator_kind], '+'
    jmp .consume_operator
.sub_operator:
    mov qword [operator_kind], '-'
.consume_operator:
    call next_token
    call parse_multiplicative
    cmp qword [operator_kind], '+'
    je .emit_add
    lea rdi, [rel op_sub]
    jmp .emit_binary
.emit_add:
    lea rdi, [rel op_add]
.emit_binary:
    xor esi, esi
    call emit_instruction
    jmp .add_loop

parse_multiplicative:
    call parse_primary
.mul_loop:
    mov rax, [token_kind]
    cmp rax, '*'
    je .mul_operator
    cmp rax, '/'
    je .div_operator
    cmp rax, '%'
    je .mod_operator
    ret
.mul_operator:
    mov qword [operator_kind], '*'
    jmp .consume_operator
.div_operator:
    mov qword [operator_kind], '/'
    jmp .consume_operator
.mod_operator:
    mov qword [operator_kind], '%'
.consume_operator:
    call next_token
    call parse_primary
    mov rax, [operator_kind]
    cmp rax, '*'
    je .emit_mul
    cmp rax, '/'
    je .emit_div
    lea rdi, [rel op_umod]
    jmp .emit_binary
.emit_mul:
    lea rdi, [rel op_mul]
    jmp .emit_binary
.emit_div:
    lea rdi, [rel op_udiv]
.emit_binary:
    xor esi, esi
    call emit_instruction
    jmp .mul_loop

parse_primary:
    cmp qword [token_kind], TOK_NUM
    je .number
    cmp qword [token_kind], TOK_ID
    je .identifier
    cmp qword [token_kind], '('
    je .parenthesized
    jmp compile_error
.number:
    mov rax, [token_value]
    mov [temp_value], rax
    call next_token
    lea rdi, [rel op_push_const]
    mov rsi, [temp_value]
    call emit_instruction
    ret
.identifier:
    call find_symbol
    cmp rax, -1
    je compile_error
    mov [temp_index], rax
    call next_token
    lea rdi, [rel op_load_var]
    mov rsi, [temp_index]
    call emit_instruction
    ret
.parenthesized:
    call next_token
    call parse_expression
    EXPECT ')'
    ret

; RDI = handler address, RSI = immediate/cell index.
emit_instruction:
    mov rax, [instruction_count]
    cmp rax, MAX_CODE
    jae capacity_error
    shl rax, 4
    lea rdx, [rel code_stream]
    mov [rdx + rax], rdi
    mov [rdx + rax + 8], rsi
    inc qword [instruction_count]
    ret

; ---------------------------------------------------------------------------
; Direct-threaded VM. R12 is the instruction pointer.
; Every handler advances R12 by one 16-byte instruction record.
; ---------------------------------------------------------------------------
op_push_const:
    mov rax, [r12 + 8]
    mov rcx, [vm_sp]
    cmp rcx, MAX_STACK
    jae runtime_stack_error
    mov [operand_stack + rcx * 8], rax
    inc rcx
    mov [vm_sp], rcx
    add r12, 16
    jmp .vm_dispatch

op_load_var:
    mov rcx, [r12 + 8]
    cmp rcx, MAX_VARS
    jae runtime_stack_error
    mov rax, [variables + rcx * 8]
    mov rdx, [vm_sp]
    cmp rdx, MAX_STACK
    jae runtime_stack_error
    mov [operand_stack + rdx * 8], rax
    inc rdx
    mov [vm_sp], rdx
    add r12, 16
    jmp .vm_dispatch

op_store_var:
    mov rcx, [vm_sp]
    test rcx, rcx
    jz runtime_stack_error
    dec rcx
    mov rax, [operand_stack + rcx * 8]
    mov [vm_sp], rcx
    mov rdx, [r12 + 8]
    cmp rdx, MAX_VARS
    jae runtime_stack_error
    mov [variables + rdx * 8], rax
    add r12, 16
    jmp .vm_dispatch

op_add:
    call vm_binary_pop
    add rax, rbx
    jmp vm_binary_push
op_sub:
    call vm_binary_pop
    sub rax, rbx
    jmp vm_binary_push
op_mul:
    call vm_binary_pop
    imul rax, rbx
    jmp vm_binary_push
op_udiv:
    call vm_binary_pop
    test rbx, rbx
    jz division_error
    xor edx, edx
    div rbx
    jmp vm_binary_push
op_umod:
    call vm_binary_pop
    test rbx, rbx
    jz division_error
    xor edx, edx
    div rbx
    mov rax, rdx
    jmp vm_binary_push

; On entry: RAX = left, RBX = right. Stack has already been reduced by one.
vm_binary_push:
    mov rcx, [vm_sp]
    mov [operand_stack + rcx * 8], rax
    inc rcx
    mov [vm_sp], rcx
    add r12, 16
    jmp .vm_dispatch

vm_binary_pop:
    mov rcx, [vm_sp]
    cmp rcx, 2
    jb runtime_stack_error
    dec rcx
    mov rbx, [operand_stack + rcx * 8] ; right
    dec rcx
    mov rax, [operand_stack + rcx * 8] ; left
    mov [vm_sp], rcx
    ret

op_print:
    mov rcx, [vm_sp]
    test rcx, rcx
    jz runtime_stack_error
    dec rcx
    mov rax, [operand_stack + rcx * 8]
    mov [vm_sp], rcx

    lea rdi, [rel output_buf + 31]
    mov byte [rdi], 10
    dec rdi
    xor ecx, ecx
    mov ebx, 10
.convert_digit:
    xor edx, edx
    div rbx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    inc rcx
    test rax, rax
    jnz .convert_digit
    lea rsi, [rdi + 1]
    lea rdx, [rcx + 1]
    mov edi, 1
    call write_all
    jc output_error
    add r12, 16
    jmp .vm_dispatch

op_halt:
    xor edi, edi
    mov eax, 60
    syscall

; write_all(RDI=fd, RSI=buffer, RDX=length), returns CF on failure.
write_all:
    mov r8, rdi
.write_more:
    test rdx, rdx
    jz .write_ok
    mov eax, 1
    mov rdi, r8
    syscall
    cmp rax, -4
    je .write_more
    test rax, rax
    jle .write_fail
    add rsi, rax
    sub rdx, rax
    jmp .write_more
.write_ok:
    clc
    ret
.write_fail:
    stc
    ret

; ---------------------------------------------------------------------------
; Controlled diagnostics. All errors terminate without entering/continuing VM.
; ---------------------------------------------------------------------------
compile_error:
    mov edi, 2
    lea rsi, [rel msg_syntax]
    mov edx, len_syntax
    jmp fatal_error
literal_error:
    mov edi, 2
    lea rsi, [rel msg_literal]
    mov edx, len_literal
    jmp fatal_error
capacity_error:
    mov edi, 2
    lea rsi, [rel msg_capacity]
    mov edx, len_capacity
    jmp fatal_error
input_error:
    mov edi, 2
    lea rsi, [rel msg_input]
    mov edx, len_input
    jmp fatal_error
division_error:
    mov edi, 2
    lea rsi, [rel msg_divzero]
    mov edx, len_divzero
    jmp fatal_error
runtime_stack_error:
    mov edi, 2
    lea rsi, [rel msg_stack]
    mov edx, len_stack
    jmp fatal_error
output_error:
    mov edi, 2
    lea rsi, [rel msg_output]
    mov edx, len_output
    jmp fatal_error

fatal_error:
    call write_all
    mov edi, 1
    mov eax, 60
    syscall

%macro EXPECT 1
    cmp qword [token_kind], %1
    jne compile_error
    call next_token
%endmacro
