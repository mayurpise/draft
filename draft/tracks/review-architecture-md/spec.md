# Specification: Review & Fix architecture.md Feature

**Track ID:** review-architecture-md
**Created:** 2026-02-01
**Status:** [ ] Draft

## Summary
Audit and fix the architecture.md feature across all 4 source files — template, agent, decompose skill, and methodology — resolving 6 identified inconsistencies in story lifecycle, cycle breaking, plan merging, codebase scanning, coverage format, and API surface guidance. Rebuild .cursorrules after changes.

## Background
The architecture mode feature spans multiple files with a cascading source-of-truth hierarchy (methodology → agents/templates → skills → .cursorrules). An audit found 6 gaps where these files are inconsistent or underspecified, leading to ambiguous behavior during `/draft:decompose` and architecture-mode implementation.

## Requirements

### Functional
1. **Story placeholder lifecycle:** Define how the `[placeholder]` in architecture.md template gets populated — connect architect.md's story format to the template field with explicit instructions on when and how it's filled
2. **Cycle-breaking strategy:** Expand architect.md's "extract shared interface" guidance with a concrete decision framework: naming conventions, responsibility assignment, and API design for extracted modules
3. **Plan merge logic:** Define explicit rules in decompose SKILL.md for how Step 6 restructures plan.md when tasks already exist — preserve, remap, or flag conflicts
4. **Codebase scanning:** Operationalize Step 2 of decompose SKILL.md with concrete search patterns, file type filters, and directory traversal guidance for identifying modules
5. **Coverage results format:** Define the exact section structure for recording coverage results in both plan.md and architecture.md, referenced from methodology.md
6. **API surface guidance:** Add language-specific examples to architect.md and the template for representing module API surfaces (TypeScript interfaces, Python protocols, Go exported functions, etc.)

### Non-Functional
- All changes must maintain the source-of-truth hierarchy: methodology.md updated first, then derived files
- .cursorrules must be regenerated via `./scripts/build-cursorrules.sh`
- No breaking changes to existing decompose workflow — additions and clarifications only

## Acceptance Criteria
- [ ] Story placeholder in template has clear lifecycle documentation linking to architect.md story format
- [ ] Cycle-breaking section in architect.md includes decision framework with at least one concrete example
- [ ] Decompose SKILL.md Step 6 has explicit merge rules for existing plan tasks
- [ ] Decompose SKILL.md Step 2 lists concrete codebase scanning patterns and tools
- [ ] Methodology.md defines coverage results section format for plan.md and architecture.md
- [ ] Architect.md and template include language-specific API surface examples
- [ ] .cursorrules regenerated and consistent with updated skills
- [ ] All changes follow source-of-truth hierarchy (methodology first)

## Non-Goals
- Adding new skills or commands
- Changing the architecture mode opt-in/opt-out behavior
- Modifying metadata.json schema
- Changing the module decomposition philosophy (single responsibility, 1-3 files, etc.)

## Technical Approach
1. Update `core/methodology.md` first (coverage format, architecture mode clarifications)
2. Update `core/agents/architect.md` (cycle breaking, API surface, story format)
3. Update `core/templates/architecture.md` (story lifecycle, API surface examples)
4. Update `skills/decompose/SKILL.md` (scanning, merge logic)
5. Run `./scripts/build-cursorrules.sh` to regenerate Cursor integration

## Open Questions
- None — scope confirmed by developer
