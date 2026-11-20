# Project Charter

## Mission

Build and deliver a complete, runnable, guided laboratory in which the learner
experiences the engineering progression from machine-level programming toward
a compact C-like systems language, under the thought experiment that C does not
yet exist.

## Roles

- **Maintainer / lab author:** ChatGPT. Responsible for research, design, code,
  build artifacts, tests, documentation, repository maintenance, and progress
  records.
- **Learner / end user:** Abel. Runs the supplied lab, follows explanations,
  observes behavior, reads source with guidance, and chooses whether to try
  optional experiments.

The learner is not the implementation workforce. Core artifacts must be
complete before a lesson asks the learner to use them.

## Learning outcomes

By the end, the learner should be able to explain and demonstrate:

- How an assembler, linker, loader, runtime, interpreter, and compiler differ.
- How machine words, bytes, addresses, and memory layout constrain language design.
- How variables, expressions, control flow, functions, arrays, and pointers can
  be represented and implemented.
- How a small language can be translated into assembly and native machine code.
- What self-hosting means, what it proves, and what it does not prove.
- Which parts of the journey parallel the historical B-to-C transition and
  which are modern teaching adaptations.

## Scope boundaries

In scope:
- A progression of small, deliberately limited languages.
- NASM implementations of interpreters, compilers, and runtime components.
- Linux x86-64 hosted execution as the initial target.
- Reproducible commands, tests, walkthroughs, and historical context.

Out of scope unless later justified:
- Building a general-purpose operating system or bootloader.
- Recreating a PDP-7/PDP-11 hardware environment as the main lab.
- Requiring the learner to write the compiler or interpreter.
- Adding a graphical IDE or unrelated application framework.

## Integrity rules

1. Never label a modern reconstruction as Ritchie's original implementation.
2. Distinguish historical evidence, reasonable inference, and teaching invention.
3. Keep each generation runnable and preserve earlier versions.
4. Verify commands and expected output against the committed artifacts.
5. Do not claim a stage is complete while its implementation or tests are absent.
6. Record deviations, limitations, and known defects openly.

## Definition of done for a lesson

A lesson is ready when its referenced files exist, the stated commands work in
the documented environment, expected output is verified, the source walkthrough
matches the committed version, and the learner can complete it without writing
missing infrastructure or implementation code.

