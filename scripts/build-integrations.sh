#!/usr/bin/env bash
#
# Build integration files from skill sources
# Generates: GitHub Copilot copilot-instructions.md + Gemini GEMINI.md
#
# Note: Cursor integration removed - Cursor now supports .claude/ plugin structure natively.
# Use: Cursor > Settings > Rules, Skills, Subagents > Rules > New > Add from Github
#
# Skills are the single source of truth for all integrations.
#
# Adding a new skill:
#   1. Create skills/<name>/SKILL.md
#   2. Add the skill name to SKILL_ORDER array below
#   3. Add display name and trigger to the case statements
#   4. Run this script
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"
COPILOT_OUTPUT="$ROOT_DIR/integrations/copilot/.github/copilot-instructions.md"

# ─────────────────────────────────────────────────────────
# Shared: skill ordering and metadata
# ─────────────────────────────────────────────────────────

SKILL_ORDER=(
    draft
    init
    index
    new-track
    decompose
    implement
    coverage
    bughunt
    review
    deep-review
    learn
    adr
    status
    revert
    change
    jira-preview
    jira-create
)

get_skill_header() {
    local skill="$1"
    case "$skill" in
        draft)        echo "Draft Overview" ;;
        init)         echo "Init Command" ;;
        index)        echo "Index Command" ;;
        new-track)    echo "New Track Command" ;;
        decompose)    echo "Decompose Command" ;;
        implement)    echo "Implement Command" ;;
        coverage)     echo "Coverage Command" ;;
        bughunt)      echo "Bug Hunt Command" ;;
        review)       echo "Review Command" ;;
        deep-review)  echo "Deep Review Command" ;;
        learn)        echo "Learn Command" ;;
        adr)          echo "ADR Command" ;;
        status)       echo "Status Command" ;;
        revert)       echo "Revert Command" ;;
        change)       echo "Change Command" ;;
        jira-preview) echo "Jira Preview Command" ;;
        jira-create)  echo "Jira Create Command" ;;
        *)            echo "$(echo "${skill:0:1}" | tr '[:lower:]' '[:upper:]')${skill:1} Command" ;;
    esac
}

# Common logic for trigger generation
get_trigger() {
    local skill="$1"
    local prefix="$2"
    case "$skill" in
        draft)        echo "\"help\" or \"${prefix}draft\"" ;;
        init)         echo "\"init draft\" or \"${prefix}draft init [refresh]\"" ;;
        index)        echo "\"index services\" or \"${prefix}draft index [--init-missing]\"" ;;
        new-track)    echo "\"new feature\" or \"${prefix}draft new-track <description>\"" ;;
        decompose)    echo "\"break into modules\" or \"${prefix}draft decompose\"" ;;
        implement)    echo "\"implement\" or \"${prefix}draft implement\"" ;;
        coverage)     echo "\"check coverage\" or \"${prefix}draft coverage\"" ;;
        bughunt)      echo "\"hunt bugs\" or \"${prefix}draft bughunt [--track <id>]\"" ;;
        review)       echo "\"review code\" or \"${prefix}draft review [--track <id>] [--full]\"" ;;
        deep-review)  echo "\"deep review\" or \"${prefix}draft deep-review [module]\"" ;;
        learn)        echo "\"learn patterns\" or \"${prefix}draft learn [promote|migrate|path]\"" ;;
        adr)          echo "\"document decision\" or \"${prefix}draft adr [title]\"" ;;
        status)       echo "\"status\" or \"${prefix}draft status\"" ;;
        revert)       echo "\"revert\" or \"${prefix}draft revert\"" ;;
        change)       echo "\"handle change\" or \"${prefix}draft change <description>\"" ;;
        jira-preview) echo "\"preview jira\" or \"${prefix}draft jira-preview [track-id]\"" ;;
        jira-create)  echo "\"create jira\" or \"${prefix}draft jira-create [track-id]\"" ;;
        *)            echo "\"${prefix}draft $skill\"" ;;
    esac
}

# Gemini uses @draft syntax
# (Removed Gemini trigger)


# Copilot uses natural language (no @ mentions)
get_copilot_trigger() {
    get_trigger "$1" ""
}

# ─────────────────────────────────────────────────────────
# Shared: content extraction and transforms
# ─────────────────────────────────────────────────────────

# Extract body content from a SKILL.md file (strip YAML frontmatter)
extract_body() {
    local file="$1"

    # Check that file starts with frontmatter delimiter
    if [[ "$(head -1 "$file")" != "---" ]]; then
        echo "ERROR: Missing YAML frontmatter in $file" >&2
        echo "  Skill files must start with --- delimiter on line 1" >&2
        return 1
    fi

    # Extract and validate frontmatter (awk stops at closing ---, naturally bounded)
    local frontmatter
    frontmatter=$(awk '
        /^---$/ { if (!seen_first) { seen_first=1; next } else { exit } }
        seen_first { print }
    ' "$file")

    # Validate required fields
    if ! echo "$frontmatter" | grep -q "^name:"; then
        echo "ERROR: Missing 'name:' field in frontmatter of $file" >&2
        return 1
    fi

    if ! echo "$frontmatter" | grep -q "^description:"; then
        echo "ERROR: Missing 'description:' field in frontmatter of $file" >&2
        return 1
    fi

    # Extract body (existing logic)
    awk '
        BEGIN { in_frontmatter = 0; found_end = 0 }
        /^---$/ {
            if (in_frontmatter == 0) {
                in_frontmatter = 1
                next
            } else if (found_end == 0) {
                found_end = 1
                next
            }
        }
        found_end == 1 { print }
    ' "$file"
}

# Gemini transform: /draft: → @draft
# (Removed Gemini transform)


# Copilot transform: /draft: → draft (no @)
transform_copilot_syntax() {
    sed -E \
        -e 's|/draft:([a-z0-9-]+)|draft \1|g' \
        -e 's|@draft([^a-z0-9_-])|draft\1|g' \
        -e 's|@draft$|draft|g' \
        -e 's|`@draft`|`draft`|g' \
        -e 's|`@draft |`draft |g' \
        -e 's#@(architect|debugger|planner|rca|reviewer)([^a-z0-9_-])#@workspace\2#g' \
        -e 's#@(architect|debugger|planner|rca|reviewer)$#@workspace#g'
}

# ─────────────────────────────────────────────────────────
# Shared: core files to inline
# ─────────────────────────────────────────────────────────

CORE_DIR="$ROOT_DIR/core"

# Core files referenced by skills - inline into integrations
CORE_FILES=(
    # Methodology
    "methodology.md"
    "knowledge-base.md"
    # Shared procedures
    "shared/draft-context-loading.md"
    "shared/git-report-metadata.md"
    "shared/pattern-learning.md"
    # Templates
    "templates/guardrails.md"
    "templates/intake-questions.md"
    "templates/ai-context.md"
    "templates/architecture.md"
    "templates/jira.md"
    "templates/product.md"
    "templates/tech-stack.md"
    "templates/workflow.md"
    "templates/spec.md"
    "templates/plan.md"
    # Index templates (monorepo)
    "templates/service-index.md"
    "templates/dependency-graph.md"
    "templates/tech-matrix.md"
    "templates/root-product.md"
    "templates/root-architecture.md"
    "templates/root-tech-stack.md"
    # Agents
    "agents/architect.md"
    "agents/debugger.md"
    "agents/planner.md"
    "agents/rca.md"
    "agents/reviewer.md"
)

# Emit all core files as appendices
# Takes transform function as argument to apply correct syntax
emit_core_files() {
    local transform_fn="$1"

    echo ""
    echo "---"
    echo ""
    echo "# Core Reference Files"
    echo ""
    echo "> These files are inlined for integrations that cannot access the core/ directory at runtime."
    echo ""

    for core_file in "${CORE_FILES[@]}"; do
        local full_path="$CORE_DIR/$core_file"
        if [[ -f "$full_path" ]]; then
            echo ""
            echo "---"
            echo ""
            echo "## core/${core_file}"
            echo ""
            echo "<core-file path=\"core/${core_file}\">"
            echo ""
            # Apply transform to core file content
            "$transform_fn" < "$full_path"
            echo ""
            echo "</core-file>"
        else
            echo "" >&2
            echo "ERROR: Core file not found: $full_path" >&2
            exit 1
        fi
    done
}

# ─────────────────────────────────────────────────────────
# Shared: quality disciplines, communication, behaviors
# ─────────────────────────────────────────────────────────

emit_quality_disciplines() {
    cat << 'QUALITY'
## Quality Disciplines

### Verification Before Completion
**Iron Law:** No completion claims without fresh verification evidence.
- Run verification command (test/build/lint) IN THIS MESSAGE
- Show output as evidence
- Only then mark `[x]`

### Systematic Debugging (Debugger Agent)
**Iron Law:** No fixes without root cause investigation first.

When blocked (`[!]`), follow the four phases IN ORDER:

1. **Investigate** - Read errors, reproduce, trace data flow (NO fixes yet)
   - Read full error message, stack trace, logs
   - Reproduce consistently
   - Trace data from input to error point
   - Document what you observe

2. **Analyze** - Find similar working code, list differences
   - Compare working vs. failing cases
   - Check and verify each assumption
   - Narrow to the smallest change that breaks

3. **Hypothesize** - Single hypothesis, smallest test
   - One cause, one test — predict outcome before running
   - If wrong, return to Analyze (don't try random fixes)

4. **Implement** - Regression test first, then fix
   - Write a test that fails now, will pass after fix
   - Minimal fix for root cause only
   - Run full test suite to confirm no breakage
   - Document root cause in plan.md

**Anti-patterns:** "Let me try this...", changing multiple things at once, skipping reproduction, fixing without understanding. If after 3 hypothesis cycles no root cause found: document findings, list eliminations, ask for external input.

### Three-Stage Review (Reviewer Agent)
At phase boundaries, run ALL three stages in order:

**Stage 1: Automated Validation** (REQUIRED) — Is the code structurally sound and secure?
- Architecture conformance (no pattern violations, module boundaries respected)
- Dead code detection (no unused exports, no unreachable paths)
- Dependency cycle check (no circular imports)
- Security scan (no hardcoded secrets, no injection risks)
- Performance anti-patterns (no N+1 queries, no blocking I/O in async)

**If Stage 1 FAILS:** Stop. List structural failures and return to implementation.

**Stage 2: Spec Compliance** (only if Stage 1 passes) — Did we build what was specified?
- All functional requirements implemented
- All acceptance criteria met
- No missing features, no scope creep
- Edge cases and error scenarios addressed

**If Stage 2 FAILS:** Stop. List gaps and return to implementation.

**Stage 3: Code Quality** (only if Stage 2 passes) — Is the code well-crafted?
- Follows project patterns (tech-stack.md)
- Appropriate error handling
- Tests cover real logic (not implementation details)
- No obvious performance or security issues

**Issue Classification:**
- **Critical** — Blocks release, breaks functionality, security issue → Must fix before proceeding
- **Important** — Degrades quality, creates tech debt → Should fix before phase complete
- **Minor** — Style, optimization → Note for later, don't block

Only proceed to next phase if Stage 1 passes and no Critical issues remain.

### Architecture Agent (when architecture mode enabled)

**Module Decomposition Rules:**
1. Single Responsibility — each module owns one concern
2. Size Constraint — 1-3 files per module; split if more
3. Clear API Boundary — every module has a defined public interface
4. Minimal Coupling — communicate through interfaces, not internals
5. Testable in Isolation — each module can be unit-tested independently

**Cycle-Breaking:** When circular dependencies detected:
- Extract shared interface into a new `<concern>-types` or `<concern>-core` module
- Invert dependency (accept callback/interface instead of importing)
- Merge if modules are actually one concern split artificially

**Story Lifecycle:**
QUALITY
}

emit_communication() {
    cat << 'COMMUNICATION'
## Communication Style

Lead with conclusions. Be concise. Prioritize clarity over comprehensiveness.

- Direct, professional tone
- Code over explanation when implementing
- Complete, runnable code blocks
- Show only changed lines with context for updates
- Ask clarifying questions only when requirements are genuinely ambiguous

COMMUNICATION
}

emit_proactive() {
    cat << 'PROACTIVE'
## Proactive Behaviors

1. **Context Loading** - Always read relevant draft files before acting
2. **Progress Tracking** - Update plan.md and metadata.json after each task
3. **Verification Prompts** - Ask for manual verification at phase boundaries
4. **Commit Suggestions** - Suggest commits following workflow.md patterns

## Error Recovery

If user seems lost:
- Check status to orient them
- Reference the active track's spec.md for requirements
- Suggest next steps based on plan.md state
PROACTIVE
}

# ─────────────────────────────────────────────────────────
# Shared integration builder
# ─────────────────────────────────────────────────────────

build_integration() {
    local command_prefix="$1"        # "@draft" | "draft"
    local get_trigger_fn="$2"        # "get_gemini_trigger" | "get_copilot_trigger"
    local transform_fn="$3"          # "transform_gemini_syntax" | "transform_copilot_syntax"
    local story_marker="$4"          # "@draft" | "draft"

    # Header (common for all integrations)
    cat << 'COMMON_HEADER'
# Draft - Context-Driven Development

You are operating with the Draft methodology for Context-Driven Development.

**Measure twice, code once.**

## Core Workflow

**Context -> Spec & Plan -> Implement**

Every feature follows this lifecycle:
1. **Setup** - Initialize project context (once per project)
2. **New Track** - Create specification and plan
3. **Implement** - Execute tasks with TDD workflow
4. **Verify** - Confirm acceptance criteria met

## Project Context Files

When `draft/` exists in the project, always consider:
- `draft/.ai-context.md` - Source of truth for AI agents (dense codebase understanding)
- `draft/architecture.md` - Human-readable engineering guide (derived from .ai-context.md)
- `draft/product.md` - Product vision and goals
- `draft/tech-stack.md` - Technical constraints
- `draft/workflow.md` - TDD and commit preferences
- `draft/tracks.md` - Active work items

## Available Commands

| Command | Purpose |
|---------|---------|
COMMON_HEADER

    # Command table with parameterized prefix
    echo "| \`${command_prefix}\` | Show overview and available commands |"
    echo "| \`${command_prefix} init\` | Initialize project (run once) |"
    echo "| \`${command_prefix} index [--init-missing]\` | Aggregate monorepo service contexts |"
    echo "| \`${command_prefix} new-track <description>\` | Create feature/bug track |"
    echo "| \`${command_prefix} decompose\` | Module decomposition with dependency mapping |"
    echo "| \`${command_prefix} implement\` | Execute tasks from plan |"
    echo "| \`${command_prefix} coverage\` | Code coverage report (target 95%+) |"
    echo "| \`${command_prefix} bughunt [--track <id>]\` | Systematic bug discovery |"
    echo "| \`${command_prefix} review [--track <id>]\` | Three-stage code review |"
    echo "| \`${command_prefix} deep-review [module]\` | Exhaustive production-grade module audit |"
    echo "| \`${command_prefix} learn [promote\\|migrate]\` | Discover coding patterns, update guardrails |"
    echo "| \`${command_prefix} adr [title]\` | Architecture Decision Records |"
    echo "| \`${command_prefix} status\` | Show progress overview |"
    echo "| \`${command_prefix} revert\` | Git-aware rollback |"
    echo "| \`${command_prefix} change <description>\` | Handle mid-track requirement changes |"
    echo "| \`${command_prefix} jira-preview [track-id]\` | Generate jira-export.md for review |"
    echo "| \`${command_prefix} jira-create [track-id]\` | Create Jira issues from export via MCP |"

    # Rest of header (common)
    cat << 'COMMON_HEADER2'

## Intent Mapping

Recognize these natural language patterns:

| User Says | Action |
|-----------|--------|
| "set up the project" | Run init |
| "index services", "aggregate context" | Run index |
| "new feature", "add X" | Create new track |
| "break into modules", "decompose" | Run decompose |
| "start implementing" | Execute implement |
| "check coverage", "test coverage" | Run coverage |
| "hunt bugs", "find bugs" | Run bug hunt |
| "review code", "review track", "check quality" | Run review |
| "deep review", "production audit", "module audit" | Run deep-review |
| "learn patterns", "update guardrails", "discover conventions" | Run learn |
| "what's the status" | Show status |
| "undo", "revert" | Run revert |
| "requirements changed", "scope changed", "update the spec" | Run change |
| "preview jira", "export to jira" | Run jira-preview |
| "create jira", "push to jira" | Run jira-create |
| "document decision", "create ADR" | Create architecture decision record |
| "help", "what commands" | Show draft overview |
| "the plan" | Read active track's plan.md |
| "the spec" | Read active track's spec.md |

## Tracks

A **track** is a high-level unit of work (feature, bug fix, refactor). Each track contains:
- `spec.md` - Requirements and acceptance criteria
- `plan.md` - Phased task breakdown
- `metadata.json` - Status and timestamps

Located at: `draft/tracks/<track-id>/`

## Status Markers

Recognize and use these throughout plan.md:
- `[ ]` - Pending
- `[~]` - In Progress
- `[x]` - Completed
- `[!]` - Blocked

COMMON_HEADER2

    # Skill loop with parameterized trigger and transform functions
    for skill in "${SKILL_ORDER[@]}"; do
        # Skip 'draft' skill — its content (commands table, core workflow,
        # status markers) is already covered by the static COMMON_HEADER above.
        if [[ "$skill" == "draft" ]]; then
            continue
        fi

        # Validate skill name format (security: prevent path traversal)
        if [[ ! "$skill" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
            echo "ERROR: Invalid skill name '$skill' (must be kebab-case: start with letter, no leading/trailing hyphens)" >&2
            exit 1
        fi

        local skill_file="$SKILLS_DIR/$skill/SKILL.md"
        if [[ -f "$skill_file" ]]; then
            # Extract body once and cache (avoids double file read + inconsistent error handling)
            local skill_body
            skill_body=$(extract_body "$skill_file")

            # Validate body format: line 1 blank, line 2 starts with #, line 3 blank
            local line1 line2 line3
            line1=$(echo "$skill_body" | sed -n '1p')
            line2=$(echo "$skill_body" | sed -n '2p')
            line3=$(echo "$skill_body" | sed -n '3p')
            if [[ -n "$line1" ]] || [[ ! "$line2" =~ ^#\  ]] || [[ -n "$line3" ]]; then
                echo "ERROR: Skill '$skill' body format invalid (expected: blank, '# Title', blank). Got:" >&2
                echo "  Line 1: '${line1}'" >&2
                echo "  Line 2: '${line2}'" >&2
                echo "  Line 3: '${line3}'" >&2
                exit 1
            fi

            echo ""
            echo "---"
            echo ""
            echo "## $(get_skill_header "$skill")"
            echo ""
            echo "When user says $($get_trigger_fn "$skill"):"
            echo ""
            echo "$skill_body" | "$transform_fn" | tail -n +4
        else
            echo "" >&2
            echo "ERROR: Skill file not found: $skill_file" >&2
            exit 1
        fi
    done

    echo ""
    echo "---"
    echo ""

    emit_quality_disciplines

    # Story lifecycle with parameterized command marker
    echo "1. Placeholder during \`${story_marker} decompose\` → \"[placeholder]\" in architecture.md"
    echo "2. Written during \`${story_marker} implement\` → code comment at file top, summary in architecture.md"
    echo "3. Updated during refactoring → code comment is source of truth"
    echo ""
    echo "### Red Flags - STOP if you're:"
    echo "- Making completion claims without running verification"
    echo "- Fixing bugs without investigating root cause"
    echo "- Skipping spec compliance check at phase boundary"
    echo "- Writing code before tests (when TDD enabled)"
    echo "- Reporting status without reading actual files"
    echo ""

    echo ""
    echo "---"
    echo ""

    emit_communication
    emit_proactive

    # Inline core files for integrations that can't access core/ at runtime
    emit_core_files "$transform_fn"

    # Completeness sentinel — verified by verify_output
    echo ""
    echo "<!-- DRAFT_BUILD_COMPLETE -->"
}

# ─────────────────────────────────────────────────────────
# Copilot: build copilot-instructions.md
# ─────────────────────────────────────────────────────────

build_copilot() {
    build_integration "draft" "get_copilot_trigger" "transform_copilot_syntax" "draft"
}

# ─────────────────────────────────────────────────────────
# Gemini: build GEMINI.md
# ─────────────────────────────────────────────────────────

# (Removed build_gemini)


# ─────────────────────────────────────────────────────────
# Verification helpers
# ─────────────────────────────────────────────────────────

verify_output() {
    local label="$1"
    local output_file="$2"
    local expect_at_draft="$3"  # "yes" or "no"

    local line_count old_syntax_count at_draft_count
    # Single pass with awk to count lines and check patterns
    read -r line_count old_syntax_count at_draft_count < <(awk '
        {
            total_lines++
            if (/\/draft:/) old_count++
            if (/@draft/) at_count++
        }
        END {
            print total_lines+0, old_count+0, at_count+0
        }
    ' "$output_file")

    echo "  Lines: $line_count"

    # Verify completeness sentinel (catches truncated output from disk-full etc.)
    if ! tail -5 "$output_file" | grep -q "DRAFT_BUILD_COMPLETE"; then
        echo "  FAIL: Missing completeness sentinel — output may be truncated" >&2
        return 1
    fi

    # Verify minimum line count (a valid build is always >1000 lines)
    if [[ "$line_count" -lt 1000 ]]; then
        echo "  FAIL: Output too small ($line_count lines, expected >1000) — likely truncated or incomplete" >&2
        return 1
    fi

    # Count skills included
    local skill_count=0
    for skill in "${SKILL_ORDER[@]}"; do
        if [[ -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
            skill_count=$((skill_count + 1))
        fi
    done
    echo "  Skills: $skill_count/${#SKILL_ORDER[@]}"

    # Verify no /draft: references remain
    if [[ "$old_syntax_count" -gt 0 ]]; then
        echo "  WARNING: Found $old_syntax_count '/draft:' references (should be 0)"
        return 1
    else
        echo "  Syntax check: OK (no /draft: references)"
    fi

    # Verify @draft presence based on integration type
    if [[ "$expect_at_draft" == "yes" ]]; then
        echo "  Found $at_draft_count '@draft' references"
    else
        if [[ "$at_draft_count" -gt 0 ]]; then
            echo "  WARNING: Found $at_draft_count '@draft' references (should be 0 for $label)" >&2
            echo "  Offending lines:" >&2
            grep -n '@draft' "$output_file" | head -5 >&2
            return 1
        else
            echo "  Syntax check: OK (no @draft references)"
        fi
    fi

    # Note: Agent references to core/agents/*.md are now preserved (not stripped)
    echo "  Agent refs: preserved (not stripped)"

    return 0
}

# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

main() {
    echo "Building integrations from skills..."
    echo ""
    echo "Note: Cursor integration removed - Cursor now supports .claude/ plugin structure natively."
    echo ""

    # Ensure output directories exist
    mkdir -p "$(dirname "$COPILOT_OUTPUT")"

    local start_seconds=$SECONDS

    # Generate Copilot integration (atomic: write to temp, verify, then mv)
    echo "── Copilot ─────────────────────────────────────"
    local copilot_tmp
    copilot_tmp=$(mktemp "${COPILOT_OUTPUT}.XXXXXX")
    trap 'rm -f "$copilot_tmp"' EXIT
    build_copilot > "$copilot_tmp"
    echo "  Generated: $COPILOT_OUTPUT"
    if verify_output "Copilot" "$copilot_tmp" "no"; then
        mv "$copilot_tmp" "$COPILOT_OUTPUT"
        trap - EXIT
    else
        rm -f "$copilot_tmp"
        trap - EXIT
        exit 1
    fi
    echo ""

    local elapsed=$((SECONDS - start_seconds))
    echo "All integrations built successfully. (${elapsed}s)"
}

main "$@"
