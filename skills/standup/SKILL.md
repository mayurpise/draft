---
name: standup
description: Generate standup summary from git history, track progress, and Jira/Gerrit activity. Read-only — makes no changes to the codebase.
---

# Standup

You are generating a standup summary using Draft's Context-Driven Development methodology. This is a **read-only** skill — it makes no changes to the codebase, tracks, or any files.

## Red Flags - STOP if you're:

- Modifying any files (this is read-only)
- Making up git history or progress data
- Reporting on tracks without reading their actual state
- Summarizing without checking actual commit messages
- Fabricating Jira or Gerrit data

**Read-only. Report facts. No modifications.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context (if available)

```bash
ls draft/ 2>/dev/null
```

If `draft/` exists:
- Read `draft/tracks.md` for active tracks
- Read `draft/workflow.md` for team conventions and standup preferences

No Draft context is fine — standup falls back to git-only mode.

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:standup` | Generate standup for today (default: last 24 hours) |
| `/draft:standup <date>` | Generate standup for a specific date (YYYY-MM-DD) |
| `/draft:standup week` | Generate weekly summary |
| `/draft:standup save` | Generate and save to file |

---

## Step 2: Gather Data

### 2.1: Git History

Gather commits from the relevant time period:

```bash
# Last 24 hours (default)
git log --oneline --since="24 hours ago" --author="$(git config user.name)" --no-merges

# Specific date
git log --oneline --after="<date> 00:00:00" --before="<date> 23:59:59" --author="$(git config user.name)" --no-merges

# Weekly
git log --oneline --since="7 days ago" --author="$(git config user.name)" --no-merges
```

For each commit, also gather:
```bash
# Files changed per commit (summary)
git show --stat --format="" <sha>
```

### 2.2: Track Progress (if Draft context exists)

For each active track in `draft/tracks.md`:

1. Read `draft/tracks/<id>/metadata.json`:
   - Tasks completed vs. total
   - Current phase
   - Status

2. Read `draft/tracks/<id>/plan.md`:
   - Find `[x]` tasks completed in the time period (match commit SHAs from git log)
   - Find `[~]` tasks currently in progress
   - Find `[!]` blocked tasks

3. Check for reports generated in the time period:
   ```bash
   ls -lt draft/tracks/<id>/*report*.md 2>/dev/null | head -5
   ```

### 2.3: Jira Activity (if MCP available)

If Jira MCP is available:
- Fetch issues updated by current user in the time period
- Gather: issue key, summary, status transitions, comments added

If MCP not available, skip silently (do not error).

### 2.4: Gerrit Activity (if MCP available)

If Gerrit MCP is available:
- Fetch changes authored/reviewed by current user in the time period
- Gather: change ID, subject, status (merged, reviewing, WIP)

If MCP not available, skip silently (do not error).

### 2.5: Work In Progress

Check current working state:
```bash
# Uncommitted changes
git status --short

# Current branch purpose (from branch name convention)
git branch --show-current
```

---

## Step 3: Generate Standup

### Standard Format (Yesterday / Today / Blockers)

```
═══════════════════════════════════════════════════════════
                     STANDUP SUMMARY
═══════════════════════════════════════════════════════════
Date: [YYYY-MM-DD]
Author: [git user.name]
Branch: [current branch]

YESTERDAY (completed)
─────────────────────────────────────────────────────────
[If commits exist:]
• [commit message 1] ([short SHA])
  Files: [N] changed in [module/area]
• [commit message 2] ([short SHA])
  Files: [N] changed in [module/area]

[If track context:]
Track Progress:
• [track-id]: [N]/[M] tasks complete ([percentage]%)
  Completed: [task description from plan.md]

[If Jira:]
Jira:
• [JIRA-KEY]: [summary] → [status transition]

[If Gerrit:]
Gerrit:
• [change-id]: [subject] — [status]

[If no activity:]
• No commits in the last 24 hours

TODAY (planned)
─────────────────────────────────────────────────────────
[If track context with pending tasks:]
• [track-id]: Next task — [task description from plan.md]
  Phase: [current phase] ([N] tasks remaining)

[If WIP detected:]
• Continue work on branch [branch-name]
  Uncommitted changes: [N] files modified

[If no track context:]
• [Inferred from branch name and recent work]

BLOCKERS
─────────────────────────────────────────────────────────
[If blocked tasks found:]
• [track-id] — Task: [description]
  Reason: [from plan.md blocked task notes]

[If no blockers:]
• None

═══════════════════════════════════════════════════════════
```

### Weekly Format (additional)

When `week` argument is used, add a summary section:

```
WEEKLY SUMMARY
─────────────────────────────────────────────────────────
Commits: [N] total
Tracks progressed: [list with delta]
  • [track-id]: [start]% → [end]% (+[delta]%)
Tracks completed: [list or "none"]
Reviews: [N] (if Gerrit data available)
Jira issues closed: [N] (if Jira data available)
```

---

## Step 4: Present Results

Display the standup in the conversation.

### Save Option

If `save` argument provided or developer requests saving:

```bash
mkdir -p draft
```

Save to `draft/standup-<date>.md` (e.g., `draft/standup-2026-03-15.md`):

```markdown
---
date: "[YYYY-MM-DD]"
author: "[git user.name]"
generated_by: "draft:standup"
---

# Standup: [YYYY-MM-DD]

[Full standup content from Step 3]
```

Announce save location:
```
Standup saved to: draft/standup-<date>.md
```

---

## Cross-Skill Dispatch

### Inbound

- **Standalone** — invoked directly by developer

### Outbound

- **Reads `/draft:status` data** — uses track progress information for standup generation
- **No downstream dispatch** — standup is informational only, does not trigger other skills

---

## Error Handling

### No Git History

```
No commits found in the time period.

Git user: [git config user.name]
Period: [time range searched]

Verify:
- Git user.name matches your commit author
- You have commits in this time period
- The repository has recent history (not a shallow clone)
```

### No Draft Context

```
No Draft context found. Generating git-only standup.

For richer standup with track progress, run /draft:init first.
```

### Empty Standup

If no activity found across any source:

```
No activity found for [date/period].

Sources checked:
- Git history: 0 commits
- Track progress: [N/A or no changes]
- Jira: [N/A or no updates]
- Gerrit: [N/A or no activity]

Nothing to report.
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Modify any files silently | This skill is read-only |
| Fabricate commit messages | Report actual git log output |
| Guess at track progress | Read metadata.json and plan.md |
| Include other people's commits | Filter by git user.name |
| Report Jira/Gerrit data without MCP | Skip gracefully, don't fabricate |

---

## Examples

### Daily standup
```bash
/draft:standup
```

### Standup for specific date
```bash
/draft:standup 2026-03-14
```

### Weekly summary
```bash
/draft:standup week
```

### Save standup to file
```bash
/draft:standup save
```
