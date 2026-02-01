# Draft

**Measure twice, code once.**

A Claude Code plugin for Context-Driven Development. Draft specs and plans before implementation with structured workflows for features and fixes.

Also available for [Cursor](#cursor-integration).

## Installation

### Claude Code

```bash
/plugin marketplace add mayurpise/draft
/plugin install draft
```

**Verify installation:** Type `/draft` and you should see the commands appear.

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
| `/draft:jira-preview` | Generate Jira export file for review |
| `/draft:jira-create` | Create Jira issues from export via MCP |

## Workflow

```
┌───────────────────────────────────────────────────────────────┐
│                       DRAFT WORKFLOW                          │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│   /draft:init             One-time project initialization    │
│        │                                                      │
│        ▼                                                      │
│   /draft:new-track        Create spec.md + plan.md           │
│        │                                                      │
│        ├──────────────────────────────────┐                   │
│        │                                  │ (optional)        │
│        ▼                                  ▼                   │
│   /draft:implement        /draft:jira-preview → jira-create  │
│        │                                                      │
│        ▼                                                      │
│   /draft:status           Check progress anytime              │
│        │                                                      │
│        ▼                                                      │
│   /draft:revert           Git-aware rollback if needed        │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## Project Structure (After Setup)

```
your-project/
├── draft/
│   ├── product.md              # Product vision and goals
│   ├── product-guidelines.md   # Style, branding, UX standards (optional)
│   ├── tech-stack.md           # Technical choices
│   ├── workflow.md             # TDD and commit preferences
│   ├── jira.md                 # Jira project configuration (optional)
│   ├── tracks.md               # Master track list
│   └── tracks/
│       └── <track-id>/
│           ├── spec.md         # Requirements
│           ├── plan.md         # Phased task breakdown
│           ├── metadata.json   # Status and timestamps
│           └── jira-export.md  # Jira stories for export (optional)
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

### Jira Integration

Sync tracks to Jira with two-step workflow:
1. `/draft:jira-preview` - Generate `jira-export.md` with epic and stories
2. Review and adjust story points, descriptions as needed
3. `/draft:jira-create` - Push to Jira via MCP server

Story points auto-calculated: 1-2 tasks = 1pt, 3-4 = 2pt, 5-6 = 3pt, 7+ = 5pt

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
│   ├── revert/SKILL.md      # /draft:revert
│   ├── jira-preview/SKILL.md # /draft:jira-preview
│   └── jira-create/SKILL.md  # /draft:jira-create
├── core/                 # Shared methodology
│   ├── methodology.md       # Master methodology docs
│   ├── templates/           # Templates for init
│   │   ├── product.md
│   │   ├── product-guidelines.md
│   │   ├── tech-stack.md
│   │   ├── workflow.md
│   │   └── jira.md
│   └── agents/              # Specialized agent behaviors
│       ├── debugger.md
│       └── reviewer.md
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
