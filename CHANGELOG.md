# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Architecture Discovery for brownfield projects** — `/draft:init` now performs deep two-phase codebase analysis for existing projects:
  - Phase 1 (Orientation): Directory structure, entry points, critical paths, request/response flows, tech stack inventory with mermaid diagrams (`graph TD`, `sequenceDiagram`)
  - Phase 2 (Logic): Data lifecycle mapping, primary domain objects, design pattern recognition, anti-pattern/complexity hotspot flagging, convention extraction, external dependency mapping with mermaid diagrams (`flowchart LR`, `graph LR`)
  - Generates `draft/architecture.md` as persistent context — every future track references it instead of re-analyzing the codebase
- `/draft:init refresh` now includes architecture refresh — re-scans codebase, diffs against existing `architecture.md`, updates mermaid diagrams, flags structural changes
- Mermaid component diagram section in `tech-stack.md` template
- Enhanced `architecture.md` template with Phase 1 & Phase 2 sections, 6 mermaid diagram types, and anti-pattern/hotspot tracking
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
  - Command Reference (all 10 commands)
  - Chat-Driven Development Problems section (6 problem cards + comparison table)
  - Revert Workflow visualization (3 levels + Preview → Confirm → Execute)
  - Quality Disciplines section (debugging flow, review comparison, coverage cards)
  - Architecture Mode deep-dive with checkpoint explanations and decomposition process
  - Constraint Mechanisms table
  - Engineering rationale ("why it exists") for every workflow step

### Changed
- `/draft:implement` — Mandatory per-task commits with SHA tracking; revert skill updated to match
- `core/methodology.md` — Full overhaul: added Installation & Getting Started, expanded all 9 command workflows, added Agent summaries, added Team Workflow section, added Gemini integration section
- `README.md` — Full rewrite: detailed installation, all 10 commands with usage/examples/output, Architecture Mode section, Quality Disciplines, Troubleshooting FAQ, Contributing guide, Team Workflow section, Gemini integration section; direct raw GitHub URLs for Cursor and Copilot setup
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
