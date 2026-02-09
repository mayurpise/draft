# Draft Methodology

**Measure twice, code once.**

Draft is a methodology for Context-Driven Development that ensures consistent, high-quality delivery through: **Context → Spec & Plan → Implement**.

## Philosophy

### The Core Problem

AI coding assistants are powerful but undirected. Without structure, they:
- Make assumptions about requirements
- Choose arbitrary technical approaches
- Produce code that doesn't fit the existing codebase
- Lack accountability checkpoints

Draft solves this through **Context-Driven Development**: structured documents that constrain and guide AI behavior. By treating context as a managed artifact alongside code, your repository becomes a single source of truth that drives every agent interaction with deep, persistent project awareness.

### Why Each Document Exists

| Document | Purpose | Prevents |
|----------|---------|----------|
| `product.md` | Defines users, goals, success criteria | AI building features nobody asked for |
| `product-guidelines.md` | Style, branding, UX patterns | Inconsistent UI/UX decisions |
| `tech-stack.md` | Languages, frameworks, patterns | AI introducing random dependencies |
| `architecture.md` | System map, data flows, patterns, mermaid diagrams | AI re-analyzing codebase every session |
| `workflow.md` | TDD preference, commit style, review process | AI skipping tests or making giant commits |
| `spec.md` | Acceptance criteria for a specific track | Scope creep, gold-plating |
| `plan.md` | Ordered phases with verification steps | AI attempting everything at once |

### The Constraint Hierarchy

```
product.md          →  "Build a task manager for developers"
  ↓
tech-stack.md       →  "Use React, TypeScript, Tailwind"
  ↓
architecture.md     →  "Express API → Service layer → Prisma ORM → PostgreSQL"
  ↓
spec.md             →  "Add drag-and-drop reordering"
  ↓
plan.md             →  "Phase 1: sortable list, Phase 2: persistence"
```

Each layer narrows the solution space. By the time AI writes code, most decisions are already made.

### Keeping AI Constrained

Without constraints, AI will:
1. **Over-engineer** — add abstractions, utilities, "improvements" you didn't ask for
2. **Assume context** — guess at requirements instead of asking
3. **Lose focus** — drift across the codebase making tangential changes
4. **Skip verification** — claim completion without proving it works

| Mechanism | Effect |
|-----------|--------|
| Explicit spec | AI can only implement what's documented |
| Phased plans | AI works on one phase at a time |
| Verification steps | Each phase requires proof of completion |
| Status markers | Progress is tracked, not assumed |

The AI becomes an executor of pre-approved work, not an autonomous decision-maker.

### Human Review Before AI Codes

**This is Draft's most important feature.**

The workflow:
1. Developer runs `/draft:new-track` — AI creates `spec.md` and `plan.md`
2. Developer reviews and edits these documents
3. Developer commits them for peer review
4. Team approves the approach
5. *Only then* does `/draft:implement` begin

| Traditional AI Coding | Draft Approach |
|-----------------------|----------------|
| AI writes code immediately | AI writes spec first |
| Review happens on code PR | Review happens on spec PR |
| Disagreements require rewriting code | Disagreements resolved before coding |
| AI decisions are implicit | AI decisions are documented |

**Benefits:**
- **Faster reviews** — Reviewers approve approach, not implementation details
- **Fewer rewrites** — Catch design issues before code exists
- **Knowledge transfer** — Specs document *why*, not just *what*
- **Accountability** — Clear record of what was requested vs. delivered
- **Onboarding** — New team members read specs to understand features

### Team Workflow: Alignment Before Code

Draft's artifacts are designed for team collaboration through standard git workflows. Before any code is written, every markdown file goes through **commit → review → update → merge** until the team is aligned.

**The PR cycle on documents:**

1. **Project context** — Tech lead runs `/draft:init`. Team reviews `product.md`, `tech-stack.md`, and `workflow.md` via PR. Product managers review vision without reading code. Engineers review technical choices without context-switching into implementation.
2. **Spec & plan** — Lead runs `/draft:new-track`. Team reviews `spec.md` (requirements, acceptance criteria) and `plan.md` (phased task breakdown, dependencies) via PR. Disagreements surface as markdown comments — resolved by editing a paragraph, not rewriting a module.
3. **Architecture** — Lead runs `/draft:decompose`. Team reviews `architecture.md` (module boundaries, API surfaces, dependency graph, implementation order) via PR. Senior engineers validate architecture without touching the codebase.
4. **Work distribution** — Lead runs `/draft:jira-preview` and `/draft:jira-create`. Epics, stories, and sub-tasks are created from the approved plan. Individual team members pick up Jira stories and implement — with or without `/draft:implement`.
5. **Implementation** — Only after all documents are merged does coding start. Every developer has full context: what to build (`spec.md`), in what order (`plan.md`), with what boundaries (`architecture.md`).

**Why this works:** The CLI is single-user, but the artifacts it produces are the collaboration layer. Draft handles planning and decomposition. Git handles review. Jira handles distribution. Changing a sentence in `spec.md` takes seconds. Changing an architectural decision after 2,000 lines of code takes days.

### When to Use Draft

**Good fit:**
- Features requiring design decisions
- Work that will be reviewed by others
- Complex multi-step implementations
- Anything where "just do it" has failed before

**Overkill:**
- One-line bug fixes
- Typo corrections
- Exploratory prototypes you'll throw away

Draft adds structure. Use it when structure has value.

### Problems with Chat-Driven Development

Traditional AI chat interfaces have fundamental limitations:

| Problem | Impact |
|---------|--------|
| **Context window fills up** | Long chats exhaust token limits; AI loses early context |
| **Hallucination increases with context size** | More tokens → more confusion → worse decisions |
| **No persistent memory** | Close the chat, lose the context |
| **Unsearchable history** | "Where did I work on feature X?" — good luck finding it |
| **No team visibility** | Your chat history is invisible to colleagues |
| **Repeated context loading** | Every session starts from zero |

### How Draft Solves This

| Draft Approach | Benefit |
|----------------|---------|
| **File-based context** | Persistent memory on the filesystem |
| **Git-tracked specs** | Version history, diffs, blame |
| **Scoped context loading** | Only load what's needed for the current track |
| **Fewer tokens used** | Smaller context → better AI decisions |
| **Searchable artifacts** | `grep` your specs, not chat logs |
| **Team-visible planning** | Specs and plans are PR-reviewable |

### The Economics

Writing specs feels slower. It isn't.

| Scenario | Without Spec | With Spec |
|----------|--------------|-----------|
| Simple feature | 1 hour | 1.2 hours |
| Feature with ambiguity | 3 hours + rework | 2 hours |
| Feature requiring team input | 5 hours + meetings + rework | 2.5 hours |
| Wrong feature entirely | Days wasted | Caught in review |

The overhead is constant (~20% for simple tasks). The savings scale with:
- **Complexity** — More moving parts = more value from upfront planning
- **Team size** — More reviewers = more value from documented decisions
- **Criticality** — Higher stakes = more value from discipline

For critical product development, Draft isn't overhead — it's risk mitigation.

## Installation & Getting Started

### Prerequisites

- **Claude Code CLI** — Install from [claude.ai/code](https://claude.ai/code) or via `npm install -g @anthropic-ai/claude-code`
- **Git** — Version control is required for track history, revert, and commit workflows
- **Node.js 18+** — Required for Claude Code CLI

### Install Draft Plugin

```bash
# From Claude Code CLI
claude plugin install draft

# Or clone and install locally
git clone https://github.com/mayurpise/draft.git ~/.claude/plugins/draft
```

### Verify Installation

```bash
# Run the overview command
/draft
```

You should see the list of available Draft commands. If not, check that the plugin directory is correctly placed under `~/.claude/plugins/`.

### Quick Start

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

### Cursor Integration (Optional)

Draft also works as a Cursor rules file:

```bash
# Download directly (no clone required)
curl -o .cursorrules https://raw.githubusercontent.com/mayurpise/draft/main/integrations/cursor/.cursorrules

# Or copy from a local clone
cp ~/.claude/plugins/draft/integrations/cursor/.cursorrules /your-project/.cursorrules
```

This gives Cursor the same methodology awareness, though without slash commands.

### GitHub Copilot Integration (Optional)

Draft also works with GitHub Copilot via `copilot-instructions.md`:

```bash
# Download directly (no clone required)
mkdir -p .github
curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/copilot/.github/copilot-instructions.md

# Or copy from a local clone
cp ~/.claude/plugins/draft/integrations/copilot/.github/copilot-instructions.md /your-project/.github/
```

This gives Copilot the same methodology awareness. Commands use natural language (`draft init`, `draft new-track`) instead of `@` mentions.

### Gemini Integration (Optional)

Draft also works with Gemini Code Assist and Gemini CLI via `GEMINI.md`:

```bash
# Download directly (no clone required)
curl -o GEMINI.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/gemini/GEMINI.md

# Or copy from a local clone
cp ~/.claude/plugins/draft/integrations/gemini/GEMINI.md /your-project/GEMINI.md
```

Place `GEMINI.md` at the root of your project. Commands use `@draft` syntax.

---

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
├── spec.md          # Requirements and acceptance criteria
├── plan.md          # Phased task breakdown
├── metadata.json    # Status and timestamps
└── jira-export.md   # Jira stories for export (optional)
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
| `architecture.md` | System map, data flows, patterns, mermaid diagrams (brownfield) |
| `workflow.md` | TDD preferences, commit strategy |
| `jira.md` | Jira project configuration (optional) |
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

## Command Workflows

### `/draft:init` — Initialize Project

Initializes a Draft project by creating the `draft/` directory and context files. Run once per project.

#### Project Discovery

Draft auto-classifies the project:

- **Brownfield (existing codebase):** Detected by the presence of `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `src/`, or git history with commits. Draft scans the existing stack and pre-fills `tech-stack.md`.
- **Greenfield (new project):** Empty or near-empty directory. Developer provides all context through dialogue.

#### Initialization Sequence

1. **Project discovery** — Classify as brownfield (existing) or greenfield (new)
2. **Architecture discovery (brownfield only)** — Three-phase deep analysis of the existing codebase → `draft/architecture.md`:
   - **Phase 1: Orientation** — Directory structure, entry points, critical paths, request/response flows, tech stack inventory. Generates mermaid diagrams: system architecture (`graph TD`), directory hierarchy (`graph TD`), request flow (`sequenceDiagram`).
   - **Phase 2: Logic** — Data lifecycle mapping, primary domain objects, design pattern recognition, anti-pattern/complexity hotspot flagging, convention extraction, external dependency mapping. Generates mermaid diagrams: data flow (`flowchart LR`), external integrations (`graph LR`).
   - **Phase 3: Module Discovery** — Reverse-engineers existing modules from import graph and directory boundaries. Documents each module's responsibility, files, API surface, dependencies, and complexity. Generates module dependency diagram (`graph LR`), dependency table, and topological dependency order. `/draft:decompose` later extends (not replaces) these modules when planning new features.
   - This document becomes persistent context — every future track references it instead of re-analyzing the codebase.
3. **Product definition** — Dialogue to define product vision, users, goals, constraints → `draft/product.md`
4. **Product guidelines (optional)** — Writing style, visual identity, UX principles → `draft/product-guidelines.md`
5. **Tech stack** — Auto-detected for brownfield (cross-referenced with architecture discovery); manual for greenfield → `draft/tech-stack.md`
6. **Workflow configuration** — TDD preference (strict/flexible/none), commit style, review process → `draft/workflow.md`
7. **Note:** Architecture features (module decomposition, stories, execution state, skeletons, chunk reviews) are automatically enabled when you run `/draft:decompose` on a track. File-based activation - no opt-in needed.
8. **Tracks registry** — Empty tracks list → `draft/tracks.md`
9. **Directory structure** — Creates `draft/tracks/` directory

If `draft/` already exists with context files, init reports "already initialized" and suggests using `/draft:init refresh` or `/draft:new-track`.

#### Refresh Mode (`/draft:init refresh`)

Re-scans and updates existing context without starting from scratch:

1. **Tech Stack Refresh** — Re-scans `package.json`, `go.mod`, etc. Compares with existing `draft/tech-stack.md`. Proposes updates.
2. **Architecture Refresh** — Re-runs architecture discovery (Phase 1, 2 & 3) and diffs against existing `draft/architecture.md`. Detects new directories, removed components, changed integrations, new domain objects, new or merged modules. Updates mermaid diagrams. Preserves modules added by `/draft:decompose`. Presents changes for review before writing.
3. **Product Refinement** — Asks if product vision/goals in `draft/product.md` need updates.
4. **Workflow Review** — Asks if `draft/workflow.md` settings (TDD, commits) need changing.
5. **Preserve** — Does NOT modify `draft/tracks.md` unless explicitly requested.

---

### `/draft:index` — Monorepo Service Index

Aggregates Draft context from multiple services in a monorepo into unified root-level documents. Designed for organizations with multiple services, each with their own `draft/` context.

#### What It Does

1. **Scans** immediate child directories for services (detects `package.json`, `go.mod`, `Cargo.toml`, etc.)
2. **Reads** each service's `draft/product.md`, `draft/architecture.md`, `draft/tech-stack.md`
3. **Synthesizes** root-level documents:
   - `draft/service-index.md` — Service registry with status, tech, and links
   - `draft/dependency-graph.md` — Inter-service dependency topology
   - `draft/tech-matrix.md` — Technology distribution across services
   - `draft/product.md` — Synthesized product vision (if not exists)
   - `draft/architecture.md` — System-of-systems architecture view
   - `draft/tech-stack.md` — Org-wide technology standards

#### Flags

- `--init-missing` — Run `/draft:init` on services that lack a `draft/` directory

#### When to Use

- After running `/draft:init` on individual services
- After adding or removing services from the monorepo
- Periodically to refresh cross-service context

---

### `/draft:new-track` — Create Feature Track

Creates a new track (feature, bug fix, or refactor) with a specification and phased plan.

#### Context Loading

Every new track loads the full project context before spec creation:
- `draft/product.md` — product vision, users, goals
- `draft/tech-stack.md` — languages, frameworks, patterns
- `draft/architecture.md` — system map, modules, data flows (if exists)
- `draft/product-guidelines.md` — UX standards, style (if exists)
- `draft/workflow.md` — TDD preference, commit conventions
- `draft/tracks.md` — existing tracks (check for overlap/dependencies)

Every spec includes a **Context References** section that explicitly links back to these documents with a one-line description of how each is relevant to this track. This ensures every track is grounded in the big picture.

#### Track Types

New track auto-detects the track type from the description and dialogue:

| Type | Indicators | Spec Template | Plan Structure |
|------|-----------|---------------|----------------|
| **Feature / Refactor** | "add", "implement", "refactor", "improve" | Standard spec | Flexible phases |
| **Bug / RCA** | "fix", "bug", "investigate", Jira bug ticket, "root cause", production incident | Bug spec with Code Locality, Blast Radius | Fixed 3-phase: Investigate → RCA → Fix |

#### Specification Creation (Feature)

Engages in dialogue to understand scope before generating `spec.md`:
- **What** — Exact scope and boundaries
- **Why** — Business/user value
- **Acceptance criteria** — How we know it's done
- **Non-goals** — What's explicitly out of scope
- **Technical approach** — High-level approach based on tech-stack.md and architecture.md

#### Specification Creation (Bug / RCA)

For bugs, incidents, and Jira-sourced issues. Focused investigation, not broad exploration:
- **Symptoms** — Exact error, affected users/flows, frequency
- **Reproduction** — Steps to trigger, environment conditions
- **Blast Radius** — What's broken AND what's not (scopes the investigation)
- **Code Locality** — Direct `file:line` references to suspect area, entry point, related code
- **Investigation Constraints** — Stay in the blast radius, respect module boundaries

The spec is presented for approval and iterated until the developer is satisfied.

#### Plan Creation

Based on the approved spec, generates a phased task breakdown in `plan.md`:
- **Feature tracks:** Tasks organized into phases (Foundation → Implementation → Integration → Polish)
- **Bug tracks:** Fixed 3-phase structure: Investigate & Reproduce → Root Cause Analysis → Fix & Verify. Includes an RCA Log table for tracking hypotheses.
- Each task specifies target files and test files
- Dependencies between tasks are documented
- Verification criteria defined per phase

Also creates `metadata.json` (status tracking) and registers the track in `draft/tracks.md`.

#### Track ID

Auto-generated kebab-case from the description:
- Full description converted to lowercase
- Spaces replaced with hyphens
- Special characters removed
- Examples:
  - "Add user authentication" → `add-user-authentication`
  - "Fix: login bug" → `fix-login-bug`
  - "Update project docs" → `update-project-docs`

---

### `/draft:implement` — Execute Tasks

Implements tasks from the active track's plan, following the TDD workflow when enabled.

#### Task Selection

Scans `plan.md` for the first uncompleted task:
- `[ ]` Pending — picks this one
- `[~]` In Progress — resumes this one
- `[x]` Completed — skips
- `[!]` Blocked — skips, notifies user

#### TDD Cycle (when enabled in `workflow.md`)

1. **RED** — Write a failing test that captures the requirement. Run the test, verify it fails with an assertion failure (not a syntax error).
2. **GREEN** — Write the minimum code to make the test pass. Run the test, verify it passes.
3. **REFACTOR** — Clean up the code while keeping tests green. Run all related tests after each change.

Red flags that stop the cycle: writing code before a test exists, test passes immediately, running tests mentally instead of executing.

#### Architecture Mode Checkpoints (when architecture.md exists)

**Activation:** Automatically enabled when track has `draft/tracks/<id>/architecture.md` (created by `/draft:decompose`).

Before the TDD cycle, three additional mandatory checkpoints:

1. **Story** — Natural-language algorithm description (Input → Process → Output) written as a comment at the top of the code file. Developer approves before proceeding.
2. **Execution State** — Define intermediate state variables needed for processing. Developer approves.
3. **Function Skeletons** — Generate function stubs with complete signatures and docstrings, no implementation bodies. Developer approves.

Additionally, implementation chunks are limited to ~200 lines with a review checkpoint after each chunk.

#### Progress Updates

After each task: update `plan.md` status markers, increment `metadata.json` counters, commit per workflow conventions.

#### Phase Boundary Review

When all tasks in a phase are `[x]`, a two-stage review is triggered:
1. **Stage 1: Spec Compliance** — Verify all requirements for the phase are implemented
2. **Stage 2: Code Quality** — Verify patterns, error handling, test quality; classify issues as Critical/Important/Minor

Only proceeds to the next phase if no Critical issues remain.

#### Track Completion

When all phases complete: update `plan.md`, `metadata.json`, and `draft/tracks.md`. Move the track from Active to Completed.

---

### `/draft:status` — Show Progress

Displays a comprehensive overview of project progress:
- All active tracks with phase and task counts
- Current task indicator
- Module status (if `architecture.md` exists) with coverage percentages
- Blocked items with reasons
- Recently completed tracks
- Quick stats summary

---

### `/draft:revert` — Git-Aware Rollback

Safely undo work at three levels:

| Level | What It Reverts |
|-------|----------------|
| **Task** | Single task's commits |
| **Phase** | All commits in a phase |
| **Track** | Entire track's commits |

#### Revert Process

1. **Identify commits** — Finds commits matching the track's commit pattern (`feat(<track_id>): ...`)
2. **Preview** — Shows commits, affected files, and plan.md status changes before executing
3. **Confirm** — Requires explicit user confirmation
4. **Execute** — Runs `git revert --no-commit` for each commit (newest first), then creates a single revert commit
5. **Update Draft state** — Reverts task markers from `[x]` to `[ ]`, decrements metadata counters

If a revert produces merge conflicts, Draft reports the conflicted files and halts. The user resolves conflicts manually, then runs `git revert --continue`.

---

### `/draft:decompose` — Module Decomposition

Breaks a project or track into modules with clear responsibilities, dependencies, and implementation order.

#### Scope

- **Project-wide** (`/draft:decompose project`) → `draft/architecture.md`
- **Track-scoped** (`/draft:decompose` with active track) → `draft/tracks/<id>/architecture.md`

#### Process

1. **Load context** — Read product.md, tech-stack.md, spec.md; scan codebase for brownfield projects (directory structure, entry points, existing module boundaries, import patterns)
2. **Module identification** — Propose modules with: name, responsibility, files, API surface, dependencies, complexity. Each module targets 1-3 files with a single responsibility.
3. **CHECKPOINT** — Developer reviews and modifies module breakdown
4. **Dependency mapping** — Map inter-module imports, detect cycles, generate ASCII dependency diagram, determine implementation order via topological sort
5. **CHECKPOINT** — Developer reviews dependency diagram and implementation order
6. **Generate `architecture.md`** — Module definitions, dependency diagram/table, implementation order, story placeholders
7. **Update plan.md (track-scoped only)** — Restructure phases to align with module boundaries, preserving completed/in-progress task states

#### Cycle Breaking

When circular dependencies are detected, Draft proposes one of: extract shared interface module, invert dependency direction, or merge the coupled modules.

---

### `/draft:coverage` — Code Coverage Report

Measures test coverage quality after implementation. Complements TDD — TDD is the process, coverage is the measurement.

#### Process

1. **Detect coverage tool** — Auto-detect from tech-stack.md or project config files (jest, vitest, pytest-cov, go test -coverprofile, cargo tarpaulin, etc.)
2. **Determine scope** — Argument-provided path, architecture module files, track-changed files, or full project
3. **Run coverage** — Execute the coverage command and capture output
4. **Report** — Per-file breakdown with line/branch percentages and uncovered line ranges
5. **Gap analysis** — Classify uncovered lines:
   - **Testable** — Should be covered; suggests specific tests to write
   - **Defensive** — Error handlers for impossible states; acceptable to leave uncovered
   - **Infrastructure** — Framework boilerplate; acceptable
6. **CHECKPOINT** — Developer reviews and approves
7. **Record results** — Update plan.md with coverage section, architecture.md module status, and metadata.json

Target: 95%+ line coverage (configurable in `workflow.md`).

---

### `/draft:jira-preview` — Preview Jira Issues

Generates a `jira-export.md` file from the track's plan for review before creating Jira issues.

#### Mapping

| Draft Concept | Jira Entity |
|---------------|-------------|
| Track | Epic |
| Phase | Story |
| Task | Sub-task |

Story points are auto-calculated from task count per phase (1-2 tasks = 1pt, 3-4 = 2pt, 5-6 = 3pt, 7+ = 5pt).

The export file is editable — adjust points, descriptions, or sub-tasks before running `/draft:jira-create`.

---

### `/draft:jira-create` — Create Jira Issues

Creates Jira epic, stories, and sub-tasks from `jira-export.md` via MCP-Jira integration. Auto-generates the export file if missing.

Creates issues in order: Epic → Stories (one per phase) → Sub-tasks (one per task). Updates plan.md and jira-export.md with Jira issue keys after creation.

Requires MCP-Jira server configuration and `draft/jira.md` with project key.

---

### `/draft:validate` — Codebase Quality Validation

Validates codebase quality using Draft context (architecture.md, tech-stack.md, product.md). Runs architecture conformance, security scan, and performance analysis.

#### Scope

- **Track-level:** `--track <id>` — validates files touched by a specific track
- **Project-level:** `--project` — validates entire codebase

Generates report at `draft/tracks/<id>/validation-report.md` (track) or `draft/validation-report.md` (project). Non-blocking by default — reports warnings without halting workflow.

---

### `/draft:bughunt` — Exhaustive Bug Discovery

Systematic bug hunt across 12 dimensions: correctness, reliability, security, performance, UI responsiveness, concurrency, state management, API contracts, accessibility, configuration, tests, and maintainability.

#### Process

1. Load Draft context (architecture, tech-stack, product)
2. For tracks: verify implementation matches spec requirements
3. Analyze code across all 12 dimensions
4. Verify each finding (trace code paths, check for mitigations, eliminate false positives)
5. Generate severity-ranked report with fix recommendations

Generates report at `draft/bughunt-report.md` or `draft/tracks/<id>/bughunt-report.md`.

---

### `/draft:review` — Code Review Orchestrator

Standalone review command that orchestrates two-stage code review with optional quality tool integration.

#### Track-Level Review

Reviews a track's implementation against its spec.md and plan.md:
- **Stage 1:** Spec Compliance — verifies all requirements and acceptance criteria are met
- **Stage 2:** Code Quality — architecture, error handling, testing, maintainability (only if Stage 1 passes)

Extracts commit SHAs from plan.md to determine diff range. Supports fuzzy track matching.

#### Project-Level Review

Reviews arbitrary changes (code quality only, no spec compliance):
- `--project` — uncommitted changes
- `--files <pattern>` — specific file patterns
- `--commits <range>` — commit range

#### Quality Integration

- `--with-validate` — include `/draft:validate` results
- `--with-bughunt` — include `/draft:bughunt` findings
- `--full` — run both validate and bughunt

Generates unified report with deduplication across tools.

---

## Architecture Mode

Draft supports granular pre-implementation design for complex projects. **Architecture mode is automatically enabled when `architecture.md` exists** - no manual configuration needed.

**How it works:**
1. Run `/draft:decompose` on a track → Creates `draft/tracks/<id>/architecture.md`
2. Run `/draft:implement` → Automatically detects architecture.md and enables architecture features
3. Features: Story writing, Execution State design, Function Skeletons, ~200-line chunk reviews

See `core/agents/architect.md` for detailed decomposition rules, story writing, and skeleton generation.

### Module Decomposition

Use `/draft:decompose` to break a project or track into modules:

- **Project-wide:** `draft/architecture.md` — overall codebase module structure
- **Per-track:** `draft/tracks/<id>/architecture.md` — module breakdown for a specific feature

Each module defines: responsibility, files, API surface, dependencies, complexity. Modules are ordered by dependency graph (topological sort) to determine implementation sequence.

### Pre-Implementation Design

When `architecture.md` exists for a track, `/draft:implement` automatically enables three additional checkpoints before the TDD cycle:

1. **Story** — Natural-language algorithm description (Input → Process → Output) written as a comment at the top of the code file. Captures the "how" before coding. Mandatory checkpoint for developer approval.

2. **Execution State** — Define intermediate state variables (input state, intermediate state, output state, error state) needed for processing. Bridges the gap between algorithm and code structure. Mandatory checkpoint.

3. **Function Skeletons** — Generate function/method stubs with complete signatures, types, and docstrings. No implementation bodies. Developer approves names, signatures, and structure before TDD begins. Mandatory checkpoint.

Additionally, implementation chunks are limited to ~200 lines with a review checkpoint after each chunk.

### Code Coverage

Use `/draft:coverage` after implementation to measure test quality:

- Auto-detects coverage tool from `tech-stack.md`
- Targets 95%+ line coverage (configurable in `workflow.md`)
- Reports per-file breakdown and identifies uncovered lines
- Classifies gaps: testable (should add tests), defensive (acceptable), infrastructure (acceptable)
- Results recorded in `plan.md` and `architecture.md` using the following format:

#### Coverage Results Format (plan.md)

Add a `## Coverage` section at the end of the relevant phase:

```markdown
## Coverage
- **Overall:** 96.2% line coverage (target: 95%)
- **Tool:** jest --coverage
- **Date:** 2026-02-01

| File | Lines | Covered | % | Uncovered Lines |
|------|-------|---------|---|-----------------|
| src/auth.ts | 120 | 116 | 96.7% | 45, 88, 112, 119 |
| src/config.ts | 80 | 80 | 100% | - |

### Gaps
- **Testable:** `auth.ts:45` — error branch for expired token (add test)
- **Defensive:** `auth.ts:88` — unreachable fallback (acceptable)
- **Infrastructure:** `auth.ts:112,119` — logging statements (acceptable)
```

#### Coverage Results Format (architecture.md)

Update each module's status line to include coverage:

```markdown
- **Status:** [x] Complete — 96.7% coverage
```

And add a coverage summary in the Notes section:

```markdown
## Notes
- Overall coverage: 96.2% (target: 95%)
- Uncovered gaps classified and documented in plan.md
```

Coverage complements TDD — TDD is the process (write test, implement, refactor), coverage is the measurement.

### When to Use Architecture Mode

**Good fit:**
- Multi-module features with component dependencies
- New projects where architecture decisions haven't been made
- Complex algorithms or data transformations
- Teams wanting maximum review granularity

**Overkill:**
- Simple features touching 1-2 files
- Bug fixes with clear scope
- Configuration changes

### Workflow with Architecture Mode

```
/draft:init
     │ (creates draft/architecture.md for brownfield)
     │
/draft:new-track "feature"
     │ (creates draft/tracks/feature/spec.md + plan.md)
     │
/draft:decompose
     │ (creates draft/tracks/feature/architecture.md)
     │ → Architecture mode AUTO-ENABLED
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

**Key insight:** Running `/draft:decompose` automatically enables architecture features for that track. No manual configuration needed.

---

## Jira Integration (Optional)

Sync tracks to Jira with a two-step workflow:

1. **Preview** (`/draft:jira-preview`) - Generate `jira-export.md` with epic and stories
2. **Review** - Adjust story points, descriptions, acceptance criteria as needed
3. **Create** (`/draft:jira-create`) - Push to Jira via MCP server

Story points are auto-calculated from task count:
- 1-2 tasks = 1 point
- 3-4 tasks = 2 points
- 5-6 tasks = 3 points
- 7+ tasks = 5 points

Requires `jira.md` configuration with project key, board ID, and epic link field.

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
| "index services", "aggregate context" | Monorepo service index |
| "new feature", "add X" | Create new track |
| "start implementing" | Execute tasks from plan |
| "what's the status" | Show progress overview |
| "undo", "revert" | Rollback changes |
| "break into modules" | Module decomposition |
| "check coverage" | Code coverage report |
| "validate", "check quality" | Codebase quality validation |
| "hunt bugs", "find bugs" | Systematic bug discovery |
| "review code", "review track" | Code review orchestrator (track/project) |
| "preview jira", "export to jira" | Preview Jira issues |
| "create jira issues" | Create Jira issues via MCP |
| "the plan" | Read active track's plan.md |
| "the spec" | Read active track's spec.md |

## Quality Disciplines

### Verification Before Completion

**Iron Law:** Evidence before claims, always.

Every completion claim requires:
1. Running verification command IN THE CURRENT MESSAGE
2. Reading full output and confirming result
3. Showing evidence with the claim
4. Only then updating status markers

**Never mark `[x]` without:**
- Fresh test/build/lint run in this message
- Confirmation that output shows success
- Evidence visible in the response

### Systematic Debugging

**Iron Law:** No fixes without root cause investigation first.

When blocked (`[!]`):
1. **Investigate** - Read errors, reproduce, trace data flow (NO fixes yet)
2. **Analyze** - Find similar working code, list differences
3. **Hypothesize** - Single hypothesis, smallest possible test
4. **Implement** - Regression test first, then fix, verify

See `core/agents/debugger.md` for detailed process.

### Root Cause Analysis (Bug Tracks)

**Iron Law:** No fix without a confirmed root cause. No investigation without scope boundaries.

For bug tracks (from Jira incidents, production bugs, regressions):
1. **Reproduce & Scope** - Confirm bug, define blast radius, map to architecture.md modules
2. **Trace & Analyze** - Follow data/control flow with `file:line` references, differential analysis
3. **Hypothesize & Confirm** - One hypothesis at a time, log all results (including failures)
4. **Fix & Prevent** - Regression test first, minimal fix within blast radius, blameless RCA summary

Key practices (from Google SRE and distributed systems engineering):
- **Blast radius first** — Know what's broken AND what isn't before investigating
- **Differential analysis** — Compare working vs. failing cases systematically
- **5 Whys** — Trace from symptom to systemic root cause
- **Blameless RCA** — Focus on systems and processes, not individuals
- **Code locality** — Every claim cites `file:line`, no hand-waving

See `core/agents/rca.md` for detailed process.

### Two-Stage Review

At phase boundaries:
1. **Stage 1: Spec Compliance** - Did implementation match specification?
2. **Stage 2: Code Quality** - Clean architecture, proper error handling, meaningful tests?

See `core/agents/reviewer.md` for detailed process.

---

## Agents

Draft includes five specialized agent behaviors that activate during specific workflow phases.

### Debugger Agent

Activated when a task is blocked (`[!]`). Enforces root cause investigation before any fix attempts.

**Four-Phase Process:**

| Phase | Goal | Output |
|-------|------|--------|
| **1. Investigate** | Understand what's happening (NO fixes) | Failure description and reproduction steps |
| **2. Analyze** | Find root cause, not symptoms | Root cause hypothesis with evidence |
| **3. Hypothesize** | Test with minimal change | Confirmed root cause or return to Phase 2 |
| **4. Implement** | Fix with confidence | Regression test + minimal fix + verification |

**Anti-patterns:** "Quick fixes" without understanding, changing multiple things at once, skipping reproduction, deleting code to "test".

**Escalation:** After 3 failed hypothesis cycles, document findings, list what's been eliminated, and ask for external input.

See `core/agents/debugger.md` for the full process.

### RCA Agent

Activated for bug/RCA tracks created via `/draft:new-track`. Provides structured Root Cause Analysis methodology extending the debugger agent with practices from Google SRE postmortem culture and distributed systems debugging.

**Four-Phase Process:**

| Phase | Goal | Output |
|-------|------|--------|
| **1. Reproduce & Scope** | Confirm bug, define blast radius, map to architecture.md modules | Reproduction steps + scoped investigation area |
| **2. Trace & Analyze** | Follow data/control flow to the divergence point | Flow trace with `file:line` references |
| **3. Hypothesize & Confirm** | Test one hypothesis at a time, document all results | Confirmed root cause with evidence |
| **4. Fix & Prevent** | Regression test first, minimal fix, RCA summary | Fix + test + blameless RCA document |

**Key Techniques:**
- **Differential Analysis** — Compare working vs. failing cases systematically
- **5 Whys** — Trace from immediate cause to systemic root cause
- **Blast Radius Scoping** — Define investigation boundaries before diving in
- **Hypothesis Logging** — Track every hypothesis (failed ones narrow the search)
- **Code Locality** — Every claim must cite `file:line`

**Root Cause Classification:** logic error, race condition, data corruption, config error, dependency issue, missing validation, state management, resource exhaustion.

**Anti-patterns:** Fixing symptoms without root cause, investigating the entire system, shotgun debugging, skipping failed hypothesis documentation, fixing adjacent issues "while we're here".

See `core/agents/rca.md` for the full process including distributed systems considerations.

### Reviewer Agent

Activated at phase boundaries during `/draft:implement`. Performs a two-stage review before proceeding to the next phase.

**Stage 1: Spec Compliance** — Did they build what was specified?
- Requirements coverage (all functional requirements implemented)
- Scope adherence (no missing features, no scope creep)
- Behavior correctness (edge cases, error scenarios, integration points)

If Stage 1 fails, gaps are listed and implementation resumes. Stage 2 does not run.

**Stage 2: Code Quality** — Is the code well-crafted?
- Architecture (follows project patterns, separation of concerns)
- Error handling (appropriate level, helpful user-facing errors)
- Testing (tests real logic, edge case coverage, maintainability)
- Maintainability (readable, no performance issues, no security vulnerabilities)

**Issue Classification:**

| Severity | Definition | Action |
|----------|------------|--------|
| **Critical** | Blocks release, breaks functionality, security issue | Must fix before proceeding |
| **Important** | Degrades quality, technical debt | Should fix before phase complete |
| **Minor** | Style, optimization, nice-to-have | Note for later, don't block |

See `core/agents/reviewer.md` for the output template and full process.

### Architect Agent

Activated during `/draft:decompose` and `/draft:implement` (when architecture mode is enabled). Guides structured pre-implementation design.

**Capabilities:**
- **Module decomposition** — Single responsibility, 1-3 files per module, clear API boundaries, testable in isolation
- **Dependency analysis** — Import mapping, cycle detection, topological sort for implementation order
- **Story writing** — Natural-language algorithm descriptions (Input → Process → Output); 5-15 lines max; describes the algorithm, not the implementation
- **Execution state design** — Define input/intermediate/output/error state variables before coding
- **Function skeleton generation** — Complete signatures with types and docstrings, no implementation bodies, ordered by control flow

**Story Lifecycle:**
1. **Placeholder** — Created during `/draft:decompose` in architecture.md
2. **Written** — Filled in during `/draft:implement` as code comments; developer approves
3. **Updated** — Maintained when algorithms change during refactoring

See `core/agents/architect.md` for module rules, API surface examples, and cycle-breaking framework.

### Planner Agent

Activated during `/draft:new-track` plan creation and `/draft:decompose`. Provides structured plan generation with phased task breakdown.

**Capabilities:**
- **Phase decomposition** — Break work into sequential phases with clear goals and verification criteria
- **Task ordering** — Dependencies between tasks, topological sort for implementation sequence
- **Integration with Architect Agent** — When architecture.md exists, aligns phases with module boundaries and dependency graph

**Key Principles:**
- Each phase should be independently verifiable
- Tasks within a phase should be ordered by dependency
- Phase boundaries are review checkpoints
- Plan structure mirrors spec requirements for traceability

See `core/agents/planner.md` for the full planning process and integration workflows.

---

## Communication Style

Lead with conclusions. Be concise. Prioritize clarity over comprehensiveness.

- Direct, professional tone
- Code over explanation when implementing
- Complete, runnable code blocks
- Show only changed lines with context for updates
- Ask clarifying questions only when requirements are genuinely ambiguous

## Principles

1. **Plan before you build** - Create specs and plans that guide development
2. **Maintain context** - Ensure agents follow style guides and product goals
3. **Iterate safely** - Review plans before code is written
4. **Work as a team** - Share project context across team members
5. **Verify before claiming** - Evidence before assertions, always
