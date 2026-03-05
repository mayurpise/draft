#!/usr/bin/env bash
# Shared test helpers for all test suites

PASS=0
FAIL=0

assert() {
    local description="$1"
    local result="$2"
    if [[ "$result" == "true" ]]; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $description"
        FAIL=$((FAIL + 1))
    fi
}
