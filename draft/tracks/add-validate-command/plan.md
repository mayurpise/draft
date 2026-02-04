# Plan: Add Validate Command

**Track ID:** add-validate-command
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview
Implement `/draft:validate` command for systematic codebase validation using Draft context. Provides project-level and track-level validation with configurable automatic execution.

---

## Phase 1: Core Skill Infrastructure [COMPLETE]
**Goal:** Create skill file structure and command parsing
**Verification:** ✓ Skill file exists with complete structure, argument parsing, and context loading

### Tasks
- [x] **Task 1.1:** Create skill file structure (a1743af)
  - Files: `skills/validate/SKILL.md`
  - Test: Manual invocation via `/draft:validate`
  - Details: Create frontmatter with name/description, basic command structure

- [x] **Task 1.2:** Implement argument parsing (a1743af)
  - Files: `skills/validate/SKILL.md`
  - Test: `/draft:validate` and `/draft:validate --track <id>` both parse correctly
  - Details: Detect whole-codebase vs track-specific mode, validate track ID exists

- [x] **Task 1.3:** Load Draft context (a1743af)
  - Files: `skills/validate/SKILL.md`
  - Test: Verify reads architecture.md, tech-stack.md, product.md, workflow.md
  - Details: Pre-check for Draft initialization, load validation configuration from workflow.md

---

## Phase 2: Project-Level Validators [COMPLETE]
**Goal:** Implement all 5 project-level validation checks
**Verification:** ✓ All 5 validators implemented with detection logic

### Tasks
- [x] **Task 2.1:** Architecture conformance validator (8fac591)
  - Files: `skills/validate/SKILL.md`
  - Test: Detect pattern violations against architecture.md examples
  - Details: Parse architecture.md for documented patterns, use AST/grep to verify conformance

- [x] **Task 2.2:** Dead code detector (1270b53)
  - Files: `skills/validate/SKILL.md`
  - Test: Identify unused exports in sample codebase
  - Details: Track exports vs imports, flag unreferenced functions/classes

- [x] **Task 2.3:** Dependency cycle detector (d39467d)
  - Files: `skills/validate/SKILL.md`
  - Test: Detect circular imports in test scenario
  - Details: Build dependency graph from imports, run cycle detection algorithm

- [x] **Task 2.4:** Security scanner (d931b83)
  - Files: `skills/validate/SKILL.md`
  - Test: Flag hardcoded secrets, SQL injection patterns
  - Details: Pattern matching for common vulnerabilities (secrets, injection, missing validation)

- [x] **Task 2.5:** Performance anti-pattern detector (9a2baab)
  - Files: `skills/validate/SKILL.md`
  - Test: Detect N+1 queries, blocking I/O in async code
  - Details: Pattern match for loops with DB calls, sync ops in async contexts

---

## Phase 3: Track-Level Validators [COMPLETE]
**Goal:** Implement track-specific validation (spec compliance, architectural impact, regression risk)
**Verification:** ✓ All 3 track-level validators implemented

### Tasks
- [x] **Task 3.1:** Spec compliance validator (0711a1b)
  - Files: `skills/validate/SKILL.md`
  - Test: Verify acceptance criteria have corresponding tests
  - Details: Parse spec.md acceptance criteria, check for test file coverage

- [x] **Task 3.2:** Architectural impact analyzer (1ced7cb)
  - Files: `skills/validate/SKILL.md`
  - Test: Detect new dependencies not in tech-stack.md
  - Details: Git diff analysis, cross-reference with architecture.md patterns and tech-stack.md

- [x] **Task 3.3:** Regression risk analyzer (0a069dc)
  - Files: `skills/validate/SKILL.md`
  - Test: Compute blast radius of track changes
  - Details: Analyze changed files, compute affected module count via dependency graph

---

## Phase 4: Report Generation & Integration [COMPLETE]
**Goal:** Generate validation reports and integrate with `/draft:implement`
**Verification:** ✓ Report generation complete, integration hook added, workflow.md template updated

### Tasks
- [x] **Task 4.1:** Implement report generation (4d2066b)
  - Files: `skills/validate/SKILL.md`
  - Test: Verify report format (✓/⚠/✗ grouped by category)
  - Details: Generate `draft/validation-report.md` (project) and `draft/tracks/<id>/validation-report.md` (track)

- [x] **Task 4.2:** Integrate with /draft:implement (aeb7706)
  - Files: `skills/implement/SKILL.md`
  - Test: Validation auto-runs at track completion when enabled
  - Details: Add validation hook at track completion, read workflow.md config

- [x] **Task 4.3:** Implement warn-only behavior (0f89c5b)
  - Files: `skills/validate/SKILL.md`
  - Test: Validation failures produce warnings, don't block progress
  - Details: Document issues in report, continue execution, respect blocking config option

- [x] **Task 4.4:** Add workflow.md configuration (bbd724b)
  - Files: `core/templates/workflow.md`
  - Test: New projects have validation config section
  - Details: Add validation section to workflow template with all config options

---

## Phase 5: Integration Build & Documentation [COMPLETE]
**Goal:** Rebuild integrations and update documentation
**Verification:** ✓ All integrations rebuilt, README and CLAUDE.md updated with validate command

### Tasks
- [x] **Task 5.1:** Rebuild integrations (1f20c9e)
  - Files: `integrations/cursor/.cursorrules`, `integrations/copilot/.github/copilot-instructions.md`, `integrations/gemini/GEMINI.md`
  - Test: Run `./scripts/build-integrations.sh`, verify validate command appears
  - Details: Generate all integration files from skills

- [x] **Task 5.2:** Update README.md (89650b2)
  - Files: `README.md`
  - Test: README documents /draft:validate command and usage
  - Details: Add validate command to command reference, usage examples

- [x] **Task 5.3:** Update CLAUDE.md (1a5a574)
  - Files: `CLAUDE.md`
  - Test: CLAUDE.md reflects new validation workflow
  - Details: Document validate in workflow integration section

---

## Notes
- Validation leverages existing Draft context (architecture.md, tech-stack.md) for intelligent checks
- Complements `/draft:coverage` (quantitative test metrics) with qualitative validation (architectural/security)
- Non-blocking by default to maintain development velocity while surfacing issues
- Track-level validation scopes checks to changed files for faster feedback
