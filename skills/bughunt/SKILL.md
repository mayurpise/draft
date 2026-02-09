---
name: bughunt
description: Exhaustive bug hunt using Draft context (architecture, tech-stack, product). Generates severity-ranked report with fixes.
---

# Bug Hunt

You are conducting an exhaustive bug hunt on this Git repository, enhanced by Draft context when available.

## Red Flags - STOP if you're:

- Hunting for bugs without reading Draft context first (architecture.md, tech-stack.md, product.md)
- Reporting a finding without reproducing or tracing the code path
- Fixing bugs instead of reporting them (bughunt reports, it doesn't fix)
- Assuming a pattern is buggy without checking if it's used successfully elsewhere
- Skipping the verification protocol (every bug needs evidence)
- Making up file locations or line numbers without reading the actual code
- Reporting framework-handled concerns as bugs without checking the docs

**Verify before you report. Evidence over assumptions.**

---

## Pre-Check

### 0. Capture Git Context

Before starting analysis, capture the current git state:

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

Store this for the report header. All bugs found are relative to this specific branch/commit.

### 1. Load Draft Context (if available)

If `draft/` directory exists, read and internalize:

- [ ] `draft/architecture.md` - Module boundaries, dependencies, intended patterns
- [ ] `draft/tech-stack.md` - Frameworks, libraries, known constraints
- [ ] `draft/product.md` - Product intent, user flows, requirements
- [ ] `draft/workflow.md` - Team conventions, testing preferences

Use this context to:
- Flag violations of intended architecture as bugs (coupling, boundary violations)
- Apply framework-specific checks from tech-stack (React anti-patterns, Node gotchas, etc.)
- Catch bugs that violate product requirements or user flows
- Prioritize areas relevant to active tracks

### 2. Confirm Scope

Ask user to confirm scope:
- **Entire repo** - Full codebase analysis
- **Specific paths** - Target directories or files
- **Track-level** (specify `<track-id>`) - Focus on files relevant to a specific track

### 3. Load Track Context (if track-level)

If running for a specific track, also load:
- [ ] `draft/tracks/<id>/spec.md` - Requirements, acceptance criteria, edge cases
- [ ] `draft/tracks/<id>/plan.md` - Implementation tasks, phases, dependencies

Use track context to:
- Verify implemented features match spec requirements
- Check edge cases listed in spec are handled
- Identify bugs in areas touched by the track's plan
- Focus analysis on files modified/created by the track

If no Draft context exists, proceed with code-only analysis.

## Dimension Applicability Check

Before analyzing all 12 dimensions, determine which apply to this codebase:

- **Skip explicitly** rather than forcing analysis of N/A dimensions
- **Mark skipped dimensions** with reason in report summary

**Examples of skipping:**
- "N/A - no backend code" (skip dimensions 2, 8, 10 for frontend-only repo)
- "N/A - no UI components" (skip dimensions 5, 9 for CLI tool)
- "N/A - no database" (skip dimension 2 for in-memory app)
- "N/A - no external integrations" (skip dimension 8)

## Analysis Dimensions

Analyze systematically across all applicable dimensions. Skip N/A dimensions explicitly (see Dimension Applicability Check above).

### 1. Correctness
- Logical errors, invalid assumptions, edge cases
- Incorrect state transitions, stale or inconsistent UI state
- Error handling gaps, silent failures
- Off-by-one errors, boundary conditions

### 2. Reliability & Resilience
- Crash paths, unhandled exceptions
- Reload/refresh behavior, retry logic
- UI behavior on partial backend failure
- Broken recovery after errors, navigation

### 3. Security
- XSS, injection vectors, unsafe rendering
- Client-side trust assumptions
- Secrets, tokens, auth data exposure
- CSRF, insecure deserialization
- Path traversal, command injection

### 4. Performance (Backend + UI)
- Inefficient algorithms and data fetching
- N+1 queries, over-fetching, chatty APIs
- Blocking work on main/UI thread
- Excessive re-renders, unnecessary state updates
- Large bundles, unused code, slow startup paths
- Unbounded memory growth (listeners, caches, stores)

### 5. UI Responsiveness & Perceived Performance
- Long tasks blocking input
- Jank during scrolling, typing, resizing
- Layout thrashing, forced reflows
- Expensive animations or transitions
- Poor loading states, flicker, content shifts

### 6. Concurrency & Ordering
- Race conditions between async calls
- Stale responses overwriting newer state
- Incorrect cancellation or debouncing
- Event ordering assumptions
- Deadlocks, livelocks

### 7. State Management
- Source-of-truth violations
- Derived state bugs (computed from stale data)
- Global state misuse
- Memory leaks from subscriptions or observers
- Inconsistent state across components

### 8. API & Contracts
- UI assumptions not guaranteed by backend
- Schema drift, weak typing, missing validation
- Backward compatibility risks
- Undocumented API behavior dependencies

### 9. Accessibility & UX Correctness
- Keyboard navigation gaps
- Focus management bugs
- ARIA misuse or absence
- Broken tab order or unreadable states
- UI behavior that contradicts user intent
- Color contrast, screen reader compatibility

### 10. Configuration & Build
- Fragile environment assumptions
- Build-time vs runtime config leaks
- Dev-only code shipping to prod
- Missing environment variable validation
- CI gaps affecting builds or tests

### 11. Tests
- Missing coverage for critical flows
- Snapshot misuse (testing implementation, not behavior)
- Tests that assert implementation instead of behavior
- Mismatch between test and real user interaction
- Flaky tests, timing dependencies

### 12. Maintainability
- Dead code, unused exports, orphaned files
- Over-abstracted hooks/components
- Tight coupling between layers
- Refactoring hazards (implicit dependencies)
- Inconsistent naming, patterns

## Bug Verification Protocol

**CRITICAL: No bug is valid without verification.** Before declaring any finding as a bug, complete ALL applicable verification steps:

### Verification Checklist (for each potential bug)

1. **Code Path Verification**
   - [ ] Read the actual code at the suspected location
   - [ ] Trace the data flow from input to the bug location
   - [ ] Check if there are guards, validators, or error handlers upstream
   - [ ] Verify the code path is actually reachable in production

2. **Context Cross-Reference**
   - [ ] Check `architecture.md` — Is this behavior intentional by design?
   - [ ] Check `tech-stack.md` — Does the framework handle this case?
   - [ ] Check `product.md` — Is this actually a requirement violation?
   - [ ] Check existing tests — Is this behavior already tested and expected?

3. **Framework/Library Verification**
   - [ ] Read official docs for the specific method/pattern in question
   - [ ] Quote relevant doc section proving this is/isn't handled
   - [ ] Check framework version in tech-stack.md (behavior may vary by version)
   - [ ] Look for middleware, interceptors, or global handlers that may address the issue

**Example Framework Documentation Quote:**
"React automatically escapes JSX content to prevent XSS (React Docs: Main Concepts > JSX). However, `dangerouslySetInnerHTML` bypasses this protection. Framework version: React 18.2.0 (from tech-stack.md)."

4. **Codebase Pattern Check**
   - [ ] Search for similar patterns elsewhere in codebase
   - [ ] If pattern is used consistently, verify it's actually buggy (not just unfamiliar)
   - [ ] Check if there's a project-specific utility/wrapper that handles the concern

5. **False Positive Elimination**
   - [ ] Is this dead code that's never executed?
   - [ ] Is this test/mock/stub code not in production?
   - [ ] Is this intentionally disabled (feature flag, config)?
   - [ ] Is there a comment explaining why this appears unsafe but is actually safe?

6. **Pattern Prevalence Check (before reporting)**
   - [ ] Run Grep to find all occurrences of the pattern
   - [ ] If found >5x:
     - Randomly sample 3 instances
     - Verify they exhibit the same suspected bug
     - If they work correctly, investigate: what's different about THIS instance?
   - [ ] If no difference found and other instances work: DO NOT REPORT
   - [ ] If all instances have the bug: Report with pattern count in "Impact"

**Example Pattern Prevalence Check:**
```
1. Grep: `rg 'dangerouslySetInnerHTML' src/` → found 12 occurrences
2. Sampled 3: src/Blog.tsx:45, src/About.tsx:12, src/FAQ.tsx:30
3. All 3 sanitize input via `DOMPurify.sanitize()` before rendering
4. THIS instance (src/Comment.tsx:88) passes raw user input without sanitization
5. Decision: REPORT — this instance lacks the sanitization all others have
```

### Confidence Levels

Only report bugs with HIGH or CONFIRMED confidence:

| Level | Criteria | Action |
|-------|----------|--------|
| **CONFIRMED** | Verified through code trace, no mitigating factors found | Report as bug |
| **HIGH** | Strong evidence, checked context, no obvious mitigation | Report as bug |
| **MEDIUM** | Suspicious but couldn't verify all factors | Use AskUserQuestion to check with user before reporting |
| **LOW** | Possible issue but likely handled elsewhere | Do NOT report |

**Example AskUserQuestion for MEDIUM Confidence:**
"I found a potential race condition in `src/handler.ts:45` where async state updates may overwrite each other. However, I couldn't verify if there's a locking mechanism elsewhere. Should I report this as a bug?"

### Evidence Requirements

Each reported bug MUST include:
- **Code Evidence:** The actual problematic code snippet
- **Trace:** How data reaches this point (caller chain or data flow)
- **Verification Done:** Which checks from the checklist were completed
- **Why Not a False Positive:** Explicit statement of why this isn't handled elsewhere

## Analysis Rules

- **Do not execute code** - Reason from source only
- **Do not assume frameworks "handle it"** - Verify explicitly by checking docs/code
- **Do not assume code is buggy** - Verify it's actually reachable and unguarded
- **Trace data flow completely** - From input source to bug location
- **Cross-reference ALL Draft context** - Check architecture, tech-stack, product, tests
- **Check for existing mitigations** - Middleware, wrappers, utilities, global handlers
- **Search for patterns** - If used elsewhere without issues, investigate why

## Optional: Runtime Verification (if test suite exists)

For suspected bugs that can be tested, write a minimal failing test to confirm:

1. **Write minimal test** — Target the specific bug, not the entire feature
2. **Run test** — Execute and observe failure
3. **Confirm bug** — If test fails as predicted, confidence level increases to CONFIRMED
4. **Only report if**: Test fails OR CONFIRMED confidence from code trace

**Example:**
```javascript
// Suspected bug: off-by-one in pagination
test('should handle last page boundary', () => {
  const items = Array(100).fill('item');
  const result = paginate(items, { page: 10, perPage: 10 });
  expect(result.items.length).toBe(10); // Currently returns 9
});
```

If test fails, upgrade confidence to CONFIRMED and include test in bug report.

## Output Format

For each verified bug:

```markdown
### [SEVERITY] Category: Brief Title

**Location:** `path/to/file.ts:123`
**Confidence:** [CONFIRMED | HIGH | MEDIUM]

**Code Evidence:**
```[language]
// The actual problematic code
```

**Data Flow Trace:**
[How data reaches this point: caller → caller → this function]

**Issue:** [Precise technical description of what is wrong]

**Impact:** [User-visible effect or system failure mode]

**Verification Done:**
- [x] Traced code path from [entry point]
- [x] Checked architecture.md — not intentional
- [x] Verified framework doesn't handle this
- [x] No upstream guards found in [files checked]

**Why Not a False Positive:**
[Explicit statement: "No sanitization exists because X", "Framework Y doesn't escape Z in this context", etc.]

**Fix:** [Minimal code change or mitigation]

**Regression Test:** [Test case that would fail due to this bug, or "N/A - not testable without [reason]"]
```

**Example Regression Test Field:**
```javascript
**Regression Test:**
test('should sanitize user input', () => {
  const malicious = '<script>alert("xss")</script>';
  const result = processInput(malicious);
  expect(result).not.toContain('<script>');
});
// Expected: Test fails (currently would pass, allowing XSS)
```

Severity levels:
- **CRITICAL** - Data loss, security vulnerability, crashes in production
- **HIGH** - Incorrect behavior affecting users, significant performance issues
- **MEDIUM** - Edge case bugs, minor UX issues, code quality concerns
- **LOW** - Maintainability issues, minor inconsistencies, cleanup opportunities

## Report Generation

Generate report at:
- **Project-level:** `draft/bughunt-report.md`
- **Track-level:** `draft/tracks/<track-id>/bughunt-report.md` (if analyzing specific track)

Report structure:

```markdown
# Bug Hunt Report

**Branch:** `[branch-name]`
**Commit:** `[short-hash]`
**Date:** YYYY-MM-DD HH:MM
**Scope:** [Entire repo | Specific paths | Track: <track-id>]
**Draft Context:** [Loaded | Not available]

## Summary

| Severity | Count | Confirmed | High Confidence |
|----------|-------|-----------|-----------------|
| Critical | N | X | Y |
| High | N | X | Y |
| Medium | N | X | Y |
| Low | N | X | Y |

## Critical Issues

[Issues...]

## High Issues

[Issues...]

## Medium Issues

[Issues...]

## Low Issues

[Issues...]

## Dimensions With No Findings

| Dimension | Status |
|-----------|--------|
| Correctness | No bugs found |
| Reliability | N/A — no runtime application |
| Performance | N/A — static site, no dynamic content |
| Concurrency | N/A — no async operations |
```

## Final Instructions

- **No unverified bugs** — Every finding must pass the verification protocol
- **Evidence required** — Include code snippets and trace for every bug
- **Explicit false positive elimination** — State why each bug isn't handled elsewhere
- Analyze all applicable dimensions — skip N/A dimensions explicitly with reason (see Dimension Applicability Check)
- Assume the reader is a senior engineer who will verify your findings
- If Draft context is available, explicitly note which architectural violations or product requirement bugs were found
- Be precise about file locations and line numbers
- Include git branch and commit in report header
