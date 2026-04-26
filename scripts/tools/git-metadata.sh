#!/usr/bin/env bash
# git-metadata.sh — emit deterministic git metadata for Draft reports.
#
# Output is YAML frontmatter by default; --json emits the same fields as JSON.
#
# Usage:
#   scripts/tools/git-metadata.sh [--yaml|--json]
#                                 [--project NAME] [--module NAME]
#                                 [--track-id ID] [--generated-by CMD]
#                                 [--base BRANCH]
#
# Exit codes: 0 OK, 1 not a git repo or invocation error.
set -euo pipefail

# shellcheck source=_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

FORMAT="yaml"
PROJECT=""
MODULE="root"
TRACK_ID="null"
GENERATED_BY=""
BASE_BRANCH="main"

usage() {
    cat <<'EOF'
git-metadata.sh — emit deterministic git metadata for Draft reports.

Usage:
  scripts/tools/git-metadata.sh [--yaml|--json]
                                [--project NAME] [--module NAME]
                                [--track-id ID] [--generated-by CMD]
                                [--base BRANCH]

Flags:
  --yaml           Emit YAML frontmatter (default).
  --json           Emit JSON object.
  --project NAME   Project name (default: basename of repo).
  --module NAME    Module name (default: "root").
  --track-id ID    Track id (default: null).
  --generated-by   Command or skill name that produced the report.
  --base BRANCH    Upstream branch to compare against (default: main).
  --help           Show this help.

Exit codes: 0 OK, 1 not a git repo or invocation error.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yaml) FORMAT="yaml"; shift;;
        --json) FORMAT="json"; shift;;
        --project) PROJECT="$2"; shift 2;;
        --module) MODULE="$2"; shift 2;;
        --track-id) TRACK_ID="$2"; shift 2;;
        --generated-by) GENERATED_BY="$2"; shift 2;;
        --base) BASE_BRANCH="$2"; shift 2;;
        --help|-h) usage; exit 0;;
        *) echo "Unknown flag: $1" >&2; usage >&2; exit 1;;
    esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: not inside a git repository" >&2
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
if [[ -z "$PROJECT" ]]; then
    PROJECT="$(basename "$REPO_ROOT")"
fi

LOCAL_BRANCH="$(git branch --show-current 2>/dev/null || echo "")"
REMOTE_BRANCH="$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "none")"
FULL_SHA="$(git rev-parse HEAD)"
SHORT_SHA="$(git rev-parse --short HEAD)"
COMMIT_DATE="$(git log -1 --format=%cI HEAD)"
COMMIT_MESSAGE="$(git log -1 --format=%s HEAD)"
if [[ -n "$(git status --porcelain)" ]]; then
    DIRTY="true"
else
    DIRTY="false"
fi

# Ahead/behind vs base (graceful fallback if base missing)
AHEAD=0
BEHIND=0
if git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
    read -r BEHIND AHEAD < <(git rev-list --left-right --count "$BASE_BRANCH"...HEAD 2>/dev/null || echo "0 0")
fi

GENERATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Escape double quotes in commit message for JSON/YAML safety
escape_for_yaml() {
    # YAML double-quoted strings use \" and \\ as escapes
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    printf '%s' "$s"
}

if [[ "$FORMAT" == "json" ]]; then
    cat <<EOF
{
  "project": "$(json_escape "$PROJECT")",
  "module": "$(json_escape "$MODULE")",
  "track_id": $([[ "$TRACK_ID" == "null" ]] && echo "null" || echo "\"$(json_escape "$TRACK_ID")\""),
  "generated_by": $([[ -z "$GENERATED_BY" ]] && echo "null" || echo "\"$(json_escape "$GENERATED_BY")\""),
  "generated_at": "$GENERATED_AT",
  "git": {
    "branch": "$(json_escape "$LOCAL_BRANCH")",
    "remote": "$(json_escape "$REMOTE_BRANCH")",
    "commit": "$FULL_SHA",
    "commit_short": "$SHORT_SHA",
    "commit_date": "$COMMIT_DATE",
    "commit_message": "$(json_escape "$COMMIT_MESSAGE")",
    "dirty": $DIRTY,
    "base_branch": "$(json_escape "$BASE_BRANCH")",
    "commits_ahead_base": $AHEAD,
    "commits_behind_base": $BEHIND
  },
  "synced_to_commit": "$FULL_SHA"
}
EOF
else
    cat <<EOF
---
project: "$(escape_for_yaml "$PROJECT")"
module: "$(escape_for_yaml "$MODULE")"
track_id: $([[ "$TRACK_ID" == "null" ]] && echo "null" || echo "\"$(escape_for_yaml "$TRACK_ID")\"")
generated_by: $([[ -z "$GENERATED_BY" ]] && echo "null" || echo "\"$(escape_for_yaml "$GENERATED_BY")\"")
generated_at: "$GENERATED_AT"
git:
  branch: "$(escape_for_yaml "$LOCAL_BRANCH")"
  remote: "$(escape_for_yaml "$REMOTE_BRANCH")"
  commit: "$FULL_SHA"
  commit_short: "$SHORT_SHA"
  commit_date: "$COMMIT_DATE"
  commit_message: "$(escape_for_yaml "$COMMIT_MESSAGE")"
  dirty: $DIRTY
  base_branch: "$(escape_for_yaml "$BASE_BRANCH")"
  commits_ahead_base: $AHEAD
  commits_behind_base: $BEHIND
synced_to_commit: "$FULL_SHA"
---
EOF
fi
