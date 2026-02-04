# Plan: Add GitHub Copilot Integration

**Track ID:** add-copilot-integration
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview
Generate `copilot-instructions.md` from Draft skill files (same source as `.cursorrules`), unify the build script, and update all project documentation to keep integrations in sync.

---

## Phase 1: Unified Build Script
**Goal:** Replace `build-cursorrules.sh` with `build-integrations.sh` that generates both Cursor and Copilot outputs
**Verification:** Running `./scripts/build-integrations.sh` produces `integrations/cursor/.cursorrules` identical to current output

### Tasks
- [x] **Task 1.1:** Create `scripts/build-integrations.sh` by refactoring `build-cursorrules.sh`
  - Extract shared functions (SKILL_ORDER, extract_body, get_skill_header, get_skill_trigger) into reusable section
  - Keep `build_cursorrules()` function intact for Cursor output
  - Add `build_copilot()` function stub (placeholder — content in Phase 2)
  - Add `main()` that calls both builders and reports results
  - Files: `scripts/build-integrations.sh`

- [x] **Task 1.2:** Create backward-compat wrapper `scripts/build-cursorrules.sh`
  - Thin script that calls `build-integrations.sh`
  - Print deprecation notice pointing to the new script
  - Files: `scripts/build-cursorrules.sh`

- [x] **Task 1.3:** Verify Cursor output regression
  - Save current `.cursorrules` output as baseline
  - Run new `build-integrations.sh`
  - Diff the outputs — must be identical
  - Files: `integrations/cursor/.cursorrules`

---

## Phase 2: Copilot Integration Content
**Goal:** Generate valid `copilot-instructions.md` with Copilot-appropriate syntax
**Verification:** Generated file contains no `@draft`, no `/draft:`, no dead agent references; reads correctly as standalone doc

### Tasks
- [x] **Task 2.1:** Implement Copilot syntax transform function
  - Transform `@draft <cmd>` → `"draft <cmd>"` (quoted, no @)
  - Transform `@draft` (standalone) → `"draft"` or `Draft`
  - Preserve `/draft:` → natural language transform (already handled by existing `transform_syntax`)
  - Handle edge cases: backtick-wrapped commands, table cells, trigger phrases
  - Files: `scripts/build-integrations.sh`

- [x] **Task 2.2:** Implement `build_copilot()` function
  - Generate header with Copilot-specific framing (no `@` mention instructions)
  - Reuse shared skill content assembly (same as Cursor)
  - Apply Copilot syntax transform as final pass
  - Output to `integrations/copilot/.github/copilot-instructions.md`
  - Files: `scripts/build-integrations.sh`

- [x] **Task 2.3:** Add Copilot verification checks to `main()`
  - Verify no `@draft` references in Copilot output
  - Verify no `/draft:` references
  - Verify no dead `core/agents/` references
  - Report line count and skill count for Copilot output
  - Files: `scripts/build-integrations.sh`

---

## Phase 3: Documentation Updates
**Goal:** Update all project docs to reflect Copilot integration and unified build
**Verification:** CLAUDE.md, tech-stack.md, and README.md all reference Copilot integration and `build-integrations.sh`

### Tasks
- [x] **Task 3.1:** Update `CLAUDE.md`
  - Add Copilot to source of truth hierarchy (methodology → skills → .cursorrules / copilot-instructions.md)
  - Update plugin structure diagram to include `integrations/copilot/`
  - Update build command from `build-cursorrules.sh` to `build-integrations.sh`
  - Update "Maintaining the Plugin" section
  - Files: `CLAUDE.md`

- [x] **Task 3.2:** Update `draft/tech-stack.md`
  - Add Copilot Integration under Frameworks
  - Update Build section to reference `build-integrations.sh`
  - Files: `draft/tech-stack.md`

- [x] **Task 3.3:** Update `README.md` with Copilot setup instructions
  - Add Copilot to supported integrations list
  - Add setup instructions (copy `integrations/copilot/.github/` to project root)
  - Files: `README.md`

---

## Phase 4: End-to-End Verification
**Goal:** Full validation that both integrations generate correctly from clean state
**Verification:** All acceptance criteria from spec.md pass

### Tasks
- [x] **Task 4.1:** Clean build verification
  - Delete both generated files
  - Run `./scripts/build-integrations.sh`
  - Verify both outputs exist and pass all checks
  - Verify backward-compat wrapper works
  - Files: `scripts/build-integrations.sh`, `scripts/build-cursorrules.sh`

- [x] **Task 4.2:** Content diff review
  - Compare Cursor and Copilot outputs side-by-side
  - Verify methodology content is identical (only syntax differs)
  - Verify Copilot-specific transforms applied correctly
  - Files: `integrations/cursor/.cursorrules`, `integrations/copilot/.github/copilot-instructions.md`

---

## Notes
- The existing `transform_syntax` function already handles `/draft:` → `@draft` for Cursor. Copilot needs a second pass: `@draft` → natural language.
- Copilot's `copilot-instructions.md` has no special format requirements — it's plain markdown injected into the system prompt.
- The backward-compat wrapper ensures anyone with existing scripts or CI referencing `build-cursorrules.sh` isn't broken.
