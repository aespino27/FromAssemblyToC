# G1 — W1 Word Language

G1 defines W1, the first deliberately small word-oriented language in the lab.
Its normative design is documented in [the W1 language specification](../../docs/G1_LANGUAGE_SPEC.md).

## Status

**NASM interpreter, build script, regression suite, and learner lab committed. CI validation is pending.**

The interpreter source is `w1_interpreter.asm`. It implements the bounded
source reader, lexer, recursive-descent parser, symbol table, direct-threaded
code generator, virtual machine, unsigned decimal output, and diagnostics
entirely in NASM. The implementation uses Linux system calls and does not
link libc or invoke GCC.

Do not begin the learner lab until the G1 GitHub Actions workflow passes.

## Build and test

From the repository root:

    bash scripts/build-g1.sh
    bash scripts/test-g1.sh

The build produces `build/g1/w1`. The test script rebuilds before running
positive and negative conformance checks. See
[Lesson G1.01](../../lessons/G1/01-first-word-language.md) for the learner
procedure and expected outputs.

## Design summary

- One universal unsigned 64-bit word per variable.
- One main block with auto declarations, assignment, expressions, and print.
- Decimal literals, parentheses, and conventional arithmetic precedence.
- NASM lexer/parser that generates a direct-threaded instruction stream.
- NASM virtual machine that executes the generated instruction records.
- No C runtime or high-level language implementation component.

The direct-threaded execution model is a modern teaching analogue to the
threaded-code strategy used by early Unix B implementations, not a reproduction
of their original source or internal representation.
