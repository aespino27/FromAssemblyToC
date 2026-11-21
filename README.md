# From Assembly to C

An executable, guided laboratory exploring how a practical high-level systems
language can emerge from assembly-language foundations.

## Project contract

**The maintainer builds the lab; the learner uses it.**

The learner is not expected to implement the interpreters, compilers, runtimes,
or supporting infrastructure. The maintainer supplies working artifacts,
source code, reproducible build/run instructions, explanations, and checkpoints.
Learner activities focus on running programs, reading and tracing code, observing
behavior, and optionally experimenting with supplied examples.

## Premise

Imagine that C and its descendants do not exist. We have a modern x86-64
computer, NASM, a text editor, and the motivation to make programming more
productive than writing assembly directly.

We will evolve a sequence of small languages and their implementation tools,
using the historical B-to-C transition as an intellectual and pedagogical
reference.

This is **not** a claim to reproduce Dennis Ritchie's exact source code,
toolchain, machine, or chronology. The target machine and implementation
constraints are modern; historical parallels and departures will be documented.

## Initial technical baseline

- Host: Windows 11, with the existing Ubuntu x86-64 Hyper-V virtual machine.
- Working environment: Ubuntu Linux.
- Architecture/ABI: x86-64 Linux.
- Assembler: NASM.
- Linker: GNU ld (used as a linker, not as a compiler).
- Editor: Visual Studio Code.
- Shell and automation: Bash scripts for setup, build, and test orchestration.
- Emulator: QEMU only where a lesson genuinely requires emulation.

We will begin with hosted Linux executables rather than a custom bootloader or
operating system. This keeps the focus on language design, implementation,
runtime representation, and compilation.

## Non-negotiable implementation constraint

The language implementation artifacts (interpreters, compilers, and runtimes)
will be written in NASM assembly. We will not use an existing high-level
language compiler or implementation language to create them.

Shell scripts may orchestrate tools and tests; they are not language
implementations. The assembler and linker are permitted foundational tools.
Any additional tool must be justified and documented.

## Learning model

Each stage should include, as applicable:

1. A working, inspectable implementation supplied by the maintainer.
2. A concise explanation of the problem that motivates the next capability.
3. Exact repository paths and commands.
4. Expected output and ways to verify the result.
5. Guided source walkthroughs, including relevant assembly concepts.
6. A checkpoint recording what works, what changed, and what comes next.

The learner should be able to follow the lab without having to fill in missing
implementation work.

## Planned repository layout

    docs/                 Project design, decisions, historical notes
    environment/          Ubuntu setup and verification
    generations/          Language generations and their implementations
    lessons/              Learner-facing guided lessons
    progress/             Checkpoints, status, and next steps
    references/           Bibliography and source notes
    scripts/              Setup, build, run, and test orchestration

The structure may evolve as the actual artifacts take shape.

## Current status

**G0 machine-level foundation complete.** The learner validated the original G0.01 batch on the Ubuntu VM. GitHub Actions run #22 passed the complete expanded suite on Ubuntu 24.04 with NASM 2.16.01, including all ten programs and regression cases through decimal parsing, overflow detection, overlong input, and empty EOF.

G1 W1 v0.1 is implemented and CI-validated. Its NASM lexer, parser, direct-threaded code generator, and VM passed the full positive/negative regression suite on Ubuntu 24.04 with NASM 2.16.01. The learner's next step is [Lesson G1.01](lessons/G1/01-first-word-language.md), which validates the same implementation on the primary Ubuntu 26.04.1 / NASM 3.01 VM.

Follow [Lesson G0.01](lessons/G0/01-program-lifecycle.md),
[Lesson G0.02](lessons/G0/02-memory-and-data-representation.md),
[Lesson G0.03](lessons/G0/03-reliable-linux-io.md),
[Lesson G0.04](lessons/G0/04-integer-to-decimal.md), and
[Lesson G0.05](lessons/G0/05-decimal-input-parsing.md) in order, then complete [Lesson G1.01](lessons/G1/01-first-word-language.md). G0 and the initial G1 vertical slice are complete.

See [the project charter](docs/PROJECT_CHARTER.md),
[architecture and stage plan](docs/ARCHITECTURE.md),
[environment baseline](environment/README.md),
[historical notes](references/HISTORICAL_NOTES.md), and
[progress log](progress/PROGRESS.md).
