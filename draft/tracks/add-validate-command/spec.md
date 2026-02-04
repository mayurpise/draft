# Specification: Add Validate Command

**Track ID:** add-validate-command
**Created:** 2026-02-03
**Status:** [ ] Draft

## Summary
Implement `/draft:validate` command for systematic codebase quality validation using Draft context (architecture.md, product.md, tech-stack.md). Validates both whole codebase and individual tracks with configurable automatic execution at track completion.

## Background
After `/draft:init` generates comprehensive project context (architecture.md with diagrams, product.md, tech-stack.md), developers need systematic validation to ensure:
- Code conforms to documented architecture patterns
- Security vulnerabilities are caught early
- Track changes don't violate architectural constraints
- Acceptance criteria are testable and verified

This extends Context-Driven Development with practical, consistent baseline testing accessible to all skill levels.

## Requirements

### Functional

1. **Command Variants**
   - `/draft:validate` - validates entire codebase
   - `/draft:validate --track <track-id>` - validates specific track

2. **Project-Level Validation** (whole codebase)
   - Architecture conformance: detect violations of patterns in architecture.md
   - Dead code detection: unused exports, unreachable code
   - Dependency cycle detection: circular dependencies
   - Security scan: basic OWASP checks (hardcoded secrets, injection vulnerabilities)
   - Performance anti-patterns: N+1 queries, blocking I/O in hot paths

3. **Track-Level Validation** (specific track)
   - All project-level checks scoped to track-modified files
   - Spec compliance: verify acceptance criteria have corresponding tests
   - Architectural impact: detect new dependencies not in tech-stack.md, pattern violations
   - Regression risk: analyze blast radius of changes, identify affected critical paths

4. **Automatic Execution**
   - Runs at track completion during `/draft:implement` when enabled
   - Proceeds with warnings (non-blocking)
   - Documents all issues in validation report

5. **Output Reports**
   - Project-level: `draft/validation-report.md`
   - Track-level: `draft/tracks/<track-id>/validation-report.md`
   - Format: grouped by category (✓ pass, ⚠ warning, ✗ critical)

6. **Configuration** (in workflow.md)
   ```markdown
   ## Validation
   - [x] Auto-validate at track completion
   - [ ] Block on validation failures (vs warn-only)
   - Scope: architecture, security, performance, spec-compliance
   ```

### Non-Functional

- **Performance**: Validation should complete within 30s for typical projects (<100k LOC)
- **Accuracy**: Minimize false positives (prefer under-reporting to noise)
- **Context-Awareness**: Leverage architecture.md, product.md, tech-stack.md for intelligent validation

## Acceptance Criteria

- [ ] `/draft:validate` validates entire codebase and generates `draft/validation-report.md`
- [ ] `/draft:validate --track <id>` validates track-specific changes and generates `draft/tracks/<id>/validation-report.md`
- [ ] Project-level validation includes: architecture conformance, dead code, dependency cycles, security scan, performance anti-patterns
- [ ] Track-level validation includes: spec compliance, architectural impact, regression risk
- [ ] Validation automatically runs at track completion when enabled in workflow.md
- [ ] Validation failures produce warnings (non-blocking) with documented issues
- [ ] Configuration options in workflow.md control auto-validation and blocking behavior
- [ ] Validation reports use ✓/⚠/✗ format grouped by category
- [ ] Validation leverages architecture.md for pattern checking and tech-stack.md for dependency validation

## Non-Goals

- Replacing existing linters (ESLint, Prettier, TypeScript compiler)
- Unit test generation or test coverage computation (see `/draft:coverage`)
- Dynamic analysis or runtime profiling (future Phase 2)
- AI-powered code review (separate from systematic validation)

## Technical Approach

### Skill Structure
Create `skills/validate/SKILL.md` following plugin architecture:
```yaml
---
name: validate
description: Validate codebase quality using Draft context
---
```

### Validation Engine Components

1. **Architecture Validator**
   - Parse architecture.md for documented patterns
   - Use AST analysis to detect pattern violations
   - Example: "All API routes use middleware X" → verify in routes/

2. **Security Scanner**
   - Grep for common vulnerability patterns (hardcoded secrets, SQL injection)
   - Check auth/session handling against security best practices
   - Flag missing input validation at system boundaries

3. **Dependency Analyzer**
   - Build dependency graph via import analysis
   - Detect cycles using tarjan's algorithm
   - Flag new dependencies not in tech-stack.md

4. **Dead Code Detector**
   - Track exports vs imports across codebase
   - Identify unreferenced functions/classes
   - Flag for manual review (may be public API)

5. **Performance Analyzer**
   - Pattern match for N+1 query indicators (loops with DB calls)
   - Detect blocking I/O in async contexts
   - Flag synchronous operations in hot paths

6. **Track-Specific Validators**
   - **Spec Compliance**: Parse `spec.md` acceptance criteria, verify test file coverage
   - **Architectural Impact**: Git diff analysis → cross-reference with architecture.md
   - **Regression Risk**: Analyze changed files → compute affected module count via dependency graph

### Integration Points
- Hook into `/draft:implement` phase completion logic
- Read `workflow.md` for configuration
- Generate structured markdown reports

### Report Format
```markdown
# Validation Report

**Generated:** [timestamp]
**Scope:** [whole-codebase | track-id]

## Summary
- ✓ 45 checks passed
- ⚠ 3 warnings
- ✗ 1 critical issue

---

## Architecture Conformance (✓ 12/12)
✓ All API routes use auth middleware
✓ Database access follows repository pattern
...

## Security (⚠ 1 warning, ✗ 1 critical)
✗ **CRITICAL:** auth/jwt.ts:23 - JWT secret hardcoded
⚠ api/users.ts:67 - Missing input validation on email field
...

## Dead Code (⚠ 2 warnings)
⚠ utils/legacy.ts:15 - Function `oldParser` has no references
⚠ components/Deprecated.tsx - Entire file unreferenced
...
```

## Open Questions
None - requirements clarified.
