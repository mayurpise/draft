# Development Workflow

## Test-Driven Development
- [x] Strict TDD enabled
- [x] Write failing test first (RED)
- [x] Implement minimum code to pass (GREEN)
- [x] Refactor with passing tests (REFACTOR)
- [x] No production code without a failing test

## Commit Strategy
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Commit after each completed task
- Scope examples: init, new-track, implement, status, revert, methodology

## Code Review
- Self-review before marking complete
- Two-stage review at phase boundaries:
  1. Spec Compliance — does output match spec?
  2. Code Quality — architecture, error handling, tests

## Phase Verification
- No `[x]` without fresh verification evidence
- Run verification command, read output, show proof
- Document verification steps in plan.md

## Debugging Protocol
- Investigate → Analyze → Hypothesize → Implement
- No fixes without root cause investigation
- Reference `core/agents/debugger.md` for systematic process
