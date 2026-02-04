# Plan: Update Project Documentation

**Track ID:** update-project-docs
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview
Full overhaul of methodology.md, README.md, and index.html to provide comprehensive, detailed project documentation. Follows source-of-truth hierarchy: methodology first, then README, then landing page.

---

## Phase 1: Methodology Overhaul
**Goal:** Make methodology.md the definitive, complete reference for all Draft features
**Verification:** All 10 commands documented; all 3 agents summarized; installation section present; no broken internal references

### Tasks
- [x] **Task 1.1:** Add Installation & Getting Started section to methodology.md
  - Prerequisites (Claude Code CLI, git)
  - Plugin installation command
  - Verification steps
  - Quick start flow
  - Files: `core/methodology.md`

- [x] **Task 1.2:** Expand Init workflow documentation
  - Brownfield vs greenfield detection details
  - Product guidelines (optional) step
  - Architecture mode opt-in step
  - Full file creation sequence
  - Files: `core/methodology.md`

- [x] **Task 1.3:** Expand New Track workflow documentation
  - Dialogue-driven spec creation process
  - Spec template with field explanations
  - Plan creation with phase structure
  - Metadata and tracks.md updates
  - Files: `core/methodology.md`

- [x] **Task 1.4:** Expand Implement workflow documentation
  - Full TDD cycle with red/green/refactor detail
  - Architecture mode steps (story, execution state, skeletons, chunk limits)
  - Verification gate process
  - Phase boundary two-stage review
  - Track completion flow
  - Error handling and debugging integration
  - Files: `core/methodology.md`

- [x] **Task 1.5:** Add Revert workflow documentation
  - Three revert levels (task, phase, track)
  - Preview before execution
  - Git revert mechanics
  - Draft state updates after revert
  - Conflict handling
  - Files: `core/methodology.md`

- [x] **Task 1.6:** Add Decompose workflow documentation
  - Scope determination (project vs track)
  - Codebase scanning patterns
  - Module identification rules
  - Dependency mapping and cycle-breaking
  - Plan merge logic
  - Files: `core/methodology.md`

- [x] **Task 1.7:** Add Coverage workflow documentation
  - Tool auto-detection
  - Scope determination
  - Report format
  - Gap analysis and classification
  - Recording results in plan.md and architecture.md
  - Files: `core/methodology.md`

- [x] **Task 1.8:** Add Agent summaries section
  - Debugger agent: 4-phase process, anti-patterns, escalation
  - Reviewer agent: two-stage review, issue classification, severity levels
  - Architect agent: module decomposition, story writing, execution state, skeletons
  - Files: `core/methodology.md`

---

## Phase 2: README Overhaul
**Goal:** Make README.md a comprehensive, scannable project guide with detailed installation, commands, and workflows
**Verification:** All sections from spec present; content derives from methodology.md; no contradictions

### Tasks
- [x] **Task 2.1:** Rewrite Installation section
  - Prerequisites
  - Claude Code plugin installation
  - Cursor integration installation
  - Verification steps
  - Files: `README.md`

- [x] **Task 2.2:** Expand Commands section with detailed descriptions and examples
  - All 10 commands with usage, arguments, and expected output
  - Files: `README.md`

- [x] **Task 2.3:** Add detailed Architecture Mode section
  - Full feature breakdown (decompose, stories, execution state, skeletons, chunk reviews, coverage)
  - When to use vs when it's overkill
  - Workflow diagram
  - Files: `README.md`

- [x] **Task 2.4:** Add Revert, Debugging, Review, and Coverage sections
  - Revert: levels, preview, execution
  - Debugging: 4-phase systematic process
  - Review: two-stage process at phase boundaries
  - Coverage: tool detection, gap analysis, targets
  - Files: `README.md`

- [x] **Task 2.5:** Add Troubleshooting and Contributing sections
  - Common issues and solutions
  - How to add new skills
  - How to update methodology
  - How to rebuild cursorrules
  - Files: `README.md`

---

## Phase 3: Landing Page Overhaul
**Goal:** Make index.html a comprehensive, visually polished landing page covering all Draft features
**Verification:** All sections from spec present; visual design system maintained; content consistent with methodology.md and README.md

### Tasks
- [x] **Task 3.1:** Add Installation / Getting Started section
  - Code block with installation commands
  - Quick start flow
  - Files: `index.html`

- [x] **Task 3.2:** Add Command Reference section
  - All 10 commands with icons and descriptions
  - Files: `index.html`

- [x] **Task 3.3:** Add Chat-Driven Development Problems section
  - Problem grid with icons (context window, hallucination, no memory, unsearchable, no visibility, repeated loading)
  - How Draft Solves It comparison table
  - Files: `index.html`

- [x] **Task 3.4:** Add Revert Workflow section
  - Visual representation of 3 revert levels
  - Preview → Confirm → Execute flow
  - Files: `index.html`

- [x] **Task 3.5:** Add Quality Disciplines section (Debugging + Review + Coverage)
  - Debugging: 4-phase visual flow
  - Review: two-stage visual
  - Coverage: report visualization
  - Files: `index.html`

- [x] **Task 3.6:** Expand When to Use section and add Constraint Mechanisms table
  - Expanded good fit / overkill examples
  - Table: mechanism → effect (from methodology)
  - Files: `index.html`

---

## Phase 4: Consistency Audit
**Goal:** Verify all three files are consistent and complete
**Verification:** Cross-reference check passes; no contradictions; all acceptance criteria met

### Tasks
- [x] **Task 4.1:** Cross-reference audit across all three files
  - Feature lists match
  - Command counts match
  - Terminology is consistent
  - No contradictions
  - Files: `core/methodology.md`, `README.md`, `index.html`

---

## Notes
- Phase 1 must complete before Phases 2 and 3 (source-of-truth hierarchy)
- Phases 2 and 3 can be done in parallel after Phase 1
- Phase 4 depends on all previous phases
- All changes are additive — no existing features removed
- index.html must preserve the existing CSS design system
