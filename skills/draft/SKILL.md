---
name: draft
description: Context-Driven Development methodology overview. Shows available Draft commands and guides you to the right workflow.
---

# Draft - Context-Driven Development

Draft is a methodology for structured software development: **Context → Spec & Plan → Implement**

## Available Commands

| Command | Purpose |
|---------|---------|
| `/draft:init` | Initialize project (run once) |
| `/draft:new-track` | Create feature/bug track with spec and plan |
| `/draft:implement` | Execute tasks from plan with TDD |
| `/draft:status` | Show progress overview |
| `/draft:revert` | Git-aware rollback |

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
- `draft/product.md` - Product vision and goals
- `draft/tech-stack.md` - Technical constraints
- `draft/workflow.md` - TDD and commit preferences
- `draft/tracks.md` - Active work items

## Status Markers

Used throughout plan.md files:
- `[ ]` - Pending
- `[~]` - In Progress
- `[x]` - Completed
- `[!]` - Blocked

## Intent Mapping

You can also use natural language:

| Say this... | Runs this |
|-------------|-----------|
| "set up the project" | `/draft:init` |
| "new feature", "add X" | `/draft:new-track` |
| "start implementing" | `/draft:implement` |
| "what's the status" | `/draft:status` |
| "undo", "revert" | `/draft:revert` |

## Need Help?

- Run `/draft` (this command) for overview
- Run `/draft:status` to see current state
- Check `draft/tracks/<track_id>/spec.md` for requirements
- Check `draft/tracks/<track_id>/plan.md` for task details
