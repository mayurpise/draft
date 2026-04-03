---
name: tech-debt
description: Identify, categorize, and prioritize technical debt across six dimensions. Generates remediation plans with effort estimates. Offered by /draft:new-track for refactor tracks.
---

# Tech Debt

You are identifying and prioritizing technical debt using Draft's Context-Driven Development methodology.

## Red Flags - STOP if you're:

- Reporting debt without reading the actual code
- Categorizing everything as high priority (prioritization requires trade-offs)
- Suggesting rewrites when incremental fixes suffice
- Ignoring effort estimates (impact without effort is not actionable)
- Making up file locations or code patterns
- Reporting framework conventions as debt

**Evidence-based. Prioritized. Actionable.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context

Read and follow the base procedure in `core/shared/draft-context-loading.md`.

**Tech-debt-specific context application:**
- Use `draft/.ai-context.md` for architecture, module boundaries, known technical decisions
- Use `draft/tech-stack.md` for framework versions, dependency age, accepted patterns
- Use `draft/guardrails.md` for known conventions and anti-patterns (anti-patterns ARE debt indicators)
- Use `draft/product.md` for business priorities (aligns debt prioritization with product goals)

If `draft/` does not exist: **STOP** — "No Draft context found. Run `/draft:init` first. Tech debt analysis requires project context."

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:tech-debt` | Full codebase tech debt scan |
| `/draft:tech-debt <path>` | Scan specific directory or module |
| `/draft:tech-debt track <id>` | Scan files related to a specific track |
| `/draft:tech-debt quick` | Quick scan — top-level indicators only, skip deep analysis |

---

## Step 2: Scan Across Six Dimensions

For each dimension, scan the codebase and record findings with evidence.

### Dimension 1: Code Debt

Issues within individual files and functions.

- [ ] **Code duplication:** Repeated logic across files (3+ occurrences of similar patterns)
- [ ] **Complex functions:** Cyclomatic complexity > 15, nesting depth > 3
- [ ] **Long files:** Files exceeding 500 lines (language-dependent threshold)
- [ ] **Magic numbers/strings:** Hardcoded values that should be constants or config
- [ ] **Dead code:** Unreachable functions, unused imports, commented-out blocks
- [ ] **TODO/FIXME/HACK markers:** Accumulated unresolved markers
- [ ] **Type safety gaps:** `any` types (TypeScript), missing type hints (Python), unsafe casts
- [ ] **Inconsistent patterns:** Same problem solved differently across the codebase

**Detection approach:**
```bash
# TODO/FIXME/HACK count
grep -rn "TODO\|FIXME\|HACK" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.rs" . | grep -v node_modules | grep -v vendor

# Large files
find . -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.java" -o -name "*.rs" | xargs wc -l | sort -rn | head -20

# Dead imports (language-specific tools)
```

### Dimension 2: Architecture Debt

Structural issues in system design.

- [ ] **Circular dependencies:** Modules that import each other (trace import chains)
- [ ] **God objects/modules:** Single module with too many responsibilities
- [ ] **Missing abstractions:** Direct coupling where interfaces should exist
- [ ] **Layer violations:** Business logic in controllers, data access in views
- [ ] **Monolith coupling:** Components that should be decoupled for independent deployment
- [ ] **Missing boundaries:** No clear separation between domains/bounded contexts

**Detection approach:**
- Read `draft/.ai-context.md` module definitions and check actual imports against intended boundaries
- Trace import chains for cycles
- Identify modules with high fan-in AND high fan-out (connector modules that are likely over-coupled)

### Dimension 3: Test Debt

Gaps in testing quality and coverage.

- [ ] **Missing tests:** Public functions/methods without test coverage
- [ ] **Brittle tests:** Tests that break on implementation changes (testing internals, not behavior)
- [ ] **Slow tests:** Tests taking >5 seconds individually or >60 seconds total
- [ ] **Flaky tests:** Tests that pass/fail non-deterministically
- [ ] **Missing integration tests:** Components tested in isolation but not together
- [ ] **No edge case coverage:** Only happy path tested
- [ ] **Test anti-patterns:** Shared mutable state, logic in tests, no assertions

**Detection approach:**
```bash
# Test file count vs source file count
find . -name "*test*" -o -name "*spec*" | wc -l
find . -name "*.ts" -o -name "*.py" | grep -v test | grep -v spec | wc -l

# Run test suite and check for slow tests (if safe to run)
```

### Dimension 4: Dependency Debt

Issues with third-party dependencies.

- [ ] **Outdated dependencies:** Major version behind current (check lock files)
- [ ] **Vulnerable dependencies:** Known CVEs in dependency tree
- [ ] **Abandoned dependencies:** No commits in 12+ months, no maintenance
- [ ] **Duplicate dependencies:** Multiple libraries solving the same problem
- [ ] **License issues:** Incompatible licenses for the project type
- [ ] **Pinning issues:** Floating version ranges that risk breaking changes

**Detection approach:**
```bash
# Check for outdated (npm example)
npm outdated 2>/dev/null

# Check for vulnerabilities
npm audit 2>/dev/null || pip audit 2>/dev/null || cargo audit 2>/dev/null

# Dependency age (check lock file dates)
```

### Dimension 5: Documentation Debt

Gaps in project documentation.

- [ ] **Missing README:** No project or module README
- [ ] **Stale docs:** Documentation references non-existent files, APIs, or patterns
- [ ] **Missing API docs:** Public interfaces without documentation
- [ ] **No architecture docs:** Missing system overview for new developers
- [ ] **Missing runbooks:** No operational documentation for production systems
- [ ] **Inline comment debt:** Complex logic without explanatory comments

**Detection approach:**
- Check for README.md at project root and key directories
- Cross-reference doc references with actual codebase
- Check for JSDoc/docstring coverage on public exports

### Dimension 6: Infrastructure Debt

Issues in build, deploy, and operational systems.

- [ ] **CI/CD gaps:** Missing or incomplete CI pipeline stages
- [ ] **Manual deployment steps:** Processes that should be automated
- [ ] **Missing monitoring:** No alerting, no APM, no log aggregation
- [ ] **Environment drift:** Dev/staging/prod configuration divergence
- [ ] **Missing IaC:** Infrastructure not codified (manual server/cloud setup)
- [ ] **Build performance:** Slow builds that impede development velocity
- [ ] **Missing health checks:** No readiness/liveness probes

**Detection approach:**
- Read CI config files (`.github/workflows/`, `.gitlab-ci.yml`, etc.)
- Check for monitoring configuration
- Compare environment configs

---

## Step 3: Prioritize

### Priority Scoring

For each finding, score on three axes (1-5 scale):

| Axis | 1 (Low) | 3 (Medium) | 5 (High) |
|------|---------|------------|----------|
| **Impact** | Cosmetic, developer annoyance | Slows development, causes occasional bugs | Blocks features, causes production issues |
| **Risk** | Low probability of causing problems | Moderate probability, growing concern | High probability, ticking time bomb |
| **Effort** | < 1 day | 1-5 days | > 1 week |

### Priority Formula

```
Priority Score = (Impact + Risk) / (6 - Effort)
```

Higher score = higher priority. This formula favors high-impact, low-effort items (quick wins).

### Sort into Three Tiers

| Tier | Priority Score | Action |
|------|---------------|--------|
| **Quick Wins** | Score > 3.0 AND Effort ≤ 2 | Fix immediately, low risk |
| **Strategic** | Score > 2.0 OR Impact ≥ 4 | Plan and schedule, high value |
| **Nice-to-Haves** | Score ≤ 2.0 AND Impact ≤ 2 | Track but don't prioritize |

---

## Step 4: Generate Report

**MANDATORY: Include YAML frontmatter with git metadata.** Follow the procedure in `core/shared/git-report-metadata.md` to gather git info, generate frontmatter, and include the report header table. Use `generated_by: "draft:tech-debt"`.

### Report Structure

```markdown
[YAML frontmatter — see core/shared/git-report-metadata.md]

# Tech Debt Report

[Report header table — see core/shared/git-report-metadata.md]

## Summary

| Dimension | Findings | Critical | Important | Minor |
|-----------|----------|----------|-----------|-------|
| Code | [N] | [N] | [N] | [N] |
| Architecture | [N] | [N] | [N] | [N] |
| Test | [N] | [N] | [N] | [N] |
| Dependency | [N] | [N] | [N] | [N] |
| Documentation | [N] | [N] | [N] | [N] |
| Infrastructure | [N] | [N] | [N] | [N] |
| **Total** | **[N]** | **[N]** | **[N]** | **[N]** |

## Health Score

**Overall: [score]/100**

| Dimension | Score | Grade |
|-----------|-------|-------|
| Code | [N]/100 | [A/B/C/D/F] |
| Architecture | [N]/100 | [A/B/C/D/F] |
| Test | [N]/100 | [A/B/C/D/F] |
| Dependency | [N]/100 | [A/B/C/D/F] |
| Documentation | [N]/100 | [A/B/C/D/F] |
| Infrastructure | [N]/100 | [A/B/C/D/F] |

Grading: A (90-100), B (80-89), C (70-79), D (60-69), F (<60)

---

## Tier 1: Quick Wins

[Findings with Priority Score > 3.0 AND Effort ≤ 2]

### [Finding Title]
- **Dimension:** [category]
- **Location:** [file:line or module]
- **Impact:** [score]/5 — [description]
- **Risk:** [score]/5 — [description]
- **Effort:** [score]/5 — [estimated time]
- **Priority Score:** [calculated]
- **Remediation:** [specific action to take]

---

## Tier 2: Strategic

[Findings with Priority Score > 2.0 OR Impact ≥ 4]

### [Finding Title]
[Same format as Tier 1]

---

## Tier 3: Nice-to-Haves

[Remaining findings]

### [Finding Title]
[Same format as Tier 1]

---

## Remediation Plan

### Phase 1: Quick Wins (1-2 sprints)
- [ ] [Action 1] — [effort estimate]
- [ ] [Action 2] — [effort estimate]

### Phase 2: Strategic (3-6 sprints)
- [ ] [Action 1] — [effort estimate]
- [ ] [Action 2] — [effort estimate]

### Phase 3: Nice-to-Haves (backlog)
- [ ] [Action 1] — [effort estimate]
- [ ] [Action 2] — [effort estimate]

---

## Trend (if previous report exists)

| Dimension | Previous | Current | Delta |
|-----------|----------|---------|-------|
| Code | [score] | [score] | [+/-] |
| Total findings | [N] | [N] | [+/-] |
```

### Save Location

Save to `draft/tech-debt-report-<timestamp>.md` (where `<timestamp>` is generated via `date +%Y-%m-%dT%H%M`, e.g., `2026-03-15T1430`):

```bash
ln -sf tech-debt-report-<timestamp>.md draft/tech-debt-report-latest.md
```

---

## Step 5: Present Results

```
Tech debt analysis complete.

Overall Health: [score]/100 ([grade])
Findings: [N] total across 6 dimensions
  Quick Wins: [N] (fix now, low effort)
  Strategic: [N] (plan and schedule)
  Nice-to-Haves: [N] (track, don't prioritize)

Top 3 Quick Wins:
1. [Finding] — [effort estimate]
2. [Finding] — [effort estimate]
3. [Finding] — [effort estimate]

Report: draft/tech-debt-report-<timestamp>.md
        (symlink: tech-debt-report-latest.md)

Next steps:
1. Review findings and adjust priorities
2. Create tracks for strategic items: /draft:new-track
3. Address quick wins in current sprint
4. Re-run periodically to track trend
```

---

## Cross-Skill Dispatch

### Inbound

- **Offered by `/draft:new-track`** — when creating refactor tracks, suggest running tech debt analysis first
- **Suggested by `/draft:implement`** — when tech debt is logged during implementation (plan.md ## Tech Debt)
- **Suggested by `/draft:deep-review`** — when deep review identifies systemic issues

### Outbound

- **Feeds `/draft:new-track`** — strategic findings become new refactor tracks
- **Feeds `/draft:learn`** — recurring debt patterns inform guardrails
- **References `draft/guardrails.md`** — anti-patterns in guardrails are debt indicators

---

## Error Handling

### No Draft Context

```
No Draft context found. Run /draft:init first.
Tech debt analysis requires project context for accurate prioritization.
```

### Empty Codebase

```
No source files found matching scan criteria.
Verify the path and file extensions are correct.
```

### Previous Report Comparison

If a previous report exists (`draft/tech-debt-report-latest.md`):
- Compare findings count per dimension
- Show trend (improving / stable / degrading)
- Highlight new findings not in previous report
- Note resolved findings (in previous but not current)

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Report everything as critical | Use the priority scoring formula |
| Suggest full rewrites | Recommend incremental improvements |
| Ignore effort estimates | Every finding needs an effort score |
| Skip dimensions that seem fine | Scan all 6, mark clean dimensions as healthy |
| Report framework patterns as debt | Check tech-stack.md accepted patterns |
| Run without Draft context | Require /draft:init for accurate analysis |

---

## Examples

### Full codebase scan
```bash
/draft:tech-debt
```

### Scan specific module
```bash
/draft:tech-debt src/auth/
```

### Scan track-related files
```bash
/draft:tech-debt track add-user-auth
```

### Quick scan
```bash
/draft:tech-debt quick
```
