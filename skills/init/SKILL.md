---
name: init
description: Initialize Draft project context for Context-Driven Development. Run once per project to create product.md, tech-stack.md, workflow.md, tracks.md, .ai-context.md (brownfield), and architecture.md (derived). Always performs deep analysis.
---

# Draft Init

You are initializing a Draft project for Context-Driven Development.

## Red Flags - STOP if you're:

- Re-initializing a project that already has `draft/` without using `refresh` mode
- Skipping brownfield analysis for an existing codebase
- Rushing through product definition questions without probing for detail
- Auto-generating tech-stack.md without verifying detected dependencies
- Not presenting .ai-context.md for developer review before proceeding
- Overwriting existing tracks.md (this destroys track history)

**Initialize once, refresh to update. Never overwrite without confirmation.**

---

## Pre-Check

Check for arguments:
- `refresh`: Update existing context without full re-init

### Standard Init Check

```bash
ls draft/ 2>/dev/null
```

If `draft/` exists with context files:
- Announce: "Project already initialized. Use `/draft:init refresh` to update context or `/draft:new-track` to create a feature."
- Stop here.

### Monorepo Detection

Check for monorepo indicators:
- Multiple `package.json` / `go.mod` / `Cargo.toml` in child directories
- `lerna.json`, `pnpm-workspace.yaml`, `nx.json`, or `turbo.json` at root
- `packages/`, `apps/`, `services/` directories with independent manifests

If monorepo detected:
- Announce: "Detected monorepo structure. Consider using `/draft:index` at root level to aggregate service context, or run `/draft:init` within individual service directories."
- Ask user to confirm: initialize here (single service) or abort (use /draft:index instead)

### Migration Detection

If `draft/architecture.md` exists WITHOUT `draft/.ai-context.md`:
- Announce: "Detected legacy architecture.md without .ai-context.md. Would you like to migrate? This will generate .ai-context.md as the new source of truth and regenerate architecture.md from it."
- If user accepts: Run refresh mode targeting `.ai-context.md` generation
- If user declines: Continue with legacy format

### Refresh Mode

If the user runs `/draft:init refresh`:

1. **Tech Stack Refresh**: Re-scan `package.json`, `go.mod`, etc. Compare with `draft/tech-stack.md`. Propose updates.

2. **Architecture Refresh**: If `draft/.ai-context.md` exists, re-run architecture discovery with safe backup workflow:

   **a. Create backup:**
   ```bash
   cp draft/.ai-context.md draft/.ai-context.md.backup
   ```

   **b. Generate to temporary file:**
   - Run full architecture discovery (all 6 phases)
   - Write output to `draft/.ai-context.md.new` (NOT the original file)
   - Detect new directories, files, or modules added since last scan
   - Identify removed or renamed components
   - Update mermaid diagrams to reflect structural changes
   - Flag new external dependencies or changed integration points
   - Update data lifecycle: new domain objects, changed state machines, new storage tiers, new transformation boundaries
   - Update critical paths: new async/event paths, changed consistency boundaries, updated failure recovery matrix
   - Discover new modules or detect removed/merged modules
   - Update YAML frontmatter `git.commit` and `git.message` to current HEAD
   - Preserve any modules added by `/draft:decompose` (planned modules) — only update `[x] Existing` modules

   **c. Present diff for review:**
   ```bash
   diff draft/.ai-context.md draft/.ai-context.md.new
   ```
   Show summary of changes to user.

   **d. On user approval:**
   ```bash
   mv draft/.ai-context.md.new draft/.ai-context.md
   rm draft/.ai-context.md.backup
   ```
   Then regenerate `draft/architecture.md` from `.ai-context.md` using the Derivation Subroutine below.

   **e. On user rejection:**
   ```bash
   rm draft/.ai-context.md.new
   ```
   Original .ai-context.md preserved unchanged.

   - If `draft/.ai-context.md` does NOT exist and the project is brownfield, offer to generate it now

3. **Product Refinement**: Ask if product vision/goals in `draft/product.md` need updates.
4. **Workflow Review**: Ask if `draft/workflow.md` settings (TDD, commits) need changing.
5. **Preserve**: Do NOT modify `draft/tracks.md` unless explicitly requested.

Stop here after refreshing. Continue to standard steps ONLY for fresh init.

## Step 1: Project Discovery

Analyze the current directory to classify the project:

**Brownfield (Existing)** indicators:
- Has `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.
- Has `src/`, `lib/`, or similar code directories
- Has git history with commits

**Greenfield (New)** indicators:
- Empty or near-empty directory
- Only has README or basic config

Respect `.gitignore` and `.claudeignore` when scanning.

If **Brownfield**: proceed to Step 1.5 (Architecture Discovery).
If **Greenfield**: skip to Step 2 (Product Definition).

## Step 1.5: Architecture Discovery (Brownfield Only)

For existing codebases, perform full deep analysis across all 6 phases. This generates `draft/.ai-context.md` as the source of truth and derives `draft/architecture.md` for human consumption.

Use the template from `core/templates/ai-context.md`.

### Language-Specific Exploration Guide

Use this guide to know WHERE to look based on detected language:

| Language | Build/Deps | Entry Point | Interfaces | Config | Tests |
|----------|-----------|-------------|------------|--------|-------|
| C/C++ | `BUILD`, `CMakeLists.txt`, `Makefile` | `main()` in `*_main.cc` | `.h` headers, virtual methods | `DEFINE_*` macros | `*_test.cc` |
| Go | `go.mod`, `go.sum` | `func main()` in `main.go` or `cmd/*/main.go` | `type Interface interface` | `flag.*`, Viper, env vars | `*_test.go` |
| Python | `pyproject.toml`, `requirements.txt`, `setup.py` | `__main__`, `app.py`, `main.py` | ABC, Protocol classes | `settings.py`, `.env`, argparse | `test_*.py` |
| TypeScript | `package.json`, `tsconfig.json` | `"main"` in package.json, `index.ts` | `interface`/`type` in `*.ts` | `.env`, `config.ts` | `*.test.ts` |
| Java | `pom.xml`, `build.gradle` | `@SpringBootApplication`, `main()` | `interface` declarations | `application.yml` | `*Test.java` |
| Rust | `Cargo.toml` | `fn main()` in `src/main.rs` | `trait` definitions | `clap`, `config.toml` | `#[test]` |

---

### Phase 1: Orientation (The System Map)

Analyze the codebase to produce the **Orientation** sections of `.ai-context.md`:

1. **System Overview**: Write a "Key Takeaway" paragraph summarizing the system's primary purpose and function. Generate a mermaid `graph TD` diagram showing the system's layered architecture (presentation, logic, data layers with actual component names).

2. **Directory Structure**: Scan top-level directories. For each, identify its single responsibility and key files. Generate a table mapping directory → responsibility → key files.

3. **Entry Points & Critical Paths**: Identify all entry points into the system:
   - Application startup (main/index files)
   - API routes or HTTP handlers
   - Background jobs, workers, or scheduled tasks
   - CLI commands
   - Event listeners or serverless handlers

4. **Request/Response Flow**: Trace one representative request through the full stack. Generate a mermaid `sequenceDiagram` showing the actual participants (use real file/class names from the codebase).

5. **Tech Stack Inventory**: Cross-reference detected dependencies with config files. Record language versions, framework versions, and the config file that defines each. This feeds into `draft/tech-stack.md`.

#### Phase 2: Logic (The "How" & "Why")

Examine specific files and functions to produce the **Logic** sections:

1. **Data Lifecycle**: Identify the 3-5 primary domain objects. For each:
   - **Domain Objects**: Map where it enters, is modified, persisted, and exits the system.
   - **State Machines**: Trace valid states and transitions. Look for enum fields, status columns, state pattern implementations, guard clauses that check current state before allowing operations. Each transition should have: trigger, invariant (what must be true), and enforcement location (`file:line`). Generate a mermaid `stateDiagram-v2`.
   - **Storage Topology**: Map where data lives at each tier (in-memory cache → primary DB → event log → archive). For each tier: technology, durability guarantee, TTL/eviction policy, recovery strategy. For single-DB apps, state "Single DB — no caching tier, no event log."
   - **Data Transformation Chain**: Trace how data shape changes across boundaries (API payload → DTO → domain model → persistence model → event payload). Mark lossy transformations where fields are dropped. Each boundary is a potential data corruption point. For simple apps with one shape throughout, state "Single shape — no transformation boundaries."

2. **Design Patterns**: Identify dominant patterns — Repository, Factory, Singleton, Middleware, Observer, Strategy, etc. Document where each is used and why.

3. **Anti-Patterns & Complexity Hotspots**: Flag god objects (500+ lines), circular dependencies, high cyclomatic complexity, deviations from dominant patterns. Mark unclear logic as "Unknown/Legacy Context Required".

4. **Conventions & Guardrails**: Extract error handling patterns, logging approach, naming conventions, validation patterns.

5. **External Dependencies**: Map external service integrations. Generate a mermaid `graph LR`.

6. **Critical Invariants**: Scan for assertions, validation logic, auth checks, version checks, lock acquisitions, transaction boundaries. Group by category:
   - Data safety (prevent data loss / corruption)
   - Security (auth, authz, input validation, secrets handling)
   - Concurrency (lock ordering, thread affinity)
   - Ordering / sequencing (must-happen-before relationships)
   - Idempotency (safe to retry?)
   - Backward compatibility (schema evolution, API versioning)

7. **Security Architecture**: Trace auth middleware, authz decorators, input validation boundaries, secrets loading, TLS config. Document:
   - Authentication & initialization
   - Authorization enforcement
   - Data sanitization boundaries
   - Secrets management
   - Network security

8. **Concurrency Model**: Find thread pools, async executors, goroutines, worker processes. Map lock/mutex usage. For single-threaded modules, state "Single-threaded — N/A". Document:
   - Execution model
   - Thread/worker pools
   - Async patterns
   - Locking strategy
   - Common pitfalls

9. **Error Handling**: Identify error propagation pattern (return codes, exceptions, Result monads). Find retry logic, map failure modes from catch/error handlers. Document:
   - Propagation model
   - Retry policy table
   - Failure modes table
   - Graceful degradation

10. **Observability**: Find logging framework, trace instrumentation, metrics definitions, health endpoints. Document:
    - Logging strategy
    - Distributed tracing
    - Metrics inventory
    - Health checks

#### Phase 3: Module Discovery (Existing Modules)

Analyze the codebase's import graph and directory boundaries to discover existing modules:

1. **Module Identification**: Identify logical modules from directory structure, namespace boundaries, and import clusters. Each module should have:
   - A clear single responsibility
   - A list of actual source files
   - Key exported functions, classes, or interfaces
   - Dependencies on other discovered modules
   - Complexity rating (Low / Medium / High)

2. **Module Dependency Diagram**: Generate a mermaid `graph LR` diagram.

3. **Dependency Table**: Map each module to what it depends on and what depends on it. Flag circular dependencies.

4. **Dependency Order**: Topological ordering from leaf modules to most dependent.

**Important distinctions:**
- Set **Story** to a brief summary of what each module currently does. Reference key files.
- Set **Status** to `[x] Existing`
- `/draft:decompose` may later add new planned modules alongside these.

#### Phase 4: Critical Path Tracing

Trace end-to-end read and write paths through the codebase with `file:line` references. **Data is the primary organizing principle** — the code exists to serve the data paths.

1. **Identify Critical Operations**: Ask the developer to name 2-3 critical operations. If not provided, infer from entry points.

2. **Synchronous Write Path Tracing**: For each write operation, trace from entry to persistence. At each step, document:
   - Location (`file:line`)
   - Consistency level (strong/eventual)
   - Failure mode (what happens if this step fails)
   - **Mark the commit point** — the step where data becomes durable. Everything before is retriable; failures after require reconciliation.

3. **Synchronous Read Path Tracing**: For each read operation, trace from entry through cache/DB to response. Document staleness guarantees and cache invalidation strategy per step.

4. **Asynchronous / Event Paths**: Identify queues, event buses, CDC streams, scheduled jobs, background workers. For each:
   - Trigger, source, channel (topic/queue), consumer
   - Ordering guarantee (FIFO, partition-key, unordered)
   - Delivery guarantee (at-most-once, at-least-once, exactly-once)
   - Dead letter handling
   - For apps with no async paths: "No async data paths — all operations are synchronous request/response."

5. **Consistency Boundaries**: Map where strong consistency ends and eventual consistency begins. For each boundary: strong side, eventual side, expected lag, reconciliation mechanism. For single-DB apps: "Single database — all reads and writes are strongly consistent."

6. **Failure & Recovery Matrix**: For each critical path, document what happens to in-flight data at each stage when failure occurs. Map: failure point → data state → impact → recovery mechanism → idempotency guarantee. For simple apps: "Single request-response cycle. Failure = transaction rollback. No partial states possible."

7. **Cross-Cutting Concerns**: Identify middleware, interceptors, or aspects that apply across multiple paths.

#### Phase 5: Schema & Contract Discovery

1. **Schema File Detection**: Scan for Protobuf (`*.proto`), OpenAPI (`openapi.yaml`), GraphQL (`*.graphql`), JSON Schema (`*.schema.json`), Database schemas (`prisma/schema.prisma`, `migrations/`, `*.sql`).

2. **Service Definitions**: Extract services and methods from schema files.

3. **Inter-Service Dependencies**: Map which services call which.

#### Phase 6: Test, Config & Extension Points

1. **Test File Mapping**: For each module, identify corresponding test files and test types.

2. **Config & Environment Discovery**: Map configuration files, environment variables, feature flags.

3. **Extension Cookbooks**: After module discovery, generate step-by-step guides for each identified extension point (adding endpoints, models, integrations, etc.). Each cookbook should be a numbered, file-by-file guide an AI agent can follow mechanically.

---

### Architecture Discovery Output

Write all completed phases to `draft/.ai-context.md`, populating the YAML frontmatter with current git state:

```bash
git branch --show-current
git rev-parse --short HEAD
git log -1 --format="%s"
```

Then derive `draft/architecture.md` using the **Derivation Subroutine** below.

Present both documents for developer review before proceeding to Step 2.

### Operational Constraints for Architecture Discovery

- **Bottom-Line First**: Start with the Key Takeaway summary
- **Code-to-Context Ratio**: Explain intent, not syntax
- **No Hallucinations**: If a dependency or business reason is unclear, flag it as "Unknown/Legacy Context Required"
- **Mermaid Diagrams**: Use actual component/file names from the codebase
- **Respect Boundaries**: Only analyze code in the repository
- **Progress Updates**: Announce progress: "Phase 1 complete... analyzing Phase 2..."

---

## Derivation Subroutine: Generate architecture.md from .ai-context.md

This subroutine converts the dense, machine-optimized `.ai-context.md` into a human-readable `architecture.md`. It is called by:
- **Init** — after initial generation
- **Implement** — after module status updates
- **Decompose** — after adding new modules

### Process

1. Read `draft/.ai-context.md`
2. Generate `draft/architecture.md` with the following transformations:
   - **Expand tables into prose paragraphs** — Add context and explanation
   - **Annotate mermaid diagrams** — Add descriptive labels, expand abbreviated nodes
   - **Add "Getting Started" framing** — Orient human readers with onboarding context
   - **Strip mutation-oriented fields** — Remove status markers (`[ ]`, `[~]`, `[x]`, `[!]`), story placeholders
   - **Remove YAML frontmatter** — Not needed for human consumption
   - **Omit Extension Cookbooks** — These are agent-only; humans read the source code
   - **Simplify module section** — Show module names, responsibilities, and dependencies without status/story fields
   - **Preserve all mermaid diagrams** — These are valuable for both audiences
   - **Add section introductions** — Brief paragraph before each section explaining what it covers

3. Use the template from `core/templates/architecture.md` as the structural guide for the human-readable output.

### Reference from Other Skills

Other skills that mutate `.ai-context.md` should trigger this subroutine with:
> "After updating `.ai-context.md`, regenerate `draft/architecture.md` using the Derivation Subroutine defined in `/draft:init`."

---

## Step 2: Product Definition

Create `draft/product.md` using the template from `core/templates/product.md`.

Engage in structured dialogue:

1. **Vision**: "What does this product do and why does it matter?"
2. **Users**: "Who uses this? What are their primary needs?"
3. **Core Features**: "What are the must-have (P0), should-have (P1), and nice-to-have (P2) features?"
4. **Success Criteria**: "How will you measure if this product is successful?"
5. **Constraints**: "What technical, business, or timeline constraints exist?"
6. **Non-Goals**: "What is explicitly out of scope?"

Present for approval, iterate if needed, then write to `draft/product.md`.

## Step 3: Tech Stack

For Brownfield projects, auto-detect from:
- `package.json` → Node.js/TypeScript
- `requirements.txt` / `pyproject.toml` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust

Create `draft/tech-stack.md` using the template from `core/templates/tech-stack.md`.

Present detected stack for verification before writing.

## Step 4: Workflow Configuration

Create `draft/workflow.md` using the template from `core/templates/workflow.md`.

Ask about:
- TDD preference (strict/flexible/none)
- Commit style and frequency
- Validation settings (auto-validate, blocking behavior)

**Note on Architecture Mode:**
Architecture features (Story, Execution State, Skeletons, Chunk Reviews) are automatically enabled when you run `/draft:decompose` on a track. No opt-in needed — the presence of `.ai-context.md` activates these features.

## Step 5: Initialize Tracks

Create empty `draft/tracks.md`:

```markdown
# Tracks

## Active
<!-- No active tracks -->

## Completed
<!-- No completed tracks -->

## Archived
<!-- No archived tracks -->
```

## Step 6: Create Directory Structure

```bash
mkdir -p draft/tracks
```

## Completion

For **Brownfield** projects, announce:
"Draft initialized successfully with deep analysis!

Created:
- draft/.ai-context.md (source of truth — dense codebase understanding for AI agents)
- draft/architecture.md (human-readable engineering guide, derived from .ai-context.md)
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review draft/.ai-context.md — verify the analysis matches your understanding
2. Review draft/architecture.md — human-friendly version for team onboarding
3. Review and edit the other generated files as needed
4. Run `/draft:new-track` to start planning a feature"

For **Greenfield** projects, announce:
"Draft initialized successfully!

Created:
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review and edit the generated files as needed
2. Run `/draft:new-track` to start planning a feature"
