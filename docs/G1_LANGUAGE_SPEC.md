# G1 Language Specification — W1 (Word Language), version 0.1

## 1. Status and naming

W1 is the first language designed for this laboratory. It is a deliberately
small, word-oriented language inspired by the design pressures and execution
approach of historical B.

W1 is **not** the historical B language, a recovered B implementation, or a
claim about the exact syntax Dennis Ritchie used. Its syntax and runtime are
modern teaching choices. The working name W1 means “Word Language, generation 1”.

This document defines the initial implementation target. Any later change to
syntax or semantics must be recorded as a versioned language decision.

## 2. Design objective

The first language should demonstrate the minimum complete path from source
text to execution:

1. Read source text.
2. Recognize tokens.
3. Parse declarations, statements, and expressions.
4. Resolve variable names to word-cell indexes.
5. Generate a compact threaded instruction stream.
6. Execute that stream in a NASM virtual machine.
7. Convert numeric results to decimal text and write them to stdout.

The learner uses the supplied interpreter. The interpreter, lexer, parser,
threaded-code generator, and runtime are implemented in NASM—not C, Python,
or another high-level language.

## 3. Example program

The canonical first program is:

    main() {
        auto left, right, result;

        left = 19;
        right = 23;
        result = left + right;

        print result;
    }

Expected output:

    42

The examples under `generations/G1/examples/` are specification fixtures.
They become runnable when the G1 interpreter and scripts are implemented.

## 4. Lexical rules

### 4.1 Character set and whitespace

- Source is ASCII.
- Space, horizontal tab, carriage return, and line feed are whitespace.
- Whitespace may appear between tokens.
- A semicolon is required after each declaration and statement.
- Comments are not part of W1 version 0.1.

### 4.2 Identifiers

An identifier matches:

    [A-Za-z_][A-Za-z0-9_]*

Identifiers are case-sensitive and may contain at most 31 characters.
The following words are reserved and cannot be identifiers:

- `main`
- `auto`
- `print`

### 4.3 Integer literals

- Integer literals contain decimal digits only.
- The value range is 0 through 18446744073709551615 (UINT64_MAX).
- A literal outside that range is a compile-time error.
- Signs are operators, not part of an integer literal; unary plus and minus
  are not included in version 0.1.

## 5. Grammar

The grammar below is normative for W1 version 0.1. It is written in EBNF-like
notation; whitespace is ignored between tokens.

    program         = "main" "(" ")" block, EOF ;
    block           = "{", declaration*, statement*, "}" ;
    declaration     = "auto", identifier, { ",", identifier }, ";" ;
    statement       = assignment | print_statement ;
    assignment      = identifier, "=", expression, ";" ;
    print_statement = "print", expression, ";" ;

    expression      = additive ;
    additive        = multiplicative, { ("+" | "-"), multiplicative } ;
    multiplicative  = primary, { ("*" | "/" | "%"), primary } ;
    primary         = integer | identifier | "(", expression, ")" ;

Declarations must precede all statements in the single main block. There are
no nested blocks, function definitions, or implicit variable declarations.

The grammar deliberately excludes control flow for the first vertical slice.
Conditionals, loops, and user-defined functions belong to later language
milestones after the basic source-to-threaded-code pipeline is proven.

## 6. Runtime data model

### 6.1 One universal word

Every variable occupies exactly one 64-bit cell. There are no distinct
character, integer, pointer, or floating-point types in W1.0.1.

This is the lab's explicit modern word model. It illustrates the single-cell
design pressure associated with B, but x86-64's 64-bit cells are not the
historical PDP-7 or PDP-11 word sizes.

### 6.2 Variable rules

- Each `auto` declaration allocates one cell in the main activation area.
- Cells are zero-initialized when the program begins.
- Duplicate declarations are compile-time errors.
- Use of an undeclared identifier is a compile-time error.
- The initial implementation supports at most 64 variables.
- Variable identity is resolved during compilation to a numeric cell index.

There is one scope: the body of main. No global variables or nested scopes
exist in W1.0.1.

### 6.3 Arithmetic semantics

All values are unsigned 64-bit words.

- Addition, subtraction, and multiplication wrap modulo 2^64.
- Division and remainder are unsigned operations.
- Division or remainder by zero is a runtime error.
- Comparisons and Boolean values are not included yet.
- There are no signed operations or negative literals in this version.

The modulo-2^64 rule is an explicit machine-oriented teaching choice. It is
not a claim that all historical B implementations had identical overflow
behavior.

### 6.4 Output

The statement:

    print expression;

evaluates the expression, converts the resulting unsigned 64-bit value to
decimal ASCII, and writes it to file descriptor 1 followed by a newline.

`print` is a laboratory built-in. It is not presented as historical B syntax.

## 7. Expression evaluation

Operator precedence, from highest to lowest:

| Operators | Precedence | Associativity |
|---|---:|---|
| `*` `/` `%` | 2 | Left |
| `+` `-` | 1 | Left |

Parentheses override precedence. All binary operators are left-associative.

Examples:

- `2 + 3 * 4` evaluates to 14.
- `(2 + 3) * 4` evaluates to 20.
- `20 - 5 - 3` evaluates to 12.

Expressions are evaluated using a runtime operand stack. The compiler emits
the operands and operations in postfix order.

## 8. Interpreter architecture

### 8.1 Compilation pipeline

The interpreter reads the complete source from standard input into a bounded
source buffer, then performs:

    source bytes
        -> lexer
        -> parser + symbol resolution
        -> direct-threaded instruction stream
        -> virtual-machine execution

The lexer, parser, symbol table, threaded-code generator, VM, and runtime
helpers are all NASM code.

### 8.2 Direct-threaded instruction records

Each generated instruction occupies a fixed 16-byte record:

| Offset | Size | Meaning |
|---:|---:|---|
| 0 | 8 bytes | Address of the NASM handler for this operation |
| 8 | 8 bytes | Immediate value or variable-cell index |

The VM instruction pointer addresses the current record. Dispatch is performed
by an indirect jump through the handler address. A handler performs its
operation, advances the instruction pointer by 16 bytes, and dispatches the
next instruction.

This is a direct-threaded interpreter design. It is chosen because it makes
the relationship between an instruction stream and threaded execution
concrete. It is a modern teaching analogue, **not** a claim to reproduce the
exact representation of the historical B compiler.

### 8.3 Initial instruction set

| Handler | Operand | Stack effect | Meaning |
|---|---|---|---|
| PUSH_CONST | 64-bit value | +1 | Push an integer literal |
| LOAD_VAR | cell index | +1 | Push the selected variable |
| STORE_VAR | cell index | -1 | Pop and store into the selected variable |
| ADD | unused | -1 | Pop two values; push their sum |
| SUB | unused | -1 | Pop two values; push left minus right |
| MUL | unused | -1 | Pop two values; push their product |
| UDIV | unused | -1 | Pop two values; push unsigned quotient |
| UMOD | unused | -1 | Pop two values; push unsigned remainder |
| PRINT | unused | -1 | Pop and print an unsigned decimal value |
| HALT | unused | 0 | Stop execution |

The generated program ends with HALT. There are no jump instructions in
version 0.1 because there are no conditional or looping statements.

### 8.4 Stack and capacity limits

The initial interpreter uses fixed-size storage to keep memory management
visible and deterministic:

- Source buffer: 4096 bytes.
- Identifier length: 31 characters.
- Variable cells: 64.
- Operand stack: 256 64-bit entries.
- Threaded instruction records: 512.

Exceeding a limit must produce a controlled diagnostic and nonzero process
status. Buffer or stack overflow must never silently corrupt adjacent memory.

These are implementation limits, not fundamental language properties. They
may be raised in a later version with a documented change.

## 9. Diagnostics and process behavior

- Source syntax and semantic errors are reported to standard error (fd 2).
- Compile-time errors prevent VM execution.
- Division by zero is a runtime error.
- Capacity violations are reported as errors.
- Successful execution exits with status 0.
- Any error exits with a nonzero status.

Exact wording of diagnostics is an implementation detail, but tests will
verify that invalid programs fail and do not produce normal program output.

## 10. Initial conformance fixtures

| File | Purpose | Expected output |
|---|---|---|
| `examples/01_arithmetic.w1` | Variables, assignment, addition | `42` |
| `examples/02_precedence.w1` | Multiplication precedence and parentheses | `14\n20` |
| `examples/03_reassignment.w1` | Reassignment and variable loads | `7\n42` |

Additional negative fixtures will cover duplicate declarations, undeclared
variables, malformed expressions, out-of-range literals, division by zero,
and each fixed-capacity limit.

## 11. Explicit exclusions

W1.0.1 does not include:

- Character or string literals.
- Character-sized or other typed data.
- Arrays, pointers, or explicit addresses in the source language.
- Comparisons or Boolean expressions.
- if, while, goto, or other control flow.
- User-defined functions, parameters, or recursion.
- Dynamic allocation, files, or operating-system APIs.
- A native-code compiler.

These exclusions are deliberate. They leave room for later generations to
introduce capabilities in response to specific limitations.

## 12. Historical relationship

The historical inspiration is the B model's compact procedural syntax,
word-oriented values, and the use of threaded execution in early Unix B
implementations.

The differences are equally important:

- W1 uses 64-bit x86-64 cells, not PDP-7 or PDP-11 words.
- W1 has a deliberately small grammar and only one entry block.
- `print` is a teaching built-in.
- The threaded instruction record format is our own documented design.
- The interpreter is written in NASM for a modern Linux ELF executable.

The next milestone is a complete NASM implementation that accepts the
conformance fixtures and passes positive and negative regression tests.
