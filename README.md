# Draft

**Measure twice, code once.**

A Claude Code plugin for Context-Driven Development. Draft specs and plans before implementation with structured workflows for features and fixes.

Also available for [Cursor](#cursor-integration).

## Installation

### Claude Code

**Option 1: Plugin Marketplace (Recommended)**

From within Claude Code:
```
/plugin marketplace add mayurpise/draft
/plugin install draft
```

The plugin persists across sessions — no need to specify flags each time.

**Option 2: Development Mode (--plugin-dir)**

For development or testing unreleased changes:

```bash
git clone https://github.com/mayurpise/draft.git ~/.claude/plugins/draft
claude --plugin-dir ~/.claude/plugins/draft
```

**Option 3: Quick Install Script**

```bash
curl -fsSL https://raw.githubusercontent.com/mayurpise/draft/main/install.sh | bash
```

Then start Claude Code with:
```bash
claude --plugin-dir ~/.claude/plugins/draft
```

---

**Verify installation:**

Type `/draft` and you should see the commands appear.

## Quick Start

```bash
/draft:init                               # Initialize project (once)
/draft:new-track "Add user authentication"  # Create a track
/draft:implement                          # Start implementing
/draft:status                             # Check progress
```

## Commands

| Command | Description |
|---------|-------------|
| `/draft` | Show overview and available commands |
| `/draft:init` | Initialize project context (run once) |
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
│   /draft:init           One-time project initialization │
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
├── skills/               # Skill definitions
│   ├── draft/SKILL.md       # Overview skill
│   ├── init/SKILL.md        # /draft:init
│   ├── new-track/SKILL.md   # /draft:new-track
│   ├── implement/SKILL.md   # /draft:implement
│   ├── status/SKILL.md      # /draft:status
│   └── revert/SKILL.md      # /draft:revert
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
@draft init
@draft new-track "Add user authentication"
@draft implement
```

See [integrations/cursor/README.md](integrations/cursor/README.md) for details.

## Credits

Adapted from [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor).

## License

Apache 2.0
