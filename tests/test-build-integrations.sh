#!/usr/bin/env bash
# Test suite for build-integrations.sh
#
# What this tests:
# - Build script exists and is executable
# - Output files are generated (Copilot, Gemini)
# - Output files have expected structure (> 100 lines)
# - Syntax transformations are correct (/draft: → @draft for Gemini, → draft for Copilot)
# - No @draft references in Copilot output
# - Idempotency (rebuilds produce identical output)
#
# What this does NOT test:
# - Skill content correctness
# - Skill frontmatter validation (handled by build script)
# - Error handling for malformed skill files
# - Individual skill inclusion/exclusion
#
# Usage:
#   ./tests/test-build-integrations.sh
#
# Expected runtime: < 2 seconds
# Exit code: Number of failed tests (0 = all pass)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"
COPILOT_OUTPUT="$ROOT_DIR/integrations/copilot/.github/copilot-instructions.md"
GEMINI_OUTPUT="$ROOT_DIR/integrations/gemini/GEMINI.md"
BASELINE="/tmp/copilot-baseline"

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

# --- Copilot output tests ---
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
    assert "Copilot output contains Draft methodology header" \
        "$(grep -q '# Draft - Context-Driven Development' "$COPILOT_OUTPUT" && echo true || echo false)"
    assert "Copilot output uses 'draft <cmd>' syntax (not @draft)" \
        "$(grep -q 'draft init' "$COPILOT_OUTPUT" && echo true || echo false)"
fi

# --- Idempotency test ---
echo ""
echo "## Idempotency"
if [[ -f "$COPILOT_OUTPUT" ]]; then
    cp "$COPILOT_OUTPUT" "$BASELINE"
    "$BUILD_SCRIPT" > /dev/null 2>&1 || true
    assert "Copilot output is idempotent (rebuild produces same result)" \
        "$(diff -q "$BASELINE" "$COPILOT_OUTPUT" > /dev/null 2>&1 && echo true || echo false)"
else
    assert "Copilot output is idempotent (rebuild produces same result)" "false"
fi

# --- Gemini output tests ---
echo ""
echo "## Gemini output"
assert "Gemini GEMINI.md generated" \
    "$([[ -f "$GEMINI_OUTPUT" ]] && echo true || echo false)"

if [[ -f "$GEMINI_OUTPUT" ]]; then
    LINES=$(wc -l < "$GEMINI_OUTPUT" | tr -d ' ')
    assert "Gemini output has content (>100 lines)" \
        "$([[ "$LINES" -gt 100 ]] && echo true || echo false)"
    DRAFT_COLON=$(grep -c '/draft:' "$GEMINI_OUTPUT" 2>/dev/null || true)
    assert "Gemini output contains no /draft: references" \
        "$([[ "${DRAFT_COLON:-0}" -eq 0 ]] && echo true || echo false)"
    AT_DRAFT=$(grep -c '@draft' "$GEMINI_OUTPUT" 2>/dev/null || true)
    assert "Gemini output contains @draft references" \
        "$([[ "${AT_DRAFT:-0}" -gt 0 ]] && echo true || echo false)"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
