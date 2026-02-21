---
name: deep-review
description: Perform an exhaustive end-to-end lifecycle review of a service, component, or module. Evaluates ACID compliance, architectural resilience, and production-grade enterprise quality.
---

# Deep Review — Production-Grade Module Audit

Perform an exhaustive end-to-end lifecycle review of a service, component, or module. Ensure ACID compliance and production-grade enterprise quality. Unlike standard review commands, this operates strictly at the module level.

## Red Flags - STOP if you're:

- Acting without reading the Draft context (`draft/product.md`, `draft/tech-stack.md`)
- Modifying production code. This command is for auditing and reporting only. Fixes should be handled in a separate implementation track.
- Reviewing a module that was already reviewed recently, unless explicitly requested.

---

## Arguments

- `$ARGUMENTS` — Optional: explicit module/service/component name (directory) to review. If omitted, auto-select the next unreviewed module.

---

## Module Selection

1. **Check review history:** Read `draft/deep-review-history.json` if it exists. This file tracks previously reviewed modules with timestamps.
2. **If `$ARGUMENTS` is provided:** Use that module. If it was previously reviewed, re-review it (the user explicitly requested it).
3. **If no argument:** Discover all modules using the following priority order:
   1. Use module definitions from `draft/.ai-context.md` if it exists (check `## Modules` or `## Module Catalog` sections).
   2. Use top-level directories under `src/` or equivalent source root.
   3. Use directories containing `__init__.py`, `package.json`, or `go.mod`.
   Document which heuristic was used in the report.
   Select the first module NOT present in the review history. If all have been reviewed, pick the one with the oldest review date.
4. **Announce selection:** State which module was selected and why before proceeding.

---

## Review Phases

### Phase 1: Context & Structural Analysis
- Read all Draft context files (e.g. `draft/.ai-context.md`, `draft/architecture.md`, `draft/tech-stack.md`) to understand intended boundaries and critical invariants.
- Map the module's full dependency graph (imports, injected services, external calls)
- Trace the complete lifecycle: initialization → processing → persistence → cleanup
- Identify all entry points and exit paths
- Catalog all state mutations and side effects

### Phase 2: ACID Compliance Audit
- **Atomicity:** Verify all multi-step operations are wrapped in transactions. Partial failure must not leave corrupt state. Check for missing rollback paths.
- **Consistency:** Validate all invariants, constraints, and business rules are enforced before and after every state transition. Check schema validation, data type enforcement, and boundary conditions.
- **Isolation:** Check for race conditions, shared mutable state, concurrent access without locking/synchronization. Verify transaction isolation levels where databases are involved.
- **Durability:** Confirm committed data survives crashes. Check for fire-and-forget patterns, missing flush/sync calls, and inadequate error handling around persistence.

### Phase 3: Production-Grade Assessment

**Applicability note:** Skip categories that are not applicable to the module type (e.g., circuit breakers and backpressure are backend-specific; skip for frontend/CLI modules).

- **Resilience:** Graceful degradation, circuit breakers, timeout handling, backpressure
- **Observability:** Logging coverage (not excessive), structured log fields, correlation IDs, metric emission points
- **Configuration:** Hardcoded values that should be configurable, missing environment variable validation
- **State Lifecycle:** Memory accumulation, zombie processes, dropped messages

### Phase 4: Identify Actionable Fixes (Spec Generation)
Instead of mutating the source code, translate all findings into clear, actionable requirements that a developer (or agent) can implement via Test-Driven Development.

---

## Update Review History

After completing the review, update `draft/deep-review-history.json`:

```json
{
  "reviews": [
    {
      "module": "<module-name>",
      "path": "<module-path>",
      "timestamp": "<ISO-8601>",
      "issues_found": <count>,
      "summary": "<one-line summary>"
    }
  ]
}
```

Create the file in the `draft/` directory if it does not exist. Append to the `reviews` array if it does. Do NOT save to `.claude/` or `.gemini/`.

---

## Final Report Generation

Output a structured summary and detailed "Implementation Spec" for any needed fixes.

**File to create:** `draft/deep-review-reports/<module-name>.md`

Create the `draft/deep-review-reports/` directory if it does not exist.

**MANDATORY: Include YAML frontmatter with git metadata.** Gather git info first:

```bash
git branch --show-current                    # LOCAL_BRANCH
git rev-parse HEAD                           # FULL_SHA
git rev-parse --short HEAD                   # SHORT_SHA
git log -1 --format=%ci HEAD                 # COMMIT_DATE
```

Report template:

```markdown
---
module: "<module-name>"
module_path: "<module-path>"
generated_by: "draft:deep-review"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
reviewer: "{model name from runtime}"
---
```

**Module reviewed:** name and path
**Issues by category:** ACID | Resilience | Observability
**Verdict:** PASS / CONDITIONAL PASS / FAIL

**Verdict criteria:**
- **FAIL** = any Critical issue found.
- **CONDITIONAL PASS** = no Critical issues but Important issues exist.
- **PASS** = only Minor issues or no issues.

Format findings as actionable tasks:
```markdown
### [Critical/Important/Minor] Issue Name
**File:** path/to/file:line
**Description:** What's wrong conceptually (e.g., Transaction lacks rollback on Exception XYZ).
**Proposed Fix Specification:**
- Add `try/except` block catching Exception XYZ.
- Explicitly call `db.rollback()`.
- Emit structured log with correlation ID.
```

**Constraints:**
- Do not refactor code yourself.
- Flag ambiguous fixes for human review instead of guessing.
- If the module is too large, decompose it and review sub-modules sequentially.
