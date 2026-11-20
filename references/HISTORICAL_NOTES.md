# Historical Notes: BCPL → B → New B → C

## Purpose and evidence policy

This note records the historical constraints that inform the lab. It is not a complete history of Unix or a claim that our modern exercises reproduce the original implementations.

Evidence labels:
- **Documented:** stated in a primary or near-primary source listed below.
- **Interpretation:** a conclusion drawn from documented facts.
- **Lab adaptation:** a deliberate modern teaching choice, not a historical claim.

## The documented sequence

### BCPL and B

**Documented:** Dennis Ritchie describes B as derived from BCPL, characterizing it as BCPL reduced to fit the PDP-7's severe memory constraints and reshaped by Ken Thompson. Ritchie describes BCPL, B, and C as compact procedural languages oriented toward system programming. Their central data model was a single fixed-size word/cell; the meaning of a bit pattern depended on the operation applied to it.

**Documented:** The PDP-7 environment was extremely constrained: 8K 18-bit words, with little useful software initially available. Thompson wrote the early Unix system in PDP-7 assembly before B was created.

**Documented:** Ken Thompson's January 1972 *Users' Reference to B* describes B on the PDP-11. It specifies 16-bit rvalues on that machine, an intentionally permissive model in which an expression's object kind was inferred from use rather than statically checked, and operators for indirection and address formation. It also documents arrays/vectors, functions, recursion, and compact expression syntax.

### The move to the PDP-11 and the problems exposed

**Documented:** Ritchie explains that BCPL and B had been used on word-addressed machines, where a single cell naturally matched the machine word. The PDP-11 was byte-addressed. B's inherited character-handling approach—packing and unpacking characters through library procedures—became awkward.

**Documented:** Ritchie also identifies performance as a separate problem: the early Unix B compilers generated threaded code, which was too slow for replacing assembly in the operating system and central utilities.

**Interpretation:** The transition was not simply “add types to make a better language.” The target hardware exposed a mismatch between the language's word-oriented memory model and byte-addressed data, while the compiler's execution strategy limited performance. Both representation and implementation strategy had to evolve.

### New B (NB) and early C

**Documented:** Ritchie says that in 1971 he began adding a character type and rewrote the compiler to generate PDP-11 machine instructions instead of threaded code. He called the slightly extended language NB (“new B”). NB was short-lived and had no complete language description.

**Documented:** Ritchie describes embryonic C as adding int and char, arrays of these types, and pointers to them. The evolution continued through 1972–73, with additional language changes; by September 1973 Unix had been translated into C.

**Interpretation:** Language design and compiler design were coupled. The new data model was useful because the target machine exposed byte-level operations, and direct machine-code generation made the resulting language practical for systems work.

## Historical facts versus our reconstruction

| Topic | Historical record | Our lab |
|---|---|---|
| Hardware | PDP-7 then PDP-11, with distinct word sizes and memory models | Modern x86-64 Linux |
| Starting point | Thompson's BCPL-derived B, after early Unix assembly work | NASM examples, then deliberately invented language generations |
| B values | Single word/cell model; context determines interpretation | A controlled word-oriented model, explicitly specified for x86-64 |
| Main pressure toward types | Byte addressing, character handling, and future numeric needs | Demonstrate why one universal machine word becomes awkward |
| Compiler evolution | Threaded-code B implementation, then PDP-11 native-code generation | A small NASM interpreter/compiler progression |
| Historical language | NB was a brief transitional language | Our G1/G2/G3 stages are teaching constructs, not recovered NB versions |
| Bootstrap | Historical compiler development occurred within a working Unix environment | A documented modern bootstrap chain, with each stage preserved |

## Important cautions

1. Do not attribute B's increment/decrement operators to PDP-11 auto-increment addressing: B predates the PDP-11. Ritchie discusses this historical misconception in his paper.
2. Do not say that B was simply “untyped” without qualification. Ritchie and Thompson describe a single word/cell model; the B manual also discusses contextual interpretation and lvalues/rvalues.
3. Do not collapse the performance issue into the type issue. Threaded-code performance and byte-addressed data representation were distinct pressures.
4. Do not call our modern stages “the original B,” “NB,” or “Ritchie's C compiler.” They are controlled teaching analogues.

## Primary and near-primary sources

1. Dennis M. Ritchie, [“The Development of the C Language” (1993)](https://cm-bell-labs.github.io/who/dmr/chist.html). First-person historical account presented at the Second History of Programming Languages conference. This is the principal source for the BCPL/B/C lineage, PDP-7 constraints, word/cell model, PDP-11 problems, NB, and early C.
2. Ken Thompson, [“Users' Reference to B” (January 7, 1972)](https://www.nokia.com/bell-labs/about/dennis-m-ritchie/kbman.html). Original B language reference for the PDP-11, reproduced from the Bell Labs memorandum.
3. S. C. Johnson and B. W. Kernighan, [“The Programming Language B,” Bell Labs CSTR #8 (January 1973)](https://cm-bell-labs.github.io/who/dmr/bintro.html). Contemporary description and tutorial for the Honeywell 6070/MH-TSS implementation; Ritchie's note explains how it relates to Unix B.
4. Dennis M. Ritchie, [“The Evolution of the Unix Time-sharing System”](https://www.bell-labs.com/usr/dmr/www/hist.html). Additional first-person Unix context; secondary to the C-language paper for this lab's specific language-design questions.

## How these sources shape the curriculum

- Begin with the machine's actual execution model, not with anachronistic C syntax.
- Introduce a single-cell abstraction as a design choice, then expose its limitations.
- Treat character data and byte addressing as a representational problem, not merely a syntax feature.
- Teach interpretation/threaded execution and native code generation as different implementation strategies.
- Make the historical and modern machine models explicit at every transition.
