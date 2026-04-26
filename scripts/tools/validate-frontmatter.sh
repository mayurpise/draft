#!/usr/bin/env bash
# validate-frontmatter.sh — validate YAML frontmatter of a Markdown file.
#
# Checks:
#   1. File starts with a "---" delimiter on line 1.
#   2. A closing "---" delimiter exists.
#   3. Every --require field is present as a top-level key.
#
# Usage:
#   scripts/tools/validate-frontmatter.sh <FILE> [--require FIELD[,FIELD...]]
#
# Exit codes: 0 valid, 1 invalid, 2 file not found.
set -euo pipefail

FILE=""
REQUIRED=""

usage() {
    cat <<'EOF'
validate-frontmatter.sh — validate a Markdown file's YAML frontmatter.

Usage:
  scripts/tools/validate-frontmatter.sh <FILE> [--require FIELD[,FIELD...]]

Flags:
  --require LIST   Comma-separated required top-level keys (default: name,description).
  --help           Show this help.

Exit 0 valid, 1 invalid (writes diagnostics to stderr), 2 file not found.
EOF
}

REQUIRED="name,description"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --require) REQUIRED="$2"; shift 2;;
        --help|-h) usage; exit 0;;
        -*) echo "Unknown flag: $1" >&2; usage >&2; exit 1;;
        *)
            if [[ -z "$FILE" ]]; then FILE="$1"
            else echo "Unexpected arg: $1" >&2; exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$FILE" ]]; then
    usage >&2
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "ERROR: file not found: $FILE" >&2
    exit 2
fi

IFS= read -r first_line <"$FILE" || true
# Tolerate CRLF input (Windows-edited files): strip a trailing \r.
first_line="${first_line%$'\r'}"
if [[ "$first_line" != "---" ]]; then
    echo "ERROR: $FILE — missing opening '---' delimiter on line 1" >&2
    exit 1
fi

if ! awk 'NR > 1 && /^---\r?$/ { found=1; exit } END { exit !found }' "$FILE"; then
    echo "ERROR: $FILE — missing closing '---' delimiter" >&2
    exit 1
fi

frontmatter="$(awk '
    NR == 1 && /^---$/ { in_fm = 1; next }
    in_fm && /^---$/ { exit }
    in_fm { print }
' "$FILE")"

# Validate each required field is present at top-level (no indentation).
IFS=',' read -ra FIELDS <<<"$REQUIRED"
MISSING=()
for field in "${FIELDS[@]}"; do
    field="${field// /}"
    [[ -z "$field" ]] && continue
    if ! printf '%s\n' "$frontmatter" | grep -qE "^${field}:"; then
        MISSING+=("$field")
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "ERROR: $FILE — missing required frontmatter fields: ${MISSING[*]}" >&2
    exit 1
fi

exit 0
