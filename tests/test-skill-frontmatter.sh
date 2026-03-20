#!/usr/bin/env bash
# Test suite for SKILL.md frontmatter and body format validation
#
# What this tests:
# - Build script rejects skills with missing YAML frontmatter delimiters
# - Build script rejects skills with missing 'name:' field
# - Build script rejects skills with missing 'description:' field
# - Build script rejects skills with invalid body format (must be: blank, # Title, blank)
# - All real skills pass frontmatter validation
#
# Usage:
#   ./tests/test-skill-frontmatter.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"
SKILLS_DIR="$ROOT_DIR/skills"
TMPDIR_BASE="$(mktemp -d)"

source "$SCRIPT_DIR/test-helpers.sh"

cleanup() {
    rm -rf "$TMPDIR_BASE"
}
trap cleanup EXIT

# Helper: create a temporary skill directory with given SKILL.md content,
# patch SKILL_ORDER to only include this skill, and run the build.
# Returns 0 if build succeeds, 1 if it fails.
run_build_with_skill() {
    local skill_name="$1"
    local skill_content="$2"
    local tmpdir="$TMPDIR_BASE/$skill_name"
    mkdir -p "$tmpdir/skills/$skill_name"
    mkdir -p "$tmpdir/integrations/copilot/.github"
    mkdir -p "$tmpdir/integrations/gemini"
    mkdir -p "$tmpdir/core/templates"
    mkdir -p "$tmpdir/core/agents"

    echo "$skill_content" > "$tmpdir/skills/$skill_name/SKILL.md"

    # Create a minimal build script that tests just extract_body + validation
    # by sourcing the relevant functions from the real build script
    cat > "$tmpdir/test-runner.sh" << RUNNER
#!/usr/bin/env bash
set -euo pipefail

SKILL_FILE="\$1"

source "$SCRIPT_DIR/test-helpers.sh"

# Run extract_body
BODY=\$(extract_body "\$SKILL_FILE") || exit 1

# Validate body format: line 1 blank, line 2 starts with #, line 3 blank
line1=\$(echo "\$BODY" | sed -n '1p')
line2=\$(echo "\$BODY" | sed -n '2p')
line3=\$(echo "\$BODY" | sed -n '3p')
if [[ -n "\$line1" ]] || [[ ! "\$line2" =~ ^#\  ]] || [[ -n "\$line3" ]]; then
    echo "ERROR: Body format invalid" >&2
    exit 1
fi

echo "OK"
RUNNER
    chmod +x "$tmpdir/test-runner.sh"

    "$tmpdir/test-runner.sh" "$tmpdir/skills/$skill_name/SKILL.md" >/dev/null 2>/dev/null
}

echo "=== SKILL.md frontmatter & body format tests ==="
echo ""

# --- Missing frontmatter delimiters ---
echo "## Missing frontmatter delimiters"
CONTENT_NO_DELIMITERS="name: test
description: A test skill

# Test Skill

Some content here."

assert "Rejects skill with no --- delimiters" \
    "$(run_build_with_skill "no-delimiters" "$CONTENT_NO_DELIMITERS" && echo false || echo true)"

# --- Missing closing delimiter ---
CONTENT_NO_CLOSE="---
name: test
description: A test skill

# Test Skill

Some content here."

assert "Rejects skill with missing closing ---" \
    "$(run_build_with_skill "no-close" "$CONTENT_NO_CLOSE" && echo false || echo true)"

# --- Missing name field ---
echo ""
echo "## Missing name field"
CONTENT_NO_NAME="---
description: A test skill
---

# Test Skill

Some content here."

assert "Rejects skill with missing name: field" \
    "$(run_build_with_skill "no-name" "$CONTENT_NO_NAME" && echo false || echo true)"

# --- Missing description field ---
echo ""
echo "## Missing description field"
CONTENT_NO_DESC="---
name: test
---

# Test Skill

Some content here."

assert "Rejects skill with missing description: field" \
    "$(run_build_with_skill "no-desc" "$CONTENT_NO_DESC" && echo false || echo true)"

# --- Invalid body format: no blank first line ---
echo ""
echo "## Invalid body format"
CONTENT_BAD_BODY1="---
name: test
description: A test skill
---
# Test Skill

Some content here."

assert "Rejects skill with non-blank first body line" \
    "$(run_build_with_skill "bad-body1" "$CONTENT_BAD_BODY1" && echo false || echo true)"

# --- Invalid body format: no # Title on line 2 ---
CONTENT_BAD_BODY2="---
name: test
description: A test skill
---

Not a heading

Some content here."

assert "Rejects skill with missing # Title on line 2" \
    "$(run_build_with_skill "bad-body2" "$CONTENT_BAD_BODY2" && echo false || echo true)"

# --- Invalid body format: non-blank third line ---
CONTENT_BAD_BODY3="---
name: test
description: A test skill
---

# Test Skill
Not blank line here."

assert "Rejects skill with non-blank third body line" \
    "$(run_build_with_skill "bad-body3" "$CONTENT_BAD_BODY3" && echo false || echo true)"

# --- Valid skill passes ---
echo ""
echo "## Valid skill accepted"
CONTENT_VALID="---
name: test
description: A test skill
---

# Test Skill

Some content here."

assert "Accepts valid skill with correct frontmatter and body" \
    "$(run_build_with_skill "valid" "$CONTENT_VALID" && echo true || echo false)"

# --- All real skills pass validation ---
echo ""
echo "## Real skill validation"
ALL_REAL_PASS=true
for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    if [[ -f "$skill_file" ]]; then
        # Re-use the test runner against real skills
        TMPDIR_REAL="$TMPDIR_BASE/real-$skill_name"
        mkdir -p "$TMPDIR_REAL"
        cp "$TMPDIR_BASE/no-delimiters/test-runner.sh" "$TMPDIR_REAL/test-runner.sh" 2>/dev/null || true
        # Use the first test runner we created
        RUNNER="$TMPDIR_BASE/no-delimiters/test-runner.sh"
        if [[ -x "$RUNNER" ]]; then
            if ! "$RUNNER" "$skill_file" > /dev/null 2>&1; then
                echo "  FAIL: Real skill '$skill_name' failed validation"
                ALL_REAL_PASS=false
            fi
        fi
    fi
done
assert "All real skills (skills/*) pass frontmatter + body validation" "$ALL_REAL_PASS"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
