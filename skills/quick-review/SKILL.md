---
name: quick-review
description: Lightweight ad-hoc code review for a PR, diff, or file. Four dimensions — security, performance, correctness, maintainability. No track context required.
---

# Quick Review

You are conducting a lightweight, ad-hoc code review using Draft's Context-Driven Development methodology. This is a fast, focused review that does not require track context.

## Red Flags - STOP if you're:

- Reviewing without actually reading the code (skimming headers only)
- Making up file locations or line numbers
- Reporting findings without checking if the pattern is used successfully elsewhere
- Treating this as a full `/draft:review` (this is intentionally lightweight)
- Skipping the severity classification for findings

**Read the code. Evidence over opinion. Fast but thorough.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context (Optional)

```bash
ls draft/ 2>/dev/null
```

If `draft/` exists, load lightweight context:
- Read `draft/.ai-context.md` (or `draft/architecture.md`) for architecture patterns
- Read `draft/tech-stack.md` for framework conventions
- Read `draft/guardrails.md` for known conventions and anti-patterns

Quick review works without Draft context — it just won't have project-specific pattern awareness.

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:quick-review` | Review staged changes (`git diff --cached`), falls back to unstaged (`git diff`) |
| `/draft:quick-review <file>` | Review a specific file |
| `/draft:quick-review <file1> <file2> ...` | Review multiple specific files |
| `/draft:quick-review pr <number>` | Review a pull request (via `gh pr diff <number>`) |
| `/draft:quick-review pr <url>` | Review a pull request by URL |
| `/draft:quick-review commits <range>` | Review a commit range |

### Argument Resolution

1. **No arguments:**
   - Try `git diff --cached` (staged changes)
   - If empty, try `git diff` (unstaged changes)
   - If empty: "No changes to review. Specify a file, PR, or commit range."

2. **File path(s):**
   - Verify file(s) exist
   - Read full file content for each
   - If file doesn't exist: "File not found: [path]"

3. **PR number or URL:**
   - Extract PR number from URL if needed
   - Fetch diff: `gh pr diff <number>`
   - If `gh` not available: "GitHub CLI not available. Install `gh` or provide a diff directly."

4. **Commit range:**
   - Validate range: `git rev-parse <range> 2>/dev/null`
   - Fetch diff: `git diff <range>`
   - If invalid: "Invalid commit range: [range]"

---

## Step 2: Analyze

Review the code across four dimensions. For each dimension, scan the entire diff or file content.

### Dimension 1: Security

- [ ] No hardcoded secrets, API keys, tokens, or passwords
- [ ] Input validation present for user-supplied data
- [ ] SQL injection protection (parameterized queries, no string concatenation)
- [ ] XSS protection (no raw HTML insertion, proper escaping)
- [ ] Authentication/authorization checks in place for protected operations
- [ ] No sensitive data in logs or error messages
- [ ] Secure random generation (no `Math.random()` for security-sensitive operations)
- [ ] CSRF protection for state-changing endpoints

### Dimension 2: Performance

- [ ] No N+1 query patterns (loops containing database queries)
- [ ] No unbounded queries (missing LIMIT/pagination)
- [ ] No blocking I/O in async contexts
- [ ] No unnecessary memory allocations in hot paths
- [ ] Appropriate caching for expensive operations
- [ ] No excessive logging in hot paths
- [ ] Resource cleanup (connections, file handles, streams) in finally/defer blocks

### Dimension 3: Correctness

- [ ] Logic matches apparent intent (variable names, comments, context)
- [ ] Edge cases handled (null, empty, zero, negative, max values)
- [ ] Error handling present and appropriate (not swallowed, not overly broad)
- [ ] Boundary conditions correct (off-by-one, inclusive/exclusive ranges)
- [ ] Concurrency safety (shared state protected, no race conditions)
- [ ] Type safety (no unsafe casts, proper null checks)
- [ ] Return values checked (no ignored errors, no unchecked promises)

### Dimension 4: Maintainability

- [ ] Code is readable without excessive comments
- [ ] Naming is clear and consistent with project conventions
- [ ] Functions are focused (single responsibility, reasonable length)
- [ ] No code duplication that should be extracted
- [ ] Appropriate abstraction level (not over-engineered, not under-abstracted)
- [ ] Test coverage considerations (is this testable? are tests included?)
- [ ] No TODO/FIXME/HACK without tracking reference

---

## Step 3: Classify Findings

For each finding, classify severity:

| Severity | Symbol | Definition | Action Required |
|----------|--------|------------|-----------------|
| **Critical** | `[C]` | Security vulnerability, data loss risk, crash | Must fix before merge |
| **Important** | `[I]` | Bug, performance issue, missing validation | Should fix before merge |
| **Suggestion** | `[S]` | Style, readability, minor improvement | Consider for future |

### Finding Format

```markdown
- [C] **[File:line]** [Title]
  Description of the issue.
  **Impact:** [what could go wrong]
  **Fix:** [suggested resolution]

- [I] **[File:line]** [Title]
  Description of the issue.
  **Impact:** [what could go wrong]
  **Fix:** [suggested resolution]

- [S] **[File:line]** [Title]
  Description of the suggestion.
  **Suggestion:** [what to improve]
```

---

## Step 4: Generate Review Report

Present findings in a structured format.

### Review Output

```markdown
# Quick Review

**Scope:** [staged changes / file(s) / PR #N / commits range]
**Files reviewed:** [N]
**Lines reviewed:** [N additions, M deletions]
**Branch:** [branch name]
**Commit:** [short SHA]

---

## Findings

### Critical ([N])

[Critical findings or "None"]

### Important ([N])

[Important findings or "None"]

### Suggestions ([N])

[Suggestion findings or "None"]

---

## Summary

| Dimension | Status |
|-----------|--------|
| Security | PASS / [N] issues |
| Performance | PASS / [N] issues |
| Correctness | PASS / [N] issues |
| Maintainability | PASS / [N] issues |

**Verdict:** PASS / PASS WITH NOTES / NEEDS CHANGES

**Total findings:** [N] ([C] critical, [I] important, [S] suggestions)
```

### Verdict Logic

- **PASS:** Zero Critical, Zero Important findings
- **PASS WITH NOTES:** Zero Critical, has Important or Suggestion findings
- **NEEDS CHANGES:** Any Critical finding present

---

## Step 5: Present Results

Display the review in the conversation. Optionally save if requested.

```
Quick review complete.

Scope: [description]
Verdict: [PASS / PASS WITH NOTES / NEEDS CHANGES]
Findings: [N] total ([C] critical, [I] important, [S] suggestions)

[If NEEDS CHANGES:]
Critical issues must be resolved before merge.

[If PASS WITH NOTES:]
No blocking issues. Consider addressing important findings.

[If PASS:]
No issues found. Code looks good.
```

### Save Option

If developer requests saving the review:
- Save to `draft/quick-review-<timestamp>.md` (where `<timestamp>` is generated via `date +%Y-%m-%dT%H%M`)
- Include YAML frontmatter per `core/shared/git-report-metadata.md` with `generated_by: "draft:quick-review"`
  ```bash
  ln -sf quick-review-<timestamp>.md draft/quick-review-latest.md
  ```

---

## Cross-Skill Dispatch

### Inbound

- **Offered by `/draft:implement`** — quick review of changes before commit
- **Standalone** — used for ad-hoc reviews outside of track workflow

### Outbound

- **Escalates to `/draft:review`** — if findings suggest a deeper review is needed (e.g., many Critical findings, architectural concerns)
- **Feeds `/draft:learn`** — recurring findings across quick reviews indicate patterns worth learning

---

## Differences from `/draft:review`

| Aspect | `/draft:quick-review` | `/draft:review` |
|--------|----------------------|-----------------|
| Track context | Not required | Required (or project scope) |
| Spec compliance | Not checked | Three-stage (validation, spec, quality) |
| Depth | 4 dimensions, surface scan | Deep analysis with adversarial pass |
| Bughunt integration | No | Optional (with-bughunt) |
| Report persistence | Optional (on request) | Always saved |
| Time | Fast (~2 minutes) | Thorough (~10+ minutes) |
| Use case | Quick check before commit/merge | Formal review before track completion |

---

## Error Handling

### No Changes Found

```
No changes to review.

Options:
1. Specify a file: /draft:quick-review src/auth/handler.ts
2. Specify a PR: /draft:quick-review pr 42
3. Specify a commit range: /draft:quick-review commits main...HEAD
```

### PR Not Found

```
PR #[N] not found or not accessible.

Verify:
- PR number is correct
- You have access to the repository
- GitHub CLI (gh) is authenticated: gh auth status
```

### Large Diff Warning

If diff exceeds 500 lines:
```
Large diff detected ([N] lines). Quick review is designed for smaller changes.

Options:
1. Proceed with quick review (may miss context-dependent issues)
2. Use /draft:review for a thorough analysis
3. Specify a subset: /draft:quick-review <specific files>
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Report without reading the code | Read every changed line |
| Treat as a replacement for /draft:review | Use for quick checks, escalate when needed |
| Make up line numbers | Reference actual code locations |
| Report framework conventions as issues | Check tech-stack.md for accepted patterns |
| Block on style-only findings | Classify as Suggestion, not Critical |

---

## Examples

### Review staged changes
```bash
/draft:quick-review
```

### Review a specific file
```bash
/draft:quick-review src/auth/middleware.ts
```

### Review a pull request
```bash
/draft:quick-review pr 42
```

### Review a commit range
```bash
/draft:quick-review commits main...feature-branch
```

### Review multiple files
```bash
/draft:quick-review src/auth/handler.ts src/auth/types.ts
```
