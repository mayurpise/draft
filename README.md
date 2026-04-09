<h1 align="center">Draft</h1>

<p align="center">
  <strong>Ship fast. Ship right.</strong><br>
  Context-Driven Development for AI-powered software engineering.
</p>

<p align="center">
  <a href="https://github.com/mayurpise/draft/releases"><img src="https://img.shields.io/github/v/release/mayurpise/draft?include_prereleases&style=for-the-badge" alt="GitHub release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
  <a href="https://github.com/mayurpise/draft/stargazers"><img src="https://img.shields.io/github/stars/mayurpise/draft?style=for-the-badge" alt="Stars"></a>
</p>

<p align="center">
  <a href="https://getdraft.dev">Website</a> ·
  <a href="https://getdraft.dev#commands">Docs</a> ·
  <a href="core/methodology.md">Methodology</a> ·
  <a href="https://www.youtube.com/watch?v=gBSwFEFVd7Y">Watch (8 min)</a> ·
  <a href="https://www.youtube.com/playlist?list=PLoN73NRJ_HQPdnR5Su4WkWK-O_7IOrOg_">All Videos</a>
</p>

---

AI agents for every stage of the software development lifecycle — architected around human decision-making. Draft drives collaborative design through structured requirements gathering, trade-off analysis, and specification review before execution begins. It then delivers implementation, testing, code review, and validation — all grounded in deep codebase context with full traceability.

Works with **Claude Code**, **Cursor**, **GitHub Copilot**, and **Gemini**.

---

## Quickstart

### Claude Code
```bash
/plugin marketplace add mayurpise/draft
/plugin install draft
/draft:init                           # Set up project context
/draft:new-track "Add user auth"      # Create spec + plan
/draft:implement                      # Build it
```

### Cursor

Cursor natively supports the `.claude/` plugin structure. Add via:

Cursor > Settings > Rules, Skills, Subagents > Rules > New > Add from Github:
```
https://github.com/mayurpise/draft.git
```

Then use: `@draft init`, `@draft new-track`, `@draft implement`

Draft integrates with your AI pair programmer by providing context-optimized instructions. These instructions tell the AI how to follow the Draft methodology and where to find the detailed skills.

### Antigravity IDE
Draft is used globally with Antigravity IDE by installing the skills to a central location.

1. Clone Draft to `~/.gemini/antigravity/skills/draft`
2. Configure `~/.gemini.md` (bootstrap) to point to the global skills:
```markdown
**Skill Locations:**
The authoritative Draft implementation skills are located at:
`/Users/mayurpise/.gemini/antigravity/skills/draft/skills`
```

### GitHub Copilot
For Copilot in VS Code, Draft uses a `.github/copilot-instructions.md` file.

```bash
# Add bootstrap to your project
mkdir -p .github && curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/copilot/.github/copilot-instructions.md
```

### Gemini
For Gemini, Draft uses a `.gemini.md` file.

```bash
# Add bootstrap to your project
curl -o .gemini.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/gemini/.gemini.md
```

---

## What You Get

| Command | What It Does |
|---------|--------------|
| **`/draft`** | Overview, intent mapping, and command reference |
| **`/draft:init`** | Analyze codebase, create context files + state tracking |
| **`/draft:index`** | Aggregate monorepo service contexts |
| **`/draft:new-track`** | Collaborative spec + plan with AI |
| **`/draft:decompose`** | Module decomposition with dependency mapping |
| **`/draft:implement`** | TDD workflow with checkpoints |
| **`/draft:coverage`** | Code coverage report (target 95%+) |
| **`/draft:review`** | 3-stage review (validation + spec compliance + code quality) |
| **`/draft:deep-review`** | Enterprise-grade module lifecycle and ACID audit |
| **`/draft:bughunt`** | Exhaustive 14-dimension defect discovery with taint tracking |
| **`/draft:learn`** | Discover coding patterns, update guardrails |
| **`/draft:adr`** | Architecture Decision Records |
| **`/draft:status`** | Show progress overview |
| **`/draft:revert`** | Git-aware rollback |
| **`/draft:change`** | Handle mid-track requirement changes |
| **`/draft:debug`** | Structured debugging: reproduce, isolate, diagnose, fix |
| **`/draft:quick-review`** | Lightweight 4-dimension code review |
| **`/draft:deploy-checklist`** | Pre-deployment verification with rollback triggers |
| **`/draft:testing-strategy`** | Test plan design with coverage targets |
| **`/draft:tech-debt`** | Technical debt analysis across 6 dimensions |
| **`/draft:standup`** | Git activity standup summary (read-only) |
| **`/draft:incident-response`** | Incident lifecycle: triage, communicate, mitigate, postmortem |
| **`/draft:documentation`** | Technical docs: readme, runbook, api, onboarding |
| **`/draft:jira-preview`** | Generate Jira export for review |
| **`/draft:jira-create`** | Push issues to Jira via MCP |
| **`/draft:tour`** | Interactive architecture mentorship and codebase walk-through |
| **`/draft:impact`** | ROI analytics tracking friction and timeline metrics |
| **`/draft:assist-review`** | Summarize intent and highlight structural PR risks for reviewers |

[See all 28 commands →](core/methodology.md#command-workflows)

---

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                        /draft:init                          │
│    5-phase codebase analysis + signal detection + state     │
│  architecture.md + .ai-context.md + .state/ (freshness,    │
│                   signals, run memory)                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      /draft:new-track                       │
│            AI-guided spec.md + phased plan.md               │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     /draft:implement                        │
│              RED → GREEN → REFACTOR (repeat)                │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      /draft:review                          │
│        Three-stage review (validation + spec + quality)     │
└─────────────────────────────────────────────────────────────┘

         /draft:init --refresh  ←── incremental: only re-analyze
                                    files with changed hashes
```

[Full workflow →](core/methodology.md#core-workflow)

---

## Why Draft?

AI tools are fast but unstructured. Draft applies Context-Driven Development to impose clear boundaries: explicit context, phased execution, and built-in verification, ensuring outputs remain aligned, predictable, and production-ready.

```
product.md       →  "Build a task manager"
tech-stack.md    →  "React, TypeScript, Tailwind"
architecture.md  →  Comprehensive: 25 sections + appendices, Mermaid diagrams (source of truth)
.ai-context.md   →  200-400 lines: condensed from architecture.md (token-optimized AI context)
.ai-profile.md   →  20-50 lines: ultra-compact always-on profile (active tracks, key constraints)
.state/          →  freshness hashes, signal classification, run memory (incremental refresh)
spec.md          →  "Add drag-and-drop reordering"
plan.md          →  "Phase 1: sortable, Phase 2: persist"
```

Each layer narrows the solution space. By the time AI writes code, decisions are made.

**Module detection**: Init uses two-tier module detection — Tier 1 scans top-level directories for initial boundaries, Tier 2 recurses into each to discover sub-modules using import graphs, build file markers, and DI wiring. Sub-modules are promoted when a parent directory contains 2+ children. The module map is refined during Phase 2 import analysis. Each discovered module gets a full deep dive in Section 7 of `architecture.md`.

**Incremental refresh**: `/draft:init --refresh` uses stored file hashes and signal classification to only re-analyze what changed. Early-exit happens after signal analysis to catch structural drift. Use `--force` to bypass freshness checks and force full re-analysis when methodology has been updated. Cross-session continuity via `run-memory.json` enables resume from interrupted runs.

[Read methodology →](core/methodology.md#philosophy)

---

## Contributing

### Source of Truth
1. `core/methodology.md` — Master methodology
2. `skills/<name>/SKILL.md` — Command implementations
3. `integrations/` — Auto-generated (don't edit)

### Update Workflow
```bash
# 1. Edit core/methodology.md or skills/*/SKILL.md
# 2. Rebuild integrations
./scripts/build-integrations.sh
```

[Full architecture →](CLAUDE.md)

---

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=mayurpise/draft&type=Date)](https://star-history.com/#mayurpise/draft&Date)

---

<p align="center">MIT License</p>

<p align="center">
  <strong>Credits:</strong> Inspired by <a href="https://github.com/gemini-cli-extensions/conductor">gemini-cli-extensions/conductor</a>
</p>
