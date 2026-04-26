#!/usr/bin/env bash
# Test suite for scripts/tools/parse-reports.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/parse-reports.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== parse-reports.sh tests ==="
echo ""

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

cat > "$FIXTURE/bughunt-report-2026-04-22T1000.md" <<'EOF'
---
project: "draft"
module: "root"
track_id: "AUTH-7"
generated_at: "2026-04-22T10:00:00Z"
---

# Bughunt Report

| Finding | Severity | File |
|---------|----------|------|
| leak | Critical | a.c |
| race | High | b.c |
| typo | Low | c.md |

- Critical: leak
- High: race
EOF

cat > "$FIXTURE/review-report-2026-04-23T0800.md" <<'EOF'
---
project: "draft"
module: "root"
track_id: null
generated_at: "2026-04-23T08:00:00Z"
---

# Review

Severity: medium — small nits only.
EOF

# Directory with no reports
mkdir -p "$FIXTURE/empty"

# Empty case
empty_out="$("$TOOL" --root "$FIXTURE/empty")"
if [[ "$(echo "$empty_out" | tr -d '[:space:]')" == "[]" ]]; then
    assert "Empty directory emits []" "true"
else
    assert "Empty directory emits []" "false"
fi

out="$("$TOOL" --root "$FIXTURE")"

if command -v jq >/dev/null 2>&1; then
    if echo "$out" | jq . >/dev/null 2>&1; then
        assert "Output is valid JSON" "true"
    else
        assert "Output is valid JSON" "false"
    fi

    n=$(echo "$out" | jq 'length')
    assert "Two reports parsed" "$([[ "$n" == "2" ]] && echo true || echo false)"

    bh_type=$(echo "$out" | jq -r '.[] | select(.path | contains("bughunt-report")) | .report_type')
    assert "bughunt report_type extracted" "$([[ "$bh_type" == "bughunt" ]] && echo true || echo false)"

    track=$(echo "$out" | jq -r '.[] | select(.path | contains("bughunt-report")) | .track_id')
    assert "bughunt track_id extracted" "$([[ "$track" == "AUTH-7" ]] && echo true || echo false)"

    crit=$(echo "$out" | jq -r '.[] | select(.path | contains("bughunt-report")) | .severity.critical')
    assert "bughunt critical severity counted (>= 1)" "$([[ "$crit" -ge 1 ]] && echo true || echo false)"

    r_type=$(echo "$out" | jq -r '.[] | select(.path | contains("review-report")) | .report_type')
    assert "review report_type extracted" "$([[ "$r_type" == "review" ]] && echo true || echo false)"

    r_track=$(echo "$out" | jq -r '.[] | select(.path | contains("review-report")) | .track_id')
    assert "review null track_id stays null" "$([[ "$r_track" == "null" ]] && echo true || echo false)"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
