# Specification: Sync .cursorrules with Draft Skills

**Track ID:** sync-cursorrules
**Created:** 2026-02-01
**Status:** [ ] Draft

## Summary
Fix .cursorrules generation to include all 10 skills, update stale HEADER tables, inline agent behavior summaries to eliminate dead file references, and refactor the build script from hardcoded skill blocks to dynamic discovery.

## Background
The `.cursorrules` file is auto-generated from skill files for Cursor integration. An audit found it missing 3 skills (`draft`, `coverage`, `decompose`), has stale command/intent tables (7 of 10), contains dead agent file references Cursor can't resolve, and uses a hardcoded skill list requiring 3-place changes for each new skill.

## Requirements

### Functional
1. **Add missing skills:** Include `draft` (overview), `coverage`, and `decompose` in .cursorrules output
2. **Update HEADER tables:** Available Commands table must list all 10 commands; Intent Mapping table must include "break into modules" and "check coverage" patterns
3. **Inline agent summaries:** Replace dead `See core/agents/*.md` references with actionable inline summaries for debugger, reviewer, and architect behaviors
4. **Dynamic skill discovery:** Refactor build script to discover skills from `skills/*/SKILL.md` instead of hardcoding each skill block
5. **Maintain syntax transform:** `/draft:` → `@draft` conversion must continue working for all skills

### Non-Functional
- Build script must remain a single bash file with no external dependencies
- Generated .cursorrules must pass existing syntax check (zero `/draft:` references)
- Skill ordering in output should be logical: overview first, then workflow order (init → new-track → decompose → implement → coverage → status → revert → jira-preview → jira-create)

## Acceptance Criteria
- [ ] .cursorrules contains all 10 skills
- [ ] Available Commands table lists all 10 commands
- [ ] Intent Mapping table includes decompose and coverage patterns
- [ ] No `See core/agents/*.md` dead references in .cursorrules — replaced with inline summaries
- [ ] Build script dynamically discovers skills from `skills/*/SKILL.md`
- [ ] Adding a new skill requires only creating `skills/<name>/SKILL.md` (no build script edit needed for the skill block)
- [ ] HEADER and QUALITY sections still derive from build script (not from skill files)
- [ ] `./scripts/build-cursorrules.sh` runs clean with zero warnings
- [ ] Syntax check passes (zero `/draft:` in output)

## Non-Goals
- Changing skill content (SKILL.md files) — this track only fixes the build/sync pipeline
- Inlining full agent file content — only actionable summaries
- Changing methodology.md or template files
- Modifying the Claude Code plugin (only Cursor integration)

## Technical Approach
1. Refactor build script: replace 7 hardcoded skill blocks with a loop over `skills/*/SKILL.md`
2. Add a skill ordering mechanism (ordered list or naming convention)
3. Update HEADER with complete command and intent tables
4. Add inline agent summaries in the QUALITY section
5. Rebuild and verify

## Open Questions
- None
