# Product: Draft

## Vision

Draft is a Claude Code plugin that implements Context-Driven Development — a methodology where structured documents (product.md, tech-stack.md, .ai-context.md, architecture.md, spec.md, plan.md) constrain and guide AI behavior during software development. It ensures AI acceleration doesn't mean technical debt by making every decision explicit and reviewable before code is written.

---

## Target Users

### Primary Users
- **Software Engineers**: Need structured AI-assisted development with accountability checkpoints, TDD support, and consistent workflows
- **Tech Leads**: Need spec/plan review workflows before implementation begins; want team alignment on approach before code

### Secondary Users
- **Product Managers**: Review product vision and feature specs without reading code
- **New Team Members**: Use Draft artifacts (spec.md, plan.md, .ai-context.md, architecture.md) to onboard and understand features

---

## Core Features

### Must Have (P0)
1. **Project Initialization** (`/draft:init`): Scan codebase, detect tech stack, generate context files (product.md, tech-stack.md, .ai-context.md with data state machines/invariants, architecture.md derived for humans)
2. **Track Creation** (`/draft:new-track`): Collaborative intake process producing spec.md and plan.md with phased task breakdown
3. **TDD Implementation** (`/draft:implement`): Execute tasks from plan.md using RED → GREEN → REFACTOR workflow with progress tracking
4. **Code Review** (`/draft:review`): Two-stage review (spec compliance + code quality) with bughunt and validation integration

### Should Have (P1)
1. **Module Decomposition** (`/draft:decompose`): Architecture analysis with module boundaries, dependency graphs, and implementation order
2. **Validation** (`/draft:validate`): Systematic quality checks (architecture conformance, security, performance) using Draft context
3. **Bug Hunt** (`/draft:bughunt`): Exhaustive bug analysis across 12 dimensions with severity-ranked report
4. **Status & Revert** (`/draft:status`, `/draft:revert`): Progress tracking and git-aware rollback at task/phase/track level

### Nice to Have (P2)
1. **Jira Integration** (`/draft:jira-preview`, `/draft:jira-create`): Export tracks to Jira epics/stories/subtasks via MCP
2. **Coverage** (`/draft:coverage`): Code coverage analysis targeting 95%+ with gap justification
3. **Monorepo Index** (`/draft:index`): Federated knowledge aggregation across multiple services
4. **Architecture Decision Records** (`/draft:adr`): Document significant technical decisions with context, alternatives, and consequences

---

## Success Criteria

- [x] Users can initialize a project with full architecture discovery in a single command
- [x] Spec and plan documents are reviewable before any code is written
- [x] AI behavior is constrained by the document hierarchy (product → tech-stack → architecture → spec → plan)
- [x] Works across Cursor (native .claude/ support), GitHub Copilot, and Gemini (via generated integration files)

---

## Constraints

### Technical
- Plugin runs entirely as markdown instructions interpreted by Claude LLM — no runtime code
- Must work within Claude Code Plugin API v1 constraints
- Integration files must be auto-generated from skills (single source of truth)

### Business
- Open source (Apache-2.0 license)
- Must support brownfield (existing) and greenfield (new) projects

---

## Non-Goals

- Draft is not a code execution engine — it generates instructions, not runtime artifacts
- Draft does not replace CI/CD pipelines — it complements them with pre-implementation structure
- Draft does not enforce coding standards at build time — it provides guidance through context documents

---

## Open Questions

None — all core commands implemented and stable.
