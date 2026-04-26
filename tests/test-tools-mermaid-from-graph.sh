#!/usr/bin/env bash
# Test suite for scripts/tools/mermaid-from-graph.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/mermaid-from-graph.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== mermaid-from-graph.sh tests ==="
echo ""

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

# --- Fallback: no graph data ---
set +e
out="$("$TOOL" --repo "$FIXTURE")"
rc=$?
set -e
assert "Fallback exit is 2" "$([[ "$rc" == "2" ]] && echo true || echo false)"
if echo "$out" | grep -q '```mermaid'; then
    assert "Fallback emits a mermaid fenced block" "true"
else
    assert "Fallback emits a mermaid fenced block" "false"
fi
if echo "$out" | grep -q 'graph data unavailable'; then
    assert "Fallback includes disclaimer comment" "true"
else
    assert "Fallback includes disclaimer comment" "false"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
