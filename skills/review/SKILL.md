---
name: review
description: Standalone review orchestrator for track-level and project-level code review. Integrates reviewer agent, validate, and bughunt.
---

# Code Review

You are conducting a code review using Draft's Context-Driven Development methodology.

## Red Flags - STOP if you're:

- Reviewing without reading the track's spec.md and plan.md first
- Reporting findings without reading the actual code
- Skipping spec compliance stage and jumping to code quality
- Making up file locations or line numbers
- Claiming "no issues" without systematic analysis evidence

**Read before you review. Evidence over opinion.**

---

## Overview

This command orchestrates code review workflows at two levels:
- **Track-level:** Review against spec.md and plan.md (two-stage: spec compliance + code quality)
- **Project-level:** Review arbitrary changes (code quality only)

Optionally integrates `/draft:validate` and `/draft:bughunt` for comprehensive quality analysis.

---

## Step 1: Parse Arguments

Extract and validate command arguments from user input.

### Supported Arguments

**Scope specifiers (mutually exclusive):**
- `track <id|name>` - Review specific track (exact ID or fuzzy name match)
- `project` - Review uncommitted changes (`git diff HEAD`)
- `files <pattern>` - Review specific file pattern (e.g., `src/**/*.ts`)
- `commits <range>` - Review commit range (e.g., `main...HEAD`, `abc123..def456`)

**Quality integration modifiers:**
- `with-validate` - Include `/draft:validate` results
- `with-bughunt` - Include `/draft:bughunt` results
- `full` - Include both validate and bughunt (equivalent to `with-validate with-bughunt`)

### Validation Rules

1. **Scope requirement:** At least one scope specifier OR no arguments (auto-detect track)
2. **Mutual exclusivity:** Only one of `track`, `project`, `files`, `commits`
3. **Modifier normalization:** If `full` is present, enable both `with-validate` and `with-bughunt`, discarding redundant individual modifiers. No error — silently normalize.

### Default Behavior

If no arguments provided:
- Auto-detect active `[~]` In Progress track from `draft/tracks.md`
- If no `[~]` track, find first `[ ]` Pending track
- Display: `Auto-detected track: <id> - <name> [<status>]` and proceed
- If no tracks available, error: "No tracks found. Run `/draft:new-track` to create one."

---

## Step 2: Determine Review Scope

Based on parsed arguments, determine review scope and load appropriate context.

### Track-Level Review

**Trigger:** `track <id|name>` argument OR auto-detected track

#### 2.1: Resolve Track

1. **Check if argument is exact directory match:**
   ```bash
   ls draft/tracks/<arg>/ 2>/dev/null
   ```
   If exists → use this track

2. **Parse tracks.md for fuzzy matching:**
   - Read `draft/tracks.md`
   - Split by `---` separators
   - For each section, extract:
     - Track ID (from path: `./tracks/<id>/`)
     - Track name (from heading: `### <id> - <name>`)
   - Match input against:
     - Exact ID (case-insensitive)
     - Partial ID (substring)
     - Partial name (substring, case-insensitive)

3. **Handle matches:**
   - **Exact match:** Use immediately
   - **Multiple matches:** Display numbered list with format:
     ```
     Multiple tracks match '<input>':
     1. <id> - <name> [<status>]
     2. <id> - <name> [<status>]
     Select track (1-N):
     ```
     Validate selection is within 1-N range. Re-prompt on invalid input.
   - **No matches:** Error with suggestions (closest 3 by edit distance)

#### 2.2: Load Track Context

Once track is resolved:

1. **Verify track directory exists:**
   ```bash
   ls draft/tracks/<id>/ 2>/dev/null
   ```

2. **Read spec.md:**
   - Load `draft/tracks/<id>/spec.md`
   - Extract: Summary, Requirements, Acceptance Criteria, Non-Goals
   - Store for Stage 1 compliance checks

3. **Read plan.md:**
   - Load `draft/tracks/<id>/plan.md`
   - Extract commit SHAs from completed `[x]` task lines only. Match pattern: 7+ character hex strings in parentheses, regex `\(([a-f0-9]{7,})\)`. Example: `- [x] **Task 1.1:** Description (7a7dc85)`. Collect SHAs in order of appearance; deduplicate keeping first occurrence.
   - Determine commit range:
     - First commit: `git rev-parse <first_SHA>^` (parent of first)
     - Last commit: `<last_SHA>`
     - Range: `<first_SHA>^..<last_SHA>`

4. **Check for incomplete work:**
   - Parse plan.md task statuses
   - Count `[ ]`, `[~]`, `[x]`, `[!]` tasks
   - If `[ ]` or `[~]` tasks exist: Display warning and proceed:
     ```
     Warning: Track has N incomplete tasks (M in-progress, K pending). Reviewing completed work only.
     ```

5. **Handle missing files:**
   - Missing spec.md: Error "spec.md not found for track <id>"
   - Missing plan.md: Warn "plan.md not found, skipping commit extraction"
   - No commits found: Warn "No commits found in plan.md, review may be incomplete"

### Project-Level Review

**Trigger:** `project`, `files <pattern>`, or `commits <range>` argument

#### 2.3: Project Scope Detection

1. **`project` argument:**
   - Scope: Uncommitted changes
   - Command: `git diff HEAD`

2. **`files <pattern>` argument:**
   - Scope: Specific files matching glob pattern
   - Command: `git diff HEAD -- <pattern>`
   - Validate pattern matches files:
     ```bash
     git ls-files <pattern> | head -1
     ```
     If empty: Error "No files match pattern '<pattern>'"

3. **`commits <range>` argument:**
   - Scope: Commit range
   - Validate range exists:
     ```bash
     git rev-parse <range> 2>/dev/null
     ```
     If fails: Error "Invalid commit range '<range>'"
   - Command: `git diff <range>`

#### 2.4: Load Project Context

For project-level reviews (no track context):

1. **Read project guidelines:**
   - Load `CLAUDE.md` (project instructions)
   - Load `core/methodology.md` (Draft methodology)
   - Load `core/agents/reviewer.md` (review criteria)

2. **Load Draft context (if available):**
   - Read `draft/architecture.md` (system architecture)
   - Read `draft/tech-stack.md` (technical constraints, **Accepted Patterns**)
   - Read `draft/workflow.md` (**Guardrails** section)

   **Honor Accepted Patterns** - Don't flag patterns documented in `tech-stack.md` `## Accepted Patterns`
   **Enforce Guardrails** - Flag violations of checked guardrails in `workflow.md` `## Guardrails`

3. **Note limitations:**
   - No spec.md → Skip Stage 1 (spec compliance)
   - Run Stage 2 (code quality) only

---

## Step 3: Generate Git Diff (Smart Chunking)

Generate diff output using smart chunking to avoid context overflow.

### 3.1: Determine Diff Size

Run shortstat to check diff size:
```bash
git diff --shortstat <range>
```

Parse output robustly — handle both singular (`1 file changed`) and plural (`N files changed`) forms. Extract numeric values for files, insertions, and deletions. Use total lines changed (insertions + deletions) for the chunking threshold.

### 3.2: Smart Chunking Strategy

**Small/Medium changes (<300 lines changed):**
- Run full diff in one pass:
  ```bash
  git diff <range>
  ```
- Store complete diff for analysis

**Large changes (≥300 lines changed):**
- Announce: "Large changeset detected (N files). Using file-by-file review mode."
- Get file list:
  ```bash
  git diff --name-only <range>
  ```
- For each file:
  - Display progress: `[N/M] Reviewing <filename>`
  - Run: `git diff <range> -- <file>`
  - Analyze immediately (don't store all)
  - Track findings in temporary structure
- Aggregate findings after all files processed

### 3.3: Filter Files (Optional)

Skip non-source files to focus review:
- Ignore lock/minified: `*.lock`, `package-lock.json`, `yarn.lock`, `*.min.js`, `*.min.css`, `*.map`
- Ignore build artifacts: `dist/`, `build/`, `target/`, `out/`, `__pycache__/`, `*.pyc`
- Ignore vendored: `node_modules/`, `vendor/`, `.git/`
- Ignore binaries: images, fonts, compiled assets
- Ignore generated files: check first 10 lines for `@generated` marker (case-insensitive, any comment syntax: `/* @generated */`, `// @generated`, `# @generated`)

---

## Step 4: Run Reviewer Agent

Apply two-stage review process from `core/agents/reviewer.md`.

### Stage 1: Spec Compliance (Track-Level Only)

**Skip for project-level reviews (no spec exists)**

Load spec.md acceptance criteria and verify implementation:

#### 4.1: Requirements Coverage

For each functional requirement in spec.md:
- [ ] Requirement implemented (find evidence in diff)
- [ ] Files modified/created match requirement
- [ ] No missing features

#### 4.2: Acceptance Criteria

For each criterion in spec.md:
- [ ] Criterion met (check against diff)
- [ ] Test coverage exists (if TDD enabled)
- [ ] Edge cases handled

#### 4.3: Scope Adherence

- [ ] No missing features from spec
- [ ] No extra unneeded work (scope creep)
- [ ] Non-goals remain untouched

**Verdict:**
- **PASS:** All requirements implemented AND all acceptance criteria met → Proceed to Stage 2
- **FAIL:** ANY requirement missing OR ANY acceptance criterion not met → List gaps, report, and stop (no Stage 2)

### Stage 2: Code Quality

**Run for both track-level (if Stage 1 passes) and project-level reviews**

Analyze code quality across four dimensions:

#### 4.4: Architecture

- [ ] Follows project patterns (from tech-stack.md or CLAUDE.md)
- [ ] Appropriate separation of concerns
- [ ] No unnecessary complexity
- [ ] Module boundaries respected (if architecture.md exists)

#### 4.5: Error Handling

- [ ] Errors handled at appropriate level
- [ ] User-facing errors are helpful
- [ ] System errors are logged
- [ ] No silent failures

#### 4.6: Testing

- [ ] Tests test real logic (not implementation details)
- [ ] Edge cases have test coverage
- [ ] Tests are maintainable
- [ ] No brittle assertions

#### 4.7: Maintainability

- [ ] Code is readable without excessive comments
- [ ] No obvious performance issues
- [ ] No security vulnerabilities (SQL injection, XSS, hardcoded secrets)
- [ ] Consistent naming and style

### Issue Classification

Classify all findings by severity:

| Severity | Definition | Action |
|----------|------------|--------|
| **Critical** | Blocks release, breaks functionality, security issue | Must fix before proceeding |
| **Important** | Degrades quality, technical debt | Should fix before phase complete |
| **Minor** | Style, optimization, nice-to-have | Note for later, don't block |

**Issue format:**
```markdown
- [ ] [File:line] Description of issue
  - **Impact:** [what breaks/degrades]
  - **Suggested fix:** [how to address]
```

---

## Step 5: Run Quality Tools (Optional)

If `with-validate`, `with-bughunt`, or `full` modifier set, integrate additional quality checks.

### 5.1: Run Validate

If `with-validate` or `full`:

**Track-level:**
```bash
/draft:validate <id>
```

**Project-level:**
```bash
/draft:validate
```

Parse output from `draft/tracks/<id>/validation-report.md` or `draft/validation-report.md`

### 5.2: Run Bughunt

If `with-bughunt` or `full`:

**Track-level:**
```bash
/draft:bughunt <id>
```

**Project-level:**
```bash
/draft:bughunt
```

Parse output from `draft/tracks/<id>/bughunt-report.md` or `draft/bughunt-report.md`

### 5.3: Aggregate Findings

Merge findings from:
1. Reviewer agent (Stage 1 + Stage 2)
2. Validate results (if run)
3. Bughunt results (if run)

**Deduplication:**
- Two findings are duplicates if they reference the **same file and line number**
- Severity ordering: **Critical > Important > Minor**
- On duplicate: keep the finding with highest severity; merge tool attribution as "Found by: reviewer, bughunt"
- If same severity from different tools: merge into single finding, combine descriptions

---

## Step 6: Generate Review Report

Create unified review report in markdown format.

### Track-Level Report

**Path:** `draft/tracks/<id>/review-report.md`

```markdown
# Review Report: <Track Title>

**Track ID:** <id>
**Reviewed:** <ISO timestamp>
**Reviewer:** [Current model name and context window from runtime]
**Commit Range:** <first_SHA>^..<last_SHA>
**Diff Stats:** N files changed, M insertions(+), K deletions(-)

---

## Stage 1: Spec Compliance

**Status:** PASS / FAIL

### Requirements Coverage
- [x] Requirement 1 - Implemented in <file:line>
- [x] Requirement 2 - Implemented in <file:line>
- [ ] Requirement 3 - **MISSING**

### Acceptance Criteria
- [x] Criterion 1 - Verified in <file:line>
- [x] Criterion 2 - Verified in <file:line>
- [ ] Criterion 3 - **NOT MET**

[If FAIL: List gaps and stop here]

---

## Stage 2: Code Quality

**Status:** PASS / PASS WITH NOTES / FAIL

### Critical Issues
[None / List with file:line]

### Important Issues
[None / List with file:line]

### Minor Notes
[None / List items]

---

## Additional Quality Checks

[If with-validate or full]
### Validation Results
- **Architecture Conformance:** PASS/FAIL
- **Security Scan:** N issues found
- **Performance:** N anti-patterns detected
- Full report: `./validation-report.md`

[If with-bughunt or full]
### Bug Hunt Results
- **Critical bugs:** N found
- **High severity:** N found
- **Medium severity:** N found
- Full report: `./bughunt-report.md`

---

## Summary

**Total Issues:** N
- Critical: N
- Important: N
- Minor: N

**Verdict:** PASS / PASS WITH NOTES / FAIL

**Required Actions:**
1. [Action item if any]
2. [Action item if any]

---

## Recommendations

[If incomplete tasks found]
⚠️  **Warning:** This track has N incomplete tasks. Consider completing all tasks before marking track as done.

[If no critical issues]
✅ **No blocking issues found.** This track is ready to merge.

[If critical issues found]
❌ **Critical issues must be resolved before proceeding.**
```

### Project-Level Report

**Path:** `draft/review-report.md` (all project-level scopes write to this same path)

Similar format but:
- No Stage 1 section (no spec compliance)
- Header shows scope instead of track ID:
  - `project`: "Scope: Uncommitted changes"
  - `files <pattern>`: "Scope: Files matching '<pattern>'"
  - `commits <range>`: "Scope: Commits <range>"
- Each run overwrites the previous report; include "Previous review: <timestamp>" if prior report exists

### Report Overwrite Behavior

If report already exists:
1. Read existing report timestamp
2. Overwrite file
3. Include note: "Previous review: <date>"

---

## Step 7: Update Metadata (Track-Level Only)

For track-level reviews, update metadata.json with review status.

**Condition:** Always update metadata after generating the review report, regardless of verdict. This ensures review history is tracked for all outcomes (PASS, PASS_WITH_NOTES, or FAIL).

### 7.1: Read Current Metadata

Load `draft/tracks/<id>/metadata.json`

### 7.2: Add Review Fields

```json
{
  "id": "<track_id>",
  ...
  "lastReviewed": "<ISO timestamp>",
  "reviewCount": N,
  "lastReviewVerdict": "PASS" | "PASS_WITH_NOTES" | "FAIL"
}
```

Increment `reviewCount` on each review.

### 7.3: Write Updated Metadata

Save updated metadata.json

---

## Step 8: Present Results

Display summary to user with actionable next steps.

### Success Output

```
✅ Review complete: <track_id>

Report: draft/tracks/<id>/review-report.md

Summary:
- Stage 1 (Spec Compliance): PASS
- Stage 2 (Code Quality): PASS WITH NOTES
- Total issues: 12 (0 Critical, 3 Important, 9 Minor)

[If full]
Additional Checks:
- Validation: 2 warnings
- Bug Hunt: 5 medium-severity findings

Verdict: PASS WITH NOTES

Recommended actions:
1. Fix 3 Important issues (see report)
2. Review 9 Minor notes for future improvements

Next: Address findings and run /draft:review again, or mark track complete.
```

### Failure Output

```
❌ Review failed: <track_id>

Report: draft/tracks/<id>/review-report.md

Stage 1 (Spec Compliance): FAIL
- 3 requirements not implemented
- 2 acceptance criteria not met

Stage 2: SKIPPED (Stage 1 must pass first)

Verdict: FAIL

Required actions:
1. Implement missing requirements (see report)
2. Meet all acceptance criteria
3. Run /draft:implement to resume work

Next: Fix gaps and run /draft:review again.
```

---

## Error Handling

### Missing Draft Directory

```
Error: Draft not initialized.
Run /draft:init to set up Context-Driven Development.
```

### No Tracks Found

```
Error: No tracks found in draft/tracks.md
Run /draft:new-track to create your first track.
```

### Track Not Found

```
Error: Track 'xyz' not found.

Did you mean:
1. add-review-command
2. enterprise-readiness

Use exact track ID or run /draft:status to see all tracks.
```

### Ambiguous Match

```
Multiple tracks match 'review':
1. add-review-command - Add /draft:review Command [~]
2. review-architecture-md - Review architecture.md [x]

Select track (1-2):
```

### Invalid Git Range

```
Error: Invalid commit range 'main...feature'
Git error: fatal: ambiguous argument 'feature': unknown revision

Verify the range exists:
  git log main...feature
```

### Missing Commits in Plan

```
⚠️  Warning: No commit SHAs found in plan.md

Cannot determine commit range for review.

Options:
1. Manually specify range: /draft:review track <id> commits <range>
2. Review uncommitted changes: /draft:review project
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Skip Stage 1 for track reviews | Always verify spec compliance first |
| Run Stage 2 when Stage 1 fails | Fix spec gaps before quality checks |
| Ignore incomplete tasks | Warn user, suggest completing work first |
| Auto-fix issues found | Report only, let developer decide |
| Batch multiple tracks | Review one track at a time |

---

## Examples

### Review active track
```bash
/draft:review
```

### Review specific track by ID
```bash
/draft:review track add-user-auth
```

### Review specific track by name (fuzzy)
```bash
/draft:review track "user authentication"
```

### Comprehensive track review
```bash
/draft:review track add-user-auth full
```

### Review uncommitted changes
```bash
/draft:review project
```

### Review specific files
```bash
/draft:review files "src/**/*.ts"
```

### Review commit range
```bash
/draft:review commits main...feature-branch
```

### Review with validation only
```bash
/draft:review track my-feature with-validate
```
