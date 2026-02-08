# Specification: Add /draft:review Command

**Track ID:** add-review-command
**Created:** 2026-02-07
**Status:** [ ] Draft

## Summary

Add `/draft:review` as a standalone command that orchestrates code review workflows at both track-level and project-level. Integrates existing quality agents (reviewer, validate, bughunt) into a unified review experience matching Conductor's review capabilities while leveraging Draft's existing strengths.

## Background

Currently, Draft performs code review only inline during `/draft:implement` via the reviewer agent at phase boundaries. There's no standalone command to review:
- Completed tracks before marking them done
- Work done outside `/draft:implement`
- PRs from other developers
- Arbitrary code changes or commits

Conductor (Gemini CLI extension with similar methodology) provides `/conductor:review` as a standalone command. Draft should match this capability while integrating with our existing quality tools (`/draft:validate`, `/draft:bughunt`, reviewer agent).

## Requirements

### Functional

1. **Track-level review** - Review a specific track's implementation against its `spec.md` and `plan.md`
   - Auto-detect active `[~]` track when no argument provided
   - Accept `--track <id>` or `--track <name>` with fuzzy matching
   - Extract git commits from plan.md (commit SHAs recorded during implementation)
   - Run two-stage reviewer agent: (1) Spec Compliance → (2) Code Quality
   - Generate report at `draft/tracks/<id>/review-report.md`

2. **Project-level review** - Review arbitrary changes without track context
   - `--project` flag reviews uncommitted changes (`git diff HEAD`)
   - `--files <pattern>` reviews specific files
   - `--commits <ref-range>` reviews commit range (e.g., `main...HEAD`)
   - Code quality checks only (no spec compliance - no spec exists)
   - Generate report at `draft/review-report.md`

3. **Quality tool integration** - Optionally run existing quality commands
   - `--with-validate` runs `/draft:validate` (architecture/security/performance)
   - `--with-bughunt` runs `/draft:bughunt` (defect discovery across 12 dimensions)
   - `--full` runs both validate and bughunt
   - Results integrated into unified review report

4. **Scope resolution** - Support both ID and name matching for tracks
   - Exact directory match in `draft/tracks/` (fastest)
   - Fuzzy match against track ID (slug)
   - Fuzzy match against track name (heading text)
   - Prompt user on ambiguous matches
   - Suggest alternatives on no match

5. **Smart diff handling** - Handle both small and large changesets
   - Small changes (<300 lines): full diff in one pass
   - Large changes (>300 lines): file-by-file iteration with aggregated findings

### Non-Functional

- **Performance**: Large diffs should use streaming/chunking to avoid context overflow
- **Consistency**: Output format matches existing Draft reports (markdown with file:line references)
- **Extensibility**: Easy to add new quality checks in future (coverage, accessibility, etc.)

## Acceptance Criteria

### Track-Level Review
- [ ] `/draft:review` auto-detects active `[~]` track and prompts for confirmation
- [ ] `/draft:review --track <id>` reviews by exact track ID
- [ ] `/draft:review --track <name>` fuzzy-matches track name and prompts on ambiguity
- [ ] Loads `spec.md` and `plan.md` from track directory
- [ ] Extracts commit SHAs from plan.md and generates git diff range
- [ ] Runs reviewer agent Stage 1 (Spec Compliance) checking all acceptance criteria
- [ ] Runs reviewer agent Stage 2 (Code Quality) only if Stage 1 passes
- [ ] Generates `draft/tracks/<id>/review-report.md` with Critical/Important/Minor findings
- [ ] `--with-validate` includes validation results in report
- [ ] `--with-bughunt` includes bug hunt findings in report
- [ ] `--full` runs both validate and bughunt

### Project-Level Review
- [ ] `/draft:review --project` reviews uncommitted changes
- [ ] `/draft:review --files "src/**/*.ts"` reviews matching files
- [ ] `/draft:review --commits main...HEAD` reviews commit range
- [ ] Loads project context from `core/methodology.md`, `core/agents/reviewer.md`, `CLAUDE.md`
- [ ] Runs code quality checks (Stage 2 only - no spec compliance)
- [ ] Generates `draft/review-report.md` with findings
- [ ] `--with-validate --project` includes project-level validation
- [ ] `--with-bughunt --project` includes project-level bug hunt

### Smart Diff Handling
- [ ] Runs `git diff --shortstat` first to determine size
- [ ] Uses full diff for <300 lines
- [ ] Uses file-by-file iteration for >300 lines with progress indication
- [ ] Aggregates findings from all chunks into single report

### Error Handling
- [ ] Clear error when no tracks exist
- [ ] Clear error when specified track not found (with suggestions)
- [ ] Handles missing spec.md or plan.md gracefully
- [ ] Validates git commit range before processing

## Non-Goals

- **Not a replacement for inline review** - The reviewer agent at phase boundaries in `/draft:implement` remains
- **Not a PR creation tool** - This reviews code, doesn't create GitHub/GitLab PRs
- **Not a CI/CD integration** - This is a manual command, not automated pipeline step
- **Not modifying code** - This generates reports only, doesn't auto-fix issues

## Technical Approach

### File Structure
```
skills/review/SKILL.md          # New skill implementation
core/agents/reviewer.md         # Existing - use as-is
draft/tracks/<id>/review-report.md   # Track-level output
draft/review-report.md          # Project-level output
```

### Architecture
```
/draft:review
  ├─ Parse arguments (--track, --project, --files, --commits, --with-validate, --with-bughunt, --full)
  ├─ Determine scope (track vs project)
  ├─ Load context
  │  ├─ Track: spec.md + plan.md + extract commits
  │  └─ Project: CLAUDE.md + core/methodology.md
  ├─ Generate git diff (smart chunking)
  ├─ Run reviewer agent
  │  ├─ Track: Stage 1 (spec compliance) → Stage 2 (quality)
  │  └─ Project: Stage 2 only
  ├─ Optional: run /draft:validate
  ├─ Optional: run /draft:bughunt
  ├─ Aggregate findings
  └─ Write unified report
```

### Integration Points
- Reuse `core/agents/reviewer.md` (existing agent)
- Call `/draft:validate` skill as subprocess (if `--with-validate`)
- Call `/draft:bughunt` skill as subprocess (if `--with-bughunt`)
- Follow existing report format from validate/bughunt for consistency

### Fuzzy Matching Algorithm
```python
1. Exact directory match in draft/tracks/ → use immediately
2. Parse draft/tracks.md sections (split by ---)
3. For each track:
   - Extract ID (from path)
   - Extract name (from heading)
4. Match input against:
   - Exact ID match (case-insensitive)
   - Partial ID match (substring)
   - Partial name match (substring, case-insensitive)
5. If multiple matches → prompt with numbered list
6. If no matches → suggest closest 3 via Levenshtein distance
```

## Open Questions

1. **Should `--full` be the default for track-level review?**
   - Pro: Comprehensive quality check before marking track complete
   - Con: Slower, may be overkill for small changes
   - **Proposal:** Default to reviewer agent only, explicit `--full` for comprehensive

2. **How to handle review reports for tracks with existing reports?**
   - Overwrite existing report?
   - Append with timestamp?
   - Create versioned reports (review-report-1.md, review-report-2.md)?
   - **Proposal:** Overwrite with timestamp in header showing "Last reviewed: [date]"

3. **Should we validate that all plan.md tasks are `[x]` before allowing track-level review?**
   - Pro: Prevents incomplete review
   - Con: User may want to review partial work
   - **Proposal:** Warn if incomplete but allow review to proceed

4. **Integration with `/draft:status`?**
   - Should status show "Last reviewed: X days ago" for tracks?
   - **Proposal:** Yes, add review status to metadata.json and display in status
