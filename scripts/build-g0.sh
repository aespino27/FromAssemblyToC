#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/generations/G0/programs"
BUILD_DIR="$ROOT_DIR/build/g0"

for tool in nasm ld; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required tool not found: %s\n' "$tool" >&2
        exit 127
    fi
done

mkdir -p "$BUILD_DIR"

for source in "$SOURCE_DIR"/*.asm; do
    name="$(basename "$source" .asm)"
    object="$BUILD_DIR/$name.o"
    executable="$BUILD_DIR/$name"

    printf 'Assembling %s\n' "$source"
    nasm -f elf64 -g -F dwarf "$source" -o "$object"

    printf 'Linking    %s\n' "$name"
    ld -o "$executable" "$object"
done

printf 'G0 build complete: %s\n' "$BUILD_DIR"
