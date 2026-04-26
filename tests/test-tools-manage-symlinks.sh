#!/usr/bin/env bash
# Test suite for scripts/tools/manage-symlinks.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/manage-symlinks.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== manage-symlinks.sh tests ==="
echo ""

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

touch "$FIXTURE/bughunt-report-2026-01-01T0800.md"
touch "$FIXTURE/bughunt-report-2026-03-15T1200.md"
touch "$FIXTURE/bughunt-report-2026-02-10T0930.md"
touch "$FIXTURE/review-report-2026-03-01T0900.md"

set +e
chosen="$("$TOOL" "$FIXTURE" bughunt)"
rc=$?
set -e
assert "Exit 0 on success" "$([[ "$rc" == "0" ]] && echo true || echo false)"
assert "Latest chosen is the highest-sorted (March 15)" \
    "$([[ "$chosen" == "bughunt-report-2026-03-15T1200.md" ]] && echo true || echo false)"

# Symlink exists and points at chosen target
target="$(readlink "$FIXTURE/bughunt-report-latest.md" 2>/dev/null || echo "")"
assert "bughunt-report-latest.md symlink target matches chosen" \
    "$([[ "$target" == "bughunt-report-2026-03-15T1200.md" ]] && echo true || echo false)"

# Repeat — should be idempotent
"$TOOL" "$FIXTURE" bughunt >/dev/null
target2="$(readlink "$FIXTURE/bughunt-report-latest.md" 2>/dev/null || echo "")"
assert "Idempotent on repeat invocation" \
    "$([[ "$target2" == "bughunt-report-2026-03-15T1200.md" ]] && echo true || echo false)"

# Different kind gets its own latest
"$TOOL" "$FIXTURE" review >/dev/null
rtarget="$(readlink "$FIXTURE/review-report-latest.md" 2>/dev/null || echo "")"
assert "review kind has independent latest" \
    "$([[ "$rtarget" == "review-report-2026-03-01T0900.md" ]] && echo true || echo false)"

# No matches → exit 2
EMPTY="$(mktemp -d)"
trap 'rm -rf "$FIXTURE" "$EMPTY"' EXIT
set +e
"$TOOL" "$EMPTY" bughunt >/dev/null 2>&1
rc=$?
set -e
assert "No matching files → exit 2" "$([[ "$rc" == "2" ]] && echo true || echo false)"

# Bad KIND rejected
set +e
"$TOOL" "$FIXTURE" "BADKind" >/dev/null 2>&1
rc=$?
set -e
assert "Invalid KIND rejected" "$([[ "$rc" == "1" ]] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
