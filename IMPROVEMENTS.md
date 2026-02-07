# Recommended Improvements

Areas of improvement identified across documentation, build tooling, testing, and consistency.

---

## 1. Build Script: DRY Violation

**File:** `scripts/build-integrations.sh`

`build_cursorrules()` (lines 262-384) and `build_copilot()` (lines 390-512) share ~90% identical code. The only differences are:
- Command syntax (`@draft` vs `draft`)
- Trigger format (from `get_cursor_trigger` vs `get_copilot_trigger`)
- Story lifecycle references (`@draft decompose` vs `draft decompose`)

**Recommendation:** Extract a shared `build_integration()` function parameterized by integration type. Pass the syntax transform function and trigger function as arguments. This eliminates ~120 lines of duplication and ensures future changes to the header, quality disciplines, or proactive sections apply uniformly.

---

## 2. Build Script: Hardcoded Skill Metadata

**File:** `scripts/build-integrations.sh`

Adding a new skill currently requires updating four places:
1. `SKILL_ORDER` array
2. `get_skill_header()` case statement
3. `get_cursor_trigger()` case statement
4. `get_copilot_trigger()` case statement

**Recommendation:** Derive headers and triggers from the SKILL.md frontmatter itself. Add optional `trigger_cursor` and `trigger_copilot` fields to the frontmatter YAML, and extract the `description` field to generate headers automatically. This makes the build script data-driven rather than hardcoded, so adding a new skill only requires creating the SKILL.md file and adding the name to `SKILL_ORDER`.

---

## 3. Build Script: Fragile Line Skipping

**File:** `scripts/build-integrations.sh:351`

```bash
extract_body "$skill_file" | transform_cursor_syntax | tail -n +4
```

The `tail -n +4` hardcodes skipping the first 3 lines after frontmatter extraction. If a skill's body starts with fewer or more blank lines/headers, this silently drops content or includes garbage.

**Recommendation:** Make the body extraction smarter — strip leading blank lines and the first `# Heading` line explicitly by pattern, rather than by fixed line count.

---

## 4. Architecture Discovery: Doc Says "Two-Phase" but Has Three Phases

**File:** `skills/init/SKILL.md:64`

> "For existing codebases, perform a **two-phase** deep analysis to generate `draft/architecture.md`."

The actual implementation describes Phase 1 (Orientation), Phase 2 (Logic), and Phase 3 (Module Discovery) — three phases.

**Recommendation:** Change "two-phase" to "three-phase" at `skills/init/SKILL.md:64`.

---

## 5. Version Mismatch: plugin.json vs Reality

**File:** `.claude-plugin/plugin.json`

`plugin.json` declares `"version": "1.0.0"`, but `CHANGELOG.md` documents a large `[Unreleased]` section with many features already implemented (validate, decompose, coverage, jira-preview, jira-create, architecture mode, copilot/gemini integrations, etc.).

**Recommendation:** Bump the version to `2.0.0` (or at minimum `1.1.0`) to reflect the current state. The `[Unreleased]` changelog section should be tagged when a release is cut.

---

## 6. CLAUDE.md: Incomplete Agent List

**File:** `CLAUDE.md`

The "Architecture" section mentions:
> `core/agents/` — Specialized agent behaviors (debugger, reviewer, planner)

But there are actually 5 agents: `architect.md`, `debugger.md`, `planner.md`, `reviewer.md`, `rca.md`.

**Recommendation:** Update the parenthetical to list all 5 agents, or use a generic description like "Specialized agent behaviors (5 agents)".

---

## 7. CHANGELOG: Inconsistent Command Count

**File:** `CHANGELOG.md:44`

> "Command Reference (all 10 commands)"

There are 11 skills: draft, init, new-track, decompose, implement, coverage, validate, status, revert, jira-preview, jira-create.

**Recommendation:** Change "10 commands" to "11 commands" (or to the correct count if `/draft` overview is excluded from the count).

---

## 8. Legacy Build Script Still Present

**File:** `scripts/build-cursorrules.sh`

The old `build-cursorrules.sh` still exists alongside the unified `build-integrations.sh`. If it's no longer the canonical build path, it's a source of confusion.

**Recommendation:** Either delete it or add a deprecation notice that redirects to `build-integrations.sh`.

---

## 9. Test Coverage Gaps

**File:** `tests/test-build-integrations.sh`

Current gaps:
- **No Gemini tests** — Gemini output is generated but never verified by the test suite.
- **No skill extraction tests** — Doesn't verify individual skill content appears correctly in output.
- **Ephemeral regression baseline** — Baseline stored at `/tmp/cursorrules-baseline`, which is cleared on reboot. The regression test always fails on a fresh machine.
- **No frontmatter validation** — Doesn't check that each SKILL.md has required `name` and `description` fields.

**Recommendation:**
- Add Gemini output assertions (syntax checks, line count, no dead refs).
- Store the regression baseline in the repo (e.g., `tests/fixtures/cursorrules-baseline`).
- Add a test that validates frontmatter presence in all skill files.

---

## 10. No CI/CD Pipeline

There is no GitHub Actions workflow, no automated test run on push/PR. The build script and test suite exist but are only run manually.

**Recommendation:** Add a `.github/workflows/ci.yml` that:
1. Runs `./scripts/build-integrations.sh`
2. Runs `./tests/test-build-integrations.sh`
3. Verifies generated integration files are up-to-date (no uncommitted changes after build)

This prevents integration drift where someone edits a skill but forgets to rebuild.

---

## 11. Gemini Integration: No Customization

**File:** `scripts/build-integrations.sh:518-521`

```bash
build_gemini() {
    build_cursorrules
}
```

Gemini simply reuses the Cursor output verbatim. While this works, Gemini Code Assist may have its own conventions (e.g., Gemini uses `GEMINI.md` at project root, different context window behaviors, different instruction following patterns).

**Recommendation:** At minimum, add a Gemini-specific header noting it's for Gemini Code Assist / Gemini CLI. If Gemini-specific behaviors emerge, the function is already in place for customization.

---

## 12. methodology.md: Scope Creep

**File:** `core/methodology.md`

At 903 lines, this file has grown to include installation instructions, command reference for all 11 commands, agent summaries, integration setup guides, and communication style guidelines — far beyond "methodology." It now duplicates large portions of `README.md`.

**Recommendation:** Trim `methodology.md` to its core purpose: philosophy, constraint hierarchy, quality disciplines, and workflow principles. Move command reference, installation, and integration setup to README.md (where they already exist). This aligns with the source-of-truth hierarchy documented in `CLAUDE.md`, where methodology.md should be the master for methodology concepts, not a second README.

---

## 13. Skill Files: Missing YAML Frontmatter Validation

The build script uses `extract_body()` to strip YAML frontmatter but never validates that the frontmatter contains the required `name` and `description` fields. A malformed SKILL.md would silently produce broken output.

**Recommendation:** Add a validation step in the build script that parses frontmatter and errors if required fields are missing. A simple `grep` for `^name:` and `^description:` within the frontmatter block would suffice.

---

## 14. Makefile: Minimal Utility

**File:** `Makefile`

The Makefile only has `make build` (runs the build script) and `make clean` (no-op). There's no `make test`, no `make lint`, no `make verify`.

**Recommendation:** Add:
- `make test` → runs `tests/test-build-integrations.sh`
- `make verify` → runs build + test + checks for uncommitted diffs
- `make all` → build + test

---

## 15. No Shellcheck / Linting for Bash Scripts

The build and test scripts are 600+ lines of bash with no linting configured. ShellCheck catches common bash pitfalls (unquoted variables, word splitting, POSIX compatibility).

**Recommendation:** Add ShellCheck to the CI pipeline and fix any warnings. This is especially important since the build script is the single most critical piece of code in the repo — it generates all integration files.

---

## Summary: Priority Order

| Priority | Item | Impact | Effort |
|----------|------|--------|--------|
| High | #4 Two-phase → three-phase typo | Factual error in user-facing doc | Trivial |
| High | #5 Version mismatch | Confusing for users/contributors | Trivial |
| High | #6 Incomplete agent list in CLAUDE.md | Misleading for contributors | Trivial |
| High | #7 Command count in CHANGELOG | Factual error | Trivial |
| High | #8 Legacy build script | Source of confusion | Trivial |
| Medium | #1 Build script DRY violation | Maintenance burden | Moderate |
| Medium | #9 Test coverage gaps | Risk of regression | Moderate |
| Medium | #10 CI/CD pipeline | No automated quality gate | Moderate |
| Medium | #13 Frontmatter validation | Silent failures | Small |
| Medium | #14 Makefile improvements | Developer ergonomics | Small |
| Low | #2 Hardcoded skill metadata | Scaling friction | Moderate |
| Low | #3 Fragile line skipping | Edge case risk | Small |
| Low | #11 Gemini customization | Future-proofing | Small |
| Low | #12 methodology.md scope | Documentation hygiene | Large |
| Low | #15 ShellCheck | Code quality | Small |
