# Specification: Update Project Documentation

**Track ID:** update-project-docs
**Created:** 2026-02-01
**Status:** [ ] Draft

## Summary
Comprehensive overhaul of the three main project documentation files — `core/methodology.md`, `README.md`, and `index.html` — to provide detailed, complete, and polished information about Draft's full feature set, installation, usage, and methodology.

## Background
The current documentation covers core concepts but has gaps: missing feature details (revert workflow, debugging agent, reviewer agent, coverage tool), light installation instructions, and inconsistent depth across files. A full overhaul ensures all three files are authoritative, detailed, and aligned.

## Requirements

### Functional

1. **methodology.md** — Expand with:
   - Detailed revert workflow documentation (task/phase/track level, preview, conflict handling)
   - Expanded debugging agent section (4-phase process, anti-patterns, escalation)
   - Expanded reviewer agent section (two-stage review, issue classification, output template)
   - Detailed decompose workflow (module identification, dependency mapping, codebase scanning)
   - Detailed coverage workflow (tool detection, gap analysis, recording results)
   - Expanded init workflow (brownfield/greenfield detection, product guidelines, architecture mode opt-in)
   - More detailed implement workflow (architecture mode steps: story, execution state, skeletons, chunk limits)
   - Installation and getting-started section

2. **README.md** — Expand with:
   - Detailed installation instructions (prerequisites, Claude Code installation, plugin marketplace, verification)
   - Expanded command descriptions with usage examples and expected output
   - Detailed workflow explanation for each command
   - Architecture Mode section with full feature breakdown
   - Revert workflow explanation
   - Debugging and review process overview
   - Coverage tool documentation
   - Troubleshooting / FAQ section
   - Contributing guidelines (how to add skills, update methodology, rebuild cursorrules)

3. **index.html** — Expand with:
   - Installation / Getting Started section
   - Expanded command reference section (all 10 commands with descriptions)
   - Revert workflow visualization
   - Debugging process visualization
   - Review process visualization
   - Coverage workflow section
   - Chat-driven development problems section (from methodology.md)
   - How Draft solves it section
   - Full constraint mechanism table
   - Expanded "When to Use" section with more examples
   - Credits and license in footer

### Non-Functional
- All three files must be consistent — no contradictions between methodology, README, and landing page
- methodology.md remains the source of truth; README and index.html derive from it
- index.html must maintain existing design system (colors, fonts, component styles)
- README must remain scannable with clear hierarchy

## Acceptance Criteria
- [ ] methodology.md covers all 10 commands with detailed workflows
- [ ] methodology.md documents all 3 agents (debugger, reviewer, architect) in summary form
- [ ] methodology.md includes installation section
- [ ] README.md has detailed installation with prerequisites
- [ ] README.md has expanded command descriptions with examples
- [ ] README.md documents architecture mode, revert, debugging, coverage
- [ ] README.md has troubleshooting and contributing sections
- [ ] index.html has installation/getting-started section
- [ ] index.html has all 10 commands listed
- [ ] index.html has revert, debugging, review, and coverage sections
- [ ] index.html has chat-driven development problems section
- [ ] All three files are internally consistent
- [ ] index.html maintains existing visual design system

## Non-Goals
- No changes to skill SKILL.md files
- No changes to agent .md files (debugger, reviewer, architect)
- No changes to templates
- No new features or commands — documentation only
- No changes to plugin.json or build scripts

## Technical Approach
Update pure markdown and HTML files. No code dependencies. Follow source-of-truth hierarchy: update methodology.md first, then derive README.md and index.html content from it.

## Open Questions
- None — scope is clear from the feature audit above.
