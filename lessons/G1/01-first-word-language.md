# Lesson G1.01 — Your first word-oriented language

## Objective

Run W1 programs and inspect the complete path from source text to execution:

    W1 source -> NASM lexer/parser -> threaded instructions -> NASM VM -> output

The interpreter is supplied. You are not expected to implement any part of it.

## Prerequisites

- G0 complete.
- Ubuntu x86-64 VM with NASM and GNU ld.
- Git available.
- Repository checked out locally.

The recorded primary learner baseline is Ubuntu 26.04.1 LTS, NASM 3.01,
and GNU ld 2.46. CI also checks compatibility with Ubuntu 24.04 / NASM 2.16.01.

## 1. Update the repository

From the repository root:

    git pull

## 2. Verify the environment

    bash environment/verify.sh

The command should report the required tools and end with an environment
verification success message. GCC and GDB are optional; neither is needed
to build or run W1.

## 3. Build the interpreter

    bash scripts/build-g1.sh

The build creates:

- build/g1/w1_interpreter.o — NASM ELF64 object file.
- build/g1/w1 — standalone Linux executable.

The implementation is in generations/G1/w1_interpreter.asm. It uses Linux
system calls directly; it does not link libc or use GCC.

## 4. Run the canonical program

    build/g1/w1 < generations/G1/examples/01_arithmetic.w1

Expected output:

    42

Run the other supplied examples:

    build/g1/w1 < generations/G1/examples/02_precedence.w1
    build/g1/w1 < generations/G1/examples/03_reassignment.w1

Expected outputs, respectively:

    14
    20

and:

    7
    42

## 5. Run the regression suite

    bash scripts/test-g1.sh

The script rebuilds the interpreter before testing. It checks successful
programs and malformed/invalid programs, including arithmetic precedence,
parentheses, associativity, nested expressions, reassignment, zero-initialized
variables, UINT64_MAX, unsigned wraparound, duplicate and undeclared names,
syntax errors, literal overflow, division by zero, identifier limits,
variable limits, and source-buffer limits.

The final line must be:

    All G1 checks passed.

## 6. Inspect the implementation

Open these files in VS Code:

- generations/G1/w1_interpreter.asm — lexer, parser, symbol table, code
  generator, threaded VM, and Linux I/O.
- docs/G1_LANGUAGE_SPEC.md — normative W1 v0.1 language definition.
- generations/G1/examples/ — source programs.
- scripts/build-g1.sh and scripts/test-g1.sh — build and regression harness.

A useful first inspection is the next_token routine, followed by
parse_expression, emit_instruction, and the op_* VM handlers. These
are the major boundaries in the source-to-execution pipeline.

## What this generation establishes

- Source text is not executed directly. It is first tokenized and parsed.
- The parser resolves each variable name to a numeric cell index.
- Expressions are emitted in postfix order.
- Every threaded instruction is a 16-byte record: handler address + operand.
- The VM dispatches indirectly to NASM handlers.
- Variables are unsigned 64-bit cells and begin at zero.
- Arithmetic wraps modulo 2^64; division and remainder are unsigned.
- print converts a 64-bit value to decimal and writes it to stdout.

## Limits and deliberate omissions

W1 v0.1 supports one main() block, declarations, assignments, arithmetic,
parentheses, and print. It has no comments, strings, character types, arrays,
pointers, comparisons, conditionals, loops, or user-defined functions.

Its fixed limits are 4096 source bytes, 31 identifier characters, 64
variables, 256 operand-stack cells, and 512 threaded instructions.

## Checkpoint

G1.01 is complete when the build succeeds and the regression suite ends with
All G1 checks passed. The next generation will be motivated by the
limitations of this word-oriented language; do not add features to W1 ad hoc.
