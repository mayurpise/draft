# Cross-Skill Dispatch Convention

Standard convention for how Draft skills invoke, offer, or suggest other skills during execution.

**Referenced by:** All Tier 1 orchestrators (`/draft:init`, `/draft:new-track`, `/draft:implement`, `/draft:review`)

---

## Dispatch Tiers

### Tier 1: Auto-Invoke (Silent)

Skills at this tier are loaded or executed automatically without user confirmation. The user is not prompted.

| Trigger | Auto-Invoked Action |
|---------|-------------------|
| Any skill that needs project context | Load `core/shared/draft-context-loading.md` |
| `/draft:implement` completes with quality signals | Feed quality results to `/draft:learn` |
| `/draft:new-track` or `/draft:implement` with Jira key | Sync to Jira via `core/shared/jira-sync.md` |
| `/draft:bughunt` or `/draft:debug` identifies root cause | Load `core/agents/rca.md` protocol |

### Tier 2: Offer (Ask with Default)

Skills at this tier are presented to the user with a yes/no prompt. Default is to proceed.

**Format:** "Run `/draft:skill-name` to `benefit`? [Y/n]"

| Trigger | Offer |
|---------|-------|
| `/draft:implement` encounters failing tests | "Run `/draft:debug` to investigate test failures? [Y/n]" |
| At phase boundary in `/draft:implement` | "Run `/draft:quick-review` for lightweight check? [Y/n]" |
| `/draft:implement` detects accumulating shortcuts | "Run `/draft:tech-debt` to log debt items? [Y/n]" |

### Tier 3: Suggest (Announce, Don't Block)

Skills at this tier are mentioned in output but execution is not offered. The user must invoke manually.

**Format:** "Consider running `/draft:skill-name` to `benefit`."

| Trigger | Suggestion |
|---------|-----------|
| `/draft:implement` completes a large track | "Consider running `/draft:deep-review` for a production-grade audit." |
| `/draft:bughunt` finds systemic patterns | "Consider running `/draft:learn` to capture these patterns." |
| `/draft:review` flags architecture concerns | "Consider running `/draft:adr` to document this decision." |

### Tier 4: Detect + Auto-Feed (Smart Context Injection)

Skills at this tier automatically inject relevant context into the target skill without invoking it. The context is available when the user eventually runs the target skill.

| Source Skill | Output Artifact | Target Skill | Injection Method |
|-------------|----------------|-------------|-----------------|
| `/draft:bughunt` | `bughunt-report.md` | `/draft:implement` | Loaded as context when implementing bug fix track |
| `/draft:review` | Review findings | `/draft:learn` | Quality signals extracted and fed to pattern learning |
| `/draft:deep-review` | Audit report | `/draft:implement` | Findings loaded as constraints for next implementation |
| `/draft:decompose` | Subtask breakdown | `/draft:new-track` | Subtasks offered as new tracks |
| `/draft:coverage` | Coverage gaps | `/draft:implement` | Gaps loaded as pending work items |
| `/draft:incident-response` | Incident timeline | `/draft:learn` | Incident patterns captured for prevention |

---

## Primary Dispatch Registry

This registry covers primary orchestrator dispatches. Individual skills document additional dispatch points in their `## Cross-Skill Dispatch` sections.

| Orchestrator | Dispatch Point | Target | Tier |
|-------------|---------------|--------|------|
| `/draft:init` | Monorepo detected | `/draft:index` | 3 — Suggest |
| `/draft:init` | Jira key provided | Jira sync | 1 — Auto |
| `/draft:new-track` | Track created | `/draft:decompose` | 2 — Offer |
| `/draft:new-track` | Jira key provided | Jira sync | 1 — Auto |
| `/draft:implement` | Before coding | Context loading | 1 — Auto |
| `/draft:implement` | Tests failing | `/draft:debug` | 2 — Offer |
| `/draft:implement` | After completion | pattern-learning.md | 1 — Auto |
| `/draft:implement` | After completion | `/draft:review` | 2 — Offer |
| `/draft:implement` | Large track done | `/draft:deep-review` | 3 — Suggest |
| `/draft:implement` | Jira key exists | Jira sync | 1 — Auto |
| `/draft:review` | Architecture concern | `/draft:adr` | 3 — Suggest |
| `/draft:review` | Quality signals | pattern-learning.md | 1 — Auto |
| `/draft:review` | Jira key exists | Jira sync | 1 — Auto |
| `/draft:bughunt` | Root cause found | `core/agents/rca.md` | 1 — Auto |
| `/draft:bughunt` | Systemic pattern | `/draft:learn` | 3 — Suggest |
| `/draft:bughunt` | Jira key exists | Jira sync | 1 — Auto |

---

## Implementation Pattern

When implementing dispatch in a skill, follow this template:

```markdown
## Dispatch Points

<!-- Tier 1: Auto-invoke -->
Load context: `core/shared/draft-context-loading.md`
Sync to Jira: `core/shared/jira-sync.md` (if Jira key present)

<!-- Tier 2: Offer -->
If {condition}:
  Ask: "Run `/draft:skill-name` to {benefit}? [Y/n]"
  If yes: invoke skill
  If no: continue

<!-- Tier 3: Suggest -->
If {condition}:
  Output: "Consider running `/draft:skill-name` to {benefit}."

<!-- Tier 4: Context injection -->
If {artifact} exists:
  Load as context for next relevant skill invocation
```

---

## Test Writing Guardrail

**Never auto-write tests in bug/debug/RCA workflows.**

When `/draft:bughunt`, `/draft:debug`, or the RCA agent identifies a bug:
- Diagnose and fix the bug
- Do **not** generate test files automatically
- If tests would help, use Tier 2 dispatch: "Write regression tests for this fix? [Y/n]"
- Rationale: Auto-generated tests in debug context often test the wrong thing (the symptom, not the cause)
