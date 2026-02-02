#!/usr/bin/env bash
# Test suite for build-integrations.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"
CURSOR_OUTPUT="$ROOT_DIR/integrations/cursor/.cursorrules"
COPILOT_OUTPUT="$ROOT_DIR/integrations/copilot/.github/copilot-instructions.md"
BASELINE="/tmp/cursorrules-baseline"

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

echo "=== build-integrations.sh tests ==="
echo ""

# --- Existence tests ---
echo "## Script existence"
assert "build-integrations.sh exists" \
    "$([[ -f "$BUILD_SCRIPT" ]] && echo true || echo false)"
assert "build-integrations.sh is executable" \
    "$([[ -x "$BUILD_SCRIPT" ]] && echo true || echo false)"

# --- Run the build ---
echo ""
echo "## Running build..."
if [[ -f "$BUILD_SCRIPT" && -x "$BUILD_SCRIPT" ]]; then
    BUILD_OUTPUT=$("$BUILD_SCRIPT" 2>&1) || true
    echo "$BUILD_OUTPUT" | head -5
    echo ""
fi

# --- Cursor output tests ---
echo "## Cursor output"
assert "Cursor .cursorrules generated" \
    "$([[ -f "$CURSOR_OUTPUT" ]] && echo true || echo false)"

if [[ -f "$CURSOR_OUTPUT" ]]; then
    LINES=$(wc -l < "$CURSOR_OUTPUT" | tr -d ' ')
    assert "Cursor output has content (>100 lines)" \
        "$([[ "$LINES" -gt 100 ]] && echo true || echo false)"
    DRAFT_COLON=$(grep -c '/draft:' "$CURSOR_OUTPUT" 2>/dev/null || true)
    assert "Cursor output contains no /draft: references" \
        "$([[ "${DRAFT_COLON:-0}" -eq 0 ]] && echo true || echo false)"
    AT_DRAFT=$(grep -c '@draft' "$CURSOR_OUTPUT" 2>/dev/null || true)
    assert "Cursor output contains @draft references" \
        "$([[ "${AT_DRAFT:-0}" -gt 0 ]] && echo true || echo false)"
    DEAD_REFS=$(grep -c 'See `core/agents/' "$CURSOR_OUTPUT" 2>/dev/null || true)
    assert "Cursor output contains no dead agent references" \
        "$([[ "${DEAD_REFS:-0}" -eq 0 ]] && echo true || echo false)"
fi

# --- Cursor regression test ---
echo ""
echo "## Cursor regression"
if [[ -f "$BASELINE" && -f "$CURSOR_OUTPUT" ]]; then
    assert "Cursor output matches baseline (no regression)" \
        "$(diff -q "$BASELINE" "$CURSOR_OUTPUT" > /dev/null 2>&1 && echo true || echo false)"
else
    assert "Cursor output matches baseline (no regression)" "false"
fi

# --- Copilot output tests ---
echo ""
echo "## Copilot output"
assert "Copilot copilot-instructions.md generated" \
    "$([[ -f "$COPILOT_OUTPUT" ]] && echo true || echo false)"

if [[ -f "$COPILOT_OUTPUT" ]]; then
    LINES=$(wc -l < "$COPILOT_OUTPUT" | tr -d ' ')
    assert "Copilot output has content (>100 lines)" \
        "$([[ "$LINES" -gt 100 ]] && echo true || echo false)"
    AT_DRAFT=$(grep -c '@draft' "$COPILOT_OUTPUT" 2>/dev/null || true)
    assert "Copilot output contains no @draft references" \
        "$([[ "${AT_DRAFT:-0}" -eq 0 ]] && echo true || echo false)"
    DRAFT_COLON=$(grep -c '/draft:' "$COPILOT_OUTPUT" 2>/dev/null || true)
    assert "Copilot output contains no /draft: references" \
        "$([[ "${DRAFT_COLON:-0}" -eq 0 ]] && echo true || echo false)"
    DEAD_REFS=$(grep -c 'See `core/agents/' "$COPILOT_OUTPUT" 2>/dev/null || true)
    assert "Copilot output contains no dead agent references" \
        "$([[ "${DEAD_REFS:-0}" -eq 0 ]] && echo true || echo false)"
    assert "Copilot output contains Draft methodology header" \
        "$(grep -q '# Draft - Context-Driven Development' "$COPILOT_OUTPUT" && echo true || echo false)"
    assert "Copilot output uses 'draft <cmd>' syntax (not @draft)" \
        "$(grep -q 'draft init' "$COPILOT_OUTPUT" && echo true || echo false)"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
