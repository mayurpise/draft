---
project: "{PROJECT_NAME}"
module: "root"
track_id: "{TRACK_ID}"
generated_by: "draft:new-track"
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

# Plan: {TITLE}

| Field | Value |
|-------|-------|
| **Branch** | `{LOCAL_BRANCH}` → `{REMOTE/BRANCH}` |
| **Commit** | `{SHORT_SHA}` — {COMMIT_MESSAGE} |
| **Generated** | {ISO_TIMESTAMP} |
| **Synced To** | `{FULL_SHA}` |

**Track ID:** {TRACK_ID}
**Spec:** ./spec.md
**Status:** [ ] Planning

## Overview

{One-paragraph summary of what this plan delivers, derived from spec.md}

---

## Phase 1: Foundation

**Goal:** {What this phase establishes}
**Verification:** {How to confirm phase is complete}

### Tasks

- [ ] **Task 1.1:** {Description} — `{file_path}`
- [ ] **Task 1.2:** {Description} — `{file_path}`

---

## Phase 2: Core Implementation

**Goal:** {What this phase delivers}
**Verification:** {How to confirm phase is complete}

### Tasks

- [ ] **Task 2.1:** {Description} — `{file_path}`
- [ ] **Task 2.2:** {Description} — `{file_path}`

---

## Phase 3: Integration & Polish

**Goal:** {What this phase delivers}
**Verification:** {How to confirm phase is complete — run full test suite, manual verification}

### Tasks

- [ ] **Task 3.1:** {Description} — `{file_path}`
- [ ] **Task 3.2:** Verify — {Run tests, confirm all acceptance criteria met}

---

## Status Markers

- `[ ]` Pending
- `[~]` In Progress
- `[x]` Completed — append commit SHA: `(abc1234)`
- `[!]` Blocked — note reason
