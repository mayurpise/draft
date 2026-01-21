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

If missing, tell user: "Project not initialized. Run `/draft:setup` first."

2. Load context:
- Read `draft/product.md` for product vision
- Read `draft/tech-stack.md` for technical constraints
- Read `draft/workflow.md` for development standards

## Step 1: Generate Track ID

Create a short, kebab-case ID from the description:
- "Add user authentication" → `add-user-auth`
- "Fix login bug" → `fix-login-bug`
- Include timestamp suffix if needed: `add-user-auth-0120`

## Step 2: Create Specification

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

## Summary
[2-3 sentence description of what this track delivers]

## Background
[Why this is needed, context from product.md]

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
[High-level approach based on tech-stack.md]

## Open Questions
- [Question 1]
- [Question 2]
```

Present for approval. Iterate until approved.

## Step 3: Create Plan

Based on approved spec, create phased task breakdown.

Create `draft/tracks/<track_id>/plan.md`:

```markdown
# Plan: [Title]

**Track ID:** <track_id>
**Spec:** ./spec.md
**Status:** [ ] Not Started

## Overview
[Brief summary linking to spec]

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
