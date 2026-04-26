#!/usr/bin/env bash
# Test suite for scripts/tools/hotspot-rank.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/hotspot-rank.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== hotspot-rank.sh tests ==="
echo ""

# --- Fallback path: no graph data → exits 2 with empty hotspots + source=unavailable ---
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT
set +e
out="$("$TOOL" --repo "$FIXTURE")"
rc=$?
set -e
assert "Exit 2 when graph data missing" "$([[ "$rc" == "2" ]] && echo true || echo false)"

if command -v jq >/dev/null 2>&1; then
    if echo "$out" | jq -e '.hotspots == [] and .source == "unavailable"' >/dev/null 2>&1; then
        assert "Emits {hotspots:[], source:unavailable} on fallback" "true"
    else
        assert "Emits {hotspots:[], source:unavailable} on fallback" "false"
    fi
fi

# --- hotspots.jsonl read path: seed a fake hotspots.jsonl and verify ---
mkdir -p "$FIXTURE/draft/graph"
cat > "$FIXTURE/draft/graph/hotspots.jsonl" <<'EOF'
{"id":"a.py","module":"m","lines":400,"fanIn":2}
{"id":"b.py","module":"m","lines":100,"fanIn":1}
EOF
# Block graph binary discovery by pointing --out to a non-graph path.
out2="$("$TOOL" --repo "$FIXTURE" --out "$FIXTURE/draft/graph" 2>/dev/null || true)"
if command -v jq >/dev/null 2>&1; then
    if echo "$out2" | jq -e '.hotspots | length >= 1' >/dev/null 2>&1; then
        assert "hotspots.jsonl produces at least one entry" "true"
    else
        assert "hotspots.jsonl produces at least one entry" "false"
    fi
    # --top 1 trims
    top_out="$("$TOOL" --repo "$FIXTURE" --out "$FIXTURE/draft/graph" --top 1)"
    count=$(echo "$top_out" | jq '.hotspots | length')
    assert "--top 1 returns 1 entry" "$([[ "$count" == "1" ]] && echo true || echo false)"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
