# Specification: Add GitHub Copilot Integration

**Track ID:** add-copilot-integration
**Created:** 2026-02-01
**Status:** [ ] Draft

## Summary
Add a GitHub Copilot integration that generates `copilot-instructions.md` from the same skill source files used for Cursor's `.cursorrules`. Unify the build script so all integrations (Cursor, Copilot) are generated from a single command, ensuring they stay in sync.

## Background
Draft currently supports Claude Code (native plugin) and Cursor (generated `.cursorrules`). GitHub Copilot uses `.github/copilot-instructions.md` for the same purpose. Since the methodology content is identical, this is a low-effort, high-reach addition. CLAUDE.md and tech-stack.md must be updated so future contributors maintain all integrations in lockstep.

## Requirements

### Functional
1. Generate `integrations/copilot/.github/copilot-instructions.md` from skill files
2. Transform `@draft <cmd>` syntax to Copilot-appropriate natural language (Copilot has no `@` mention system)
3. Replace `build-cursorrules.sh` with unified `build-integrations.sh` that generates both Cursor and Copilot outputs
4. Old `build-cursorrules.sh` either removed or replaced with a wrapper that calls the unified script (backward compat)
5. Update `CLAUDE.md` to document Copilot integration in the architecture section, source of truth hierarchy, and build commands
6. Update `draft/tech-stack.md` to reference Copilot integration
7. Update `README.md` to list Copilot as a supported integration with setup instructions

### Non-Functional
- Build script must remain POSIX-compatible bash (no external dependencies)
- Generated Copilot file must be a valid standalone markdown document
- Syntax transform must not break methodology content (no false positives)

## Acceptance Criteria
- [ ] Running `./scripts/build-integrations.sh` generates both `integrations/cursor/.cursorrules` and `integrations/copilot/.github/copilot-instructions.md`
- [ ] Copilot output contains no `@draft` references (all transformed to natural language)
- [ ] Copilot output contains no `/draft:` references
- [ ] Copilot output contains no dead `core/agents/` references
- [ ] Cursor output is identical to what `build-cursorrules.sh` produced before (no regression)
- [ ] `CLAUDE.md` documents both integrations and the unified build command
- [ ] `README.md` includes Copilot setup instructions
- [ ] `draft/tech-stack.md` references Copilot integration

## Non-Goals
- `.github/prompts/*.md` per-command prompt files (future enhancement)
- `.github/copilot-review-instructions.md` (separate concern)
- Auto-detection of which IDE the user has (out of scope)
- Copilot-specific features beyond instruction file generation

## Technical Approach
- Extend the existing build script pattern: same `SKILL_ORDER`, `extract_body()`, `transform_syntax()` functions
- Add a Copilot-specific syntax transform that converts `@draft <cmd>` to natural language equivalents
- Add a second output function (`build_copilot`) alongside the existing `build_cursorrules`
- Rename script from `build-cursorrules.sh` to `build-integrations.sh`
- Leave a thin `build-cursorrules.sh` wrapper for backward compatibility

## Open Questions
- None — requirements clarified via dialogue.
