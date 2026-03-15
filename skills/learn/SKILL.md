---
name: learn
description: Scan codebase to discover coding patterns and update draft/guardrails.md. Learns conventions (skip in future) and anti-patterns (always flag). Supports migration from workflow.md and pattern promotion.
---

# Learn — Pattern Discovery & Guardrails Update

Scan the codebase to discover recurring coding patterns and update `draft/guardrails.md` with learned conventions and anti-patterns. This improves future quality command accuracy by reducing false positives and catching known-bad patterns.

## Red Flags - STOP if you're:

- Writing to guardrails.md without reading the codebase first
- Learning a pattern from fewer than 3 occurrences
- Auto-promoting patterns to Hard Guardrails (requires human approval)
- Overwriting human-curated Hard Guardrails with learned patterns
- Learning patterns that contradict `tech-stack.md ## Accepted Patterns`
- Removing existing learned entries (only update or add)

**Evidence over assumptions. Quantity over anecdote.**

---

## Arguments

- No arguments — full codebase pattern scan
- `promote` — review high-confidence learned patterns and offer promotion to Hard Guardrails or Accepted Patterns
- `migrate` — migrate `## Guardrails` from `workflow.md` to `guardrails.md` (for existing projects)
- `<path>` — scan specific directory or file pattern

---

## Step 0: Verify Draft Context

```bash
ls draft/ 2>/dev/null
```

If `draft/` does not exist: **STOP** — "No Draft context found. Run `/draft:init` first."

---

## Step 1: Load Existing Guardrails

### 1.1: Check for guardrails.md

```bash
ls draft/guardrails.md 2>/dev/null
```

If it exists, read it and internalize:
- Current Hard Guardrails (checked items)
- Current Learned Conventions (existing entries)
- Current Learned Anti-Patterns (existing entries)

### 1.2: Check for Legacy Guardrails (migration path)

If `draft/guardrails.md` does NOT exist:

1. Check `draft/workflow.md` for `## Guardrails` section
2. If found, announce: "Found guardrails in workflow.md. Creating guardrails.md and migrating."
3. Create `draft/guardrails.md` using template from `core/templates/guardrails.md`
4. Copy checked guardrail items from `workflow.md ## Guardrails` into the Hard Guardrails section
5. Add a comment in `workflow.md` where `## Guardrails` was:
   ```markdown
   ## Guardrails

   > **Migrated** — Guardrails have moved to `draft/guardrails.md`. See that file for hard guardrails, learned conventions, and learned anti-patterns.
   ```

If `migrate` argument was given, stop here after migration. Otherwise, continue to pattern scanning.

### 1.3: Load Supporting Context

Read and follow `core/shared/draft-context-loading.md` for full Draft context. Key files:
- `draft/.ai-context.md` — Module boundaries, invariants, concurrency model
- `draft/tech-stack.md` — Frameworks, accepted patterns (do not learn patterns that duplicate these)
- `draft/product.md` — Product requirements

---

## Step 2: Codebase Pattern Scan

### 2.1: Discover Source Files

```bash
# Find all source files (exclude vendored, generated, build artifacts)
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
  -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \
  -o -name "*.cpp" -o -name "*.cc" -o -name "*.h" -o -name "*.hpp" \
  -o -name "*.rb" -o -name "*.php" -o -name "*.swift" -o -name "*.kt" \) \
  -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" \
  -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/__pycache__/*" \
  -not -path "*/draft/*" \
  | head -500
```

If scope argument provided, filter to that path.

### 2.2: Analyze Pattern Dimensions

Scan the codebase across these dimensions, looking for **recurring patterns** (3+ occurrences):

#### Error Handling Conventions
- How errors are caught, logged, and propagated
- Custom error classes or error codes
- Try/catch patterns, error boundaries
- Retry and fallback strategies

#### Naming Conventions
- Variable, function, class naming styles beyond language defaults
- File naming patterns (kebab-case, PascalCase, etc.)
- Module/directory organization conventions

#### Architecture Patterns
- Import/dependency patterns (barrel exports, lazy loading)
- State management approaches
- API call patterns (centralized client, interceptors)
- Component composition patterns

#### Concurrency Patterns
- Async/await usage conventions
- Locking and synchronization approaches
- Queue and worker patterns
- Cancellation and timeout handling

#### Data Flow Patterns
- Validation placement (boundary vs deep)
- Serialization/deserialization conventions
- Caching strategies
- Data transformation pipelines

#### Testing Conventions
- Test file placement and naming
- Test structure (arrange/act/assert, given/when/then)
- Mock/stub conventions
- Fixture and factory patterns

#### Configuration Patterns
- Environment variable access patterns
- Feature flag patterns
- Config file conventions

### 2.3: Cross-Reference Existing Knowledge

For each candidate pattern:

1. **Check `tech-stack.md ## Accepted Patterns`** — if already documented there, skip (no duplication)
2. **Check existing `guardrails.md` entries** — if already learned, update evidence count and date
3. **Check `.ai-context.md`** — if described as architecture, skip (it's documented)
4. **Verify consistency** — sample 3+ instances and confirm they follow the same approach

---

## Step 3: Apply Confidence Threshold

Follow the threshold from `core/shared/pattern-learning.md`:

| Evidence | Confidence | Action |
|----------|------------|--------|
| Found 1-2x | — | Skip (insufficient data) |
| Found 3-5x, all consistent | `medium` | Learn as convention or anti-pattern |
| Found >5x, all consistent, cross-verified | `high` | Learn + flag as promotion candidate |
| Found >5x but inconsistent | — | Do NOT learn (investigate inconsistency) |

### Distinguishing Conventions from Anti-Patterns

- **Convention:** Pattern is consistently applied AND does not cause bugs, security issues, or violations of documented invariants
- **Anti-Pattern:** Pattern is consistently applied BUT causes or risks bugs, security issues, performance problems, or invariant violations

---

## Step 4: Update guardrails.md

Follow the write procedure in `core/shared/pattern-learning.md`:

1. Read current `draft/guardrails.md`
2. For each new pattern: check for duplicates, then append
3. For existing patterns: update evidence count, confidence, `last_verified`
4. Update YAML frontmatter `synced_to_commit`

### Entry Format — Convention

```markdown
### [Pattern Name]
- **Category:** error-handling | naming | architecture | concurrency | state-management | data-flow | testing | configuration
- **Confidence:** high | medium
- **Evidence:** Found in N files — `path/file1.ext:line`, `path/file2.ext:line`, `path/file3.ext:line`
- **Last verified:** YYYY-MM-DD
- **Discovered by:** draft:learn on YYYY-MM-DD
- **Description:** [What the pattern is and why it's intentional]
```

### Entry Format — Anti-Pattern

```markdown
### [Anti-Pattern Name]
- **Category:** security | reliability | performance | correctness | concurrency
- **Severity:** critical | high | medium
- **Evidence:** Found in N files — `path/file1.ext:line`, `path/file2.ext:line`
- **Last verified:** YYYY-MM-DD
- **Discovered by:** draft:learn on YYYY-MM-DD
- **Description:** [What the pattern is and why it's problematic]
- **Suggested fix:** [Brief description of the correct approach]
```

---

## Step 5: Promotion Workflow (when `promote` argument given)

Review all learned patterns with `confidence: high` and present promotion candidates:

```
Pattern promotion candidates:

1. [Convention] "Centralized API client pattern" (high confidence, 12 files)
   → Promote to: tech-stack.md ## Accepted Patterns? [y/n]

2. [Convention] "Error boundary at route level" (high confidence, 8 files)
   → Promote to: Hard Guardrail (enforce always)? [y/n]

3. [Anti-Pattern] "Unguarded .env access" (high confidence, 6 files)
   → Promote to: Hard Guardrail (enforce always)? [y/n]
```

For each promoted pattern:
- **Convention → Accepted Pattern**: Append to `draft/tech-stack.md ## Accepted Patterns` and remove from guardrails.md Learned Conventions
- **Convention → Hard Guardrail**: Move from Learned Conventions to Hard Guardrails section (as checked `[x]` item)
- **Anti-Pattern → Hard Guardrail**: Move from Learned Anti-Patterns to Hard Guardrails section (as checked `[x]` item)

---

## Step 6: Generate Summary Report

Display results to the user:

```
/draft:learn complete

Scanned: N source files across M directories
Duration: ~Xs

Results:
  New conventions learned:     N  [list names]
  New anti-patterns learned:   N  [list names]
  Existing patterns updated:   N  [list names]
  Skipped (insufficient data): N
  Skipped (already documented): N

Promotion candidates (high confidence):
  N patterns ready for promotion — run /draft:learn promote to review

Updated: draft/guardrails.md
```

---

## How Quality Commands Use guardrails.md

After `/draft:learn` populates guardrails.md, all quality commands automatically:

| Section | Quality Command Behavior |
|---------|------------------------|
| **Hard Guardrails** (checked) | Flag violations as issues |
| **Learned Conventions** | Skip these patterns during analysis (not bugs) |
| **Learned Anti-Patterns** | Always flag these patterns as bugs |
| **Unchecked Hard Guardrails** | Ignore (not enforced) |

This creates a **continuous improvement loop**:
1. Quality command runs → discovers patterns → updates guardrails.md
2. Next quality command run → reads updated guardrails.md → fewer false positives, catches known-bad patterns
3. `/draft:learn promote` → graduates stable patterns to permanent status

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Learn from <3 occurrences | Require minimum 3 consistent instances |
| Auto-promote to Hard Guardrails | Always require human approval for promotion |
| Overwrite human-curated entries | Learned patterns complement, never replace |
| Learn framework defaults as conventions | Only learn project-specific patterns |
| Remove entries on re-scan | Update evidence/dates, never delete |
| Learn from test/mock code | Focus on production source code |
