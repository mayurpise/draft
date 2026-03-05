#!/usr/bin/env bash
# Test suite for core file inlining
#
# What this tests:
# - All files listed in CORE_FILES array exist on disk
# - Each core file appears in Copilot output wrapped in <core-file> tags
# - Each core file appears in Gemini output wrapped in <core-file> tags
# - No WARNING about missing core files on build stderr
#
# Usage:
#   ./tests/test-core-files.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"
CORE_DIR="$ROOT_DIR/core"
COPILOT_OUTPUT="$ROOT_DIR/integrations/copilot/.github/copilot-instructions.md"
GEMINI_OUTPUT="$ROOT_DIR/integrations/gemini/GEMINI.md"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Core file inlining tests ==="
echo ""

# Extract CORE_FILES array from build script
CORE_FILES_RAW=$(sed -n '/^CORE_FILES=(/,/^)/p' "$BUILD_SCRIPT" | grep -v '^CORE_FILES=(' | grep -v '^)' | grep -v '^\s*#' | sed 's/^[[:space:]]*"//' | sed 's/"[[:space:]]*$//')
mapfile -t CORE_FILES <<< "$CORE_FILES_RAW"

echo "## Core files count: ${#CORE_FILES[@]}"
echo ""

# --- All core files exist on disk ---
echo "## Core files exist on disk"
ALL_EXIST=true
for core_file in "${CORE_FILES[@]}"; do
    [[ -z "$core_file" ]] && continue
    full_path="$CORE_DIR/$core_file"
    if [[ ! -f "$full_path" ]]; then
        echo "  MISSING: $full_path"
        ALL_EXIST=false
    fi
done
assert "All CORE_FILES entries exist on disk" "$ALL_EXIST"

# --- Ensure outputs are current ---
echo ""
echo "## Rebuilding outputs..."
"$BUILD_SCRIPT" > /dev/null 2>&1 || true

# --- Core files appear in Copilot output ---
echo ""
echo "## Core files in Copilot output"
ALL_IN_COPILOT=true
COPILOT_MISSING=()
for core_file in "${CORE_FILES[@]}"; do
    [[ -z "$core_file" ]] && continue
    TAG="<core-file path=\"core/${core_file}\">"
    if ! grep -qF "$TAG" "$COPILOT_OUTPUT" 2>/dev/null; then
        COPILOT_MISSING+=("$core_file")
        ALL_IN_COPILOT=false
    fi
done
if [[ "$ALL_IN_COPILOT" == "false" ]]; then
    for missing in "${COPILOT_MISSING[@]}"; do
        echo "  MISSING in Copilot: $missing"
    done
fi
assert "All core files inlined in Copilot output with <core-file> tags" "$ALL_IN_COPILOT"

# --- Core files appear in Gemini output ---
echo ""
echo "## Core files in Gemini output"
ALL_IN_GEMINI=true
GEMINI_MISSING=()
for core_file in "${CORE_FILES[@]}"; do
    [[ -z "$core_file" ]] && continue
    TAG="<core-file path=\"core/${core_file}\">"
    if ! grep -qF "$TAG" "$GEMINI_OUTPUT" 2>/dev/null; then
        GEMINI_MISSING+=("$core_file")
        ALL_IN_GEMINI=false
    fi
done
if [[ "$ALL_IN_GEMINI" == "false" ]]; then
    for missing in "${GEMINI_MISSING[@]}"; do
        echo "  MISSING in Gemini: $missing"
    done
fi
assert "All core files inlined in Gemini output with <core-file> tags" "$ALL_IN_GEMINI"

# --- Closing tags present ---
echo ""
echo "## Closing tags"
COPILOT_OPEN=$(grep -c '<core-file path=' "$COPILOT_OUTPUT" 2>/dev/null || true)
COPILOT_CLOSE=$(grep -c '</core-file>' "$COPILOT_OUTPUT" 2>/dev/null || true)
assert "Copilot output has matching open/close core-file tags ($COPILOT_OPEN/$COPILOT_CLOSE)" \
    "$([[ "$COPILOT_OPEN" -eq "$COPILOT_CLOSE" ]] && echo true || echo false)"

GEMINI_OPEN=$(grep -c '<core-file path=' "$GEMINI_OUTPUT" 2>/dev/null || true)
GEMINI_CLOSE=$(grep -c '</core-file>' "$GEMINI_OUTPUT" 2>/dev/null || true)
assert "Gemini output has matching open/close core-file tags ($GEMINI_OPEN/$GEMINI_CLOSE)" \
    "$([[ "$GEMINI_OPEN" -eq "$GEMINI_CLOSE" ]] && echo true || echo false)"

# --- No missing-file warnings ---
echo ""
echo "## No missing file warnings"
BUILD_STDERR=$("$BUILD_SCRIPT" 2>&1 >/dev/null || true)
MISSING_WARNS=$(echo "$BUILD_STDERR" | grep -c "Core file not found" || true)
assert "Build produces no 'Core file not found' warnings" \
    "$([[ "${MISSING_WARNS:-0}" -eq 0 ]] && echo true || echo false)"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
