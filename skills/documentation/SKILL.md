---
name: documentation
description: Technical documentation writing and maintenance. Modes — readme, runbook, api, onboarding. Uses writer agent principles for audience-appropriate, maintainable docs.
---

# Documentation

You are generating or updating technical documentation using Draft's Context-Driven Development methodology and writer agent principles.

## Red Flags - STOP if you're:

- Writing documentation without reading the source code first
- Generating docs that duplicate inline code comments verbatim
- Ignoring the target audience (writing for experts when onboarding, or oversimplifying for API reference)
- Not loading project context (tech-stack, architecture) before writing
- Producing stale docs that reference non-existent files, functions, or APIs

**Audience-first. Source-verified. Maintainable.**

---

## Pre-Check

### 0. Capture Git Context

```bash
git branch --show-current    # Current branch name
git rev-parse --short HEAD   # Current commit hash
```

### 1. Load Draft Context

Read and follow the base procedure in `core/shared/draft-context-loading.md`.

**Documentation-specific context application:**
- Use `draft/.ai-context.md` for system architecture, module boundaries, data flows
- Use `draft/tech-stack.md` for language, framework, and tooling specifics
- Use `draft/product.md` for product vision, user types, and domain language
- Use `draft/workflow.md` for development processes, CI/CD, and deployment

If `draft/` does not exist, proceed with code-only documentation. Warn: "No Draft context available — documentation may miss architectural context."

---

## Step 1: Parse Arguments

| Invocation | Behavior |
|------------|----------|
| `/draft:documentation readme` | Generate or update project README |
| `/draft:documentation runbook` | Generate operational runbook |
| `/draft:documentation api` | Generate API reference documentation |
| `/draft:documentation onboarding` | Generate developer onboarding guide |
| `/draft:documentation readme <path>` | Generate README for a specific module/directory |
| `/draft:documentation` | Interactive — ask which mode to use |

### Mode Selection (No Arguments)

If no mode specified, present options:
```
Documentation modes:
1. readme     — Project or module README
2. runbook    — Operational runbook (deploy, monitor, troubleshoot)
3. api        — API reference (endpoints, types, examples)
4. onboarding — Developer onboarding guide (setup, architecture, workflows)

Select mode (1-4):
```

---

## Step 2: Gather Source Material

Each mode has specific source material requirements.

### README Mode

1. **Project-level README:**
   - Read `draft/product.md` for project purpose, features, target users
   - Read `draft/tech-stack.md` for language, framework, prerequisites
   - Read `draft/workflow.md` for development commands (build, test, lint)
   - Scan `package.json`, `Makefile`, `Cargo.toml`, `pyproject.toml` etc. for scripts/commands
   - Check existing README.md for content to preserve or update

2. **Module-level README:**
   - Read `draft/.ai-context.md` for module description, dependencies, interfaces
   - Read source files in the target directory for exports, public API
   - Check for existing README.md in the directory

### Runbook Mode

1. Read `draft/tech-stack.md` for infrastructure, hosting, monitoring tools
2. Read `draft/workflow.md` for deployment process, environments
3. Read `draft/.ai-context.md` for external dependencies, failure modes, data stores
4. Check for existing runbooks in `docs/`, `runbooks/`, `ops/`
5. Read CI/CD configuration files (`.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`)
6. Reference `core/agents/ops.md` for operational best practices

### API Mode

1. Read `draft/.ai-context.md` for API architecture, authentication, versioning
2. Read `draft/tech-stack.md` for API framework, serialization format
3. Scan source code for:
   - Route definitions (Express routes, FastAPI paths, Spring controllers, etc.)
   - Request/response types and schemas
   - Authentication middleware
   - Error response formats
4. Check for existing API docs (OpenAPI/Swagger, Postman collections)
5. Read test files for API endpoints — test cases document expected behavior

### Onboarding Mode

1. Read ALL Draft context files (product, tech-stack, workflow, architecture)
2. Read `draft/guardrails.md` for coding conventions and anti-patterns
3. Read `CONTRIBUTING.md`, `DEVELOPMENT.md` if they exist
4. Scan project root for development setup files (Docker, devcontainers, Makefiles)
5. Read `draft/.ai-context.md` for system architecture overview
6. Check recent `draft/tracks/` for examples of how development work flows

---

## Step 3: Apply Writer Agent Principles

Reference `core/agents/writer.md` for writing guidelines. Apply these principles:

### Audience Awareness

| Mode | Primary Audience | Tone | Depth |
|------|-----------------|------|-------|
| README | New users, evaluators, contributors | Welcoming, clear | Overview + quickstart |
| Runbook | On-call engineers, ops team | Direct, procedural | Step-by-step, no ambiguity |
| API | Developers integrating with the API | Technical, precise | Comprehensive reference |
| Onboarding | New team members | Supportive, structured | Progressive disclosure |

### Writing Principles

1. **Source-verified:** Every claim must trace to actual code, config, or documentation
2. **Audience-first:** Write for the reader's context and goals, not the author's knowledge
3. **Maintainable:** Prefer dynamic references (links to code, generated API docs) over hardcoded details that rot
4. **DRY:** Don't duplicate information that exists elsewhere — link to it
5. **Scannable:** Use headers, bullet points, tables, and code blocks for quick navigation
6. **Actionable:** Every section should help the reader DO something

---

## Step 4: Generate Documentation

### README Output Structure

```markdown
# [Project Name]

[One-sentence description from product.md]

## Features

- [Key feature 1]
- [Key feature 2]
- [Key feature 3]

## Quick Start

### Prerequisites

- [Runtime/language] version [X.Y+]
- [Package manager]
- [Other dependencies]

### Installation

\`\`\`bash
[installation commands]
\`\`\`

### Usage

\`\`\`bash
[basic usage example]
\`\`\`

## Development

### Setup

\`\`\`bash
[dev setup commands]
\`\`\`

### Commands

| Command | Description |
|---------|-------------|
| `make build` | [description] |
| `make test` | [description] |
| `make lint` | [description] |

## Architecture

[Brief architecture overview — link to detailed docs if available]

## Contributing

[Contributing guidelines or link to CONTRIBUTING.md]

## License

[License info]
```

### Runbook Output Structure

```markdown
# Runbook: [Service/System Name]

## Overview

**Service:** [name]
**Owner:** [team]
**Tier:** [P1/P2/P3]
**Dependencies:** [list]

## Architecture

[Brief system diagram or description]
[External dependencies and their SLAs]

## Deployment

### Prerequisites
- [ ] [Pre-deploy check 1]
- [ ] [Pre-deploy check 2]

### Deploy Procedure
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Rollback Procedure
1. [Step 1]
2. [Step 2]

## Monitoring

### Key Metrics
| Metric | Normal Range | Alert Threshold |
|--------|-------------|-----------------|
| [metric] | [range] | [threshold] |

### Dashboards
- [Dashboard name]: [URL]

### Alerts
| Alert | Severity | Runbook Section |
|-------|----------|-----------------|
| [alert] | [severity] | [link] |

## Troubleshooting

### [Common Issue 1]
**Symptoms:** [what you'll see]
**Cause:** [root cause]
**Resolution:** [steps to fix]

### [Common Issue 2]
**Symptoms:** [what you'll see]
**Cause:** [root cause]
**Resolution:** [steps to fix]

## Disaster Recovery

### Data Backup
- **Frequency:** [schedule]
- **Location:** [where]
- **Restore procedure:** [steps]

### Failover
- [Failover procedure]
```

### API Output Structure

```markdown
# API Reference

## Overview

**Base URL:** `[base URL]`
**Authentication:** [method]
**Content-Type:** `application/json`
**Versioning:** [strategy]

## Authentication

[How to authenticate — API keys, OAuth, JWT, etc.]

### Example

\`\`\`bash
curl -H "Authorization: Bearer <token>" [base URL]/endpoint
\`\`\`

## Endpoints

### [Resource Name]

#### [METHOD] [path]

[Description]

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| [param] | [type] | [yes/no] | [description] |

**Request Body:**

\`\`\`json
{
  "field": "value"
}
\`\`\`

**Response:**

\`\`\`json
{
  "field": "value"
}
\`\`\`

**Status Codes:**

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Validation error |
| 401 | Unauthorized |
| 404 | Not found |

**Example:**

\`\`\`bash
curl -X POST [base URL]/path \
  -H "Authorization: Bearer <token>" \
  -d '{"field": "value"}'
\`\`\`

## Error Format

\`\`\`json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description"
  }
}
\`\`\`

## Rate Limiting

[Rate limit details]
```

### Onboarding Output Structure

```markdown
# Developer Onboarding Guide

## Welcome

[Brief project description and mission]

## Day 1: Setup

### Prerequisites
- [Software requirements]
- [Access requirements — repos, services, tools]

### Environment Setup
1. [Step-by-step setup instructions]
2. [Verification: how to confirm setup works]

### First Build
\`\`\`bash
[commands to build and run locally]
\`\`\`

## Day 2: Architecture

### System Overview
[High-level architecture from .ai-context.md]

### Key Modules
| Module | Responsibility | Key Files |
|--------|---------------|-----------|
| [module] | [what it does] | [entry points] |

### Data Flow
[How data moves through the system]

### Key Decisions
[Important architectural decisions and their rationale — link to ADRs if available]

## Day 3: Workflow

### Development Process
[From workflow.md — branching, TDD, review process]

### Coding Conventions
[From guardrails.md and tech-stack.md]

### Common Commands
| Task | Command |
|------|---------|
| Build | `[command]` |
| Test | `[command]` |
| Lint | `[command]` |
| Deploy | `[command]` |

## First Contribution

### Finding Work
- Check `draft/tracks.md` for available tracks
- Look for "good first issue" labels

### Making Changes
1. Create a track: `/draft:new-track <description>`
2. Implement: `/draft:implement`
3. Review: `/draft:review`
4. Submit PR

### Code Review Expectations
[What reviewers look for — from workflow.md and guardrails.md]

## Resources

- [Architecture docs]: `draft/.ai-context.md`
- [Product context]: `draft/product.md`
- [Tech stack]: `draft/tech-stack.md`
- [Coding conventions]: `draft/guardrails.md`
```

---

## Step 5: Review and Save

### CHECKPOINT (MANDATORY)

**STOP.** Present the generated documentation to the developer for review.

- Developer may request additions, removals, or style changes
- **Do NOT save until developer approves**

### Save Location

| Mode | Default Path |
|------|-------------|
| readme (project) | `README.md` (project root) |
| readme (module) | `<path>/README.md` |
| runbook | `draft/docs/runbook.md` |
| api | `draft/docs/api-reference.md` |
| onboarding | `draft/docs/onboarding.md` |

Create `draft/docs/` directory if it doesn't exist:
```bash
mkdir -p draft/docs
```

---

## Step 6: Present Results

```
Documentation generated.

Mode: [readme/runbook/api/onboarding]
Output: [file path]
Sections: [N] sections
Source files consulted: [N]

Next steps:
1. Review the generated document for accuracy
2. Update any placeholder values marked with [brackets]
3. Keep documentation in sync with code changes
```

---

## Cross-Skill Dispatch

### Inbound

- **Suggested by `/draft:init`** — after project initialization, suggest generating docs
- **Suggested by `/draft:implement`** — after track completion, suggest updating docs
- **Suggested by `/draft:decompose`** — architecture changes may require doc updates

### Outbound

- **References `core/agents/writer.md`** — for writing style and principles
- **Feeds `/draft:learn`** — documentation patterns (templates, conventions) can be learned

---

## Error Handling

### No Source Material

```
Insufficient source material for [mode] documentation.

Missing:
- [file/info that's needed]

Generate partial documentation anyway? Or provide the missing context first?
```

### Existing Documentation Conflict

```
Existing [file] found with [N] lines of content.

Options:
1. Replace entirely with generated version
2. Merge — keep existing structure, update outdated sections
3. Append — add new sections without modifying existing content
4. Cancel

Select (1-4):
```

---

## Anti-Patterns

| Don't | Instead |
|-------|---------|
| Copy-paste code comments as documentation | Synthesize higher-level explanations |
| Write documentation without reading source | Verify every claim against actual code |
| Use jargon in onboarding docs | Explain terms or link to glossary |
| Hardcode version numbers, URLs, paths | Use dynamic references where possible |
| Write a wall of text | Use headers, tables, code blocks, bullet points |
| Document implementation details that change often | Document stable interfaces and concepts |

---

## Examples

### Generate project README
```bash
/draft:documentation readme
```

### Generate module README
```bash
/draft:documentation readme src/auth/
```

### Generate operational runbook
```bash
/draft:documentation runbook
```

### Generate API reference
```bash
/draft:documentation api
```

### Generate onboarding guide
```bash
/draft:documentation onboarding
```

### Interactive mode
```bash
/draft:documentation
```
