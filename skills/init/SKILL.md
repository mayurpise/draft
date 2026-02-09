---
name: init
description: Initialize Draft project context for Context-Driven Development. Run once per project to create product.md, tech-stack.md, workflow.md, tracks.md, and architecture.md (brownfield). Includes deep codebase analysis with mermaid diagrams for existing projects.
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
- If argument is `refresh`: Proceed to **Refresh Mode**.
- If no argument: Check if already initialized.

### Standard Init Check
```bash
ls draft/ 2>/dev/null
```

If `draft/` exists with context files:
- Announce: "Project already initialized. Use `/draft:init refresh` to update context or `/draft:new-track` to create a feature."
- Stop here.

### Refresh Mode
If the user runs `/draft:init refresh`:
1. **Tech Stack Refresh**: Re-scan `package.json`, `go.mod`, etc. Compare with `draft/tech-stack.md`. Propose updates.
2. **Architecture Refresh**: If `draft/architecture.md` exists, re-run architecture discovery (Phase 1, 2 & 3 from Step 1.5) with safe backup workflow:

   **a. Create backup:**
   ```bash
   cp draft/architecture.md draft/architecture.md.backup
   ```

   **b. Generate to temporary file:**
   - Run architecture discovery (Phase 1, 2 & 3 from Step 1.5)
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

   - If `draft/architecture.md` does NOT exist and the project is brownfield, offer to generate it now using Step 1.5

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

For existing codebases, perform a two-phase deep analysis to generate `draft/architecture.md`. This document becomes the persistent context that every future track references — pay the analysis cost once, benefit on every track.

Use the template from `core/templates/architecture.md`.

### Phase 1: Orientation (The System Map)

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

### Phase 2: Logic (The "How" & "Why")

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

### Phase 3: Module Discovery (Existing Modules)

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

### Architecture Discovery Output

Write all Phase 1, Phase 2, and Phase 3 sections to `draft/architecture.md`.

Present the architecture document for developer review before proceeding to Step 2.

### Operational Constraints for Architecture Discovery
- **Bottom-Line First**: Start with the Key Takeaway summary
- **Code-to-Context Ratio**: Explain intent, not syntax
- **No Hallucinations**: If a dependency or business reason is unclear, flag it as "Unknown/Legacy Context Required"
- **Mermaid Diagrams**: Use actual component/file names from the codebase, not generic placeholders
- **Respect Boundaries**: Only analyze code in the repository; do not make assumptions about external services

## Step 2: Product Definition

Create `draft/product.md` through dialogue:

1. Ask about the product's purpose and target users
2. Ask about key features and goals
3. Ask about constraints or requirements

Template:
```markdown
# Product: [Name]

## Vision
[One paragraph describing what this product does and why it matters]

## Target Users
- [User type 1]: [Their needs]
- [User type 2]: [Their needs]

## Core Features
1. [Feature 1]
2. [Feature 2]
3. [Feature 3]

## Success Criteria
- [Measurable goal 1]
- [Measurable goal 2]

## Constraints
- [Technical/business constraint]
```

Present for approval, iterate if needed, then write to `draft/product.md`.

## Step 3: Product Guidelines (Optional)

Ask if they want to define product guidelines. If yes, create `draft/product-guidelines.md`:

```markdown
# Product Guidelines

## Writing Style
- Tone: [professional/casual/technical]
- Voice: [first person/third person]

## Visual Identity
- Primary colors: [if applicable]
- Typography preferences: [if applicable]

## UX Principles
- [Principle 1]
- [Principle 2]
```

## Step 4: Tech Stack

For Brownfield projects, auto-detect from:
- `package.json` → Node.js/TypeScript
- `requirements.txt` / `pyproject.toml` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust

Create `draft/tech-stack.md`:

```markdown
# Tech Stack

## Languages
- Primary: [Language] [Version]
- Secondary: [if applicable]

## Frameworks
- [Framework 1]: [Purpose]
- [Framework 2]: [Purpose]

## Database
- [Database]: [Purpose]

## Testing
- Unit: [Framework]
- Integration: [Framework]
- E2E: [Framework if applicable]

## Build & Deploy
- Build: [Tool]
- CI/CD: [Platform]
- Deploy: [Target]

## Code Patterns
- Architecture: [e.g., Clean Architecture, MVC]
- State Management: [if applicable]
- Error Handling: [pattern]
```

## Step 5: Workflow Configuration

Create `draft/workflow.md` based on team preferences:

```markdown
# Development Workflow

## Test-Driven Development
- [ ] Write failing test first
- [ ] Implement minimum code to pass
- [ ] Refactor with passing tests

## Commit Strategy
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Commit after each completed task

## Code Review
- Self-review before marking complete
- Run linter and tests before commit

## Phase Verification
- Manual verification required at phase boundaries
- Document verification steps in plan.md
```

Ask about their TDD preference (strict/flexible/none) and commit style.

**Note on Architecture Mode:**
Architecture features (Story, Execution State, Skeletons, Chunk Reviews) are automatically enabled when you run `/draft:decompose` on a track. No opt-in needed - the presence of `architecture.md` activates these features.

## Step 6: Initialize Tracks

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

## Step 7: Create Directory Structure

```bash
mkdir -p draft/tracks
```

## Completion

For **Brownfield** projects, announce:
"Draft initialized successfully!

Created:
- draft/architecture.md (system map with mermaid diagrams)
- draft/product.md
- draft/tech-stack.md
- draft/workflow.md
- draft/tracks.md

Next steps:
1. Review draft/architecture.md — verify the system map matches your understanding
2. Review and edit the other generated files as needed
3. Run `/draft:new-track` to start planning a feature"

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
