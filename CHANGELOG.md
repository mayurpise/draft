# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2026-02-08

### Added
- `/draft:index` — Monorepo federation and service aggregation:
  - **Service discovery:** Scans immediate child directories for service markers (package.json, go.mod, Cargo.toml, etc.) at depth=1 only
  - **Context aggregation:** Reads each service's draft/ context (product.md, architecture.md, tech-stack.md) and synthesizes root-level knowledge
  - **Dependency mapping:** Detects inter-service dependencies and generates topological ordering for implementation planning
  - **Auto-generated files:** Creates service-index.md (service registry), dependency-graph.md (mermaid topology), tech-matrix.md (technology distribution), root product.md/architecture.md/tech-stack.md (system-of-systems view)
  - **Monorepo templates:** 6 new templates (service-index, dependency-graph, tech-matrix, root-product, root-architecture, root-tech-stack) in core/templates/
  - **Uninitialized service handling:** `--init-missing` flag to bootstrap services without draft/ context
  - **Manifest tracking:** Creates draft/manifest.json per service with metadata (name, tech, dependencies, team, last indexed)
- `/draft:adr` — Architecture Decision Records for documenting significant technical decisions:
  - **ADR structure:** Context (forces driving decision) → Decision (active voice proposal) → Alternatives Considered (≥2 with pros/cons) → Consequences (positive/negative/risks)
  - **Lifecycle:** Proposed → Accepted → Deprecated/Superseded
  - **Storage:** `draft/adrs/NNNN-title.md` with track linkage in metadata
  - **Commands:** `draft adr list`, `draft adr supersede <number>`
  - **Integration:** Suggested during `/draft:new-track` when making architectural choices
- `/draft:review` — Standalone code review orchestrator supporting both track-level and project-level review:
  - **Track-level review:** Reviews specific track implementation against spec.md and plan.md using two-stage process (spec compliance → code quality)
  - **Project-level review:** Reviews arbitrary changes (uncommitted, specific files, commit ranges) with code quality checks only
  - **Fuzzy track matching:** Accepts both exact track ID and fuzzy name matching (e.g., `--track "user auth"` finds `add-user-authentication`)
  - **Smart diff chunking:** Handles small diffs (<300 lines) with full context, large diffs (≥300 lines) with file-by-file iteration to avoid context overflow
  - **Quality tool integration:** Optional integration with `/draft:validate` and `/draft:bughunt` via `--with-validate`, `--with-bughunt`, or `--full` flags
  - **Unified reporting:** Aggregates findings from reviewer agent, validate, and bughunt with deduplication and severity ranking (Critical/Important/Minor)
  - **Review history tracking:** Updates metadata.json with lastReviewed timestamp and reviewCount
  - Generates reports: `draft/tracks/<id>/review-report.md` (track) or `draft/review-report.md` (project)
- **Enterprise Readiness Enhancements:**
  - **Red Flags sections** added to all 15 skills — proactive warnings to prevent common mistakes (wrong directory, missing context, skipping verification)
  - **OWASP Top 10 security checks** integrated into `/draft:validate` — detects SQL injection, XSS, broken auth, insecure deserialization, insufficient logging
  - **Tech Debt Log** section added to `/draft:implement` — tracks shortcuts, TODOs, and deferred improvements per task
  - **Enterprise spec sections** — Security/Compliance, Performance Requirements, Operational Runbooks added to spec.md template
- **Methodology Improvements:**
  - **Table of Contents** added to core/methodology.md (1,070+ lines) — hierarchical navigation for 8 major sections and 14 commands
  - **Mermaid diagrams** — Workflow visualization (Context → Spec → Plan → Implement → Review) and context hierarchy (Product → Architecture → Tech Stack)
  - **Validation expanded examples** — Concrete categories (Architecture Conformance, Security Scan, Performance Analysis) with specific patterns to detect
  - **ISO timestamp flexibility** documented — both `Z` and `.000Z` suffixes valid (second vs millisecond precision)

### Changed
- `.gitignore` expanded to ignore generated reports (`draft/bughunt-report.md`, `draft/validation-report.md`, `draft/tracks/*/validation-report.md`)
- Integration files regenerated with all methodology updates (Cursor, Copilot, Gemini)

## [1.1.0] - 2026-02-07

### Added
- `/draft:bughunt` — Exhaustive bug hunting across 12 analysis dimensions (correctness, reliability, security, performance, UI responsiveness, concurrency, state management, API contracts, accessibility, configuration, tests, maintainability):
  - Project-level analysis: full codebase bug discovery
  - Track-level analysis (`--track <id>`): focused hunt using spec.md and plan.md to verify implementation matches requirements
  - Draft context integration: uses architecture.md for module boundary violations, tech-stack.md for framework-specific anti-patterns, product.md for product requirement bugs
  - Severity-ranked findings (Critical/High/Medium/Low) with file:line locations and fix recommendations
  - Generates reports: `draft/bughunt-report.md` (project), `draft/tracks/<id>/bughunt-report.md` (track)
  - Complements `/draft:validate` (compliance checking) with defect discovery
- `/draft:validate` — Systematic codebase quality validation using Draft context (architecture.md, product.md, tech-stack.md):
  - Project-level validation: architecture conformance, dead code detection, dependency cycles, security scan (OWASP basics), performance anti-patterns (N+1 queries, blocking I/O)
  - Track-level validation: spec compliance (acceptance criteria coverage), architectural impact (new dependencies, pattern violations), regression risk (blast radius analysis)
  - Auto-runs at track completion when enabled in workflow.md (non-blocking by default)
  - Generates reports: `draft/validation-report.md` (project), `draft/tracks/<id>/validation-report.md` (track)
  - Configurable scope and blocking behavior via workflow.md
  - Integrated with `/draft:implement` for automatic quality checks
- **Architecture Discovery for brownfield projects** — `/draft:init` now performs deep three-phase codebase analysis for existing projects:
  - Phase 1 (Orientation): Directory structure, entry points, critical paths, request/response flows, tech stack inventory with mermaid diagrams (`graph TD`, `sequenceDiagram`)
  - Phase 2 (Logic): Data lifecycle mapping, primary domain objects, design pattern recognition, anti-pattern/complexity hotspot flagging, convention extraction, external dependency mapping with mermaid diagrams (`flowchart LR`, `graph LR`)
  - Phase 3 (Module Discovery): Reverse-engineers existing modules from import graph and directory boundaries — responsibility, files, API surface, dependencies, complexity. Generates module dependency diagram (`graph LR`), dependency table, topological ordering. `/draft:decompose` extends (not replaces) these when planning new features.
  - Generates `draft/architecture.md` as persistent context — every future track references it instead of re-analyzing the codebase
- `/draft:init refresh` now includes architecture refresh — re-scans codebase, diffs against existing `architecture.md`, updates mermaid diagrams, detects new/merged modules, flags structural changes
- Mermaid component diagram section in `tech-stack.md` template
- Enhanced `architecture.md` template with Phase 1, Phase 2 & Phase 3 sections, 7 mermaid diagram types, module discovery with init vs decompose ownership model, and anti-pattern/hotspot tracking
- GitHub Copilot integration (`integrations/copilot/.github/copilot-instructions.md`) — generated from skills via build script
- Google Gemini integration (`integrations/gemini/GEMINI.md`) — generated from skills via build script, uses `@draft` syntax
- `/draft:init refresh` — Re-scan tech stack, update product vision, review workflow settings without touching tracks
- `/draft:decompose` — Module decomposition with dependency mapping, cycle detection, and implementation ordering
- `/draft:coverage` — Auto-detect coverage tooling, run reports, classify gaps (testable / defensive / infrastructure), target 95%+
- `/draft:jira-preview` — Generate `jira-export.md` from track plan with auto-calculated story points
- `/draft:jira-create` — Push epics, stories, and sub-tasks to Jira via MCP integration
- Architecture Mode — opt-in during `/draft:init` for granular pre-implementation design:
  - Algorithm stories (Input → Process → Output documentation)
  - Execution state design (intermediate variables defined before coding)
  - Function skeletons (stubs with full type signatures approved before TDD)
  - Chunk reviews (~200-line implementation limits with mandatory review)
- Architect agent (`core/agents/architect.md`) — module decomposition, story writing, skeleton generation
- Team Workflow documentation — commit → review → update → merge cycle on all markdown artifacts before code
- "Alignment Before Code" section across methodology, README, and landing page
- Landing page (`index.html`) — full visual landing page with:
  - Installation / Getting Started section
  - Command Reference (all 12 commands)
  - Chat-Driven Development Problems section (6 problem cards + comparison table)
  - Revert Workflow visualization (3 levels + Preview → Confirm → Execute)
  - Quality Disciplines section (debugging flow, review comparison, coverage cards)
  - Architecture Mode deep-dive with checkpoint explanations and decomposition process
  - Constraint Mechanisms table
  - Engineering rationale ("why it exists") for every workflow step

### Changed
- `/draft:implement` — Mandatory per-task commits with SHA tracking; revert skill updated to match
- `core/methodology.md` — Full overhaul: added Installation & Getting Started, expanded all 9 command workflows, added Agent summaries, added Team Workflow section, added Gemini integration section
- `README.md` — Full rewrite: detailed installation, all 12 commands with usage/examples/output, Architecture Mode section, Quality Disciplines, Troubleshooting FAQ, Contributing guide, Team Workflow section, Gemini integration section; direct raw GitHub URLs for Cursor and Copilot setup
- `index.html` — Expanded all workflow sections with Problem/Solution framing and engineering rationale; added Gemini and Copilot to Getting Started
- `scripts/build-integrations.sh` — Unified build script now generates Cursor, Copilot, and Gemini integrations
- Debugger agent and Reviewer agent documentation expanded in methodology
- `.cursorrules`, `copilot-instructions.md`, `GEMINI.md` regenerated from updated skill files

### Removed
- `install.sh` — Unused installation script removed
- Conductor attribution removed from landing page footer

## [1.0.0] - 2025-01-25

### Added
- `/draft:init` - Initialize project context with product, tech-stack, and workflow definitions
- `/draft:new-track` - Create feature/bug/refactor tracks with spec.md and plan.md
- `/draft:implement` - Execute tasks with optional TDD workflow (RED → GREEN → REFACTOR)
- `/draft:status` - Display comprehensive progress overview
- `/draft:revert` - Git-aware rollback of tasks, phases, or entire tracks
- Cursor IDE integration via `.cursorrules`
- Quality disciplines: verification before completion, systematic debugging, two-stage review
- Specialized agents: planner, debugger, reviewer
