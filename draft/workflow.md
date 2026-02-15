---
project: "draft"
module: "root"
generated_by: "draft:init"
generated_at: "2026-02-15T09:15:00Z"
git:
  branch: "main"
  remote: "origin/main"
  commit: "8b120fb6de234d14c78e637bc90c0238308f2321"
  commit_short: "8b120fb"
  commit_date: "2026-02-15 01:06:48 -0800"
  commit_message: "fix(landing): update social share links to point to research tab"
  dirty: true
synced_to_commit: "8b120fb6de234d14c78e637bc90c0238308f2321"
---

# Development Workflow

| Field | Value |
|-------|-------|
| **Branch** | `main` → `origin/main` |
| **Commit** | `8b120fb` — fix(landing): update social share links to point to research tab |
| **Generated** | 2026-02-15T09:15:00Z |
| **Synced To** | `8b120fb6de234d14c78e637bc90c0238308f2321` |

---

## Test-Driven Development

**Mode:** flexible

### Flexible TDD
- [x] Tests required but can be written after implementation
- [x] All code must have tests before marking complete
- [x] Refactoring encouraged

---

## Commit Strategy

**Format:** `type(scope): description`

### Types
| Type | Use For |
|------|---------|
| `feat` | New feature (new skill, new agent, new template) |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace |
| `refactor` | Code restructure without behavior change |
| `test` | Adding or fixing tests |
| `chore` | Build, tooling, dependencies |

### Scope
- Use skill name for skill changes: `feat(init): ...`
- Use component name otherwise: `fix(build): ...`, `docs(readme): ...`

### Commit Frequency
- [x] After each task completion
- [x] At phase boundaries
- [ ] End of session

---

## Code Review

### Self-Review Checklist
- [x] Skill follows frontmatter format (name + description in YAML)
- [x] Skill body starts with blank line + `# Title` + blank line
- [x] Build passes (`make build`)
- [x] Tests pass (`make test`)
- [x] No `/draft:` syntax in generated integration files

### Before Marking Task Complete
- [x] Run `make build && make test`
- [x] Review diff
- [x] Verify integration files regenerated correctly

---

## Phase Verification

At the end of each phase:

1. **Run full test suite** (`make test`)
2. **Verify build output** (`make build`)
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

### Context Handoff
If task exceeds 5 iterations:
1. Document current state in plan.md
2. Note any discoveries or blockers
3. Suggest resumption approach

---

## Guardrails

### Git & Version Control
- [x] No force push to shared branches

### Code Quality
- [x] No commented-out code blocks
- [x] No TODO comments without linked issue

### Security
- [x] No secrets/credentials in code

### Testing
- [x] Tests required before merge
- [x] No skipped tests without documented reason
