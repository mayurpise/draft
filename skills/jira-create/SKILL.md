---
name: jira-create
description: Create Jira issues from jira-export.md via MCP. Auto-generates export if missing.
---

# Create Jira Issues from Export

Create Jira epic, stories, and sub-tasks from `jira-export.md` using MCP-Jira. If no export file exists, auto-generates one first.

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
4. Check for `draft/tracks/<track_id>/jira-export.md`

If no track found:
- Tell user: "No track found. Run `/draft:new-track` to create one, or specify track ID."

## Step 2: Ensure Export Exists

**If `jira-export.md` exists:**
- Read and parse the export file
- Proceed to Step 3

**If `jira-export.md` missing:**
- Inform user: "No jira-export.md found. Generating preview first..."
- Execute `/draft:jira-preview` logic to generate it
- Proceed to Step 3

## Step 3: Check MCP-Jira Availability

Attempt to detect MCP-Jira tools:
1. Check if `mcp_jira_create_issue` or similar tool is available
2. If unavailable:
   ```
   MCP-Jira not configured.

   To create issues:
   1. Configure MCP-Jira server in your settings
   2. Run `/draft:jira-create` again

   Or manually import from:
     draft/tracks/<id>/jira-export.md
   ```
   - Stop execution

## Step 4: Parse Export File

Extract from `jira-export.md`:

### Epic
- Summary (from `**Summary:**` line)
- Description (from `{noformat}` block)
- Issue Type: Epic

### Stories
For each `## Story N:` section:
- Summary
- Story Points (from `**Story Points:**` line)
- Description (from `{noformat}` block)

### Sub-tasks
For each row in `### Sub-tasks` table:
- Task number (e.g., 1.1, 1.2)
- Summary
- Status (To Do, Done, In Progress, Blocked)

### Quality Findings (if present)
If export contains `## Quality Reports` section:
- Parse validation findings table
- Parse bughunt findings table
- Extract severity, category, file, issue for each

## Step 5: Create Issues via MCP

### 5a. Create Epic
```
MCP call: create_issue
- project: [from config or prompt]
- issue_type: Epic
- summary: [Epic summary]
- description: [Epic description]
```
- Capture epic key (e.g., PROJ-123)
- Report: "Created Epic: PROJ-123"

### 5b. Create Stories (one per phase)
For each story in export:
```
MCP call: create_issue
- project: [same as epic]
- issue_type: Story
- summary: [Story summary]
- description: [Story description]
- story_points: [from export]
- epic_link: [Epic key from step 5a]
```
- Capture story key (e.g., PROJ-124)
- Report: "Created Story: PROJ-124 - Phase 1 (3 pts)"

### 5c. Create Sub-tasks (one per task)
For each sub-task under the story:
```
MCP call: create_issue
- project: [same as epic]
- issue_type: Sub-task
- parent: [Story key from step 5b]
- summary: [Task summary, e.g., "Task 1.1: Extract logging utilities"]
- status: [Map from export: To Do, In Progress, Done]
```
- Capture sub-task key (e.g., PROJ-125)
- Report: "  - Sub-task: PROJ-125 - Task 1.1"

### 5d. Create Bug Issues (from Bug Hunt Report)

For **each bug** in the `## Bug Issues` section of jira-export.md, create a separate Bug issue:

```
MCP call: create_issue
- project: [same as epic]
- issue_type: Bug
- summary: [Category] [Brief issue description]
- description: {noformat}
  h3. Location
  [file:line]

  h3. Category
  [Bug category from report]

  h3. Issue
  [Full issue description]

  h3. Impact
  [User-visible or system failure mode]

  h3. Recommended Fix
  [Fix recommendation from report]

  ---
  🤖 Generated with Draft (Bug Hunt)
  Branch: [branch-name] | Commit: [short-hash]
  {noformat}
- epic_link: [Epic key from step 5a]
- priority: [Map from severity]
```

**Priority Mapping:**
| Severity | Jira Priority |
|----------|---------------|
| Critical | Highest |
| High | High |
| Medium | Medium |
| Low | Low |

- Capture bug key (e.g., PROJ-131)
- Report: "- Bug: PROJ-131 - [Critical] Correctness: Off-by-one error"

**All bugs from bughunt-report.md get their own Bug issue.** They are linked to the Epic but separate from Stories (phases). This keeps implementation work (Stories/Sub-tasks) distinct from defect tracking (Bugs).

## Step 6: Update Tracking

1. **Update plan.md:**
   Add Jira keys to phase headers and tasks:
   ```markdown
   ## Phase 1: Setup [PROJ-124]
   ...
   - [x] **Task 1.1:** Extract logging utilities [PROJ-125]
   - [x] **Task 1.2:** Extract security utilities [PROJ-126]
   ```

2. **Update jira-export.md:**
   Change status and add keys:
   ```markdown
   **Status:** Created
   **Epic Key:** PROJ-123

   ## Story 1: [Phase Name] [PROJ-124]

   ### Sub-tasks
   | # | Summary | Status | Key |
   |---|---------|--------|-----|
   | 1.1 | Extract logging utilities | Done | PROJ-125 |
   | 1.2 | Extract security utilities | Done | PROJ-126 |
   ```

## Step 7: Report

```
Jira Issues Created

Track: [track_id] - [title]
Project: [PROJ]

Created:
- Epic: PROJ-123 - [Track title]
- Story: PROJ-124 - Phase 1: [name] (3 pts)
  - Sub-task: PROJ-125 - Task 1.1
  - Sub-task: PROJ-126 - Task 1.2
  - Sub-task: PROJ-127 - Task 1.3
- Story: PROJ-128 - Phase 2: [name] (5 pts)
  - Sub-task: PROJ-129 - Task 2.1
  - Sub-task: PROJ-130 - Task 2.2
  [...]

Bugs (from Bug Hunt):
- Bug: PROJ-131 - [Critical] Correctness: Off-by-one error in pagination
- Bug: PROJ-132 - [High] Concurrency: Race condition in cache update
- Bug: PROJ-133 - [Medium] Security: Missing input validation

Total: 1 epic, N stories, M sub-tasks, B bugs, P story points

Updated:
- plan.md (added issue keys to phases and tasks)
- jira-export.md (marked as created with keys)
```

## Error Handling

**If MCP call fails:**
```
Failed to create [Epic/Story/Sub-task]: [error message]

Partial creation:
- Epic: PROJ-123 (created)
- Story 1: PROJ-124 (created)
  - Sub-task 1.1: PROJ-125 (created)
  - Sub-task 1.2: FAILED - [error]
- Story 2: (skipped)

Fix the issue and run `/draft:jira-create` again.
Already-created issues will be detected by keys in jira-export.md.
```

**If export has existing keys:**
- Skip items that already have Jira keys
- Only create items without keys
- Report: "Skipped Story 1 (already exists: PROJ-124)"
- Still create sub-tasks if story exists but sub-tasks don't have keys

**If project not configured:**
- Prompt user: "Which Jira project should issues be created in?"
- Store in `draft/workflow.md` for future use

**If plan.md phases don't match export:**
- Warn: "Export has N stories but plan has M phases. Proceeding with export structure."
- Create based on export (user may have manually edited it)

**If sub-task creation not supported:**
- Some Jira configurations may not allow sub-tasks
- Fall back to adding tasks as checklist items in story description
- Warn: "Sub-tasks not supported in this project. Tasks added to story description."
