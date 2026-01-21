---
name: draft
description: Context-Driven Development methodology for structured software delivery. Provides planning, specification, and implementation workflows.
---

# Draft Skill

You are operating with the Draft methodology for Context-Driven Development.

## Core Workflow

**Context → Spec & Plan → Implement**

Every feature follows this lifecycle:
1. **Setup** - Initialize project context (once per project)
2. **New Track** - Create specification and plan
3. **Implement** - Execute tasks with TDD workflow
4. **Verify** - Confirm acceptance criteria met

## Available Commands

| Command | Purpose |
|---------|---------|
| `/draft:setup` | Initialize project (run once) |
| `/draft:new-track` | Create feature/bug track |
| `/draft:implement` | Execute tasks from plan |
| `/draft:status` | Show progress overview |
| `/draft:revert` | Git-aware rollback |

## Context Files

When `draft/` exists, always consider:
- `draft/product.md` - Product vision and goals
- `draft/tech-stack.md` - Technical constraints
- `draft/workflow.md` - TDD and commit preferences
- `draft/tracks.md` - Active work items

## Intent Mapping

Recognize these natural language patterns:

| User Says | Action |
|-----------|--------|
| "set up the project" | `/draft:setup` |
| "new feature", "add X" | `/draft:new-track` |
| "start implementing" | `/draft:implement` |
| "what's the status" | `/draft:status` |
| "undo", "revert" | `/draft:revert` |
| "the plan" | Read active track's plan.md |
| "the spec" | Read active track's spec.md |

## TDD Workflow

When implementing tasks (if TDD enabled in workflow.md):

1. **Red** - Write failing test first
2. **Green** - Implement minimum to pass
3. **Refactor** - Clean up with tests green

## Status Markers

Recognize and use these throughout plan.md:
- `[ ]` - Pending
- `[~]` - In Progress
- `[x]` - Completed
- `[!]` - Blocked

## Proactive Behaviors

1. **Context Loading** - Always read relevant draft files before acting
2. **Progress Tracking** - Update plan.md and metadata.json after each task
3. **Verification Prompts** - Ask for manual verification at phase boundaries
4. **Commit Suggestions** - Suggest commits following workflow.md patterns

## Error Recovery

If user seems lost:
- Check `/draft:status` to orient them
- Reference the active track's spec.md for requirements
- Suggest next steps based on plan.md state
