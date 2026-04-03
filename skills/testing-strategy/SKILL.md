---
name: testing-strategy
description: Design test strategies and test plans with coverage targets. Complements /draft:coverage which measures what this skill plans. Auto-loaded by /draft:implement before TDD.
---

# Testing Strategy

You are designing a test strategy using Draft's Context-Driven Development methodology. This skill plans what to test and how; `/draft:coverage` measures the results.

## Red Flags - STOP if you're:

- Designing a test strategy without reading the codebase first
- Copying a generic test pyramid without customizing for this project
- Setting coverage targets without understanding the module's risk level
- Ignoring the existing test infrastructure (framework, patterns, helpers)
- Planning tests for generated or vendored code
- Designing tests that test implementation details instead of behavior

**Codebase-first. Risk-aware. Behavior-focused.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context

Read and follow the base procedure in `core/shared/draft-context-loading.md`.

**Testing-strategy-specific context application:**
- Use `draft/.ai-context.md` for module boundaries, dependencies, critical paths
- Use `draft/tech-stack.md` for test framework, testing tools, language conventions
- Use `draft/workflow.md` for TDD preferences, CI configuration, coverage targets
- Use `draft/guardrails.md` for test-related conventions and anti-patterns
- Use `draft/product.md` for critical user flows that need end-to-end coverage

If `draft/` does not exist: **STOP** — "No Draft context found. Run `/draft:init` first."

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:testing-strategy` | Design strategy for active track or project |
| `/draft:testing-strategy track <id>` | Design strategy for specific track |
| `/draft:testing-strategy <path>` | Design strategy for specific module/directory |
| `/draft:testing-strategy refresh` | Update existing strategy with new findings |

### Default Behavior

If no arguments:
- Auto-detect active `[~]` In Progress track from `draft/tracks.md`
- If no active track, design project-level strategy
- If active track found: "Designing test strategy for track: [id] — [name]"

---

## Step 2: Analyze Codebase

### 2.1: Test Infrastructure Inventory

Detect existing test setup:

```bash
# Find test files
find . -name "*test*" -o -name "*spec*" -o -name "__tests__" | grep -v node_modules | grep -v vendor | head -50

# Check test framework config
ls jest.config.* vitest.config.* pytest.ini setup.cfg pyproject.toml .nycrc Cargo.toml go.mod 2>/dev/null

# Check CI test configuration
ls .github/workflows/*.yml .gitlab-ci.yml Jenkinsfile Makefile 2>/dev/null
```

Document:
- **Test framework:** [detected framework and version]
- **Test runner:** [how tests are executed]
- **Coverage tool:** [if configured]
- **CI integration:** [which pipeline stages run tests]
- **Test helpers/utilities:** [shared test infrastructure]
- **Mocking libraries:** [detected mocking tools]
- **Test data management:** [fixtures, factories, seeds]

### 2.2: Codebase Structure Analysis

Map the codebase to understand what needs testing:

1. **Identify module boundaries** (from `.ai-context.md` or directory structure)
2. **Classify each module by risk level:**

| Risk Level | Criteria | Examples |
|------------|----------|---------|
| **Critical** | Data integrity, security, financial | Auth, payments, crypto, data persistence |
| **High** | Core business logic, user-facing | API handlers, domain logic, state machines |
| **Medium** | Supporting logic, integrations | Utilities, adapters, transformers |
| **Low** | Configuration, glue code, generated | Config loaders, type definitions, stubs |

3. **Identify external boundaries:**
   - Database interactions
   - Third-party API calls
   - Message queues / event systems
   - File system operations
   - Network boundaries

4. **Map existing test coverage:**
   - Which modules have tests?
   - What type of tests exist? (unit, integration, e2e)
   - What's the approximate coverage per module?

### 2.3: Critical Path Analysis

From `draft/.ai-context.md` or `draft/product.md`, identify:
- **Critical user flows:** Login, checkout, data submission, etc.
- **Write paths:** Operations that mutate state
- **Error-sensitive paths:** Operations where failure has high cost
- **Concurrency-sensitive paths:** Operations with race condition risk

---

## Step 3: Design Testing Pyramid

### 3.1: Pyramid Configuration

Based on the codebase analysis, define the testing pyramid:

```
                    ┌─────────┐
                    │  E2E    │  [N]%
                    ├─────────┤
                    │         │
                  ┌─┤ Integr. ├─┐  [N]%
                  │ │         │ │
                ┌─┤ ├─────────┤ ├─┐
                │ │ │         │ │ │
              ┌─┤ │ │  Unit   │ │ ├─┐  [N]%
              │ │ │ │         │ │ │ │
              └─┴─┴─┴─────────┴─┴─┴─┘
```

### Recommended Distribution

| Layer | Typical Ratio | Speed | Confidence | Maintenance |
|-------|--------------|-------|------------|-------------|
| **Unit** | 70% of tests | Fast (ms) | Per-function | Low |
| **Integration** | 20% of tests | Medium (s) | Per-module | Medium |
| **E2E** | 10% of tests | Slow (min) | Per-flow | High |

Adjust based on codebase characteristics:
- **Heavy business logic → More unit tests** (validate rules)
- **Heavy integrations → More integration tests** (validate boundaries)
- **User-facing app → More E2E tests** (validate flows)
- **Library/SDK → More unit + contract tests** (validate API surface)

### 3.2: Layer Definitions

**Unit Tests:**
- Test individual functions/methods in isolation
- Mock external dependencies
- Focus: correctness of logic, edge cases, error handling
- Speed: < 100ms per test
- Pattern: Arrange → Act → Assert

**Integration Tests:**
- Test module interactions and boundaries
- Use real (or test) databases, file systems, etc.
- Focus: data flow across boundaries, contract adherence
- Speed: < 5s per test
- Pattern: Setup environment → Execute flow → Verify state → Cleanup

**End-to-End Tests:**
- Test complete user flows through the system
- Use real (or staging) infrastructure
- Focus: critical user journeys work end-to-end
- Speed: < 30s per test
- Pattern: Simulate user action → Verify outcome

---

## Step 4: Per-Component Strategy

For each module/component, define a specific testing approach.

### Component Strategy Template

```markdown
### [Module Name]

**Risk Level:** [Critical / High / Medium / Low]
**Coverage Target:** [percentage]%
**Current Coverage:** [percentage]% (or "unknown")

**Unit Tests:**
- [Function/class]: Test [what behavior]
  - Happy path: [scenario]
  - Edge cases: [list]
  - Error cases: [list]

**Integration Tests:**
- [Boundary]: Test [what interaction]
  - [Scenario 1]
  - [Scenario 2]

**What NOT to test:**
- [Generated code, trivial getters/setters, framework internals]
```

### Coverage Targets by Risk Level

| Risk Level | Line Coverage | Branch Coverage | Mutation Score |
|------------|-------------|-----------------|----------------|
| **Critical** | 95%+ | 90%+ | 80%+ (recommended) |
| **High** | 85%+ | 80%+ | — |
| **Medium** | 70%+ | 60%+ | — |
| **Low** | 50%+ | — | — |
| **Generated** | Excluded | Excluded | Excluded |

---

## Step 5: Test Quality Guidelines

### What Makes a Good Test

1. **Tests behavior, not implementation:** Verify observable outcomes, not internal method calls
2. **One behavior per test:** Each test should verify exactly one logical behavior
3. **No logic in tests:** No conditionals, loops, or try/catch in test code
4. **DAMP over DRY:** Descriptive and meaningful test names and setup over deduplication
5. **No shared mutable state:** Each test sets up its own state
6. **Fast and deterministic:** No flakiness, no network calls in unit tests
7. **Clear failure messages:** When a test fails, the message tells you what went wrong

### Test Naming Convention

```
[Module/Class].[method]_[scenario]_[expectedBehavior]

Examples:
- AuthService.login_validCredentials_returnsToken
- UserRepository.findById_nonExistentId_returnsNull
- PaymentProcessor.charge_insufficientFunds_throwsPaymentError
```

Adapt to the project's existing naming convention if one exists.

### Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|-------------|---------|-----------------|
| Testing private methods | Couples tests to implementation | Test through public interface |
| Excessive mocking | Tests don't verify real behavior | Use fakes or real dependencies |
| Test interdependence | One test's failure cascades | Isolate each test completely |
| Assert on everything | Brittle, breaks on any change | Assert on behavior, not structure |
| Copy-paste test code | Hard to maintain | Use test helpers and builders |
| Sleep in tests | Flaky, slow | Use events, polling, or test clocks |

### Reference Sources

- Google SWE Book Ch. 11-14 (Testing Overview, Unit Testing, Test Doubles, Larger Tests)
- Google Testing Blog: "Test Behavior, Not Implementation"
- Martin Fowler: "Test Pyramid" (https://martinfowler.com/bliki/TestPyramid.html)
- ISTQB Test Analyst syllabus for structured test design techniques

---

## Step 6: Gap Analysis

Compare the designed strategy against the current state.

### Gap Identification

| Module | Risk | Target | Current | Gap | Priority |
|--------|------|--------|---------|-----|----------|
| [module] | [level] | [target]% | [current]% | [delta]% | [1-3] |

### Missing Test Categories

- [ ] **Missing unit tests:** [list modules without unit tests]
- [ ] **Missing integration tests:** [list boundaries without integration tests]
- [ ] **Missing E2E tests:** [list critical flows without E2E coverage]
- [ ] **Missing edge case tests:** [list known edge cases without coverage]
- [ ] **Missing error path tests:** [list error scenarios without coverage]

### Prioritized Test Writing Plan

1. **Immediate (before next release):**
   - [Test 1]: [what to test, why it's urgent]
   - [Test 2]: [what to test, why it's urgent]

2. **Short-term (next 2 sprints):**
   - [Test 1]: [what to test]
   - [Test 2]: [what to test]

3. **Long-term (backlog):**
   - [Test 1]: [what to test]
   - [Test 2]: [what to test]

---

## Step 7: Developer Review

### CHECKPOINT (MANDATORY)

**STOP.** Present the testing strategy to the developer for review.

Ask developer:
- Are the risk classifications accurate?
- Are the coverage targets appropriate?
- Are there critical paths we missed?
- Should any modules be excluded or added?
- Does the test writing plan priority match team priorities?

**Wait for developer approval before saving.**

---

## Step 8: Save Strategy

### Save Location

- **Track-level:** `draft/tracks/<id>/testing-strategy.md`
- **Project-level:** `draft/testing-strategy.md`

### Strategy Document Format

```markdown
---
project: "[project name]"
track_id: "[track-id or null]"
generated_by: "draft:testing-strategy"
generated_at: "[ISO timestamp]"
git:
  branch: "[branch]"
  commit: "[short SHA]"
---

# Testing Strategy

## Overview

**Project:** [name]
**Date:** [date]
**Scope:** [track-level or project-level]

## Test Infrastructure

[From Step 2.1]

## Testing Pyramid

[From Step 3]

## Per-Component Strategy

[From Step 4 — one section per module]

## Coverage Targets

[Target table from Step 4]

## Test Quality Guidelines

[From Step 5 — project-customized]

## Gap Analysis

[From Step 6]

## Test Writing Plan

[Prioritized plan from Step 6]
```

---

## Step 9: Present Results

```
Testing strategy generated.

Scope: [track-level / project-level]
Modules analyzed: [N]
Risk classification: [N] critical, [N] high, [N] medium, [N] low

Testing Pyramid:
  Unit: [N]% target
  Integration: [N]% target
  E2E: [N]% target

Coverage Gaps:
  [N] modules below target
  [N] critical paths without E2E coverage
  [N] test categories missing

Strategy: draft/[tracks/<id>/]testing-strategy.md

Next steps:
1. Review and adjust per-component targets
2. Start writing tests per the prioritized plan
3. Run /draft:coverage to measure progress
4. Re-run /draft:testing-strategy refresh to update
```

---

## Cross-Skill Dispatch

### Inbound

- **Auto-loaded by `/draft:implement`** — before TDD cycle, load testing strategy for guidance on what to test
- **Suggested by `/draft:decompose`** — after module decomposition, suggest designing test strategy
- **Suggested by `/draft:init`** — after project initialization, suggest establishing test strategy

### Outbound

- **Feeds `/draft:coverage`** — coverage measures what this skill plans. Coverage targets defined here are enforced by `/draft:coverage`
- **Feeds `/draft:implement`** — TDD cycle uses per-component strategy for test design guidance
- **References `draft/workflow.md`** — TDD preferences and CI configuration inform strategy

---

## Error Handling

### No Draft Context

```
No Draft context found. Run /draft:init first.
Testing strategy design requires project context for accurate risk classification.
```

### No Test Framework Detected

```
No test framework detected in the project.

Recommendations by language:
- JavaScript/TypeScript: Jest (https://jestjs.io/) or Vitest (https://vitest.dev/)
- Python: pytest (https://pytest.org/)
- Go: built-in testing package
- Rust: built-in #[test] + cargo test
- Java: JUnit 5 (https://junit.org/junit5/)

Set up a test framework first, then re-run /draft:testing-strategy.
```

### Existing Strategy Found

```
Existing testing strategy found at [path].

Options:
1. Refresh — update with new findings while preserving existing decisions
2. Replace — generate new strategy from scratch
3. Cancel

Select (1-3):
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Copy a generic test pyramid | Customize based on codebase analysis |
| Set 100% coverage for everything | Use risk-based coverage targets |
| Design tests for generated code | Exclude generated/vendored code |
| Test implementation details | Test behavior through public interfaces |
| Ignore existing test patterns | Build on established conventions |
| Plan tests without reading code | Understand the code before planning tests |

---

## Examples

### Design strategy for active track
```bash
/draft:testing-strategy
```

### Design strategy for specific track
```bash
/draft:testing-strategy track add-user-auth
```

### Design strategy for a module
```bash
/draft:testing-strategy src/auth/
```

### Refresh existing strategy
```bash
/draft:testing-strategy refresh
```
