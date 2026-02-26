#!/usr/bin/env bash
# Test suite for build script error handling paths
#
# What this tests:
# - Build fails with non-zero exit code when a skill file is missing
# - Build fails when frontmatter is malformed
# - Error messages go to stderr (not stdout)
# - Build fails with non-zero exit for invalid skill names
#
# Usage:
#   ./tests/test-error-handling.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"
SKILLS_DIR="$ROOT_DIR/skills"
TMPDIR_BASE="$(mktemp -d)"

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

cleanup() {
    # Remove any temp skill directories we created
    rm -rf "$SKILLS_DIR/zzz-test-bad-frontmatter" 2>/dev/null || true
    rm -rf "$TMPDIR_BASE"
}
trap cleanup EXIT

# Create a modified copy of the build script with ROOT_DIR hardcoded
# so it works when run from a temp directory.
create_modified_script() {
    local dest="$1"
    cp "$BUILD_SCRIPT" "$dest"
    chmod +x "$dest"
    # Override ROOT_DIR to point to the real repo root
    sed -i "s|^ROOT_DIR=.*|ROOT_DIR=\"$ROOT_DIR\"|" "$dest"
}

echo "=== Error handling tests ==="
echo ""

# --- Missing skill file produces error ---
echo "## Missing skill file"
MODIFIED_SCRIPT="$TMPDIR_BASE/modified-build.sh"
create_modified_script "$MODIFIED_SCRIPT"

# Add a fake skill to SKILL_ORDER
sed -i 's/^SKILL_ORDER=(/SKILL_ORDER=(\n    zzz-nonexistent-skill/' "$MODIFIED_SCRIPT"

STDERR=$("$MODIFIED_SCRIPT" 2>&1 >/dev/null || true)
EXIT_CODE=0
"$MODIFIED_SCRIPT" > /dev/null 2>/dev/null || EXIT_CODE=$?

assert "Build exits non-zero when skill file is missing" \
    "$([[ "$EXIT_CODE" -ne 0 ]] && echo true || echo false)"

assert "Missing skill error goes to stderr" \
    "$(echo "$STDERR" | grep -q "ERROR" && echo true || echo false)"

assert "Error message mentions the missing skill" \
    "$(echo "$STDERR" | grep -q "zzz-nonexistent-skill" && echo true || echo false)"

# --- Bad frontmatter produces error ---
echo ""
echo "## Bad frontmatter"
# Create a skill with invalid frontmatter (missing description)
mkdir -p "$SKILLS_DIR/zzz-test-bad-frontmatter"
cat > "$SKILLS_DIR/zzz-test-bad-frontmatter/SKILL.md" << 'EOF'
---
name: zzz-test-bad-frontmatter
---

# Test

Content here.
EOF

MODIFIED_SCRIPT2="$TMPDIR_BASE/modified-build2.sh"
create_modified_script "$MODIFIED_SCRIPT2"
sed -i 's/^SKILL_ORDER=(/SKILL_ORDER=(\n    zzz-test-bad-frontmatter/' "$MODIFIED_SCRIPT2"

STDERR2=$("$MODIFIED_SCRIPT2" 2>&1 >/dev/null || true)
EXIT_CODE2=0
"$MODIFIED_SCRIPT2" > /dev/null 2>/dev/null || EXIT_CODE2=$?

assert "Build exits non-zero for skill with missing description" \
    "$([[ "$EXIT_CODE2" -ne 0 ]] && echo true || echo false)"

assert "Missing description error goes to stderr" \
    "$(echo "$STDERR2" | grep -q "description" && echo true || echo false)"

# Clean up the temp skill
rm -rf "$SKILLS_DIR/zzz-test-bad-frontmatter"

# --- Invalid skill name in SKILL_ORDER produces error ---
echo ""
echo "## Invalid skill name"
MODIFIED_SCRIPT3="$TMPDIR_BASE/modified-build3.sh"
create_modified_script "$MODIFIED_SCRIPT3"

# Add an invalid skill name (uppercase)
sed -i 's/^SKILL_ORDER=(/SKILL_ORDER=(\n    InvalidName/' "$MODIFIED_SCRIPT3"

STDERR3=$("$MODIFIED_SCRIPT3" 2>&1 >/dev/null || true)
EXIT_CODE3=0
"$MODIFIED_SCRIPT3" > /dev/null 2>/dev/null || EXIT_CODE3=$?

assert "Build exits non-zero for invalid skill name" \
    "$([[ "$EXIT_CODE3" -ne 0 ]] && echo true || echo false)"

assert "Invalid name error mentions the bad name" \
    "$(echo "$STDERR3" | grep -q "InvalidName" && echo true || echo false)"

# --- Normal build still works after all this ---
echo ""
echo "## Normal build unaffected"
EXIT_CODE_NORMAL=0
"$BUILD_SCRIPT" > /dev/null 2>/dev/null || EXIT_CODE_NORMAL=$?
assert "Original build script still succeeds" \
    "$([[ "$EXIT_CODE_NORMAL" -eq 0 ]] && echo true || echo false)"

# --- Summary ---
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
