---
name: jira-preview
description: Generate Jira export file from track plan for review before creating issues.
---

# Preview Jira Issues from Track Plan

Generate `jira-export.md` from the track's plan for review and editing before creating actual Jira issues.

## Red Flags - STOP if you're:

- Generating a preview without an approved plan.md
- Assigning story points inconsistent with task count
- Missing sub-tasks that exist in plan.md
- Not including quality findings when validation/bughunt reports exist
- Overwriting a reviewed jira-export.md without warning the user

**Plan first, then preview. Accuracy over speed.**

---

## Mapping Structure

| Draft Concept | Jira Entity |
|---------------|-------------|
| Track | Epic |
| Phase | Story |
| Task | Sub-task (under story) |

## Step 1: Load Context

1. **Capture git context first:**
   ```bash
   git branch --show-current    # Current branch name
   git rev-parse --short HEAD   # Current commit hash
   ```
2. Find active track from `draft/tracks.md` (look for `[~] In Progress` or first `[ ]` track)
3. If track ID provided as argument, use that instead
4. Read the track's `plan.md` for phases and tasks
5. Read the track's `metadata.json` for title and type
6. Read the track's `spec.md` for epic description
7. Read `core/templates/jira.md` for field structure
8. Check for quality reports:
   - `draft/tracks/<id>/validation-report.md` — compliance findings
   - `draft/tracks/<id>/bughunt-report.md` — defect findings

If no track found:
- Tell user: "No track found. Run `/draft:new-track` to create one, or specify track ID."

## Step 2: Parse Plan Structure

Extract from `plan.md`:

### Epic (from track)
- **Summary:** Track title from metadata.json or first `# Plan:` heading
- **Description:** Overview section from spec.md
- **Type:** Feature (from metadata.json type: feature|bugfix|refactor)

### Stories (from phases)
For each `## Phase N: [Name]` section:
- **Summary:** Phase name
- **Goal:** Extract from `**Goal:**` line
- **Verification:** Extract from `**Verification:**` line

### Sub-tasks (from tasks)
For each `- [ ] **Task N.M:**` within a phase:
- **Summary:** Task description (text after `**Task N.M:**`)
- **Parent:** The phase's story
- **Status:** Map `[ ]` → To Do, `[x]` → Done, `[~]` → In Progress, `[!]` → Blocked

### Story Points Calculation
Count tasks per phase and assign points to the **story**:

| Task Count | Story Points |
|------------|--------------|
| 1-2 tasks  | 1 point      |
| 3-4 tasks  | 2 points     |
| 5-6 tasks  | 3 points     |
| 7+ tasks   | 5 points     |

## Step 3: Extract Quality Findings (if reports exist)

If `validation-report.md` or `bughunt-report.md` exists in the track directory:

1. Parse findings by severity (Critical, High, Medium, Low)
2. Extract: severity, category, file location, issue description, fix recommendation
3. Group by severity for the export

**Critical/High findings** should be highlighted — consider suggesting additional stories or tasks to address them before the track is complete.

## Step 4: Generate Export File

Create `draft/tracks/<track_id>/jira-export.md`:

```markdown
# Jira Export: [Track Title]

**Generated:** [ISO timestamp]
**Track ID:** [track_id]
**Branch:** `[branch-name]`
**Commit:** `[short-hash]`
**Status:** Ready for review

> Edit this file to adjust story points, descriptions, or sub-tasks before running `/draft:jira-create`.

---

## Epic

**Summary:** [Track Title]
**Issue Type:** Epic
**Description:**
{noformat}
[Spec overview - first 2-3 paragraphs]

---
🤖 Generated with Draft (Context-Driven Development)
Branch: [branch-name] | Commit: [short-hash]
{noformat}

---

## Story 1: [Phase 1 Name]

**Summary:** Phase 1: [Phase Name]
**Issue Type:** Story
**Story Points:** [calculated based on task count]
**Epic Link:** (will be set on creation)

**Description:**
{noformat}
h3. Goal
[Phase goal]

h3. Verification
[Phase verification criteria]

---
🤖 Generated with Draft
{noformat}

### Sub-tasks

| # | Summary | Status |
|---|---------|--------|
| 1.1 | [Task 1.1 description] | To Do |
| 1.2 | [Task 1.2 description] | Done |
| 1.3 | [Task 1.3 description] | To Do |

---

## Story 2: [Phase 2 Name]

**Summary:** Phase 2: [Phase Name]
**Issue Type:** Story
**Story Points:** [calculated]
**Epic Link:** (will be set on creation)

**Description:**
{noformat}
h3. Goal
[Phase goal]

h3. Verification
[Phase verification criteria]

---
🤖 Generated with Draft
{noformat}

### Sub-tasks

| # | Summary | Status |
|---|---------|--------|
| 2.1 | [Task 2.1 description] | To Do |
| 2.2 | [Task 2.2 description] | To Do |

---

[Continue for all phases...]

---

## Quality Reports

### Validation Findings (informational)
| Severity | Category | File | Issue |
|----------|----------|------|-------|
| High | Security | src/auth.ts:45 | Hardcoded API key |
| Medium | Architecture | src/utils.ts:12 | Layer boundary violation |

> Validation findings are compliance issues. Include in Epic description for awareness.

---

## Bug Issues (from Bug Hunt Report)

Each bug from `bughunt-report.md` becomes a separate **Bug** issue linked to the Epic.

### Bug 1: [CRITICAL] Off-by-one error in pagination

**Summary:** [Correctness] Off-by-one error in pagination
**Issue Type:** Bug
**Priority:** Highest
**Epic Link:** (will be set on creation)

**Description:**
{noformat}
h3. Location
src/calc.ts:78

h3. Category
Correctness

h3. Issue
[Full description from bughunt-report.md]

h3. Impact
[User-visible or system failure mode]

h3. Recommended Fix
[Fix recommendation from report]

---
🤖 Generated with Draft (Bug Hunt)
Branch: [branch-name] | Commit: [short-hash]
{noformat}

---

### Bug 2: [HIGH] Race condition in cache update

**Summary:** [Concurrency] Race condition in cache update
**Issue Type:** Bug
**Priority:** High
**Epic Link:** (will be set on creation)

**Description:**
{noformat}
h3. Location
src/api.ts:92

h3. Category
Concurrency

h3. Issue
[Full description from bughunt-report.md]

h3. Impact
[User-visible or system failure mode]

h3. Recommended Fix
[Fix recommendation from report]

---
🤖 Generated with Draft (Bug Hunt)
Branch: [branch-name] | Commit: [short-hash]
{noformat}

---

[Continue for all bugs from bughunt-report.md...]

> **Priority Mapping:** Critical → Highest, High → High, Medium → Medium, Low → Low
> All bugs are linked to the Epic but are separate from Stories (phases).
```

## Step 5: Report

```
Jira Preview Generated

Track: [track_id] - [title]
Export: draft/tracks/<id>/jira-export.md

Summary:
- 1 epic
- N stories (phases)
- M sub-tasks (tasks)
- P total story points
- B bugs (from bughunt-report.md)

Breakdown:
- Phase 1: [name] - X pts, Y tasks
- Phase 2: [name] - X pts, Y tasks
- Phase 3: [name] - X pts, Y tasks

Bugs (if bughunt-report.md exists):
- X critical bugs
- Y high bugs
- Z medium/low bugs

Next steps:
1. Review and edit jira-export.md (adjust points, descriptions, sub-tasks, bug priorities)
2. Run `/draft:jira-create` to create issues in Jira
```

## Error Handling

**If plan.md has no phases:**
- Tell user: "No phases found in plan.md. Run `/draft:new-track` to generate a proper plan."

**If spec.md missing:**
- Use plan.md overview for epic description
- Warn: "spec.md not found, using plan overview for epic description."

**If jira-export.md already exists:**
- Warn: "jira-export.md already exists. Overwriting with fresh generation."
- Proceed with overwrite (user can always re-edit)

**If phase has no tasks:**
- Create story with 1 story point
- Add note: "No sub-tasks defined for this phase"
