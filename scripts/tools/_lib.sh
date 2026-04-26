#!/usr/bin/env bash
# Shared helpers for scripts/tools/*.sh.
#
# Sourced, not executed. No side effects at source time.

# shellcheck shell=bash

json_escape() {
    # Fast-path with bash substitution for the common cases, then strip any
    # remaining ASCII control chars (0x00-0x1F minus the ones we already mapped)
    # and the DEL char so we always emit valid JSON, even when input comes from
    # adversarial filenames or repository content.
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\t'/\\t}"
    s="${s//$'\r'/}"
    # Drop any other control chars (NUL, BEL, FF, VT, ESC, …) and DEL.
    s=$(printf '%s' "$s" | LC_ALL=C tr -d '\000-\010\013\014\016-\037\177')
    printf '%s' "$s"
}

# Extract a top-level YAML frontmatter field value from a Markdown file.
get_yaml_field() {
    local file="$1"
    local key="$2"
    awk -v key="$key" '
        NR == 1 && /^---$/ { in_fm = 1; next }
        in_fm && /^---$/ { exit }
        in_fm {
            if ($0 ~ "^"key":[[:space:]]*") {
                val = $0
                sub("^"key":[[:space:]]*", "", val)
                if (val ~ /^".*"$/) { val = substr(val, 2, length(val)-2) }
                sub(/[[:space:]]+$/, "", val)
                print val
                exit
            }
        }
    ' "$file"
}

# Locate the `graph` binary (Draft knowledge graph CLI). Sets GRAPH_BIN
# globally; returns 0 if found, 1 otherwise. Search order:
#   1. Plugin install breadcrumb files
#   2. `graph` on $PATH
#   3. <repo>/graph/bin/graph
#   4. <tool-repo>/graph/bin/graph (self-hosted in draft repo)
find_graph_bin() {
    local repo_abs="$1"
    local self_repo="$2"
    GRAPH_BIN=""

    local breadcrumb
    for breadcrumb in \
        "$HOME/.cursor/plugins/local/draft/.draft-install-path" \
        "$HOME/.claude-plugin/../.draft-install-path"; do
        if [[ -f "$breadcrumb" ]]; then
            local candidate
            candidate="$(cat "$breadcrumb")/graph/bin/graph"
            if [[ -x "$candidate" ]]; then
                GRAPH_BIN="$candidate"
                return 0
            fi
        fi
    done

    if command -v graph >/dev/null 2>&1; then
        GRAPH_BIN="graph"
        return 0
    fi

    if [[ -n "$repo_abs" && -x "$repo_abs/graph/bin/graph" ]]; then
        GRAPH_BIN="$repo_abs/graph/bin/graph"
        return 0
    fi

    if [[ -n "$self_repo" && -x "$self_repo/graph/bin/graph" ]]; then
        GRAPH_BIN="$self_repo/graph/bin/graph"
        return 0
    fi

    return 1
}
