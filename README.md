# Draft

**Measure twice, code once.**

A Claude Code plugin for Context-Driven Development. Draft specs and plans before implementation with structured workflows for features and fixes.

Also available for [Cursor](#cursor-integration).

## Installation

### Claude Code

```bash
# Clone to plugins directory
git clone https://github.com/mayurpise/draft.git ~/.claude/plugins/draft

# Or use directly
claude --plugin-dir /path/to/draft
```

## Quick Start

```bash
/draft:setup                              # Initialize project (once)
/draft:new-track "Add user authentication"  # Create a track
/draft:implement                          # Start implementing
/draft:status                             # Check progress
```

## Commands

| Command | Description |
|---------|-------------|
| `/draft:setup` | Initialize project context (run once) |
| `/draft:new-track` | Create a new feature/bug track with spec and plan |
| `/draft:implement` | Execute tasks from the current plan with TDD |
| `/draft:status` | Display progress overview |
| `/draft:revert` | Git-aware rollback of tasks/phases/tracks |

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

## Project Structure (After Setup)

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

## Core Concepts

### Tracks

A **track** is a high-level unit of work (feature, bug fix, refactor):
- `spec.md` - Requirements and acceptance criteria
- `plan.md` - Phased task breakdown
- `metadata.json` - Status and timestamps

### Status Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending/New |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |

### TDD Workflow

When enabled in workflow.md:
1. **Red** - Write failing test first
2. **Green** - Implement minimum code to pass
3. **Refactor** - Clean up with tests green
4. **Commit** - Following project conventions

## Plugin Structure

```
draft/
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
├── CLAUDE.md             # Context file (auto-loaded)
├── commands/             # Slash commands
│   ├── setup.md
│   ├── new-track.md
│   ├── implement.md
│   ├── status.md
│   └── revert.md
├── skills/
│   └── draft/
│       └── SKILL.md      # Auto-activation skill
├── core/                 # Shared methodology
│   ├── methodology.md
│   ├── templates/
│   └── agents/
└── integrations/
    └── cursor/           # Cursor integration
        └── .cursorrules
```

## Cursor Integration

Copy `.cursorrules` to your project root:

```bash
cp /path/to/draft/integrations/cursor/.cursorrules ~/my-project/.cursorrules
```

Then use in Cursor:
```
@draft setup
@draft new-track "Add user authentication"
@draft implement
```

See [integrations/cursor/README.md](integrations/cursor/README.md) for details.

## Credits

Adapted from [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor).

## License

Apache 2.0
