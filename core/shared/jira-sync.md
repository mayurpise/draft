# Jira Sync Protocol

Standard procedure for syncing Draft artifacts to Jira via MCP.

**Referenced by:** `/draft:new-track`, `/draft:implement`, `/draft:review`, `/draft:bughunt`, `/draft:debug`, `/draft:deep-review`, `/draft:adr`, `/draft:init`

---

## Prerequisites

1. **Jira MCP available** — The Jira MCP server is connected and responding
2. **Ticket key exists** — A valid Jira ticket key (e.g., `PROJ-123`) is present in track metadata or provided by the user
3. **Artifact exists** — The Draft artifact to sync (spec, plan, review, report) has been generated

---

## MCP Operations

| Operation | MCP Tool | Use Case |
|-----------|----------|----------|
| `add_comment` | `jira_add_comment` | Post status updates, review summaries, implementation notes |
| `add_attachment` | `jira_add_attachment` | Attach spec.md, plan.md, review reports, RCA documents |
| `update_issue` | `jira_update_issue` | Update status, labels, custom fields, story points |

---

## Comment Format

All Draft comments posted to Jira follow this format:

```
[draft] {action}: {1-line summary}
```

### Examples

```
[draft] spec-created: Authentication flow spec with 5 acceptance criteria
[draft] plan-generated: 12-step implementation plan, estimated 3 story points
[draft] review-complete: 2 critical findings, 4 suggestions — see attachment
[draft] implementation-done: All 12 plan steps completed, tests passing
[draft] bug-found: Race condition in token refresh — RCA attached
[draft] incident-update: SEV2 — API latency resolved, monitoring stable
```

---

## Sync Triggers

| When | Artifact | Jira Action |
|------|----------|-------------|
| `/draft:new-track` completes | `spec.md` | Attach spec, comment with summary, update labels |
| `/draft:new-track` generates plan | `plan.md` | Attach plan, comment with step count and estimate |
| `/draft:implement` step completes | Step status | Comment with progress update |
| `/draft:implement` all steps done | Final status | Comment with completion summary, update issue status |
| `/draft:review` completes | Review report | Attach report, comment with finding counts |
| `/draft:bughunt` finds issues | `bughunt-report.md` | Attach report, comment with bug count and severities |
| `/draft:debug` resolves issue | Debug summary | Comment with root cause and fix applied |
| `/draft:incident-response` updates | Incident status | Comment with severity and current status |

---

## Sync Procedure

### Step 1: Verify MCP Connection

Check that the Jira MCP server is available. If not, skip sync and log to `.jira-sync-queue.json`.

### Step 2: Extract Ticket Key

Look for the Jira ticket key in this order:
1. `metadata.json` → `jira_key` field in the current track
2. User-provided key in the command invocation
3. Branch name pattern: `{KEY}-{number}` (e.g., `PROJ-123-feature-name`)

If no key is found, skip sync silently.

### Step 3: Attach Artifact

If the artifact is a file (spec, plan, report):
- Use `jira_add_attachment` to attach the file to the ticket
- File name follows the pattern: `draft-{artifact-type}-{timestamp}.md`

### Step 4: Post Comment

Post a structured comment using the format defined above:
- Include the action type and a 1-line summary
- For implementation progress, include step X/Y completion status
- For reviews, include finding counts by severity

### Step 5: Update Fields

Update Jira fields based on the action:
- After spec creation: add label `draft:spec-ready`
- After plan generation: update story points if estimated
- After implementation: transition status if workflow allows
- After review: add label `draft:reviewed`

### Step 6: Record in Metadata

Write sync record to the track's `metadata.json`:

```json
{
  "jira_sync": {
    "last_sync": "{ISO_TIMESTAMP}",
    "ticket_key": "{JIRA_KEY}",
    "synced_artifacts": ["spec.md", "plan.md"],
    "comment_ids": ["12345", "12346"]
  }
}
```

---

## Failure Handling

Jira sync is a **non-blocking** operation. Failures must never break the parent skill.

1. **Don't fail the parent skill** — If Jira sync fails, log the error and continue. The Draft workflow takes priority over Jira bookkeeping.

2. **Save to queue** — On failure, write the pending sync operation to `draft/.state/.jira-sync-queue.json`:

```json
{
  "queue": [
    {
      "timestamp": "{ISO_TIMESTAMP}",
      "ticket_key": "{JIRA_KEY}",
      "action": "add_comment",
      "payload": "[draft] spec-created: Authentication flow spec with 5 acceptance criteria",
      "error": "MCP connection timeout",
      "retries": 0
    }
  ]
}
```

3. **Retry on next connection** — When the next Draft skill runs and Jira MCP is available, flush the queue before proceeding with new sync operations. Retry each queued item once. If it fails again, leave it in the queue with `retries` incremented.
