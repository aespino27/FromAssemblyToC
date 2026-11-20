#!/usr/bin/env bash
set -euo pipefail

printf 'Checking From Assembly to C lab environment...\n'

if [[ "$(uname -m)" != "x86_64" ]]; then
    printf 'ERROR: expected x86_64; detected %s\n' "$(uname -m)" >&2
    exit 1
fi

missing=0
for tool in bash git nasm ld; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf 'OK      %-8s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf 'MISSING %-8s\n' "$tool"
        missing=$((missing + 1))
    fi
done

if command -v nasm >/dev/null 2>&1; then nasm -v; fi
if command -v ld >/dev/null 2>&1; then ld --version | head -n 1; fi

if [[ "$missing" -ne 0 ]]; then
    printf '\nEnvironment is not ready: %s required tool(s) missing.\n' "$missing" >&2
    printf 'On Ubuntu, install the missing tools with: sudo apt update && sudo apt install nasm binutils git\n' >&2
    exit 1
fi

printf 'Environment checks passed.\n'
