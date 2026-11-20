# Lesson G0.01 — A program starts, does work, and exits

## Objective

By the end of this lesson, you will be able to trace the lifecycle of a tiny Linux x86-64 executable: the kernel transfers control to its entry point, instructions execute, a system call requests a kernel service, and the process terminates with an exit status.

You do not need to write or modify assembly to complete this lesson. All source files and build scripts are supplied.

## 1. Verify the environment

From the repository root, run:

    bash environment/verify.sh

The script checks that the machine is x86-64 and that Bash, Git, NASM, and GNU ld are available. If NASM is missing on Ubuntu, install the required packages:

    sudo apt update
    sudo apt install nasm binutils git

Then rerun the verification script.

## 2. Build the examples

    bash scripts/build-g0.sh

The build process performs two distinct operations for each source file:

1. NASM translates the assembly source into an ELF64 relocatable object file.
2. GNU ld links that object file into an executable.

The generated files are placed in build/g0/. The original source remains under generations/G0/programs/.

## 3. Run the first executable

    ./build/g0/01_exit
    echo $?

Expected shell output for the second command:

    37

The program does not print 37. It passes 37 to the Linux exit system call. The shell reports the process's exit status after the program terminates.

Open generations/G0/programs/01_exit.asm. Trace these three instructions:

- mov eax, 60 selects Linux x86-64 system call number 60 (exit).
- mov edi, 37 places the exit status in the first argument register.
- syscall enters the kernel to perform the requested operation.

There is no main function here. The linker uses _start as the executable entry point. There is no C runtime or C startup code.

## 4. Observe output

    ./build/g0/02_hello

Expected output:

    Hello from NASM!

Open generations/G0/programs/02_hello.asm. The write system call receives:
- rax = 1: system call number for write.
- rdi = 1: file descriptor for standard output.
- rsi = address of the first byte to write.
- rdx = number of bytes.

The string is data in the executable, not a special feature of the terminal. The program asks Linux to write those bytes to file descriptor 1.

This first example assumes the write succeeds and completes in one call. Real I/O code must handle errors and partial writes; we will add that when input/output becomes a language-runtime concern.

## 5. Observe arithmetic and control flow

Run:

    ./build/g0/03_arithmetic
    echo $?
    ./build/g0/04_branch

Expected results:

    42
    equal

In 03_arithmetic.asm, the processor adds two integer values in a register. The result is passed to exit as the process status. The shell exposes only the low eight bits of that status, so this is an observation technique for small values, not a general way to print integers.

In 04_branch.asm, cmp updates the processor flags based on the comparison. je transfers execution to the equal path when the zero flag is set. Otherwise, execution falls through to the different path.

## 6. Observe a function call

Run:

    ./build/g0/05_function
    echo $?

Expected exit status:

    42

Inspect generations/G0/programs/05_function.asm.

This example is deliberately different from a system call. The call instruction pushes a return address on the process stack and transfers control to add_numbers. The function receives its two integer arguments in rdi and rsi, returns its result in rax, and ret returns to the instruction after call.

These argument and return registers belong to the System V AMD64 function calling convention. Linux system calls use a related but different convention. In particular, the fourth system-call argument uses r10, not rcx.

## 7. Run the regression checks

    bash scripts/test-g0.sh

The script rebuilds all examples from the current NASM sources, then checks expected output and exit statuses. A successful run ends with:

    All G0 checks passed.

## Checkpoint

You have now seen five essential machine-level mechanisms:

- Process entry and termination.
- A direct request to the operating-system kernel.
- Integer arithmetic.
- Conditional control flow.
- Function calls, arguments, return values, and the stack.

This is still assembly programming. The next lesson will examine how the machine represents data in memory and why the distinction between an address, a byte, and a machine-sized value matters before we invent our first language.
