# Draft Context Loading

Standard procedure for loading Draft project context. All Draft commands that read project context follow this procedure before analysis or execution.

Referenced by: `/draft:bughunt`, `/draft:deep-review`, `/draft:review`, `/draft:learn`, `/draft:new-track`, `/draft:implement`, `/draft:init` (refresh), and others

## Context Loading Layers

Draft uses a layered context system inspired by memory tiering — compact, always-available context at the top, with progressively deeper context loaded on demand.

### Layer 0: Project Profile (Always Loaded)

If `draft/.ai-profile.md` exists, **always** read it first. This ultra-compact file (20-50 lines) provides the minimum context every command needs: language, framework, database, auth, API style, critical invariants, safety rules, active tracks, and recent changes.

- **Always loaded** regardless of task complexity
- **Purpose**: Enables simple tasks (quick edits, config changes, small fixes) without loading full context
- **Fallback**: If `.ai-profile.md` does not exist, proceed to Layer 1

### Layer 1: Base Context Files

If `draft/` directory exists, read and internalize these files in order:

| Priority | File | Purpose | Fallback |
|----------|------|---------|----------|
| 1 | `draft/.ai-context.md` | Module boundaries, dependencies, critical invariants, concurrency model, error handling, data flows | `draft/architecture.md` (legacy projects) |
| 2 | `draft/tech-stack.md` | Frameworks, libraries, constraints, **Accepted Patterns** | — |
| 3 | `draft/product.md` | Product vision, user flows, requirements, **Guidelines** | — |
| 4 | `draft/workflow.md` | Team conventions, testing preferences | — |
| 5 | `draft/guardrails.md` | Hard guardrails, **Learned Conventions**, **Learned Anti-Patterns** | `draft/workflow.md` `## Guardrails` (legacy) |

### Layer 2: Fact Registry (When Available)

If `draft/.state/facts.json` exists, it provides granular fact-level context:

- **For refresh operations**: Load facts sourced from changed files to enable contradiction detection
- **For quality commands**: Load facts by category relevant to the current analysis dimension
- **For implementation**: Load facts related to files being modified (match via `source_files`)

Facts are NOT loaded in full for every command — use relevance filtering (see below).

## Relevance-Scored Context Loading

Not all context is equally relevant to every task. When a specific track or task is active, apply relevance scoring to prioritize which context sections are most useful.

### When to Apply

Apply relevance scoring when ALL of these conditions are true:
1. A specific track or task is active (has `spec.md` and/or `plan.md`)
2. `draft/.ai-context.md` exists and is >200 lines
3. The command benefits from focused context (`/draft:implement`, `/draft:bughunt`, `/draft:review`)

Do NOT apply relevance scoring for commands that need full context (`/draft:init`, `/draft:deep-review`, `/draft:decompose`).

### Scoring Procedure

1. **Extract key concepts** from the active task:
   - Read `spec.md` acceptance criteria and extract domain terms
   - Read `plan.md` current task description and extract file paths, module names, technology terms
   - Identify the primary concern: data flow, UI, API, security, performance, configuration, etc.

2. **Score `.ai-context.md` sections** against the task concepts:

   | Section | Load When Task Involves... |
   |---------|--------------------------|
   | `## META` | Always (baseline) |
   | `## GRAPH:COMPONENTS` | Module boundary changes, new components |
   | `## GRAPH:DEPENDENCIES` | Integration work, new external dependencies |
   | `## GRAPH:DATAFLOW` | Data pipeline changes, new flows |
   | `## INVARIANTS` | Always (safety critical) |
   | `## INTERFACES` | API changes, new implementations |
   | `## CATALOG:*` | Implementation work matching the category |
   | `## THREADS` | Concurrency-related tasks |
   | `## CONFIG` | Configuration changes |
   | `## ERRORS` | Error handling tasks |
   | `## CONCURRENCY` | Any async/parallel work |
   | `## EXTEND:*` | Adding new implementations of existing patterns |
   | `## TEST` | Always (need test commands) |
   | `## FILES` | Always (need file locations) |
   | `## VOCAB` | Domain-specific tasks |

3. **Always include**: `META`, `INVARIANTS`, `TEST`, `FILES` (minimum context floor)
4. **Include if relevant**: All other sections scored against task concepts
5. **Result**: A focused subset of `.ai-context.md` that maximizes signal-to-noise for the current task

### Fact Registry Relevance

When `draft/.state/facts.json` exists, also load relevant facts:

1. **By file overlap**: Facts whose `source_files` overlap with files the current task will modify
2. **By category**: Facts in categories matching the task's primary concern
3. **By recency**: Prefer facts with recent `last_active_at` timestamps (active code areas)
4. **Limit**: Load at most 20 relevant facts per task to stay within token budget

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
| `.ai-profile.md` missing | Skip Layer 0; proceed directly to Layer 1 context loading |
| `.ai-context.md` missing | Fall back to `draft/architecture.md` if it exists |
| `tech-stack.md` missing | Skip framework-specific checks |
| `product.md` missing | Skip product requirement verification |
| `workflow.md` missing | Skip workflow preferences |
| `guardrails.md` missing | Fall back to `workflow.md ## Guardrails`; if neither exists, skip guardrail enforcement |
| `facts.json` missing | Skip Layer 2; no fact-level context available |
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
