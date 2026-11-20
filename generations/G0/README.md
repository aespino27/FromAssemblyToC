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
| 06_memory.asm | Initialized data, reserved storage, load/store, byte order | Writes bytes 08 07 06 05 04 03 02 01 |
| 07_array.asm | Byte array traversal and indexed addressing | Sums five elements; exits with 15 |\n| 08_io.asm | Repeated reads, partial-write handling, EINTR retry, EOF and errors | Copies stdin to stdout until EOF |\n| 09_unsigned_decimal.asm | Unsigned 64-bit division/remainder and decimal formatting | Prints UINT64_MAX as decimal ASCII |

## Build and test

From the repository root:

    bash scripts/build-g0.sh
    bash scripts/test-g0.sh

The test script always rebuilds the examples before running checks, so it does not silently test stale executables. Build outputs are placed under build/g0/ and are not source files.

To run one program and inspect its exit status:

    ./build/g0/01_exit
    echo $?

Expected exit status: 37.

To inspect the raw bytes emitted by the memory example:

    ./build/g0/06_memory | od -An -v -t x1

Expected byte sequence:

    08 07 06 05 04 03 02 01

The process exit status is an 8-bit observable value on the shell interface. These examples deliberately use small positive values.

## Execution model

The kernel starts each executable at _start. We link directly with GNU ld, so there is no C startup object and no main function. Linux system calls use rax for the call number and rdi, rsi, rdx, r10, r8, r9 for up to six arguments. The syscall instruction overwrites rcx and r11; the result is returned in rax.

The Linux x86-64 system-call convention is distinct from the System V AMD64 function-call convention. The latter is used by the ordinary function example in 05_function.asm.

## Memory model in these examples

- `.rodata`: read-only initialized data, used by the byte array.
- `.data`: initialized writable data, used by the 64-bit initial value.
- `.bss`: zero-initialized writable storage reserved for the copied value.
- `mov reg, [label]`: loads a value from memory.
- `lea reg, [label]`: computes an address.
- `movzx`: loads a narrow integer and zero-extends it to a wider register.

The memory example demonstrates x86-64 little-endian representation by writing the eight bytes of a known 64-bit value. The array example demonstrates indexed byte access and accumulation. The I/O example copies an input stream in 256-byte chunks, retries interrupted system calls, and completes partial writes before reading more data.

These are still machine-level building blocks, not yet a language. G0 gives us a verified vocabulary for designing the value, memory, and runtime models of later generations.
