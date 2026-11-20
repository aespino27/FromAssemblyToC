# Lesson G0.05 — Parsing decimal text into an integer

## Objective

This lab performs the reverse operation from G0.04: it reads decimal characters and constructs an unsigned 64-bit integer.

The parser accepts one line containing 1–20 decimal digits. It rejects non-digits, empty input, more than 20 digits, and values larger than UINT64_MAX. A leading plus/minus sign and surrounding whitespace are intentionally not accepted.

No source-code implementation work is required.

## 1. Build and test

From the repository root:

    bash scripts/build-g0.sh
    bash scripts/test-g0.sh

The regression suite checks ordinary input, the maximum unsigned 64-bit value, invalid characters, overflow, and empty input.

## 2. Try a small value

Run:

    printf '42\n' | ./build/g0/10_parse_u64
    echo $?

Expected exit status:

    42

The program does not print the parsed value. It uses the process exit status as a simple observation mechanism for small values. A shell exposes only the low eight bits of the status, so this technique is not a general way to return a 64-bit result.

## 3. Understand the parser

Open:

    generations/G0/programs/10_parse_u64.asm

The input loop reads one byte at a time until it receives a newline or EOF. It retries an interrupted read. It stores at most 20 characters, matching the maximum number of decimal digits in an unsigned 64-bit value.

For each character, the parser first verifies that it is between ASCII '0' and ASCII '9'. Subtracting ASCII '0' converts the character code into its numeric digit from 0 through 9.

The accumulator is updated using:

    accumulator = accumulator * 10 + digit

This is the positional-value rule for base-10 notation. For example, parsing 427 performs:

- Start with 0.
- Read '4': 0 × 10 + 4 = 4.
- Read '2': 4 × 10 + 2 = 42.
- Read '7': 42 × 10 + 7 = 427.

## 4. Detect overflow

A 64-bit unsigned value cannot exceed 18446744073709551615.

The MUL instruction produces a 128-bit result in RDX:RAX. If RDX is nonzero after multiplying the current accumulator by 10, the result does not fit in 64 bits. The parser rejects it.

Even when multiplication fits, adding the next digit could overflow. The ADD instruction sets the carry flag in that case; the parser checks it and rejects the input.

This is important: checking only the number of digits is insufficient. A 20-digit decimal string can still exceed UINT64_MAX.

## 5. Try boundary cases

The following inputs illustrate the accepted and rejected cases:

| Input | Result |
|---|---|
| 42 | Accepted; exit status 42 |
| 0 | Accepted; exit status 0 |
| 18446744073709551615 | Accepted; exit status 255 (low eight bits) |
| 18446744073709551616 | Rejected; exit status 1 |
| 12x | Rejected; exit status 1 |
| Empty input | Rejected; exit status 1 |

Try the maximum value:

    printf '18446744073709551615\n' | ./build/g0/10_parse_u64
    echo $?

Expected exit status:

    255

The value is accepted. The shell displays 255 because only the low eight bits of the parsed value are returned as the process status.

Try one greater than the maximum:

    printf '18446744073709551616\n' | ./build/g0/10_parse_u64
    echo $?

Expected exit status:

    1

## 6. Run the complete regression suite

    bash scripts/test-g0.sh

A successful run ends with:

    All G0 checks passed.

## Checkpoint

G0 now demonstrates both directions of numeric/text conversion:

- Unsigned 64-bit binary value to decimal ASCII.
- Decimal ASCII to unsigned 64-bit value, with input validation and overflow detection.

These are foundational operations for a language implementation: a lexer/parser must recognize numeric literals, and a runtime needs ways to present numeric results. The next step is to specify G1's word-oriented language model and its smallest useful grammar before implementing its NASM interpreter.
