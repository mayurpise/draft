# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Draft is a Claude Code plugin that implements Context-Driven Development methodology. It provides slash commands (`/draft:init`, `/draft:new-track`, `/draft:implement`, `/draft:status`, `/draft:revert`) for structured software development through specifications and plans before implementation.

## Build Commands

```bash
# Rebuild .cursorrules from skill files (run after changing skills)
./scripts/build-cursorrules.sh
```

The `.cursorrules` file is auto-generated from skills - do not edit directly.

## Architecture

### Source of Truth Hierarchy

1. **`core/methodology.md`** - Master methodology documentation
2. **`skills/<name>/SKILL.md`** - Skill implementations (derive from methodology)
3. **`integrations/cursor/.cursorrules`** - Generated from skills via build script

### Plugin Structure

```
.claude-plugin/plugin.json  # Plugin manifest
skills/                     # Slash command implementations
  └── <command>/SKILL.md    # Frontmatter (name, description) + execution body
core/
  ├── methodology.md        # Master methodology (update first)
  ├── templates/            # Templates used by /draft:init
  └── agents/               # Specialized agent behaviors (debugger, reviewer, planner)
integrations/cursor/
  └── .cursorrules          # GENERATED - do not edit directly
```

### Skill File Format

```yaml
---
name: skill-name
description: Brief description
---
# Execution instructions below...
```

The frontmatter configures the command; the body contains step-by-step instructions.

## Maintaining the Plugin

### Updating Methodology

1. Update `core/methodology.md` first
2. Apply changes to relevant `skills/` SKILL.md files
3. Run `./scripts/build-cursorrules.sh` to regenerate Cursor integration
4. Update this CLAUDE.md only if core concepts change

### Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter
2. Rebuild: `./scripts/build-cursorrules.sh`
3. Document in README.md

## End-User Context

When users use Draft, it creates a `draft/` directory in their project:

| File | Purpose |
|------|---------|
| `product.md` | Product vision, users, goals |
| `product-guidelines.md` | Style, branding, UX standards (optional) |
| `tech-stack.md` | Languages, frameworks, patterns |
| `workflow.md` | TDD preferences, commit strategy |
| `tracks.md` | Master list of all tracks |
| `tracks/<id>/` | Individual tracks with `spec.md`, `plan.md`, `metadata.json` |

### Status Markers

- `[ ]` Pending/New
- `[~]` In Progress
- `[x]` Completed
- `[!]` Blocked

## Quality Disciplines

### Verification Before Completion
**Iron Law:** No completion claims without fresh verification evidence.

### Strict TDD (when enabled)
**Iron Law:** RED → GREEN → REFACTOR. No production code without a failing test first.

### Systematic Debugging
**Iron Law:** Investigate → Analyze → Hypothesize → Implement. No fixes without root cause first.
See `core/agents/debugger.md`.

### Two-Stage Review
At phase boundaries: (1) Spec Compliance, (2) Code Quality.
See `core/agents/reviewer.md`.

## Communication Style

Lead with conclusions. Be concise. Direct, professional tone. Code over explanation.
