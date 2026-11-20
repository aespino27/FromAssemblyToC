# Architecture and Stage Plan

## Design principle

The lab follows a sequence of increasingly expressive programming systems.
Each generation is motivated by a limitation encountered while using the
previous one. We will avoid pretending that this is a line-by-line historical
reconstruction: it is a modern executable thought experiment informed by the
history of B and C.

## Target platform

- x86-64 Linux user space, using the System V AMD64 ABI.
- NASM emits ELF64 object files.
- GNU ld links objects into Linux executables.
- Linux provides process loading and system-call services.

The linker does not translate a high-level language. It combines object files
and resolves symbols/relocations. NASM translates assembly source into object
code. Linux loads the resulting executable. Keeping these roles explicit is
part of the curriculum.

## Historical-to-lab feature matrix

The historical sequence is a design reference, not a set of source-compatible versions. See [Historical Notes](../references/HISTORICAL_NOTES.md) for source-backed detail.

| Concern | B / early Unix context | New B / early C pressure | Lab treatment |
|---|---|---|---|
| Value model | One word/cell; interpretation depends on use | Distinguish character and integer data | G1 begins with one 64-bit cell; G3 introduces explicit widths |
| Memory model | Word-addressed origins | PDP-11 byte addressing makes packed characters awkward | Contrast word-indexed and byte-addressed layouts experimentally |
| Arrays and addresses | Vectors and indirection already present in B | Typed arrays and pointers become important | Introduce address arithmetic before then constrain it with element widths |
| Execution | Early Unix B compiler used threaded code | Direct PDP-11 code generation addresses performance | Demonstrate interpretation first, then native code generation |
| Hardware | PDP-7 18-bit words; PDP-11 16-bit words | Machine features shape representation and code generation | Modern x86-64 is explicitly an adaptation, never presented as historical hardware |

## Proposed generations

These are design milestones, not promises that each will map one-to-one to a
historical language release. Exact syntax and scope will be fixed when each
generation is implemented and tested.

### G0 — Machine-level foundation

NASM programs establish the execution model in a deliberate order: process entry and exit; integer operations, branches, and calls; memory sections, addresses, byte order, and arrays; reliable Linux input/output; and conversion between binary integers and decimal text. The learner runs and inspects supplied programs. G0 is not complete until these foundations and their regression checks have been exercised.

### G1 — A word-oriented symbolic language

Introduce a tiny language whose values and operations are deliberately close
to machine words. The learner uses a supplied NASM implementation to run
programs and sees how names, expressions, and control flow can be represented.

### G2 — A more usable B-like language

Improve notation and composition: structured statements, expressions,
conditionals, loops, and function-like units. The exact feature set will be
kept small enough to explain completely.

### G3 — Types and byte-addressed data

Introduce explicit distinctions such as character-sized and integer-sized
values, arrays, addresses, and pointer-like operations. Explain why a language
that treats everything as a machine word becomes awkward for text and compact
data. Compare the teaching model with the historical New B/C transition.

### G4 — Translation to native code

Move from interpretation or an intermediate representation to a compiler that
emits NASM source or object code. The compiler implementation itself remains
NASM. Show parsing, symbol handling, code generation, assembly, linking, and
execution as separate steps.

### G5 — Self-hosting

Port the compiler into the language it compiles, then use an earlier compiler
to build the newer compiler. Document the bootstrap chain and reproducibility
checks. Self-hosting is a milestone, not proof that the language is equivalent
to C or that its compiler is production-grade.

## Implementation strategy

Prefer the smallest complete vertical slice at each stage. Every generation
will have a defined source format, executable implementation, sample programs,
tests, build/run scripts, and a lesson. Avoid adding features merely because
they are familiar from modern languages.

## Runtime and operating-system boundary

The first stages will use Linux hosted executables. Linux system calls provide
minimal input/output and process services without requiring a C runtime.
Where practical, the lab will make direct system calls from NASM. Any use of
libc or another compiled runtime would require explicit justification and is
not part of the default plan.

## Open design questions for implementation

- Choose a minimal input/output convention for early language programs.
- Decide whether G1 executes source directly or first lowers to a compact
  bytecode. The choice must serve the learning objective, not convenience alone.
- Define the smallest useful grammar and error-reporting strategy.
- Decide the transition point from interpretation to native code generation.
- Establish automated regression tests that run without high-level language
  tooling.

