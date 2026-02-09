# Plan: Polish Review Skill

**Track ID:** review-skill-polish
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview

Address all 16 review findings from add-review-command review report. Single phase — all changes are isolated edits to `skills/review/SKILL.md` and `index.html`, followed by integration rebuild.

---

## Phase 1: Address Review Findings

**Goal:** Fix all 16 findings and rebuild integrations
**Verification:** All review report items resolved; integrations regenerated; parent track closed

### Tasks

- [x] **Task 1.1:** Fix SHA extraction (Important #1) (bb39aef)
  - Files: `skills/review/SKILL.md` (~line 100)
  - Add explicit regex pattern: `\([a-f0-9]{7,}\)` from `[x]` completed lines only
  - Add dedup rule: remove duplicates keeping first occurrence
  - Add ordering note: preserve chronological order of appearance

- [x] **Task 1.2:** Fix flag conflict handling (Important #2) (bb39aef)
  - Files: `skills/review/SKILL.md` (~line 41-42)
  - Replace mutual exclusivity rule with graceful handling:
    "If both --full and --with-validate/--with-bughunt provided, treat as --full and ignore redundant flags"

- [x] **Task 1.3:** Fix ambiguous track match flow (Important #3) (bb39aef)
  - Files: `skills/review/SKILL.md` (~line 79-82)
  - Add step-by-step: display numbered list, prompt "Select track (1-N):", validate input range

- [x] **Task 1.4:** Fix metadata update conditional (Important #4) (bb39aef)
  - Files: `skills/review/SKILL.md` (~line 458-482)
  - Add condition: only update metadata.json when verdict is PASS or PASS_WITH_NOTES
  - On FAIL: generate report but skip metadata update

- [x] **Task 1.5:** Fix cross-tool deduplication (Important #5) (bb39aef)
  - Files: `skills/review/SKILL.md` (~line 335-337)
  - Define: duplicate = same file:line reference
  - Severity ordering: Critical > Important > Minor
  - Merge: keep highest severity, combine descriptions as "Found by: tool1, tool2"

- [x] **Task 1.6:** Fix incomplete task warning (Important #6) (bb39aef)
  - Files: `skills/review/SKILL.md` (~line 106-109)
  - Define exact format: "Warning: Track has N incomplete tasks (M in-progress, K pending). Reviewing completed work only."

- [x] **Task 1.7:** Fix duplicate icon (Minor #1) (58feba4)
  - Files: `index.html` (~line 1628)
  - Change /draft:review icon from magnifying glass to clipboard

- [x] **Task 1.8:** Fix reviewer identification (Minor #2) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 354)
  - Replace "Claude Sonnet 4.5 (1M context)" with runtime model instruction

- [x] **Task 1.9:** Fix file filter list (Minor #3) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 199-201)
  - Add: `__pycache__/`, `target/`, `vendor/`, `dist/`, `build/`, `node_modules/`, `.git/`

- [x] **Task 1.10:** Fix @generated detection (Minor #4) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 201)
  - Specify: case-insensitive, any comment syntax (`/* */`, `//`, `#`)

- [x] **Task 1.11:** Fix shortstat parsing (Minor #5) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 170-174)
  - Add: handle both "1 file changed" and "N files changed" forms

- [x] **Task 1.12:** Fix large diff progress (Minor #6) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 186)
  - Add: display "[N/M] Reviewing <filename>" for each file

- [x] **Task 1.13:** Fix auto-detect confirmation (Minor #7) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 45-48)
  - Add: display "Auto-detected track: <id> - <name> [status]" and proceed

- [x] **Task 1.14:** Fix project-level report semantics (Minor #8) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 438-447)
  - Add: all project-level scopes write to `draft/review-report.md`; overwrite with previous timestamp

- [x] **Task 1.15:** Fix Stage 1 FAIL threshold (Minor #9) (58feba4)
  - Files: `skills/review/SKILL.md` (~line 235-237)
  - Add explicit: "FAIL if ANY requirement missing OR ANY acceptance criterion not met"

- [x] **Task 1.16:** Rebuild integrations (cafbaf0)
  - Command: `./scripts/build-integrations.sh`
  - Verify: review skill changes propagated to all 3 integration files (13/13 skills)
  - Depends on: Tasks 1.1-1.15

- [x] **Task 1.17:** Close parent track (this commit)
  - Files: `draft/tracks/add-review-command/plan.md`, `draft/tracks/add-review-command/metadata.json`, `draft/tracks.md`
  - Mark Task 4.5 as [x] complete
  - Update metadata.json status to completed
  - Move add-review-command to Completed section in tracks.md

---

## Notes

- All SKILL.md edits are additive clarifications — no structural changes
- Integration rebuild required after SKILL.md changes (source-of-truth hierarchy)
- Parent track (add-review-command) closed after this track completed
