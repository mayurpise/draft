#!/usr/bin/env bash
#
# Build integration files from skill sources
# Generates: Cursor .cursorrules + GitHub Copilot copilot-instructions.md
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
CURSOR_OUTPUT="$ROOT_DIR/integrations/cursor/.cursorrules"
COPILOT_OUTPUT="$ROOT_DIR/integrations/copilot/.github/copilot-instructions.md"
GEMINI_OUTPUT="$ROOT_DIR/integrations/gemini/GEMINI.md"

# ─────────────────────────────────────────────────────────
# Shared: skill ordering and metadata
# ─────────────────────────────────────────────────────────

SKILL_ORDER=(
    draft
    init
    new-track
    decompose
    implement
    coverage
    validate
    bughunt
    status
    revert
    jira-preview
    jira-create
)

get_skill_header() {
    local skill="$1"
    case "$skill" in
        draft)        echo "Draft Overview" ;;
        init)         echo "Init Command" ;;
        new-track)    echo "New Track Command" ;;
        decompose)    echo "Decompose Command" ;;
        implement)    echo "Implement Command" ;;
        coverage)     echo "Coverage Command" ;;
        validate)     echo "Validate Command" ;;
        bughunt)      echo "Bug Hunt Command" ;;
        status)       echo "Status Command" ;;
        revert)       echo "Revert Command" ;;
        jira-preview) echo "Jira Preview Command" ;;
        jira-create)  echo "Jira Create Command" ;;
        *)            echo "${skill^} Command" ;;
    esac
}

# Cursor uses @draft syntax
get_cursor_trigger() {
    local skill="$1"
    case "$skill" in
        draft)        echo "\"help\" or \"@draft\"" ;;
        init)         echo "\"init draft\" or \"@draft init [refresh]\"" ;;
        new-track)    echo "\"new feature\" or \"@draft new-track <description>\"" ;;
        decompose)    echo "\"break into modules\" or \"@draft decompose\"" ;;
        implement)    echo "\"implement\" or \"@draft implement\"" ;;
        coverage)     echo "\"check coverage\" or \"@draft coverage\"" ;;
        validate)     echo "\"validate\" or \"@draft validate [--track <id>]\"" ;;
        bughunt)      echo "\"hunt bugs\" or \"@draft bughunt [--track <id>]\"" ;;
        status)       echo "\"status\" or \"@draft status\"" ;;
        revert)       echo "\"revert\" or \"@draft revert\"" ;;
        jira-preview) echo "\"preview jira\" or \"@draft jira-preview [track-id]\"" ;;
        jira-create)  echo "\"create jira\" or \"@draft jira-create [track-id]\"" ;;
        *)            echo "\"@draft $skill\"" ;;
    esac
}

# Copilot uses natural language (no @ mentions)
get_copilot_trigger() {
    local skill="$1"
    case "$skill" in
        draft)        echo "\"help\" or \"draft\"" ;;
        init)         echo "\"init draft\" or \"draft init [refresh]\"" ;;
        new-track)    echo "\"new feature\" or \"draft new-track <description>\"" ;;
        decompose)    echo "\"break into modules\" or \"draft decompose\"" ;;
        implement)    echo "\"implement\" or \"draft implement\"" ;;
        coverage)     echo "\"check coverage\" or \"draft coverage\"" ;;
        validate)     echo "\"validate\" or \"draft validate [--track <id>]\"" ;;
        bughunt)      echo "\"hunt bugs\" or \"draft bughunt [--track <id>]\"" ;;
        status)       echo "\"status\" or \"draft status\"" ;;
        revert)       echo "\"revert\" or \"draft revert\"" ;;
        jira-preview) echo "\"preview jira\" or \"draft jira-preview [track-id]\"" ;;
        jira-create)  echo "\"create jira\" or \"draft jira-create [track-id]\"" ;;
        *)            echo "\"draft $skill\"" ;;
    esac
}

# ─────────────────────────────────────────────────────────
# Shared: content extraction and transforms
# ─────────────────────────────────────────────────────────

# Extract body content from a SKILL.md file (strip YAML frontmatter)
extract_body() {
    local file="$1"

    # Check for frontmatter delimiters
    if ! grep -q "^---$" "$file"; then
        echo "ERROR: Missing YAML frontmatter in $file" >&2
        echo "  Skill files must start with --- delimiter" >&2
        return 1
    fi

    # Extract and validate frontmatter (use || true to ignore SIGPIPE from head)
    local frontmatter
    frontmatter=$(awk '/^---$/{flag=!flag;next}flag' "$file" | head -20 || true)

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

# Base transform: /draft: → @draft
transform_cursor_syntax() {
    sed -E \
        -e 's|/draft:([a-z-]+)|@draft \1|g'
}

# Copilot transform: /draft: → draft (no @)
transform_copilot_syntax() {
    sed -E \
        -e 's|/draft:([a-z-]+)|draft \1|g' \
        -e 's|@draft |draft |g' \
        -e 's|`@draft`|`draft`|g' \
        -e 's|`@draft |`draft |g'
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

### Two-Stage Review (Reviewer Agent)
At phase boundaries, run BOTH stages in order:

**Stage 1: Spec Compliance** — Did we build what was specified?
- All functional requirements implemented
- All acceptance criteria met
- No missing features, no scope creep
- Edge cases and error scenarios addressed

**If Stage 1 FAILS:** Stop. List gaps and return to implementation.

**Stage 2: Code Quality** (only if Stage 1 passes) — Is the code well-crafted?
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
    local get_trigger_fn="$2"        # "get_cursor_trigger" | "get_copilot_trigger"
    local transform_fn="$3"          # "transform_cursor_syntax" | "transform_copilot_syntax"
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
    echo "| \`${command_prefix} new-track <description>\` | Create feature/bug track |"
    echo "| \`${command_prefix} decompose\` | Module decomposition with dependency mapping |"
    echo "| \`${command_prefix} implement\` | Execute tasks from plan |"
    echo "| \`${command_prefix} coverage\` | Code coverage report (target 95%+) |"
    echo "| \`${command_prefix} validate [--track <id>]\` | Codebase quality validation |"
    echo "| \`${command_prefix} bughunt [--track <id>]\` | Systematic bug discovery |"
    echo "| \`${command_prefix} status\` | Show progress overview |"
    echo "| \`${command_prefix} revert\` | Git-aware rollback |"
    echo "| \`${command_prefix} jira-preview [track-id]\` | Generate jira-export.md for review |"
    echo "| \`${command_prefix} jira-create [track-id]\` | Create Jira issues from export via MCP |"

    # Rest of header (common)
    cat << 'COMMON_HEADER2'

## Intent Mapping

Recognize these natural language patterns:

| User Says | Action |
|-----------|--------|
| "set up the project" | Run init |
| "new feature", "add X" | Create new track |
| "break into modules", "decompose" | Run decompose |
| "start implementing" | Execute implement |
| "check coverage", "test coverage" | Run coverage |
| "validate", "check quality" | Run validation |
| "hunt bugs", "find bugs" | Run bug hunt |
| "what's the status" | Show status |
| "undo", "revert" | Run revert |
| "preview jira", "export to jira" | Run jira-preview |
| "create jira", "push to jira" | Run jira-create |
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
        # Validate skill name format (security: prevent path traversal)
        if [[ ! "$skill" =~ ^[a-z0-9-]+$ ]]; then
            echo "ERROR: Invalid skill name '$skill' (must be lowercase alphanumeric + hyphens)" >&2
            exit 1
        fi

        local skill_file="$SKILLS_DIR/$skill/SKILL.md"
        if [[ -f "$skill_file" ]]; then
            echo ""
            echo "---"
            echo ""
            echo "## $(get_skill_header "$skill")"
            echo ""
            echo "When user says $($get_trigger_fn "$skill"):"
            echo ""
            extract_body "$skill_file" | $transform_fn | tail -n +4
        else
            echo "" >&2
            echo "WARNING: Skill file not found: $skill_file" >&2
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
}

# ─────────────────────────────────────────────────────────
# Cursor: build .cursorrules
# ─────────────────────────────────────────────────────────

build_cursorrules() {
    build_integration "@draft" "get_cursor_trigger" "transform_cursor_syntax" "@draft"
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

build_gemini() {
    # Gemini uses @draft syntax like Cursor
    build_integration "@draft" "get_cursor_trigger" "transform_cursor_syntax" "@draft"
}

# ─────────────────────────────────────────────────────────
# Verification helpers
# ─────────────────────────────────────────────────────────

verify_output() {
    local label="$1"
    local output_file="$2"
    local expect_at_draft="$3"  # "yes" or "no"

    local line_count
    line_count=$(wc -l < "$output_file" | tr -d ' ')
    echo "  Lines: $line_count"

    # Count skills included
    local skill_count=0
    for skill in "${SKILL_ORDER[@]}"; do
        if [[ -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
            skill_count=$((skill_count + 1))
        fi
    done
    echo "  Skills: $skill_count/${#SKILL_ORDER[@]}"

    # Verify no /draft: references remain
    local old_syntax_count
    old_syntax_count=$(grep -c "/draft:" "$output_file" 2>/dev/null || true)
    old_syntax_count=${old_syntax_count:-0}
    if [[ "$old_syntax_count" -gt 0 ]]; then
        echo "  WARNING: Found $old_syntax_count '/draft:' references (should be 0)"
        return 1
    else
        echo "  Syntax check: OK (no /draft: references)"
    fi

    # Verify @draft presence based on integration type
    local at_draft_count
    at_draft_count=$(grep -c "@draft" "$output_file" 2>/dev/null || true)
    at_draft_count=${at_draft_count:-0}
    if [[ "$expect_at_draft" == "yes" ]]; then
        echo "  Found $at_draft_count '@draft' references"
    else
        if [[ "$at_draft_count" -gt 0 ]]; then
            echo "  WARNING: Found $at_draft_count '@draft' references (should be 0 for $label)"
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

    # Ensure output directories exist
    mkdir -p "$(dirname "$CURSOR_OUTPUT")"
    mkdir -p "$(dirname "$COPILOT_OUTPUT")"
    mkdir -p "$(dirname "$GEMINI_OUTPUT")"

    # Generate Cursor integration
    echo "── Cursor ──────────────────────────────────────"
    build_cursorrules > "$CURSOR_OUTPUT"
    echo "  Generated: $CURSOR_OUTPUT"
    verify_output "Cursor" "$CURSOR_OUTPUT" "yes" || exit 1
    echo ""

    # Generate Copilot integration
    echo "── Copilot ─────────────────────────────────────"
    build_copilot > "$COPILOT_OUTPUT"
    echo "  Generated: $COPILOT_OUTPUT"
    verify_output "Copilot" "$COPILOT_OUTPUT" "no" || exit 1
    echo ""

    # Generate Gemini integration
    echo "── Gemini ──────────────────────────────────────"
    build_gemini > "$GEMINI_OUTPUT"
    echo "  Generated: $GEMINI_OUTPUT"
    verify_output "Gemini" "$GEMINI_OUTPUT" "yes" || exit 1
    echo ""

    echo "All integrations built successfully."
}

main "$@"
