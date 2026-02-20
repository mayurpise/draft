# Draft

**Ship fast. Ship right.**

AI agents for every stage of the software development lifecycle — architected around human decision-making. Draft drives collaborative design through structured requirements gathering, trade-off analysis, and specification review before execution begins. It then delivers implementation, testing, code review, and validation — all grounded in deep codebase context with full traceability.

Works with Claude Code, Cursor, GitHub Copilot, and Gemini.

[**getdraft.dev**](https://getdraft.dev) · [**Docs**](https://getdraft.dev#commands)

🎥 [**Watch: Draft Overview (8 min)**](https://www.youtube.com/watch?v=gBSwFEFVd7Y) · [**All Videos**](https://www.youtube.com/playlist?list=PLoN73NRJ_HQPdnR5Su4WkWK-O_7IOrOg_)

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
| `/draft:init` | Analyze codebase, create context files |
| `/draft:new-track` | Collaborative spec + plan with AI |
| `/draft:implement` | TDD workflow with checkpoints |
| `/draft:review` | 3-stage review (validation + spec compliance + code quality) |
| `/draft:deep-review` | Enterprise-grade module lifecycle and ACID audit |
| `/draft:bughunt` | Exhaustive defect discovery |

[See all 14 commands →](core/methodology.md#command-workflows)

---

## How It Works

```
/draft:init  →  Creates product.md, tech-stack.md, architecture.md + .ai-context.md
     ↓
/draft:new-track  →  AI-guided spec.md + phased plan.md
     ↓
/draft:implement  →  RED → GREEN → REFACTOR (repeat)
     ↓
/draft:review  →  Three-stage review (validation + spec + quality)
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

## License

MIT

---

**Credits:** Inspired by [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor)
