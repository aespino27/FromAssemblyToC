# Progress Log

## 2026-11-20 — G0.04 implemented; CI validation pending

### Unsigned integer-to-decimal conversion
- Added `generations/G0/programs/09_unsigned_decimal.asm`.
- Implements unsigned 64-bit to decimal ASCII conversion using repeated
  division by 10 and remainder extraction, writing digits backward into a
  buffer.
- Uses a separate `write_all` routine for complete output, including
  partial-write and EINTR handling.
- Demonstrates the full unsigned 64-bit range endpoint by printing
  UINT64_MAX (18446744073709551615).
- Added `lessons/G0/04-integer-to-decimal.md`.
- Added exact byte-for-byte output and exit-status regression checks.

### Verification status
- The GitHub Actions workflow successfully completed its G0 build and
  regression suite on Ubuntu 24.04 for the G0.02/G0.03 batch (run #3,
  commit `4f8f6b4`). Environment verification, assembly/linking, and all
  then-current regression checks passed.
- G0.04 was added after that successful run. Its assembly and new regression
  checks are awaiting the next CI run.
- The learner VM has not yet reported validation of G0.02/G0.03/G0.04 as a
  combined batch.

### Next development
Add the complementary decimal-text-to-integer parser with input validation
and overflow detection. Then specify the first G1 word-oriented language and
its execution model before implementing its NASM interpreter.

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
- GitHub Actions run #3 completed successfully on Ubuntu 24.04. All steps
  passed, including environment verification, assembly/linking, and the
  regression suite for G0.01 through G0.03.
- The learner's Ubuntu VM validation of this expanded batch is still pending.

## 2026-11-20 — G0.01 validated on learner Ubuntu VM

### Validation reported by learner
- `bash environment/verify.sh` completed successfully.
- `bash scripts/build-g0.sh` assembled and linked all five initial G0 programs.
- `bash scripts/test-g0.sh` completed with **All G0 checks passed.**
- This validates the initial G0 program set and scripts in the learner's Ubuntu
  x86-64 Hyper-V VM.

### Verification boundary
- This result is based on the learner's successful execution report.
- No failure was reported, so no corrective code changes were required.

## 2026-11-20 — G0 first implementation batch

### Added
- Five NASM examples covering process exit, stdout, arithmetic, conditional branching, and an internal function call.
- A G0 build script and regression-test script.
- An environment verification script.
- The first complete guided lesson: `lessons/G0/01-program-lifecycle.md`.
- A G0 overview and a clear distinction between Linux system calls and the System V AMD64 function-call convention.

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

**G0.01 validated by learner VM. G0.02 and G0.03 validated by GitHub Actions
on Ubuntu 24.04. G0.04 implemented; CI and learner-VM validation pending.**

