---
project: "{PROJECT_NAME}"
module: "root"
generated_by: "draft:init"
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

# Development Workflow

## Test-Driven Development

**Mode:** [strict | flexible | none]

### Strict TDD

**Iron Law:** No production code without a failing test first.

The Cycle:
1. **RED** - Write failing test, run it, VERIFY it FAILS
2. **GREEN** - Write minimum code, run test, VERIFY it PASSES
3. **REFACTOR** - Clean up, keep tests green throughout

**Red Flags - Delete and Restart if:**
- Code written before test exists
- Test passes immediately (testing wrong thing or wrong code)
- "Just this once" rationalization
- "This is too simple to test"
- Running test mentally instead of actually

**Checklist:**
- [ ] Test written and committed BEFORE implementation
- [ ] Test fails with expected failure (not syntax error)
- [ ] Minimum code to pass (no extra features)
- [ ] Refactor preserves green state

### Flexible TDD
- [ ] Tests required but can be written after implementation
- [ ] All code must have tests before marking complete
- [ ] Refactoring encouraged

### No TDD
- [ ] Tests optional
- [ ] Manual verification acceptable

---

## Commit Strategy

**Format:** `type(scope): description`

### Types
| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `refactor` | Code restructure without behavior change |
| `test` | Adding or fixing tests |
| `chore` | Build, tooling, dependencies |

### Scope
- Use track ID for Draft work: `feat(add-auth): ...`
- Use component name otherwise: `fix(api): ...`

### Commit Frequency
- [ ] After each task completion
- [ ] At phase boundaries
- [ ] End of session

---

## Code Review

### Self-Review Checklist
- [ ] Code follows project style guide
- [ ] Tests pass locally
- [ ] No console.log or debug statements
- [ ] Error handling complete
- [ ] Edge cases considered

### Before Marking Task Complete
- [ ] Run linter
- [ ] Run tests
- [ ] Review diff

---

## Phase Verification

At the end of each phase:

1. **Run full test suite**
2. **Manual smoke test** if applicable
3. **Review against phase goals** in plan.md
4. **Document any issues** found

Do not proceed to next phase until verification passes.

---

## Validation

### Auto-Validation
- [ ] Auto-validate at track completion

When enabled, runs `/draft:validate --track <id>` automatically when `/draft:implement` completes a track.

### Blocking Behavior
- [ ] Block on validation failures

When enabled, halt track completion if critical (✗) issues found. Requires fixes before marking complete.

When disabled (default), validation failures produce warnings only. Issues documented in `draft/tracks/<id>/validation-report.md`.

### Validation Scope
- [x] Architecture conformance
- [x] Dead code detection
- [x] Dependency cycle detection
- [x] Security scan
- [x] Performance anti-patterns
- [x] Spec compliance (track-level only)
- [x] Architectural impact (track-level only)
- [x] Regression risk (track-level only)

Uncheck categories to skip during validation. All enabled by default.

> **How to configure:** Edit the checkboxes above directly in this file. Change `[x]` to `[ ]` to disable a validation category. The `/draft:validate` command reads these settings before running.

---

## Session Management

### Starting a Session
1. Run `/draft:status` to see current state
2. Read active track's spec.md and plan.md
3. Find current task (marked `[~]` or first `[ ]`)

### Ending a Session
1. Commit any pending changes
2. Update plan.md with progress
3. Add notes for next session if mid-task

### Context Handoff
If task exceeds 5 iterations:
1. Document current state in plan.md
2. Note any discoveries or blockers
3. Suggest resumption approach

---

## Guardrails

<!-- Hard constraints that must never be violated -->

### Git & Version Control
- [ ] No direct commits to main/master
- [ ] No force push to shared branches
- [ ] PR required for all changes

### Code Quality
- [ ] No console.log/print statements in production code
- [ ] No commented-out code blocks
- [ ] No TODO comments without linked issue

### Security
- [ ] No secrets/credentials in code
- [ ] No disabled security checks without documented exception
- [ ] Dependencies must pass security audit

### Testing
- [ ] Tests required before merge
- [ ] No skipped tests without documented reason
- [ ] Coverage must not decrease

> Check the guardrails that apply to this project. Unchecked items are not enforced. Commands like bughunt, validate, and review will flag violations of checked guardrails.
