#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
SOURCE="$ROOT_DIR/generations/G1/w1_interpreter.asm"
BUILD_DIR="$ROOT_DIR/build/g1"
OUTPUT="$BUILD_DIR/w1"
for tool in nasm ld; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required tool not found: %s\n' "$tool" >&2
        exit 127
    fi
done
mkdir -p "$BUILD_DIR"
printf 'Assembling %s\n' "$SOURCE"
nasm -f elf64 -g -F dwarf "$SOURCE" -o "$BUILD_DIR/w1_interpreter.o"
printf 'Linking W1 interpreter\n'
ld -o "$OUTPUT" "$BUILD_DIR/w1_interpreter.o"
printf 'G1 build complete: %s\n' "$OUTPUT"
