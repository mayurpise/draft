---
name: decompose
description: Decompose project or track into modules with dependency mapping. Updates architecture.md (source of truth) and derives .ai-context.md (token-optimized, derived from architecture.md) with module definitions, dependency diagram, and implementation order.
---

# Decompose

You are decomposing a project or track into modules with clear responsibilities, dependencies, and implementation order.

## Red Flags - STOP if you're:

- Defining modules without understanding the codebase
- Creating modules with circular dependencies
- Making modules too large (>5 files, excluding test files) or too small (single function)
- Skipping dependency analysis
- Not waiting for developer approval at checkpoints

---

## Standard File Metadata

**ALL generated files MUST include the standard YAML frontmatter.** This enables refresh tracking, sync verification, and traceability.

### Gathering Git Information

Before generating any file, run these commands to gather metadata:

```bash
# Project name (from manifest or directory)
basename "$(pwd)"

# Git branch
git branch --show-current

# Git remote tracking branch
git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "none"

# Git commit SHA (full)
git rev-parse HEAD

# Git commit SHA (short)
git rev-parse --short HEAD

# Git commit date
git log -1 --format="%ci"

# Git commit message (first line)
git log -1 --format="%s"

# Check for uncommitted changes
git status --porcelain | head -1
```

### Metadata Template

Insert this YAML frontmatter block at the **top of every generated file**:

```yaml
---
project: "{PROJECT_NAME}"
module: "{MODULE_NAME or 'root'}"
track_id: "{TRACK_ID or null}"
generated_by: "draft:decompose"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  remote: "{REMOTE/BRANCH or 'none'}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
  commit_message: "{FIRST_LINE_OF_COMMIT_MESSAGE}"
  dirty: {true|false}
synced_to_commit: "{FULL_SHA}"
---
```

> **Note**: `generated_by` uses `draft:command` format (not `/draft:command`) for cross-platform compatibility.

---

## Step 1: Determine Scope

Check for an argument:
- `project` or no argument with no active track → **Project-wide** decomposition → `draft/.ai-context.md`
- Track ID or active track exists → **Track-scoped** decomposition → `draft/tracks/<id>/architecture.md`

## Step 2: Load Context

1. Read `draft/product.md` for product understanding
2. Read `draft/tech-stack.md` for technical patterns
3. If track-scoped:
   - Read track's `spec.md` for requirements
   - Read track's `plan.md` for existing task breakdown

For brownfield projects, scan the existing codebase using these concrete steps:

### Codebase Scanning Patterns

**Directory structure** — Map top-level organization:
```bash
ls -d src/*/ lib/*/ app/*/ packages/*/ 2>/dev/null
```

**Entry points** — Find main files and exports:
- Look for: `index.ts`, `main.ts`, `app.ts`, `mod.rs`, `__init__.py`, `main.go`
- Check `package.json` `main`/`exports` fields, `pyproject.toml` entry points, `go.mod` module path

**Existing module boundaries** — Identify by:
- Directory-per-feature patterns (e.g., `src/auth/`, `src/users/`)
- Package files (`package.json` in subdirs, `__init__.py`, `go` package declarations)
- Barrel exports (`index.ts` re-exporting from a directory)

**Dependency patterns** — Trace imports:
- Search for `import` / `require` / `from` statements across source files
- Identify which directories import from which other directories
- Flag cross-cutting imports (e.g., `utils/` imported everywhere)

**File type filters by language:**
| Language | Source Extensions | Config Files |
|----------|-------------------|--------------|
| TypeScript/JS | `*.ts`, `*.tsx`, `*.js`, `*.jsx` | `tsconfig.json`, `package.json` |
| Python | `*.py` | `pyproject.toml`, `setup.py`, `requirements.txt` |
| Go | `*.go` | `go.mod`, `go.sum` |
| Rust | `*.rs` | `Cargo.toml` |

**What to ignore:** `node_modules/`, `__pycache__/`, `target/`, `dist/`, `build/`, `.git/`, vendored dependencies. Always respect `.gitignore` and `.claudeignore`.

## Step 3: Module Identification

Propose a module breakdown through dialogue:

For each module, define:
- **Name** - Short, descriptive identifier
- **Responsibility** - One sentence: what this module owns
- **Files** - Expected source files (existing or to be created)
- **API Surface** - Public functions, classes, or interfaces
- **Dependencies** - Which other modules it imports from
- **Complexity** - Low / Medium / High

### Module Guidelines (see `core/agents/architect.md`)

- Each module should have a single responsibility
- Target 1-3 files per module
- Every module needs a clear API boundary
- Modules should be testable in isolation
- Each module typically contains: API, control flow, execution state, functions

### CHECKPOINT (MANDATORY)

**STOP.** Present the module breakdown to the developer.

```
═══════════════════════════════════════════════════════════
                   MODULE BREAKDOWN
═══════════════════════════════════════════════════════════

Scope: [Project / Track: <track-id>]

MODULE 1: [name]
  Responsibility: [one sentence]
  Files: [file list]
  API: [public interface summary]
  Dependencies: [none / module names]
  Complexity: [Low/Medium/High]

MODULE 2: [name]
  ...

═══════════════════════════════════════════════════════════
```

**Wait for developer approval.** Developer may add, remove, rename, or reorganize modules.

## Step 4: Dependency Mapping

After modules are approved:

1. **Map dependencies** - For each module, list what it imports from other modules
2. **Detect cycles** - If circular dependencies exist, propose how to break them (extract shared interface into new module)
3. **Generate ASCII diagram** - Visual representation of dependency graph
4. **Generate dependency table** - Tabular format for reference
5. **Determine implementation order** - Topological sort (implement leaves first, then dependents)

### CHECKPOINT (MANDATORY)

**STOP.** Present the dependency diagram and implementation order.

```
═══════════════════════════════════════════════════════════
                 DEPENDENCY ANALYSIS
═══════════════════════════════════════════════════════════

DIAGRAM
─────────────────────────────────────────────────────────
[auth] ──> [database]
   │            │
   └──> [config] <──┘
            │
      [logging] (no deps)

TABLE
─────────────────────────────────────────────────────────
Module     | Depends On        | Depended By
---------- | ----------------- | -----------------
logging    | -                 | auth, database, config
config     | logging           | auth, database
database   | config, logging   | auth
auth       | database, config  | -

IMPLEMENTATION ORDER
─────────────────────────────────────────────────────────
1. logging (leaf - no dependencies)
2. config (depends on: logging)
3. database (depends on: config, logging)
4. auth (depends on: database, config)

Parallel opportunities: config and database can start after logging.
═══════════════════════════════════════════════════════════
```

**Wait for developer approval.**

## Step 5: Generate Architecture Context

Write the architecture document using the template from `core/templates/ai-context.md` (project-wide) or `core/templates/architecture.md` (track-scoped):

**Location:**
- Project-wide: Update `draft/architecture.md` with the module changes, then run the Condensation Subroutine (defined in `/draft:init`) to regenerate `draft/.ai-context.md`
- Track-scoped: `draft/tracks/<id>/architecture.md`

**Contents:**
- Overview section (what the system/feature does, inputs, outputs, constraints)
- Module definitions with all fields from Step 3
- Dependency diagram from Step 4
- Dependency table from Step 4
- Implementation order from Step 4
- Story placeholder per module (see `core/agents/architect.md` Story Lifecycle for how this gets populated during `/draft:implement`)
- Status marker per module (`[ ] Not Started`)
- Notes section for architecture decisions

## Step 6: Update Plan (Track-Scoped Only)

If this is a track-scoped decomposition and a `plan.md` exists:

1. Review existing phases against the module implementation order
2. Propose restructuring phases to align with module boundaries
3. Each module becomes a phase or maps to existing phases

### Plan Merge Rules

When restructuring plan.md around modules, follow these rules for existing tasks:

**Completed tasks `[x]`:** Preserve exactly as-is. Map them to the appropriate module phase. Do not rename, reorder, or modify. Add a note: `(preserved from original plan)`.

**In-progress tasks `[~]`:** Map to the appropriate module phase. Flag for developer review if the task spans multiple modules:
```markdown
- [~] **Task 2.1:** Original task description
  - ⚠ REVIEW: This task may need splitting across modules [auth] and [database]
```

**Pending tasks `[ ]`:** Remap freely to module phases. Split tasks that span module boundaries into per-module tasks. Preserve the original task description in the new task.

**Blocked tasks `[!]`:** Preserve the blocked status and reason. Map to appropriate module. If the blocker is in a different module, add a cross-module dependency note.

**Conflict handling:** If a task doesn't map cleanly to any module:
1. List it under a `### Unmapped Tasks` section at the end
2. Flag it for developer decision
3. Never silently drop tasks

### CHECKPOINT (MANDATORY)

**STOP.** Present the updated plan structure.

```
PROPOSED PLAN RESTRUCTURE
─────────────────────────────────────────────────────────
Phase 1: [Module A] (Foundation)
  - Task 1.1: [existing or new task]
  - Task 1.2: ...

Phase 2: [Module B] (depends on Module A)
  - Task 2.1: ...
  ...
```

**Wait for developer approval before writing changes to plan.md.**

## Completion

Announce:
```
Architecture decomposition complete.

Created: [path to architecture.md]
Modules: [count]
Implementation order: [module names in order]

Next steps:
- Review architecture.md and edit as needed
- Run /draft:implement to start building (stories, execution state,
  and skeleton checkpoints will activate automatically)
- After implementation is complete, run `/draft:coverage` to verify test quality
```

## Mutation Protocol for .ai-context.md (Project-Wide)

> If `draft/.ai-context.md` already exists (e.g., from `/draft:init`), use the Mutation Protocol below to append new modules. Only use the template for fresh creation when no `.ai-context.md` exists.

When adding new modules to project-wide `.ai-context.md`:

1. Append `### Module: <name>` block after existing modules in `## Modules`
2. Set Status to `[ ] Not Started`
3. Update `## Dependency Table`, `## Dependency Order`, `## Module Dependency Diagram`
4. Do NOT remove/modify `[x] Existing` modules
5. Update YAML frontmatter `git.commit` and `git.message` to current HEAD
6. After updating `draft/architecture.md` with the module changes, run the Condensation Subroutine (defined in `/draft:init`) to regenerate `draft/.ai-context.md`

**Safe write pattern:**
1. Backup `.ai-context.md` → `.ai-context.md.backup`
2. Write changes to `.ai-context.md.new`
3. Present diff for review
4. On approval: replace `.ai-context.md` with `.ai-context.md.new`, then delete `.ai-context.md.backup`
5. On rejection: delete `.ai-context.md.new` and rename `.ai-context.md.backup` back to `.ai-context.md`

## Updating architecture context

When revisiting decomposition (running `/draft:decompose` on an existing `.ai-context.md` or `architecture.md`):
1. Read the existing context file
2. Ask developer what changed (new modules, removed modules, restructured boundaries)
3. Follow the same checkpoint process for changes
4. Update the document, preserving completed module statuses and stories
