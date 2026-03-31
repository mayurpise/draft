# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Draft is a Claude Code plugin that implements Context-Driven Development methodology. It provides slash commands for structured software development through specifications and plans before implementation. Commands: `/draft`, `/draft:init`, `/draft:index`, `/draft:new-track`, `/draft:implement`, `/draft:status`, `/draft:revert`, `/draft:decompose`, `/draft:coverage`, `/draft:review`, `/draft:deep-review`, `/draft:bughunt`, `/draft:learn`, `/draft:adr`, `/draft:change`, `/draft:jira-preview`, `/draft:jira-create`. Run `/draft` for overview.

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
  ├── <command>/SKILL.md    # Frontmatter (name, description) + execution body
  └── GRAPH.md              # Skill dependency graph (reference artifact, not a skill)
core/
  ├── methodology.md        # Master methodology (update first)
  ├── shared/               # Shared procedures (context loading, git metadata, pattern learning)
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

The frontmatter configures the command; the body contains step-by-step instructions. After the closing `---` of frontmatter, the body **must** follow this exact format: (1) a blank line, (2) `# Title` heading, (3) a blank line, (4) content. The build script validates this structure and skips the first 3 lines of the body (via `tail -n +4`) when inlining skills into integration files.

## Maintaining the Plugin

### Updating Methodology

1. Update `core/methodology.md` first
2. Apply changes to relevant `skills/` SKILL.md files
3. Run `./scripts/build-integrations.sh` to regenerate integrations (Copilot + Gemini)
4. Update this CLAUDE.md only if core concepts change

### Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter
2. Add `skills/<skill-name>/SKILL.md` to the `skills` array in `.claude-plugin/plugin.json`
3. Rebuild: `./scripts/build-integrations.sh`
4. Document in README.md

## End-User Context

When users use Draft, it creates a `draft/` directory in their project:

| File | Purpose |
|------|---------|
| `product.md` | Product vision, users, goals, guidelines (optional section) |
| `tech-stack.md` | Languages, frameworks, patterns, accepted patterns |
| `architecture.md` | **Source of truth.** Comprehensive human-readable engineering reference with 25 sections + 4 appendices, Mermaid diagrams, and code snippets. Generated from 5-phase codebase analysis. |
| `.ai-profile.md` | **Derived from .ai-context.md.** 20-50 lines, ultra-compact always-injected project profile. Contains: language, framework, database, auth, API style, critical invariants, safety rules, active tracks, recent changes. Tier 0 context — loaded by every command. |
| `.ai-context.md` | **Derived from architecture.md.** 200-400 lines, token-optimized, self-contained AI context. 15+ sections covering architecture, invariants, interfaces, data flows, concurrency, error handling, catalogs, cookbooks, testing, glossary. Tier 1 context — loaded for most tasks. Auto-refreshed on mutations. |
| `workflow.md` | TDD preferences, commit strategy, validation config |
| `guardrails.md` | Hard guardrails, learned conventions, learned anti-patterns. Entries include dual-layer timestamps (discovered_at, established_at, last_verified, last_active) for temporal reasoning. |
| `tracks.md` | Master list of all tracks |
| `tracks/<id>/` | Individual tracks with `spec.md`, `plan.md`, `metadata.json` |
| `.state/facts.json` | Atomic fact registry with dual-layer timestamps, confidence scoring, and knowledge graph edges (updates/extends/derives). Enables fact-level contradiction detection on refresh and relevance-scored context loading. |
| `.state/freshness.json` | SHA-256 hashes of all analyzed source files. Enables file-level staleness detection for incremental refresh. |
| `.state/signals.json` | Codebase signal classification (11 categories). Detects structural drift on refresh (e.g., auth files added for the first time). |
| `.state/run-memory.json` | Run metadata: phases completed, unresolved questions, resumable checkpoints. Enables cross-session continuity. |

### Key Sections

- **`product.md` `## Guidelines`** - UX standards, writing style, branding (optional)
- **`tech-stack.md` `## Accepted Patterns`** - Intentional design decisions that bughunt/review/deep-review should honor
- **`guardrails.md`** - Hard guardrails (human-defined constraints), learned conventions (auto-discovered, skip in analysis), learned anti-patterns (auto-discovered, always flag)

### Status Markers

- `[ ]` Pending/New
- `[~]` In Progress
- `[x]` Completed
- `[!]` Blocked

## Quality Disciplines

### Verification Before Completion
**Iron Law:** No completion claims without fresh verification evidence.

### Systematic Debugging
**Iron Law:** Investigate → Analyze → Hypothesize → Implement. No fixes without root cause first.
See `core/agents/debugger.md`.

### Root Cause Analysis (Bug Tracks)
**Iron Law:** Reproduce → Trace → Hypothesize → Fix. Blast radius scoping before investigation. Detection lag analysis. 5 Whys chain. See `core/agents/rca.md`.

### Three-Stage Review
At phase boundaries: (1) Automated Validation, (2) Spec Compliance, (3) Code Quality.
See `core/agents/reviewer.md`.

## Communication Style

Lead with conclusions. Be concise. Direct, professional tone. Code over explanation.
