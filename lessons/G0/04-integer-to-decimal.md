# Lesson G0.04 — Converting an integer into decimal text

## Objective

The processor stores an integer as a binary value. A terminal, however, displays characters. This lab bridges those representations by converting an unsigned 64-bit integer into a sequence of ASCII decimal digits.

The example uses the largest unsigned 64-bit value:

    18446744073709551615

No source-code implementation work is required.

## 1. Build and test

From the repository root:

    bash scripts/build-g0.sh
    bash scripts/test-g0.sh

The regression suite checks the exact output bytes, including the trailing newline.

## 2. Run the program

    ./build/g0/09_unsigned_decimal

Expected output:

    18446744073709551615

Inspect:

    generations/G0/programs/09_unsigned_decimal.asm

The program begins with:

    mov rax, -1

At the bit level, this places 64 one-bits in RAX. The conversion routine interprets that bit pattern as an unsigned integer, whose decimal value is 18446744073709551615. The same bits would represent -1 if interpreted as a signed two's-complement integer. The bit pattern alone does not specify signedness; the operation and interpretation do.

## 3. Why the conversion works backward

The conversion routine repeatedly divides the unsigned value by 10.

For each division:

- The quotient remains in RAX.
- The remainder is returned in RDX.
- The remainder is between 0 and 9, so adding ASCII '0' produces the corresponding digit character.

The least significant decimal digit is produced first. Therefore, the routine writes digits from the end of the buffer toward the beginning.

For example, the value 1234 produces remainders in this order:

| Division | Quotient | Remainder |
|---|---:|---:|
| 1234 / 10 | 123 | 4 |
| 123 / 10 | 12 | 3 |
| 12 / 10 | 1 | 2 |
| 1 / 10 | 0 | 1 |

Writing those digits backward into the buffer yields the readable sequence 1234.

The routine also handles zero: it executes the division once and emits the digit 0.

## 4. Separate conversion from output

The routine u64_to_ascii does not invoke Linux and does not print anything. It transforms a numeric value into bytes in memory and returns:

- RSI: address of the first digit.
- RDX: number of digits.

The caller then adds the newline to the output length and passes the resulting byte range to write_all. This separation is important: converting a value to text and sending text to an output device are different operations.

The write_all routine uses the same partial-write and EINTR strategy introduced in G0.03.

## 5. Check the result

    bash scripts/test-g0.sh

A successful run ends with:

    All G0 checks passed.

## Checkpoint

You have now seen a complete path from a 64-bit binary value to decimal ASCII text, including the division/remainder algorithm and a reusable conversion routine.

The complementary operation—parsing decimal text into an integer—will be needed before the first language can interpret numeric literals. After that, G0 will have the minimum machine-level facilities needed to begin the first B-like language.
