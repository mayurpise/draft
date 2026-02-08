# Review Report: Add /draft:review Command

**Track ID:** add-review-command
**Reviewed:** 2026-02-08T00:00:00Z
**Reviewer:** Claude Sonnet 4.5 (1M context)
**Commit Range:** 7a7dc85^..fa8983a
**Diff Stats:** 9 files changed, 2699 insertions(+), 2 deletions(-)

---

## Stage 1: Spec Compliance

**Status:** PASS

### Requirements Coverage

#### Functional Requirements

- [x] **Track-level review** — Implemented in `skills/review/SKILL.md:56-115`
  - [x] Auto-detect active `[~]` track (SKILL.md:46-48)
  - [x] `--track <id|name>` with fuzzy matching (SKILL.md:60-83)
  - [x] Extract git commits from plan.md (SKILL.md:98-104)
  - [x] Two-stage reviewer agent (SKILL.md:205-288)
  - [x] Generate `draft/tracks/<id>/review-report.md` (SKILL.md:341-436)

- [x] **Project-level review** — Implemented in `skills/review/SKILL.md:116-160`
  - [x] `--project` flag for uncommitted changes (SKILL.md:122-124)
  - [x] `--files <pattern>` for specific files (SKILL.md:126-133)
  - [x] `--commits <range>` for commit range (SKILL.md:135-142)
  - [x] Code quality checks only / Stage 2 only (SKILL.md:157-159)
  - [x] Generate `draft/review-report.md` (SKILL.md:438-448)

- [x] **Quality tool integration** — Implemented in `skills/review/SKILL.md:292-338`
  - [x] `--with-validate` integration (SKILL.md:296-310)
  - [x] `--with-bughunt` integration (SKILL.md:312-326)
  - [x] `--full` runs both (SKILL.md:35)
  - [x] Results aggregated into unified report (SKILL.md:328-338)

- [x] **Scope resolution** — Implemented in `skills/review/SKILL.md:60-83`
  - [x] Exact directory match (SKILL.md:62-66)
  - [x] Fuzzy match against track ID (SKILL.md:74-77)
  - [x] Fuzzy match against track name (SKILL.md:74-77)
  - [x] Prompt on ambiguous matches (SKILL.md:80)
  - [x] Suggest alternatives on no match (SKILL.md:81)

- [x] **Smart diff handling** — Implemented in `skills/review/SKILL.md:163-201`
  - [x] Small changes (<300 lines): full diff (SKILL.md:178-183)
  - [x] Large changes (>=300 lines): file-by-file (SKILL.md:185-195)

### Acceptance Criteria

#### Track-Level Review
- [x] Auto-detects active `[~]` track — SKILL.md:46-48
- [x] `--track <id>` reviews by exact ID — SKILL.md:62-66
- [x] `--track <name>` fuzzy-matches — SKILL.md:68-77
- [x] Loads spec.md and plan.md — SKILL.md:88-104
- [x] Extracts commit SHAs from plan.md — SKILL.md:98-104
- [x] Runs Stage 1 (Spec Compliance) — SKILL.md:209-237
- [x] Runs Stage 2 (Code Quality) only if Stage 1 passes — SKILL.md:239-288
- [x] Generates review-report.md with severity classification — SKILL.md:341-436
- [x] `--with-validate` includes validation results — SKILL.md:296-310
- [x] `--with-bughunt` includes bug hunt findings — SKILL.md:312-326
- [x] `--full` runs both — SKILL.md:35

#### Project-Level Review
- [x] `--project` reviews uncommitted changes — SKILL.md:122-124
- [x] `--files` reviews matching files — SKILL.md:126-133
- [x] `--commits` reviews commit range — SKILL.md:135-142
- [x] Loads project context — SKILL.md:144-159
- [x] Runs Stage 2 only — SKILL.md:157-159
- [x] Generates `draft/review-report.md` — SKILL.md:438-448
- [x] `--with-validate --project` works — SKILL.md:300-303
- [x] `--with-bughunt --project` works — SKILL.md:316-325

#### Smart Diff Handling
- [x] Runs `git diff --shortstat` first — SKILL.md:169-174
- [x] Full diff for <300 lines — SKILL.md:178-183
- [x] File-by-file for >=300 lines — SKILL.md:185-195
- [x] Aggregates findings — SKILL.md:194-195

#### Error Handling
- [x] Error when no tracks exist — SKILL.md:548-555
- [x] Error when track not found with suggestions — SKILL.md:557-567
- [x] Handles missing spec.md/plan.md — SKILL.md:111-114
- [x] Validates git commit range — SKILL.md:135-141

### Scope Adherence
- [x] No missing features from spec
- [x] No scope creep beyond spec
- [x] Non-goals untouched (no PR creation, no CI/CD, no auto-fixing)

---

## Stage 2: Code Quality

**Status:** PASS WITH NOTES

### Critical Issues

None.

### Important Issues

- [ ] [skills/review/SKILL.md:100] SHA extraction pattern is vague — spec says `<SHA>` or `commit <SHA>` but SKILL.md just says "Extract commit SHAs (pattern: `<SHA>` or `commit <SHA>`)" without defining the regex. This is a declarative skill file (instructions to an LLM, not executable code), so the LLM executing the review must infer the pattern. **Low practical risk** since the executing LLM reads plan.md directly and can identify 7-char hex SHAs contextually.
  - **Impact:** Ambiguity in how SHAs are extracted could lead to missed commits in edge cases
  - **Suggested fix:** Add explicit pattern guidance: "Match 7+ character hex strings in parentheses after task markers, e.g., `(7a7dc85)`"

- [ ] [skills/review/SKILL.md:35] Flag conflict rule states `--full` cannot combine with `--with-validate` or `--with-bughunt`, but this is purely instructional — no enforcement mechanism exists. The LLM executing the command may silently accept invalid combinations.
  - **Impact:** User could pass `--full --with-validate` and get undefined behavior
  - **Suggested fix:** Add explicit instruction: "If both `--full` and `--with-validate`/`--with-bughunt` are provided, treat as `--full` and ignore the redundant flags."

- [ ] [README.md:370-420] README documents `/draft:review` extensively but the expandable card format used for other commands (like validate and bughunt with `<details>/<summary>`) is not used for review. The review section uses a flat heading + code block format.
  - **Impact:** Visual inconsistency in documentation
  - **Suggested fix:** Wrap in `<details><summary>` to match other command reference cards

### Minor Notes

- [CHANGELOG.md] Mentions "Comparison with Conductor" in changelog which is good for context but unusual for a changelog entry. Standard changelogs describe what changed, not competitive comparisons.

- [index.html:1321-1326] Both `/draft:review` and `/draft:jira-preview` use the same eye icon (👁️). Minor visual distinction issue.

- [skills/review/SKILL.md:200-201] The file filter list (`.lock`, `package-lock.json`, `.min.js`, `.map`) is marked "Optional" which is appropriate, but the `@generated` marker check adds complexity for marginal gain in this context (Draft skills are markdown, not compiled output).

- [scripts/build-integrations.sh] The review skill is placed between `bughunt` and `status` in SKILL_ORDER. Logical ordering — review comes after quality tools and before status/utility commands.

---

## Summary

**Total Issues:** 6
- Critical: 0
- Important: 3
- Minor: 3 (non-blocking notes)

**Verdict:** PASS WITH NOTES

**Required Actions:**
1. Consider clarifying SHA extraction pattern in SKILL.md (Important #1)
2. Consider adding graceful handling for redundant flag combinations (Important #2)
3. Consider aligning README format with expandable card pattern (Important #3)

---

## Recommendations

Warning: This track has 1 incomplete task (Task 4.5: Integration testing). Consider completing before marking track as done.

No blocking issues found. The core skill implementation is complete and well-structured. The important issues are quality improvements, not functional gaps. This track is ready to complete Task 4.5 (integration testing) and close.
