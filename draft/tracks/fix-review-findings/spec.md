# Specification: Fix Review Command Findings

**Track ID:** fix-review-findings
**Created:** 2026-02-08
**Status:** [x] Complete

## Context References
- **Source:** `draft/tracks/add-review-command/review-report.md` — 3 Important + 2 Minor findings
- **Architecture:** `CLAUDE.md` — Source of truth hierarchy, skill file format
- **Tech Stack:** Shell scripts (build-integrations.sh), Markdown skill files, HTML (index.html)

## Problem Statement

The `/draft:review` command passed review with a PASS WITH NOTES verdict. Five actionable issues were identified: 3 Important (SHA extraction ambiguity, flag conflict handling, README format inconsistency) and 2 Minor (duplicate icon, changelog wording). These should be resolved before closing the add-review-command track.

## Background & Why Now

The add-review-command track is at 86% completion (18/21 tasks). Fixing these findings cleans up the implementation before final integration testing (Task 4.5) and track closure.

## Requirements

### Functional

1. **SHA extraction clarity** — Add explicit pattern guidance to SKILL.md for extracting commit SHAs from plan.md
2. **Flag conflict graceful handling** — Add instruction for how to handle redundant `--full --with-validate` combinations
3. **README format alignment** — Wrap `/draft:review` section in `<details><summary>` expandable card matching other commands
4. **Unique icon for review** — Change `/draft:review` icon in index.html to differentiate from `/draft:jira-preview`
5. **Changelog wording** — Remove competitive comparison line from CHANGELOG.md entry

### Non-Functional

- All changes must be backwards-compatible (no behavior changes to review command)
- Integration files must be rebuilt after SKILL.md changes

## Acceptance Criteria

- [x] SKILL.md contains explicit SHA extraction pattern: "Match 7+ character hex strings in parentheses after task markers"
- [x] SKILL.md contains graceful handling instruction for redundant flag combinations
- [x] index.html uses a distinct icon for `/draft:review` (not the same as jira-preview)
- [x] CHANGELOG.md entry removes "Comparison with Conductor" line
- [x] Integration files regenerated via `./scripts/build-integrations.sh`

## Non-Goals

- Not changing review command behavior or logic
- Not addressing Minor #3 (@generated marker check — already marked Optional, no action needed)
- Not modifying other commands or skills

## Technical Approach

Direct edits to 4 source files + integration rebuild:
1. `skills/review/SKILL.md` — 2 targeted edits (SHA pattern, flag handling)
2. `README.md` — Restructure review section with expandable card
3. `index.html` — Change icon character
4. `CHANGELOG.md` — Remove one line
5. Rebuild integrations

## Conversation Log

> Track created from review findings. User confirmed scope: all 5 actionable issues (3 Important + 2 Minor). Skipping Minor #3 (@generated marker) as already appropriately handled.
