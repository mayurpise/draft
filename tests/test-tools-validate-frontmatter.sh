#!/usr/bin/env bash
# Test suite for scripts/tools/validate-frontmatter.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/validate-frontmatter.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== validate-frontmatter.sh tests ==="
echo ""

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

# Valid file (default requirement: name + description)
cat > "$FIXTURE/ok.md" <<'EOF'
---
name: sample
description: a sample skill
---

# Sample
EOF
set +e
"$TOOL" "$FIXTURE/ok.md" >/dev/null 2>&1
rc=$?
set -e
assert "Valid file → exit 0" "$([[ "$rc" == "0" ]] && echo true || echo false)"

# Missing opening --- delimiter
cat > "$FIXTURE/no-open.md" <<'EOF'
name: x
description: y

# body
EOF
set +e
"$TOOL" "$FIXTURE/no-open.md" >/dev/null 2>&1
rc=$?
set -e
assert "Missing opening --- → exit 1" "$([[ "$rc" == "1" ]] && echo true || echo false)"

# Missing closing --- delimiter
cat > "$FIXTURE/no-close.md" <<'EOF'
---
name: x
description: y

# body
EOF
set +e
"$TOOL" "$FIXTURE/no-close.md" >/dev/null 2>&1
rc=$?
set -e
assert "Missing closing --- → exit 1" "$([[ "$rc" == "1" ]] && echo true || echo false)"

# Missing required field
cat > "$FIXTURE/no-desc.md" <<'EOF'
---
name: x
---

# body
EOF
set +e
"$TOOL" "$FIXTURE/no-desc.md" >/dev/null 2>&1
rc=$?
set -e
assert "Missing 'description' → exit 1" "$([[ "$rc" == "1" ]] && echo true || echo false)"

# --require override
cat > "$FIXTURE/report.md" <<'EOF'
---
project: draft
generated_at: "2026-04-22T00:00:00Z"
git:
  branch: main
---

# report
EOF
set +e
"$TOOL" "$FIXTURE/report.md" --require project,generated_at,git >/dev/null 2>&1
rc=$?
set -e
assert "Custom --require set satisfied → exit 0" "$([[ "$rc" == "0" ]] && echo true || echo false)"

# File not found → exit 2
set +e
"$TOOL" "$FIXTURE/none.md" >/dev/null 2>&1
rc=$?
set -e
assert "Missing file → exit 2" "$([[ "$rc" == "2" ]] && echo true || echo false)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
