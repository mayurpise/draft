---
name: new-track
description: Start a new feature or bug track. Generates spec.md and plan.md with phased tasks for Context-Driven Development.
---

# Create New Track

You are creating a new track (feature, bug fix, or refactor) for Context-Driven Development.

**Feature Description:** $ARGUMENTS

## Pre-Check

1. Verify Draft is initialized:
```bash
ls draft/product.md draft/tech-stack.md draft/workflow.md draft/tracks.md 2>/dev/null
```

If missing, tell user: "Project not initialized. Run `/draft:init` first."

2. Load full project context (these documents ARE the big picture — every track must be grounded in them):
- Read `draft/product.md` — product vision, users, goals, constraints
- Read `draft/tech-stack.md` — languages, frameworks, patterns, code style
- Read `draft/architecture.md` (if exists) — system map, modules, data flows, integration points
- Read `draft/product-guidelines.md` (if exists) — UX standards, writing style, branding
- Read `draft/workflow.md` — TDD preference, commit conventions, review process
- Read `draft/tracks.md` — existing tracks to check for overlap or dependencies

## Step 1: Generate Track ID

Create a short, kebab-case ID from the description:
- "Add user authentication" → `add-user-auth`
- "Fix login bug" → `fix-login-bug`
- If collision risk, append ISO date suffix: `add-user-auth-20250126`

## Red Flags - STOP if you're:

- Writing spec without dialogue (assuming you understand requirements)
- Copying requirements verbatim without clarifying questions
- Creating plan before spec is approved
- Skipping non-goals section ("everything is in scope")
- Not referencing product.md, tech-stack.md, and architecture.md for context
- Creating a bug track without checking if it needs the RCA flow (see Step 2B)
- Rushing to get to implementation

**The goal is understanding, not speed.**

---

## Step 2: Determine Track Type

Based on the feature description and dialogue:

- **Feature / Refactor** → Proceed to Step 2A (Standard Specification)
- **Bug / RCA / Jira Incident** → Proceed to Step 2B (Bug & RCA Specification)

Indicators for bug/RCA track: Jira bug ticket reference, production incident, error reports, regression, "fix", "investigate", "root cause".

---

## Step 2A: Create Specification (Feature / Refactor)

Engage in dialogue to understand:
1. **What** - Exact scope and boundaries
2. **Why** - Business/user value
3. **Acceptance Criteria** - How we know it's done
4. **Non-Goals** - What's explicitly out of scope

Create `draft/tracks/<track_id>/spec.md`:

```markdown
# Specification: [Title]

**Track ID:** <track_id>
**Created:** [ISO date]
**Status:** [ ] Draft

## Context References
> These documents define the big picture. This track operates within their constraints.
- **Product:** `draft/product.md` — [1-line: how this track serves product goals]
- **Tech Stack:** `draft/tech-stack.md` — [1-line: key stack constraints for this track]
- **Architecture:** `draft/architecture.md` — [1-line: affected modules/components/flows]
- **Guidelines:** `draft/product-guidelines.md` — [1-line: relevant UX/style constraints, or "N/A"]

## Summary
[2-3 sentence description of what this track delivers]

## Background
[Why this is needed, grounded in product.md goals and architecture.md context]

## Requirements

### Functional
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

### Non-Functional
- Performance: [if applicable]
- Security: [if applicable]
- Accessibility: [if applicable]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Non-Goals
- [What's explicitly out of scope]

## Technical Approach
[High-level approach grounded in tech-stack.md patterns and architecture.md modules]

## Open Questions
- [Question 1]
- [Question 2]
```

Present for approval. Iterate until approved.

---

## Step 2B: Create Specification (Bug & RCA)

For bugs, incidents, or Jira-sourced issues. This flow prioritizes precision over breadth — investigate in and around the bug, not the whole system.

**If a Jira ticket is referenced**, extract: summary, description, reproduction steps, environment, severity, linked issues.

Engage in focused dialogue:
1. **Symptoms** - Exact error, affected users/flows, frequency
2. **Reproduction** - Steps to trigger, environment conditions
3. **Blast Radius** - What works, what doesn't, boundary of the failure
4. **Severity** - P0 (outage) / P1 (major degradation) / P2 (significant) / P3 (minor)

Create `draft/tracks/<track_id>/spec.md`:

```markdown
# Bug Specification: [Title]

**Track ID:** <track_id>
**Type:** bugfix
**Created:** [ISO date]
**Status:** [ ] Draft
**Severity:** [P0/P1/P2/P3]
**Jira:** [ticket key, or "N/A"]

## Context References
> These documents define the system. The bug exists within this context.
- **Architecture:** `draft/architecture.md` — [affected module/component/service]
- **Tech Stack:** `draft/tech-stack.md` — [relevant framework/library versions]
- **Product:** `draft/product.md` — [affected user flow/feature]

## Symptoms
[Precise description: what happens, what should happen, who is affected]

## Reproduction
1. [Step 1]
2. [Step 2]
3. [Expected: ...]
4. [Actual: ...]

**Environment:** [OS, runtime version, config, deployment target]
**Frequency:** [always / intermittent / edge case]
**First observed:** [date/commit/release if known]

## Blast Radius
- **Affected:** [specific flows, endpoints, users]
- **Not affected:** [what still works — narrows investigation scope]

## Code Locality
> Direct references to the area of investigation. Stay focused here.
- **Entry point:** `path/to/file.ts:line` — [brief description]
- **Suspect area:** `path/to/file.ts:line-range` — [why this is suspect]
- **Related code:** `path/to/related.ts` — [connection to the bug]
- **Data flow:** [brief trace: input → processing → failure point]

## Investigation Constraints
- [ ] Do NOT modify code outside the blast radius without explicit approval
- [ ] Reference architecture.md for module boundaries — respect them
- [ ] Check existing tests in the suspect area before writing new ones
- [ ] Document every hypothesis, even failed ones

## Acceptance Criteria
- [ ] Root cause identified and documented
- [ ] Regression test reproducing the exact failure
- [ ] Fix addresses root cause (not symptoms)
- [ ] Existing tests pass
- [ ] No changes outside blast radius without approval

## Non-Goals
- [What's explicitly out of scope — resist the urge to "fix while we're here"]
```

Present for approval. Iterate until approved.

**After spec approval**, the plan for bug tracks follows a fixed 3-phase structure. See Step 3.

## Step 3: Create Plan

Based on approved spec, create phased task breakdown.

### Step 3A: Feature / Refactor Plan

Create `draft/tracks/<track_id>/plan.md`:

```markdown
# Plan: [Title]

**Track ID:** <track_id>
**Spec:** ./spec.md
**Status:** [ ] Not Started

## Overview
[Brief summary linking to spec and relevant architecture.md modules]

---

## Phase 1: [Phase Name]
**Goal:** [What this phase achieves]
**Verification:** [How to verify phase completion]

### Tasks
- [ ] **Task 1.1:** [Description]
  - Files: `path/to/file.ts`
  - Test: `path/to/file.test.ts`

- [ ] **Task 1.2:** [Description]
  - Files: `path/to/another.ts`
  - Test: `path/to/another.test.ts`

---

## Phase 2: [Phase Name]
**Goal:** [What this phase achieves]
**Verification:** [How to verify phase completion]

### Tasks
- [ ] **Task 2.1:** [Description]
  - Depends on: Task 1.1, Task 1.2
  - Files: `path/to/file.ts`

---

## Phase 3: Integration & Polish
**Goal:** Final integration and cleanup
**Verification:** All acceptance criteria from spec met

### Tasks
- [ ] **Task 3.1:** Integration testing
- [ ] **Task 3.2:** Documentation update
- [ ] **Task 3.3:** Code review and cleanup

---

## Notes
- [Important consideration]
- [Risk or dependency]
```

### Step 3B: Bug & RCA Plan

Bug tracks follow a fixed 3-phase structure based on systematic RCA methodology. See `core/agents/rca.md` for the full process.

Create `draft/tracks/<track_id>/plan.md`:

```markdown
# Plan: [Title]

**Track ID:** <track_id>
**Type:** bugfix
**Spec:** ./spec.md
**Status:** [ ] Not Started

## Overview
[Brief: what's broken, where it's breaking, severity]

---

## Phase 1: Investigate & Reproduce
**Goal:** Confirm the bug, establish reproduction, trace the failure
**Verification:** Bug reproduced reliably with documented steps

### Tasks
- [ ] **Task 1.1:** Reproduce the bug
  - Run reproduction steps from spec
  - Document exact error output, stack trace, logs
  - Files: [entry point from spec's Code Locality]

- [ ] **Task 1.2:** Trace the data/control flow
  - Trace from entry point to failure point
  - Document the path: `file:line` → `file:line` → failure
  - Map against `draft/architecture.md` module boundaries
  - Files: [suspect area from spec]

- [ ] **Task 1.3:** Establish blast radius boundary
  - Confirm what works and what doesn't
  - Identify the exact boundary of the failure
  - Document: "Bug is in [module/layer], not in [adjacent module/layer]"

---

## Phase 2: Root Cause Analysis
**Goal:** Identify and confirm the root cause with evidence
**Verification:** Root cause confirmed via targeted test

### Tasks
- [ ] **Task 2.1:** Analyze — compare working vs. failing paths
  - Find similar code that works correctly
  - List differences between working and failing cases
  - Check assumptions (data types, nullability, timing, state)
  - Files: [suspect area + related code from spec]

- [ ] **Task 2.2:** Hypothesize and test
  - Form single hypothesis based on analysis
  - Predict: "If hypothesis is correct, then [X] should happen"
  - Write minimal test to prove/disprove
  - If disproved: document, return to 2.1 with updated understanding
  - Files: [test file for suspect area]

- [ ] **Task 2.3:** Document root cause
  - Write root cause statement: what, why, how, since when
  - Reference specific code: `file:line` with explanation
  - Classify: logic error / race condition / data corruption / config / dependency

---

## Phase 3: Fix & Verify
**Goal:** Fix the root cause, prevent regression, verify no side effects
**Verification:** Regression test passes, existing tests pass, fix is minimal

### Tasks
- [ ] **Task 3.1:** Write regression test
  - Test MUST fail before fix, pass after
  - Test reproduces the exact failure from Phase 1
  - Files: [test file]

- [ ] **Task 3.2:** Implement minimal fix
  - Address root cause only — no refactoring, no "while we're here"
  - Stay within blast radius from spec
  - Files: [suspect area]

- [ ] **Task 3.3:** Verify fix
  - Run regression test — must pass
  - Run full test suite — no new failures
  - Run reproduction steps from spec — bug resolved
  - Verify no changes outside blast radius

- [ ] **Task 3.4:** Write RCA summary
  - Update spec.md with root cause findings
  - Document: timeline, root cause, fix, prevention measures
  - Reference: `file:line` for every claim

---

## RCA Log
> Track every hypothesis — failed ones are as valuable as the correct one.

| # | Hypothesis | Evidence | Result |
|---|-----------|----------|--------|
| 1 | | | |

## Notes
- [Important consideration]
- [Risk or dependency]
```

Present for approval. Iterate until approved.

## Step 4: Create Metadata

Create `draft/tracks/<track_id>/metadata.json`:

```json
{
  "id": "<track_id>",
  "title": "[Title]",
  "type": "feature|bugfix|refactor",
  "status": "planning",
  "created": "[ISO timestamp]",
  "updated": "[ISO timestamp]",
  "phases": {
    "total": 3,
    "completed": 0
  },
  "tasks": {
    "total": 0,
    "completed": 0
  }
}
```

## Step 5: Update Master Tracks List

Add to `draft/tracks.md` under Active:

```markdown
## Active

### [track_id] - [Title]
- **Status:** [ ] Planning
- **Created:** [date]
- **Phases:** 0/3
- **Path:** `./tracks/<track_id>/`
```

## Completion

Announce:
"Track created: <track_id>

Created:
- draft/tracks/<track_id>/spec.md
- draft/tracks/<track_id>/plan.md
- draft/tracks/<track_id>/metadata.json

Updated:
- draft/tracks.md

Next: Review the spec and plan, then run `/draft:implement` to begin."
