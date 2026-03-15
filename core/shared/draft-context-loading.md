# Draft Context Loading

Standard procedure for loading Draft project context. All Draft commands that read project context follow this procedure before analysis or execution.

Referenced by: `/draft:bughunt`, `/draft:deep-review`, `/draft:review`, `/draft:learn`, `/draft:new-track`, `/draft:implement`, `/draft:init` (refresh), and others

## Base Context Files

If `draft/` directory exists, read and internalize these files in order:

| Priority | File | Purpose | Fallback |
|----------|------|---------|----------|
| 1 | `draft/.ai-context.md` | Module boundaries, dependencies, critical invariants, concurrency model, error handling, data flows | `draft/architecture.md` (legacy projects) |
| 2 | `draft/tech-stack.md` | Frameworks, libraries, constraints, **Accepted Patterns** | — |
| 3 | `draft/product.md` | Product vision, user flows, requirements, **Guidelines** | — |
| 4 | `draft/workflow.md` | Team conventions, testing preferences | — |
| 5 | `draft/guardrails.md` | Hard guardrails, **Learned Conventions**, **Learned Anti-Patterns** | `draft/workflow.md` `## Guardrails` (legacy) |

## Special Sections to Honor

### Accepted Patterns (`tech-stack.md` → `## Accepted Patterns`)

Patterns listed here are **intentional design decisions**. Do NOT flag these as bugs, issues, or violations. They represent deliberate trade-offs documented by the team.

### Guardrails (`guardrails.md`)

Three types of guardrails, each with different enforcement behavior:

| Section | Behavior |
|---------|----------|
| **Hard Guardrails** (checked `[x]`) | Always flag violations as issues |
| **Learned Conventions** | Skip these patterns during analysis — they are verified intentional patterns |
| **Learned Anti-Patterns** | Always flag these patterns — they are verified problematic patterns |
| **Hard Guardrails** (unchecked `[ ]`) | Ignore (not enforced) |

**Legacy fallback:** If `draft/guardrails.md` does not exist, check `draft/workflow.md` for a `## Guardrails` section and enforce checked items there. Suggest running `/draft:learn migrate` to move to the new format.

### Critical Invariants (`.ai-context.md` → `## Critical Invariants`)

Invariants covering data safety, security, concurrency, ordering, and idempotency. Check for violations across all relevant code paths.

## Track Context (when scoped to a track)

If analyzing a specific track, also load:

| File | Purpose |
|------|---------|
| `draft/tracks/<id>/spec.md` | Requirements, acceptance criteria, edge cases |
| `draft/tracks/<id>/plan.md` | Implementation tasks, phases, dependencies |

Use track context to:
- Verify implemented features match spec requirements
- Check edge cases listed in spec are handled
- Focus analysis on files modified/created by the track

## Degradation Behavior

| Scenario | Behavior |
|----------|----------|
| No `draft/` directory | Proceed with code-only analysis (no context enrichment) |
| `.ai-context.md` missing | Fall back to `draft/architecture.md` if it exists |
| `tech-stack.md` missing | Skip framework-specific checks |
| `product.md` missing | Skip product requirement verification |
| `workflow.md` missing | Skip workflow preferences |
| `guardrails.md` missing | Fall back to `workflow.md ## Guardrails`; if neither exists, skip guardrail enforcement |
| Track files missing | Warn and proceed with project-level scope |

## Context-Enriched Analysis

Once loaded, Draft context enables analysis that pure code reading cannot:

- **Architecture violations** — Coupling or boundary violations against intended module structure
- **Framework-specific checks** — Anti-patterns for the specific frameworks in tech-stack.md
- **Product requirement bugs** — Behavior that contradicts product.md user flows
- **Invariant violations** — Data safety, security, concurrency, ordering, idempotency violations
- **Concurrency analysis** — Race conditions and deadlocks informed by the documented concurrency model
- **Error handling gaps** — Missing failure modes against documented failure recovery matrix
- **State machine violations** — Invalid transitions, missing guards, states with no exit
- **Consistency boundary bugs** — Stale reads, lost events at eventual-consistency seams
- **Guardrail violations** — Checked hard guardrails and learned anti-patterns from guardrails.md
- **False positive suppression** — Learned conventions and accepted patterns are skipped during analysis
