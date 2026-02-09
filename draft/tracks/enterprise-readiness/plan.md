# Plan: Enterprise Readiness Features

**Track ID:** enterprise-readiness
**Spec:** ./spec.md
**Status:** [~] In Progress

## Overview

Implement 11 enterprise features from RECOMMENDATIONS.md to achieve Fortune 500 adoption readiness. Work organized into 4 phases: foundation (Red Flags), templates, new skill (ADR), and documentation polish.

---

## Phase 1: Add Red Flags to All Skills
**Goal:** Establish guardrails across all 12 skills to prevent common mistakes
**Verification:** All SKILL.md files contain "## Red Flags - STOP if you're:" section

### Tasks
- [x] **Task 1.1:** Add Red Flags section to skills/bughunt/SKILL.md `8358984`
  - Files: `skills/bughunt/SKILL.md`
  - Red flags: hunting without context, reporting without reproduction, fixing without understanding root cause

- [x] **Task 1.2:** Add Red Flags section to skills/draft/SKILL.md `ba4f8f6`
  - Files: `skills/draft/SKILL.md`
  - Red flags: jumping to implementation, not reading existing context, skipping command guidance

- [x] **Task 1.3:** Add Red Flags section to skills/implement/SKILL.md `a4e27af`
  - Files: `skills/implement/SKILL.md`
  - Red flags: implementing without approved plan, skipping TDD when enabled, marking complete without verification

- [x] **Task 1.4:** Add Red Flags section to skills/init/SKILL.md `dc3ddaa`
  - Files: `skills/init/SKILL.md`
  - Red flags: re-initializing without confirmation, skipping brownfield analysis, rushing through product questions

- [x] **Task 1.5:** Add Red Flags section to skills/jira-create/SKILL.md `9994453`
  - Files: `skills/jira-create/SKILL.md`
  - Red flags: creating without preview review, no MCP configured, creating duplicates

- [x] **Task 1.6:** Add Red Flags section to skills/jira-preview/SKILL.md `5a3f302`
  - Files: `skills/jira-preview/SKILL.md`
  - Red flags: generating without approved plan, inconsistent story points, missing sub-tasks

- [x] **Task 1.7:** Add Red Flags section to skills/index/SKILL.md `c03719d` (bonus)

- [x] **Task 1.8:** Add Red Flags section to skills/review/SKILL.md `2b96e58` (bonus)

---

## Phase 2: Enhance Spec Template with Enterprise Sections
**Goal:** Add enterprise-grade sections to spec template
**Verification:** core/templates/spec.md includes all 4 new sections; new-track skill references them

### Tasks
- [ ] **Task 2.1:** Add Success Metrics section to spec template
  - Files: `core/templates/spec.md`
  - Content: Performance, Quality, Business, UX metrics with examples

- [ ] **Task 2.2:** Add Stakeholder & Approvals section to spec template
  - Files: `core/templates/spec.md`
  - Content: Role table, approval gates checklist

- [ ] **Task 2.3:** Add Risk Assessment section to spec template
  - Files: `core/templates/spec.md`
  - Content: Risk matrix with probability/impact/mitigation, scoring guide

- [ ] **Task 2.4:** Add Deployment Strategy section to spec template
  - Files: `core/templates/spec.md`
  - Content: Rollout phases, feature flag, rollback plan, monitoring

- [ ] **Task 2.5:** Add Tech Debt Log section to implement skill
  - Files: `skills/implement/SKILL.md`
  - Content: Debt tracking table, payback policy

- [ ] **Task 2.6:** Enhance validate skill with OWASP security checks
  - Files: `skills/validate/SKILL.md`
  - Content: OWASP Top 10 checklist (SQL injection, XSS, CSRF, auth, authz, secrets, input validation, logging)

---

## Phase 3: Create ADR Skill
**Goal:** Add Architecture Decision Records command
**Verification:** /draft:adr creates ADR files with proper template

### Tasks
- [ ] **Task 3.1:** Create skills/adr/SKILL.md with YAML frontmatter
  - Files: `skills/adr/SKILL.md`
  - Content: name, description, trigger patterns

- [ ] **Task 3.2:** Add ADR execution instructions
  - Files: `skills/adr/SKILL.md`
  - Content: Pre-checks, ADR template, numbering logic, file creation

- [ ] **Task 3.3:** Add Red Flags section to ADR skill
  - Files: `skills/adr/SKILL.md`
  - Content: common ADR mistakes

- [ ] **Task 3.4:** Update README with ADR command documentation
  - Files: `README.md`
  - Content: Add /draft:adr section under Commands

- [ ] **Task 3.5:** Run build-integrations.sh to regenerate integration files
  - Depends on: Task 3.1, 3.2, 3.3
  - Command: `./scripts/build-integrations.sh`

---

## Phase 4: Documentation & Polish
**Goal:** Add visual diagrams and real-world examples
**Verification:** methodology.md has Mermaid diagrams; README has example walkthrough

### Tasks
- [ ] **Task 4.1:** Add Mermaid workflow visualization to methodology.md
  - Files: `core/methodology.md`
  - Content: graph TD showing init → new-track → implement flow

- [ ] **Task 4.2:** Add context hierarchy diagram to methodology.md
  - Files: `core/methodology.md`
  - Content: graph LR showing product → tech-stack → architecture → spec → plan

- [ ] **Task 4.3:** Add real-world example section to README
  - Files: `README.md`
  - Content: Example walkthrough showing spec, plan, implementation snippets

- [ ] **Task 4.4:** Standardize Red Flags format verification
  - Files: all `skills/*/SKILL.md`
  - Action: Verify consistent format across all skills

- [ ] **Task 4.5:** Final integration rebuild and validation
  - Depends on: All previous tasks
  - Command: `./scripts/build-integrations.sh`
  - Verification: Check generated files reflect all changes

---

## Notes

- Phase 1 and Phase 2 can run in parallel
- Phase 3 depends on Phase 1 completion (ADR needs Red Flags pattern)
- Phase 4 should be last to capture all changes in examples
- Run build-integrations.sh after any skill file changes
