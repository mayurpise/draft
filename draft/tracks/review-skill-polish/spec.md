# Specification: Polish Review Skill

**Track ID:** review-skill-polish
**Created:** 2026-02-08
**Status:** [x] Complete
**Source:** `draft/tracks/add-review-command/review-report.md` (Review #2, 2026-02-08)

## Summary

Address all 16 findings from the add-review-command review report: 6 Important specification clarity issues in `skills/review/SKILL.md`, 1 icon fix in `index.html`, and 9 Minor improvements. Then rebuild integrations and close the parent track.

## Context References
- **Source:** `draft/tracks/add-review-command/review-report.md`
- **Target File:** `skills/review/SKILL.md` (primary)
- **Target File:** `index.html` (icon fix)
- **Build:** `./scripts/build-integrations.sh`

## Problem Statement

The `/draft:review` skill passed review with PASS WITH NOTES verdict. Six Important issues are specification clarity gaps that could cause inconsistent behavior across different LLM interpreters. Ten Minor issues improve robustness and UX.

## Requirements

### Important Fixes (SKILL.md)

1. **SHA extraction regex** — Define explicit pattern `\([a-f0-9]{7,}\)` from `[x]` lines only; dedup rule keeping first occurrence
2. **Flag conflict handling** — Add explicit instruction for `--full` + `--with-validate`/`--with-bughunt` overlap
3. **Ambiguous track match flow** — Define step-by-step interactive prompt for multi-match selection
4. **Metadata update conditional** — Only update metadata.json on PASS or PASS_WITH_NOTES; skip on FAIL
5. **Cross-tool deduplication** — Define severity ordering, match criteria (same file:line), tool attribution merge
6. **Incomplete task warning** — Define exact warning message format with task counts

### Minor Fixes

7. **Duplicate icon** (index.html) — Use distinct icon for /draft:review vs /draft:bughunt
8. **Reviewer identification** (SKILL.md) — Replace hardcoded model name with runtime instruction
9. **File filter list** (SKILL.md) — Add Python, Rust, Go ecosystem ignore patterns
10. **@generated detection** (SKILL.md) — Specify regex and case-sensitivity rule
11. **Shortstat parsing** (SKILL.md) — Handle singular/plural forms robustly
12. **Large diff progress** (SKILL.md) — Define per-file progress output format
13. **Auto-detect confirmation** (SKILL.md) — Add user confirmation step for auto-detected track
14. **Project-level report overwrite** (SKILL.md) — Clarify semantics for multiple scopes
15. **Stage 1 FAIL threshold** (SKILL.md) — Explicitly state ANY missing requirement = FAIL

### Post-Fix

16. **Rebuild integrations** — Run `./scripts/build-integrations.sh` after SKILL.md changes
17. **Close parent track** — Mark add-review-command Task 4.5 as complete, update tracks.md

## Acceptance Criteria

- [ ] All 6 Important issues addressed in skills/review/SKILL.md
- [ ] All 9 Minor issues addressed (8 in SKILL.md, 1 in index.html)
- [ ] Integrations rebuilt and verified
- [ ] add-review-command track marked complete in tracks.md

## Non-Goals

- No new features added to the review skill
- No changes to reviewer agent (core/agents/reviewer.md)
- No changes to spec.md or plan.md format
