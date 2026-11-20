# Lesson G0.03 — Reliable input and output

## Objective

This lab turns direct Linux I/O into reusable behavior. The program copies standard input to standard output. It does not assume that one `read` or `write` call transfers all requested bytes.

The supplied implementation demonstrates:

- Reading repeatedly until end-of-file (EOF).
- Handling the `EINTR` error by retrying an interrupted system call.
- Handling partial writes by advancing the buffer address and reducing the remaining byte count.
- Treating other errors—and a zero-byte write when data remains—as failures.

No source-code implementation work is required.

## 1. Build and test

From the repository root:

    bash scripts/build-g0.sh
    bash scripts/test-g0.sh

The regression suite now includes an input/output round-trip larger than the 256-byte input buffer. This verifies that the program continues reading and writing across multiple buffer fills.

## 2. Run an interactive test

Run:

    ./build/g0/08_io

Type a few lines, then send EOF:

- In a terminal, press Ctrl+D on an empty line.
- The program should reproduce the text you entered and then exit.

The program reads from file descriptor 0 (standard input) and writes to file descriptor 1 (standard output).

## 3. Run a deterministic test

You can test it without typing:

    printf 'Assembly to C\n' | ./build/g0/08_io

Expected output:

    Assembly to C

The pipe closes after sending its input. Linux then makes `read` return zero, which the program treats as EOF.

## 4. Understand the read loop

Open:

    generations/G0/programs/08_io.asm

The `read` system call is number 0. It receives the input file descriptor, buffer address, and maximum byte count in RDI, RSI, and RDX.

Its return value in RAX has three broad meanings:

- Positive: that many bytes were read.
- Zero: EOF.
- Negative: an error encoded as a negative error number.

A successful read is not required to fill the entire buffer. The program therefore writes exactly the number of bytes returned and then goes back to read again.

Linux reports an interrupted system call as `-EINTR` (numeric value -4 on this ABI). The program retries that operation. Other read errors terminate with exit status 1.

## 5. Understand write_all

The `write` system call is number 1. A common mistake is to assume that a successful call always writes every requested byte. It may write fewer bytes.

The `write_all` routine tracks two pieces of state:

- R9: address of the next byte that still needs to be written.
- R8: number of bytes that still need to be written.

After a positive return value, it advances the address by the number of bytes written and subtracts that count from the remaining length. It continues until no bytes remain.

If the call is interrupted, it retries without changing the address or remaining count. A different error, or a zero-byte result while bytes remain, is treated as failure so the routine cannot loop forever without making progress.

This is a small runtime routine: it gives later language implementations a dependable output primitive instead of embedding fragile one-shot system calls everywhere.

## 6. Check the result

Run:

    bash scripts/test-g0.sh

A successful run ends with:

    All G0 checks passed.

The test includes an input payload larger than the 256-byte buffer, so it checks the repeated-read path as well as exact output preservation.

## Checkpoint

G0 now has examples for process lifecycle, arithmetic, branches, calls, data sections, byte representation, indexed arrays, and basic reliable stream I/O.

The next planned work is to add reusable numeric/text conversion routines and then define the smallest useful G1 word-oriented language. We will not start the language implementation until its machine-level data and I/O foundations are clear.
