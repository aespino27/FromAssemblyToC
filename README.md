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

**G0.01 validated; G0.02 and G0.03 implemented, awaiting learner-VM verification.** The learner
reported that the initial G0 environment, build, and regression checks passed
on 2026-11-20. The repository now contains additional memory/array examples
and a reliable stream-I/O example. The expanded regression script rebuilds
all examples and checks byte layout, array arithmetic, multi-buffer input/output,
and empty input.

The maintainer's execution environment still lacks NASM. The new G0.02 and
G0.03 assembly sources have therefore not yet been assembled or executed by
the maintainer. A GitHub Actions workflow now installs NASM and runs the full
G0 build and regression suite on pushes and pull requests; its first Ubuntu 24.04 run has started, but no
result is available yet. The learner's next run will also validate the expanded
batch on the target Ubuntu VM.

Follow [Lesson G0.01](lessons/G0/01-program-lifecycle.md),
[Lesson G0.02](lessons/G0/02-memory-and-data-representation.md), and
[Lesson G0.03](lessons/G0/03-reliable-linux-io.md) in order. The next planned
work is numeric/text conversion and the design of the first B-like language.

See [the project charter](docs/PROJECT_CHARTER.md),
[architecture and stage plan](docs/ARCHITECTURE.md),
[environment baseline](environment/README.md),
[historical notes](references/HISTORICAL_NOTES.md), and
[progress log](progress/PROGRESS.md).
