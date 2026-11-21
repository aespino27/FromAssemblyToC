#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/g1"
BIN="$BUILD_DIR/w1"
TMP_DIR="$BUILD_DIR/test-tmp"
bash "$ROOT_DIR/scripts/build-g1.sh"
mkdir -p "$TMP_DIR"
failures=0
check_success() {
    local name="$1" source="$2" expected="$3" status
    printf '%s' "$source" > "$TMP_DIR/input"
    printf '%s' "$expected" > "$TMP_DIR/expected"
    set +e
    "$BIN" < "$TMP_DIR/input" > "$TMP_DIR/output" 2> "$TMP_DIR/error"
    status=$?
    set -e
    if [[ "$status" -eq 0 ]] && cmp -s "$TMP_DIR/expected" "$TMP_DIR/output" && [[ ! -s "$TMP_DIR/error" ]]; then
        printf 'PASS %-28s\n' "$name"
    else
        printf 'FAIL %-28s (status %s)\n' "$name" "$status"
        diff -u "$TMP_DIR/expected" "$TMP_DIR/output" || true
        cat "$TMP_DIR/error" >&2
        failures=$((failures + 1))
    fi
}
check_failure() {
    local name="$1" source="$2" status
    printf '%s' "$source" > "$TMP_DIR/input"
    set +e
    "$BIN" < "$TMP_DIR/input" > "$TMP_DIR/output" 2> "$TMP_DIR/error"
    status=$?
    set -e
    if [[ "$status" -ne 0 ]] && [[ ! -s "$TMP_DIR/output" ]] && [[ -s "$TMP_DIR/error" ]]; then
        printf 'PASS %-28s rejected\n' "$name"
    else
        printf 'FAIL %-28s (status %s)\n' "$name" "$status"
        cat "$TMP_DIR/output"
        cat "$TMP_DIR/error" >&2
        failures=$((failures + 1))
    fi
}
check_success "canonical arithmetic" \
'main() {
    auto left, right, result;
    left = 19;
    right = 23;
    result = left + right;
    print result;
}
' \
'42
'
check_success "precedence and parentheses" \
'main() {
    print 2 + 3 * 4;
    print (2 + 3) * 4;
}
' \
'14
20
'
check_success "left associativity" \
'main() {
    print 20 - 5 - 3;
    print 100 / 5 / 2;
    print 29 % 6;
}
' \
'12
10
5
'
check_success "nested expression preservation" \
'main() {
    print 2 * (3 + 4 * (5 - 2));
    print (100 - (20 + 5)) / 3;
}
' \
'30
25
'
check_success "reassignment" \
'main() {
    auto value;
    value = 7;
    print value;
    value = value * 6;
    print value;
}
' \
'7
42
'
check_success "zero initialization" \
'main() {
    auto first, second;
    print first;
    print second + 9;
}
' \
'0
9
'
check_success "UINT64_MAX literal and output" \
'main() { print 18446744073709551615; }
' \
'18446744073709551615
'
check_success "wraparound arithmetic" \
'main() {
    print 18446744073709551615 + 1;
    print 0 - 1;
    print 18446744073709551615 * 2;
}
' \
'0
18446744073709551615
18446744073709551614
'
check_failure "duplicate declaration" 'main() { auto value, value; print value; }'
check_failure "undeclared assignment target" 'main() { missing = 1; }'
check_failure "undeclared expression name" 'main() { print missing; }'
check_failure "missing semicolon" 'main() { print 42 }'
check_failure "malformed expression" 'main() { print 1 + ; }'
check_failure "trailing source" 'main() { print 1; } garbage'
check_failure "literal overflow" 'main() { print 18446744073709551616; }'
check_failure "division by zero" 'main() { print 10 / (3 - 3); }'
check_failure "remainder by zero" 'main() { print 10 % 0; }'
check_failure "reserved identifier" 'main() { auto print; }'
check_failure "identifier over 31 chars" 'main() { auto abcdefghijklmnopqrstuvwxyzabcdef; }'
vars='main() { auto '
for name in $(seq 1 65); do vars+="v${name},"; done
vars="${vars%,}; print 0; }"
check_failure "more than 64 variables" "$vars"
large='main() { print 1; '
while [[ ${#large} -le 4100 ]]; do large+=' '; done
large+='}'
check_failure "source exceeds 4096 bytes" "$large"
if [[ "$failures" -ne 0 ]]; then
    printf '%s G1 test(s) failed.\n' "$failures" >&2
    exit 1
fi
printf 'All G1 checks passed.\n'
