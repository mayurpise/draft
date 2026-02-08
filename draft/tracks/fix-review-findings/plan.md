# Plan: Fix Review Command Findings

**Track ID:** fix-review-findings
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview

Address 4 actionable findings from the add-review-command review report. Two Important (SKILL.md clarity fixes) and two Minor (icon, changelog). Important #3 (README format) was a false finding — all commands use the same flat heading format.

---

## Phase 1: SKILL.md and Documentation Fixes
**Goal:** Resolve all 4 findings and rebuild integrations
**Verification:** All acceptance criteria met, integrations regenerated

### Tasks

- [x] **Task 1.1:** Add explicit SHA extraction pattern to SKILL.md (8ab38eb)
  - Files: `skills/review/SKILL.md`
  - In Step 2.2 (Read plan.md), replace vague "Extract commit SHAs" with explicit pattern guidance
  - Pattern: "Match 7+ character hex strings in parentheses after task markers, e.g., `(7a7dc85)`"
  - Also note format: `- [x] **Task N.N:** Description (SHA)`

- [x] **Task 1.2:** Add graceful flag conflict handling to SKILL.md (ca86a7c)
  - Files: `skills/review/SKILL.md`
  - In Step 1 Validation Rules, add instruction: "If both `--full` and `--with-validate`/`--with-bughunt` are provided, treat as `--full` and ignore the redundant flags"

- [x] **Task 1.3:** Change review icon in index.html (18b5f53)
  - Files: `index.html`
  - Change `/draft:review` icon from `👁️` to a distinct icon (e.g., `🔍` or `📋`)
  - Depends on: None

- [x] **Task 1.4:** Clean up changelog competitive comparison (45187ee)
  - Files: `CHANGELOG.md`
  - Remove or rephrase the "Comparison with Conductor" bullet point
  - Depends on: None

- [x] **Task 1.5:** Rebuild integrations (18da048)
  - Command: `./scripts/build-integrations.sh`
  - Verify review skill changes propagated to all 3 integration files
  - Depends on: Task 1.1, Task 1.2

- [x] **Task 1.6:** Update spec.md acceptance criteria
  - Files: `draft/tracks/fix-review-findings/spec.md`
  - Remove the README `<details>` criterion (false finding)
  - Mark all completed criteria

---

## Notes

- Important #3 (README expandable cards) was a false finding — no commands use `<details>/<summary>`, all use flat `### heading` format. Dropped from scope.
- Single phase since all changes are independent, small, and can be verified together.
- Integration rebuild only needed for SKILL.md changes (Tasks 1.1 and 1.2).
