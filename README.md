# Draft

**Measure twice, code once.**

A Claude Code plugin for Context-Driven Development. Draft specs and plans before implementation with structured workflows for features and fixes.

Also available for [Cursor](#cursor-integration).

## Installation

### Claude Code

**Quick Install (Recommended)**

```bash
curl -fsSL https://raw.githubusercontent.com/mayurpise/draft/main/install.sh | bash
```

Then restart Claude Code.

---

**Manual Installation**

<details>
<summary>Click to expand manual steps</summary>

**Step 1: Clone the plugin**

```bash
git clone https://github.com/mayurpise/draft.git ~/.claude/plugins/draft
```

**Step 2: Register the plugin**

Add to `~/.claude/plugins/installed_plugins.json` (create if doesn't exist):

```json
{
  "version": 2,
  "plugins": {
    "draft@local": [
      {
        "scope": "user",
        "installPath": "/home/YOUR_USERNAME/.claude/plugins/draft",
        "version": "1.0.0",
        "installedAt": "2026-01-20T00:00:00.000Z",
        "lastUpdated": "2026-01-20T00:00:00.000Z"
      }
    ]
  }
}
```

> Replace `YOUR_USERNAME` with your actual username, or use `$HOME` path.

**Step 3: Enable the plugin**

Add to `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "draft@local": true
  }
}
```

If the file already exists, just add `"draft@local": true` to the `enabledPlugins` object.

**Step 4: Restart Claude Code**

Close and reopen Claude Code to load the plugin.

**Verify installation:**

```bash
# In Claude Code, run:
/draft:status
```

</details>

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
