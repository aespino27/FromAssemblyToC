# Progress Log

## 2026-11-20 — G0.01 validated on learner Ubuntu VM

### Validation reported by learner
- `bash environment/verify.sh` completed successfully.
- `bash scripts/build-g0.sh` assembled and linked all five G0 programs.
- `bash scripts/test-g0.sh` completed with **All G0 checks passed.**
- This validates the initial G0 program set and scripts in the learner's Ubuntu
  x86-64 Hyper-V VM.

### Verification boundary
- This result is based on the learner's successful execution report.
- The maintainer's execution environment still does not have NASM; the
  maintainer has not independently assembled or run these binaries.
- No failure was reported, so no corrective code changes were required.

### Next development
Extend G0 in a dependency-aware sequence:
1. Memory sections and representation: `.rodata`, `.data`, `.bss`,
   addresses, bytes, words, little-endian layout, and load/store operations.
2. Addressing and data structures: values versus addresses, indexed access,
   arrays, and pointer-like operations at the machine level.
3. Reliable Linux I/O: read/write system calls, error returns, partial writes,
   and reusable string/integer conversion routines.
4. Only after these foundations are in place, begin the first word-oriented
   B-like language generation.

## 2026-11-20 — G0 first implementation batch

### Added
- Five NASM examples covering process exit, stdout, arithmetic, conditional branching, and an internal function call.
- A G0 build script and regression-test script.
- An environment verification script.
- The first complete guided lesson: `lessons/G0/01-program-lifecycle.md`.
- A G0 overview and a clear distinction between Linux system calls and the System V AMD64 function-call convention.

### Verification status at time of implementation
- Bash syntax checked for the build script in the maintainer's Debian x86-64 tool environment.
- NASM was not installed in that environment, so the NASM sources had not been assembled or executed there.
- The learner's subsequent Ubuntu VM validation is recorded in the section above.

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

### Completed since bootstrap
- Added source-backed historical notes covering BCPL, B, the PDP-11 transition, NB, and early C.
- Added a historical-to-lab feature matrix to the architecture plan.
- Implemented and validated the initial G0 NASM foundation examples and scripts.

### Current status

**G0.01 complete and validated on the learner's Ubuntu VM.** Subsequent G0
memory and I/O labs remain to be developed.

