#!/usr/bin/env bash
# Test suite for scripts/tools/cycle-detect.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/cycle-detect.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== cycle-detect.sh tests ==="
echo ""

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

set +e
out="$("$TOOL" --repo "$FIXTURE")"
rc=$?
set -e

assert "Exit 2 when graph data missing" "$([[ "$rc" == "2" ]] && echo true || echo false)"
if command -v jq >/dev/null 2>&1; then
    if echo "$out" | jq -e '.cycles == [] and .source == "unavailable"' >/dev/null 2>&1; then
        assert "Fallback emits {cycles:[], source:unavailable}" "true"
    else
        assert "Fallback emits {cycles:[], source:unavailable}" "false"
    fi
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
