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

## Context Files

When `draft/` exists, these files guide development:
- `draft/.ai-context.md` - Source of truth for AI agents (dense codebase understanding)
- `draft/architecture.md` - Human-readable engineering guide (derived from .ai-context.md)
- `draft/product.md` - Product vision and goals
- `draft/tech-stack.md` - Technical constraints
- `draft/workflow.md` - TDD and commit preferences
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
| "deep review", "audit module" | `/draft:deep-review` |
| "hunt bugs", "find bugs" | `/draft:bughunt` |
| "review code", "review track" | `/draft:review` |
| "preview jira", "export to jira" | `/draft:jira-preview` |
| "create jira issues" | `/draft:jira-create` |

## Need Help?

- Run `/draft` (this command) for overview
- Run `/draft:status` to see current state
- Check `draft/tracks/<track_id>/spec.md` for requirements
- Check `draft/tracks/<track_id>/plan.md` for task details
