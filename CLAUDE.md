# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Draft is a Claude Code plugin that implements Context-Driven Development methodology. It provides slash commands (`/draft:setup`, `/draft:new-track`, `/draft:implement`, `/draft:status`, `/draft:revert`) for structured software development through specifications and plans before implementation.

## Architecture

### Plugin Structure

```
.claude-plugin/plugin.json  # Plugin manifest (name, version, metadata)
CLAUDE.md                   # Auto-loaded context for Claude Code
skills/                     # Slash command implementations
  └── <command>/SKILL.md    # Each skill defines one /draft:<command>
core/                       # Canonical source of truth
  ├── methodology.md        # Master methodology documentation
  ├── templates/            # Template files for /draft:setup
  └── agents/               # Agent behavior definitions
integrations/cursor/        # Cursor IDE integration
  └── .cursorrules          # Cursor rules file
```

### Key Files

- **`skills/<name>/SKILL.md`**: Each file defines a slash command. The frontmatter (`name`, `description`) configures the command, and the body contains the execution instructions.
- **`core/methodology.md`**: Single source of truth for the Draft methodology. All other files should reflect this.
- **`integrations/cursor/.cursorrules`**: Cursor integration that mirrors the Claude Code functionality.

## Maintaining the Plugin

When updating the Draft methodology:

1. Update `core/methodology.md` first
2. Apply changes to `skills/` SKILL.md files as needed
3. Update this `CLAUDE.md` if core concepts change
4. Update `integrations/cursor/.cursorrules` to stay in sync

### Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Brief description of what the skill does
   ---
   ```
2. Add execution instructions in the body
3. Document the command in `README.md`

## Draft Methodology (for end-users)

When users use Draft in their projects, it creates a `draft/` directory with:
- `product.md`, `tech-stack.md`, `workflow.md` - Project context
- `tracks.md` - Master list of work items
- `tracks/<track-id>/` - Individual tracks containing `spec.md`, `plan.md`, `metadata.json`

### Status Markers

Used in spec.md and plan.md files:
- `[ ]` - Pending/New
- `[~]` - In Progress
- `[x]` - Completed
- `[!]` - Blocked

### Intent Mapping

When users say... → Use command:
- "set up draft" / "initialize project" → `/draft:setup`
- "new feature" / "start a track" / "add feature X" → `/draft:new-track`
- "implement" / "start coding" / "work on the plan" → `/draft:implement`
- "what's the status" / "show progress" → `/draft:status`
- "undo" / "revert the last change" → `/draft:revert`

## Quality Disciplines

Draft enforces these quality disciplines throughout the development process:

### Verification Before Completion
**Iron Law:** No completion claims without fresh verification evidence.
- Run verification command IN THE CURRENT MESSAGE
- Show output as evidence
- Only then mark tasks/phases complete

### Strict TDD (when enabled)
**Iron Law:** No production code without a failing test first.
- RED: Write test, verify it FAILS
- GREEN: Minimum code, verify it PASSES
- REFACTOR: Keep tests green throughout

### Systematic Debugging
**Iron Law:** No fixes without root cause investigation first.
- Investigate → Analyze → Hypothesize → Implement
- See `core/agents/debugger.md`

### Two-Stage Review
At phase boundaries:
1. **Spec Compliance:** Did we build what was specified?
2. **Code Quality:** Is it well-crafted?
- See `core/agents/reviewer.md`

### Agents

The `core/agents/` directory contains specialized agent definitions:
- `planner.md` - Specification and plan creation
- `debugger.md` - Systematic debugging process
- `reviewer.md` - Two-stage code review
