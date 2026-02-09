# Draft

**Ship fast. Ship right.**

Structure your AI development with specs, plans, and quality gates. No more chaotic AI coding — every feature starts with context, builds through phases, and ends with verification.

[**Website**](https://getdraft.dev) · [**Docs**](https://getdraft.dev#commands)

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

**Method 1: Built-in (Recommended)**
Cursor > Settings > Rules, Skills, Subagents > Rules > New > Add from Github:
```
https://github.com/mayurpise/draft.git
```

**Method 2: Manual**
```bash
curl -o .cursorrules https://raw.githubusercontent.com/mayurpise/draft/main/integrations/cursor/.cursorrules
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
| `/draft:review` | Spec compliance + code quality |
| `/draft:validate` | Architecture + security scan |
| `/draft:bughunt` | 12-dimension defect discovery |

[See all 14 commands →](https://getdraft.dev#commands)

---

## How It Works

```
/draft:init  →  Creates product.md, tech-stack.md, architecture.md
     ↓
/draft:new-track  →  AI-guided spec.md + phased plan.md
     ↓
/draft:implement  →  RED → GREEN → REFACTOR (repeat)
     ↓
/draft:review  →  Two-stage review (spec + quality)
```

[Full workflow →](https://getdraft.dev#workflow)

---

## Why Draft?

AI tools are fast but chaotic. Draft constrains them with **Context-Driven Development**:

```
product.md      →  "Build a task manager"
tech-stack.md   →  "React, TypeScript, Tailwind"
architecture.md →  "Express → Service → Prisma → PostgreSQL"
spec.md         →  "Add drag-and-drop reordering"
plan.md         →  "Phase 1: sortable, Phase 2: persist"
```

Each layer narrows the solution space. By the time AI writes code, decisions are made.

[Read methodology →](https://getdraft.dev#methodology)

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

Apache 2.0

---

**Credits:** Adapted from [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor)
