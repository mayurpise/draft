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

### GitHub Copilot
```bash
mkdir -p .github
curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/copilot/.github/copilot-instructions.md
```

Commands use natural language: `draft init`, `draft new-track`

### Gemini
```bash
curl -o GEMINI.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/gemini/GEMINI.md
```

Commands use `@draft` syntax.

---

## What You Get

| Command | What It Does |
|---------|--------------|
| **`/draft:init`** | Analyze codebase, create context files |
| **`/draft:new-track`** | Collaborative spec + plan with AI |
| **`/draft:implement`** | TDD workflow with checkpoints |
| **`/draft:review`** | 3-stage review (validation + spec compliance + code quality) |
| **`/draft:deep-review`** | Enterprise-grade module lifecycle and ACID audit |
| **`/draft:bughunt`** | Exhaustive defect discovery |

[See all 16 commands →](core/methodology.md#command-workflows)

---

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                        /draft:init                          │
│       Creates product.md, tech-stack.md, architecture.md    │
│                      + .ai-context.md                       │
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
```

[Full workflow →](core/methodology.md#core-workflow)

---

## Why Draft?

AI tools are fast but unstructured. Draft applies Context-Driven Development to impose clear boundaries: explicit context, phased execution, and built-in verification, ensuring outputs remain aligned, predictable, and production-ready.

```
product.md       →  "Build a task manager"
tech-stack.md    →  "React, TypeScript, Tailwind"
architecture.md  →  30-45 pages: 25 sections + appendices, Mermaid diagrams (source of truth)
.ai-context.md   →  200-400 lines: condensed from architecture.md (token-optimized AI context)
spec.md          →  "Add drag-and-drop reordering"
plan.md          →  "Phase 1: sortable, Phase 2: persist"
```

Each layer narrows the solution space. By the time AI writes code, decisions are made.

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
