---
project: "draft"
module: "root"
generated_by: "draft:init"
generated_at: "2026-02-15T09:15:00Z"
git:
  branch: "main"
  remote: "origin/main"
  commit: "8b120fb6de234d14c78e637bc90c0238308f2321"
  commit_short: "8b120fb"
  commit_date: "2026-02-15 01:06:48 -0800"
  commit_message: "fix(landing): update social share links to point to research tab"
  dirty: true
synced_to_commit: "8b120fb6de234d14c78e637bc90c0238308f2321"
---

# Product: Draft

| Field | Value |
|-------|-------|
| **Branch** | `main` → `origin/main` |
| **Commit** | `8b120fb` — fix(landing): update social share links to point to research tab |
| **Generated** | 2026-02-15T09:15:00Z |
| **Synced To** | `8b120fb6de234d14c78e637bc90c0238308f2321` |

---

## Vision

Draft is a Claude Code plugin that implements Context-Driven Development — a methodology requiring structured specifications and plans before any implementation begins. It provides 15 slash commands that guide developers through project initialization, architecture discovery, feature planning, TDD implementation, code review, and quality validation. Draft eliminates the "just start coding" anti-pattern by enforcing a disciplined workflow: understand the codebase, define the problem, plan the solution, then implement with verification at every step.

---

## Target Users

### Primary Users
- **Software Engineers using Claude Code**: Developers who want structured, methodology-driven AI assistance for feature development, bug fixing, and refactoring
- **Tech Leads**: Engineers who need comprehensive architecture documentation and quality gates for AI-assisted development

### Secondary Users
- **Teams using Copilot/Gemini**: Developers on other AI platforms who benefit from Draft's cross-platform integrations (generated from the same skill definitions)
- **Open Source Contributors**: Developers extending Draft with new skills, agents, or templates

---

## Core Features

### Must Have (P0)
1. **Project Initialization** (`/draft:init`): 5-phase exhaustive codebase analysis generating architecture.md (30-45 pages) and .ai-context.md (200-400 lines, token-optimized)
2. **Track Creation** (`/draft:new-track`): Collaborative 6-phase intake producing spec.md and plan.md with risk assessment, acceptance criteria, and phased task breakdown
3. **TDD Implementation** (`/draft:implement`): Task-by-task execution following RED-GREEN-REFACTOR with phase boundary reviews
4. **Code Review** (`/draft:review`): Two-stage review (spec compliance + code quality) with reviewer agent protocol
5. **Cross-Platform Build** (`build-integrations.sh`): Generates Copilot and Gemini integration files from skill definitions

### Should Have (P1)
1. **Quality Validation** (`/draft:validate`): 5-category validation against Draft context (architecture conformance, security, performance, dead code, dependency cycles)
2. **Bug Discovery** (`/draft:bughunt`): 12-dimension exhaustive bug analysis with severity-ranked findings
3. **Module Decomposition** (`/draft:decompose`): Architecture-aware module breakdown with dependency mapping
4. **Monorepo Indexing** (`/draft:index`): Federated knowledge aggregation across services

### Nice to Have (P2)
1. **Jira Integration** (`/draft:jira-preview`, `/draft:jira-create`): Export track plans to Jira issues
2. **ADR Management** (`/draft:adr`): Architecture Decision Records
3. **Coverage Reporting** (`/draft:coverage`): Code coverage targeting 95%+

---

## Success Criteria

- [x] All 15 skills discoverable and executable via Claude Code plugin system
- [x] Build script generates valid Copilot and Gemini integrations (13 tests passing)
- [x] Idempotent builds — same input produces same output
- [ ] Architecture discovery produces accurate, exhaustive documentation for any codebase
- [ ] Track workflow (new-track → implement → review) completes without manual intervention on skill logic

---

## Constraints

### Technical
- No runtime process — document-driven plugin only (Markdown skills, Bash build/test)
- Must work within Claude Code's plugin discovery mechanism (`.claude-plugin/plugin.json`)
- Integration files must not contain `/draft:` syntax (platform-specific transforms required)
- YAML frontmatter required on all skill files (enforced by build script)

### Business
- Open source (MIT or similar) — published at getdraft.dev
- Single-developer maintained — simplicity over features

---

## Non-Goals

- Draft is NOT a runtime framework — no daemon, no server, no API
- Draft does NOT execute code — it generates instructions for AI agents to follow
- Draft does NOT replace CI/CD — it complements existing pipelines
- Draft does NOT support interactive/GUI workflows — CLI-only via Claude Code
- No Cursor-specific integration — Cursor now supports `.claude/` plugin structure natively

---

## Open Questions

- [x] Plugin architecture for Claude Code auto-discovery (resolved — documented in PLUGIN_ARCHITECTURE.md)
- [ ] Versioning strategy for skill breaking changes across integrations

---

## Guidelines (Optional)

### Writing Style
- **Tone:** Direct, professional, technical
- **Voice:** Second person imperative ("Run this command", "Create this file")
- **Terminology:** See glossary in .ai-context.md (Track, Skill, Agent, Template, Condensation, Iron Law)

### UX Principles
1. "Convention over configuration" — sensible defaults, minimal required decisions
2. "Document before implement" — no code without spec and plan
3. "Verify before complete" — no `[x]` without evidence
4. "Progressive refinement" — draft files evolve through conversation

### Content Standards
- **Date format:** ISO 8601 (`2026-02-15T09:15:00Z`)
- **Status markers:** `[ ]` pending, `[~]` in progress, `[x]` completed, `[!]` blocked
- **IDs:** kebab-case (`add-user-auth`, `fix-login-bug`)
