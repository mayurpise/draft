---
name: implement
description: Execute tasks from the current track's plan using TDD workflow. Implements tasks phase by phase with progress tracking.
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

**Iron Law:** No production code without a failing test first.

**3a. RED - Write Failing Test**
```
1. Create/update test file as specified in task
2. Write test that captures the requirement
3. RUN test - VERIFY it FAILS (not syntax error, actual assertion failure)
4. Show test output with failure
5. Announce: "Test failing as expected: [failure message]"
```

**3b. GREEN - Implement Minimum Code**
```
1. Write MINIMUM code to make test pass (no extras)
2. RUN test - VERIFY it PASSES
3. Show test output with pass
4. Announce: "Test passing: [evidence]"
```

**3c. REFACTOR - Clean with Tests Green**
```
1. Review code for improvements
2. Refactor while keeping tests green
3. RUN all related tests after each change
4. Show final test output
5. Announce: "Refactoring complete, all tests passing: [evidence]"
```

**Red Flags - STOP and restart the cycle if:**
- About to write code before test exists
- Test passes immediately (testing wrong thing)
- Thinking "just this once" or "too simple to test"
- Running tests mentally instead of actually executing

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

## Verification Gate (REQUIRED)

**Iron Law:** No completion claims without fresh verification evidence.

Before marking ANY task/phase/track complete:

1. **IDENTIFY:** What command proves this claim? (test, build, lint)
2. **RUN:** Execute the FULL command (fresh, complete run)
3. **READ:** Full output, check exit code
4. **VERIFY:** Does output confirm the claim?
   - If **NO**: Keep task as `[~]`, state actual status
   - If **YES**: Show evidence, then mark `[x]`

**Red Flags - STOP if you're thinking:**
- "Should pass", "probably works"
- Satisfaction before running verification
- About to mark `[x]` without evidence THIS MESSAGE
- "I already tested earlier"
- "This is a simple change, no need to verify"

---

## Step 5: Phase Boundary Check

When all tasks in a phase are `[x]`:

1. Announce: "Phase N complete. Running two-stage review."

### Two-Stage Review (REQUIRED)

**Stage 1: Spec Compliance**
- Load track's `spec.md`
- Verify all requirements for this phase are implemented
- Check acceptance criteria coverage
- **If gaps found:** List them, return to implementation

**Stage 2: Code Quality** (only if Stage 1 passes)
- Verify code follows project patterns (tech-stack.md)
- Check error handling is appropriate
- Verify tests cover real logic
- Classify issues: Critical (must fix) > Important (should fix) > Minor (note)

See `core/agents/reviewer.md` for detailed review process.

2. Run verification steps from plan (tests, builds)
3. Present review findings to user
4. If review passes (no Critical issues):
   - Update phase status in plan
   - Update `metadata.json` phases.completed
   - Proceed to next phase
5. If Critical/Important issues found:
   - Document issues in plan.md
   - Fix before proceeding (don't skip)

## Step 6: Track Completion

When all phases complete:

1. Update `plan.md` status to `[x] Completed`
2. Update `metadata.json` status to `"completed"`
3. Update `draft/tracks.md`:
   - Move from Active to Completed section
   - Add completion date

4. Announce:
"Track <track_id> completed!

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
- **REQUIRED:** Follow systematic debugging process (see `core/agents/debugger.md`)
  1. **Investigate** - Read errors, reproduce, trace (NO fixes yet)
  2. **Analyze** - Find similar working code, list differences
  3. **Hypothesize** - Single hypothesis, smallest test
  4. **Implement** - Regression test first, then fix
- Do NOT attempt random fixes
- Document root cause when found

**If test fails unexpectedly:**
- Don't mark complete
- Follow systematic debugging process above
- Announce failure details with root cause analysis
- Show evidence when resolved

**If unsure about implementation:**
- Ask clarifying questions
- Reference spec.md for requirements
- Don't proceed with assumptions

## Progress Reporting

After each task, report:
```
Task: [description]
Status: Complete
Phase Progress: N/M tasks
Overall: X% complete
```
