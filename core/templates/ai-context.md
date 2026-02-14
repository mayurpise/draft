---
project: "{PROJECT_NAME}"
module: "root"
generated_by: "draft:init"
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

# {PROJECT_NAME} Context Map

> Self-contained AI context. 200-400 lines. Token-optimized.
> This file must stand alone — no references to architecture.md or source files needed.

## Architecture

- **Type**: {type} <!-- e.g., gRPC Microservice, CLI tool, library, REST API -->
- **Language**: {language} <!-- e.g., TypeScript 5.3, Python 3.12, Go 1.21 -->
- **Pattern**: {pattern} <!-- e.g., Hexagonal, MVC, Pipeline, Event-driven -->
- **Build**: `{build_command}`
- **Test**: `{test_command}`
- **Entry**: `{entry_file}` → `{entry_function}`
- **Config**: {config_mechanism} <!-- e.g., .env + config.ts, gflags, Viper -->
- **Generational**: {generational} <!-- V1/V2 split or "single generation" -->

## Component Graph

```
{project_root}/
├── {dir1}/           ← {5-10 word description}
│   ├── {subdir}/     ← {description}
│   └── {file}        ← {description}
├── {dir2}/           ← {description}
└── {dir3}/           ← {description}
```

## Dependency Injection / Wiring

{One paragraph or bullets explaining how components find each other.}

Key injection points:
- `{token1}`: {what it provides}
- `{token2}`: {what it provides}
- `{token3}`: {what it provides}

## Critical Invariants (DO NOT BREAK)

- [Data] **{name}**: {one-sentence rule} — enforced at `{file}:{line}`
- [Security] **{name}**: {rule} — enforced at `{file}:{line}`
- [Concurrency] **{name}**: {rule} — enforced at `{file}:{line}`
- [Ordering] **{name}**: {rule} — enforced at `{file}:{line}`
- [Idempotency] **{name}**: {rule} — enforced at `{file}:{line}`
- [Compatibility] **{name}**: {rule} — enforced at `{file}:{line}`

## Interface Contracts (TypeScript-like IDL)

```typescript
// Primary extension interface
interface {InterfaceName} {
  {method}({param}: {Type}): {ReturnType};  // {brief description}
  {optionalMethod}?({param}: {Type}): {ReturnType};
}

// Service contract
interface {ServiceName} {
  {rpcMethod}(req: {RequestType}): Promise<{ResponseType}>;
}
```

## Dependency Graph

```
[{Component}] -> (HTTP) -> [{ExternalService}]
[{Component}] -> (SQL) -> [{Database}]
[{Component}] -> (gRPC) -> [{PeerService}]
[{Component}] -> (queue) -> [{MessageBroker}]
```

## Key Data Sources

| Source | Type | Readers |
|--------|------|---------|
| `{table/topic/endpoint}` | {DB/Queue/API} | `{component1}`, `{component2}` |

## Data Flow Summary

**{FlowName}**: {Source} receives {input}, passes to {Processor} for {transformation}, persists via {Repository} to {Storage}, emits {Event} to {downstream}.

**{FlowName2}**: {Description of another major flow.}

## Error Handling & Failure Recovery

- **{Scenario}**: {Recovery mechanism} — {where handled}
- **{Scenario}**: {Recovery mechanism} — {where handled}
- **Retries**: {policy description}
- **Circuit breaker**: {if applicable}
- **Graceful degradation**: {behavior when dependencies unavailable}

## Concurrency Safety Rules

- **{ComponentName}**: {rule} — violating causes {consequence}
- **{ComponentName}**: {rule} — violating causes {consequence}
- **Lock ordering**: {if applicable}
- **Thread affinity**: {which components are single-threaded}

## Implementation Catalog

### {Category1}

| Name | Type | Description |
|------|------|-------------|
| `{impl1}` | `{Class}` | {brief description} |
| `{impl2}` | `{Class}` | {brief description} |

### {Category2}

| Name | Type | Description |
|------|------|-------------|
| `{impl3}` | `{Class}` | {brief description} |

## V1 ↔ V2 Migration Status

> Skip if no generational split.

| V1 | V2 | Status |
|----|----|----|
| `{v1_impl}` | `{v2_impl}` | {Migrated/Pending/Deprecated} |

**Rule**: When adding new {X}, prefer {V1/V2} because {reason}.

## Thread Pools / Execution Model

| Pool | Count | Purpose |
|------|-------|---------|
| `{pool_name}` | {N} | {what runs on it} |

> For single-threaded: "Single-threaded event loop — N/A"

## Key Configuration

| Flag/Param | Default | Critical? | Purpose |
|------------|---------|-----------|---------|
| `{FLAG_NAME}` | `{value}` | Yes | {description} |
| `{flag_name}` | `{value}` | No | {description} |

## Extension Points — Step-by-Step Cookbooks

### Adding a New {ExtensionType}

1. Create `{path/to/new_file.ext}` (naming: `{convention}`)
2. Implement interface:
   - Required: `{method1}()`, `{method2}()`
   - Optional: `{method3}?()`
3. Register at `{registry_file}:{line}` via `{mechanism}`
4. Add to build: `{build_dep_instruction}`
5. Test: create `{test_path}` covering {scenarios}

### Adding a New {ExtensionType2}

1. {step}
2. {step}
3. {step}

## Testing Strategy

- **Unit**: `{exact_test_command}`
- **Integration**: `{framework}` in `{location}`
- **E2E**: `{command}` (if applicable)
- **Key hooks**: `{injection_point}`, `{mock_pattern}`, `{test_utility}`

## File Layout Quick Reference

- Entry: `{path}`
- Config: `{path}`
- Routes/Handlers: `{path}`
- Services: `{path}`
- Repositories: `{path}`
- Models: `{path}`
- Tests: `{path}`
- Build: `{path}`

## Glossary (Critical Terms Only)

| Term | Definition |
|------|------------|
| {term} | {one-sentence definition} |
| {term} | {one-sentence definition} |

## Draft Integration

- See `draft/tech-stack.md` for accepted patterns and technology decisions
- See `draft/workflow.md` for TDD preferences and guardrails
- See `draft/product.md` for product context and guidelines
