# Draft - Claude Code Plugin

**Measure twice, code once.**

A Claude Code plugin for Context-Driven Development. Draft specs and plans before implementation with structured workflows for features and fixes.

## Installation

### From GitHub
```bash
# Clone and use as plugin directory
git clone https://github.com/mayurpise/draft.git
claude --plugin-dir ./draft
```

### Copy to Global Plugins
```bash
git clone https://github.com/mayurpise/draft.git ~/.claude/plugins/draft
```

## Quick Start

```bash
# 1. Initialize your project
/draft:setup

# 2. Create a new feature track
/draft:new-track "Add user authentication with JWT"

# 3. Start implementing
/draft:implement

# 4. Check progress anytime
/draft:status
```

## Commands

| Command | Description |
|---------|-------------|
| `/draft:setup` | Initialize project context (run once) |
| `/draft:new-track` | Create a new feature/bug track with spec and plan |
| `/draft:implement` | Execute tasks from the current plan with TDD |
| `/draft:status` | Display progress overview |
| `/draft:revert` | Git-aware rollback of tasks/phases/tracks |

## Project Structure

After `/draft:setup`, your project will have:

```
your-project/
├── draft/
│   ├── product.md        # Product vision and goals
│   ├── tech-stack.md     # Technical choices
│   ├── workflow.md       # TDD and commit preferences
│   ├── tracks.md         # Master track list
│   └── tracks/
│       └── <track-id>/
│           ├── spec.md      # Requirements
│           ├── plan.md      # Phased task breakdown
│           └── metadata.json
```

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│                    DRAFT WORKFLOW                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   /draft:setup          One-time project initialization │
│        │                                                │
│        ▼                                                │
│   /draft:new-track      Create spec.md + plan.md       │
│        │                                                │
│        ▼                                                │
│   /draft:implement      TDD: Red → Green → Refactor    │
│        │                                                │
│        ▼                                                │
│   /draft:status         Check progress anytime         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Philosophy

**Control your code.** By treating context as a managed artifact alongside code, your repository becomes a single source of truth that drives every agent interaction with deep, persistent project awareness.

- **Plan before you build**: Create specs and plans that guide development
- **Maintain context**: Ensure Claude follows style guides and product goals
- **Iterate safely**: Review plans before code is written
- **Work as a team**: Share project context across team members

## TDD Workflow

When implementing (with TDD enabled in workflow.md):

1. **Red** - Write failing test first
2. **Green** - Implement minimum code to pass
3. **Refactor** - Clean up with tests green
4. **Commit** - Following project commit conventions

## Status Markers

Used throughout plan.md:

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending/New |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |

## Plugin Structure

```
draft/
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
├── CLAUDE.md             # Context file (auto-loaded)
├── commands/
│   ├── setup.md          # /draft:setup
│   ├── new-track.md      # /draft:new-track
│   ├── implement.md      # /draft:implement
│   ├── status.md         # /draft:status
│   └── revert.md         # /draft:revert
├── skills/
│   └── draft/
│       └── SKILL.md      # Auto-activation skill
├── agents/
│   └── planner.md        # Planning specialist
└── templates/
    ├── product.md
    ├── tech-stack.md
    └── workflow.md
```

## Credits

Adapted from [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor) for Claude Code.

## License

Apache 2.0
