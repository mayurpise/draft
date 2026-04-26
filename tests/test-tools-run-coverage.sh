#!/usr/bin/env bash
# Test suite for scripts/tools/run-coverage.sh (schema-only)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/run-coverage.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== run-coverage.sh tests ==="
echo ""

# Schema-check for each supported language emits valid JSON with required fields.
for lang in python go javascript typescript shell; do
    set +e
    out="$("$TOOL" "$lang" --schema-check)"
    rc=$?
    set -e
    # shell returns 2 even in schema mode; others 0.
    if [[ "$lang" == "shell" ]]; then
        assert "schema-check $lang: exit 2" \
            "$([[ "$rc" == "2" ]] && echo true || echo false)"
    else
        assert "schema-check $lang: exit 0" \
            "$([[ "$rc" == "0" ]] && echo true || echo false)"
    fi
    if command -v jq >/dev/null 2>&1; then
        for f in language tool total per_file; do
            if echo "$out" | jq -e "has(\"$f\")" >/dev/null 2>&1; then
                assert "schema-check $lang: field $f present" "true"
            else
                assert "schema-check $lang: field $f present" "false"
            fi
        done
        if echo "$out" | jq -e '.total | has("lines") and has("branches")' >/dev/null 2>&1; then
            assert "schema-check $lang: total has lines and branches" "true"
        else
            assert "schema-check $lang: total has lines and branches" "false"
        fi
    fi
done

# Unknown language returns invocation error
set +e
"$TOOL" ruby --schema-check >/dev/null 2>&1
rc=$?
set -e
assert "Unknown language exits 1" "$([[ "$rc" == "1" ]] && echo true || echo false)"

# Missing language exits 1
set +e
"$TOOL" --schema-check >/dev/null 2>&1
rc=$?
set -e
assert "Missing language arg exits 1" "$([[ "$rc" == "1" ]] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
