#!/usr/bin/env bash
# Test suite for scripts/tools/adr-index.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/adr-index.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== adr-index.sh tests ==="
echo ""

FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

mkdir -p "$FIXTURE/adrs"
cat > "$FIXTURE/adrs/001-use-postgres.md" <<'EOF'
---
title: "Use Postgres for primary store"
date: "2025-06-01"
status: "accepted"
related_tracks:
  - DB-12
  - AUTH-7
---

# Use Postgres

Context: ...
EOF

cat > "$FIXTURE/adrs/002-switch-to-redis.md" <<'EOF'
---
title: "Adopt Redis for caching"
date: "2025-08-20"
status: "proposed"
---

# Redis
EOF

# Missing dir → empty adrs
empty_out="$("$TOOL" --root "$FIXTURE/nope")"
if command -v jq >/dev/null 2>&1; then
    if echo "$empty_out" | jq -e '.adrs == []' >/dev/null 2>&1; then
        assert "Missing root → {adrs:[]}" "true"
    else
        assert "Missing root → {adrs:[]}" "false"
    fi
fi

out="$("$TOOL" --root "$FIXTURE/adrs")"
if command -v jq >/dev/null 2>&1; then
    if echo "$out" | jq . >/dev/null 2>&1; then
        assert "Output is valid JSON" "true"
    else
        assert "Output is valid JSON" "false"
    fi

    n=$(echo "$out" | jq '.adrs | length')
    assert "Two ADRs indexed" "$([[ "$n" == "2" ]] && echo true || echo false)"

    id_first=$(echo "$out" | jq -r '.adrs[0].id')
    assert "Numeric prefix id extracted (001)" "$([[ "$id_first" == "001" ]] && echo true || echo false)"

    status_first=$(echo "$out" | jq -r '.adrs[0].status')
    assert "status field parsed" "$([[ "$status_first" == "accepted" ]] && echo true || echo false)"

    tracks=$(echo "$out" | jq -r '.adrs[0].related_tracks | length')
    assert "related_tracks parsed (count 2)" "$([[ "$tracks" == "2" ]] && echo true || echo false)"

    has_db12=$(echo "$out" | jq -r '.adrs[0].related_tracks | index("DB-12") != null')
    assert "DB-12 is in related_tracks" "$has_db12"

    title2=$(echo "$out" | jq -r '.adrs[1].title')
    assert "Second ADR title parsed" "$([[ "$title2" == "Adopt Redis for caching" ]] && echo true || echo false)"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
