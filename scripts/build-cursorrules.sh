#!/usr/bin/env bash
#
# Build .cursorrules from skill files
# Skills become the single source of truth for Cursor integration
#
# Adding a new skill:
#   1. Create skills/<name>/SKILL.md
#   2. Add the skill name to SKILL_ORDER array below
#   3. Add display name and trigger to the case statement
#   4. Run this script
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"
OUTPUT_FILE="$ROOT_DIR/integrations/cursor/.cursorrules"

# Ordered skill list — controls output order
# Overview first, then workflow order
SKILL_ORDER=(
    draft
    init
    new-track
    decompose
    implement
    coverage
    status
    revert
    jira-preview
    jira-create
)

# Display name and trigger phrase for each skill
get_skill_header() {
    local skill="$1"
    case "$skill" in
        draft)        echo "Draft Overview" ;;
        init)         echo "Init Command" ;;
        new-track)    echo "New Track Command" ;;
        decompose)    echo "Decompose Command" ;;
        implement)    echo "Implement Command" ;;
        coverage)     echo "Coverage Command" ;;
        status)       echo "Status Command" ;;
        revert)       echo "Revert Command" ;;
        jira-preview) echo "Jira Preview Command" ;;
        jira-create)  echo "Jira Create Command" ;;
        *)            echo "${skill^} Command" ;;
    esac
}

get_skill_trigger() {
    local skill="$1"
    case "$skill" in
        draft)        echo "\"help\" or \"@draft\"" ;;
        init)         echo "\"init draft\" or \"@draft init\"" ;;
        new-track)    echo "\"new feature\" or \"@draft new-track <description>\"" ;;
        decompose)    echo "\"break into modules\" or \"@draft decompose\"" ;;
        implement)    echo "\"implement\" or \"@draft implement\"" ;;
        coverage)     echo "\"check coverage\" or \"@draft coverage\"" ;;
        status)       echo "\"status\" or \"@draft status\"" ;;
        revert)       echo "\"revert\" or \"@draft revert\"" ;;
        jira-preview) echo "\"preview jira\" or \"@draft jira-preview [track-id]\"" ;;
        jira-create)  echo "\"create jira\" or \"@draft jira-create [track-id]\"" ;;
        *)            echo "\"@draft $skill\"" ;;
    esac
}

# Extract body content from a SKILL.md file (strip YAML frontmatter)
extract_body() {
    local file="$1"
    # Skip lines until we find the closing ---, then print everything after
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

# Transform /draft: syntax to @draft syntax and replace dead agent references
transform_syntax() {
    sed -E \
        -e 's|/draft:([a-z-]+)|@draft \1|g' \
        -e 's|See `core/agents/[a-z]+\.md`[^.]*\.?|(see Quality Disciplines section)|g' \
        -e 's|\(see `core/agents/[a-z]+\.md`\)|(see Quality Disciplines section)|g' \
        -e 's|`core/agents/[a-z]+\.md`|Quality Disciplines section|g'
}

# Build the complete .cursorrules file
build_cursorrules() {
    cat << 'HEADER'
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
| `@draft` | Show overview and available commands |
| `@draft init` | Initialize project (run once) |
| `@draft new-track <description>` | Create feature/bug track |
| `@draft decompose` | Module decomposition with dependency mapping |
| `@draft implement` | Execute tasks from plan |
| `@draft coverage` | Code coverage report (target 95%+) |
| `@draft status` | Show progress overview |
| `@draft revert` | Git-aware rollback |
| `@draft jira-preview [track-id]` | Generate jira-export.md for review |
| `@draft jira-create [track-id]` | Create Jira issues from export via MCP |

## Intent Mapping

Recognize these natural language patterns:

| User Says | Action |
|-----------|--------|
| "set up the project" | Run init |
| "new feature", "add X" | Create new track |
| "break into modules", "decompose" | Run decompose |
| "start implementing" | Execute implement |
| "check coverage", "test coverage" | Run coverage |
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

HEADER

    # Add each skill's content dynamically
    for skill in "${SKILL_ORDER[@]}"; do
        local skill_file="$SKILLS_DIR/$skill/SKILL.md"
        if [[ -f "$skill_file" ]]; then
            echo ""
            echo "---"
            echo ""
            echo "## $(get_skill_header "$skill")"
            echo ""
            echo "When user says $(get_skill_trigger "$skill"):"
            echo ""
            extract_body "$skill_file" | transform_syntax | tail -n +4
        else
            echo "" >&2
            echo "WARNING: Skill file not found: $skill_file" >&2
        fi
    done

    echo ""
    echo "---"
    echo ""

    # Quality Disciplines with inlined agent summaries
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
1. Placeholder during `@draft decompose` → "[placeholder]" in architecture.md
2. Written during `@draft implement` → code comment at file top, summary in architecture.md
3. Updated during refactoring → code comment is source of truth

### Red Flags - STOP if you're:
- Making completion claims without running verification
- Fixing bugs without investigating root cause
- Skipping spec compliance check at phase boundary
- Writing code before tests (when TDD enabled)
- Reporting status without reading actual files

QUALITY

    echo ""
    echo "---"
    echo ""

    # Communication Style
    cat << 'COMMUNICATION'
## Communication Style

Lead with conclusions. Be concise. Prioritize clarity over comprehensiveness.

- Direct, professional tone
- Code over explanation when implementing
- Complete, runnable code blocks
- Show only changed lines with context for updates
- Ask clarifying questions only when requirements are genuinely ambiguous

COMMUNICATION

    # Proactive Behaviors
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

# Main execution
main() {
    echo "Building .cursorrules from skills..."

    # Ensure output directory exists
    mkdir -p "$(dirname "$OUTPUT_FILE")"

    # Generate the file
    build_cursorrules > "$OUTPUT_FILE"

    # Report results
    local line_count
    line_count=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')

    echo "Generated: $OUTPUT_FILE"
    echo "Lines: $line_count"

    # Count skills included
    local skill_count=0
    for skill in "${SKILL_ORDER[@]}"; do
        if [[ -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
            skill_count=$((skill_count + 1))
        fi
    done
    echo "Skills: $skill_count/${#SKILL_ORDER[@]}"

    # Verify no /draft: references remain
    local old_syntax_count
    old_syntax_count=$(grep -c "/draft:" "$OUTPUT_FILE" 2>/dev/null || true)
    old_syntax_count=${old_syntax_count:-0}

    if [[ "$old_syntax_count" -gt 0 ]]; then
        echo "WARNING: Found $old_syntax_count '/draft:' references (should be 0)"
        exit 1
    else
        echo "Syntax check: OK (no /draft: references)"
    fi

    # Verify @draft commands present
    local new_syntax_count
    new_syntax_count=$(grep -c "@draft" "$OUTPUT_FILE" 2>/dev/null || true)
    new_syntax_count=${new_syntax_count:-0}
    echo "Found $new_syntax_count '@draft' references"

    # Verify no dead agent references
    local dead_refs
    dead_refs=$(grep -c "See \`core/agents/" "$OUTPUT_FILE" 2>/dev/null || true)
    dead_refs=${dead_refs:-0}

    if [[ "$dead_refs" -gt 0 ]]; then
        echo "WARNING: Found $dead_refs dead 'See core/agents/' references"
        exit 1
    else
        echo "Agent refs check: OK (no dead references)"
    fi
}

main "$@"
