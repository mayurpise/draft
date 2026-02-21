# Deep Review Report — Full System Audit

**Date:** 2026-02-21
**Scope:** All 43 modules across 7 categories
**Reviewers:** 5 parallel agents (reviewer-workflow, reviewer-quality, reviewer-support, reviewer-agents, reviewer-infra)

---

## Executive Summary

| Severity | Count |
|----------|-------|
| Critical | 9 |
| Important | 27 |
| Minor | 45 |

**System Verdict: CONDITIONAL PASS**

The Draft plugin is architecturally sound with clear separation of concerns and well-structured skill files. However, several critical issues — particularly around data integrity (report overwrites, partial creation without rollback) and a pervasive naming inconsistency ("Derivation Subroutine" vs "Condensation Subroutine") — must be resolved before the system can be considered production-grade.

---

## Critical Findings (9)

### C1. Derivation/Condensation Subroutine Naming Chaos
**Files:** `skills/implement/SKILL.md:252`, `skills/decompose/SKILL.md:228,314`, `core/agents/architect.md:328`, `core/methodology.md:441`
**Description:** `init/SKILL.md` defines a "Condensation Subroutine" (architecture.md → .ai-context.md). But `implement`, `decompose`, and `architect` reference a "Derivation Subroutine" which is **never defined anywhere**. The direction of transformation is also confused — some references imply .ai-context.md → architecture.md (the reverse).
**Impact:** Agents following implement or decompose literally cannot execute these steps. Blocks two core skills.
**Fix:** Define both directions explicitly in `init/SKILL.md`, pick one canonical naming scheme, and update all references across all files.

### C2. deep-review Report Overwrites Previous Reviews
**File:** `skills/deep-review/SKILL.md:85`
**Description:** Single output path `draft/deep-review-report.md`. Sequential module reviews (the skill's primary use case) overwrite each other. History file only stores one-line summaries.
**Fix:** Use `draft/deep-review-reports/<module-name>.md` for per-module reports.

### C3. jira-create Partial Creation Without Incremental Key Persistence
**File:** `skills/jira-create/SKILL.md` Steps 5-6
**Description:** Issues are created sequentially (Epic → Stories → Sub-tasks → Bugs) but `jira-export.md` is only updated AFTER all creation (Step 6). If process fails mid-Step 5, no keys are recorded. Re-running creates duplicates.
**Fix:** Update `jira-export.md` incrementally after EACH successful issue creation.

### C4. revert Missing Uncommitted Changes Check
**File:** `skills/revert/SKILL.md:14`
**Description:** Red flags section warns about not checking uncommitted changes, but NO step actually runs `git status` before proceeding. `git revert --no-commit` on a dirty working tree fails or produces unexpected results.
**Fix:** Add Step 0: Run `git status --porcelain`. If non-empty, warn and abort until working tree is clean.

### C5. revert Atomicity Gap Between Git and Draft State
**File:** `skills/revert/SKILL.md` Steps 4-5
**Description:** If interrupted between git revert and Draft state update, git is reverted but `plan.md` still shows `[x]` for reverted tasks. No rollback mechanism.
**Fix:** Update Draft state (plan.md, metadata.json) BEFORE the git commit, or define recovery instructions.

### C6. new-track Track ID Collision — No Existence Check
**File:** `skills/new-track/SKILL.md:47-50`
**Description:** ID generation uses kebab-case from description. No verification that `draft/tracks/<track_id>/` doesn't already exist. Second track with same name silently overwrites the first.
**Fix:** Check directory existence before creation. Auto-append date suffix on collision.

### C7. init Atomicity Gap — No Rollback on Partial Init
**File:** `skills/init/SKILL.md`
**Description:** If init fails mid-execution (after writing architecture.md but before product.md), the project is half-initialized. Pre-check sees `draft/` exists and refuses re-init.
**Fix:** Add rollback instructions or stage files in a temp directory first.

### C8. init Duplicate Step Labels in Refresh Mode
**File:** `skills/init/SKILL.md:175-184`
**Description:** Two steps labeled "c." in Architecture Refresh sub-steps. Causes ambiguous instruction execution.
**Fix:** Relabel steps sequentially: a, b, c, d, e, f, g, h, i.

### C9. build-integrations.sh References Removed `validate` Skill
**File:** `scripts/build-integrations.sh:38`
**Description:** `SKILL_ORDER` includes `validate` (removed in commit d8b2c50). Generated integrations advertise a non-existent command. `deep-review` is missing from `SKILL_ORDER` entirely.
**Fix:** Remove `validate` from SKILL_ORDER/headers/triggers. Add `deep-review`. Update hardcoded command table. Rebuild.

---

## Important Findings (27)

### Skills — Core Workflow

| # | Issue | File | Fix Summary |
|---|-------|------|-------------|
| I1 | Condensation/Derivation reference inconsistency between init and decompose/implement | `init/SKILL.md:1856` | Define both subroutines or unify naming |
| I2 | grep command in refresh is fragile (YAML parsing) | `init/SKILL.md:172` | Use robust sed extraction |
| I3 | No file size guardrail for architecture.md on large codebases | `init/SKILL.md` | Cap at 500 source files, summarize the rest |
| I4 | new-track rename operation has no error handling | `new-track/SKILL.md:407-410` | Explicit read→write→verify→delete sequence |
| I5 | new-track metadata.json tasks.total initialized to 0 despite plan having tasks | `new-track/SKILL.md:493` | Count `- [ ]` lines and populate |
| I6 | implement concurrent track modification — no locking | `implement/SKILL.md` | Advisory: single-agent per track |
| I7 | implement git add/commit without staged changes check | `implement/SKILL.md:226` | Check `git diff --cached --quiet` first |
| I8 | implement phase boundary review underspecified (OWASP scans) | `implement/SKILL.md:284` | Reference specific tools per language or soften wording |
| I9 | decompose backup pattern has no restore instruction | `decompose/SKILL.md:317` | Define rejection restore procedure |
| I10 | decompose module size guideline too restrictive (>3 files) | `decompose/SKILL.md:14` | Change to >5 files, exclude test files |
| I11 | decompose overwrites existing .ai-context.md from init | `decompose/SKILL.md:84` | Use Mutation Protocol for existing files |
| I12 | coverage no report file persisted | `coverage/SKILL.md` | Write to `coverage-report.md` |
| I13 | coverage 95% target undocumented in workflow.md template | `coverage/SKILL.md:25` | Add field to workflow template |
| I14 | coverage tool output format parsing unspecified | `coverage/SKILL.md:71` | Add per-tool parsing hints |

### Skills — Quality/Management

| # | Issue | File | Fix Summary |
|---|-------|------|-------------|
| I15 | review duplicates reviewer agent content (drift risk) | `review/SKILL.md:241-324` | Reference `core/agents/reviewer.md` instead |
| I16 | review project-level loads Draft plugin files instead of user project files | `review/SKILL.md:173-176` | Remove lines 173-176 |
| I17 | deep-review no git metadata in report | `deep-review/SKILL.md:85` | Add YAML frontmatter |
| I18 | deep-review module discovery underspecified | `deep-review/SKILL.md:28` | Define priority algorithm |
| I19 | bughunt scope confirmation blocks automation from /draft:review | `bughunt/SKILL.md:68` | Skip when invoked programmatically |
| I20 | revert SHA authority ambiguity (plan.md vs git log) | `revert/SKILL.md:53` | Clarify git log is always authoritative |
| I21 | revert partial revert recovery undefined | `revert/SKILL.md:138` | Track which commits succeeded |
| I22 | revert metadata.json phase status update logic underspecified | `revert/SKILL.md:106` | Define phase status transition rules |

### Skills — Support

| # | Issue | File | Fix Summary |
|---|-------|------|-------------|
| I23 | index atomicity — partial file generation on interruption | `index/SKILL.md` | Temp dir staging or lockfile |
| I24 | index manifest.json dependents field never resolved | `index/SKILL.md` | Add explicit reverse-lookup step |
| I25 | index concurrent execution conflict | `index/SKILL.md` | Add lockfile mechanism |
| I26 | jira-preview silent overwrite of reviewed export | `jira-preview/SKILL.md:452` | Check mtime before overwrite |
| I27 | jira-create MCP tool detection is fragile | `jira-create/SKILL.md` | List known tool name variants |

### Agents & Core

| # | Issue | File | Fix Summary |
|---|-------|------|-------------|
| I28 | RCA/Debugger overlap — no decision rule for bug track tasks | `rca.md:253` | Add explicit routing rule |
| I29 | Reviewer no cross-module review guidance | `reviewer.md` | Add module boundary verification step |
| I30 | Planner under-specified — missing phase assignment rules | `planner.md` | Add Foundation/Implementation/Integration/Polish criteria |
| I31 | Methodology agent summaries duplicate and drift from canonical files | `methodology.md:1036-1151` | Reduce to table with links |

### Infrastructure

| # | Issue | File | Fix Summary |
|---|-------|------|-------------|
| I32 | build script $transform_fn unquoted | `build-integrations.sh:239` | Quote or use stdin redirection |
| I33 | Test suite doesn't catch stale skill references | `test-build-integrations.sh` | Add WARNING detection test |
| I34 | metadata.json template not in CORE_FILES for inlining | `build-integrations.sh:187` | Add to array |

---

## Cross-Cutting Themes

### 1. Source-of-Truth Direction Inconsistency
`architecture.md` vs `.ai-context.md` — which is derived from which?
- **CLAUDE.md, init**: architecture.md is source, .ai-context.md is derived
- **decompose description**: .ai-context.md is source, architecture.md is derived
- **Multiple skills**: Conflicting references

**Resolution needed:** Establish one canonical direction and enforce everywhere. Recommendation: architecture.md is source of truth (aligns with init's 5-phase discovery).

### 2. No Concurrency Model
Multiple skills modify `tracks.md`, `metadata.json`, `plan.md`, and `.ai-context.md` with no locking, optimistic concurrency, or conflict detection. Running any two Draft commands simultaneously on the same track risks corruption.

**Resolution needed:** Add system-wide advisory in methodology.md and per-skill guards.

### 3. Report File Overwrite Pattern
`review-report.md`, `bughunt-report.md`, `deep-review-report.md` all use single-file output. Sequential runs destroy previous reports.

**Resolution needed:** Per-run or per-module report files, or append-mode with timestamps.

### 4. Agent Content Duplication
Reviewer logic exists in 3 places: `core/agents/reviewer.md`, `skills/review/SKILL.md`, `core/methodology.md`. Architect content is duplicated similarly. Drift is already observable (reviewer maintainability items differ).

**Resolution needed:** Single-source agent definitions with references from skills and methodology.

---

## Module Verdicts

| Module | Verdict | Critical | Important | Minor |
|--------|---------|----------|-----------|-------|
| init | FAIL | 2 | 3 | 2 |
| new-track | FAIL | 1 | 2 | 2 |
| implement | CONDITIONAL PASS | 1 | 3 | 2 |
| decompose | CONDITIONAL PASS | 1 | 3 | 1 |
| coverage | CONDITIONAL PASS | 0 | 3 | 2 |
| review | CONDITIONAL PASS | 0 | 2 | 3 |
| deep-review | FAIL | 1 | 2 | 2 |
| bughunt | CONDITIONAL PASS | 0 | 1 | 3 |
| revert | FAIL | 2 | 3 | 1 |
| status | PASS | 0 | 0 | 4 |
| draft (overview) | PASS | 0 | 0 | 2 |
| index | CONDITIONAL PASS | 0 | 3 | 3 |
| adr | CONDITIONAL PASS | 0 | 1 | 3 |
| jira-preview | CONDITIONAL PASS | 0 | 1 | 3 |
| jira-create | FAIL | 1 | 2 | 2 |
| architect | PASS | 0 | 0 | 3 |
| rca | CONDITIONAL PASS | 0 | 1 | 2 |
| reviewer | CONDITIONAL PASS | 0 | 1 | 2 |
| planner | CONDITIONAL PASS | 0 | 1 | 2 |
| debugger | PASS | 0 | 0 | 2 |
| methodology | CONDITIONAL PASS | 0 | 2 | 3 |
| knowledge-base | PASS | 0 | 0 | 3 |
| build-integrations.sh | FAIL | 1 | 2 | 1 |
| test-build-integrations.sh | CONDITIONAL PASS | 0 | 1 | 1 |
| Templates (all) | PASS | 0 | 0 | 0 |
| Plugin manifest | PASS | 0 | 0 | 1 |
| Integrations (generated) | N/A | 0 | 0 | 0 |

### Verdict Distribution
- **PASS:** 7 modules
- **CONDITIONAL PASS:** 13 modules
- **FAIL:** 6 modules (init, new-track, deep-review, revert, jira-create, build-integrations.sh)

---

## Priority Fix Order

1. **Subroutine naming** (C1) — Unblocks implement and decompose
2. **build-integrations.sh stale validate** (C9) — Users see broken command
3. **jira-create incremental key persistence** (C3) — Data integrity
4. **revert uncommitted changes check** (C4) — Data loss prevention
5. **deep-review per-module reports** (C2) — Core functionality broken
6. **new-track collision check** (C6) — Data loss prevention
7. **init rollback/atomicity** (C7, C8) — First-run experience
8. **revert atomicity** (C5) — State corruption prevention
9. **Source-of-truth direction** (cross-cutting) — Systemic consistency
10. **Concurrency advisory** (cross-cutting) — Safety documentation
