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
6. Check if `architecture_mode: true` in `workflow.md` → enables pre-implementation design steps
7. If architecture mode is on, check for `draft/tracks/<id>/architecture.md` or `draft/architecture.md`

If no active track found:
- Tell user: "No active track found. Run `/draft:new-track` to create one."

## Step 2: Find Next Task

Scan `plan.md` for the first uncompleted task:
- `[ ]` = Pending (pick this one)
- `[~]` = In Progress (resume this one)
- `[x]` = Completed (skip)
- `[!]` = Blocked (skip, notify user)

If resuming `[~]` task, check for partial work.

## Step 2.5: Write Story (Architecture Mode Only)

**Activation:** Only runs when `architecture_mode: true` is set in `workflow.md`.

When the next task involves creating or substantially modifying a code file:

1. **Check if file already has a Story comment** - If yes, skip this step
2. **Skip for trivial tasks** - Config files, type definitions, simple one-liners
3. **Write a natural-language algorithm description** as a comment block at the top of the target file

### Story Format

```
// Story: [Module/File Name]
//
// Input:  [what this module/function receives]
// Process:
//   1. [first algorithmic step]
//   2. [second algorithmic step]
//   3. [third algorithmic step]
// Output: [what this module/function produces]
//
// Dependencies: [what this module relies on]
// Side effects: [any mutations, I/O, or external calls]
```

Adapt comment syntax to the language (`#` for Python, `/* */` for CSS, etc.).

### CHECKPOINT (MANDATORY)

**STOP.** Present the Story to the developer for review.

- Developer may refine, modify, or rewrite the Story
- **Do NOT proceed to execution state or implementation until Story is approved**
- Developer can say "skip" to bypass this checkpoint for the current task

See `core/agents/architect.md` for story writing guidelines.

---

## Step 3: Execute Task

### Step 3.0: Design Before Code (Architecture Mode Only)

**Activation:** Only runs when `architecture_mode: true` is set in `workflow.md`.
**Skip for trivial tasks** - Config updates, type-only changes, single-function tasks where the design is obvious.

#### 3.0a. Execution State Design

Study the control flow for the task and propose intermediate state variables:

1. Read the Story (from Step 2.5) to understand the Input -> Output path
2. Study similar patterns in the existing codebase
3. Propose execution state: input state, intermediate state, output state, error state

Present in this format:
```
EXECUTION STATE: [Task/Module Name]
─────────────────────────────────────────────────────────
Input State:
  - variableName: Type — purpose

Intermediate State:
  - variableName: Type — purpose

Output State:
  - variableName: Type — purpose

Error State:
  - variableName: Type — purpose
```

**CHECKPOINT (MANDATORY):** Present execution state to developer. Wait for approval. Developer may add, remove, or modify state variables. Developer can say "skip" to bypass.

#### 3.0b. Function Skeleton Generation

Generate function/method stubs based on the approved execution state:

1. Create stubs with complete signatures (all parameters, return types)
2. Include a one-line docstring describing purpose and when it's called
3. No implementation bodies — use `// TODO`, `pass`, `unimplemented!()`, etc.
4. Order functions to match control flow sequence
5. Follow naming conventions from `tech-stack.md`

**CHECKPOINT (MANDATORY):** Present skeletons to developer. Wait for approval. Developer may rename functions, change signatures, add/remove methods. Developer can say "skip" to bypass.

See `core/agents/architect.md` for execution state and skeleton guidelines.

---

### Step 3.1: Implement (TDD Workflow)

For each task, follow this workflow based on `workflow.md`. If skeletons were generated in Step 3.0b, fill them in using the TDD cycle below.

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

### Implementation Chunk Limit (Architecture Mode Only)

**Activation:** Only applies when `architecture_mode: true` is set in `workflow.md`.

If the implementation diff for a task exceeds **~200 lines**:

1. **STOP** after ~200 lines of implementation
2. Present the chunk for developer review
3. **CHECKPOINT (MANDATORY):** Wait for developer approval of the chunk
4. Commit the approved chunk: `feat(<track_id>): <task description> (chunk N)`
5. Continue with the next chunk
6. Repeat until the task is fully implemented

This prevents large, unreviewable code drops. Each chunk should be a coherent, reviewable unit.

---

## Step 4: Update Progress & Commit

**Iron Law:** Every completed task gets its own commit. No batching. No skipping.

After completing each task:

1. Commit FIRST (REQUIRED - non-negotiable):
   - Stage only files changed by this task (never `git add .`)
   - `git add <specific files>`
   - `git commit -m "type(<track_id>): task description"`
   - Do NOT proceed to the next task without committing
   - Do NOT batch multiple tasks into one commit

2. Update `plan.md`:
   - Change `[ ]` to `[x]` for the completed task
   - Add the commit SHA next to the task

3. Update `metadata.json`:
   - Increment `tasks.completed`
   - Update `updated` timestamp

4. If `architecture.md` exists for the track:
   - Update module status markers (`[ ]` → `[~]` when first task in module starts, `[~]` → `[x]` when all tasks complete)
   - Fill in Story placeholders with the approved story from Step 2.5

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

1. **Run validation (if enabled):**
   - Read `draft/workflow.md` validation configuration
   - Check if auto-validation enabled:
     ```markdown
     ## Validation
     - [x] Auto-validate at track completion
     ```
   - If enabled, run `/draft:validate --track <track_id>`
   - Check validation results:
     - If block-on-failure enabled AND critical issues found → HALT, require fixes
     - Otherwise, document warnings and continue

2. Update `plan.md` status to `[x] Completed`
3. Update `metadata.json` status to `"completed"`
4. Update `draft/tracks.md`:
   - Move from Active to Completed section
   - Add completion date

5. Announce:
"Track <track_id> completed!

Summary:
- Phases: N/N
- Tasks: M/M
- Duration: [if tracked]

[If validation ran:]
Validation: ✓ [pass] | ⚠ [warn] | ✗ [critical]
Report: draft/tracks/<track_id>/validation-report.md

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
