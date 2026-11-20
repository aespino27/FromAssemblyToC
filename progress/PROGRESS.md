# Progress Log

## 2026-11-20 — G0.05 validated; G0 foundation complete

### Decimal text parser
- Added `generations/G0/programs/10_parse_u64.asm`.
- Reads a line of up to 20 decimal digits, accepts newline or EOF, rejects
  non-digits and empty input, and detects both multiplication and addition
  overflow while accumulating an unsigned 64-bit value.
- Added `lessons/G0/05-decimal-input-parsing.md` with boundary examples.
- Extended the regression suite to cover 0, 42, UINT64_MAX, UINT64_MAX + 1,
  invalid characters, and empty input.

### Verification and correction
- GitHub Actions successfully assembled and linked the new parser source.
- The first regression attempt exposed a defect in the test-script insertion:
  the shell test calls had been split by literal newlines, producing an
  unbound positional-parameter error. The parser itself assembled successfully;
  the failure occurred in the test harness before parser cases could run.
- Rewrote the test helper to pass input as a single argument and append the
  newline inside the helper. The corrected regression script is committed.
- GitHub Actions run #18 passed on Ubuntu 24.04 with the corrected parser
  regression helper. The parser's ordinary value, zero, UINT64_MAX,
  UINT64_MAX + 1, invalid-character, and empty-line cases all passed.
- Added two additional boundary checks (21-digit input and EOF with zero
  bytes). GitHub Actions run #22 passed the complete suite, including these
  additional cases. Its log ends with **All G0 checks passed.**

## 2026-11-20 — G0.04 validated by CI

- Added `09_unsigned_decimal.asm` and
  `lessons/G0/04-integer-to-decimal.md`.
- Converts UINT64_MAX to decimal ASCII by repeated unsigned division by 10,
  writing the digits backward into a buffer.
- Uses a separate write-all routine for reliable output.
- GitHub Actions run #8 passed on Ubuntu 24.04, including environment
  verification, assembly/linking of all G0 programs through G0.04, and the
  complete regression suite for that batch.

## 2026-11-20 — G0.02 and G0.03 validated by CI

- G0.02 added memory sections, load/store, little-endian byte order, and
  indexed byte-array access.
- G0.03 added repeated reads, EOF handling, EINTR retry, partial-write
  handling, and a write-all routine.
- GitHub Actions run #3 passed on Ubuntu 24.04, including environment
  verification, assembly/linking, and all G0.01–G0.03 regression checks.
- The learner VM's validation of G0.02–G0.05 as a combined batch is pending.

## 2026-11-20 — G0.01 validated on learner Ubuntu VM

- Learner reported successful environment verification, assembly/linking of
  the initial five programs, and **All G0 checks passed**.
- This is validation on the learner's Ubuntu x86-64 Hyper-V VM.

## 2026-11-20 — Repository and G0 bootstrap

- Established the maintainer/learner contract: the maintainer creates and
  maintains all implementation artifacts; the learner follows the supplied
  labs without being asked to implement missing infrastructure.
- Selected Ubuntu x86-64, NASM, GNU ld, Bash, Git, and VS Code.
- Added the project charter, architecture, environment baseline, historical
  notes, G0.01 programs, build/test scripts, and first lesson.
- Added GitHub Actions CI to install NASM and run environment verification,
  assembly/linking, and regression checks on pushes and pull requests.

### Current status

**G0.01 validated on learner VM. G0.01–G0.05 all build and pass the complete
regression suite on GitHub Actions Ubuntu 24.04. G0 machine-level foundation
is complete. Next: G1 language specification and interpreter.**

