---
name: adr
description: Create and manage Architecture Decision Records. Documents significant technical decisions with context, alternatives, and consequences.
---

# Architecture Decision Records

You are creating or managing Architecture Decision Records (ADRs) for this project.

## Red Flags - STOP if you're:

- Creating an ADR without understanding the decision context
- Documenting trivial decisions that don't warrant an ADR (e.g., variable naming)
- Writing an ADR after the fact without capturing the original reasoning
- Listing alternatives without genuine pros/cons analysis
- Skipping the "Consequences" section (the most valuable part)
- Not checking existing ADRs for conflicts or superseded decisions

**ADRs capture WHY, not just WHAT. Every decision needs alternatives considered.**

---

## Pre-Check

1. Verify Draft is initialized:
```bash
ls draft/ 2>/dev/null
```

If `draft/` doesn't exist:
- Tell user: "Project not initialized. Run `/draft:init` first."
- Stop here.

2. Check for existing ADR directory:
```bash
ls draft/adrs/ 2>/dev/null
```

If `draft/adrs/` doesn't exist, create it:
```bash
mkdir -p draft/adrs
```

## Step 1: Parse Arguments

Check for arguments:
- `/draft:adr` — Interactive mode: ask about the decision
- `/draft:adr "decision title"` — Create ADR with given title
- `/draft:adr list` — List all existing ADRs
- `/draft:adr supersede <number>` — Mark an ADR as superseded

### List Mode

If argument is `list`:
1. Read all files in `draft/adrs/`
2. Display summary table:

```
Architecture Decision Records

| # | Title | Status | Date |
|---|-------|--------|------|
| 001 | Use PostgreSQL for primary storage | Accepted | 2026-01-15 |
| 002 | Adopt event-driven architecture | Proposed | 2026-02-01 |
| 003 | Replace REST with GraphQL | Superseded by #005 | 2026-02-03 |
```

Stop here after listing.

### Supersede Mode

If argument is `supersede <number>`:
1. Read the ADR file `draft/adrs/<number>-*.md`
2. Change status from `Accepted` to `Superseded by ADR-<new_number>`
3. Ask what new ADR supersedes it, or create the new one
4. Stop here after updating.

## Step 2: Gather Decision Context

If in interactive mode (no title provided), ask:

1. "What technical decision needs to be documented?"
2. "What's the context? What forces are driving this decision?"
3. "What alternatives did you consider?"

If title provided, proceed directly with the title.

## Step 3: Load Project Context

Read relevant Draft context:
- `draft/.ai-context.md` — Current architecture patterns, invariants, data paths, and constraints. Falls back to `draft/architecture.md` for legacy projects.
- `draft/tech-stack.md` — Current technology choices
- `draft/product.md` — Product requirements that influence the decision

Cross-reference the decision against existing context:
- Does it align with documented architecture patterns?
- Does it introduce a new technology not in tech-stack.md?
- Does it affect product requirements?

## Step 4: Determine ADR Number

```bash
# Count existing ADRs and increment
ls draft/adrs/*.md 2>/dev/null | wc -l
```

Next number = existing count + 1, zero-padded to 3 digits (001, 002, ...).

## Step 5: Create ADR File

**MANDATORY: Include YAML frontmatter with git metadata.** Gather git info first:

```bash
git branch --show-current                    # LOCAL_BRANCH
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "none"  # REMOTE/BRANCH
git rev-parse HEAD                           # FULL_SHA
git rev-parse --short HEAD                   # SHORT_SHA
git log -1 --format=%ci HEAD                 # COMMIT_DATE
git log -1 --format=%s HEAD                  # COMMIT_MESSAGE
git status --porcelain | head -1 | wc -l     # 0 = clean, >0 = dirty
```

Create `draft/adrs/<number>-<kebab-case-title>.md`:

```markdown
---
project: "{PROJECT_NAME}"
module: "root"
adr_number: <number>
generated_by: "draft:adr"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  remote: "{REMOTE/BRANCH}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
  commit_message: "{COMMIT_MESSAGE}"
  dirty: {true|false}
synced_to_commit: "{FULL_SHA}"
---

# ADR-<number>: <Title>

| Field | Value |
|-------|-------|
| **Branch** | `{LOCAL_BRANCH}` → `{REMOTE/BRANCH}` |
| **Commit** | `{SHORT_SHA}` — {COMMIT_MESSAGE} |
| **Generated** | {ISO_TIMESTAMP} |
| **Synced To** | `{FULL_SHA}` |

**Status:** Proposed
**Deciders:** [names or roles]

## Context

[What is the issue that we're seeing that is motivating this decision or change?]
[What forces are at play (technical, business, organizational)?]

## Decision

[What is the change that we're proposing and/or doing?]
[State the decision in active voice: "We will..."]

## Alternatives Considered

### Alternative 1: <name>
- **Pros:** [advantages]
- **Cons:** [disadvantages]
- **Why rejected:** [specific reason]

### Alternative 2: <name>
- **Pros:** [advantages]
- **Cons:** [disadvantages]
- **Why rejected:** [specific reason]

## Consequences

### Positive
- [Benefit 1]
- [Benefit 2]

### Negative
- [Trade-off 1]
- [Trade-off 2]

### Risks
- [Risk and mitigation]

## References

- [Link to relevant discussion, RFC, or documentation]
- [Related ADRs: ADR-xxx]
```

## Step 6: Present for Review

Present the ADR to the user for review:

```
ADR-<number> created: <title>
File: draft/adrs/<number>-<kebab-case-title>.md
Status: Proposed

Review the ADR and update status to "Accepted" when approved.
```

## Step 7: Update References (if applicable)

If the decision affects existing Draft context:

1. **tech-stack.md** — If introducing or removing technology, note: "Consider updating draft/tech-stack.md to reflect this decision."
2. **.ai-context.md** — If changing architectural patterns, note: "Consider updating draft/.ai-context.md to reflect this decision (architecture.md will be auto-derived)."
3. **Superseded ADRs** — If this decision replaces a previous one, update the old ADR's status.

## ADR Status Lifecycle

```
Proposed → Accepted → [Deprecated | Superseded by ADR-xxx]
```

- **Proposed** — Decision documented, awaiting review
- **Accepted** — Decision approved and in effect
- **Deprecated** — Decision no longer relevant (context changed)
- **Superseded** — Replaced by a newer decision (link to replacement)

## Error Handling

**If no draft/ directory:**
- Tell user to run `/draft:init` first

**If ADR number conflict:**
- Increment to next available number
- Warn: "ADR-<number> already exists. Using ADR-<next>."

**If superseding non-existent ADR:**
- Warn: "ADR-<number> not found. Check `draft/adrs/` for valid ADR numbers."
