---
name: incident-response
description: Incident management lifecycle — triage, communicate, mitigate, postmortem. Three modes — new (start incident), update (status update), postmortem (blameless RCA report).
---

# Incident Response

You are managing an incident using Draft's Context-Driven Development methodology. This skill covers the full incident lifecycle from triage through postmortem.

## Red Flags - STOP if you're:

- Investigating before mitigating (restore service first)
- Skipping severity classification
- Writing a postmortem that assigns blame to individuals
- Not communicating status updates at defined intervals
- Making changes to production without documenting them
- Assuming root cause without evidence

**Mitigate first. Communicate always. Blame never.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context

Read and follow the base procedure in `core/shared/draft-context-loading.md`.

**Incident-specific context application:**
- Use `draft/.ai-context.md` for system architecture, dependencies, failure modes
- Use `draft/tech-stack.md` for infrastructure, monitoring, alerting tools
- Use `draft/workflow.md` for escalation paths, communication channels
- Use `draft/product.md` for user impact assessment

If `draft/` does not exist, proceed without project context. Warn: "No Draft context — incident response will lack architectural context."

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:incident-response new` | Start a new incident |
| `/draft:incident-response new <description>` | Start incident with initial description |
| `/draft:incident-response update <incident-id>` | Post status update to existing incident |
| `/draft:incident-response postmortem <incident-id>` | Generate blameless postmortem report |
| `/draft:incident-response` | Interactive — ask which mode |

### Mode Selection (No Arguments)

```
Incident Response modes:
1. new        — Start a new incident (triage, communicate, mitigate)
2. update     — Post status update to an existing incident
3. postmortem — Generate blameless postmortem / RCA report

Select mode (1-3):
```

---

## Mode: NEW — Start Incident

### Step 2: Triage

#### 2.1: Classify Severity

| Severity | Definition | Response Time | Update Frequency |
|----------|------------|---------------|------------------|
| **P1 — Critical** | Service down, data loss, security breach, revenue impact | Immediate | Every 15 minutes |
| **P2 — Major** | Significant degradation, feature broken for many users | < 30 minutes | Every 30 minutes |
| **P3 — Minor** | Partial degradation, workaround available | < 2 hours | Every 2 hours |
| **P4 — Low** | Cosmetic, minor inconvenience, no workaround needed | Next business day | Daily |

Ask the developer to confirm severity:
```
Incident severity assessment:

Impact: [who/what is affected]
Scope: [how many users/systems]
Workaround: [available / not available]

Recommended severity: P[N] — [justification]

Confirm severity (P1-P4):
```

#### 2.2: Assign Incident ID

Generate incident ID from timestamp:
```bash
echo "INC-$(date +%Y%m%d-%H%M)"
```

#### 2.3: Document Initial State

Capture immediately:
- **What's broken:** Exact symptoms, error messages, affected endpoints
- **When it started:** First alert time, first user report, or discovery time
- **Who's affected:** Users, systems, downstream services
- **Current impact:** Revenue, data, user experience, SLA

---

### Step 3: Communicate

#### 3.1: Initial Communication

Generate initial incident notification:

```markdown
## Incident: [INC-ID]

**Severity:** P[N]
**Status:** Investigating
**Started:** [timestamp]
**Impact:** [description of user/system impact]

**Summary:** [1-2 sentence description of the incident]

**Current actions:**
- [what's being done right now]

**Next update:** [time based on severity update frequency]
```

#### 3.2: Stakeholder Identification

Based on severity and `draft/workflow.md`:
- **P1:** Engineering lead, on-call, product owner, support team
- **P2:** On-call engineer, team lead
- **P3:** On-call engineer
- **P4:** Ticket created, assigned to team

---

### Step 4: Gather Evidence

Before attempting any fix:

1. **Capture current state:**
   - Error logs (last 30 minutes)
   - Metrics dashboards (screenshot or key values)
   - Recent deployments (within last 24 hours)
   - Recent config changes

2. **Timeline construction:**
   ```
   INCIDENT TIMELINE: [INC-ID]
   ═══════════════════════════════════════════════════════════
   [timestamp] — First alert / user report
   [timestamp] — Incident declared, severity P[N]
   [timestamp] — [action taken]
   [timestamp] — [observation]
   ```

3. **Check recent deployments:**
   ```bash
   git log --oneline --since="24 hours ago"
   ```

---

### Step 5: Mitigate

**Priority: Restore service first, investigate later.**

#### 5.1: Mitigation Strategy

Apply in order of preference (rollback first per ops best practices):

| Priority | Strategy | When to Use |
|----------|----------|-------------|
| 1 | **Rollback** | Recent deployment correlated with incident |
| 2 | **Feature flag disable** | Issue isolated to a specific feature |
| 3 | **Scale up** | Capacity-related degradation |
| 4 | **Failover** | Infrastructure failure |
| 5 | **Hotfix** | When rollback isn't possible and root cause is clear |
| 6 | **Workaround** | Temporary measure while fix is developed |

#### 5.2: Mitigation Execution

For each mitigation action:
1. **Announce:** "Attempting [mitigation strategy]"
2. **Execute:** Run the mitigation
3. **Verify:** Confirm impact is reduced
4. **Document:** Add to timeline with result

#### 5.3: Verify Mitigation

- [ ] Primary symptom resolved
- [ ] Error rate returning to baseline
- [ ] Key user flows working
- [ ] No new issues introduced by mitigation

---

### Step 6: Save Incident Record

Create incident file at `draft/incidents/incident-<INC-ID>.md`:

```bash
mkdir -p draft/incidents
```

```markdown
---
incident_id: "[INC-ID]"
severity: "P[N]"
status: "mitigated"  # investigating | mitigated | resolved | postmortem-complete
started: "[ISO timestamp]"
mitigated: "[ISO timestamp]"
resolved: null
root_cause: null
---

# Incident: [INC-ID]

## Summary

**Severity:** P[N]
**Status:** Mitigated
**Impact:** [description]
**Duration:** [start to mitigation time]

## Timeline

| Time | Event |
|------|-------|
| [timestamp] | [event] |

## Mitigation

**Strategy:** [what was done]
**Verification:** [evidence it worked]

## Next Steps

- [ ] Root cause investigation
- [ ] Postmortem (run `/draft:incident-response postmortem [INC-ID]`)
- [ ] Preventive measures
```

---

## Mode: UPDATE — Status Update

### Step 2: Load Incident

1. Read `draft/incidents/incident-<INC-ID>.md`
2. If not found, list available incidents:
   ```bash
   ls draft/incidents/incident-*.md 2>/dev/null
   ```

### Step 3: Gather Update

Ask developer:
- What changed since last update?
- Current status (investigating / mitigated / resolved)?
- Any new findings?

### Step 4: Generate Status Update

```markdown
## Status Update: [INC-ID] — [timestamp]

**Severity:** P[N]
**Status:** [current status]
**Duration:** [elapsed time]

**Since last update:**
- [what changed]

**Current state:**
- [current situation]

**Next actions:**
- [what's planned]

**Next update:** [time]
```

### Step 5: Update Incident Record

Append the status update to the incident file's timeline section.

---

## Mode: POSTMORTEM — Blameless RCA Report

### Step 2: Load Incident

1. Read `draft/incidents/incident-<INC-ID>.md`
2. Read full timeline and all status updates
3. If incident not found: "Incident [INC-ID] not found. Create it first with `/draft:incident-response new`"

### Step 3: Root Cause Analysis

#### 3.1: 5 Whys Analysis

Apply the 5 Whys technique to find root cause:

```
WHY 1: Why did the service go down?
→ [answer]

WHY 2: Why did [answer to Why 1] happen?
→ [answer]

WHY 3: Why did [answer to Why 2] happen?
→ [answer]

WHY 4: Why did [answer to Why 3] happen?
→ [answer]

WHY 5: Why did [answer to Why 4] happen?
→ [ROOT CAUSE]
```

#### 3.2: Root Cause Classification

| Category | Examples |
|----------|---------|
| **Code defect** | Logic error, missing validation, race condition |
| **Configuration** | Wrong env var, misconfigured service, expired cert |
| **Infrastructure** | Hardware failure, capacity, network partition |
| **Dependency** | Third-party service outage, API change |
| **Process** | Missing review, skipped test, incomplete migration |
| **Human error** | Misapplied change, wrong environment targeted |

#### 3.3: Contributing Factors

Identify factors that amplified the incident:
- Detection delay (monitoring gaps)
- Response delay (unclear runbook, missing on-call)
- Mitigation delay (no rollback path, manual process)
- Communication gap (stakeholders not notified)

### Step 4: Generate Postmortem

**MANDATORY: Include YAML frontmatter with git metadata.** Follow the procedure in `core/shared/git-report-metadata.md` to gather git info, generate frontmatter, and include the report header table. Use `generated_by: "draft:incident-response"`.

```markdown
[YAML frontmatter — see core/shared/git-report-metadata.md]

# Postmortem: [INC-ID] — [Incident Title]

[Report header table — see core/shared/git-report-metadata.md]

## Incident Summary

| Field | Value |
|-------|-------|
| Incident ID | [INC-ID] |
| Severity | P[N] |
| Duration | [total time from start to resolution] |
| Impact | [user/system impact description] |
| Root Cause | [one-sentence root cause] |
| Root Cause Category | [from classification table] |

## Timeline

| Time | Event | Actor |
|------|-------|-------|
| [timestamp] | [event] | [person/system] |

## Root Cause Analysis

### 5 Whys

[5 Whys analysis from Step 3.1]

### Contributing Factors

- [Factor 1]: [how it amplified the incident]
- [Factor 2]: [how it amplified the incident]

## What Went Well

- [Positive aspect 1]
- [Positive aspect 2]

## What Went Wrong

- [Failure 1]
- [Failure 2]

## Action Items

| Priority | Action | Owner | Due Date | Status |
|----------|--------|-------|----------|--------|
| P1 | [preventive action] | [assignee] | [date] | [ ] |
| P2 | [improvement] | [assignee] | [date] | [ ] |
| P3 | [nice-to-have] | [assignee] | [date] | [ ] |

## Lessons Learned

1. [Lesson 1]
2. [Lesson 2]
3. [Lesson 3]
```

### Step 5: Save Postmortem

Save to `draft/incidents/postmortem-<INC-ID>.md`

Update the incident record:
- Set `status: "postmortem-complete"`
- Set `resolved: "[ISO timestamp]"`
- Set `root_cause: "[one-sentence root cause]"`

### Step 6: Present Results

```
Postmortem generated.

Incident: [INC-ID]
Severity: P[N]
Duration: [total time]
Root Cause: [one-sentence]
Category: [classification]
Action Items: [N] items ([M] P1, [K] P2)

Postmortem: draft/incidents/postmortem-[INC-ID].md
Incident record: draft/incidents/incident-[INC-ID].md (updated)

Next steps:
1. Review postmortem with team
2. Assign action item owners and due dates
3. Track action item completion
4. Consider running /draft:learn to capture patterns
```

---

## Cross-Skill Dispatch

### Inbound

- **Triggered by `/draft:new-track`** — when track type is `incident`
- **Triggered by `/draft:deploy-checklist`** — when rollback is triggered during deployment

### Outbound

- **Feeds `/draft:new-track`** — action items from postmortem become new tracks for preventive work
- **Feeds `/draft:learn`** — incident patterns (root causes, contributing factors) feed into guardrails
- **Jira sync:** If ticket linked, attach incident report and post status updates via `core/shared/jira-sync.md`
- **References `core/agents/rca.md`** — for root cause analysis methodology
- **References `core/agents/ops.md`** — for operational best practices

---

## Error Handling

### No Incidents Directory

```
No incidents directory found. Creating draft/incidents/.
```

### Incident Not Found

```
Incident [INC-ID] not found.

Available incidents:
- [INC-ID-1] — [title] (P[N], [status])
- [INC-ID-2] — [title] (P[N], [status])

Specify a valid incident ID or create a new one: /draft:incident-response new
```

### Missing Timeline Data

```
Incident [INC-ID] has incomplete timeline data.

For an accurate postmortem, please provide:
- [missing data point 1]
- [missing data point 2]

Generate postmortem with available data anyway? [yes/no]
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Investigate before mitigating | Restore service first, investigate later |
| Assign blame to individuals | Focus on systems and processes |
| Skip status updates | Communicate at defined intervals |
| Make undocumented production changes | Log every action in the timeline |
| Rush the postmortem | Be thorough — the goal is prevention |
| Ignore contributing factors | Amplifiers are as important as root cause |

---

## Examples

### Start a new incident
```bash
/draft:incident-response new "Payment processing failing with 503 errors"
```

### Post status update
```bash
/draft:incident-response update INC-20260315-1430
```

### Generate postmortem
```bash
/draft:incident-response postmortem INC-20260315-1430
```

### Interactive mode
```bash
/draft:incident-response
```
