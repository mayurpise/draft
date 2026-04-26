#!/usr/bin/env bash
# Test suite for scripts/tools/detect-test-framework.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TOOL="$ROOT_DIR/scripts/tools/detect-test-framework.sh"

source "$SCRIPT_DIR/test-helpers.sh"

echo "=== detect-test-framework.sh tests ==="
echo ""

# --- Empty directory → empty languages array ---
EMPTY="$(mktemp -d)"
trap 'rm -rf "$EMPTY" "${PYFIX:-}" "${GOFIX:-}" "${JSFIX:-}"' EXIT
empty_out="$("$TOOL" --root "$EMPTY")"
if command -v jq >/dev/null 2>&1; then
    if echo "$empty_out" | jq -e '.languages == []' >/dev/null 2>&1; then
        assert "Empty repo → {languages:[]}" "true"
    else
        assert "Empty repo → {languages:[]}" "false"
    fi
fi

# --- Python pytest fixture ---
PYFIX="$(mktemp -d)"
touch "$PYFIX/pytest.ini"
mkdir -p "$PYFIX/tests"
echo "def test_one(): assert True" > "$PYFIX/tests/test_sample.py"
py_out="$("$TOOL" --root "$PYFIX")"
if command -v jq >/dev/null 2>&1; then
    if echo "$py_out" | jq -e '.languages | map(select(.language=="python" and .framework=="pytest")) | length == 1' >/dev/null 2>&1; then
        assert "pytest detected via pytest.ini" "true"
    else
        assert "pytest detected via pytest.ini" "false"
    fi
fi

# --- Go fixture ---
GOFIX="$(mktemp -d)"
echo 'module x' > "$GOFIX/go.mod"
echo 'package x' > "$GOFIX/x.go"
echo 'package x; import "testing"; func TestX(t *testing.T){}' > "$GOFIX/x_test.go"
go_out="$("$TOOL" --root "$GOFIX")"
if command -v jq >/dev/null 2>&1; then
    if echo "$go_out" | jq -e '.languages | map(select(.language=="go")) | length == 1' >/dev/null 2>&1; then
        assert "go test detected" "true"
    else
        assert "go test detected" "false"
    fi
fi

# --- JS vitest fixture ---
JSFIX="$(mktemp -d)"
cat > "$JSFIX/package.json" <<'EOF'
{"devDependencies":{"vitest":"^1.0.0"}}
EOF
js_out="$("$TOOL" --root "$JSFIX")"
if command -v jq >/dev/null 2>&1; then
    if echo "$js_out" | jq -e '.languages | map(select(.language=="javascript" and .framework=="vitest")) | length == 1' >/dev/null 2>&1; then
        assert "vitest detected via package.json" "true"
    else
        assert "vitest detected via package.json" "false"
    fi
fi

# --- Repo self-run always returns valid JSON ---
self_out="$("$TOOL" --root "$ROOT_DIR")"
if command -v jq >/dev/null 2>&1; then
    if echo "$self_out" | jq -e '.languages' >/dev/null 2>&1; then
        assert "Self-run returns valid .languages array" "true"
    else
        assert "Self-run returns valid .languages array" "false"
    fi
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit "$FAIL"
