---
description: Execute tasks from the current track's plan using TDD workflow
allowed-tools: Bash(*), Read, Write, Edit
---

# Implement Track

You are implementing tasks from the active track's plan following the TDD workflow.

## Step 1: Load Context

1. Find active track from `draft/tracks.md` (look for `[~] In Progress` or first `[ ]` track)
2. Read the track's `spec.md` for requirements
3. Read the track's `plan.md` for task list
4. Read `draft/workflow.md` for TDD and commit preferences
5. Read `draft/tech-stack.md` for technical context

If no active track found:
- Tell user: "No active track found. Run `/draft:new-track` to create one."

## Step 2: Find Next Task

Scan `plan.md` for the first uncompleted task:
- `[ ]` = Pending (pick this one)
- `[~]` = In Progress (resume this one)
- `[x]` = Completed (skip)
- `[!]` = Blocked (skip, notify user)

If resuming `[~]` task, check for partial work.

## Step 3: Execute Task (TDD Workflow)

For each task, follow this workflow based on `workflow.md`:

### If TDD Enabled:

**3a. Write Failing Test**
```
1. Create/update test file as specified in task
2. Write test that captures the requirement
3. Run test to confirm it fails
4. Announce: "Test written and failing as expected"
```

**3b. Implement Minimum Code**
```
1. Write minimum code to make test pass
2. Run test to confirm it passes
3. Announce: "Implementation complete, test passing"
```

**3c. Refactor**
```
1. Review code for improvements
2. Refactor while keeping tests green
3. Run all related tests
4. Announce: "Refactoring complete, all tests passing"
```

### If TDD Not Enabled:

**3a. Implement**
```
1. Implement the task as specified
2. Test manually or run existing tests
3. Announce: "Implementation complete"
```

## Step 4: Update Progress

After completing each task:

1. Update `plan.md`:
   - Change `[ ]` to `[x]` for the completed task
   - Add completion note with commit SHA if available

2. Update `metadata.json`:
   - Increment `tasks.completed`
   - Update `updated` timestamp

3. Commit (if workflow specifies):
```bash
git add .
git commit -m "feat(<track_id>): <task description>"
```

## Step 5: Phase Boundary Check

When all tasks in a phase are `[x]`:

1. Announce: "Phase N complete. Verification required."
2. Read verification steps from plan
3. Guide user through verification
4. Wait for user confirmation
5. If verified:
   - Update phase status in plan
   - Update `metadata.json` phases.completed
   - Proceed to next phase
6. If issues found:
   - Document issues
   - Ask if should fix before proceeding

## Step 6: Track Completion

When all phases complete:

1. Update `plan.md` status to `[x] Completed`
2. Update `metadata.json` status to `"completed"`
3. Update `draft/tracks.md`:
   - Move from Active to Completed section
   - Add completion date

4. Announce:
"✓ Track <track_id> completed!

Summary:
- Phases: N/N
- Tasks: M/M
- Duration: [if tracked]

All acceptance criteria from spec.md should be verified.

Next: Run `/draft:status` to see project overview."

## Error Handling

**If blocked:**
- Mark task as `[!]` Blocked
- Add reason in plan.md
- Skip to next non-blocked task
- Announce: "Task blocked: [reason]. Moving to next task."

**If test fails unexpectedly:**
- Don't mark complete
- Announce failure details
- Ask user how to proceed

**If unsure about implementation:**
- Ask clarifying questions
- Reference spec.md for requirements
- Don't proceed with assumptions

## Progress Reporting

After each task, report:
```
Task: [description]
Status: ✓ Complete
Phase Progress: N/M tasks
Overall: X% complete
```
