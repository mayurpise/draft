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
   - Run full architecture discovery (all 5 phases)
   - Write output to `draft/.ai-context.md.new` (NOT the original file)
   - Detect new directories, files, or modules added since last scan
   - Identify removed or renamed components
   - Update critical invariants and safety rules
   - Flag new external dependencies or changed integration points
   - Update extension cookbooks with new patterns
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

---

## Step 1.5: Architecture Discovery (Brownfield Only)

For existing codebases, perform exhaustive analysis to generate:
- `draft/.ai-context.md` — Token-optimized, 200-400 lines, self-contained AI context
- `draft/architecture.md` — Human-readable, 30-45 page engineering reference

---

### Adaptive Sections

Not every codebase has every concept. Apply these rules:

| If the codebase... | Then... |
|---------------------|---------|
| Has no plugin / algorithm / handler system | Skip Framework & Extension Points catalog |
| Has no V1/V2 generational split | Skip V1 ↔ V2 Migration section |
| Has no RPC / proto / API definitions | Adapt API section to cover REST / GraphQL / OpenAPI |
| Is a library (no binary / process) | Adapt Process Lifecycle to "Usage Lifecycle" — how consumers integrate it |
| Is a frontend / UI module | Add: Component hierarchy, route map, state management, styling system |
| Uses a database directly | Add: schema definitions, migration system, ORM models |
| Is containerized / has infra config | Add: Dockerfile, Kubernetes manifests, Helm charts, CI/CD pipeline |
| Is a single-threaded / simple module | Simplify Concurrency section to note "single-threaded" |
| Has no configuration flags | Adapt Config section to cover whatever mechanism exists |

---

### Language-Specific Exploration Guide

| Language | Build/Deps | Entry Point | Interfaces | Config | Tests |
|----------|-----------|-------------|------------|--------|-------|
| C/C++ | `BUILD`, `CMakeLists.txt`, `Makefile` | `main()` in `*_main.cc` | `.h` headers, virtual methods | `DEFINE_*` macros | `*_test.cc` |
| Go | `go.mod`, `go.sum` | `func main()` in `main.go` or `cmd/*/main.go` | `type Interface interface` | `flag.*`, Viper, env vars | `*_test.go` |
| Python | `pyproject.toml`, `requirements.txt`, `setup.py` | `__main__`, `app.py`, `main.py` | ABC, Protocol classes | `settings.py`, `.env`, argparse | `test_*.py` |
| TypeScript | `package.json`, `tsconfig.json` | `"main"` in package.json, `index.ts` | `interface`/`type` in `*.ts` | `.env`, `config.ts` | `*.test.ts` |
| Java | `pom.xml`, `build.gradle` | `@SpringBootApplication`, `main()` | `interface` declarations | `application.yml` | `*Test.java` |
| Rust | `Cargo.toml` | `fn main()` in `src/main.rs` | `trait` definitions | `clap`, `config.toml` | `#[test]` |

---

### Phase 1: Discovery (Broad Scan)

1. **Map the directory tree**: Recursively list the project to understand file layout. Note subdirectory groupings.

2. **Read build / dependency files**: These reveal module structure, dependencies, and targets.

3. **Read API definition files**: `.proto`, OpenAPI specs, GraphQL schemas, route definitions. These define the module's data model and service interfaces.

4. **Read interface / type definition files**: Class declarations, interface definitions, type annotations reveal the public API and design intent.

### Phase 2: Wiring (Trace the Graph)

5. **Find the entry point**: Trace the initialization sequence from main/bootstrap.

6. **Follow the orchestrator**: From the top-level controller / app / server, trace how it creates, initializes, and wires all owned components.

7. **Find the registry / registration code**: Look for files that register handlers, plugins, routes, middleware, algorithms. This reveals the full implementation catalog.

8. **Map the dependency wiring**: Find the DI container, context struct, module system, or import graph that connects components. Document injection tokens / getter categories.

### Phase 3: Depth (Trace the Flows)

9. **Trace data flows end-to-end**: For each major flow, start at the data source / entry point and follow the code through processing stages to the output.

10. **Read implementation files**: For core modules, read the implementation to understand algorithms, error handling, retry logic, and state management.

11. **Identify concurrency model**: Find where thread pools, async executors, goroutines, or worker processes are created and what work is dispatched to each.

12. **Find safety checks**: Look for invariant assertions, validation logic, auth checks, version checks, lock acquisitions, and transaction boundaries.

### Phase 4: Periphery

13. **Catalog external dependencies**: Check build/dependency files and import statements to map all external library and service dependencies.

14. **Examine test infrastructure**: Read test files and test utilities to understand the testing approach, mock patterns, and test harness.

15. **Scan for configuration**: Find all configuration mechanisms (flags, env vars, config files, feature gates, constants).

16. **Look for documentation**: Check for existing README, docs/, ADRs, or inline comments that provide architectural context.

### Phase 5: Synthesis

17. **Cross-reference**: Ensure every component mentioned in one section appears in all relevant sections.

18. **Validate completeness**: Confirm ALL handlers / endpoints / plugins / schemas / dependencies are listed. Do not sample — enumerate exhaustively.

19. **Identify patterns**: Look for recurring design patterns and document them.

20. **Generate output**: Create `.ai-context.md` and derive `architecture.md` AFTER understanding the full picture.

---

## .ai-context.md Specification

Generate `draft/.ai-context.md` — a self-contained, token-optimized AI context file (200-400 lines).

### Crucial Rules

1. **Do NOT refer back to architecture.md** (e.g., "See Section 4.1"). Duplicate all critical facts.
2. **This file must stand alone** as the sole context source for an AI agent making code changes.
3. **Optimize for token efficiency** — use tables, bullet lists, compact notation instead of prose.
4. **Include everything for SAFE changes** — invariants, thread safety rules, error handling patterns.
5. **Include everything for CORRECT changes** — data flow knowledge, component relationships, interface contracts.

### Required Sections (all mandatory)

```markdown
# {PROJECT_NAME} Context Map

## Architecture
- **Type**: (e.g., gRPC Microservice, CLI tool, library, distributed daemon)
- **Language**: (e.g., Go 1.21, TypeScript 5.3, Python 3.12)
- **Pattern**: (e.g., Hexagonal, Master/Worker, Pipeline, Event-driven)
- **Build**: (exact build command)
- **Test**: (exact test command)
- **Entry**: (file → function/class)
- **Config**: (mechanism + location)
- **Generational**: (V1/V2 split if any, or "single generation")

## Component Graph
(ASCII tree showing full component hierarchy. Each node gets 5-10 word annotation.
Include sub-components 2-3 levels deep.)

## Dependency Injection / Wiring
(One paragraph or bullet list explaining how components find each other.
Name the DI mechanism: constructor injection, context struct, module imports, etc.
List the 5-10 most important injection tokens / getter names.)

## Critical Invariants (DO NOT BREAK)
(ALL invariants condensed to one line each.
Format: `- [Category] **Name**: one-sentence rule + where enforced`
Categories: Data, Security, Concurrency, Ordering, Compatibility, Idempotency
Aim for 8-15 invariants. MOST IMPORTANT section for agent safety.)

## Interface Contracts (TypeScript-like IDL)
(TypeScript-style interface declarations for ALL major extension points.
Include method signatures with param types and return types.
Mark optional methods with `?`. Add one-line comments for non-obvious methods.)

## Dependency Graph
(Arrow notation: `[ComponentA] -> (protocol) -> [ComponentB]`
Cover ALL external service dependencies and their protocols.)

## Key Data Sources
(Table or bullet list mapping each data source to which components read it.
Include: database tables, message queues, API endpoints, config files.)

## Data Flow Summary
(Prose description — NOT Mermaid — of each major data-flow path.
One paragraph per flow. Include: source → processing stages → output.
Cover: primary pipeline, variant flows, safety mechanisms.)

## Error Handling & Failure Recovery
(Bullet list of failure scenarios and their recovery mechanisms.
Include: failover, retries, backpressure, hung detection, graceful degradation.)

## Concurrency Safety Rules
(Bullet list of thread-safety rules specific to this codebase.
Format: `- **ComponentName**: rule + consequence of violation`
Include: which components are single-threaded, which locks protect what.)

## Implementation Catalog
(Complete list of ALL handlers / plugins / algorithms / endpoints / pipelines.
Use tables: ID/Name | Type/Class | Brief Description
Group by category. Include V1 AND V2 if both exist.)

## V1 ↔ V2 Migration Status
(Skip if no generational split. Table mapping V1 → V2 equivalents.
Include one-line rule: "When adding new X, prefer V1/V2 because Y.")

## Thread Pools / Execution Model
(Table: Pool Name | Thread Count | What Runs On It)

## Key Configuration
(Table of 10-20 most important config parameters.
Columns: Flag/Param | Default | Critical?
Mark "Critical" for flags that cause data loss or crashes if misconfigured.)

## Extension Points — Step-by-Step Cookbooks
(For EACH major extension point, a numbered recipe:
1. File to create (path + naming convention)
2. Interface to implement (required + optional methods)
3. Where to register (file + function + mechanism)
4. Build dependencies to add
5. Tests required
MOST IMPORTANT section for agent productivity.)

## Testing Strategy
- Unit: (exact command)
- Integration: (framework + location)
- Key test hooks: (injection points, completion notifiers, overrides)

## File Layout Quick Reference
(Bullet list mapping logical concepts to file paths.
Format: `- ConceptName: path/to/file.ext`
Cover: entry point, controller, registry, algorithms, config, tests, build.)

## Glossary (Critical Terms Only)
(Table of 10-20 domain terms that appear in code identifiers.
Columns: Term | Definition (one sentence)
Only include terms that would confuse an agent reading the code.)

## Draft Integration
(Cross-references to other Draft files:
- See `draft/tech-stack.md` for accepted patterns and technology decisions
- See `draft/workflow.md` for TDD preferences and guardrails
- See `draft/product.md` for product context and guidelines)
```

### What to EXCLUDE from .ai-context.md

- Mermaid diagrams (use prose or ASCII instead)
- Full code snippets (use TypeScript-like IDL instead)
- Detailed per-module deep dives
- Security architecture details (unless directly relevant to code changes)
- Observability/telemetry details (unless agents need to add logging/metrics)
- Reusable modules assessment (engineer-facing only)
- Performance characteristics (engineer-facing only)

### Quality Checklist

Before finalizing, verify:
- [ ] An agent can implement a new plugin/handler using ONLY this file
- [ ] An agent knows which thread pool to use for any new async work
- [ ] An agent knows what invariants to check before emitting side effects
- [ ] An agent knows the correct error handling pattern for this codebase
- [ ] An agent can find the right file to modify for any given task
- [ ] An agent knows what tests to write and how to run them
- [ ] No section says "See Section X" or "See architecture.md"
- [ ] Total length is 200-400 lines

**After completing analysis: Write this content to `draft/.ai-context.md` using the Write tool.**

---

## architecture.md Specification

Generate `draft/architecture.md` — a comprehensive human-readable engineering reference (30-45 pages).

### Report Structure — Follow This Section Ordering

#### 1. Executive Summary
- One paragraph: What the module IS, what it DOES, its role in the larger system
- Key Facts bullet list: language, entry point, architecture style, component count, data sources, action targets

#### 2. System Identity & Purpose
- What {PROJECT} Does — numbered list of core responsibilities
- Why {PROJECT} Exists — business/system problem it solves

#### 3. Architecture Overview
- High-Level Topology — Mermaid `flowchart TD` with nested subgraphs
- Process Lifecycle — numbered steps from startup to steady state

#### 4. Component Map & Interactions
- Top-Level Orchestrator — role, owned components table, initialization stages
- Dependency Injection Pattern — how components reference each other
- Interaction Matrix — table showing which components communicate

#### 5. Data Flow — End to End
- Separate Mermaid flowcharts for each major data-flow path
- Primary processing pipeline, variant flows, safety mechanisms
- Annotate arrows with data that moves between stages

#### 6. Core Modules Deep Dive
- For each major module (5-8): role, responsibilities, key operations table
- State machines (Mermaid `stateDiagram-v2`) where applicable
- Notable mechanisms: backpressure, retry, caching, rate limiting

#### 7. Concurrency Model & Thread Safety
- Execution model, thread pool map, affinity rules
- Locking strategy, async patterns, common pitfalls
- (For simple modules: "single-threaded — N/A")

#### 8. Framework & Extension Points
- Plugin/Handler types table
- Registry mechanism
- Core interface code blocks with actual signatures

#### 9. Full Catalog of Implementations
- Exhaustive enumeration of ALL handlers/plugins/algorithms
- Group by category, include V1 and V2 if both exist

#### 10. API & Interface Definitions
- RPC/REST/GraphQL endpoints table
- Key data models/messages/schemas table
- Reference to actual definition files

#### 11. External Dependencies
- Service dependencies table
- Infrastructure/utility libraries table

#### 12. Cross-Module Integration Points
- Contracts, failure isolation, version coupling
- Mermaid sequence diagrams for 2-3 important cross-module flows

#### 13. Critical Invariants & Safety Rules
- For each invariant (8-15): What, Why, Where Enforced, Common Violation Pattern
- Group by: Data safety, Security, Concurrency, Ordering, Idempotency, Backward-compatibility

#### 14. Security Architecture
- Authentication & initialization
- Authorization enforcement
- Data sanitization, secrets management, network security

#### 15. Observability & Telemetry
- Logging strategy, distributed tracing, metrics, health checks

#### 16. Error Handling & Failure Modes
- Error propagation model with code example
- Retry semantics table, common failure modes table
- Alerting/monitoring, graceful degradation

#### 17. State Management & Persistence
- State inventory table: state, storage, durability, recovery
- Persistence formats, recovery sequences, schema migration

#### 18. Key Design Patterns
- For each pattern (4-8): description, actual code snippet, where used

#### 19. Configuration & Tuning
- Key configuration parameters table (10-20 most important)
- Scheduling/periodic configuration
- Config-related code blocks

#### 20. Performance Characteristics & Hot Paths
- Hot paths with file references
- Scaling dimensions table, memory profile, I/O patterns

#### 21. How to Extend — Step-by-Step Cookbooks
- Numbered, file-by-file cookbook for each extension point
- Include minimal working example for each

#### 22. Build System & Development Workflow
- Build system, key targets table
- How to build, test, run locally
- Common build issues, code style conventions, CI/CD

#### 23. Testing Infrastructure
- Test framework, test patterns, test-to-feature mapping
- Test coverage expectations

#### 24. Known Technical Debt & Limitations
- Deprecated code, known workarounds, scaling limitations
- Complexity hotspots, design compromises, migration status

#### 25. Glossary
- Table of ALL domain-specific terms (15-30 terms)

#### Appendix A: File Structure Summary
- Full directory tree with inline annotations

#### Appendix B: Data Source → Implementation Mapping
- Table: Data Source | Implementations Reading It

#### Appendix C: Output Flow — Implementation to Target
- Table: Implementation | Output Type | Target API/System

#### Appendix D: Mermaid Sequence Diagrams — Critical Flows
- 2-3 sequence diagrams for complex cross-component flows

### Quality Requirements

- Every claim must be traceable to a specific source file
- Mermaid diagrams must be syntactically valid
- Code snippets must be actual code from the codebase
- Include ALL instances — do not sample or abbreviate
- When a section does not apply, state explicitly that it is skipped and why

**After generating: Derive this from `.ai-context.md` and write to `draft/architecture.md` using the Write tool.**

---

## Architecture Discovery Output (End of Step 1.5)

After completing the 5-phase analysis:

1. **Write `draft/.ai-context.md`**: Using the template from `core/templates/ai-context.md`, populate all 15+ sections based on your analysis. This is the primary output — token-optimized, self-contained.

2. **Derive `draft/architecture.md`**: Using the Derivation Subroutine below, expand `.ai-context.md` into the 30-45 page human-readable reference.

3. **Present for review**: Show the user a summary of what was discovered before proceeding to Step 2.

**CRITICAL**: Do NOT skip this step. Both files MUST be written before continuing.

---

## Derivation Subroutine: Generate architecture.md from .ai-context.md

This subroutine converts the dense `.ai-context.md` into human-readable `architecture.md`. Called by:
- **Init** — after initial generation
- **Implement** — after module status updates
- **Decompose** — after adding new modules

### Process

1. Read `draft/.ai-context.md`
2. Generate `draft/architecture.md` with these transformations:
   - **Expand tables into prose paragraphs** — Add context and explanation
   - **Add Mermaid diagrams** — Visual representations of component relationships
   - **Add "Getting Started" framing** — Orient human readers with onboarding context
   - **Add section introductions** — Brief paragraph before each section
   - **Include full code snippets** — Actual code examples with inline comments
   - **Add detailed per-module deep dives** — Full analysis of each core module
   - **Strip mutation-oriented fields** — Remove status markers
   - **Remove Draft Integration section** — Not needed for human consumption

3. End the document with:
   `"End of analysis. For AI-optimized context, see draft/.ai-context.md"`

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
"Draft initialized successfully with comprehensive analysis!

Created:
- draft/.ai-context.md (200-400 lines — token-optimized AI context, self-contained)
- draft/architecture.md (30-45 pages — human-readable engineering reference)
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review draft/.ai-context.md — verify the AI context is complete and accurate
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
