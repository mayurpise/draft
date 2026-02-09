# Development Workflow

## Test-Driven Development

**Mode:** flexible

### Flexible TDD
- [x] Tests required but can be written after implementation
- [x] All code must have tests before marking complete
- [x] Refactoring encouraged

> Draft is primarily a markdown methodology project. TDD applies to the build script and any future code additions, not to markdown skill files.

---

## Commit Strategy

**Format:** `type(scope): description`

### Types
| Type | Use For |
|------|---------|
| `feat` | New skill or feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `refactor` | Code restructure without behavior change |
| `test` | Adding or fixing tests |
| `chore` | Build, tooling, dependencies |

### Scope
- Use track ID for Draft work: `feat(add-auth): ...`
- Use component name otherwise: `fix(build): ...`

### Commit Frequency
- [x] After each task completion
- [x] At phase boundaries
- [ ] End of session

---

## Code Review

### Self-Review Checklist
- [x] Skill follows frontmatter + body format
- [x] Build script runs without errors after skill changes
- [x] Integration files regenerated (`./scripts/build-integrations.sh`)
- [x] No placeholder text left in templates

### Before Marking Task Complete
- [x] Run build script
- [x] Review diff
- [x] Test affected slash commands manually

---

## Phase Verification

At the end of each phase:

1. **Run build script** — verify integrations regenerate cleanly
2. **Test affected commands** — invoke slash commands and verify behavior
3. **Review against phase goals** in plan.md
4. **Document any issues** found

Do not proceed to next phase until verification passes.

---

## Validation

### Auto-Validation
- [ ] Auto-validate at track completion

### Blocking Behavior
- [ ] Block on validation failures

### Validation Scope
- [x] Architecture conformance
- [x] Dead code detection
- [x] Dependency cycle detection
- [x] Security scan
- [x] Performance anti-patterns
- [x] Spec compliance (track-level only)
- [x] Architectural impact (track-level only)
- [x] Regression risk (track-level only)

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
