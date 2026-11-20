#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/g0"

for tool in od tr; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required test utility not found: %s\n' "$tool" >&2
        exit 127
    fi
done

# Always rebuild: tests must exercise the current source, not stale binaries.
bash "$ROOT_DIR/scripts/build-g0.sh"

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

check_hex_bytes() {
    local program="$1"
    local expected="$2"
    local actual
    actual="$("$BUILD_DIR/$program" | od -An -v -t x1 | tr -d ' \n')"
    if [[ "$actual" == "$expected" ]]; then
        printf 'PASS %-18s byte sequence matches\n' "$program"
    else
        printf 'FAIL %-18s expected bytes <%s>, got <%s>\n' "$program" "$expected" "$actual"
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
check_hex_bytes 06_memory "0807060504030201"
check_status 06_memory 0
check_status 07_array 15

check_io_roundtrip() {
    local expected actual
    expected="$(printf '0123456789%.0s' {1..60})"
    actual="$(printf '%s' "$expected" | "$BUILD_DIR/08_io")"
    if [[ "$actual" == "$expected" ]]; then
        printf 'PASS %-18s multi-buffer round-trip\n' "08_io"
    else
        printf 'FAIL %-18s input/output differs\n' "08_io"
        failures=$((failures + 1))
    fi
}

check_io_empty() {
    local actual
    actual="$("$BUILD_DIR/08_io" </dev/null)"
    if [[ -z "$actual" ]]; then
        printf 'PASS %-18s EOF on empty input\n' "08_io"
    else
        printf 'FAIL %-18s expected no output for empty input\n' "08_io"
        failures=$((failures + 1))
    fi
}

check_io_roundtrip
check_io_empty
check_hex_bytes 09_unsigned_decimal "31383434363734343037333730393535313631350a"
check_status 09_unsigned_decimal 0

if [[ "$failures" -ne 0 ]]; then
    printf '%s G0 test(s) failed.\n' "$failures" >&2
    exit 1
fi

printf 'All G0 checks passed.\n'
