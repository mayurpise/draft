---
name: new-track
description: Start a new feature or bug track. Collaborative intake process with structured questions, AI guidance, and progressive refinement before generating spec.md and plan.md.
---

# Create New Track

You are creating a new track (feature, bug fix, or refactor) for Context-Driven Development. This is a **collaborative process** — you are an active participant providing guidance, fact-checking, and expertise grounded in vetted sources.

**Feature Description:** $ARGUMENTS

## Red Flags - STOP if you're:

- Creating a track without reading existing Draft context (product.md, tech-stack.md, architecture.md)
- Asking questions without contributing expertise or trade-off analysis
- Rushing through intake without probing deeper with "why"
- Generating spec/plan without user confirmation at checkpoints
- Skipping risk identification
- Not citing sources when giving architectural advice

**Collaborative understanding, not speed.**

---

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

3. Load guidance references:
- Read `core/templates/intake-questions.md` — structured questions for intake
- Read `core/knowledge-base.md` — vetted sources for AI guidance

## Step 1: Generate Track ID

Create a short, kebab-case ID from the description:
- "Add user authentication" → `add-user-auth`
- "Fix login bug" → `fix-login-bug`
- If collision risk, append ISO date suffix: `add-user-auth-20250126`

## Step 2: Create Draft Files

Create the track directory and draft files immediately with skeleton structure:

### Create `draft/tracks/<track_id>/spec-draft.md`:

```markdown
# Specification Draft: [Title]

**Track ID:** <track_id>
**Created:** [ISO date]
**Status:** [ ] Drafting

> This is a working draft. Content will evolve through conversation.

## Context References
- **Product:** `draft/product.md` — [pending]
- **Tech Stack:** `draft/tech-stack.md` — [pending]
- **Architecture:** `draft/architecture.md` — [pending]

## Problem Statement
[To be developed through intake conversation]

## Background & Why Now
[To be developed through intake conversation]

## Requirements
### Functional
[To be developed through intake conversation]

### Non-Functional
[To be developed through intake conversation]

## Acceptance Criteria
[To be developed through intake conversation]

## Non-Goals
[To be developed through intake conversation]

## Technical Approach
[To be developed through intake conversation]

## Success Metrics
<!-- Remove metrics that don't apply -->

| Category | Metric | Target | Measurement |
|----------|--------|--------|-------------|
| Performance | [e.g., API response time] | [e.g., <200ms p95] | [e.g., APM dashboard] |
| Quality | [e.g., Test coverage] | [e.g., >90%] | [e.g., CI coverage report] |
| Business | [e.g., User adoption rate] | [e.g., 50% in 30 days] | [e.g., Analytics] |
| UX | [e.g., Task completion rate] | [e.g., >95%] | [e.g., User testing] |

## Stakeholders & Approvals
<!-- Add roles relevant to your organization -->

| Role | Name | Approval Required | Status |
|------|------|-------------------|--------|
| Product Owner | [name] | Spec sign-off | [ ] |
| Tech Lead | [name] | Architecture review | [ ] |
| Security | [name] | Security review (if applicable) | [ ] |
| QA | [name] | Test plan review | [ ] |

### Approval Gates
- [ ] Spec approved by Product Owner
- [ ] Architecture reviewed by Tech Lead
- [ ] Security review completed (if touching auth, data, or external APIs)
- [ ] Test plan reviewed by QA

## Risk Assessment
<!-- Score: Probability (1-5) × Impact (1-5). Risks scoring ≥9 require mitigation plans. -->

| Risk | Probability | Impact | Score | Mitigation |
|------|-------------|--------|-------|------------|
| [e.g., Third-party API instability] | 3 | 4 | 12 | [e.g., Circuit breaker + fallback cache] |
| [e.g., Data migration failure] | 2 | 5 | 10 | [e.g., Dry-run migration + rollback script] |
| [e.g., Scope creep] | 3 | 3 | 9 | [e.g., Strict non-goals enforcement] |

## Deployment Strategy
<!-- Define rollout approach for production delivery -->

### Rollout Phases
1. **Canary** (1-5% traffic) — Validate core flows, monitor error rates
2. **Limited GA** (25%) — Expand to subset, watch performance metrics
3. **Full GA** (100%) — Complete rollout

### Feature Flags
- Flag name: `[feature_flag_name]`
- Default: `off`
- Kill switch: [yes/no]

### Rollback Plan
- Trigger: [e.g., error rate >1%, latency >500ms p95]
- Process: [e.g., disable feature flag, revert deployment]
- Data rollback: [e.g., migration revert script, N/A]

### Monitoring
- Dashboard: [link or name]
- Alerts: [e.g., PagerDuty rule for error rate spike]
- Key metrics: [e.g., error rate, latency, throughput]

## Open Questions
[Tracked during conversation]

## Conversation Log
> Key decisions and reasoning captured during intake.

[Conversation summary will be added here]
```

### Create `draft/tracks/<track_id>/plan-draft.md`:

```markdown
# Plan Draft: [Title]

**Track ID:** <track_id>
**Spec:** ./spec-draft.md
**Status:** [ ] Drafting

> This is a working draft. Phases will be defined after spec is finalized.

## Overview
[To be developed after spec finalization]

## Phases
[To be developed after spec finalization]

## Notes
[Tracked during conversation]
```

Announce: "Created draft files. Let's build out the specification through conversation."

---

## Step 3: Collaborative Intake

Follow the structured intake from `core/templates/intake-questions.md`. You are an **active collaborator**, not just a questioner.

### Your Role as AI Collaborator

For each question:
1. **Ask** the question clearly
2. **Listen** to the user's response
3. **Contribute** your expertise:
   - Pattern recognition from industry experience
   - Trade-off analysis with citations from knowledge-base.md
   - Risk identification the user may not see
   - Fact-checking against project context (architecture.md, tech-stack.md)
   - Alternative approaches with pros/cons
4. **Update** spec-draft.md with what's been established
5. **Summarize** periodically: "Here's what we have so far..."

### Citation Style

Ground advice in vetted sources:
- "Consider CQRS here (DDIA, Ch. 11) — separates read/write concerns."
- "This could violate the Dependency Rule (Clean Architecture)."
- "Circuit breaker pattern (Release It!) would help prevent cascade failures."
- "Watch for OWASP A01:2021 — Broken Access Control."

### Red Flags - STOP if you're:

- Asking questions without contributing expertise
- Accepting answers without probing deeper with "why"
- Not citing sources when giving architectural advice
- Skipping risk identification
- Not updating drafts as conversation progresses
- Rushing toward generation instead of understanding
- Not referencing product.md, tech-stack.md, architecture.md

**The goal is collaborative understanding, not speed.**

---

## Step 3A: Intake Flow (Feature / Refactor)

### Phase 1: Existing Documentation
- "Do you have existing documentation for this work? (PRD, RFC, design doc, Jira ticket)"
- If yes: Ingest, extract key points, identify gaps
- AI contribution: "I've extracted [X, Y, Z]. I notice [gap] isn't covered yet."

### Phase 2: Problem Space
Walk through problem questions from intake-questions.md:
- What problem are we solving?
- Why does this problem matter now?
- Who experiences this pain?
- What's the scope boundary?

After each answer:
- Contribute relevant patterns, similar problems, domain concepts
- Challenge assumptions with "why" questions
- Update spec-draft.md Problem Statement section

**Checkpoint:** "Here's the problem as I understand it: [summary]. Does this capture it?"

### Phase 3: Solution Space
Walk through solution questions:
- What's the simplest version that solves this?
- Why this approach over alternatives?
- What are we explicitly NOT doing?
- How does this fit with current architecture?

After each answer:
- Present 2-3 alternative approaches with trade-offs
- Cross-reference architecture.md for integration points
- Suggest tech-stack.md patterns to leverage
- Update spec-draft.md Technical Approach and Non-Goals sections

**Checkpoint:** "The proposed approach is [summary]. I've identified these alternatives: [list]. Your reasoning for this choice is [X]. Correct?"

### Phase 4: Risk & Constraints
Walk through risk questions:
- What could go wrong?
- What dependencies or blockers exist?
- Why might this fail?
- Security or compliance considerations?

After each answer:
- Surface risks user may not have considered
- Reference OWASP, distributed systems fallacies, failure modes
- Fact-check assumptions against project context
- Update spec-draft.md with risks as Open Questions

**Checkpoint:** "Key risks identified: [list]. Are there others you're aware of?"

### Phase 5: Success Criteria
Walk through success questions:
- How do we know this is complete?
- How will we verify it works?
- What would make stakeholders accept this?

After each answer:
- Suggest measurable, testable acceptance criteria
- Recommend testing strategies appropriate to feature type
- Align with product.md goals
- Update spec-draft.md Acceptance Criteria section

**Checkpoint:** "Acceptance criteria so far: [list]. Missing anything?"

---

## Step 3B: Intake Flow (Bug & RCA)

For bugs, incidents, or Jira-sourced issues. Tighter scope, investigation-focused.

### Phase 1: Symptoms & Context
- "What's the exact error or unexpected behavior?"
- "Who is affected? How often does this occur?"
- "When did this start? Any recent changes?"

AI contribution: Pattern recognition for common bug types, severity assessment.

### Phase 2: Reproduction
- "What are the exact steps to reproduce?"
- "What environment conditions are required?"
- "What's the expected vs actual behavior?"

AI contribution: Suggest additional reproduction scenarios, edge cases to check.

### Phase 3: Blast Radius
- "What still works correctly?"
- "Where does the failure boundary lie?"

AI contribution: Help narrow investigation scope, reference architecture.md for module boundaries.

### Phase 4: Code Locality
- "Where do you suspect the bug is?"
- "What's the entry point and failure point?"

AI contribution: Suggest investigation approach, reference debugging patterns.

Update spec-draft.md with bug-specific structure after gathering sufficient context.

---

## Step 4: Draft Review & Refinement

After completing intake sections:

1. Present complete spec-draft.md summary
2. List any remaining Open Questions
3. Ask: "Want to refine any section, or ready to finalize?"

If refining:
- Continue conversation on specific sections
- Update drafts as discussion progresses
- Return to this step when ready

---

## Step 5: Finalize Specification

When user confirms spec is ready:

1. Update spec-draft.md status to `[x] Complete`
2. Rename `spec-draft.md` → `spec.md`
3. Update Context References with specific connections to product.md, tech-stack.md, architecture.md
4. Add Conversation Log summary with key decisions and reasoning

Present final spec.md for acknowledgment.

---

## Step 6: Create Plan

Based on finalized spec, build out plan-draft.md:

### For Feature / Refactor:
Create phased breakdown:
- Phase 1: Foundation / Setup
- Phase 2: Core Implementation
- Phase 3: Integration & Polish

For each phase:
- Define Goal and Verification criteria
- Break into specific Tasks with file references
- Identify dependencies between tasks

AI contribution:
- Suggest task ordering based on dependencies
- Reference tech-stack.md for implementation patterns
- Identify testing requirements per task
- Flag integration points with architecture.md modules

### For Bug & RCA:
Use fixed 3-phase structure:
- Phase 1: Investigate & Reproduce
- Phase 2: Root Cause Analysis
- Phase 3: Fix & Verify

Reference `core/agents/rca.md` for detailed process.

Present plan-draft.md for review.

---

## Step 7: Finalize Plan

When user confirms plan is ready:

1. Update plan-draft.md status to `[x] Complete`
2. Rename `plan-draft.md` → `plan.md`
3. Validate phases against spec requirements
4. Ensure all acceptance criteria are covered by tasks

Present final plan.md for acknowledgment.

---

## Step 8: Create Metadata & Update Tracks

### Pre-Validation

Before creating metadata, verify final files exist:

```bash
ls draft/tracks/<track_id>/spec.md draft/tracks/<track_id>/plan.md 2>/dev/null
```

If either missing:
- ERROR: "Track creation incomplete. Missing files: [list missing]"
- "Expected: spec.md and plan.md in draft/tracks/<track_id>/"
- Halt - do not create metadata.json or update tracks.md

### Create `draft/tracks/<track_id>/metadata.json`:

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

**Note:** ISO timestamps can use either `Z` or `.000Z` suffix (both valid ISO 8601). No format constraint enforced — both second precision (`2026-02-08T12:00:00Z`) and millisecond precision (`2026-02-08T12:00:00.000Z`) are acceptable.

### Update `draft/tracks.md`:

Add under Active:

```markdown
## Active

### [track_id] - [Title]
- **Status:** [ ] Planning
- **Created:** [date]
- **Phases:** 0/3
- **Path:** `./tracks/<track_id>/`
```

### Cleanup (Defensive)

Remove draft files if they still exist (defensive cleanup for failed renames):

```bash
rm -f draft/tracks/<track_id>/spec-draft.md
rm -f draft/tracks/<track_id>/plan-draft.md
```

The `-f` flag ensures idempotent cleanup whether files exist or not.

### Post-Validation

Verify tracks.md was updated successfully:

```bash
grep "<track_id>" draft/tracks.md
```

If not found:
- ERROR: "Failed to update tracks.md with new track entry"
- "Expected track_id '<track_id>' in draft/tracks.md Active section"
- Provide recovery: "Manually add track entry to draft/tracks.md or remove draft/tracks/<track_id>/ and retry"

---

## Completion

Announce:
"Track created: <track_id>

Created:
- draft/tracks/<track_id>/spec.md
- draft/tracks/<track_id>/plan.md
- draft/tracks/<track_id>/metadata.json

Updated:
- draft/tracks.md

Key decisions documented in spec.md Conversation Log.

Next: Review the spec and plan, then run `/draft:implement` to begin."
