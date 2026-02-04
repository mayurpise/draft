# Plan: Sync .cursorrules with Draft Skills

**Track ID:** sync-cursorrules
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview
Fix the .cursorrules build pipeline to dynamically include all skills, update stale tables, and inline agent summaries. Changes are limited to `scripts/build-cursorrules.sh` and the generated `integrations/cursor/.cursorrules`.

---

## Phase 1: Refactor Build Script
**Goal:** Replace hardcoded skill blocks with dynamic discovery and ordered output
**Verification:** Script runs without errors; output includes all 10 skills

### Tasks
- [x] **Task 1.1:** Add skill ordering mechanism to build script
  - Define an ordered array of skill names: `draft`, `init`, `new-track`, `decompose`, `implement`, `coverage`, `status`, `revert`, `jira-preview`, `jira-create`
  - Replace 7 individual `if` blocks with a loop over this array
  - Each iteration: extract body, transform syntax, output with section header
  - Files: `scripts/build-cursorrules.sh`

- [x] **Task 1.2:** Add display name and trigger mapping for each skill
  - Map skill directory names to human-readable section headers and trigger phrases
  - e.g., `init` → "Init Command" / "init draft" or "@draft init"
  - Use an associative array or case statement
  - Files: `scripts/build-cursorrules.sh`

---

## Phase 2: Update HEADER Content
**Goal:** HEADER tables reflect all 10 commands
**Verification:** Available Commands table has 10 rows; Intent Mapping table has all patterns

### Tasks
- [x] **Task 2.1:** Update Available Commands table in HEADER
  - Add: `@draft decompose`, `@draft coverage`, `@draft` (overview)
  - Files: `scripts/build-cursorrules.sh`

- [x] **Task 2.2:** Update Intent Mapping table in HEADER
  - Add: "break into modules" → decompose, "check coverage" → coverage, "help" / "what commands" → draft overview
  - Files: `scripts/build-cursorrules.sh`

---

## Phase 3: Inline Agent Summaries
**Goal:** Replace dead `See core/agents/*.md` references with actionable inline content
**Verification:** Zero `See core/agents/` references in .cursorrules output

### Tasks
- [x] **Task 3.1:** Expand Quality Disciplines section with agent summaries
  - Add architect summary: module decomposition rules (5 rules), cycle-breaking strategies, story lifecycle stages
  - Add debugger summary: 4-step process with key rules (no fixes without investigation, single hypothesis)
  - Add reviewer summary: two-stage process with criteria for each stage, issue classification (Critical/Important/Minor)
  - Files: `scripts/build-cursorrules.sh`

- [x] **Task 3.2:** Remove dead file references from skill bodies during transform
  - Add a sed rule to strip or replace `See core/agents/*.md` patterns with "(see Quality Disciplines section)"
  - Files: `scripts/build-cursorrules.sh`

---

## Phase 4: Rebuild & Verify
**Goal:** Generate .cursorrules and confirm all acceptance criteria
**Verification:** Script runs clean; syntax check passes; all 10 skills present; no dead references

### Tasks
- [x] **Task 4.1:** Run build-cursorrules.sh and verify output
  - Skills: 10/10
  - Lines: 2087
  - `/draft:` references: 0 (PASS)
  - `See core/agents/` references: 0 (PASS)
  - `@draft` references: 67
  - Available Commands table: 10 rows (PASS)
  - Files: `integrations/cursor/.cursorrules`

- [x] **Task 4.2:** Spot-check generated content for 3 new skills
  - Draft Overview: line 79 (PASS)
  - Decompose Command: line 584 (PASS)
  - Coverage Command: line 1153 (PASS)
  - `/draft:` → `@draft` transform verified (PASS)
  - Files: `integrations/cursor/.cursorrules`

---

## Notes
- Phase 1 must complete before Phase 4
- Phases 2 and 3 can run in parallel after Phase 1
- The `draft` overview skill should appear first in the output (before init)
- HEADER and QUALITY sections remain hardcoded heredocs in the build script — they are not derived from skill files
