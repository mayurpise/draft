# Development Workflow

## Test-Driven Development

**Mode:** [strict | flexible | none]

### Strict TDD
- [ ] Write failing test first (Red)
- [ ] Implement minimum code to pass (Green)
- [ ] Refactor with tests green (Refactor)
- [ ] Never write production code without a failing test

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
