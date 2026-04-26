#!/usr/bin/env bash
# Test suite for scripts/tools/git-metadata.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/git-metadata.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== git-metadata.sh tests ==="
echo ""

# --- JSON output is valid JSON and has required fields ---
json_out="$("$TOOL" --json)"
if command -v jq >/dev/null 2>&1; then
    if echo "$json_out" | jq . >/dev/null 2>&1; then
        assert "JSON output parses with jq" "true"
    else
        assert "JSON output parses with jq" "false"
    fi
elif command -v python3 >/dev/null 2>&1; then
    if echo "$json_out" | python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null; then
        assert "JSON output parses with python3" "true"
    else
        assert "JSON output parses with python3" "false"
    fi
else
    echo "  SKIP: neither jq nor python3 available"
fi

for field in project module generated_at git synced_to_commit; do
    if echo "$json_out" | grep -q "\"$field\""; then
        assert "JSON output contains '$field'" "true"
    else
        assert "JSON output contains '$field'" "false"
    fi
done

# --- YAML output begins and ends with --- delimiters ---
yaml_out="$("$TOOL" --yaml)"
first_line="$(echo "$yaml_out" | sed -n '1p')"
last_line="$(echo "$yaml_out" | sed -n '$p')"
assert "YAML output starts with ---" \
    "$([[ "$first_line" == "---" ]] && echo true || echo false)"
assert "YAML output ends with ---" \
    "$([[ "$last_line" == "---" ]] && echo true || echo false)"

# --- YAML output includes required fields ---
for field in "project:" "module:" "generated_at:" "git:" "synced_to_commit:"; do
    if echo "$yaml_out" | grep -q "^${field}\|^  ${field}"; then
        assert "YAML output contains '$field'" "true"
    else
        assert "YAML output contains '$field'" "false"
    fi
done

# --- Custom flags propagate ---
custom="$("$TOOL" --json --project MyProj --module core --track-id T-42 --generated-by draft:bughunt)"
for expect in '"project": "MyProj"' '"module": "core"' '"track_id": "T-42"' '"generated_by": "draft:bughunt"'; do
    if echo "$custom" | grep -qF "$expect"; then
        assert "Custom flag propagates: $expect" "true"
    else
        assert "Custom flag propagates: $expect" "false"
    fi
done

# --- Commit SHA is 40 hex chars ---
sha="$(echo "$json_out" | grep -oE '"commit": "[0-9a-f]{40}"' | head -1)"
assert "git.commit is full 40-char SHA" \
    "$([[ -n "$sha" ]] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
