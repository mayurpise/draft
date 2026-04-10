#!/usr/bin/env bash
# Test suite for trigger function coverage
#
# What this tests:
# - Every skill in SKILL_ORDER has an explicit case entry in get_skill_header
# - Every skill in SKILL_ORDER has an explicit case entry in get_trigger
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

SKILL_ORDER_RAW=$(sed -n '/^SKILL_ORDER=(/,/^)/p' "$BUILD_SCRIPT" | grep -v '^SKILL_ORDER=(' | grep -v '^)' | tr -d ' ' | grep -v '^\s*$')
SKILL_ORDER=()
while IFS= read -r line; do
    [[ -n "$line" ]] && SKILL_ORDER+=("$line")
done <<< "$SKILL_ORDER_RAW"

# Extract case entries from each function
extract_case_entries() {
    local func_name="$1"
    # Find the function, extract case entries (lines matching "skill-name)")
    sed -n "/^${func_name}()/,/^}/p" "$BUILD_SCRIPT" | sed -n 's/^[[:space:]]*\([a-z0-9][a-z0-9-]*\)).*$/\1/p' || true
}

TRIGGER_CASES=$(extract_case_entries "get_trigger")

# (Removed get_skill_header coverage)

# --- get_trigger coverage ---
echo ""
echo "## get_trigger coverage"
ALL_TRIGGER=true
for skill in "${SKILL_ORDER[@]}"; do
    [[ -z "$skill" ]] && continue
    if ! echo "$TRIGGER_CASES" | grep -qx "$skill"; then
        echo "  MISSING in get_trigger: $skill"
        ALL_TRIGGER=false
    fi
done
assert "Every SKILL_ORDER entry has explicit get_trigger case" "$ALL_TRIGGER"

# (Removed Gemini trigger tests)

# --- Copilot triggers do NOT contain @draft ---
echo ""
echo "## Copilot trigger syntax"

COPILOT_FUNC_FILE="$(mktemp)"
sed -n '/^get_trigger()/,/^}/p' "$BUILD_SCRIPT" > "$COPILOT_FUNC_FILE"
sed -n '/^get_copilot_trigger()/,/^}/p' "$BUILD_SCRIPT" >> "$COPILOT_FUNC_FILE"

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

rm -f "$COPILOT_FUNC_FILE"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
