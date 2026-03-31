---
name: implement
description: Execute tasks from the current track's plan using TDD workflow. Implements tasks phase by phase with progress tracking.
---

# Implement Track

You are implementing tasks from the active track's plan following the TDD workflow.

## Red Flags - STOP if you're:

- Implementing without an approved spec and plan
- Skipping TDD cycle when workflow.md has TDD enabled
- Marking a task `[x]` without fresh verification evidence
- Batching multiple tasks into a single commit
- Proceeding past a phase boundary without running the three-stage review
- Writing production code before a failing test (when TDD is strict)
- Assuming a test passes without actually running it

**Verify before you mark complete. One task, one commit.**

## Constraints

Draft skills are designed for single-agent, single-track execution. Do not run multiple Draft commands concurrently on the same track.

---

## Step 1: Load Context

1. Find active track from `draft/tracks.md` (look for `[~] In Progress` or first `[ ]` track)
2. Read the track's `spec.md` for requirements
3. Read the track's `plan.md` for task list
4. Read `draft/workflow.md` for TDD and commit preferences
5. Read `draft/tech-stack.md` for technical context
6. **Check for architecture context:**
   - Track-level: `draft/tracks/<id>/architecture.md`
   - Project-level: `draft/.ai-context.md` (or legacy `draft/architecture.md`)
   - If either exists → **Enable architecture mode** (Story, Execution State, Skeletons)
   - If neither exists → Standard TDD workflow
7. **Load production invariants** (if `draft/.ai-context.md` exists):
   - Read the `## INVARIANTS` section (and `## CONCURRENCY` if present)
   - Identify which invariants reference files this task will modify (same file or same module)
   - Keep matching invariants as **active constraints** for this task — these govern code generation, not just review
   - If invariants reference lock ordering, fail-closed behavior, or data integrity rules: these are non-negotiable during implementation

If no active track found:
- Tell user: "No active track found. Run `/draft:new-track` to create one."

**Architecture Mode Activation:**
- Automatically enabled when `.ai-context.md` or `architecture.md` exists (file-based, no flag needed)
- Track-level architecture.md created by `/draft:decompose`
- Project-level `.ai-context.md` created by `/draft:init` (brownfield only)

## Step 1.5: Readiness Gate (Fresh Start Only)

**Skip if:** Any task in `plan.md` is already `[x]` — the track is in progress, this check has already passed.

Run once, before the first task of a new track:

### AC Coverage Check

For each acceptance criterion in `spec.md`:
- Verify at least one task in `plan.md` references or addresses it
- If an AC has no corresponding task, flag it: "⚠️ AC: '[criterion]' has no task in plan.md"

### Sync Check (if `.ai-context.md` exists)

Compare the `synced_to_commit` values in the YAML frontmatter of `spec.md` and `plan.md`.
- **Skip if** either file has no YAML frontmatter or no `synced_to_commit` field (quick-mode tracks omit it).
- If they differ: "⚠️ Spec and plan were synced to different commits — verify they are still aligned."

### Result

**Issues found:** List them, then ask:
```
Readiness issues found (see above). Proceed anyway or update first? [proceed/update]
```
- `proceed` → add a `## Notes` entry in `plan.md` listing the issues, then continue to Step 2
- `update` → stop here and let the user refine spec or plan before re-running

**No issues:** Print `Readiness check passed.` and continue to Step 2.

## Step 2: Find Next Task

Scan `plan.md` for the first uncompleted task:
- `[ ]` = Pending (pick this one)
- `[~]` = In Progress (resume this one)
- `[x]` = Completed (skip)
- `[!]` = Blocked (skip - requires manual intervention)

**IMPORTANT:** If blocked task found, notify user:
- "Task [task description] is marked `[!]` Blocked"
- Show the blocked task details and recovery message
- "Resolve the blockage manually before continuing implementation"
- Do NOT attempt to implement blocked tasks

If resuming `[~]` task, check for partial work:
1. **Detect existing changes**: Run `git diff --name-only` and `git diff --cached --name-only` to find uncommitted files related to this task
2. **Check for partial implementation**: Read the task description, then scan the target files for TODO/FIXME markers or incomplete implementations
3. **Assess state**: Does the partial work compile/pass lint? Run a quick validation (`build` or `lint` if available)
4. **Decision**:
   - If partial work is substantial and valid → continue from where it left off
   - If partial work is broken or minimal → ask user: "Found partial work for this task. Continue from current state or start fresh?"
   - If no partial work detected (task was just marked `[~]` but nothing changed) → proceed as new task

## Step 2.5: Write Story (Architecture Mode Only)

**Activation:** Only runs when architecture mode is enabled (Step 1.6) — i.e., any of `draft/tracks/<id>/architecture.md`, `draft/.ai-context.md`, or `draft/architecture.md` exists.

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

**Activation:** Only runs when architecture mode is enabled (Step 1.6) — i.e., any of `draft/tracks/<id>/architecture.md`, `draft/.ai-context.md`, or `draft/architecture.md` exists.
**Skip for trivial tasks** - Config updates, type-only changes, single-function tasks where the design is obvious.

#### 3.0a. Execution State Design

Study the control flow for the task and propose intermediate state variables:

1. Read the Story (from Step 2.5) to understand the Input -> Output path
2. Study similar patterns in the existing codebase
3. **Check `.ai-context.md` Data Lifecycle** — Align execution state with documented state machines (valid states/transitions), storage topology (which tier data targets), and data transformation chain (shape changes at boundaries)
4. **Check `.ai-context.md` Critical Paths** — Identify where this task sits in documented write/read/async paths. Note consistency boundaries and failure recovery expectations.
5. Propose execution state: input state, intermediate state, output state, error state

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

### Step 3.0c: Production Robustness Patterns (REQUIRED)

**Applies to all code generation** — architecture mode or not. These patterns are generation directives, not a post-hoc checklist. Apply them **while writing code**, not after.

When your implementation hits any of these triggers, use the corresponding pattern. Do not write code that violates these and plan to "fix it later."

#### Atomicity

| Trigger | Required Pattern |
|---------|-----------------|
| Multi-step state mutation (DB + memory, multiple records) | Wrap in transaction or try/finally with rollback on failure |
| File write | Write to temp file + atomic rename to target path. Never write directly to the target. |
| DB write paired with in-memory state update | DB-first: persist to DB, update memory only on DB success. Never update memory optimistically. |
| Resource acquisition (locks, file handles, connections, capital) | Release in `finally` / `defer` / RAII — never rely on happy-path-only cleanup |

#### Isolation

| Trigger | Required Pattern |
|---------|-----------------|
| Method mutates shared/instance state | Acquire the class's or module's existing lock before mutation |
| Lifecycle operations (start/stop/reset/reconnect) | Use a dedicated lifecycle lock, separate from data locks |
| Returning internal state to callers | Return a deep copy or frozen snapshot — never a mutable reference to internal state |
| Acquiring a second lock while holding one | Follow documented lock ordering. If no ordering exists, do not nest locks — restructure to acquire sequentially. |
| DB I/O while holding a state lock | Move DB I/O outside the lock scope. Lock only the in-memory mutation, not the I/O. |

#### Durability

| Trigger | Required Pattern |
|---------|-----------------|
| Critical state that must survive crashes | Ensure state is recoverable from DB/disk alone — no reliance on in-memory-only state for recovery |
| Async DB write (fire-and-forget) | Await the write. Check return value or propagate exceptions. No fire-and-forget on data persistence. |
| Event log / audit trail / fill history | Use append-only pattern where specified by architecture |

#### Defensive Boundaries

| Trigger | Required Pattern |
|---------|-----------------|
| External numeric data used in arithmetic | Guard with `isFinite()` / `isnan()` / equivalent before any calculation |
| External API/webhook response consumed | Validate expected fields exist and have correct types before accessing nested properties |
| SQL query with dynamic values | Parameterized queries only — zero string interpolation for values |
| Dynamic column names, table names, or identifiers in SQL | Validate against an explicit allowlist — never pass user-controlled strings as identifiers |

#### Idempotency

| Trigger | Required Pattern |
|---------|-----------------|
| Operation that may be retried (network calls, queue consumers, webhook handlers) | Use a dedup key (UUID, request ID, fill ID) — check-before-write or upsert |
| State transition (status changes, lifecycle events) | Validate the transition is legal from the current state. Reject terminal→terminal transitions. |
| Alert / notification emission | Dedup on (alert_type, entity_id, time_window) to prevent re-firing on retries |

#### Fail-Closed

| Trigger | Required Pattern |
|---------|-----------------|
| Error path or exception handler that determines access/action | Default to the safe/restrictive/deny state — never default to permissive on error |
| Missing data, null, or undefined where a decision depends on it | Treat as deny/reject/skip — not as allow/proceed |
| Config or feature flag missing/unparseable | Use the restrictive default — system runs in safe mode, not open mode |

#### Resilience

| Trigger | Required Pattern |
|---------|-----------------|
| Any retry logic | Exponential backoff with jitter — never fixed-interval or immediate retries. Prevents retry storms. |
| Cache population under high concurrency | Cache stampede prevention: use probabilistic early expiration or request coalescing to prevent thundering herd |
| External dependency call (HTTP, RPC, DB to external service) | Circuit breaker pattern: track failure rate, open circuit on threshold, allow periodic probes to recover |
| Non-critical dependency failure | Graceful degradation: return cached/default/partial result rather than failing the entire request |

**Enforcement:** These patterns override convenience. If following a pattern makes the code more verbose, that's correct — the verbosity is the safety. If a pattern is genuinely N/A for the current task (e.g., no DB in a pure utility function), skip it — only apply relevant patterns.

**If project invariants were loaded in Step 1:** Cross-reference them here. Project-specific invariants (lock ordering, concurrency model, consistency boundaries) take precedence over these general patterns when they conflict.

---

### Step 3.1: Implement (TDD Workflow)

For each task, follow this workflow based on `workflow.md`. If skeletons were generated in Step 3.0b, fill them in using the TDD cycle below.

### Characterization Testing (Refactoring Existing Code Without Tests)

When a task involves refactoring existing code that lacks test coverage, run this **before** the TDD cycle:

1. **Identify seams** (Michael Feathers' technique):
   - Object seams: interfaces where test doubles can be injected
   - Link seams: module imports that can be swapped
2. **Write characterization tests** that capture the current behavior as a baseline
   - Run the existing code and record actual outputs for representative inputs
   - These tests document "what it does now," not "what it should do"
3. Proceed with the TDD cycle below for the new/changed behavior
4. Characterization tests serve as a safety net — if they break during refactoring, the behavioral change is intentional or a regression
- Reference: "Working Effectively with Legacy Code" (Michael Feathers)

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

**Test Quality Checklist (REQUIRED for every test):**
- No shared mutable state between test cases — each test sets up its own state
- Assertion density: every test must have at least one meaningful assertion (not just `assertTrue(true)`)
- No logic in tests: no conditionals, loops, or try/catch in test code — tests should be trivially readable
- DAMP over DRY: prefer descriptive and meaningful test names and setup over deduplication
- Test behavior, not implementation: verify observable outcomes, not internal method calls
- One behavior per test: each test should verify exactly one logical behavior
- Reference: Google SWE Book Ch. 12, Google Testing Blog "Test Behavior, Not Implementation"

**Property-Based Testing Checkpoint:**
After writing example-based tests, consider whether property-based tests would add value:
- For pure functions (no side effects, deterministic): suggest property-based tests
- For mathematical operations: suggest algebraic properties (commutativity, associativity, identity)
- For serialization: suggest round-trip property (serialize → deserialize = identity)
- For sorting: suggest ordering, permutation, length-preservation properties
- Tool recommendations by language:
  - Python: Hypothesis (https://hypothesis.works/)
  - JavaScript/TypeScript: fast-check (https://fast-check.dev/)
  - Java: jqwik (https://jqwik.net/)
  - Rust: proptest (https://github.com/proptest-rs/proptest)
  - Go: rapid (https://github.com/flyingmutant/rapid)
- Reference: Amazon ShardStore property-based testing
- **Not mandatory** — skip if the function is not pure or properties are not obvious

**3b. GREEN - Implement Minimum Code**
```
1. Write MINIMUM code to make test pass (no extras)
2. RUN test - VERIFY it PASSES
3. Show test output with pass
4. Announce: "Test passing: [evidence]"
```

**Observability Prompts (consider during implementation):**
- Structured logging at key decision points (not just errors)
- Metrics emission for latency-sensitive operations (counters, histograms)
- Tracing span creation at service boundaries and significant internal operations
- Error classification (transient vs permanent) for retry logic
- These are prompts, not mandates — use engineering judgment on what's appropriate for the task
- Reference: Netflix Full Cycle Developers

**Contract Testing Checkpoint (Service Boundaries Only):**
When implementing new API endpoints, message handlers, or service-to-service interfaces:
- Suggest consumer-driven contract tests to verify interface compatibility
- For REST APIs: suggest Pact (https://pact.io/) or Spring Cloud Contract
- For GraphQL: suggest schema validation tests
- For message queues: suggest schema registry validation
- Skip for purely internal modules with no cross-service communication
- Reference: ThoughtWorks Tech Radar, Pact documentation

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
2. Run existing test suite if one exists (do NOT skip existing tests even when TDD is off)
3. If no test suite exists, perform manual verification:
   - For API changes: test with a sample request/response
   - For UI changes: describe the visual state before and after
   - For logic changes: trace through at least one happy path and one error path
4. Show verification evidence (test output, screenshot, or trace)
5. Announce: "Implementation complete — verified by [method]"
```

**Minimum quality bar (even without TDD):**
- Existing tests must still pass — never break them
- New code must compile/lint without errors
- Edge cases listed in spec.md must be addressed (not just the happy path)

### Implementation Chunk Limit (Architecture Mode Only)

**Activation:** Only when architecture mode is enabled (Step 1.6).

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

0. **Quick robustness scan** (30-second check before committing):
   - Scan the code you just wrote against the Step 3.0c triggers
   - If any trigger is present but the pattern wasn't applied: fix it now
   - This is a rapid pattern-match, not a full review — you should have applied these during generation, this catches anything missed

1. Commit FIRST (REQUIRED - non-negotiable):
   - Stage only files changed by this task (never `git add .`)
   - `git add <specific files>`
   - Verify staged changes exist before committing: `git diff --cached --quiet`. If nothing staged, skip the commit step.
   - `git commit -m "type(<track_id>): task description"`
   - **If commit fails:**
     - Pre-commit hook failure → read hook output, fix the flagged issues, re-stage, and retry commit (do NOT use `--no-verify`)
     - Lock file error (`index.lock`) → check for concurrent git processes; if none, remove the lock file and retry
     - Other git error → report the error to user, mark task as `[~]` (in progress, not complete), do NOT proceed
   - Get commit SHA: `git rev-parse --short HEAD`
   - Do NOT proceed to the next task without committing
   - Do NOT batch multiple tasks into one commit

2. Update `plan.md`:
   - Change `[ ]` to `[x]` for the completed task
   - Add the commit SHA next to the task: `[x] Task description (abc1234)`

3. Update `metadata.json`:
   - Increment `tasks.completed`
   - Update `updated` timestamp

4. **Verify state updates (CRITICAL):**
   - Read back `plan.md` - confirm task marked `[x]` with SHA
   - Read back `metadata.json` - confirm `tasks.completed` incremented
   - If EITHER verification fails:
     - **First**, revert the task marker in `plan.md` from `[x]` to `[!]` (do not leave it as `[x]` if metadata is inconsistent)
     - Add recovery message: "State update failed after commit <SHA>. Recovery: manually mark task `[x]` in plan.md line X, update metadata.json tasks.completed to Y"
     - Specify which file(s) failed: plan.md, metadata.json, or both
     - HALT - require manual intervention before continuing

5. If `.ai-context.md` or `architecture.md` exists for the track:
   - Update module status markers (`[ ]` → `[~]` when first task in module starts, `[~]` → `[x]` when all tasks complete)
   - Fill in Story placeholders with the approved story from Step 2.5
   - If updating project-level `draft/.ai-context.md`: also update YAML frontmatter `git.commit` and `git.message` to current HEAD. Update `draft/architecture.md` with structural changes, then run the Condensation Subroutine to regenerate `draft/.ai-context.md`:
     1. Read the updated `draft/architecture.md`
     2. Condense it into the token-optimized `.ai-context.md` format (see `core/templates/ai-context.md` for the target structure)
     3. Preserve all `## INVARIANTS` and `## CONCURRENCY` sections verbatim (safety-critical, never summarize)
     4. Update `synced_to_commit` in `.ai-context.md` frontmatter to match current HEAD
     5. Full procedure details: `skills/init/SKILL.md` → "Condensation Subroutine" section

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
- About to mark `[x]` without fresh evidence from this session
- "I already tested earlier"
- "This is a simple change, no need to verify"

---

## Step 4.6: Phase Boundary Detection

After completing Step 4 for each task, check whether the completed task was the **last task in its phase**:
- Re-read `plan.md` and scan the current phase's task list
- If ALL tasks in the current phase are now `[x]` → proceed to Step 5 (Phase Boundary Check)
- If uncompleted tasks remain in the phase → return to Step 2 (Find Next Task)

## Step 5: Phase Boundary Check

When all tasks in a phase are `[x]` (detected in Step 4.6):

1. Announce: "Phase N complete. Running three-stage review."

### Three-Stage Review (REQUIRED)

**Stage 1: Automated Validation**
- Fast static checks: architecture conformance, dead code, circular dependencies, performance anti-patterns. Review for common security anti-patterns (OWASP top 10). For automated checks, use language-specific tools (e.g., `npm audit` for JS, `bandit` for Python, `cargo audit` for Rust).
- **If critical issues found:** List them, return to implementation

**Stage 2: Spec Compliance** (only if Stage 1 passes)
- Load track's `spec.md`
- Verify all requirements for this phase are implemented
- Check acceptance criteria coverage
- **If gaps found:** List them, return to implementation

**Stage 3: Code Quality** (only if Stage 2 passes)
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

1. **Run review (if enabled):**
   - Read `draft/workflow.md` review configuration
   - Check if auto-review enabled:
     ```markdown
     ## Review Settings
     - [x] Auto-review at track completion
     ```
   - If enabled, run `/draft:review track <track_id>`
   - Check review results:
     - If block-on-failure enabled AND critical issues found → HALT, require fixes
     - Otherwise, document warnings and continue

2. Update `plan.md` status to `[x] Completed`
3. Update `metadata.json` status to `"completed"`
4. Update `draft/tracks.md`:
   - Remove the track entry from `## Active` section
   - Add to `## Completed` section using this format:
     ```markdown
     - [x] **<track_id>** — <title> (completed YYYY-MM-DD)
     ```
   - If no `## Completed` section exists, create it below `## Active`

5. **Verify completion state consistency (CRITICAL):**
   - Read back `plan.md` - confirm status `[x] Completed`
   - Read back `metadata.json` - confirm status `"completed"`
   - Read back `draft/tracks.md` - confirm track in Completed section with completion date
   - If ANY file shows inconsistent state:
     - ERROR: "Track completion partially failed"
     - Report: "plan.md: <status>, metadata.json: <status>, tracks.md: <section>"
     - Provide recovery: "Manually complete updates: [list specific edits needed]"
     - Do NOT announce completion until all three files verified consistent

6. Announce:
"Track <track_id> completed!

Summary:
- Phases: N/N
- Tasks: M/M
- Duration: [if tracked]

[If review ran:]
Review: PASS | PASS WITH NOTES | FAIL
Report: draft/tracks/<track_id>/review-report-latest.md

All acceptance criteria from spec.md should be verified.

Next: Run `/draft:status` to see project overview."

## Session Recovery

If resuming `/draft:implement` in a new session (context was lost mid-implementation):

1. **Detect state**: Read `plan.md` — find the first `[~]` or `[ ]` task. Check `metadata.json` for `tasks.completed` count.
2. **Check git state**: Run `git log --oneline -5` and `git status` to verify last committed task matches plan.md's last `[x]` entry.
3. **Reconcile mismatches**: If plan.md shows `[x]` for a task but no matching commit SHA exists in git log, the state update succeeded but the commit was lost (or vice versa). Fix the mismatch before continuing.
4. **Resume**: Skip to Step 2 (Find Next Task). The readiness gate (Step 1.5) will be skipped automatically since `[x]` tasks exist.

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

## Tech Debt Log

During implementation, track technical debt decisions in the track's plan.md:

When you encounter a shortcut, workaround, or known-imperfect solution during implementation:

1. Add an entry to the `## Tech Debt` section at the bottom of plan.md
2. Use this format:

```markdown
## Tech Debt

| ID | Location | Description | Severity | Payback Trigger |
|----|----------|-------------|----------|-----------------|
| TD-1 | `src/api/handler.ts:45` | Hardcoded timeout instead of config | Low | When adding config system |
| TD-2 | `src/auth/session.ts:12` | In-memory session store | Medium | Before horizontal scaling |
```

**Severity levels:**
- **Low** — Cosmetic or minor maintainability issue
- **Medium** — Will cause problems at scale or in specific scenarios
- **High** — Actively impeding development or risking production issues

**Payback Trigger** — The condition or event that should trigger debt repayment (e.g., "before launch", "when adding feature X", "before scaling past N users").

Only log genuine debt — intentional shortcuts with known consequences. Not everything imperfect is debt.

---

## Progress Reporting

After each task, report:
```
Task: [description]
Status: Complete
Phase Progress: N/M tasks
Overall: X% complete
```
