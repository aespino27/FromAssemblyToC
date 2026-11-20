#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/g0"

if [[ ! -x "$BUILD_DIR/01_exit" ]]; then
    bash "$ROOT_DIR/scripts/build-g0.sh"
fi

failures=0

check_status() {
    local program="$1"
    local expected="$2"
    local actual
    set +e
    "$BUILD_DIR/$program" >/dev/null
    actual=$?
    set -e
    if [[ "$actual" -eq "$expected" ]]; then
        printf 'PASS %-18s exit status %s\n' "$program" "$actual"
    else
        printf 'FAIL %-18s expected status %s, got %s\n' "$program" "$expected" "$actual"
        failures=$((failures + 1))
    fi
}

check_output() {
    local program="$1"
    local expected="$2"
    local actual
    actual="$("$BUILD_DIR/$program")"
    if [[ "$actual" == "$expected" ]]; then
        printf 'PASS %-18s output matches\n' "$program"
    else
        printf 'FAIL %-18s expected <%s>, got <%s>\n' "$program" "$expected" "$actual"
        failures=$((failures + 1))
    fi
}

check_status 01_exit 37
check_output 02_hello "Hello from NASM!"
check_status 02_hello 0
check_status 03_arithmetic 42
check_output 04_branch "equal"
check_status 04_branch 0
check_status 05_function 42

if [[ "$failures" -ne 0 ]]; then
    printf '%s G0 test(s) failed.\n' "$failures" >&2
    exit 1
fi

printf 'All G0 checks passed.\n'
