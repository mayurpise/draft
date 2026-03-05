#!/usr/bin/env bash
# Test suite for plugin manifest consistency
#
# What this tests:
# - plugin.json is valid JSON with required fields
# - marketplace.json is valid JSON with required structure
# - Version consistency between plugin.json and marketplace.json
# - Plugin name matches skill directory structure
# - Required fields present in plugin.json
#
# Usage:
#   ./tests/test-plugin-manifest.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_JSON="$ROOT_DIR/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$ROOT_DIR/.claude-plugin/marketplace.json"
SKILLS_DIR="$ROOT_DIR/skills"

source "$SCRIPT_DIR/test-helpers.sh"

# Check if jq is available; if not, use python3 as fallback
json_get() {
    local file="$1"
    local query="$2"
    if command -v jq &>/dev/null; then
        jq -r "$query" "$file" 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "
import json, sys
with open('$file') as f:
    data = json.load(f)
keys = '$query'.strip('.').split('.')
for k in keys:
    if k.startswith('[') and k.endswith(']'):
        data = data[int(k[1:-1])]
    else:
        data = data[k]
print(data)
" 2>/dev/null
    else
        echo "ERROR"
    fi
}

json_valid() {
    local file="$1"
    if command -v jq &>/dev/null; then
        jq empty "$file" 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "import json; json.load(open('$file'))" 2>/dev/null
    else
        return 1
    fi
}

echo "=== Plugin manifest consistency tests ==="
echo ""

# --- plugin.json exists and is valid JSON ---
echo "## plugin.json validity"
assert "plugin.json exists" \
    "$([[ -f "$PLUGIN_JSON" ]] && echo true || echo false)"

assert "plugin.json is valid JSON" \
    "$(json_valid "$PLUGIN_JSON" && echo true || echo false)"

# --- Required fields in plugin.json ---
echo ""
echo "## plugin.json required fields"
if [[ -f "$PLUGIN_JSON" ]]; then
    PLUGIN_NAME=$(json_get "$PLUGIN_JSON" ".name")
    assert "plugin.json has 'name' field" \
        "$([[ -n "$PLUGIN_NAME" && "$PLUGIN_NAME" != "null" ]] && echo true || echo false)"

    PLUGIN_DESC=$(json_get "$PLUGIN_JSON" ".description")
    assert "plugin.json has 'description' field" \
        "$([[ -n "$PLUGIN_DESC" && "$PLUGIN_DESC" != "null" ]] && echo true || echo false)"

    PLUGIN_VERSION=$(json_get "$PLUGIN_JSON" ".version")
    assert "plugin.json has 'version' field" \
        "$([[ -n "$PLUGIN_VERSION" && "$PLUGIN_VERSION" != "null" ]] && echo true || echo false)"

    PLUGIN_AUTHOR=$(json_get "$PLUGIN_JSON" ".author.name")
    assert "plugin.json has 'author.name' field" \
        "$([[ -n "$PLUGIN_AUTHOR" && "$PLUGIN_AUTHOR" != "null" ]] && echo true || echo false)"

    PLUGIN_LICENSE=$(json_get "$PLUGIN_JSON" ".license")
    assert "plugin.json has 'license' field" \
        "$([[ -n "$PLUGIN_LICENSE" && "$PLUGIN_LICENSE" != "null" ]] && echo true || echo false)"
fi

# --- marketplace.json exists and is valid JSON ---
echo ""
echo "## marketplace.json validity"
assert "marketplace.json exists" \
    "$([[ -f "$MARKETPLACE_JSON" ]] && echo true || echo false)"

assert "marketplace.json is valid JSON" \
    "$(json_valid "$MARKETPLACE_JSON" && echo true || echo false)"

# --- Version consistency ---
echo ""
echo "## Version consistency"
if [[ -f "$PLUGIN_JSON" && -f "$MARKETPLACE_JSON" ]]; then
    PLUGIN_VERSION=$(json_get "$PLUGIN_JSON" ".version")
    MARKETPLACE_VERSION=$(json_get "$MARKETPLACE_JSON" ".plugins.[0].version")
    echo "  plugin.json version: $PLUGIN_VERSION"
    echo "  marketplace.json version: $MARKETPLACE_VERSION"
    assert "Versions match between plugin.json and marketplace.json" \
        "$([[ "$PLUGIN_VERSION" == "$MARKETPLACE_VERSION" ]] && echo true || echo false)"
fi

# --- Plugin name matches skills directory ---
echo ""
echo "## Plugin name consistency"
if [[ -f "$PLUGIN_JSON" ]]; then
    PLUGIN_NAME=$(json_get "$PLUGIN_JSON" ".name")
    # The plugin name should match the main skill directory name
    assert "Plugin name '$PLUGIN_NAME' has a matching skill directory" \
        "$([[ -d "$SKILLS_DIR/$PLUGIN_NAME" ]] && echo true || echo false)"
fi

# --- Marketplace plugin name matches plugin.json ---
echo ""
echo "## Marketplace-plugin name consistency"
if [[ -f "$PLUGIN_JSON" && -f "$MARKETPLACE_JSON" ]]; then
    PLUGIN_NAME=$(json_get "$PLUGIN_JSON" ".name")
    MARKETPLACE_PLUGIN_NAME=$(json_get "$MARKETPLACE_JSON" ".plugins.[0].name")
    assert "marketplace.json plugin name matches plugin.json name" \
        "$([[ "$PLUGIN_NAME" == "$MARKETPLACE_PLUGIN_NAME" ]] && echo true || echo false)"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
