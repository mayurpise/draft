---
name: validate
description: Validate codebase quality using Draft context (architecture.md, product.md, tech-stack.md). Runs project-level or track-level validation with configurable automatic execution.
---

# Validate Codebase

You are validating codebase quality using Draft context files to ensure architectural conformance, security, and spec compliance.

## Red Flags - STOP if you're:

- Reporting validation results without actually running checks
- Making up check counts or findings
- Skipping categories of validation
- Not generating the actual report file
- Claiming "no issues" without evidence

**Run the checks. Report the evidence.**

---

## Usage

- `/draft:validate` - Validate entire codebase
- `/draft:validate <track-id>` - Validate specific track

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
- **Track-Level:** `<track-id>` → validate specific track

### Track-Level Mode

If `<track-id>` specified:

1. Verify track exists: `ls draft/tracks/<track-id>/spec.md`
2. If not found, tell user: "Track '<track-id>' not found. Check `draft/tracks.md` for valid track IDs."
3. Read `draft/tracks/<track-id>/spec.md` for acceptance criteria
4. Get changed files via git: `git diff --name-only main..HEAD` (or appropriate base branch)

## Step 2: Load Draft Context

Read the following context files:

1. `draft/workflow.md` - Check validation configuration, **Guardrails** section
2. `draft/tech-stack.md` - Technology constraints, dependency list, **Accepted Patterns** section
3. `draft/product.md` - Product context, guidelines (optional)
4. `draft/architecture.md` - Architectural patterns (if exists)

**Important context sections:**
- `tech-stack.md` `## Accepted Patterns` - Skip flagging these as issues (intentional design decisions)
- `workflow.md` `## Guardrails` - Enforce checked guardrails as validation rules

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

**Goal:** Verify code follows documented architectural patterns.

**Process:**

1. **Check for architecture.md:**
   ```bash
   ls draft/architecture.md 2>/dev/null
   ```
   If missing, skip this check with message: "No architecture.md found - skipping pattern validation"

2. **Parse architectural patterns:**
   - Read `draft/architecture.md`
   - Search for sections: "Patterns", "Standards", "Conventions", "Code Organization"
   - Extract documented rules (look for bullets, numbered lists, bolded statements)
   - Common pattern types:
     - File organization (e.g., "All components in src/components/")
     - Naming conventions (e.g., "Test files must end in .test.ts")
     - Structural rules (e.g., "All API routes use auth middleware")
     - Dependency rules (e.g., "UI components cannot import from database layer")

3. **Validate patterns:**
   - For each documented pattern, verify compliance using grep/find
   - Example checks:
     ```bash
     # Pattern: "All API routes use auth middleware"
     grep -r "app\.(get|post|put|delete)" --include="*.ts" | grep -v "authMiddleware"

     # Pattern: "Test files end in .test.ts"
     find . -path "*/test/*" -name "*.ts" ! -name "*.test.ts"

     # Pattern: "No direct database imports in UI layer"
     grep -r "import.*from.*database" src/components/
     ```

4. **Report violations:**
   - List file:line for each violation
   - Include pattern name and expected behavior
   - Classify severity based on architecture.md language:
     - "MUST" / "REQUIRED" → ✗ Critical
     - "SHOULD" / "RECOMMENDED" → ⚠ Warning

**Output format:**
```
✓ All API routes use auth middleware (15 files checked)
✗ **CRITICAL:** src/components/UserList.tsx:12 - Direct database import (violates layer separation)
⚠ src/utils/helper.ts - Missing header comment (recommended by standards)
```

#### 3.2 Dead Code Detection

**Goal:** Identify unused exports and unreferenced code.

**Process:**

1. **Identify source directories:**
   - Read `tech-stack.md` for project structure hints
   - Common patterns: `src/`, `lib/`, `app/`, `packages/`
   - Exclude: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.test.*`, `*.spec.*`

2. **Find all exports:**
   ```bash
   # JavaScript/TypeScript
   grep -r "export \(default\|const\|function\|class\|interface\|type\)" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx"

   # Python
   grep -r "^def \|^class " --include="*.py" | grep -v "^    "  # Top-level only

   # Go
   grep -r "^func [A-Z]" --include="*.go"  # Exported functions (capitalized)
   ```

3. **Track imports/references:**
   - For each exported symbol, search for imports/usage across codebase
   - Exclude self-references (same file)
   ```bash
   # Check if 'UserService' is imported anywhere
   grep -r "import.*UserService" src/ --exclude="user-service.ts"
   grep -r "UserService" src/ --exclude="user-service.ts"
   ```

4. **Flag unreferenced exports:**
   - Exports with zero external references → potential dead code
   - Note: May be public API, CLI entry points, or future use
   - Classify as ⚠ Warning (not Critical) - requires manual review

**Output format:**
```
⚠ src/utils/old-parser.ts:15 - Function 'parseOldFormat' has no references (0 imports)
⚠ src/components/Deprecated.tsx - Entire file unreferenced (no imports)
✓ src/services/user.ts - All exports referenced
```

**Performance optimization:**
- Limit to files changed in last 90 days if full scan takes >10s
- Use `git log --since="90 days ago" --name-only --pretty=format: | sort -u`

#### 3.3 Dependency Cycle Detection

**Goal:** Detect circular dependencies that can cause runtime errors and complicate maintenance.

**Process:**

1. **Build dependency graph:**
   - Parse import statements from source files
   ```bash
   # JavaScript/TypeScript - extract imports
   grep -r "import.*from" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx"

   # Python
   grep -r "^import \|^from .* import" --include="*.py"

   # Go
   grep -r "^import" --include="*.go"
   ```

2. **Detect cycles using tools:**
   - **JavaScript/TypeScript:**
     ```bash
     # Use madge if available
     npx madge --circular src/

     # Fallback: manual cycle detection
     # For each file, trace import chain and detect if it imports itself transitively
     ```

   - **Python:**
     ```bash
     # Use pydeps if available
     pydeps --show-cycles src/

     # Fallback: parse import statements and build adjacency list
     ```

   - **Go:**
     ```bash
     # Go detects cycles at compile time
     go list -f '{{.ImportPath}} {{.Imports}}' ./... | grep cycle
     ```

3. **Manual cycle detection (fallback):**
   - Build adjacency list: `file -> [imported files]`
   - Run depth-first search (DFS) with visited tracking
   - If visiting a node already in current path → cycle detected
   - Record cycle chain

4. **Report cycles:**
   - Show complete cycle chain (A → B → C → A)
   - Classify as ✗ Critical (cycles break modularity)
   - Suggest breaking the cycle (extract interface, dependency injection)

**Output format:**
```
✗ **CRITICAL:** Circular dependency detected
   src/services/user.ts → src/models/user.ts → src/services/auth.ts → src/services/user.ts
   Suggestion: Extract shared types to src/types/user.ts

✓ No circular dependencies detected (42 files analyzed)
```

**Tool detection priority:**
1. Check package.json for madge/pydeps/eslint-plugin-import
2. Try running tool directly (may be globally installed)
3. Fall back to manual detection if no tools available

#### 3.4 Security Scan

**Goal:** Detect common security vulnerabilities aligned with OWASP Top 10 (2021).

**OWASP Top 10 Coverage:**
| # | OWASP Category | Check |
|---|----------------|-------|
| A01 | Broken Access Control | Auth/authz checks below |
| A02 | Cryptographic Failures | Weak hashing, hardcoded secrets |
| A03 | Injection | SQL injection, command injection |
| A04 | Insecure Design | Missing input validation |
| A05 | Security Misconfiguration | Cookie flags, CORS, headers |
| A06 | Vulnerable Components | Dependency audit |
| A07 | Auth Failures | JWT misuse, session handling |
| A08 | Data Integrity Failures | Insecure deserialization |
| A09 | Logging Failures | Missing security event logging |
| A10 | SSRF | Server-side request forgery patterns |

**Process:**

1. **Hardcoded Secrets Detection (A02):**
   ```bash
   # API keys, tokens, passwords in source code
   grep -rE "(api[_-]?key|API[_-]?KEY|secret|SECRET|password|PASSWORD|token|TOKEN)\s*=\s*['\"][^'\"]{8,}" src/ --exclude="*.test.*" --exclude="*.spec.*"

   # AWS credentials
   grep -rE "AKIA[0-9A-Z]{16}" src/

   # Private keys
   grep -rE "BEGIN (RSA |EC |DSA )?PRIVATE KEY" src/

   # Database URLs with credentials
   grep -rE "(postgres|mysql|mongodb)://[^:]+:[^@]+@" src/
   ```
   - Exclude: `.env.example`, test fixtures, documentation
   - Severity: ✗ Critical

2. **Injection Patterns (A03):**
   ```bash
   # String concatenation in queries (JavaScript/TypeScript)
   grep -rE "(query|execute)\s*\(\s*['\"`].*\$\{|query.*\+\s*[a-zA-Z]" src/ --include="*.ts" --include="*.js"

   # Python f-strings in queries
   grep -rE "execute\(f['\"]|cursor\.execute\(.*\{" --include="*.py"

   # Raw SQL construction
   grep -rE "\"SELECT.*\"\s*\+|'SELECT.*'\s*\+" src/
   ```
   - Severity: ✗ Critical

3. **Missing Input Validation (A04):**
   ```bash
   # API routes without validation middleware
   # Check if request parameters used directly without validation
   grep -rE "req\.(body|params|query)\.[a-zA-Z]+\s*\)" src/routes/ src/api/ --include="*.ts" --include="*.js"

   # Look for sanitization/validation patterns nearby
   # If missing, flag as warning
   ```
   - Severity: ⚠ Warning (manual review needed)

4. **Insecure Auth/Session Handling (A01, A07):**
   ```bash
   # JWT without secret validation
   grep -rE "jwt\.decode\(" src/ --include="*.ts" --include="*.js"  # Should use verify, not decode

   # Session cookies without httpOnly/secure flags
   grep -rE "cookie\(.*\)" src/ | grep -v "httpOnly.*secure"

   # Weak password hashing (MD5, SHA1)
   grep -rE "(md5|MD5|sha1|SHA1)\(" src/
   ```
   - Severity: ✗ Critical (JWT, weak hashing), ⚠ Warning (cookie flags)

5. **Cross-Site Scripting (A03 — XSS):**
   ```bash
   # Dangerous HTML insertion
   grep -rE "innerHTML\s*=|dangerouslySetInnerHTML" src/ --include="*.tsx" --include="*.jsx"

   # Unescaped user input in templates
   grep -rE "\{\{.*req\.(body|params|query)" src/
   ```
   - Severity: ✗ Critical

6. **Vulnerable Dependencies (A06):**
   ```bash
   # Node.js
   npm audit --json 2>/dev/null | head -50

   # Python
   pip audit 2>/dev/null || safety check 2>/dev/null

   # Go
   govulncheck ./... 2>/dev/null
   ```
   - If audit tool unavailable, check for known-vulnerable version patterns
   - Severity: ✗ Critical (known CVEs), ⚠ Warning (outdated dependencies)

7. **CSRF Protection (A01):**
   ```bash
   # State-changing endpoints without CSRF tokens
   grep -rE "(app\.(post|put|delete|patch))" src/ --include="*.ts" --include="*.js" | grep -v "csrf\|CSRF\|csrfToken"

   # Forms without CSRF tokens
   grep -rE "<form.*method=['\"]post['\"]" src/ | grep -v "csrf\|_token"
   ```
   - Severity: ⚠ Warning (requires manual review of auth mechanism — token-based APIs may not need CSRF)

8. **Insecure Deserialization (A08):**
   ```bash
   # Unsafe deserialization (Python)
   grep -rE "pickle\.loads|yaml\.load\((?!.*Loader)" --include="*.py"

   # Unsafe JSON parsing from untrusted sources (Node.js)
   grep -rE "eval\(|new Function\(" src/ --include="*.ts" --include="*.js"

   # Java unsafe deserialization
   grep -rE "ObjectInputStream|readObject\(\)" --include="*.java"
   ```
   - Severity: ✗ Critical

9. **Missing Security Logging (A09):**
   ```bash
   # Auth endpoints without logging
   grep -rE "(login|logout|register|password|auth)" src/ --include="*.ts" --include="*.js" -l | while read f; do
     grep -L "log\.\|logger\.\|console\.log\|winston\.\|pino\." "$f"
   done

   # Failed auth attempts should be logged
   grep -rE "(unauthorized|forbidden|401|403)" src/ | grep -v "log\|logger"
   ```
   - Severity: ⚠ Warning

10. **Server-Side Request Forgery (A10):**
    ```bash
    # URL from user input passed to fetch/request
    grep -rE "(fetch|axios|request|http\.get)\s*\(\s*(req\.|params\.|query\.|body\.)" src/ --include="*.ts" --include="*.js"

    # Python
    grep -rE "(requests\.get|urlopen)\s*\(.*request\." --include="*.py"
    ```
    - Severity: ✗ Critical

**Output format:**
```
✗ **CRITICAL:** src/auth/jwt.ts:23 - Hardcoded JWT secret "my-secret-key"
   Risk: Secret exposed in version control
   Fix: Move to environment variable (process.env.JWT_SECRET)

✗ **CRITICAL:** src/api/users.ts:45 - SQL injection risk
   Code: query("SELECT * FROM users WHERE id = " + userId)
   Fix: Use parameterized queries

⚠ src/routes/posts.ts:67 - Missing input validation on req.body.email
   Recommendation: Add validation middleware or zod schema

✓ No hardcoded secrets detected (38 files scanned)
```

**Exclusions:**
- Test files (*.test.*, *.spec.*)
- Example/documentation files
- Third-party code (node_modules, vendor)

#### 3.5 Performance Anti-Patterns

**Goal:** Identify common performance issues that degrade application responsiveness.

**Process:**

1. **N+1 Query Detection:**
   ```bash
   # Loops with database calls inside (JavaScript/TypeScript)
   grep -rE "for\s*\(.*\)\s*\{" src/ -A 5 --include="*.ts" --include="*.js" | grep -E "(await.*find|query|execute|get)"

   # .map() with async database calls
   grep -rE "\.map\(.*=>.*\{" src/ -A 3 | grep -E "(await.*find|query)"

   # Python loops with ORM queries
   grep -rE "for .* in .*:" --include="*.py" -A 3 | grep -E "(\.get\(|\.filter\(|\.query\()"
   ```
   - Context: Show loop + query lines
   - Severity: ⚠ Warning
   - Suggestion: Use bulk queries (IN clause, joins, eager loading)

2. **Blocking I/O in Async Contexts:**
   ```bash
   # Synchronous file operations in async functions (Node.js)
   grep -rE "async.*function" src/ -A 10 --include="*.ts" --include="*.js" | grep -E "fs\.(readFileSync|writeFileSync|readSync)"

   # Synchronous crypto in async code
   grep -rE "async.*function" src/ -A 10 | grep -E "(crypto\.pbkdf2Sync|bcrypt\.hashSync)"

   # Python blocking calls in async functions
   grep -rE "async def" --include="*.py" -A 10 | grep -E "(open\(|requests\.|time\.sleep)"
   ```
   - Severity: ⚠ Warning
   - Suggestion: Use async alternatives (fs.promises, bcrypt.hash, aiohttp)

3. **Synchronous Operations in Hot Paths:**
   ```bash
   # Sync operations in HTTP handlers/middleware
   grep -rE "(app\.(get|post|put|delete)|router\.|@(Get|Post|Put|Delete))" src/ -A 10 | grep -E "(Sync\(|\.join\(|JSON\.parse)"

   # Heavy computation in request handlers (regex, JSON parsing large payloads)
   grep -rE "(req\.(body|query|params))" src/ -A 3 | grep -E "JSON\.parse.*req\."
   ```
   - Severity: ⚠ Warning (unless proven hot path via profiling)
   - Suggestion: Move to worker threads, use streaming parsers

4. **Missing Pagination:**
   ```bash
   # Database queries without LIMIT
   grep -rE "find\(\)\.toArray\(\)|findAll\(\)|query\(.*SELECT.*FROM" src/ | grep -v "LIMIT\|limit\|take"
   ```
   - Severity: ⚠ Warning
   - Suggestion: Add pagination (LIMIT/OFFSET, cursor-based)

5. **Inefficient String Concatenation in Loops:**
   ```bash
   # String concatenation in loops (JavaScript)
   grep -rE "for\s*\(.*\)\s*\{" src/ -A 5 | grep -E "\+\s*['\"]"

   # Python string concat in loops
   grep -rE "for .* in .*:" --include="*.py" -A 3 | grep -E "\+\s*['\"]"
   ```
   - Severity: ⚠ Warning (micro-optimization, usually not critical)
   - Suggestion: Use array.join() or StringBuilder

**Output format:**
```
⚠ src/api/users.ts:34 - Potential N+1 query
   Code: for (const user of users) { await db.posts.find({ userId: user.id }) }
   Impact: 1 query per user (N+1 pattern)
   Fix: Use JOIN or IN clause: db.posts.find({ userId: { $in: userIds } })

⚠ src/services/crypto.ts:12 - Blocking I/O in async function
   Code: async hashPassword() { bcrypt.hashSync(password, 10) }
   Impact: Blocks event loop during CPU-intensive hashing
   Fix: Use async variant: await bcrypt.hash(password, 10)

⚠ src/api/posts.ts:56 - Missing pagination
   Code: const posts = await db.posts.find()
   Impact: Could fetch millions of records
   Fix: Add limit: find().limit(100)

✓ No N+1 queries detected in hot paths
```

**Note:** Performance warnings require context - mark as ⚠ Warning, not ✗ Critical, unless clearly in hot path.

### Track-Level Validation (specific track)

Run project-level checks scoped to changed files, PLUS:

#### 3.6 Spec Compliance

**Goal:** Verify all acceptance criteria from spec.md have corresponding test coverage.

**Process:**

1. **Parse acceptance criteria:**
   ```bash
   # Read spec.md and extract acceptance criteria section
   grep -A 100 "## Acceptance Criteria" draft/tracks/<track-id>/spec.md
   ```

2. **Extract individual criteria:**
   - Look for checkbox list items: `- [ ] Criterion text`
   - Parse each criterion into testable requirement
   - Example: "User can login with email and password" → need login test

3. **Search for corresponding tests:**
   - For each criterion, search test files for related tests
   - Common test file patterns:
     ```bash
     # Find test files
     find . -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.py"

     # Search for test cases related to criterion
     grep -r "describe\|it\|test\|def test_" <test-files> | grep -i "<criterion-keywords>"
     ```

4. **Match criteria to tests:**
   - Extract keywords from criterion (e.g., "login", "email", "password")
   - Search test files for test cases with those keywords
   - Check test descriptions match criterion intent
   - Example matching:
     ```
     Criterion: "User can login with email and password"
     Keywords: login, email, password
     Found: it("should login user with valid email and password")
     Status: ✓ Covered
     ```

5. **Report uncovered criteria:**
   - List criteria without matching tests
   - Suggest test cases to write

**Output format:**
```
Spec Compliance: 4/5 criteria covered

✓ Criterion: "User can login with email and password"
   Test: src/auth/auth.test.ts:12 - "should login user with valid email and password"

✗ Criterion: "System sends password reset email"
   Status: No matching test found
   Suggestion: Add test in src/auth/password-reset.test.ts

✓ Criterion: "Invalid credentials show error message"
   Test: src/auth/auth.test.ts:34 - "should show error for invalid credentials"
```

**Matching strategy:**
- Exact keyword match (high confidence)
- Fuzzy match with keyword overlap (medium confidence)
- Manual review needed if no match (list as uncovered)

#### 3.7 Architectural Impact

**Goal:** Detect if track changes introduce new dependencies or violate architectural patterns.

**Process:**

1. **Get changed files:**
   ```bash
   # Get files modified in current branch vs main
   git diff --name-only main..HEAD

   # Or from track metadata (git log since track creation)
   git log --since="<track-created-date>" --name-only --pretty=format: | sort -u
   ```

2. **Detect new dependencies:**
   - Parse import statements from changed files
   - Extract package/module names
   ```bash
   # JavaScript/TypeScript - extract npm packages
   grep "import.*from ['\"]" <changed-files> | grep -v "^\./" | grep -v "^@/"

   # Python - extract pip packages
   grep "^import \|^from .* import" <changed-files> | grep -v "^\."

   # Go - extract go modules
   grep "import \"" <changed-files> | grep -v "^\."
   ```

3. **Cross-reference with tech-stack.md:**
   - Read `draft/tech-stack.md`
   - Extract documented dependencies (frameworks, libraries)
   - Compare imported packages against documented list
   - Flag any new packages not in tech-stack.md

4. **Check architectural pattern compliance:**
   - If `draft/architecture.md` exists, read documented patterns
   - Run same pattern checks as Section 3.1 but scoped to changed files only
   - Common violations:
     - UI layer importing from database layer
     - Breaking module boundaries
     - Violating dependency direction rules

**Output format:**
```
Architectural Impact Analysis

New Dependencies Detected:
⚠ axios (src/api/client.ts:3)
   Not documented in tech-stack.md
   Recommendation: Update tech-stack.md or use existing fetch API

✓ All imports use documented dependencies

Pattern Violations:
✗ src/components/UserProfile.tsx:15 - Direct database import
   Pattern: UI components cannot import from database layer
   File imports: import { db } from '../database/client'
   Fix: Use API service layer instead

✓ No architectural pattern violations detected

Summary:
- 1 new dependency (requires documentation)
- 1 pattern violation (critical)
- 12 files changed, 11 compliant
```

#### 3.8 Regression Risk

**Goal:** Analyze the blast radius of track changes to identify regression risk.

**Process:**

1. **Identify changed files:**
   ```bash
   git diff --name-only main..HEAD
   ```

2. **Find reverse dependencies (who imports these files):**
   ```bash
   # For each changed file, find all files that import it
   for file in <changed-files>; do
     # Extract module name/path
     module_path=$(echo $file | sed 's/\.[^.]*$//')  # Remove extension

     # Search for imports of this module
     grep -r "import.*from ['\"].*$module_path" src/ --include="*.ts" --include="*.js" --include="*.py"
   done
   ```

3. **Build affected module tree:**
   - Start with changed files (direct impact)
   - Find files that import changed files (1st degree impact)
   - Recursively find files that import 1st degree files (2nd degree impact)
   - Stop at 2-3 degrees to avoid full tree explosion

4. **Identify critical paths:**
   - Critical path indicators:
     - Authentication/authorization modules
     - Database connection/transaction handling
     - Payment processing
     - API entry points (routes, controllers)
   - Check if changed files or their dependents match critical patterns:
     ```bash
     grep -E "(auth|login|session|payment|transaction|database|db)" <affected-files>
     ```

5. **Calculate blast radius:**
   - Count unique affected files
   - Classify by degree (direct, 1st, 2nd)
   - Flag if critical paths affected

**Output format:**
```
Regression Risk Analysis

Changed Files: 3
- src/services/user.ts
- src/models/user.ts
- src/utils/validation.ts

Blast Radius:
- Direct impact: 3 files
- 1st degree: 14 files (import changed modules)
- 2nd degree: 27 files (transitively affected)
- Total affected: 44 files

Critical Paths Affected:
⚠ Authentication flow (src/auth/middleware.ts imports src/services/user.ts)
⚠ User API endpoints (src/api/users.ts imports src/services/user.ts)
✓ Payment processing not affected

Risk Level: MEDIUM
- Moderate blast radius (44 files)
- 2 critical paths affected
- Recommendation: Run full integration tests, especially auth flow

Affected Modules by Degree:
[1st] src/api/users.ts
[1st] src/auth/middleware.ts
[1st] src/components/UserProfile.tsx
[2nd] src/api/posts.ts (via users.ts)
[2nd] src/pages/Dashboard.tsx (via UserProfile.tsx)
... (39 more files)
```

**Risk Classification:**
- **LOW:** <10 affected files, no critical paths
- **MEDIUM:** 10-50 affected files or 1-2 critical paths
- **HIGH:** >50 affected files or 3+ critical paths

**Performance:** Limit dependency traversal to 2 degrees and top 50 most-impacted files to keep report concise.

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

### Implementation

1. **Collect all validation results** from Steps 3.1-3.8
2. **Count status markers:** total ✓, ⚠, ✗ across all sections
3. **Generate report file** using template above
4. **Write to correct path:**
   ```bash
   # Project-level
   cat > draft/validation-report.md <<'EOF'
   [report content]
   EOF

   # Track-level
   cat > draft/tracks/<track-id>/validation-report.md <<'EOF'
   [report content]
   EOF
   ```
5. **Include timestamp:** ISO 8601 format (e.g., `2026-02-03T14:30:00Z`)
6. **Omit empty sections:** If a validation category has no findings, show "✓ No issues detected"

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

## Notes

- Validation complements `/draft:coverage` (tests) with architectural/security checks
- Non-blocking by default to maintain velocity
- Leverages Draft context for intelligent, project-specific validation
- Track-level validation scopes to changed files for faster feedback
