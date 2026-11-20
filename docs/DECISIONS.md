# Technical and Pedagogical Decisions

## D-001 — Maintainer builds; learner consumes

**Date:** 2026-11-20

**Decision:** ChatGPT is responsible for creating and maintaining the lab's
implementations, scripts, documentation, tests, and progress records. The user
is the end user of the lab and is not expected to implement its compiler or
runtime infrastructure.

**Reason:** This is the explicit learning arrangement requested by the user.

## D-002 — Ubuntu x86-64 hosted execution

**Date:** 2026-11-20

**Decision:** Use the user's existing Ubuntu VM under Hyper-V as the primary
environment, targeting Linux x86-64 ELF executables.

**Reason:** It provides a stable native environment for NASM and Linux system
calls without diverting the project into bootloader or operating-system work.

## D-003 — Visual Studio Code

**Date:** 2026-11-20

**Decision:** Use Visual Studio Code as the recommended editor.

**Reason:** The editor is not the learning objective; there is no pedagogical
reason to require Vim.

## D-004 — NASM implementation constraint

**Date:** 2026-11-20

**Decision:** Interpreters, compilers, and runtime components developed for
the lab are to be implemented in NASM assembly. Bash may orchestrate builds
and tests. NASM and GNU ld are allowed foundational tools.

**Reason:** This preserves the user's premise that no existing high-level
language/compiler is available. The distinction between assembler, linker,
loader, and language compiler will be taught explicitly.

