---
name: deploy-checklist
description: Pre-deployment verification checklist. Generates customized checklists based on tech-stack with rollback triggers.
---

# Deploy Checklist

You are generating a pre-deployment verification checklist using Draft's Context-Driven Development methodology.

## Red Flags - STOP if you're:

- Generating a generic checklist without reading tech-stack.md
- Skipping rollback trigger definition
- Not customizing the checklist for the project's actual infrastructure
- Claiming deployment readiness without evidence for each check
- Marking items as passed without actually verifying them

**Customize to this project. Evidence for every check.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context

Read and follow the base procedure in `core/shared/draft-context-loading.md`.

**Deploy-specific context application:**
- Use `draft/tech-stack.md` for infrastructure, CI/CD, hosting, and deployment tooling
- Use `draft/workflow.md` for deployment process, environments, approval gates
- Use `draft/.ai-context.md` for system architecture, external dependencies, data stores

If `draft/` does not exist: **STOP** — "No Draft context found. Run `/draft:init` first."

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:deploy-checklist` | Generate checklist for current active track |
| `/draft:deploy-checklist track <id>` | Generate checklist for specific track |
| `/draft:deploy-checklist full` | Generate comprehensive checklist (all sections expanded) |

### Default Behavior

If no arguments:
- Auto-detect active `[~]` In Progress track from `draft/tracks.md`
- If no active track, generate a project-level deployment checklist

---

## Step 2: Gather Context

### 2.1: Infrastructure Detection

From `draft/tech-stack.md`, identify:
- **Hosting:** Cloud provider (AWS, GCP, Azure), platform (Kubernetes, ECS, Lambda, Vercel, etc.)
- **CI/CD:** Pipeline tool (GitHub Actions, GitLab CI, Jenkins, CircleCI, etc.)
- **Database:** Type and migration strategy
- **Caching:** Redis, Memcached, CDN configuration
- **Monitoring:** APM, logging, alerting tools
- **Feature flags:** LaunchDarkly, Unleash, custom

### 2.2: Deployment History

Check for previous deploy checklists:
```bash
ls draft/tracks/*/deploy-checklist*.md draft/deploy-checklist*.md 2>/dev/null
```

If previous checklists exist, note any recurring issues or custom checks added.

### 2.3: Track Context (if track-level)

If deploying a specific track:
- Read `draft/tracks/<id>/spec.md` for requirements that affect deployment
- Read `draft/tracks/<id>/plan.md` for completed tasks and their scope
- Read `draft/tracks/<id>/review-report-latest.md` (if exists) for review findings

---

## Step 3: Generate Checklist

Generate a three-phase checklist customized to the project's tech stack.

### Phase 1: Pre-Deploy

#### Code Readiness
- [ ] All tests passing (`make test` or equivalent)
- [ ] No Critical or Important issues from last review
- [ ] All acceptance criteria verified (track-level)
- [ ] Code coverage meets target (check `draft/tracks/<id>/coverage-report-latest.md`)
- [ ] No TODO/FIXME/HACK markers in shipped code (or documented as tech debt)

#### Security
- [ ] No hardcoded secrets, API keys, or credentials in codebase
- [ ] Dependencies scanned for vulnerabilities (`npm audit`, `pip audit`, `cargo audit`, etc.)
- [ ] OWASP Top 10 addressed for new endpoints
- [ ] Authentication and authorization verified for new routes
- [ ] CORS configuration reviewed (if applicable)

#### Database / Data
- [ ] Database migrations tested on staging (if applicable)
- [ ] Migrations are backward-compatible (zero-downtime deploy)
- [ ] Data backups verified before destructive migrations
- [ ] Rollback migration exists and is tested
- [ ] No breaking schema changes without migration path

#### Configuration
- [ ] Environment variables set in target environment
- [ ] Feature flags configured for gradual rollout (if applicable)
- [ ] Config values validated at startup
- [ ] Secrets rotated if compromised or expired

#### Dependencies
- [ ] All new dependencies reviewed for license compatibility
- [ ] No known-vulnerable dependencies in lock file
- [ ] Dependency versions pinned (no floating ranges in production)

### Phase 2: Deploy

#### Execution
- [ ] Deploy to staging first, verify functionality
- [ ] Run smoke tests on staging
- [ ] Deploy to production using defined strategy (rolling, blue-green, canary)
- [ ] Monitor deployment progress (no errors in deploy logs)
- [ ] Verify health check endpoints returning 200

#### Canary / Progressive Rollout (if applicable)
- [ ] Initial traffic percentage set (e.g., 5%)
- [ ] Monitoring window defined (e.g., 15 minutes)
- [ ] Success criteria defined for traffic increase
- [ ] Automatic rollback triggers configured

### Phase 3: Post-Deploy

#### Verification
- [ ] Smoke tests passing on production
- [ ] Key user flows verified end-to-end
- [ ] API response times within acceptable range
- [ ] Error rate not elevated (compare to pre-deploy baseline)
- [ ] No new errors in log aggregation

#### Monitoring
- [ ] APM dashboards showing normal performance
- [ ] No spike in error rates or latency
- [ ] Database metrics stable (connections, query time, locks)
- [ ] Memory and CPU usage within bounds
- [ ] Alert thresholds set for new features

#### Communication
- [ ] Deployment noted in team channel / changelog
- [ ] Stakeholders notified (if user-facing change)
- [ ] Documentation updated (if API or behavior changes)

---

## Step 4: Define Rollback Triggers

Based on the deployment, define explicit rollback conditions.

### Rollback Trigger Table

| Trigger | Threshold | Detection | Action |
|---------|-----------|-----------|--------|
| Error rate spike | >2x pre-deploy baseline for 5+ minutes | APM alerting | Immediate rollback |
| Latency degradation | p95 >2x baseline for 10+ minutes | APM alerting | Immediate rollback |
| Health check failure | Any production instance failing | Load balancer health check | Immediate rollback |
| Data integrity issue | Any data corruption detected | Log monitoring / alerts | Immediate rollback + incident |
| Critical user flow broken | Key flow (login, checkout, etc.) failing | Smoke tests / user reports | Immediate rollback |
| Memory / CPU spike | >90% sustained for 5+ minutes | Infrastructure monitoring | Investigate, rollback if escalating |

### Rollback Procedure

```
ROLLBACK PROCEDURE
═══════════════════════════════════════════════════════════

1. DECIDE: Rollback trigger met → Announce in team channel
2. EXECUTE:
   - [ ] Revert deployment (git revert + redeploy, or platform rollback)
   - [ ] Verify rollback deployed (health checks, version endpoint)
   - [ ] Confirm error rate / latency returning to baseline
3. VERIFY:
   - [ ] Smoke tests passing on rolled-back version
   - [ ] No data corruption (check recent transactions/records)
   - [ ] User-facing functionality restored
4. COMMUNICATE:
   - [ ] Update team channel with rollback status
   - [ ] File incident report if user impact occurred
   - [ ] Schedule post-mortem if P1/P2 severity

Rollback command (customize for your platform):
  git revert <deploy-commit> && git push
  # OR
  kubectl rollout undo deployment/<name>
  # OR
  aws ecs update-service --force-new-deployment
```

---

## Step 5: Save Checklist

**MANDATORY: Include YAML frontmatter with git metadata.** Follow the procedure in `core/shared/git-report-metadata.md` to gather git info, generate frontmatter, and include the report header table. Use `generated_by: "draft:deploy-checklist"`.

### Save Location

- **Track-level:** `draft/tracks/<id>/deploy-checklist-<timestamp>.md` (where `<timestamp>` is generated via `date +%Y-%m-%dT%H%M`, e.g., `2026-03-15T1430`)
  ```bash
  ln -sf deploy-checklist-<timestamp>.md draft/tracks/<id>/deploy-checklist-latest.md
  ```

- **Project-level:** `draft/deploy-checklist-<timestamp>.md`
  ```bash
  ln -sf deploy-checklist-<timestamp>.md draft/deploy-checklist-latest.md
  ```

---

## Step 6: Present Results

```
Deploy checklist generated.

Track: [track-id or "project-level"]
Environment: [target environment]
Checklist: [N] items across 3 phases
Rollback triggers: [N] defined

Report: draft/[tracks/<id>/]deploy-checklist-<timestamp>.md
        (symlink: deploy-checklist-latest.md)

Next steps:
1. Review and complete each checklist item with evidence
2. Get deployment approval (if required by workflow.md)
3. Execute deployment following the checklist phases
4. Monitor using post-deploy verification items
```

---

## Cross-Skill Dispatch

### Inbound

- **Suggested by `/draft:implement`** — at track completion
- **Suggested by `/draft:review`** — when review passes for production code

### Outbound

- **References `core/agents/ops.md`** — for operational best practices and runbook integration
- **Suggests `/draft:incident-response`** — if rollback is triggered during deployment
- **Feeds `/draft:learn`** — deployment issues feed back into pattern learning

---

## Error Handling

### Missing Tech Stack

```
Warning: draft/tech-stack.md not found or missing deployment information.
Generating a generic checklist. Customize for your specific infrastructure.
```

### No Active Track

```
No active track found. Generating project-level deployment checklist.
For track-specific checks, specify: /draft:deploy-checklist track <id>
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Use a generic one-size-fits-all checklist | Customize based on tech-stack.md |
| Skip rollback trigger definition | Always define explicit rollback conditions |
| Mark items as passed without evidence | Provide verification output for each check |
| Deploy without completing pre-deploy phase | Complete all phases in order |
| Skip post-deploy monitoring | Monitor for at least the defined window |

---

## Examples

### Generate for active track
```bash
/draft:deploy-checklist
```

### Generate for specific track
```bash
/draft:deploy-checklist track add-user-auth
```

### Comprehensive checklist
```bash
/draft:deploy-checklist full
```
