# Progress Log

## 2026-11-20 — G0 first implementation batch

### Added
- Five NASM examples covering process exit, stdout, arithmetic, conditional branching, and an internal function call.
- A G0 build script and regression-test script.
- An environment verification script.
- The first complete guided lesson: `lessons/G0/01-program-lifecycle.md`.
- A G0 overview and a clear distinction between Linux system calls and the System V AMD64 function-call convention.

### Verification status
- Bash syntax checked for the build script in the maintainer's Debian x86-64 tool environment.
- NASM is not installed in that environment. An attempt to install it did not complete, so the NASM sources have **not** been assembled or executed here.
- The repository test script is supplied, but its passing result is not claimed. The first learner run will validate the actual NASM build on the target Ubuntu VM.

## 2026-11-20 — Repository bootstrap

### Completed
- Confirmed `aespino27/FromAssemblyToC` as the canonical project repository.
- Established the maintainer/learner contract: the maintainer builds all core
  lab artifacts; the learner follows and uses them.
- Selected Ubuntu x86-64 under the existing Windows 11 / Hyper-V setup.
- Selected NASM, GNU ld, Bash, Git, and Visual Studio Code.
- Set hosted Linux executables as the initial execution model; no custom OS or
  bootloader at the outset.
- Added the project charter, architecture outline, environment baseline, and
  this progress log.

### Completed since bootstrap\n- Added source-backed historical notes covering BCPL, B, the PDP-11 transition, NB, and early C.\n- Added a historical-to-lab feature matrix to the architecture plan.\n\n### Not yet implemented
- No NASM lesson artifacts or language implementation exists yet.
- No environment setup script has been validated.
- No language generation is marked complete.

### Next work
1. Research and document the historical B / New B / C design transitions,
   carefully separating primary evidence from modern interpretation.
2. Finalize the language-generation feature matrix and the initial I/O/runtime
   boundary.
3. Implement and test the G0 NASM foundation examples.
4. Add a reproducible environment verification script and first guided lesson.

### Current status

**Project definition: initialized. Lab implementation: not started.**

