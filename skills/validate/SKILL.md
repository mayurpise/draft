---
name: validate
description: Validate codebase quality using Draft context (architecture.md, product.md, tech-stack.md). Runs project-level or track-level validation with configurable automatic execution.
---

# Validate Codebase

You are validating codebase quality using Draft context files to ensure architectural conformance, security, and spec compliance.

## Usage

- `/draft:validate` - Validate entire codebase
- `/draft:validate --track <track-id>` - Validate specific track

## Pre-Check

1. Verify Draft is initialized:
```bash
ls draft/product.md draft/tech-stack.md draft/workflow.md 2>/dev/null
```

If missing, tell user: "Project not initialized. Run `/draft:init` first."

## Step 1: Parse Arguments & Determine Scope

Extract arguments from the command invocation.

**Validation Modes:**
- **Project-Level:** No arguments → validate entire codebase
- **Track-Level:** `--track <track-id>` → validate specific track

### Track-Level Mode

If `--track <track-id>` specified:

1. Verify track exists: `ls draft/tracks/<track-id>/spec.md`
2. If not found, tell user: "Track '<track-id>' not found. Check `draft/tracks.md` for valid track IDs."
3. Read `draft/tracks/<track-id>/spec.md` for acceptance criteria
4. Get changed files via git: `git diff --name-only main..HEAD` (or appropriate base branch)

## Step 2: Load Draft Context

Read the following context files:

1. `draft/workflow.md` - Check validation configuration
2. `draft/tech-stack.md` - Technology constraints, dependency list
3. `draft/product.md` - Product context (optional, for understanding)
4. `draft/architecture.md` - Architectural patterns (if exists)

Extract validation configuration from `workflow.md`:
```markdown
## Validation
- [x] Auto-validate at track completion
- [ ] Block on validation failures
- Scope: architecture, security, performance, spec-compliance
```

If no validation section exists, use defaults:
- Auto-validate: disabled
- Block on failures: false
- Scope: all checks

## Step 3: Run Validation Checks

### Project-Level Validation (whole codebase)

Run all 5 validators:

#### 3.1 Architecture Conformance
- Check if `draft/architecture.md` exists
- If yes, parse for documented patterns (search for sections like "Patterns", "Standards", "Conventions")
- Validate code conforms to documented patterns
- Example patterns to check:
  - Middleware usage in API routes
  - Repository pattern for database access
  - Component structure conventions
- Report violations with file:line references

#### 3.2 Dead Code Detection
- Scan for unused exports/functions
- Track exports vs imports across codebase
- Flag unreferenced code (may be public API, manual review needed)
- Scope: project source files (exclude node_modules, build artifacts)

#### 3.3 Dependency Cycle Detection
- Build dependency graph from import statements
- Detect circular dependencies
- Report cycles with file chain (A → B → C → A)

#### 3.4 Security Scan
- Pattern matching for common vulnerabilities:
  - Hardcoded secrets (API keys, passwords, tokens)
  - SQL injection patterns (string concatenation in queries)
  - Missing input validation at system boundaries
  - Insecure auth/session handling
- Flag findings with severity (✗ critical, ⚠ warning)

#### 3.5 Performance Anti-Patterns
- N+1 query detection (loops with database calls)
- Blocking I/O in async contexts (sync file reads, network calls)
- Synchronous operations in hot paths
- Flag with file:line and explanation

### Track-Level Validation (specific track)

Run project-level checks scoped to changed files, PLUS:

#### 3.6 Spec Compliance
- Parse `draft/tracks/<track-id>/spec.md` for acceptance criteria
- Verify each criterion has corresponding test coverage
- Report uncovered criteria

#### 3.7 Architectural Impact
- Analyze changed files from git diff
- Check for new dependencies not in `tech-stack.md`
- Verify changes follow architectural patterns from `architecture.md`
- Flag pattern violations

#### 3.8 Regression Risk
- Identify changed files
- Build dependency graph to find affected modules
- Report blast radius (module count, critical paths affected)

## Step 4: Generate Validation Report

Create structured markdown report.

### Report Location
- Project-level: `draft/validation-report.md`
- Track-level: `draft/tracks/<track-id>/validation-report.md`

### Report Format

```markdown
# Validation Report

**Generated:** [ISO timestamp]
**Scope:** [whole-codebase | track: <track-id>]

## Summary
- ✓ [count] checks passed
- ⚠ [count] warnings
- ✗ [count] critical issues

---

## Architecture Conformance ([✓/⚠/✗] [passed]/[total])
[List of checks with status]

## Dead Code ([✓/⚠/✗] [passed]/[total])
[List of unused exports/functions]

## Dependency Cycles ([✓/⚠/✗] [passed]/[total])
[List of circular dependencies]

## Security ([✓/⚠/✗] [passed]/[total])
[List of vulnerabilities]

## Performance ([✓/⚠/✗] [passed]/[total])
[List of anti-patterns]

[Track-Level Only Sections:]

## Spec Compliance ([✓/⚠/✗] [passed]/[total])
[Acceptance criteria coverage]

## Architectural Impact ([✓/⚠/✗] [passed]/[total])
[New dependencies, pattern violations]

## Regression Risk ([✓/⚠/✗] [passed]/[total])
[Blast radius analysis]
```

### Status Markers
- ✓ - Check passed
- ⚠ - Warning (non-critical issue)
- ✗ - Critical issue (requires attention)

## Step 5: Present Results

Announce validation results:

```
Validation complete.

Scope: [whole-codebase | track: <track-id>]
Results: ✓ [pass] | ⚠ [warn] | ✗ [critical]

Report: [path to report file]

[If warnings or critical issues:]
Review the report for details. Validation is non-blocking unless configured otherwise in workflow.md.

[If block-on-failure enabled and critical issues found:]
⚠️  VALIDATION FAILED - Critical issues must be resolved before proceeding.
```

## Integration with /draft:implement

When called from `/draft:implement` at track completion:
1. Read `workflow.md` validation config
2. If auto-validate enabled, run track-level validation
3. Generate report
4. If block-on-failure enabled and critical issues found, halt implementation
5. Otherwise, warn and continue

## Red Flags - STOP if you're:

- Reporting validation results without actually running checks
- Making up check counts or findings
- Skipping categories of validation
- Not generating the actual report file
- Claiming "no issues" without evidence

## Notes

- Validation complements `/draft:coverage` (tests) with architectural/security checks
- Non-blocking by default to maintain velocity
- Leverages Draft context for intelligent, project-specific validation
- Track-level validation scopes to changed files for faster feedback
