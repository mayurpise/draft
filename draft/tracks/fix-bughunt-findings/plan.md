# Plan: Fix Bug Hunt Findings

**Track ID:** fix-bughunt-findings
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview

Fix 4 actionable bug hunt findings. Single phase — isolated documentation and config edits.

---

## Phase 1: Address Bug Hunt Findings

**Goal:** Fix all 4 findings, rebuild integrations
**Verification:** All bughunt report items resolved; integrations regenerated

### Tasks

- [x] **Task 1.1:** Update CLAUDE.md command list (High #1) (b46592e)
  - Files: `CLAUDE.md` (line 7)
  - Updated from 7 hardcoded commands to all 13

- [x] **Task 1.2:** Add missing command sections to methodology.md (High #2) (b46592e)
  - Files: `core/methodology.md`
  - Added sections for: `/draft:validate`, `/draft:bughunt`, `/draft:review`
  - Intent mapping table already had entries (no update needed)

- [x] **Task 1.3:** Fix missing rel attribute (Medium #3) (b46592e)
  - Files: `index.html` (line 2874)
  - Added `rel="noopener noreferrer"` to buymeacoffee link

- [x] **Task 1.4:** Document skill body format requirement (Medium #4) (b46592e)
  - Files: `CLAUDE.md` (Skill File Format section)
  - Documented 3-line preamble requirement and build script dependency

- [x] **Task 1.5:** Rebuild integrations (0551948)
  - Command: `./scripts/build-integrations.sh`
  - Verified: 13/13 skills, all syntax checks pass

---

## Notes

- Finding #5 (index.html /draft:index card) intentionally excluded — uncommitted feature
- methodology.md is source of truth; changes there flow to integrations via build script
