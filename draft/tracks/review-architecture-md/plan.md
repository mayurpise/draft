# Plan: Review & Fix architecture.md Feature

**Track ID:** review-architecture-md
**Spec:** ./spec.md
**Status:** [x] Completed

## Overview
Fix 6 identified gaps in the architecture.md feature across methodology, agent, template, and skill files. Changes follow the source-of-truth hierarchy: methodology → agents/templates → skills → .cursorrules.

---

## Phase 1: Methodology & Agent Updates
**Goal:** Fix the upstream source-of-truth files first
**Verification:** methodology.md and architect.md are internally consistent; new sections are referenced correctly

### Tasks
- [x] **Task 1.1:** Add coverage results format to methodology.md
  - Define exact markdown section structure for recording coverage in plan.md and architecture.md
  - Files: `core/methodology.md`

- [x] **Task 1.2:** Expand cycle-breaking strategy in architect.md
  - Add decision framework: when to extract, naming conventions, responsibility rules
  - Include one concrete example (e.g., shared data module extracted from two coupled modules)
  - Files: `core/agents/architect.md`

- [x] **Task 1.3:** Add language-specific API surface examples to architect.md
  - Cover TypeScript, Python, Go, Rust patterns
  - Show how to represent exported functions, interfaces, protocols
  - Files: `core/agents/architect.md`

- [x] **Task 1.4:** Clarify story format lifecycle in architect.md
  - Document when stories are written (during decompose), where they go (architecture.md), and how they relate to the template placeholder
  - Files: `core/agents/architect.md`

---

## Phase 2: Template & Skill Updates
**Goal:** Update derived files to match upstream changes
**Verification:** Template and skill reference the new guidance from Phase 1; no contradictions

### Tasks
- [x] **Task 2.1:** Update architecture.md template story placeholder
  - Replace generic `[placeholder]` with lifecycle instructions referencing architect.md story format
  - Add example of a populated story section
  - Files: `core/templates/architecture.md`

- [x] **Task 2.2:** Add API surface examples to architecture.md template
  - Add language-specific examples matching architect.md guidance from Task 1.3
  - Files: `core/templates/architecture.md`

- [x] **Task 2.3:** Operationalize codebase scanning in decompose SKILL.md
  - Add concrete patterns for Step 2: file extensions to scan, directory patterns, what to look for (exports, imports, entry points)
  - Files: `skills/decompose/SKILL.md`

- [x] **Task 2.4:** Define plan merge logic in decompose SKILL.md
  - Add explicit rules for Step 6: how to handle existing tasks when restructuring plan.md around modules
  - Cover: preserve completed tasks, remap in-progress tasks, flag conflicts for developer review
  - Files: `skills/decompose/SKILL.md`

---

## Phase 3: Integration & Rebuild
**Goal:** Regenerate .cursorrules and verify consistency
**Verification:** .cursorrules reflects skill changes; all files are cross-referenced correctly

### Tasks
- [x] **Task 3.1:** Run build-cursorrules.sh
  - Files: `integrations/cursor/.cursorrules`

- [x] **Task 3.2:** Cross-reference audit
  - Verify all 4 source files reference each other consistently
  - Check that methodology → architect → template → skill chain has no broken references
  - Files: all 4 source files

---

## Notes
- Phase 1 must complete before Phase 2 (source-of-truth hierarchy)
- Phase 3 depends on both Phase 1 and Phase 2
- All changes are additive — no existing behavior is removed or broken
