# G0 — Machine-level foundation

G0 is a collection of small Linux x86-64 ELF executables written directly in NASM. There is no C runtime and no high-level language involved.

## Programs

| Source | Demonstrates | Observable result |
|---|---|---|
| 01_exit.asm | Process termination and exit status | Exit status 37 |
| 02_hello.asm | Linux write system call | Prints Hello from NASM! |
| 03_arithmetic.asm | Integer arithmetic in registers | Computes 19 + 23; exits with 42 |
| 04_branch.asm | Comparison and conditional branch | Prints equal |
| 05_function.asm | call, ret, argument and return registers | Function computes 19 + 23; exits with 42 |

## Build and test

From the repository root:

    ./scripts/build-g0.sh
    ./scripts/test-g0.sh

Build outputs are placed under build/g0/ and are not source files.

To run one program and inspect its exit status:

    ./build/g0/01_exit
    echo $?

Expected exit status: 37.

The process exit status is an 8-bit observable value on the shell interface. These examples deliberately use small positive values.

## Execution model

The kernel starts each executable at _start. We link directly with GNU ld, so there is no C startup object and no main function. Linux system calls use rax for the call number and rdi, rsi, rdx, r10, r8, r9 for up to six arguments. The syscall instruction overwrites rcx and r11; the result is returned in rax.

The Linux x86-64 system-call convention is distinct from the System V AMD64 function-call convention. The latter is used by the ordinary function example in 05_function.asm.

These are the first building blocks, not yet a language. G0 gives us a verified machine-level vocabulary from which later generations can be designed.
