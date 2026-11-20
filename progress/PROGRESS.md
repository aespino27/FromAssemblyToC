# Progress Log

## 2026-11-20 — G0.02 and G0.03 implemented; learner verification pending

### G0.02 — Memory and data representation
- Added `generations/G0/programs/06_memory.asm`: initialized `.data`,
  reserved `.bss` storage, 64-bit load/store, and observable little-endian
  byte order.
- Added `generations/G0/programs/07_array.asm`: byte array traversal,
  indexed addressing, zero-extension, and accumulation.
- Added `lessons/G0/02-memory-and-data-representation.md` with exact commands,
  expected bytes, exit status, and explanations.

### G0.03 — Reliable Linux stream I/O
- Added `generations/G0/programs/08_io.asm`: copies standard input to standard
  output until EOF, retries interrupted reads/writes (`EINTR`), handles
  partial writes, and exits with failure on other I/O errors.
- The internal `write_all` routine tracks the next unwritten address and
  remaining byte count; it treats zero progress as an error.
- Added `lessons/G0/03-reliable-linux-io.md` with interactive and deterministic
  usage instructions and a walkthrough of the I/O behavior.

### Regression suite and CI
- The G0 test script now rebuilds all examples on every run, avoiding stale
  binaries.
- It checks the exact byte sequence from the memory example, the array sum,
  a 600-byte input/output round-trip (larger than the 256-byte buffer), and
  empty input/EOF, in addition to all G0.01 checks.
- Added `.github/workflows/g0.yml` to install NASM/binutils and run environment
  verification, the full G0 build, and regression suite on pushes to main and
  pull requests.
- No GitHub Actions run was visible immediately after adding the workflow;
  therefore CI has not yet supplied an independent pass/fail result.
- Bash syntax validation of the expanded test script passed in the maintainer
  environment.
- NASM is unavailable in the maintainer environment. The new NASM programs
  have **not** been assembled or executed by the maintainer. G0.02 and G0.03
  are implemented but await validation in the learner's Ubuntu VM.

### Learner verification
From the repository root:

    git pull
    bash environment/verify.sh
    bash scripts/build-g0.sh
    bash scripts/test-g0.sh

The expanded suite must end with `All G0 checks passed.`

## 2026-11-20 — G0.01 validated on learner Ubuntu VM

### Validation reported by learner
- `bash environment/verify.sh` completed successfully.
- `bash scripts/build-g0.sh` assembled and linked all five initial G0 programs.
- `bash scripts/test-g0.sh` completed with **All G0 checks passed.**
- This validates the initial G0 program set and scripts in the learner's Ubuntu
  x86-64 Hyper-V VM.

### Verification boundary
- This result is based on the learner's successful execution report.
- The maintainer's execution environment still does not have NASM; the
  maintainer has not independently assembled or run these binaries.
- No failure was reported, so no corrective code changes were required.

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
- The learner's subsequent Ubuntu VM validation is recorded above.

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
- Added source-backed historical notes and the historical-to-lab feature matrix.

### Current status

**G0.01 complete and validated on the learner's Ubuntu VM. G0.02 (memory and
arrays) and G0.03 (reliable stream I/O) implemented; expanded assembly/build/test
validation is pending.**

