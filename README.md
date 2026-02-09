# Draft
https://getdraft.dev/

**Ship fast. Ship right.**

Enterprise discipline for AI-assisted development. Draft brings structure — specs, plans, tracks, validation — so AI acceleration doesn't mean technical debt.

Also available for [Cursor](#cursor-integration), [GitHub Copilot](#github-copilot-integration), and [Gemini](#gemini-integration).

## Why Draft?

AI coding tools are fast. They're also chaotic. Without structure, they make assumptions about requirements, choose arbitrary technical approaches, and skip verification. Draft solves this through **Context-Driven Development**: structured documents that constrain and guide AI behavior.

```
product.md       →  "Build a task manager for developers"
  ↓
tech-stack.md    →  "Use React, TypeScript, Tailwind"
  ↓
architecture.md  →  "Express API → Service layer → Prisma ORM → PostgreSQL"
  ↓
spec.md          →  "Add drag-and-drop reordering"
  ↓
plan.md          →  "Phase 1: sortable list, Phase 2: persistence"
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
| "validate", "check quality" | `/draft:validate` |
| "hunt bugs", "find bugs" | `/draft:bughunt` |
| "review code", "review track" | `/draft:review` |
| "preview jira", "export to jira" | `/draft:jira-preview` |
| "create jira issues" | `/draft:jira-create` |
| "index services", "aggregate context" | `/draft:index` |
| "document decision", "create ADR" | `/draft:adr` |

---

### `/draft:index` — Federated Monorepo Index

Aggregates context from multiple service-level `draft/` directories into a unified root-level knowledge base. Designed for enterprise monorepos with 50+ services.

```bash
/draft:index                 # Aggregate existing drafts
/draft:index --init-missing  # Also initialize services without draft/
```

**Key difference from `/draft:init`:**
- `/draft:init` does **deep code analysis** per service
- `/draft:index` **synthesizes existing drafts** without reading source code

**What it does:**
1. Scans immediate child directories (depth=1 only) for service markers
2. Categorizes services as initialized (has `draft/`) or uninitialized
3. Reads each service's `product.md`, `architecture.md`, `tech-stack.md`
4. Synthesizes root-level context files from aggregated service knowledge
5. Generates inter-service dependency graph from cross-references
6. Creates service registry with links to individual service drafts

**With `--init-missing` flag:**
- Prompts for each uninitialized service: `[y/n/all/skip-rest]`
- Runs `/draft:init` in selected services before aggregating

**Output:**
```
draft/
├── product.md           # Synthesized org-wide vision
├── architecture.md      # System-of-systems topology
├── tech-stack.md        # Org standards + variance report
├── service-index.md     # Service registry table (GENERATED)
├── dependency-graph.md  # Inter-service dependencies (GENERATED)
├── tech-matrix.md       # Technology distribution (GENERATED)
└── config.yaml          # Index configuration
```

**Design principles:**
- **Reference, don't duplicate** — Root files link to service files
- **Fast** — Reads markdown only, no code analysis
- **Regenerable** — Re-run anytime to refresh
- **Preserves manual edits** — Sections between `<!-- MANUAL START -->` and `<!-- MANUAL END -->` are never overwritten

**When to use:**
- First-time setup of monorepo-level context
- After adding new services
- Periodic refresh (weekly/monthly)
- Before cross-service planning

---

### `/draft:init` — Initialize Project

Run once per project. Creates the `draft/` directory with context files.

```bash
/draft:init            # Fresh initialization
/draft:init refresh    # Update existing context
```

**What it does:**
1. Detects brownfield (existing code) vs greenfield (new project)
2. **Architecture Discovery (brownfield only)** — Deep three-phase codebase analysis:
   - **Phase 1: Orientation** — Directory structure, entry points, critical paths, request/response flow (mermaid `sequenceDiagram`), tech stack inventory. Generates system architecture diagram (mermaid `graph TD`).
   - **Phase 2: Logic** — Data lifecycle mapping (mermaid `flowchart LR`), primary domain objects, design pattern recognition, anti-pattern/complexity hotspot detection, convention extraction, external dependency mapping (mermaid `graph LR`).
   - **Phase 3: Module Discovery** — Reverse-engineers existing modules from import graph and directory boundaries. Documents each module's responsibility, files, API surface, dependencies, and complexity. Generates module dependency diagram (mermaid `graph LR`), dependency table, and topological ordering. `/draft:decompose` extends (not replaces) these when planning new features.
   - Produces `draft/architecture.md` — persistent context every future track references instead of re-analyzing the codebase.
3. Creates `draft/product.md` through dialogue about vision, users, goals
4. Optionally creates `draft/product-guidelines.md` for style/branding/UX
5. Creates `draft/tech-stack.md` with languages, frameworks, patterns (with mermaid component diagram)
6. Creates `draft/workflow.md` with TDD preference, commit style, review process
7. Optionally enables Architecture Mode (module decomposition, stories, skeletons, coverage)
8. Creates `draft/tracks.md` as the master track registry

**Output (brownfield):**
```
draft/
├── architecture.md        # System map with mermaid diagrams
├── product.md
├── product-guidelines.md  (optional)
├── tech-stack.md
├── workflow.md
└── tracks.md
```

**Refresh mode** (`/draft:init refresh`):
- Re-scans tech stack and compares with existing `tech-stack.md`
- Re-runs architecture discovery and diffs against existing `architecture.md` — detects new directories, removed components, changed integrations, new domain objects. Updates mermaid diagrams.
- Asks about product vision and workflow changes
- Never modifies `tracks.md` unless explicitly requested

---

### `/draft:new-track` — Create Feature Track

Creates a new track (feature, bug fix, or refactor) through **collaborative intake** — a structured conversation where AI acts as an expert collaborator, not just a questioner.

```bash
/draft:new-track "Add user authentication"
/draft:new-track "Fix login redirect bug"
```

**What it does:**
1. Creates `spec-draft.md` and `plan-draft.md` immediately (skeleton structure)
2. Conducts **collaborative intake** — structured questions asked one at a time:
   - **Problem Space:** What problem? Why now? Who's affected? Scope boundaries?
   - **Solution Space:** Simplest version? Why this approach? What's out of scope?
   - **Risk & Constraints:** What could go wrong? Dependencies? Assumptions?
   - **Success Criteria:** How do we know it's done? Verification strategy?
3. **AI actively contributes** at each step:
   - Pattern recognition from industry experience
   - Trade-off analysis with citations (DDD, Clean Architecture, OWASP, etc.)
   - Risk identification you may not see
   - Fact-checking against your `architecture.md` and `tech-stack.md`
4. Updates drafts progressively as conversation evolves
5. **Checkpoints between phases** — summarizes progress, asks to continue or refine
6. On confirmation: promotes `spec-draft.md` → `spec.md`, creates phased `plan.md`
7. Registers the track in `draft/tracks.md`

**Collaborative Intake Flow:**
```
/draft:new-track "description"
     │
     ├─> Creates spec-draft.md + plan-draft.md (skeleton)
     │
     ├─> Phase 1: Existing docs? (ingest if provided)
     │   └─> AI: Extracts context, identifies gaps
     │
     ├─> Phase 2: Problem Space (one question at a time)
     │   └─> AI: Pattern recognition, domain concepts, why probes
     │   └─> CHECKPOINT: "Does this capture the problem?"
     │
     ├─> Phase 3: Solution Space
     │   └─> AI: Alternatives with trade-offs, architecture fit
     │   └─> CHECKPOINT: "Ready to discuss risks?"
     │
     ├─> Phase 4: Risks & Constraints
     │   └─> AI: Surfaces risks, cites OWASP/failure patterns
     │   └─> CHECKPOINT: "Anything else that could derail this?"
     │
     ├─> Phase 5: Success Criteria
     │   └─> AI: Suggests measurable acceptance criteria
     │   └─> CHECKPOINT: "Ready to finalize?"
     │
     └─> Finalization: spec.md + plan.md created
```

**AI Guidance Sources:**
- Books: Domain-Driven Design, Clean Architecture, DDIA, Release It!, Building Microservices
- Standards: OWASP Top 10, 12-Factor App, SOLID
- Patterns: GoF, Enterprise Integration Patterns, Resilience patterns

**Output:**
```
draft/tracks/add-user-auth/
├── spec.md           # Requirements and acceptance criteria
├── plan.md           # Phased task breakdown
└── metadata.json     # Status and timestamps
```

**Why this matters:** Junior engineers get senior-level guidance. Senior engineers can't skip thinking "because obvious." Both produce consistent, well-documented specifications with traceable reasoning.

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

### `/draft:validate` — Validate Codebase Quality

Systematic validation using Draft context (architecture.md, product.md, tech-stack.md).

```bash
# Validate entire codebase
/draft:validate

# Validate specific track
/draft:validate --track <track-id>
```

**Project-Level Checks:**
- Architecture conformance (violations of architecture.md patterns)
- Dead code detection (unused exports, unreferenced code)
- Dependency cycle detection (circular imports)
- Security scan (hardcoded secrets, SQL injection, XSS, missing validation)
- Performance anti-patterns (N+1 queries, blocking I/O in async)

**Track-Level Checks** (in addition to project-level scoped to changed files):
- Spec compliance (acceptance criteria have corresponding tests)
- Architectural impact (new dependencies not in tech-stack.md, pattern violations)
- Regression risk (blast radius analysis, critical paths affected)

Generates report at `draft/validation-report.md` (project) or `draft/tracks/<id>/validation-report.md` (track). Auto-runs at track completion when enabled in workflow.md. Non-blocking by default (warnings only).

---

### `/draft:bughunt` — Exhaustive Bug Hunt

Systematic bug hunting across the entire codebase, enhanced by Draft context when available.

```bash
# Hunt bugs across entire repo
/draft:bughunt

# Hunt bugs for specific track
/draft:bughunt --track <track-id>
```

**What it does:**
1. Loads Draft context if available (`architecture.md`, `tech-stack.md`, `product.md`, `workflow.md`)
2. For track-level hunts, also loads `spec.md` and `plan.md` to verify implementation matches requirements
3. Analyzes code across 12 dimensions: correctness, reliability, security, performance, UI responsiveness, concurrency, state management, API contracts, accessibility, configuration, tests, maintainability
4. Generates severity-ranked findings (Critical/High/Medium/Low) with file locations and fix recommendations

**Scope options:**
- **Entire repo** — Full codebase analysis
- **Specific paths** — Target directories or files
- **Track-level** — Focus on files relevant to a specific track, verify spec compliance

**Draft context enhances the hunt:**
- `architecture.md` — Flags violations of intended module boundaries and patterns
- `tech-stack.md` — Applies framework-specific checks (React anti-patterns, Node gotchas, etc.)
- `product.md` — Catches bugs that violate product requirements or user flows
- `spec.md` / `plan.md` — Verifies implemented features match track requirements

**Output:** Generates report at `draft/bughunt-report.md` (project) or `draft/tracks/<id>/bughunt-report.md` (track). Unlike `/draft:validate` which checks compliance, `/draft:bughunt` discovers defects — correctness bugs, security vulnerabilities, performance issues, and reliability problems.

---

### `/draft:review` — Code Review Orchestrator

Standalone code review command that orchestrates reviewer agent, validate, and bughunt into a unified review workflow.

```bash
# Review active track (auto-detect)
/draft:review

# Review specific track by ID or name
/draft:review --track add-user-auth
/draft:review --track "user authentication"

# Comprehensive review (includes validate + bughunt)
/draft:review --track my-feature --full

# Review uncommitted changes
/draft:review --project

# Review specific files
/draft:review --files "src/**/*.ts"

# Review commit range
/draft:review --commits main...feature-branch
```

**Track-Level Review** (with spec.md and plan.md):
1. **Stage 1: Spec Compliance** — Verifies all requirements and acceptance criteria met
2. **Stage 2: Code Quality** — Checks architecture, error handling, testing, maintainability
3. **Optional**: Runs `/draft:validate` and `/draft:bughunt` with `--with-validate`, `--with-bughunt`, or `--full`
4. Generates unified report: `draft/tracks/<id>/review-report.md`

**Project-Level Review** (without track context):
1. **Code Quality Only** — Stage 2 checks (no spec to verify against)
2. Supports `--project` (uncommitted), `--files <pattern>`, `--commits <range>`
3. Generates report: `draft/review-report.md`

**Features:**
- Fuzzy track matching (ID or name)
- Smart diff chunking (<300 lines full, ≥300 lines file-by-file)
- Unified findings from multiple quality tools
- Critical/Important/Minor severity classification
- Updates metadata.json with review history

**When to use:**
- Before marking track complete
- Pre-PR review of track work
- Review external PRs or work done outside `/draft:implement`
- Quick quality check on uncommitted changes

---

### `/draft:adr` — Architecture Decision Records

Create and manage Architecture Decision Records to document significant technical decisions.

```bash
/draft:adr                          # Interactive — ask about the decision
/draft:adr "Use PostgreSQL"         # Create ADR with given title
/draft:adr list                     # List all existing ADRs
/draft:adr supersede 3              # Mark ADR-003 as superseded
```

**What it does:**
1. Loads project context (architecture.md, tech-stack.md) to cross-reference the decision
2. Determines next ADR number (zero-padded: 001, 002, ...)
3. Creates `draft/adrs/<number>-<kebab-title>.md` with structured template
4. Template includes: Context, Decision, Alternatives Considered, Consequences, References

**ADR Status Lifecycle:**
```
Proposed → Accepted → [Deprecated | Superseded by ADR-xxx]
```

**Output:**
```
draft/adrs/
├── 001-use-postgresql.md
├── 002-adopt-event-driven-architecture.md
└── 003-replace-rest-with-graphql.md
```

---

## Workflow

### Single Project

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
│        ├─── (optional) ─── /draft:bughunt → bug report           │
│        │                                                         │
│        ▼                                                         │
│   /draft:revert            Git-aware rollback if needed          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Monorepo (50+ Services)

```
┌──────────────────────────────────────────────────────────────────┐
│                    MONOREPO DRAFT WORKFLOW                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Per-Service (in each service directory):                       │
│   ─────────────────────────────────────────                      │
│   cd services/auth && /draft:init                                │
│   cd services/billing && /draft:init                             │
│   ... (initialize each service individually)                     │
│                                                                  │
│   Root-Level (from monorepo root):                               │
│   ────────────────────────────────                               │
│   /draft:init              Create root draft/ (minimal)         │
│        │                                                         │
│        ▼                                                         │
│   /draft:index             Aggregate all service contexts        │
│        │                   ├─ Synthesizes product.md             │
│        │                   ├─ Synthesizes architecture.md        │
│        │                   ├─ Generates service-index.md         │
│        │                   ├─ Generates dependency-graph.md      │
│        │                   └─ Generates tech-matrix.md           │
│        │                                                         │
│        ▼                                                         │
│   Global Knowledge         System-of-systems view available     │
│                            for cross-service planning            │
│                                                                  │
│   OR use --init-missing:                                         │
│   ──────────────────────                                         │
│   /draft:index --init-missing                                    │
│        │                   (prompts to init uninitialized        │
│        │                    services, then aggregates)           │
│        ▼                                                         │
│   Complete Index           All services initialized + indexed   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Key insight:** `/draft:init` analyzes source code (expensive). `/draft:index` synthesizes existing `draft/*.md` files (fast). Initialize services once, re-index as often as needed.

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

1. **Project context** — Tech lead runs `/draft:init`. Team reviews `product.md`, `tech-stack.md`, `architecture.md` (brownfield), and `workflow.md` via PR. Product managers review vision without reading code. Engineers review system architecture without exploring the codebase.
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

### Single Project

```
your-project/
├── draft/
│   ├── product.md              # Product vision and goals
│   ├── product-guidelines.md   # Style, branding, UX standards (optional)
│   ├── tech-stack.md           # Technical choices
│   ├── architecture.md         # System map + mermaid diagrams (brownfield)
│   ├── workflow.md             # TDD, commit, architecture mode preferences
│   ├── jira.md                 # Jira project configuration (optional)
│   ├── tracks.md               # Master track list
│   └── tracks/
│       └── <track-id>/
│           ├── spec.md         # Requirements
│           ├── plan.md         # Phased task breakdown
│           ├── metadata.json   # Status and timestamps
│           ├── architecture.md # Track-level module decomposition (optional)
│           ├── jira-export.md  # Jira stories for export (optional)
│           ├── validation-report.md # Quality validation results (generated)
│           └── bughunt-report.md # Bug hunt findings (generated)
```

### Monorepo (with /draft:index)

```
monorepo/
├── draft/                              # Root-level (aggregated)
│   ├── product.md                      # Synthesized org-wide vision
│   ├── architecture.md                 # System-of-systems topology
│   ├── tech-stack.md                   # Org standards
│   ├── workflow.md                     # Org conventions
│   ├── service-index.md                # GENERATED: service registry
│   ├── dependency-graph.md             # GENERATED: inter-service deps
│   ├── tech-matrix.md                  # GENERATED: tech distribution
│   ├── config.yaml                     # Index configuration
│   └── tracks/                         # Cross-service tracks
│
├── services/
│   ├── auth-service/
│   │   └── draft/                      # Service-local context
│   │       ├── product.md              # Service-scoped vision
│   │       ├── architecture.md         # Internal architecture
│   │       ├── tech-stack.md           # Service-specific tech
│   │       ├── manifest.json           # GENERATED: service metadata
│   │       └── tracks/                 # Service-specific tracks
│   │
│   ├── billing-service/
│   │   └── draft/                      # Service-local context
│   │       └── ...
│   │
│   └── api-gateway/                    # Not yet initialized
│       └── (no draft/)
```

**Key points:**
- Root `draft/` holds synthesized org-wide context
- Service `draft/` holds deep service-specific analysis
- GENERATED files are created by `/draft:index` and should not be edited
- Manual sections (between `<!-- MANUAL START -->` and `<!-- MANUAL END -->`) are preserved

## Example Walkthrough

A real-world example: adding user authentication to a task manager app.

### 1. Initialize

```bash
/draft:init
```

Draft detects your existing codebase (Express + TypeScript + PostgreSQL), generates `architecture.md` with module dependency diagrams, and creates `product.md`, `tech-stack.md`, `workflow.md`.

### 2. Create Track

```bash
/draft:new-track "Add user authentication with JWT"
```

Through collaborative intake, Draft generates:

**spec.md** (excerpt):
```markdown
## Requirements
### Functional
1. Users can register with email and password
2. Users can login and receive JWT access + refresh tokens
3. Protected routes require valid JWT
4. Tokens refresh automatically before expiry

## Acceptance Criteria
- [ ] POST /auth/register creates user with hashed password
- [ ] POST /auth/login returns { accessToken, refreshToken }
- [ ] GET /api/protected returns 401 without valid token
- [ ] POST /auth/refresh returns new access token
```

**plan.md** (excerpt):
```markdown
## Phase 1: User Model & Registration
- [ ] Task 1.1: Create User model with email, passwordHash fields
- [ ] Task 1.2: Add bcrypt password hashing utility
- [ ] Task 1.3: Implement POST /auth/register endpoint
- [ ] Task 1.4: Add input validation (email format, password strength)

## Phase 2: JWT Authentication
- [ ] Task 2.1: Implement JWT signing/verification service
- [ ] Task 2.2: Implement POST /auth/login endpoint
- [ ] Task 2.3: Create auth middleware for protected routes
- [ ] Task 2.4: Implement POST /auth/refresh endpoint
```

### 3. Implement

```bash
/draft:implement
```

Draft picks up Task 1.1, runs the TDD cycle (write test, implement, refactor), commits, and moves to the next task. At phase boundaries, it runs a two-stage review (spec compliance + code quality).

### 4. Document Decisions

```bash
/draft:adr "Use bcrypt over argon2 for password hashing"
```

Creates `draft/adrs/001-use-bcrypt-for-password-hashing.md` documenting the decision context, alternatives considered, and consequences.

### 5. Validate

```bash
/draft:validate --track add-user-auth
```

Runs architecture conformance, security scan (OWASP Top 10), spec compliance, and regression risk analysis. Generates a validation report.

## Specialized Agents

Draft includes five specialized agent behaviors that activate during specific workflow phases to ensure quality and consistency.

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

Integration files (`.cursorrules`, `copilot-instructions.md`, `GEMINI.md`) are auto-generated from skill files. Do not edit them directly.

### Plugin Structure

```
draft/
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
├── CLAUDE.md             # Context file (auto-loaded)
├── skills/               # Skill definitions (one per command)
│   ├── draft/SKILL.md
│   ├── init/SKILL.md
│   ├── index/SKILL.md        # Monorepo federation
│   ├── new-track/SKILL.md
│   ├── implement/SKILL.md
│   ├── status/SKILL.md
│   ├── revert/SKILL.md
│   ├── decompose/SKILL.md
│   ├── coverage/SKILL.md
│   ├── validate/SKILL.md
│   ├── bughunt/SKILL.md
│   ├── review/SKILL.md
│   ├── adr/SKILL.md
│   ├── jira-preview/SKILL.md
│   └── jira-create/SKILL.md
├── core/
│   ├── methodology.md       # Master methodology documentation
│   ├── templates/           # Templates for /draft:init
│   └── agents/              # Specialized agent behaviors
│       ├── architect.md
│       ├── debugger.md
│       ├── planner.md
│       ├── rca.md
│       └── reviewer.md
└── integrations/
    ├── cursor/
    │   └── .cursorrules     # GENERATED from skills
    ├── copilot/.github/
    │   └── copilot-instructions.md  # GENERATED from skills
    └── gemini/
        └── GEMINI.md        # GENERATED from skills
```

## Cursor Integration

Download directly into your project (no clone required):

```bash
curl -o .cursorrules https://raw.githubusercontent.com/mayurpise/draft/main/integrations/cursor/.cursorrules
```

Or copy from a local clone:

```bash
cp /path/to/draft/integrations/cursor/.cursorrules .cursorrules
```

Then use in Cursor:
```
@draft init
@draft new-track "Add user authentication"
@draft implement
```

See [integrations/cursor/README.md](integrations/cursor/README.md) for details.

## GitHub Copilot Integration

Download directly into your project (no clone required):

```bash
mkdir -p .github
curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/copilot/.github/copilot-instructions.md
```

Or copy from a local clone:

```bash
cp /path/to/draft/integrations/copilot/.github/copilot-instructions.md .github/
```

The instructions file works with GitHub Copilot Chat in VS Code, JetBrains, and Neovim. Commands use natural language (`draft init`, `draft new-track`) instead of `@` mentions.

## Gemini Integration

Download directly into your project (no clone required):

```bash
curl -o GEMINI.md https://raw.githubusercontent.com/mayurpise/draft/main/integrations/gemini/GEMINI.md
```

Or copy from a local clone:

```bash
cp /path/to/draft/integrations/gemini/GEMINI.md GEMINI.md
```

Place `GEMINI.md` at the root of your project. It works with Gemini Code Assist and Gemini CLI. Commands use `@draft` syntax.

## Credits

Adapted from [gemini-cli-extensions/conductor](https://github.com/gemini-cli-extensions/conductor).

## License

Apache 2.0
