---
project: "{PROJECT}"
track_id: "{TRACK_ID}"
jira_key: "{JIRA_KEY}"
generated: "{ISO_TIMESTAMP}"
git:
  branch: "{GIT_BRANCH}"
  remote: "{GIT_REMOTE}"
  commit: "{GIT_COMMIT}"
  author: "{GIT_AUTHOR}"
  timestamp: "{GIT_TIMESTAMP}"
---

# Root Cause Analysis: {TITLE}

| Field | Value |
|-------|-------|
| **Branch** | `{GIT_BRANCH}` |
| **Commit** | `{GIT_COMMIT}` |
| **Generated** | {ISO_TIMESTAMP} |
| **Synced To** | {JIRA_KEY} |

---

## Summary

<!-- 2-3 sentence description of what happened, what was affected, and the resolution status -->

{SUMMARY}

---

## Classification

| Attribute | Value |
|-----------|-------|
| **Type** | {BUG_TYPE: regression / logic-error / race-condition / integration-failure / data-corruption / config-error / performance-degradation} |
| **Severity** | {SEVERITY: SEV1 / SEV2 / SEV3 / SEV4} |
| **Detection Lag** | {DETECTION_LAG: time between introduction and detection} |
| **SLO Impact** | {SLO_IMPACT: which SLOs were affected and by how much} |

---

## Evidence Gathered

| # | Evidence | Source | Relevance |
|---|----------|--------|-----------|
| 1 | {EVIDENCE_1} | {SOURCE_1} | {RELEVANCE_1} |
| 2 | {EVIDENCE_2} | {SOURCE_2} | {RELEVANCE_2} |
| 3 | {EVIDENCE_3} | {SOURCE_3} | {RELEVANCE_3} |

---

## Timeline

| Time | Event | Actor |
|------|-------|-------|
| {T0} | {TRIGGERING_EVENT} | {ACTOR} |
| {T1} | {DETECTION_EVENT} | {ACTOR} |
| {T2} | {INVESTIGATION_START} | {ACTOR} |
| {T3} | {MITIGATION_APPLIED} | {ACTOR} |
| {T4} | {RESOLUTION_CONFIRMED} | {ACTOR} |

---

## 5 Whys

1. **Why did the issue occur?**
   {WHY_1}

2. **Why did {WHY_1_SHORT} happen?**
   {WHY_2}

3. **Why did {WHY_2_SHORT} happen?**
   {WHY_3}

4. **Why did {WHY_3_SHORT} happen?**
   {WHY_4}

5. **Why did {WHY_4_SHORT} happen?**
   {WHY_5} ← **Root Cause**

---

## Blast Radius

<!-- What was affected by this issue? Scope the impact precisely. -->

- **Users affected:** {USER_IMPACT}
- **Services affected:** {SERVICE_IMPACT}
- **Data affected:** {DATA_IMPACT}
- **Duration:** {DURATION}

---

## Prevention Items

### Detection Improvements

- [ ] {DETECTION_IMPROVEMENT_1}
- [ ] {DETECTION_IMPROVEMENT_2}

### Process Improvements

- [ ] {PROCESS_IMPROVEMENT_1}
- [ ] {PROCESS_IMPROVEMENT_2}

### Code Improvements

- [ ] {CODE_IMPROVEMENT_1}
- [ ] {CODE_IMPROVEMENT_2}

### Architecture Improvements

- [ ] {ARCHITECTURE_IMPROVEMENT_1}
- [ ] {ARCHITECTURE_IMPROVEMENT_2}

---

## Proposed Fix

<!-- Describe the fix, rationale, and files to modify -->

**Approach:** {FIX_DESCRIPTION}

**Rationale:** {FIX_RATIONALE}

**Files to modify:**

- `{FILE_1}` — {CHANGE_1}
- `{FILE_2}` — {CHANGE_2}
- `{FILE_3}` — {CHANGE_3}

---

*generated_by: draft:auto-triage*
