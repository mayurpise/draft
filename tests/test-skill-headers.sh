#!/usr/bin/env bash
# Test suite for get_skill_header function
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_SCRIPT="$ROOT_DIR/scripts/build-integrations.sh"

PASS=0
FAIL=0

assert_eq() {
    local description="$1"
    local expected="$2"
    local actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        echo "  PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $description (Expected: '$expected', Got: '$actual')"
        FAIL=$((FAIL + 1))
    fi
}

# Extract get_skill_header function from build script
FUNC_FILE="$(mktemp)"
sed -n '/^get_skill_header()/,/^}/p' "$BUILD_SCRIPT" > "$FUNC_FILE"
source "$FUNC_FILE"

echo "=== Skill header tests ==="
echo ""

# Test explicit cases
assert_eq "draft" "Draft Overview" "$(get_skill_header "draft")"
assert_eq "init" "Init Command" "$(get_skill_header "init")"
assert_eq "index" "Index Command" "$(get_skill_header "index")"
assert_eq "new-track" "New Track Command" "$(get_skill_header "new-track")"
assert_eq "decompose" "Decompose Command" "$(get_skill_header "decompose")"
assert_eq "implement" "Implement Command" "$(get_skill_header "implement")"
assert_eq "coverage" "Coverage Command" "$(get_skill_header "coverage")"
assert_eq "bughunt" "Bug Hunt Command" "$(get_skill_header "bughunt")"
assert_eq "review" "Review Command" "$(get_skill_header "review")"
assert_eq "deep-review" "Deep Review Command" "$(get_skill_header "deep-review")"
assert_eq "learn" "Learn Command" "$(get_skill_header "learn")"
assert_eq "adr" "ADR Command" "$(get_skill_header "adr")"
assert_eq "status" "Status Command" "$(get_skill_header "status")"
assert_eq "revert" "Revert Command" "$(get_skill_header "revert")"
assert_eq "change" "Change Command" "$(get_skill_header "change")"
assert_eq "jira-preview" "Jira Preview Command" "$(get_skill_header "jira-preview")"
assert_eq "jira-create" "Jira Create Command" "$(get_skill_header "jira-create")"
assert_eq "debug" "Debug Command" "$(get_skill_header "debug")"
assert_eq "deploy-checklist" "Deploy Checklist Command" "$(get_skill_header "deploy-checklist")"
assert_eq "documentation" "Documentation Command" "$(get_skill_header "documentation")"
assert_eq "incident-response" "Incident Response Command" "$(get_skill_header "incident-response")"
assert_eq "quick-review" "Quick Review Command" "$(get_skill_header "quick-review")"
assert_eq "standup" "Standup Command" "$(get_skill_header "standup")"
assert_eq "tech-debt" "Tech Debt Command" "$(get_skill_header "tech-debt")"
assert_eq "testing-strategy" "Testing Strategy Command" "$(get_skill_header "testing-strategy")"
assert_eq "assist-review" "Assist Review Command" "$(get_skill_header "assist-review")"
assert_eq "impact" "Impact Command" "$(get_skill_header "impact")"
assert_eq "tour" "Tour Command" "$(get_skill_header "tour")"

# Test fallback case
assert_eq "unknown" "Unknown Command" "$(get_skill_header "unknown")"
assert_eq "custom-skill" "Custom-skill Command" "$(get_skill_header "custom-skill")"

rm -f "$FUNC_FILE"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
