#!/usr/bin/env bash
# Test suite for scripts/tools/freshness-check.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/freshness-check.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== freshness-check.sh tests ==="
echo ""

if ! command -v jq >/dev/null 2>&1; then
    echo "SKIP: jq not available"
    exit 0
fi

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

mkdir -p "$FIXTURE/draft/.state" "$FIXTURE/sub"
echo "hello" > "$FIXTURE/sub/a.md"
echo "world" > "$FIXTURE/sub/b.md"

sha_a=$(sha256sum "$FIXTURE/sub/a.md" | awk '{print $1}')
sha_b=$(sha256sum "$FIXTURE/sub/b.md" | awk '{print $1}')

cat > "$FIXTURE/draft/.state/freshness.json" <<EOF
{
  "generated_at": "2026-04-22T10:00:00Z",
  "files": [
    {"path": "sub/a.md", "sha256": "$sha_a"},
    {"path": "sub/b.md", "sha256": "$sha_b"}
  ]
}
EOF

# --- Fresh case ---
set +e
out="$("$TOOL" --root "$FIXTURE")"
rc=$?
set -e
assert "Fresh state → exit 0" "$([[ "$rc" == "0" ]] && echo true || echo false)"
if echo "$out" | jq -e '.fresh == true and .stale_files == [] and .missing_files == []' >/dev/null 2>&1; then
    assert "Fresh JSON has fresh=true, no stale, no missing" "true"
else
    assert "Fresh JSON has fresh=true, no stale, no missing" "false"
fi

# --- Stale case: modify a file ---
echo "changed" > "$FIXTURE/sub/a.md"
set +e
out="$("$TOOL" --root "$FIXTURE")"
rc=$?
set -e
assert "Stale state → exit 2" "$([[ "$rc" == "2" ]] && echo true || echo false)"
if echo "$out" | jq -e '.fresh == false and (.stale_files | index("sub/a.md"))' >/dev/null 2>&1; then
    assert "Stale file listed" "true"
else
    assert "Stale file listed" "false"
fi

# --- Missing case: remove a file ---
rm "$FIXTURE/sub/b.md"
set +e
out="$("$TOOL" --root "$FIXTURE")"
rc=$?
set -e
assert "Missing state → exit 2" "$([[ "$rc" == "2" ]] && echo true || echo false)"
if echo "$out" | jq -e '(.missing_files | index("sub/b.md"))' >/dev/null 2>&1; then
    assert "Missing file listed" "true"
else
    assert "Missing file listed" "false"
fi

# --- No state file: exit 2 with JSON ---
NOSTATE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE" "$NOSTATE"' EXIT
set +e
out="$("$TOOL" --root "$NOSTATE")"
rc=$?
set -e
assert "No state file → exit 2" "$([[ "$rc" == "2" ]] && echo true || echo false)"
if echo "$out" | jq -e '.fresh == false and (.reason | contains("no state file"))' >/dev/null 2>&1; then
    assert "No state emits diagnostic reason" "true"
else
    assert "No state emits diagnostic reason" "false"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
