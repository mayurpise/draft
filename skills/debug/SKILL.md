---
name: debug
description: "Runs a structured debugging session: reproduces the bug, isolates the failing code path, forms and tests hypotheses one at a time, fixes with developer approval, and generates a debug report. Use when the user reports an error, crash, broken feature, exception, stack trace, or says 'not working', 'debug this', or 'investigate bug'. Invoked by /draft:new-track for bug tracks or directly for ad-hoc debugging."
---

# Debug

You are conducting a structured debugging session using Draft's Context-Driven Development methodology.

## Red Flags - STOP if you're:

- Guessing at fixes without reproducing the bug first
- Skipping isolation and jumping straight to code changes
- Making multiple changes at once instead of testing one hypothesis at a time
- Not recording failed hypotheses (they narrow the search space)
- Fixing symptoms instead of root causes
- Claiming "fixed" without verification evidence

**Reproduce before you fix. One hypothesis at a time.**

---

## Pre-Check

### 0. Capture Git Context

Before starting analysis, capture the current git state:

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

Store this for the debug report header. All debugging is relative to this specific branch/commit.

### 1. Verify Draft Context

```bash
ls draft/ 2>/dev/null
```

If `draft/` exists, load Draft context following the base procedure in `core/shared/draft-context-loading.md`. Honor Accepted Patterns and enforce Guardrails as defined there.

**Debug-specific context application:**
- Use `.ai-context.md` module boundaries to scope the investigation
- Use tech-stack.md for framework-specific debugging techniques
- Use guardrails.md to check if the bug violates known anti-patterns
- Use product.md to understand expected user-facing behavior

If `draft/` does not exist, proceed with code-only debugging. Note: "No Draft context available — debugging without project context."

---

## Step 1: Parse Arguments

Extract and validate command arguments from user input.

### Supported Invocations

| Invocation | Behavior |
|------------|----------|
| `/draft:debug` | Interactive — ask user to describe the bug |
| `/draft:debug <description>` | Start debugging with the provided description |
| `/draft:debug track <id>` | Debug within the context of a specific track |
| `/draft:debug <JIRA-KEY>` | Pull bug details from Jira via MCP (if available) |

### Argument Resolution

1. **No arguments:** Prompt user: "Describe the bug — what's the expected behavior vs. actual behavior?"
2. **Free-text description:** Use as the initial symptom description
3. **`track <id>`:** Load track context from `draft/tracks/<id>/spec.md` and `draft/tracks/<id>/plan.md`. Use spec's acceptance criteria to understand expected behavior.
4. **Jira key pattern** (matches `[A-Z]+-\d+`): Attempt to fetch bug details via Jira MCP. If MCP unavailable, ask user to paste the bug description manually.

---

## Step 2: Reproduce

Establish a reliable reproduction of the bug before any investigation.

### 2.1: Identify Symptom

Document clearly:
- **Expected behavior:** What should happen
- **Actual behavior:** What actually happens
- **Error output:** Stack traces, error messages, logs (exact text, not paraphrased)
- **Environment:** OS, runtime version, relevant config

### 2.2: Establish Reproduction

1. **Find or create a minimal reproduction:**
   - Identify the shortest sequence of steps that triggers the bug
   - Strip away unrelated setup, data, and configuration
   - If the bug is in a test: run the test and capture output
   - If the bug is runtime: identify the entry point and input

2. **Run the reproduction:**
   ```bash
   # Execute the reproduction steps
   # Capture FULL output including exit codes
   ```

3. **Capture evidence:**
   - Save exact command(s) used
   - Save full output (stdout + stderr)
   - Note the exit code
   - Screenshot if UI-related (describe what's visible)

### 2.3: Classify Reproducibility

| Classification | Definition | Action |
|----------------|------------|--------|
| **Always** | Reproduces on every attempt | Proceed to Step 3 |
| **Intermittent** | Reproduces sometimes (note frequency: N/M attempts) | Run 5+ attempts, note pattern, proceed to Step 3 |
| **Environment-specific** | Only reproduces in certain conditions | Document conditions, attempt to replicate locally |
| **Cannot reproduce** | Cannot trigger the bug | See Error Handling section |

---

## Step 3: Isolate

Narrow the scope from "something is broken" to "this specific code path is broken."

### 3.1: Trace Data Flow

Starting from the reproduction entry point:
1. Identify input data and its transformation path
2. Trace through each function/method in the call chain
3. At each boundary, verify: does the data match expectations?
4. Note the first point where actual diverges from expected

### 3.2: Trace Control Flow

1. Identify the decision points (conditionals, switches, dispatchers)
2. Determine which branch is taken during the bug
3. Verify: is this the correct branch for the given input?
4. Check edge cases at each branch point

### 3.3: Differential Analysis

Compare working vs. broken scenarios:
- **Working input vs. broken input:** What's different?
- **Working version vs. broken version:** `git bisect` or manual commit comparison
- **Working environment vs. broken environment:** Config differences?

### 3.4: Check Boundaries via `.ai-context.md`

If `.ai-context.md` exists:
- Check module boundaries — is the bug at a module interface?
- Check data flow documentation — is data being transformed incorrectly at a boundary?
- Check invariants — is a critical invariant being violated?
- Check concurrency model — is there a race condition or deadlock?

---

## Step 4: Diagnose

Form and test hypotheses systematically.

### Hypothesis Protocol

For each hypothesis:

1. **Form hypothesis:** "The bug occurs because [specific cause] in [specific location]"
2. **Predict outcome:** "If this hypothesis is correct, then [observable prediction]"
3. **Test minimally:** Design the smallest possible test that confirms or refutes the hypothesis
4. **Record result:** Update the hypothesis log

### Hypothesis Log

Maintain a running log:

| # | Hypothesis | Prediction | Test | Result | Time |
|---|-----------|------------|------|--------|------|
| 1 | Off-by-one in loop at parser.ts:45 | Array index out of bounds on empty input | Pass empty array to parse() | REFUTED — handles empty correctly | 2min |
| 2 | Missing null check on user.email at auth.ts:23 | Throws TypeError when email is undefined | Call login({name: "test"}) without email field | CONFIRMED — TypeError: Cannot read property 'toLowerCase' of undefined | 1min |

### Rules

- **One hypothesis at a time.** Do not test multiple hypotheses simultaneously.
- **Record refuted hypotheses.** They narrow the search space.
- **Prefer hypotheses that can be tested without code changes** (logging, breakpoints, different inputs).
- **If 3 consecutive hypotheses are refuted:** Step back and re-examine assumptions. See Error Handling section.

---

## Step 5: Fix with Developer Approval

Once root cause is confirmed:

### Test Writing Guardrail

**ASK before writing tests.** Do not automatically write tests. Present the fix plan and ask:
- "Should I write a regression test for this bug?"
- If developer approves: write the test FIRST (RED), then implement the fix (GREEN)
- If developer declines: implement the fix only

### Fix Protocol

1. **Minimal fix:** Change only what's necessary to fix the root cause
2. **Stay in blast radius:** Only modify files directly related to the bug
3. **Preserve existing behavior:** The fix should not change unrelated functionality
4. **Verify fix:**
   - Run the reproduction from Step 2 — bug should no longer occur
   - Run existing test suite — no regressions
   - If regression test was written — it should pass

### Fix Presentation

Present the fix to the developer before committing:

```
ROOT CAUSE: [one-sentence description]
FIX: [one-sentence description of the change]
FILES MODIFIED: [list]
BLAST RADIUS: [what could be affected]
VERIFICATION: [evidence that the fix works]
```

Wait for developer approval before committing.

---

## Step 6: Generate Debug Report

Create a structured debug report documenting the investigation.

**MANDATORY: Include YAML frontmatter with git metadata.** Follow the procedure in `core/shared/git-report-metadata.md` to gather git info, generate frontmatter, and include the report header table. Use `generated_by: "draft:debug"`.

### Report Structure

```markdown
[YAML frontmatter — see core/shared/git-report-metadata.md]

# Debug Report: [Bug Title]

[Report header table — see core/shared/git-report-metadata.md]

**Symptom:** [What was observed]
**Root Cause:** [What caused it]
**Fix:** [What was changed]
**Verification:** [How the fix was verified]

---

## Reproduction

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected:** [Expected behavior]
**Actual:** [Actual behavior]
**Reproducibility:** [Always / Intermittent / Environment-specific]

---

## Investigation

### Data Flow Trace
[Key findings from data flow analysis]

### Control Flow Trace
[Key findings from control flow analysis]

### Hypothesis Log

| # | Hypothesis | Prediction | Test | Result | Time |
|---|-----------|------------|------|--------|------|
| 1 | [hypothesis] | [prediction] | [test] | [result] | [time] |

---

## Root Cause Analysis

**Root Cause:** [Detailed explanation]
**Category:** [Logic error / Race condition / Missing validation / Type error / Configuration / etc.]
**Introduced:** [Commit SHA if identifiable, or "unknown"]

---

## Fix

**Files Modified:**
- `path/to/file.ts:45` — [description of change]

**Regression Test:** [path/to/test or "None — developer declined"]

**Blast Radius:** [Assessment of what could be affected]

---

## Prevention

**How to prevent similar bugs:**
- [Recommendation 1]
- [Recommendation 2]
```

### Report Save Location

- **Track-level:** `draft/tracks/<id>/debug-report-<timestamp>.md` (where `<timestamp>` is generated via `date +%Y-%m-%dT%H%M`, e.g., `2026-03-15T1430`)
  ```bash
  ln -sf debug-report-<timestamp>.md draft/tracks/<id>/debug-report-latest.md
  ```

- **Ad-hoc (no track):** `draft/debug-report-<timestamp>.md`
  ```bash
  ln -sf debug-report-<timestamp>.md draft/debug-report-latest.md
  ```

---

## Cross-Skill Dispatch

### Inbound

- **Auto-invoked by `/draft:new-track`** when track type is `bug` — new-track creates the track, then dispatches to `/draft:debug track <id>`
- **Invoked by `/draft:implement`** when a task is marked `[!]` Blocked due to a bug

### Outbound

- **Invokes RCA agent** (`core/agents/rca.md`) for complex root cause analysis when:
  - Bug spans multiple modules
  - Root cause is non-obvious after 3+ hypotheses
  - Bug involves concurrency, race conditions, or distributed state
- **Feeds into `/draft:new-track`** — if the fix requires significant work, suggest creating a new track
- **Suggests `/draft:learn`** at completion — if the bug reveals a pattern that should be learned (convention or anti-pattern)
- **Suggests `/draft:new-track` for regression track** — if the bug class suggests other instances may exist
- **Jira sync:** If ticket linked, attach debug report and post summary via `core/shared/jira-sync.md`

---

## Error Handling

### Cannot Reproduce

```
Unable to reproduce the bug after N attempts.

Attempted:
1. [approach 1] — [result]
2. [approach 2] — [result]

Possible reasons:
- Environment-specific (check config differences)
- Timing-dependent (try under load or with delays)
- Data-dependent (try with production-like data)
- Already fixed (check recent commits)

Recommended: Gather more information about the conditions when the bug occurs.
```

### No Draft Context

```
No Draft context found. Debugging without project context.

For better debugging, run /draft:init to set up context.
Proceeding with code-only investigation.
```

### 3 Failed Hypotheses

After 3 consecutive refuted hypotheses:

```
Three hypotheses refuted. Stepping back to re-examine.

Review:
1. Is the reproduction reliable? (Re-run it now)
2. Is the symptom correctly identified? (Re-read the error)
3. Are we looking in the right area? (Check call stack again)
4. Should we try git bisect to find the introducing commit?
5. Should we invoke RCA agent for deeper analysis?

Select an approach or describe a new hypothesis.
```

### MCP Unavailable

When Jira MCP is not available for a Jira key argument:

```
Jira MCP not available. Cannot fetch bug details for <JIRA-KEY>.

Options:
1. Paste the bug description manually
2. Continue with /draft:debug <description> instead
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Guess and fix | Reproduce first, then investigate |
| Change multiple things at once | One hypothesis, one change, one test |
| Ignore refuted hypotheses | Record them — they narrow the search |
| Fix without understanding root cause | Diagnose fully before fixing |
| Skip regression test | Ask developer, write test if approved |
| Assume the first fix is correct | Verify with reproduction and test suite |

---

## Pattern Learning

After generating the debug report, execute the pattern learning phase from `core/shared/pattern-learning.md` to update `draft/guardrails.md` with patterns discovered during this debugging session.

---

## Examples

### Ad-hoc debugging
```bash
/draft:debug "Login fails with 500 error when email contains a plus sign"
```

### Track-level debugging
```bash
/draft:debug track add-user-auth
```

### Jira bug
```bash
/draft:debug PROJ-1234
```

### Interactive (no args)
```bash
/draft:debug
```
