# Specification: Fix Bug Hunt Findings

**Track ID:** fix-bughunt-findings
**Created:** 2026-02-08
**Status:** [x] Complete
**Source:** `draft/bughunt-report.md` (main @ 0369c38)

## Summary

Address 4 actionable findings from the project-wide bug hunt: 2 High documentation staleness issues, 1 Medium security fix, 1 Medium build robustness improvement. Finding #5 (index.html missing /draft:index card) is deferred — tied to uncommitted index feature.

## Requirements

### High Priority

1. **CLAUDE.md stale command list** — Update Repository Overview to reference all 13 commands instead of hardcoding 7
2. **methodology.md missing command sections** — Add documentation sections for 5 missing commands (index, validate, bughunt, review, draft overview) and update intent mapping table

### Medium Priority

3. **index.html missing rel attribute** — Add `rel="noopener noreferrer"` to buymeacoffee link at line 2874
4. **Build script fragile line-skipping** — Document the required skill body format (3-line preamble) in CLAUDE.md, or improve `tail -n +4` to be more robust

### Deferred (Not in Scope)

5. index.html missing /draft:index card — blocked on uncommitted index feature

## Acceptance Criteria

- [ ] CLAUDE.md lists all current commands (or uses a non-enumeration approach)
- [ ] methodology.md has documentation sections for all 14 skills
- [ ] methodology.md intent mapping table is complete
- [ ] index.html:2874 has `rel="noopener noreferrer"`
- [ ] Build script preamble format is either documented or made robust
- [ ] Integrations rebuilt after methodology.md changes

## Non-Goals

- No new features
- No changes to skill implementations
- No index.html /draft:index card (deferred)
