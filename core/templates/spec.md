---
project: "{PROJECT_NAME}"
module: "root"
track_id: "{TRACK_ID}"
generated_by: "draft:new-track"
generated_at: "{ISO_TIMESTAMP}"
git:
  branch: "{LOCAL_BRANCH}"
  remote: "{REMOTE/BRANCH}"
  commit: "{FULL_SHA}"
  commit_short: "{SHORT_SHA}"
  commit_date: "{COMMIT_DATE}"
  commit_message: "{COMMIT_MESSAGE}"
  dirty: false
synced_to_commit: "{FULL_SHA}"
---

# Specification: [Title]

**Track ID:** {TRACK_ID}
**Created:** {ISO_TIMESTAMP}
**Status:** [ ] Drafting

> This is a working draft. Content will evolve through conversation.

## Context References
- **Product:** `draft/product.md` — [pending]
- **Tech Stack:** `draft/tech-stack.md` — [pending]
- **Architecture:** `draft/.ai-context.md` — [pending]

## Problem Statement
[To be developed through intake conversation]

## Background & Why Now
[To be developed through intake conversation]

## Requirements
### Functional
[To be developed through intake conversation]

### Non-Functional
[To be developed through intake conversation]

## Acceptance Criteria
[To be developed through intake conversation]

## Non-Goals
[To be developed through intake conversation]

## Technical Approach
[To be developed through intake conversation]

## Success Metrics
<!-- Remove metrics that don't apply -->

| Category | Metric | Target | Measurement |
|----------|--------|--------|-------------|
| Performance | [e.g., API response time] | [e.g., <200ms p95] | [e.g., APM dashboard] |
| Quality | [e.g., Test coverage] | [e.g., >90%] | [e.g., CI coverage report] |
| Business | [e.g., User adoption rate] | [e.g., 50% in 30 days] | [e.g., Analytics] |
| UX | [e.g., Task completion rate] | [e.g., >95%] | [e.g., User testing] |

## Stakeholders & Approvals
<!-- Add roles relevant to your organization -->

| Role | Name | Approval Required | Status |
|------|------|-------------------|--------|
| Product Owner | [name] | Spec sign-off | [ ] |
| Tech Lead | [name] | Architecture review | [ ] |
| Security | [name] | Security review (if applicable) | [ ] |
| QA | [name] | Test plan review | [ ] |

### Approval Gates
- [ ] Spec approved by Product Owner
- [ ] Architecture reviewed by Tech Lead
- [ ] Security review completed (if touching auth, data, or external APIs)
- [ ] Test plan reviewed by QA

## Risk Assessment
<!-- Score: Probability (1-5) x Impact (1-5). Risks scoring >=9 require mitigation plans. -->

| Risk | Probability | Impact | Score | Mitigation |
|------|-------------|--------|-------|------------|
| [e.g., Third-party API instability] | 3 | 4 | 12 | [e.g., Circuit breaker + fallback cache] |
| [e.g., Data migration failure] | 2 | 5 | 10 | [e.g., Dry-run migration + rollback script] |
| [e.g., Scope creep] | 3 | 3 | 9 | [e.g., Strict non-goals enforcement] |

## Deployment Strategy
<!-- Define rollout approach for production delivery -->

### Rollout Phases
1. **Canary** (1-5% traffic) — Validate core flows, monitor error rates
2. **Limited GA** (25%) — Expand to subset, watch performance metrics
3. **Full GA** (100%) — Complete rollout

### Feature Flags
- Flag name: `[feature_flag_name]`
- Default: `off`
- Kill switch: [yes/no]

### Rollback Plan
- Trigger: [e.g., error rate >1%, latency >500ms p95]
- Process: [e.g., disable feature flag, revert deployment]
- Data rollback: [e.g., migration revert script, N/A]

### Monitoring
- Dashboard: [link or name]
- Alerts: [e.g., PagerDuty rule for error rate spike]
- Key metrics: [e.g., error rate, latency, throughput]

## Open Questions
[Tracked during conversation]

## Conversation Log
> Key decisions and reasoning captured during intake.

[Conversation summary will be added here]
