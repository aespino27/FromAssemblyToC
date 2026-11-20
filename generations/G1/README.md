# G1 — W1 Word Language

G1 defines W1, the first deliberately small word-oriented language in the lab.
Its design is documented in [the W1 language specification](../../docs/G1_LANGUAGE_SPEC.md).

## Status

**Specification and conformance fixtures committed; interpreter not yet implemented.**

The files under examples/ are source fixtures for the specified language.
They are not executable until the NASM interpreter and G1 build/test scripts
are added. Do not treat this generation as runnable yet.

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

## Planned implementation

1. Implement bounded source input and lexical analysis.
2. Implement the parser, declaration table, and expression code generation.
3. Implement the threaded VM and arithmetic handlers.
4. Implement print/output and diagnostics.
5. Add positive and negative regression fixtures and CI coverage.
