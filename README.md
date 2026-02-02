# Draft

**Measure twice, code once.**

A Claude Code plugin for Context-Driven Development. Draft specs and plans before implementation with structured workflows for features and fixes.

Also available for [Cursor](#cursor-integration) and [GitHub Copilot](#github-copilot-integration).

## Why Draft?

AI coding assistants are powerful but undirected. Without structure, they make assumptions about requirements, choose arbitrary technical approaches, and skip verification. Draft solves this through **Context-Driven Development**: structured documents that constrain and guide AI behavior.

```
product.md  →  "Build a task manager for developers"
  ↓
tech-stack.md  →  "Use React, TypeScript, Tailwind"
  ↓
spec.md  →  "Add drag-and-drop reordering"
  ↓
plan.md  →  "Phase 1: sortable list, Phase 2: persistence"
```

Each layer narrows the solution space. By the time AI writes code, most decisions are already made.

## Installation

### Prerequisites

- **Claude Code CLI** — Install from [claude.ai/code](https://claude.ai/code) or via `npm install -g @anthropic-ai/claude-code`
- **Git** — Required for track history, revert, and commit workflows
- **Node.js 18+** — Required for Claude Code CLI

### Install Draft Plugin

```bash
# From Claude Code CLI
/plugin marketplace add mayurpise/draft
/plugin install draft
```

### Verify Installation

```bash
# Type this in Claude Code
/draft
```

You should see the list of available commands. If not, check that the plugin is listed in your installed plugins.

## Quick Start

```bash
# 1. Initialize project context (once per project)
/draft:init

# 2. Create a feature track with spec and plan
/draft:new-track "Add user authentication"

# 3. Review the generated spec.md and plan.md, then implement
/draft:implement

# 4. Check progress at any time
/draft:status
```

## Commands

### `/draft` — Overview

Shows available commands and guides you to the right workflow. Also supports natural language intent mapping:

| Say this... | Runs this |
|-------------|-----------|
| "set up the project" | `/draft:init` |
| "new feature", "add X" | `/draft:new-track` |
| "start implementing" | `/draft:implement` |
| "what's the status" | `/draft:status` |
| "undo", "revert" | `/draft:revert` |
| "break into modules" | `/draft:decompose` |
| "check coverage" | `/draft:coverage` |

---

### `/draft:init` — Initialize Project

Run once per project. Creates the `draft/` directory with context files.

```bash
/draft:init
```

**What it does:**
1. Detects brownfield (existing code) vs greenfield (new project) — auto-fills tech stack for existing projects
2. Creates `draft/product.md` through dialogue about vision, users, goals
3. Optionally creates `draft/product-guidelines.md` for style/branding/UX
4. Creates `draft/tech-stack.md` with languages, frameworks, patterns
5. Creates `draft/workflow.md` with TDD preference, commit style, review process
6. Optionally enables Architecture Mode (module decomposition, stories, skeletons, coverage)
7. Creates `draft/tracks.md` as the master track registry

**Output:**
```
draft/
├── product.md
├── product-guidelines.md   (optional)
├── tech-stack.md
├── workflow.md
└── tracks.md
```

---

### `/draft:new-track` — Create Feature Track

Creates a new track (feature, bug fix, or refactor) with a specification and phased plan.

```bash
/draft:new-track "Add user authentication"
/draft:new-track "Fix login redirect bug"
```

**What it does:**
1. Generates a kebab-case track ID (`add-user-auth`)
2. Engages in dialogue to create `spec.md` — scope, acceptance criteria, non-goals
3. Creates phased `plan.md` from the approved spec — tasks with files, tests, dependencies
4. Creates `metadata.json` for status tracking
5. Registers the track in `draft/tracks.md`

**Output:**
```
draft/tracks/add-user-auth/
├── spec.md           # Requirements and acceptance criteria
├── plan.md           # Phased task breakdown
└── metadata.json     # Status and timestamps
```

---

### `/draft:implement` — Execute Tasks

Implements tasks from the active track's plan using the TDD workflow.

```bash
/draft:implement
/draft:implement add-user-auth    # Specify track by ID
```

**What it does:**
1. Finds the next uncompleted task (`[ ]` or `[~]`) in the active track's plan
2. Executes the TDD cycle (if enabled): RED (failing test) → GREEN (minimum code) → REFACTOR (clean up)
3. Updates plan.md status markers and metadata.json counters
4. Commits per workflow conventions
5. At phase boundaries: runs two-stage review (spec compliance → code quality)
6. When all phases complete: marks track as completed

With Architecture Mode enabled, adds three mandatory checkpoints before TDD:
- Story (algorithm description) → developer approval
- Execution State (intermediate variables) → developer approval
- Function Skeletons (stubs with signatures) → developer approval

---

### `/draft:status` — Show Progress

Displays a comprehensive progress overview.

```bash
/draft:status
```

**Example output:**
```
═══════════════════════════════════════════════════════════
                      DRAFT STATUS
═══════════════════════════════════════════════════════════

PROJECT: My App

ACTIVE TRACKS
─────────────────────────────────────────────────────────
add-user-auth  Add User Authentication
  Status: [~] In Progress
  Phase:  2/3 (Phase 2: JWT Integration)
  Tasks:  5/12 complete
  ├─ [x] Task 1.1: Create user model
  ├─ [x] Task 1.2: Add password hashing
  ├─ [~] Task 2.1: Implement JWT signing  ← CURRENT
  └─ [ ] Task 2.2: Add token refresh

QUICK STATS
─────────────────────────────────────────────────────────
Active Tracks:    1
Total Tasks:      12
Completed:        5 (42%)
═══════════════════════════════════════════════════════════
```

---

### `/draft:revert` — Git-Aware Rollback

Safely undo work at task, phase, or track level.

```bash
/draft:revert
```

**Revert levels:**

| Level | What It Reverts |
|-------|----------------|
| Task | Single task's commits |
| Phase | All commits in a phase |
| Track | Entire track's commits |

**Process:**
1. Identifies commits by track pattern (`feat(<track_id>): ...`)
2. Shows preview with commits, affected files, and plan.md changes
3. Requires explicit confirmation
4. Executes `git revert` (newest first), creates single revert commit
5. Updates plan.md markers from `[x]` back to `[ ]`

If a revert produces merge conflicts, Draft reports them and halts for manual resolution.

---

### `/draft:decompose` — Module Decomposition

Breaks a project or track into modules with dependency mapping.

```bash
/draft:decompose project    # Project-wide → draft/architecture.md
/draft:decompose            # Track-scoped → draft/tracks/<id>/architecture.md
```

**What it does:**
1. Scans codebase for existing structure (brownfield) or works from spec (greenfield)
2. Proposes modules with: name, responsibility, files, API surface, dependencies, complexity
3. **CHECKPOINT** — developer reviews module breakdown
4. Maps dependencies, detects cycles, generates ASCII dependency diagram
5. **CHECKPOINT** — developer reviews dependency diagram and implementation order
6. Generates `architecture.md` with module definitions, dependency graph, and implementation order

---

### `/draft:coverage` — Code Coverage Report

Measures test coverage quality. Targets 95%+ line coverage.

```bash
/draft:coverage
/draft:coverage src/auth    # Scope to specific path
```

**What it does:**
1. Auto-detects coverage tool from tech stack (jest, vitest, pytest-cov, go test, cargo tarpaulin, etc.)
2. Runs coverage command and captures output
3. Reports per-file breakdown with uncovered line ranges
4. Classifies gaps: **testable** (should add tests), **defensive** (acceptable), **infrastructure** (acceptable)
5. **CHECKPOINT** — developer reviews and approves
6. Records results in plan.md, architecture.md, and metadata.json

---

### `/draft:jira-preview` — Preview Jira Issues

Generates a `jira-export.md` file from the track's plan for review.

```bash
/draft:jira-preview
```

Maps Draft concepts to Jira: Track → Epic, Phase → Story, Task → Sub-task. Story points auto-calculated from task count (1-2 tasks = 1pt, 3-4 = 2pt, 5-6 = 3pt, 7+ = 5pt).

The export file is editable — adjust points, descriptions, or sub-tasks before creating.

---

### `/draft:jira-create` — Create Jira Issues

Creates Jira issues from `jira-export.md` via MCP-Jira integration.

```bash
/draft:jira-create
```

Creates Epic → Stories → Sub-tasks in order. Updates plan.md and jira-export.md with issue keys. Auto-generates the export file if missing. Requires MCP-Jira server configuration.

---

## Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                        DRAFT WORKFLOW                             │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│   /draft:init              One-time project initialization      │
│        │                                                         │
│        ▼                                                         │
│   /draft:new-track         Create spec.md + plan.md             │
│        │                                                         │
│        ├─── (optional) ─── /draft:decompose → architecture.md   │
│        │                                                         │
│        ├──────────────────────────────────┐                      │
│        │                                  │ (optional)           │
│        ▼                                  ▼                      │
│   /draft:implement         /draft:jira-preview → jira-create    │
│        │                                                         │
│        ├─── (optional) ─── /draft:coverage → coverage report    │
│        │                                                         │
│        ▼                                                         │
│   /draft:status            Check progress anytime                │
│        │                                                         │
│        ▼                                                         │
│   /draft:revert            Git-aware rollback if needed          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Core Concepts

### Tracks

A **track** is a high-level unit of work (feature, bug fix, refactor):
- `spec.md` — Requirements and acceptance criteria
- `plan.md` — Phased task breakdown with verification steps
- `metadata.json` — Status, timestamps, completion counts

### Status Markers

| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending/New |
| `[~]` | In Progress |
| `[x]` | Completed |
| `[!]` | Blocked |

### TDD Workflow

When enabled in `workflow.md`:
1. **Red** — Write failing test first
2. **Green** — Implement minimum code to pass
3. **Refactor** — Clean up with tests green
4. **Commit** — Following project conventions

**Iron Law:** No production code without a failing test first.

## Team Workflow: Alignment Before Code

Draft's most powerful application is team-wide. Every markdown file goes through **commit → review → update → merge** before a single line of code is written.

### The PR cycle on documents

1. **Project context** — Tech lead runs `/draft:init`. Team reviews `product.md`, `tech-stack.md`, and `workflow.md` via PR. Product managers review vision without reading code.
2. **Spec & plan** — Lead runs `/draft:new-track`. Team reviews requirements, acceptance criteria, and phased task breakdown via PR. Disagreements resolved by editing a paragraph, not rewriting code.
3. **Architecture** — Lead runs `/draft:decompose`. Team reviews module boundaries, API surfaces, dependency graph, and implementation order via PR.
4. **Work distribution** — Lead runs `/draft:jira-preview` and `/draft:jira-create`. Stories created from the approved plan. Individual team members pick up Jira stories.
5. **Implementation** — Only after all documents are merged does coding start. Every developer has full context: what to build (`spec.md`), in what order (`plan.md`), with what boundaries (`architecture.md`).

The CLI is single-user, but the artifacts are the collaboration layer. Draft handles planning. Git handles review. Jira handles distribution.

## Architecture Mode

Enable during `/draft:init` for granular pre-implementation design. Recommended for complex multi-module projects.

### What It Enables

| Feature | Command | Purpose |
|---------|---------|---------|
| Module decomposition | `/draft:decompose` | Break project/track into modules with dependency mapping |
| Story checkpoints | `/draft:implement` | Algorithm documentation before coding |
| Execution state design | `/draft:implement` | Define intermediate variables before implementation |
| Function skeletons | `/draft:implement` | Approve stubs with full signatures before TDD |
| Chunk reviews | `/draft:implement` | ~200-line implementation size limits |
| Coverage reports | `/draft:coverage` | Measure test coverage (target 95%+) |

### When to Use

**Good fit:**
- Multi-module features with component dependencies
- New projects where architecture decisions haven't been made
- Complex algorithms or data transformations
- Teams wanting maximum review granularity

**Overkill:**
- Simple features touching 1-2 files
- Bug fixes with clear scope
- Configuration changes

### Architecture Mode Workflow

```
/draft:init (enable architecture mode)
     │
/draft:new-track
     │
/draft:decompose → architecture.md
     │
/draft:implement
     │  ├── Story → CHECKPOINT
     │  ├── Execution State → CHECKPOINT
     │  ├── Skeletons → CHECKPOINT
     │  ├── TDD (red/green/refactor)
     │  └── ~200-line chunk review → CHECKPOINT
     │
/draft:coverage → coverage report → CHECKPOINT
```

## Quality Disciplines

### Verification Before Completion

**Iron Law:** Evidence before claims, always. Every `[x]` requires a fresh test/build/lint run with visible proof.

### Systematic Debugging

When a task is blocked (`[!]`), Draft enforces a four-phase process:

1. **Investigate** — Read errors, reproduce, trace data flow (NO fixes yet)
2. **Analyze** — Find similar working code, list differences
3. **Hypothesize** — Single hypothesis, smallest possible test
4. **Implement** — Regression test first, then fix, verify

No random fixes. No "let me try this." Root cause first.

### Two-Stage Review

At phase boundaries, a mandatory review runs:

1. **Stage 1: Spec Compliance** — Did implementation match specification? All requirements met? No scope creep?
2. **Stage 2: Code Quality** — Clean architecture? Proper error handling? Meaningful tests?

Issues classified as Critical (must fix), Important (should fix), or Minor (note for later). Only Critical issues block progress.

### Code Coverage

After implementation, `/draft:coverage` measures test quality:
- Auto-detects coverage tool from tech stack
- Reports per-file breakdown with uncovered lines
- Classifies gaps: testable, defensive, infrastructure
- Targets 95%+ line coverage (configurable)

## Project Structure (After Setup)

```
your-project/
├── draft/
│   ├── product.md              # Product vision and goals
│   ├── product-guidelines.md   # Style, branding, UX standards (optional)
│   ├── tech-stack.md           # Technical choices
│   ├── workflow.md             # TDD, commit, architecture mode preferences
│   ├── architecture.md         # Project-wide module decomposition (optional)
│   ├── jira.md                 # Jira project configuration (optional)
│   ├── tracks.md               # Master track list
│   └── tracks/
│       └── <track-id>/
│           ├── spec.md         # Requirements
│           ├── plan.md         # Phased task breakdown
│           ├── metadata.json   # Status and timestamps
│           ├── architecture.md # Track-level module decomposition (optional)
│           └── jira-export.md  # Jira stories for export (optional)
```

## Troubleshooting

### "Project already initialized"

`/draft:init` detected existing `draft/` directory. Use `/draft:new-track` to create a feature or `/draft:implement` to continue work.

### "No active track found"

Run `/draft:new-track "description"` to create a track, or check `draft/tracks.md` to ensure a track has `[ ]` or `[~]` status.

### Tasks are `[!]` Blocked

Read the blocked reason in plan.md. Follow the four-phase debugging process (Investigate → Analyze → Hypothesize → Implement). Don't attempt random fixes.

### Revert conflicts

When `git revert` produces conflicts, Draft halts and reports affected files. Resolve conflicts manually, then run `git revert --continue`. Draft state updates only after successful revert completion.

### MCP-Jira not configured

`/draft:jira-create` requires an MCP-Jira server. Configure it in your Claude Code settings, then run the command again. The `jira-export.md` file can also be imported manually.

### Coverage tool not detected

If `/draft:coverage` can't detect your tool, check `draft/tech-stack.md` for an explicit testing section, or provide the coverage command when prompted.

## Contributing

### Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`) and execution instructions
2. Run `./scripts/build-integrations.sh` to regenerate all integrations
3. Document in this README

### Updating Methodology

1. Update `core/methodology.md` first (source of truth)
2. Apply changes to relevant `skills/` SKILL.md files
3. Run `./scripts/build-integrations.sh`

### Rebuilding Integrations

```bash
./scripts/build-integrations.sh
```

Integration files (`.cursorrules`, `copilot-instructions.md`) are auto-generated from skill files. Do not edit them directly.

### Plugin Structure

```
draft/
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
├── CLAUDE.md             # Context file (auto-loaded)
├── skills/               # Skill definitions (one per command)
│   ├── draft/SKILL.md
│   ├── init/SKILL.md
│   ├── new-track/SKILL.md
│   ├── implement/SKILL.md
│   ├── status/SKILL.md
│   ├── revert/SKILL.md
│   ├── decompose/SKILL.md
│   ├── coverage/SKILL.md
│   ├── jira-preview/SKILL.md
│   └── jira-create/SKILL.md
├── core/
│   ├── methodology.md       # Master methodology documentation
│   ├── templates/           # Templates for /draft:init
│   └── agents/              # Specialized agent behaviors
│       ├── architect.md
│       ├── debugger.md
│       └── reviewer.md
└── integrations/
    ├── cursor/
    │   └── .cursorrules     # GENERATED from skills
    └── copilot/.github/
        └── copilot-instructions.md  # GENERATED from skills
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

## GitHub Copilot Integration

Copy the `.github/` directory to your project root:

```bash
cp -r /path/to/draft/integrations/copilot/.github ~/my-project/.github
```

Or if you already have a `.github/` directory:

```bash
cp /path/to/draft/integrations/copilot/.github/copilot-instructions.md ~/my-project/.github/
```

The instructions file works with GitHub Copilot Chat in VS Code, JetBrains, and Neovim. Commands use natural language (`draft init`, `draft new-track`) instead of `@` mentions.

## Credits

Adapted from [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor).

## License

Apache 2.0
