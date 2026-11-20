# Progress Log

## 2026-11-20 — G0 complete; G1 W1 specification committed

### G0 verification
- GitHub Actions run #22 passed on Ubuntu 24.04 with NASM 2.16.01.
- The full build assembled and linked all ten G0 programs.
- The full regression suite passed, including process lifecycle, memory byte
  order, array indexing, multi-buffer I/O, EOF, UINT64_MAX formatting,
  decimal parsing, invalid input, arithmetic overflow, overlong input, and
  empty EOF.
- The CI log ends with **All G0 checks passed.**
- The learner previously validated the original G0.01 batch in the Ubuntu VM.
- G0 is now considered complete as the machine-level foundation.

### G1 design completed
- Added `docs/G1_LANGUAGE_SPEC.md`, defining W1 (Word Language) version 0.1.
- W1 uses one unsigned 64-bit cell per variable and begins with a single
  `main()` block, `auto` declarations, assignment, arithmetic expressions,
  and `print`.
- Defined the grammar, identifier and literal rules, operator precedence,
  arithmetic semantics, variable model, limits, diagnostics, and exclusions.
- Chose a NASM lexer/parser that generates a direct-threaded instruction
  stream, executed by a NASM virtual machine.
- Each threaded instruction record is 16 bytes: an 8-byte NASM handler address
  and an 8-byte operand.
- This deliberately provides a modern teaching analogy to early B threaded
  execution, without claiming to reproduce its exact internal representation.
- Added three W1 source fixtures under `generations/G1/examples/`.
- Added `generations/G1/README.md`, clearly marking the examples as design
  fixtures and the interpreter as not yet implemented.
- Updated the architecture plan to make the W1 execution strategy explicit.

### Next implementation
Implement the W1 interpreter in NASM in dependency order:
1. Bounded source input and lexical analysis.
2. Parser, declaration table, and variable resolution.
3. Expression parsing and direct-threaded instruction generation.
4. Threaded VM handlers and operand stack.
5. Decimal output, diagnostics, and positive/negative regression tests.
6. G1 CI build/test integration.

## 2026-11-20 — G0.05 validated; G0 foundation complete

- Added the decimal parser, boundary-focused lesson, and regression cases for
  0, 42, UINT64_MAX, UINT64_MAX + 1, invalid characters, overlong input,
  empty line, and EOF with zero bytes.
- The first test-harness insertion contained a shell quoting/line-splitting
  error. CI exposed it; the helper was corrected and the full suite then passed.
- GitHub Actions run #22 passed the complete suite, including all G0.05
  boundary cases. Its log ends with **All G0 checks passed.**

## 2026-11-20 — G0.04 validated by CI

- Added unsigned 64-bit integer-to-decimal conversion and its guided lesson.
- GitHub Actions run #8 passed on Ubuntu 24.04, including assembly/linking
  and the complete regression suite for that batch.

## 2026-11-20 — G0.02 and G0.03 validated by CI

- G0.02 added memory sections, load/store, little-endian byte order, and
  indexed byte-array access.
- G0.03 added repeated reads, EOF handling, EINTR retry, partial-write
  handling, and a write-all routine.
- GitHub Actions run #3 passed on Ubuntu 24.04, including environment
  verification, assembly/linking, and all G0.01–G0.03 regression checks.

## 2026-11-20 — G0.01 validated on learner Ubuntu VM

- Learner reported successful environment verification, assembly/linking of
  the initial five programs, and **All G0 checks passed**.
- This is validation on the learner's Ubuntu x86-64 Hyper-V VM.

## 2026-11-20 — Repository bootstrap

- Established the maintainer/learner contract: the maintainer creates and
  maintains all implementation artifacts; the learner follows the supplied
  labs without being asked to implement missing infrastructure.
- Selected Ubuntu x86-64, NASM, GNU ld, Bash, Git, and VS Code.
- Added the project charter, architecture, environment baseline, historical
  notes, G0 examples, build/test scripts, and guided lessons.
- Added GitHub Actions CI to install NASM and run environment verification,
  assembly/linking, and regression checks on pushes and pull requests.

### Current status

**G0 complete and CI-validated. G1 W1 v0.1 language specification and source
fixtures committed. G1 NASM interpreter implementation is the next task.**

