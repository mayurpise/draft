#!/usr/bin/env bash
#
# Build .cursorrules from skill files
# Skills become the single source of truth for Cursor integration
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$ROOT_DIR/skills"
OUTPUT_FILE="$ROOT_DIR/integrations/cursor/.cursorrules"
METHODOLOGY_FILE="$ROOT_DIR/core/methodology.md"
DEBUGGER_FILE="$ROOT_DIR/core/agents/debugger.md"
REVIEWER_FILE="$ROOT_DIR/core/agents/reviewer.md"

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

# Extract body from agent files (same format as SKILL.md)
extract_agent_body() {
    local file="$1"
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

# Transform /draft: syntax to @draft syntax
transform_syntax() {
    sed -E 's|/draft:([a-z-]+)|@draft \1|g'
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
| `@draft init` | Initialize project (run once) |
| `@draft new-track <description>` | Create feature/bug track |
| `@draft implement` | Execute tasks from plan |
| `@draft status` | Show progress overview |
| `@draft revert` | Git-aware rollback |

## Intent Mapping

Recognize these natural language patterns:

| User Says | Action |
|-----------|--------|
| "set up the project" | Run init |
| "new feature", "add X" | Create new track |
| "start implementing" | Execute implement |
| "what's the status" | Show status |
| "undo", "revert" | Run revert |
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

    # Add each skill's content
    echo ""
    echo "---"
    echo ""

    # Init Command
    if [[ -f "$SKILLS_DIR/init/SKILL.md" ]]; then
        echo "## Init Command"
        echo ""
        echo "When user says \"init draft\" or \"@draft init\":"
        echo ""
        extract_body "$SKILLS_DIR/init/SKILL.md" | transform_syntax | tail -n +4
    fi

    echo ""
    echo "---"
    echo ""

    # New Track Command
    if [[ -f "$SKILLS_DIR/new-track/SKILL.md" ]]; then
        echo "## New Track Command"
        echo ""
        echo "When user says \"new feature\" or \"@draft new-track <description>\":"
        echo ""
        extract_body "$SKILLS_DIR/new-track/SKILL.md" | transform_syntax | tail -n +4
    fi

    echo ""
    echo "---"
    echo ""

    # Implement Command
    if [[ -f "$SKILLS_DIR/implement/SKILL.md" ]]; then
        echo "## Implement Command"
        echo ""
        echo "When user says \"implement\" or \"@draft implement\":"
        echo ""
        extract_body "$SKILLS_DIR/implement/SKILL.md" | transform_syntax | tail -n +4
    fi

    echo ""
    echo "---"
    echo ""

    # Status Command
    if [[ -f "$SKILLS_DIR/status/SKILL.md" ]]; then
        echo "## Status Command"
        echo ""
        echo "When user says \"status\" or \"@draft status\":"
        echo ""
        extract_body "$SKILLS_DIR/status/SKILL.md" | transform_syntax | tail -n +4
    fi

    echo ""
    echo "---"
    echo ""

    # Revert Command
    if [[ -f "$SKILLS_DIR/revert/SKILL.md" ]]; then
        echo "## Revert Command"
        echo ""
        echo "When user says \"revert\" or \"@draft revert\":"
        echo ""
        extract_body "$SKILLS_DIR/revert/SKILL.md" | transform_syntax | tail -n +4
    fi

    echo ""
    echo "---"
    echo ""

    # Quality Disciplines
    cat << 'QUALITY'
## Quality Disciplines

### Verification Before Completion
**Iron Law:** No completion claims without fresh verification evidence.
- Run verification command (test/build/lint) IN THIS MESSAGE
- Show output as evidence
- Only then mark `[x]`

### Systematic Debugging
**Iron Law:** No fixes without root cause investigation first.

When blocked (`[!]`):
1. **Investigate** - Read errors, reproduce, trace (NO fixes yet)
2. **Analyze** - Find similar working code, list differences
3. **Hypothesize** - Single hypothesis, smallest test
4. **Implement** - Regression test first, then fix

### Two-Stage Review
At phase boundaries:
1. **Stage 1: Spec Compliance** - Did we build what was specified?
2. **Stage 2: Code Quality** - Is the code well-crafted?

Only proceed if Stage 1 passes. Fix Critical issues before proceeding.

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
}

main "$@"
