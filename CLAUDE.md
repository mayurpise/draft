# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Draft is a Claude Code plugin that implements Context-Driven Development methodology. It provides slash commands for structured software development through specifications and plans before implementation. Commands: `/draft:init`, `/draft:index`, `/draft:new-track`, `/draft:implement`, `/draft:status`, `/draft:revert`, `/draft:decompose`, `/draft:coverage`, `/draft:validate`, `/draft:bughunt`, `/draft:review`, `/draft:adr`, `/draft:jira-preview`, `/draft:jira-create`. Run `/draft` for overview.

## Build Commands

```bash
# Rebuild all integrations from skill files (run after changing skills)
./scripts/build-integrations.sh
```

Integration files (`copilot-instructions.md`, `GEMINI.md`) are auto-generated from skills - do not edit directly.

Note: Cursor integration removed - Cursor now supports `.claude/` plugin structure natively.

## Architecture

### Source of Truth Hierarchy

1. **`core/methodology.md`** - Master methodology documentation
2. **`skills/<name>/SKILL.md`** - Skill implementations (derive from methodology)
3. **`integrations/copilot/.github/copilot-instructions.md`** - Generated from skills via build script
4. **`integrations/gemini/GEMINI.md`** - Generated from skills via build script

### Plugin Structure

```
.claude-plugin/plugin.json  # Plugin manifest
skills/                     # Slash command implementations
  └── <command>/SKILL.md    # Frontmatter (name, description) + execution body
core/
  ├── methodology.md        # Master methodology (update first)
  ├── templates/            # Templates used by /draft:init
  └── agents/               # Specialized agent behaviors (architect, debugger, planner, rca, reviewer)
integrations/copilot/.github/
  └── copilot-instructions.md  # GENERATED - do not edit directly
integrations/gemini/
  └── GEMINI.md             # GENERATED - do not edit directly
```

### Skill File Format

```yaml
---
name: skill-name
description: Brief description
---
# Skill Title

Execution instructions below...
```

The frontmatter configures the command; the body contains step-by-step instructions. The body **must** start with a `# Title` heading followed by a blank line — the build script skips the first 3 lines of the body (via `tail -n +4`) when inlining skills into integration files.

## Maintaining the Plugin

### Updating Methodology

1. Update `core/methodology.md` first
2. Apply changes to relevant `skills/` SKILL.md files
3. Run `./scripts/build-integrations.sh` to regenerate integrations (Copilot + Gemini)
4. Update this CLAUDE.md only if core concepts change

### Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter
2. Rebuild: `./scripts/build-integrations.sh`
3. Document in README.md

## End-User Context

When users use Draft, it creates a `draft/` directory in their project:

| File | Purpose |
|------|---------|
| `product.md` | Product vision, users, goals, guidelines (optional section) |
| `tech-stack.md` | Languages, frameworks, patterns, accepted patterns |
| `.ai-context.md` | **Source of truth.** 200-400 lines, token-optimized, self-contained AI context. 15+ mandatory sections covering architecture, invariants, interfaces, data flows, concurrency, error handling, catalogs, cookbooks, testing, glossary. Consumed by all Draft commands and external AI tools. |
| `architecture.md` | **Derived from .ai-context.md.** 30-45 page human-readable engineering reference with 25 sections + appendices, Mermaid diagrams, and code snippets. Auto-refreshed on mutations. |
| `workflow.md` | TDD preferences, commit strategy, validation config, guardrails |
| `tracks.md` | Master list of all tracks |
| `tracks/<id>/` | Individual tracks with `spec.md`, `plan.md`, `metadata.json`, `validation-report.md` |
| `validation-report.md` | Project-level validation results (architecture, security, performance) |

### Key Sections

- **`product.md` `## Guidelines`** - UX standards, writing style, branding (optional)
- **`tech-stack.md` `## Accepted Patterns`** - Intentional design decisions that bughunt/validate/review should honor
- **`workflow.md` `## Guardrails`** - Hard constraints enforced by validation commands

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

### Validation (when enabled)
At track completion: Systematic quality checks using Draft context (`.ai-context.md`, tech-stack.md). Non-blocking by default. Reports in `draft/tracks/<id>/validation-report.md`.

## Communication Style

Lead with conclusions. Be concise. Direct, professional tone. Code over explanation.
