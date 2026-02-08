# Plan: Add /draft:review Command

**Track ID:** add-review-command
**Spec:** ./spec.md
**Status:** [~] In Progress

## Overview

Implement `/draft:review` as a new skill that orchestrates code review workflows. Supports both track-level review (against spec.md) and project-level review (code quality only). Integrates with existing reviewer agent, validate, and bughunt commands.

---

## Phase 1: Core Review Infrastructure
**Goal:** Basic track-level review working with reviewer agent integration
**Verification:** Can review a completed track and generate report

### Tasks

- [x] **Task 1.1:** Create skill file structure (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Create frontmatter with name and description
  - Add initial command structure with argument parsing

- [x] **Task 1.2:** Implement argument parser (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Parse `--track <id|name>`, `--project`, `--files`, `--commits` flags
  - Parse `--with-validate`, `--with-bughunt`, `--full` flags
  - Validate flag combinations (e.g., `--track` and `--project` are mutually exclusive)

- [x] **Task 1.3:** Implement track resolution logic (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Auto-detect active `[~]` track when no args provided
  - Exact directory match for track ID
  - Parse `draft/tracks.md` for fuzzy matching
  - Prompt user on ambiguous matches
  - Handle missing track errors with suggestions

- [x] **Task 1.4:** Load track context (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Read `draft/tracks/<id>/spec.md`
  - Read `draft/tracks/<id>/plan.md`
  - Extract commit SHAs from plan.md (search for git commit patterns)
  - Determine commit range (first commit parent → last commit)
  - Handle missing files gracefully

- [x] **Task 1.5:** Generate git diff with smart chunking (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Run `git diff --shortstat <range>` to determine size
  - If <300 lines: run full `git diff <range>`
  - If >300 lines: run `git diff --name-only <range>`, iterate files
  - Aggregate file-level diffs into memory structure

- [x] **Task 1.6:** Integrate reviewer agent for track-level review (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Reference `core/agents/reviewer.md` in prompt
  - Run Stage 1: Spec Compliance (check acceptance criteria from spec.md)
  - Run Stage 2: Code Quality (only if Stage 1 passes)
  - Classify findings as Critical/Important/Minor
  - Format findings with file:line references

- [x] **Task 1.7:** Generate track-level review report (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Create `draft/tracks/<id>/review-report.md`
  - Include header (track ID, review date, commit range, reviewer)
  - Include Stage 1 findings (spec compliance checklist)
  - Include Stage 2 findings (categorized by severity)
  - Include verdict (PASS / PASS WITH NOTES / FAIL)
  - Overwrite existing reports with timestamp update

---

## Phase 2: Project-Level Review
**Goal:** Review arbitrary code changes without track context
**Verification:** Can review uncommitted changes, specific files, and commit ranges

### Tasks

- [x] **Task 2.1:** Implement project-level scope detection (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Handle `--project` flag (uncommitted changes via `git diff HEAD`)
  - Handle `--files <pattern>` flag (specific file patterns)
  - Handle `--commits <range>` flag (e.g., `main...HEAD`)
  - Validate git ref ranges exist before processing
  - Depends on: Task 1.2

- [x] **Task 2.2:** Load project-level context (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Read `CLAUDE.md` for project instructions
  - Read `core/methodology.md` for quality standards
  - Read `core/agents/reviewer.md` for review criteria
  - Note: No spec.md or plan.md available at project-level
  - Depends on: Task 2.1

- [x] **Task 2.3:** Run code quality review (Stage 2 only) (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Skip Stage 1 (no spec to check against)
  - Run Stage 2: Code Quality checks (architecture, error handling, testing, maintainability)
  - Apply patterns from methodology and CLAUDE.md
  - Classify findings as Critical/Important/Minor
  - Depends on: Task 2.2

- [x] **Task 2.4:** Generate project-level review report (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Create `draft/review-report.md`
  - Include header (review date, scope description, commit range if applicable)
  - Include Stage 2 findings only
  - Include verdict and recommended actions
  - Depends on: Task 2.3

---

## Phase 3: Quality Tool Integration
**Goal:** Integrate `/draft:validate` and `/draft:bughunt` into unified review
**Verification:** `--full` flag runs all three tools and produces unified report

### Tasks

- [x] **Task 3.1:** Implement validate integration (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - When `--with-validate` or `--full` flag set, invoke validate skill
  - Track-level: call with `--track <id>`
  - Project-level: call with `--project`
  - Capture validate output and parse findings
  - Depends on: Task 1.7, Task 2.4

- [x] **Task 3.2:** Implement bughunt integration (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - When `--with-bughunt` or `--full` flag set, invoke bughunt skill
  - Track-level: call with `--track <id>`
  - Project-level: call with appropriate scope
  - Capture bughunt output and parse findings
  - Depends on: Task 3.1

- [x] **Task 3.3:** Create unified report format (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Merge findings from reviewer agent, validate, and bughunt
  - Organize by severity (Critical → High → Medium → Low → Minor)
  - Deduplicate findings across tools (same file:line issue)
  - Add summary section: total issues by tool and severity
  - Depends on: Task 3.2

- [x] **Task 3.4:** Add report metadata and tracking (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Add timestamp to report header
  - Track review history in `metadata.json` (lastReviewed, reviewCount)
  - Include git commit range reviewed
  - Include flags used (--full, --with-validate, etc.)
  - Depends on: Task 3.3

---

## Phase 4: Polish & Documentation
**Goal:** Complete documentation, integration testing, and edge case handling
**Verification:** All acceptance criteria met, README updated, integrated with build system

### Tasks

- [x] **Task 4.1:** Add comprehensive error handling (7a7dc85)
  - Files: `skills/review/SKILL.md`
  - Handle missing draft/ directory (project not initialized)
  - Handle no tracks exist
  - Handle invalid git commit ranges
  - Handle missing spec.md or plan.md gracefully
  - Handle git command failures
  - Provide actionable error messages
  - Depends on: Task 3.4

- [x] **Task 4.2:** Rebuild integrations (2f1f838)
  - Files: `integrations/cursor/.cursorrules`, `integrations/copilot/.github/copilot-instructions.md`, `integrations/gemini/GEMINI.md`
  - Run `./scripts/build-integrations.sh`
  - Verify review skill appears in all integrations
  - Test syntax validation passes
  - Depends on: Task 4.1

- [x] **Task 4.3:** Update documentation (8c2436e, fa8983a)
  - Files: `README.md`, `core/methodology.md`, `index.html`
  - Add `/draft:review` to command reference sections
  - Document all flags and options
  - Add usage examples (track-level, project-level, --full)
  - Update workflow diagrams to show review step
  - Add review to quality disciplines section
  - Depends on: Task 4.2

- [x] **Task 4.4:** Update CHANGELOG (fa8983a)
  - Files: `CHANGELOG.md`
  - Add `/draft:review` to [Unreleased] section
  - Document all features: track-level, project-level, quality tool integration
  - Document fuzzy track matching
  - Note comparison with Conductor's review command
  - Depends on: Task 4.3

- [ ] **Task 4.5:** Integration testing
  - Test: Manual testing across scenarios
  - Test auto-detect active track
  - Test exact track ID match
  - Test fuzzy track name matching
  - Test ambiguous match handling
  - Test `--project`, `--files`, `--commits` scopes
  - Test `--with-validate`, `--with-bughunt`, `--full` flags
  - Test small diff (<300 lines) and large diff (>300 lines)
  - Test error cases (missing files, invalid ranges, etc.)
  - Verify report format and content
  - Depends on: Task 4.4

---

## Notes

- **Reviewer agent reuse:** Leverage existing `core/agents/reviewer.md` - no changes needed
- **Report consistency:** Follow existing format from validate/bughunt for unified UX
- **Performance consideration:** Large diffs (>300 lines) use file-by-file iteration to avoid context overflow
- **Fuzzy matching algorithm:** Use substring matching first, fallback to Levenshtein distance for suggestions
- **Integration testing:** No automated tests yet - manual testing only (future: add to test suite)
- **Open question resolution:**
  - Default behavior: reviewer agent only (--full explicit for comprehensive)
  - Report overwrite: yes, with timestamp update
  - Incomplete tracks: warn but allow review
  - Status integration: yes, add to metadata.json
