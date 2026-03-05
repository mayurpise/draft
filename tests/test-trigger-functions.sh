#!/usr/bin/env bash
# Test suite for trigger function coverage
#
# What this tests:
# - Every skill in SKILL_ORDER has an explicit case entry in get_skill_header
# - Every skill in SKILL_ORDER has an explicit case entry in get_gemini_trigger
# - Every skill in SKILL_ORDER has an explicit case entry in get_copilot_trigger
# - Gemini triggers contain @draft prefix
# - Copilot triggers do NOT contain @draft prefix
# - No skill falls through to the wildcard (*) case
#
# Usage:
#   ./tests/test-trigger-functions.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Trigger function coverage tests ==="
echo ""

# Extract SKILL_ORDER from build script
SKILL_ORDER_RAW=$(sed -n '/^SKILL_ORDER=(/,/^)/p' "$BUILD_SCRIPT" | grep -v '^SKILL_ORDER=(' | grep -v '^)' | tr -d ' ')
mapfile -t SKILL_ORDER <<< "$SKILL_ORDER_RAW"

# Extract case entries from each function
extract_case_entries() {
    local func_name="$1"
    # Find the function, extract case entries (lines matching "skill-name)")
    sed -n "/^${func_name}()/,/^}/p" "$BUILD_SCRIPT" | grep -oP '^\s+\K[a-z0-9-]+(?=\))' || true
}

HEADER_CASES=$(extract_case_entries "get_skill_header")
GEMINI_CASES=$(extract_case_entries "get_gemini_trigger")
COPILOT_CASES=$(extract_case_entries "get_copilot_trigger")

# --- get_skill_header coverage ---
echo "## get_skill_header coverage"
ALL_HEADER=true
for skill in "${SKILL_ORDER[@]}"; do
    [[ -z "$skill" ]] && continue
    if ! echo "$HEADER_CASES" | grep -qx "$skill"; then
        echo "  MISSING in get_skill_header: $skill"
        ALL_HEADER=false
    fi
done
assert "Every SKILL_ORDER entry has explicit get_skill_header case" "$ALL_HEADER"

# --- get_gemini_trigger coverage ---
echo ""
echo "## get_gemini_trigger coverage"
ALL_GEMINI=true
for skill in "${SKILL_ORDER[@]}"; do
    [[ -z "$skill" ]] && continue
    if ! echo "$GEMINI_CASES" | grep -qx "$skill"; then
        echo "  MISSING in get_gemini_trigger: $skill"
        ALL_GEMINI=false
    fi
done
assert "Every SKILL_ORDER entry has explicit get_gemini_trigger case" "$ALL_GEMINI"

# --- get_copilot_trigger coverage ---
echo ""
echo "## get_copilot_trigger coverage"
ALL_COPILOT=true
for skill in "${SKILL_ORDER[@]}"; do
    [[ -z "$skill" ]] && continue
    if ! echo "$COPILOT_CASES" | grep -qx "$skill"; then
        echo "  MISSING in get_copilot_trigger: $skill"
        ALL_COPILOT=false
    fi
done
assert "Every SKILL_ORDER entry has explicit get_copilot_trigger case" "$ALL_COPILOT"

# --- Gemini triggers contain @draft ---
echo ""
echo "## Gemini trigger syntax"

# Source the function definitions by extracting them
FUNC_FILE="$(mktemp)"
sed -n '/^get_gemini_trigger()/,/^}/p' "$BUILD_SCRIPT" > "$FUNC_FILE"

ALL_GEMINI_SYNTAX=true
for skill in "${SKILL_ORDER[@]}"; do
    [[ -z "$skill" ]] && continue
    TRIGGER=$(source "$FUNC_FILE" 2>/dev/null && get_gemini_trigger "$skill" 2>/dev/null || \
        bash -c "$(cat "$FUNC_FILE"); get_gemini_trigger '$skill'" 2>/dev/null)
    if [[ -n "$TRIGGER" ]] && ! echo "$TRIGGER" | grep -q '@draft'; then
        echo "  NO @draft in trigger for: $skill → $TRIGGER"
        ALL_GEMINI_SYNTAX=false
    fi
done
assert "All Gemini triggers contain @draft" "$ALL_GEMINI_SYNTAX"

# --- Copilot triggers do NOT contain @draft ---
echo ""
echo "## Copilot trigger syntax"

COPILOT_FUNC_FILE="$(mktemp)"
sed -n '/^get_copilot_trigger()/,/^}/p' "$BUILD_SCRIPT" > "$COPILOT_FUNC_FILE"

ALL_COPILOT_SYNTAX=true
for skill in "${SKILL_ORDER[@]}"; do
    [[ -z "$skill" ]] && continue
    TRIGGER=$(bash -c "$(cat "$COPILOT_FUNC_FILE"); get_copilot_trigger '$skill'" 2>/dev/null)
    if [[ -n "$TRIGGER" ]] && echo "$TRIGGER" | grep -q '@draft'; then
        echo "  HAS @draft in trigger for: $skill → $TRIGGER"
        ALL_COPILOT_SYNTAX=false
    fi
done
assert "No Copilot triggers contain @draft" "$ALL_COPILOT_SYNTAX"

rm -f "$FUNC_FILE" "$COPILOT_FUNC_FILE"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
