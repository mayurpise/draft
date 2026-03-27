---
name: draft
description: Context-Driven Development methodology overview. Shows available Draft commands and guides you to the right workflow.
---

# Draft - Context-Driven Development

Draft is a methodology for structured software development: **Context → Spec & Plan → Implement**

## Red Flags - STOP if you're:

- Jumping straight to implementation without reading existing Draft context
- Suggesting `/draft:implement` before a track has an approved spec and plan
- Not checking `draft/tracks.md` for existing active tracks before creating new ones
- Skipping the recommended command and going freeform
- Ignoring existing .ai-context.md, product.md, tech-stack.md, or workflow.md context

**Read context first. Follow the workflow.**

---

## Available Commands

| Command | Purpose |
|---------|---------|
| `/draft:init` | Initialize project (run once) |
| `/draft:index` | Aggregate monorepo service contexts (run at root) |
| `/draft:new-track` | Create feature/bug track with spec and plan |
| `/draft:implement` | Execute tasks from plan with TDD |
| `/draft:status` | Show progress overview |
| `/draft:revert` | Git-aware rollback |
| `/draft:decompose` | Module decomposition with dependency mapping |
| `/draft:coverage` | Code coverage report (target 95%+) |
| `/draft:deep-review` | Module lifecycle audit (ACID compliance, enterprise quality) |
| `/draft:bughunt` | Exhaustive bug hunt |
| `/draft:review` | Code review orchestrator |
| `/draft:adr` | Architecture Decision Records |
| `/draft:change` | Handle mid-track requirement changes |
| `/draft:learn` | Discover coding patterns and update guardrails |
| `/draft:jira-preview` | Generate Jira export for review |
| `/draft:jira-create` | Push issues to Jira via MCP |


## Quick Start

1. **First time?** Run `/draft:init` to initialize your project
2. **Starting a feature?** Run `/draft:new-track "your feature description"`
3. **Ready to code?** Run `/draft:implement` to execute tasks
4. **Check progress?** Run `/draft:status`

## Core Workflow

Every feature follows this lifecycle:
1. **Setup** - Initialize project context (once per project)
2. **New Track** - Create specification and plan
3. **Implement** - Execute tasks with TDD workflow
4. **Verify** - Confirm acceptance criteria met
5. **Quality** - Run quality commands (see guide below)

## Quality Commands — When to Use Which

Three commands form an **audit spectrum** from narrow to broad to deep:

| Command | Scope | Question It Answers | Output |
|---------|-------|-------------------|--------|
| `/draft:review` | Change-scoped (track, diff, commits) | "Does this change meet spec and quality gates?" | Three-stage review report with verdict |
| `/draft:bughunt` | Codebase-scoped (repo, paths, track) | "What bugs exist in this code?" | Severity-ranked bug report + regression tests |
| `/draft:deep-review` | Module-scoped (single service/component) | "Is this module production-ready?" | ACID compliance audit + implementation spec |

### Decision Guide

- **Just finished a track?** → `/draft:review` — validates against spec, checks quality gates
- **Suspicious of bugs across the codebase?** → `/draft:bughunt` — 11-dimension sweep with verification protocol
- **Shipping a module to production?** → `/draft:deep-review` — ACID compliance, resilience, observability audit
- **Want everything?** → `/draft:review full` (includes bughunt), then `/draft:deep-review` for critical modules

### Relationship to Built-in Bug Hunt Agents

Some AI tools provide built-in bug hunt agents (e.g., Claude Code's `bughunt` agent). These are **complementary** to `/draft:bughunt` — the built-in agents offer fast parallel sweeps with auto-fix, while Draft's bughunt adds context-aware analysis using your architecture, tech-stack, and product context for better false-positive elimination. For maximum coverage, run both.

## Context Files

When `draft/` exists, these files guide development:
- `draft/architecture.md` - Source of truth: comprehensive human-readable engineering reference
- `draft/.ai-context.md` - Derived from architecture.md: token-optimized AI context (200-400 lines)
- `draft/product.md` - Product vision and goals
- `draft/tech-stack.md` - Technical constraints
- `draft/workflow.md` - TDD and commit preferences
- `draft/guardrails.md` - Hard guardrails, learned conventions, learned anti-patterns
- `draft/tracks.md` - Active work items

## Status Markers

Used throughout plan.md files:

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |

## Intent Mapping

You can also use natural language:

| Say this... | Runs this |
|-------------|-----------|
| "set up the project" | `/draft:init` |
| "index services", "aggregate context" | `/draft:index` |
| "new feature", "add X" | `/draft:new-track` |
| "start implementing" | `/draft:implement` |
| "what's the status" | `/draft:status` |
| "undo", "revert" | `/draft:revert` |
| "break into modules" | `/draft:decompose` |
| "check coverage" | `/draft:coverage` |
| "deep review", "module audit", "production audit" | `/draft:deep-review` |
| "hunt bugs", "find bugs" | `/draft:bughunt` |
| "review code", "review track", "check quality" | `/draft:review` |
| "document decision", "create ADR" | `/draft:adr` |
| "requirements changed", "scope changed", "update the spec" | `/draft:change` |
| "learn patterns", "update guardrails", "discover conventions" | `/draft:learn` |
| "preview jira", "export to jira" | `/draft:jira-preview` |
| "create jira", "push to jira" | `/draft:jira-create` |


## Need Help?

- Run `/draft` (this command) for overview
- Run `/draft:status` to see current state
- Check `draft/tracks/<track_id>/spec.md` for requirements
- Check `draft/tracks/<track_id>/plan.md` for task details
