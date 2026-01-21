# Draft Methodology

**Measure twice, code once.**

Draft is a methodology for Context-Driven Development that ensures consistent, high-quality delivery through: **Context → Spec & Plan → Implement**.

## Philosophy

By treating context as a managed artifact alongside code, your repository becomes a single source of truth that drives every agent interaction with deep, persistent project awareness.

## Core Workflow

```
Context → Spec & Plan → Implement
```

1. **Setup** - Initialize project context (once per project)
2. **New Track** - Create specification and plan
3. **Implement** - Execute tasks with optional TDD workflow
4. **Verify** - Confirm acceptance criteria met

## Tracks

A **track** is a high-level unit of work (feature, bug fix, refactor). Each track contains:

```
draft/tracks/<track-id>/
├── spec.md        # Requirements and acceptance criteria
├── plan.md        # Phased task breakdown
└── metadata.json  # Status and timestamps
```

### Track Lifecycle

1. **Planning** - Spec and plan are being drafted
2. **In Progress** - Tasks are being implemented
3. **Completed** - All acceptance criteria met
4. **Archived** - Track is archived for reference

## Project Context Files

Located in `draft/` of the target project:

| File | Purpose |
|------|---------|
| `product.md` | Product vision, users, goals |
| `product-guidelines.md` | Style, branding, UX standards (optional) |
| `tech-stack.md` | Languages, frameworks, patterns |
| `workflow.md` | TDD preferences, commit strategy |
| `tracks.md` | Master list of all tracks |

## Status Markers

Used throughout spec.md and plan.md:

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending/New |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |

## Plan Structure

Plans are organized into phases:

1. **Foundation** - Core data structures, interfaces
2. **Implementation** - Main functionality
3. **Integration** - Connecting components
4. **Polish** - Error handling, edge cases, docs

### Task Granularity

Good tasks are:
- Completable in a focused session
- Have clear success criteria
- Produce testable output
- Fit in a single commit

## TDD Workflow (Optional)

When enabled in workflow.md:

1. **Red** - Write failing test first
2. **Green** - Implement minimum code to pass
3. **Refactor** - Clean up with tests green
4. **Commit** - Following project conventions

## Intent Mapping

Natural language patterns that map to Draft commands:

| User Says | Action |
|-----------|--------|
| "set up the project" | Initialize Draft |
| "new feature", "add X" | Create new track |
| "start implementing" | Execute tasks from plan |
| "what's the status" | Show progress overview |
| "undo", "revert" | Rollback changes |
| "the plan" | Read active track's plan.md |
| "the spec" | Read active track's spec.md |

## Principles

1. **Plan before you build** - Create specs and plans that guide development
2. **Maintain context** - Ensure agents follow style guides and product goals
3. **Iterate safely** - Review plans before code is written
4. **Work as a team** - Share project context across team members
