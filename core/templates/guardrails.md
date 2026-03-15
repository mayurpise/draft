---
project: "{PROJECT_NAME}"
module: "root"
generated_by: "draft:init"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  remote: "{REMOTE/BRANCH}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
  commit_message: "{COMMIT_MESSAGE}"
  dirty: false
synced_to_commit: "{FULL_SHA}"
---

# Guardrails

| Field | Value |
|-------|-------|
| **Branch** | `{LOCAL_BRANCH}` → `{REMOTE/BRANCH}` |
| **Commit** | `{SHORT_SHA}` — {COMMIT_MESSAGE} |
| **Generated** | {ISO_TIMESTAMP} |
| **Synced To** | `{FULL_SHA}` |

---

This file defines project-level guardrails and learned coding patterns. All quality commands (`/draft:bughunt`, `/draft:deep-review`, `/draft:review`) read this file and enforce its rules.

- **Hard Guardrails** — Human-defined constraints. Violations are always flagged.
- **Learned Conventions** — Auto-discovered patterns that are intentional. Quality commands skip these.
- **Learned Anti-Patterns** — Auto-discovered patterns that are problematic. Quality commands always flag these.

Run `/draft:learn` to scan the codebase and update learned patterns. Quality commands also update this file incrementally after each run.

---

## Hard Guardrails

<!-- Hard constraints that must never be violated. Check [x] to enable enforcement. -->

### Git & Version Control
- [ ] No direct commits to main/master
- [ ] No force push to shared branches
- [ ] PR required for all changes

### Code Quality
- [ ] No console.log/print statements in production code
- [ ] No commented-out code blocks
- [ ] No TODO comments without linked issue

### Security
- [ ] No secrets/credentials in code
- [ ] No disabled security checks without documented exception
- [ ] Dependencies must pass security audit

### Testing
- [ ] Tests required before merge
- [ ] No skipped tests without documented reason
- [ ] Coverage must not decrease

> Check the guardrails that apply to this project. Unchecked items are not enforced. Quality commands flag violations of checked guardrails only.

---

## Learned Conventions

<!-- Auto-discovered coding patterns verified as intentional. Quality commands skip these. -->
<!-- Each entry is added by /draft:learn or by quality commands during post-analysis. -->
<!-- Format: pattern name, category, confidence, evidence, description. -->

<!-- No learned conventions yet. Run /draft:learn or a quality command to discover patterns. -->

---

## Learned Anti-Patterns

<!-- Auto-discovered patterns verified as problematic. Quality commands always flag these. -->
<!-- Each entry is added by /draft:learn or by quality commands during post-analysis. -->

<!-- No learned anti-patterns yet. Run /draft:learn or a quality command to discover patterns. -->

---

## Pattern Promotion

Learned patterns with `confidence: high` and consistent evidence across multiple quality runs are candidates for promotion:

- **Convention → Accepted Pattern**: Promote to `tech-stack.md ## Accepted Patterns` for technology-level decisions
- **Convention → Hard Guardrail**: Promote to Hard Guardrails above if the team wants enforcement
- **Anti-Pattern → Hard Guardrail**: Promote to Hard Guardrails above for mandatory enforcement

Run `/draft:learn promote` to review candidates.
