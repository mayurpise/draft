# Pattern Learning — Post-Analysis Phase

Shared procedure for auto-discovering coding patterns after quality analysis. Run as the final phase of `/draft:bughunt`, `/draft:deep-review`, and `/draft:review`.

Referenced by: `/draft:bughunt`, `/draft:deep-review`, `/draft:review`, `/draft:learn`

---

## When to Run

Execute this phase **after** the main analysis and report generation are complete. This phase updates `draft/guardrails.md` with newly discovered patterns.

**Skip this phase if:**
- `draft/` directory does not exist (no Draft context)
- Analysis found zero findings to learn from
- Running in a read-only or preview mode

---

## Step 1: Identify Pattern Candidates

Review the findings from the just-completed analysis and identify:

### Convention Candidates (patterns to NOT flag in future)

Look for patterns that were **considered during analysis but determined to be intentional**:

- Patterns checked during the Pattern Prevalence Check that were found >3x and all instances were correct
- Patterns that matched a framework idiom confirmed by documentation
- Patterns flagged as MEDIUM confidence but verified as intentional after investigation
- Recurring code structures that follow a consistent project convention

### Anti-Pattern Candidates (patterns to ALWAYS flag in future)

Look for patterns that were **confirmed as bugs across multiple locations**:

- Bug patterns found in 3+ locations with the same root cause
- Patterns that violate documented invariants consistently
- Security or reliability patterns that appeared as confirmed bugs

---

## Step 2: Apply Confidence Threshold

| Evidence | Confidence | Action |
|----------|------------|--------|
| Pattern found 1-2x | — | Do not learn (insufficient data) |
| Pattern found 3-5x, all consistent | `medium` | Add to guardrails.md |
| Pattern found >5x, all consistent, verified across multiple files | `high` | Add to guardrails.md, suggest promotion |
| Pattern found >5x but some instances are buggy | — | Do NOT learn (inconsistent — real problem exists) |

---

## Step 3: Check for Duplicates

Before adding a new entry to `draft/guardrails.md`:

1. Read current `draft/guardrails.md`
2. Check if the pattern already exists under Learned Conventions or Learned Anti-Patterns
3. If it exists:
   - Update `last_verified` date
   - Increase evidence count if new instances were found
   - Upgrade confidence from `medium` → `high` if threshold met
4. If it does NOT exist: append as new entry

---

## Step 4: Write to guardrails.md

### 4.0: Update File Metadata

Before writing entries, update the YAML frontmatter in `draft/guardrails.md`:
- Set `synced_to_commit` to the current HEAD commit SHA
- Update `git.commit`, `git.commit_short`, `git.commit_date`, `git.commit_message` fields

### Convention Entry Format

Append under `## Learned Conventions`:

```markdown
### [Pattern Name]
- **Category:** error-handling | naming | architecture | concurrency | state-management | data-flow | testing | configuration
- **Confidence:** high | medium
- **Evidence:** Found in N files — `path/file1.ext:line`, `path/file2.ext:line`, `path/file3.ext:line`
- **Discovered at:** YYYY-MM-DD (when Draft first observed this pattern)
- **Established at:** ~YYYY-MM-DD (when this pattern was introduced in the codebase, via git blame)
- **Last verified:** YYYY-MM-DD
- **Last active:** YYYY-MM-DD (when source files using this pattern were last modified)
- **Discovered by:** draft:[command] on YYYY-MM-DD
- **Description:** [What the pattern is and why it's intentional]
```

### Anti-Pattern Entry Format

Append under `## Learned Anti-Patterns`:

```markdown
### [Anti-Pattern Name]
- **Category:** security | reliability | performance | correctness | concurrency
- **Severity:** critical | high | medium
- **Evidence:** Found in N files — `path/file1.ext:line`, `path/file2.ext:line`
- **Discovered at:** YYYY-MM-DD (when Draft first observed this pattern)
- **Established at:** ~YYYY-MM-DD (when this pattern was introduced in the codebase, via git blame)
- **Last verified:** YYYY-MM-DD
- **Last active:** YYYY-MM-DD (when source files using this pattern were last modified)
- **Discovered by:** draft:[command] on YYYY-MM-DD
- **Description:** [What the pattern is and why it's problematic]
- **Suggested fix:** [Brief description of the correct approach]
```

### Temporal Metadata (Dual-Layer Timestamps)

Every learned pattern entry includes dual-layer timestamps inspired by Supermemory's temporal reasoning:

| Timestamp | Purpose | How to Determine |
|-----------|---------|-----------------|
| `Discovered at` | When Draft first observed this pattern | Current date when pattern is first learned |
| `Established at` | When this pattern was actually introduced in the codebase | Use `git blame` on evidence files to find oldest occurrence, take the approximate date |
| `Last verified` | When this pattern was last confirmed still present | Updated on each re-verification |
| `Last active` | When source files using this pattern were last modified | `git log -1 --format="%ci" -- {evidence_file}` on evidence files, take most recent |

**Temporal reasoning enabled by these timestamps:**
- Pattern discovered recently but established long ago → well-established convention
- Pattern established recently and actively used → emerging convention
- Pattern established long ago but `last_active` is old → potentially declining (cross-reference with Step 2.3 temporal analysis in `/draft:learn`)
- Pattern where `last_active` is >6 months old → candidate for deprecation review

---

## Step 5: Report Learning Summary

After updating guardrails.md, append a brief learning summary to the end of the quality report:

```markdown
## Pattern Learning

| Action | Count | Details |
|--------|-------|---------|
| New conventions learned | N | [names] |
| New anti-patterns learned | N | [names] |
| Existing patterns re-verified | N | [names] |
| Promotion candidates (high confidence) | N | [names] |
```

---

## Constraints

- **Never auto-promote** learned patterns to Hard Guardrails — that requires human decision via `/draft:learn promote`
- **Never remove** existing entries — only update evidence/confidence/dates
- **Cap at 50 learned entries** per section — if at capacity, replace the oldest `medium` confidence entry that hasn't been re-verified in 90+ days
- **Human-curated always wins** — Hard Guardrails and `tech-stack.md ## Accepted Patterns` take precedence over learned patterns if there's a conflict
- **Preserve file metadata** — update `synced_to_commit` in the YAML frontmatter when modifying guardrails.md
