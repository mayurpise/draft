#!/usr/bin/env bash
# Test suite for syntax transform functions
#
# What this tests:
# - Gemini transform: /draft:command → @draft command
# - Copilot transform: /draft:command → draft command, @draft → draft
# - Edge cases: multiple occurrences, mid-sentence, backtick-wrapped
#
# Usage:
#   ./tests/test-syntax-transforms.sh
set -euo pipefail

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

# Replicate the transform functions from build-integrations.sh
transform_gemini_syntax() {
    sed -E \
        -e 's|/draft:([a-z-]+)|@draft \1|g'
}

transform_copilot_syntax() {
    sed -E \
        -e 's|/draft:([a-z-]+)|draft \1|g' \
        -e 's|@draft\b|draft|g' \
        -e 's|`@draft`|`draft`|g' \
        -e 's|`@draft |`draft |g'
}

assert_transform() {
    local description="$1"
    local transform_fn="$2"
    local input="$3"
    local expected="$4"
    local actual
    actual=$(echo "$input" | "$transform_fn")
    if [[ "$actual" == "$expected" ]]; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $description"
        echo "    Input:    '$input'"
        echo "    Expected: '$expected'"
        echo "    Actual:   '$actual'"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Syntax transform tests ==="
echo ""

# --- Gemini transforms ---
echo "## Gemini: /draft:cmd → @draft cmd"
assert_transform "Simple command" \
    transform_gemini_syntax \
    "/draft:init" \
    "@draft init"

assert_transform "Hyphenated command" \
    transform_gemini_syntax \
    "/draft:new-track" \
    "@draft new-track"

assert_transform "Double-hyphenated command" \
    transform_gemini_syntax \
    "/draft:deep-review" \
    "@draft deep-review"

assert_transform "Mid-sentence" \
    transform_gemini_syntax \
    "Run /draft:init to set up the project" \
    "Run @draft init to set up the project"

assert_transform "Multiple on one line" \
    transform_gemini_syntax \
    "Use /draft:init then /draft:new-track to start" \
    "Use @draft init then @draft new-track to start"

assert_transform "In backticks" \
    transform_gemini_syntax \
    'Use `/draft:implement` to start' \
    'Use `@draft implement` to start'

assert_transform "No match - plain text unchanged" \
    transform_gemini_syntax \
    "This has no draft commands" \
    "This has no draft commands"

assert_transform "Preserves existing @draft" \
    transform_gemini_syntax \
    "@draft is already correct" \
    "@draft is already correct"

# --- Copilot transforms ---
echo ""
echo "## Copilot: /draft:cmd → draft cmd, @draft → draft"
assert_transform "Simple command" \
    transform_copilot_syntax \
    "/draft:init" \
    "draft init"

assert_transform "Hyphenated command" \
    transform_copilot_syntax \
    "/draft:new-track" \
    "draft new-track"

assert_transform "Mid-sentence" \
    transform_copilot_syntax \
    "Run /draft:init to set up the project" \
    "Run draft init to set up the project"

assert_transform "Multiple on one line" \
    transform_copilot_syntax \
    "Use /draft:init then /draft:new-track to start" \
    "Use draft init then draft new-track to start"

assert_transform "@draft becomes draft" \
    transform_copilot_syntax \
    "@draft is the tool" \
    "draft is the tool"

assert_transform "Backtick @draft becomes draft" \
    transform_copilot_syntax \
    'Use `@draft` for help' \
    'Use `draft` for help'

assert_transform "Backtick @draft with space becomes draft" \
    transform_copilot_syntax \
    'Use `@draft init` to start' \
    'Use `draft init` to start'

assert_transform "No match - plain text unchanged" \
    transform_copilot_syntax \
    "This has no draft commands" \
    "This has no draft commands"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
