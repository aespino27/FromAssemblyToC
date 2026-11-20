# Lesson G0.02 — Memory, bytes, words, and arrays

## Objective

This lab makes memory visible as a sequence of bytes. It introduces the distinction between a value and the address where that value is stored, the main NASM data sections, little-endian representation, and indexed access to an array.

No source-code implementation work is required. The examples are supplied.

## 1. Rebuild the complete G0 set

From the repository root:

    bash scripts/build-g0.sh

The build now includes:

- `06_memory.asm`: moves a 64-bit value from initialized data into reserved writable storage, then writes its eight bytes.
- `07_array.asm`: traverses a byte array using an index and calculates its sum.

## 2. Inspect the memory example

Open:

    generations/G0/programs/06_memory.asm

Three sections matter:

- `.data` contains initialized data. Here, `initial_value` reserves eight bytes and gives them an initial bit pattern.
- `.bss` reserves writable storage that starts zero-initialized by the executable loader. `scratch: resq 1` reserves one 8-byte quantity; it does not place eight literal bytes in the file's initialized-data payload.
- `.text` contains executable instructions.

The instruction:

    mov rax, [initial_value]

loads the eight bytes at the address labelled `initial_value` into the register RAX. The brackets mean memory access. By contrast:

    lea rsi, [scratch]

calculates the address of `scratch` and places that address in RSI; it does not load the contents of `scratch`.

This distinction—value versus address—is fundamental to arrays, pointers, function arguments, and ultimately C.

## 3. Observe little-endian byte order

Run:

    ./build/g0/06_memory | od -An -v -t x1

Expected output (spacing may differ):

    08 07 06 05 04 03 02 01

The source initializes the 64-bit value as:

    0x0102030405060708

On x86-64, the least significant byte is stored at the lowest address. Therefore, reading the eight consecutive bytes from low to high address produces `08 07 06 05 04 03 02 01`. This is little-endian representation.

The program writes those eight raw bytes to standard output. They are not eight ASCII characters; `od` displays their numeric hexadecimal values.

## 4. Observe an array

Open:

    generations/G0/programs/07_array.asm

The declaration:

    values: db 1, 2, 3, 4, 5

places five consecutive one-byte elements in read-only data. The loop maintains an index in RCX and a running sum in EAX.

The key instruction is:

    movzx edx, byte [values + rcx]

It reads one byte at the address formed by the base address of `values` plus the index. `movzx` zero-extends that 8-bit value into the 32-bit EDX register. This matters because the sum is performed using a wider register.

Run:

    ./build/g0/07_array
    echo $?

Expected exit status:

    15

The shell exposes the process exit status as a small integer. The program has summed the five array elements and passes the result to Linux when it exits.

## 5. Run the regression checks

    bash scripts/test-g0.sh

The script rebuilds all G0 examples before testing. It checks the earlier process, output, arithmetic, branch, and function examples, as well as the exact byte sequence and array sum introduced here.

A successful run ends with:

    All G0 checks passed.

## Checkpoint

You have now seen:

- Initialized data, reserved zero-initialized storage, and executable code.
- A memory address versus the value stored at that address.
- A 64-bit value represented as eight consecutive bytes.
- Little-endian byte order on x86-64.
- A byte array and indexed memory access.
- Zero-extension when loading a small value into a wider register.

The next G0 lab will make input and output reliable: checking Linux system-call return values, handling partial writes, reading input, and converting numeric values to and from text. Those routines will become the basis of the first language runtime.
