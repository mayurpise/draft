#!/usr/bin/env bash
# Shared test helpers for all test suites

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

# Extract body content from a SKILL.md file (strip YAML frontmatter)
extract_body() {
    local file="$1"

    # Check for frontmatter delimiters
    if ! grep -q "^---$" "$file"; then
        echo "ERROR: Missing YAML frontmatter in $file" >&2
        echo "  Skill files must start with --- delimiter" >&2
        return 1
    fi

    # Extract and validate frontmatter (awk stops at closing ---, naturally bounded)
    local frontmatter
    frontmatter=$(awk '
        /^---$/ { if (!seen_first) { seen_first=1; next } else { exit } }
        seen_first { print }
    ' "$file")

    # Validate required fields
    if ! echo "$frontmatter" | grep -q "^name:"; then
        echo "ERROR: Missing 'name:' field in frontmatter of $file" >&2
        return 1
    fi

    if ! echo "$frontmatter" | grep -q "^description:"; then
        echo "ERROR: Missing 'description:' field in frontmatter of $file" >&2
        return 1
    fi

    # Extract body (existing logic)
    awk '
        BEGIN { in_frontmatter = 0; found_end = 0 }
        /^---$/ {
            if (in_frontmatter == 0) {
                in_frontmatter = 1
                next
            } else if (found_end == 0) {
                found_end = 1
                next
            }
        }
        found_end == 1 { print }
    ' "$file"
}
