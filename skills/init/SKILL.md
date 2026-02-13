---
name: init
description: Initialize Draft project context for Context-Driven Development. Run once per project to create product.md, tech-stack.md, workflow.md, tracks.md, and architecture.md (brownfield). Supports --depth flag (quick/standard/deep) for analysis intensity.
---

# Draft Init

You are initializing a Draft project for Context-Driven Development.

## Red Flags - STOP if you're:

- Re-initializing a project that already has `draft/` without using `refresh` mode
- Skipping brownfield analysis for an existing codebase
- Rushing through product definition questions without probing for detail
- Auto-generating tech-stack.md without verifying detected dependencies
- Not presenting architecture.md for developer review before proceeding
- Overwriting existing tracks.md (this destroys track history)

**Initialize once, refresh to update. Never overwrite without confirmation.**

---

## Pre-Check

Check for arguments:
- `--depth quick|standard|deep`: Set analysis depth (default: `standard`)
- `refresh`: Update existing context without full re-init
- `refresh --depth <level>`: Refresh with specific depth

### Analysis Depth Levels

| Depth | Time | Best For | Description |
|-------|------|----------|-------------|
| `quick` | ~2 min | Large monorepos, CI/CD, initial exploration | Directory scan, package detection, entry points. No deep analysis. |
| `standard` | ~5-10 min | Most projects | Full Phase 1-3 analysis. Module discovery, dependency graphs, mermaid diagrams. |
| `deep` | ~15-30 min | Critical projects, onboarding, unfamiliar codebases | Standard + read/write path tracing, schema analysis, test mapping, config discovery. |

#### Feature Matrix

| Feature | Quick | Standard | Deep |
|---------|:-----:|:--------:|:----:|
| Directory structure | ✓ | ✓ | ✓ |
| Tech stack detection | ✓ | ✓ | ✓ |
| Entry points | ✓ | ✓ | ✓ |
| System overview diagram | ✓ | ✓ | ✓ |
| Module discovery | — | ✓ | ✓ |
| Dependency graph | — | ✓ | ✓ |
| Design patterns | — | ✓ | ✓ |
| Anti-patterns/hotspots | — | ✓ | ✓ |
| Mermaid diagrams (full) | — | ✓ | ✓ |
| Proto/OpenAPI/GraphQL schemas | — | — | ✓ |
| Read/write path tracing | — | — | ✓ |
| Test file mapping | — | — | ✓ |
| Config/env discovery | — | — | ✓ |
| External service contracts | — | — | ✓ |

#### Auto-Suggest Depth

Based on codebase size, suggest appropriate depth:
- **<50 files**: Suggest `deep` — small enough for thorough analysis
- **50-500 files**: Suggest `standard` — balanced coverage
- **500+ files**: Suggest `quick` — avoid timeout, offer `standard` with warning

Present the suggestion but let the user override.

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

### Refresh Mode

If the user runs `/draft:init refresh` (optionally with `--depth`):

1. **Tech Stack Refresh**: Re-scan `package.json`, `go.mod`, etc. Compare with `draft/tech-stack.md`. Propose updates.

2. **Architecture Refresh**: If `draft/architecture.md` exists, re-run architecture discovery at the specified depth with safe backup workflow:

   **a. Create backup:**
   ```bash
   cp draft/architecture.md draft/architecture.md.backup
   ```

   **b. Generate to temporary file:**
   - Run architecture discovery at specified depth
   - Write output to `draft/architecture.md.new` (NOT the original file)
   - Detect new directories, files, or modules added since last scan
   - Identify removed or renamed components
   - Update mermaid diagrams to reflect structural changes
   - Flag new external dependencies or changed integration points
   - Update data lifecycle if new domain objects were introduced
   - Discover new modules or detect removed/merged modules; update Module Dependency Diagram, Dependency Table, Dependency Order
   - Preserve any modules added by `/draft:decompose` (planned modules) — only update `[x] Existing` modules

   **c. Present diff for review:**
   ```bash
   diff draft/architecture.md draft/architecture.md.new
   ```
   Show summary of changes to user.

   **d. On user approval:**
   ```bash
   mv draft/architecture.md.new draft/architecture.md
   rm draft/architecture.md.backup
   ```

   **e. On user rejection:**
   ```bash
   rm draft/architecture.md.new
   ```
   Original architecture.md preserved unchanged.

   - If `draft/architecture.md` does NOT exist and the project is brownfield, offer to generate it now

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

**Count files** to determine suggested depth:
```bash
find . -type f -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | wc -l
```

Announce: "Found ~X source files. Suggested depth: [quick|standard|deep]. Proceed with this depth? (or specify --depth)"

If **Brownfield**: proceed to Step 1.5 (Architecture Discovery).
If **Greenfield**: skip to Step 2 (Product Definition).

## Step 1.5: Architecture Discovery (Brownfield Only)

For existing codebases, analyze based on the selected depth level. This document becomes persistent context that every future track references.

Use the template from `core/templates/architecture.md`.

---

### Quick Depth

Minimal analysis for large codebases or initial exploration.

#### Phase 1 Only: Orientation (Surface Scan)

1. **System Overview**: Write a "Key Takeaway" paragraph. Generate a basic mermaid `graph TD` showing primary layers.

2. **Directory Structure**: Scan top-level directories only. Generate:
   - A table mapping directory → responsibility → key files
   - Skip deep directory tree diagram

3. **Entry Points**: Identify main entry points:
   - Application startup (main/index files)
   - API routes or HTTP handlers
   - Skip detailed flow tracing

4. **Tech Stack Inventory**: Cross-reference detected dependencies with config files.

**Skip**: Module discovery, dependency graphs, design patterns, anti-patterns, read/write paths.

**Output**: Minimal `draft/architecture.md` with System Overview, Directory Structure, Entry Points, Tech Stack.

---

### Standard Depth (Default)

Full structural analysis — current behavior.

#### Phase 1: Orientation (The System Map)

Analyze the codebase to produce the **Orientation** sections of `architecture.md`:

1. **System Overview**: Write a "Key Takeaway" paragraph summarizing the system's primary purpose and function. Generate a mermaid `graph TD` diagram showing the system's layered architecture (presentation, logic, data layers with actual component names).

2. **Directory Structure**: Scan top-level directories. For each, identify its single responsibility and key files. Generate:
   - A table mapping directory → responsibility → key files
   - A mermaid `graph TD` tree diagram of the directory hierarchy

3. **Entry Points & Critical Paths**: Identify all entry points into the system:
   - Application startup (main/index files)
   - API routes or HTTP handlers
   - Background jobs, workers, or scheduled tasks
   - CLI commands
   - Event listeners or serverless handlers

4. **Request/Response Flow**: Trace one representative request through the full stack. Generate a mermaid `sequenceDiagram` showing the actual participants (not generic placeholders — use real file/class names from the codebase).

5. **Tech Stack Inventory**: Cross-reference detected dependencies with config files. Record language versions, framework versions, and the config file that defines each. This feeds into the more detailed `draft/tech-stack.md`.

#### Phase 2: Logic (The "How" & "Why")

Examine specific files and functions to produce the **Logic** sections of `architecture.md`:

1. **Data Lifecycle**: Identify the 3-5 primary domain objects (e.g., User, Order, Transaction). For each, map:
   - Where it enters the system (creation point)
   - Where it is modified (transformation points)
   - Where it is persisted (storage)
   - Generate a mermaid `flowchart LR` showing the data pipeline

2. **Design Patterns**: Identify dominant patterns in the codebase:
   - Repository, Factory, Singleton, Middleware, Observer, Strategy, etc.
   - Document where each pattern is used and why

3. **Anti-Patterns & Complexity Hotspots**: Flag problem areas:
   - God objects or functions (500+ lines)
   - Circular dependencies between modules
   - High cyclomatic complexity
   - Code deviating from dominant patterns
   - Mark unclear business logic as "Unknown/Legacy Context Required" — never guess

4. **Conventions & Guardrails**: Extract existing conventions:
   - Error handling patterns
   - Logging approach
   - Naming conventions (files, functions, classes)
   - Validation patterns
   - New code must respect these

5. **External Dependencies**: Map external service integrations. Generate a mermaid `graph LR` showing the application's connections to auth providers, email services, storage, queues, third-party APIs, etc.

#### Phase 3: Module Discovery (Existing Modules)

Analyze the codebase's import graph and directory boundaries to discover and document the **existing** module structure. This is reverse-engineering what already exists — not planning new modules (that's what `/draft:decompose` does for new features).

1. **Module Identification**: Identify logical modules from directory structure, namespace boundaries, and import clusters. Each module should have:
   - A clear single responsibility derived from the code it contains
   - A list of actual source files (not planned files)
   - Key exported functions, classes, or interfaces (the detected API surface)
   - Dependencies on other discovered modules (from import/require analysis)
   - Complexity rating (Low / Medium / High) based on file count, cyclomatic complexity, and coupling

2. **Module Dependency Diagram**: Generate a mermaid `graph LR` diagram showing how discovered modules depend on each other. Use actual module/directory names from the codebase.

3. **Dependency Table**: Create a table mapping each module to what it depends on and what depends on it. Flag any circular dependencies detected.

4. **Dependency Order**: Produce a topological ordering of existing modules — from leaf modules (no dependencies) to the most dependent. This helps engineers understand which parts of the system are foundational vs. which are built on top.

**Important distinctions:**
- For each module, set **Story** to a brief summary of what the module currently does (not a placeholder). Reference key files, e.g.: "Handles user authentication via JWT — see `src/auth/index.ts:1-45`"
- Set **Status** to `[x] Existing` — these modules already exist in the codebase
- `/draft:decompose` may later add **new** planned modules alongside these existing ones when planning a feature or refactor. Existing modules discovered here should not be removed or overwritten by decompose — they serve as the baseline.

---

### Deep Depth

Full analysis plus read/write paths, schemas, tests, and config.

**Includes all of Standard Depth, plus:**

#### Phase 4: Critical Path Tracing

Trace end-to-end read and write paths through the codebase with `file:line` references.

1. **Identify Critical Operations**: Ask the developer to name 2-3 critical operations (e.g., "user registration", "order checkout", "payment processing"). If not provided, infer from entry points.

2. **Write Path Tracing**: For each write operation, trace the full path:
   ```markdown
   ### Write Path: [Operation Name]
   1. Entry: `routes/users.ts:42` — POST /users handler
   2. Middleware: `middleware/auth.ts:15` — authentication check
   3. Validation: `middleware/validate.ts:28` — request schema validation
   4. Service: `services/user.ts:88` — business logic, password hashing
   5. Repository: `repos/user.ts:23` — database insert
   6. Events: `events/user.ts:12` — emit UserCreated event
   7. Response: `serializers/user.ts:5` — format response
   ```

3. **Read Path Tracing**: For each read operation, trace the full path:
   ```markdown
   ### Read Path: [Operation Name]
   1. Entry: `routes/users.ts:67` — GET /users/:id handler
   2. Middleware: `middleware/auth.ts:15` — authentication
   3. Service: `services/user.ts:45` — permission check
   4. Cache: `cache/user.ts:8` — check cache, return if hit
   5. Repository: `repos/user.ts:12` — database query
   6. Cache: `cache/user.ts:15` — populate cache
   7. Response: `serializers/user.ts:5` — format response
   ```

4. **Cross-Cutting Concerns**: Identify middleware, interceptors, or aspects that apply to multiple paths (logging, error handling, metrics, tracing).

#### Phase 5: Schema & Contract Discovery

Analyze API schemas and service contracts.

1. **Schema File Detection**: Scan for:
   - Protobuf: `*.proto` files
   - OpenAPI: `openapi.yaml`, `swagger.json`, `*.openapi.yaml`
   - GraphQL: `*.graphql`, `schema.graphql`
   - JSON Schema: `*.schema.json`
   - Database schemas: `prisma/schema.prisma`, `migrations/`, `*.sql`

2. **Service Definitions**: Extract from proto/schema files:
   ```markdown
   ### API Schemas & Contracts

   | Type | Location | Services/Endpoints |
   |------|----------|-------------------|
   | Protobuf | `proto/user.proto` | UserService: Create, Get, Update, Delete |
   | OpenAPI | `openapi.yaml` | REST: /users, /orders, /products |
   | GraphQL | `schema.graphql` | Query: user, orders; Mutation: createUser |
   ```

3. **Inter-Service Dependencies**: For microservices, map which services call which:
   ```markdown
   ### Service Dependencies
   - `OrderService` → `UserService` (get user details)
   - `OrderService` → `PaymentService` (process payment)
   - `NotificationService` → `UserService`, `OrderService` (get notification targets)
   ```

4. **Contract Validation**: Note if contracts have validation (e.g., protobuf compilation, OpenAPI validation, GraphQL type checking).

#### Phase 6: Test & Config Mapping

Map test coverage and configuration structure.

1. **Test File Mapping**: For each module discovered in Phase 3, identify corresponding test files:
   ```markdown
   ### Test Coverage Map

   | Module | Test Files | Test Type |
   |--------|-----------|-----------|
   | `src/auth/` | `tests/auth/*.test.ts` | Unit + Integration |
   | `src/orders/` | `tests/orders/*.test.ts`, `e2e/orders.spec.ts` | Unit + E2E |
   | `src/utils/` | — | No tests |
   ```

2. **Config & Environment Discovery**:
   ```markdown
   ### Configuration

   | File | Purpose | Environment Variables |
   |------|---------|----------------------|
   | `.env.example` | Environment template | DATABASE_URL, API_KEY, ... |
   | `config/default.ts` | Default config | — |
   | `config/production.ts` | Production overrides | — |

   ### Feature Flags
   - `ENABLE_NEW_CHECKOUT` — gates new checkout flow
   - `BETA_FEATURES` — enables beta feature set
   ```

3. **Secrets & Sensitive Config**: Identify where secrets are expected (but NOT their values):
   - Environment variables for API keys, database credentials
   - Secret managers referenced (AWS Secrets Manager, Vault, etc.)

---

### Architecture Discovery Output

Write all completed phases to `draft/architecture.md`.

Present the architecture document for developer review before proceeding to Step 2.

### Operational Constraints for Architecture Discovery

- **Bottom-Line First**: Start with the Key Takeaway summary
- **Code-to-Context Ratio**: Explain intent, not syntax
- **No Hallucinations**: If a dependency or business reason is unclear, flag it as "Unknown/Legacy Context Required"
- **Mermaid Diagrams**: Use actual component/file names from the codebase, not generic placeholders
- **Respect Boundaries**: Only analyze code in the repository; do not make assumptions about external services
- **Progress Updates**: For standard/deep depth, announce progress: "Phase 1 complete... analyzing Phase 2..."

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
Architecture features (Story, Execution State, Skeletons, Chunk Reviews) are automatically enabled when you run `/draft:decompose` on a track. No opt-in needed - the presence of `architecture.md` activates these features.

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

For **Brownfield** projects with **deep** depth, announce:
"Draft initialized successfully with deep analysis!

Created:
- draft/architecture.md (system map, read/write paths, schemas, test mapping)
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review draft/architecture.md — verify paths and schemas match your understanding
2. Review and edit the other generated files as needed
3. Run `/draft:new-track` to start planning a feature"

For **Brownfield** projects with **standard** depth, announce:
"Draft initialized successfully!

Created:
- draft/architecture.md (system map with mermaid diagrams)
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review draft/architecture.md — verify the system map matches your understanding
2. Run `/draft:init refresh --depth deep` later for read/write path tracing
3. Run `/draft:new-track` to start planning a feature"

For **Brownfield** projects with **quick** depth, announce:
"Draft initialized successfully (quick scan)!

Created:
- draft/architecture.md (basic structure only)
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Run `/draft:init refresh --depth standard` for full module discovery
2. Run `/draft:new-track` to start planning a feature"

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
